local sss = game:GetService("ServerScriptService")
local rs = game:GetService("ReplicatedStorage")

local data_handler = require(sss.data_handler)
local sensitive_list = require(sss.sensitive_list)
local network = require(sss.network_server)
local catalog = require(rs.ability_catalog)
local ability_rates = require(sss.ability_rates)

local ability_shop = {}

local function owned_list(profile)
    local owned = {}
    for id, value in profile.Data.owned_abilities do
        if value then
            table.insert(owned, tostring(id))
        end
    end
    return owned
end

local function equipped_map(profile)
    local equipped = profile.Data.equipped_abilities
    if not equipped then
        equipped = {}
        profile.Data.equipped_abilities = equipped
    end
    return equipped
end

local function equipped_list(profile)
    local map = equipped_map(profile)
    local equipped = {}
    local max_active = catalog.max_active or 1
    for id, value in map do
        if value then
            if #equipped < max_active then
                table.insert(equipped, tostring(id))
            else
                map[id] = nil
            end
        end
    end
    return equipped
end

local function equipped_count(profile)
    local count = 0
    for _, value in equipped_map(profile) do
        if value then
            count += 1
        end
    end
    return count
end

local function set_gold(player, profile)
    local gold_stat = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Gold")
    if gold_stat then
        gold_stat.Value = profile.Data.gold
    end
end

local function fail(message, gold)
    return {
        ok = false,
        message = message,
        gold = gold or 0,
        rolls = {},
    }
end

local pity_rarities = { "Rare", "Epic", "Mythic" }

local function pity_data(profile)
    local pity = profile.Data.pity
    if not pity then
        pity = { Rare = 0, Epic = 0, Mythic = 0 }
        profile.Data.pity = pity
    end
    return pity
end

local function pity_state(profile)
    local pity = pity_data(profile)
    return {
        rare = pity.Rare or 0,
        epic = pity.Epic or 0,
        mythic = pity.Mythic or 0,
    }
end

local function apply_pity(profile, ability)
    local pity = pity_data(profile)

    for _, rarity in pity_rarities do
        pity[rarity] = (pity[rarity] or 0) + 1
        if pity[rarity] >= catalog.pity[rarity] then
            ability = ability_rates.pick(rarity, true)
            pity[rarity] = 0
            return ability
        end
    end

    if catalog.pity[ability.rarity] then
        pity[ability.rarity] = 0
    end

    return ability
end

function ability_shop.current_period()
    local hour = sensitive_list.daily_deal_reset_hour or 0
    return math.floor((os.time() - hour * 3600) / 86400)
end

function ability_shop.reset_at()
    local hour = sensitive_list.daily_deal_reset_hour or 0
    return (ability_shop.current_period() + 1) * 86400 + hour * 3600
end

function ability_shop.deal_available(profile)
    return profile.Data.daily_deal_period ~= ability_shop.current_period()
end

function ability_shop.claim_deal(profile)
    local period = ability_shop.current_period()
    if profile.Data.daily_deal_period ~= period then
        profile.Data.daily_deal_period = period
    end
end

function ability_shop.sync(player)
    local profile = data_handler.profiles[player.UserId]
    if not profile then
        return
    end

    network.shop_state.Fire(player, {
        gold = profile.Data.gold,
        owned = owned_list(profile),
        equipped = equipped_list(profile),
        deal_available = ability_shop.deal_available(profile),
        reset_at = ability_shop.reset_at(),
        pity = pity_state(profile),
    })
end

function ability_shop.set_equipped(player, id, equipped)
    local profile = data_handler.profiles[player.UserId]
    if not profile then
        return
    end

    if not catalog.get(id) then
        return
    end

    if profile.Data.owned_abilities[id] ~= true then
        return
    end

    local map = equipped_map(profile)
    if equipped then
        table.clear(map)
        map[id] = true
    else
        map[id] = nil
    end

    ability_shop.sync(player)
end

function ability_shop.roll(player, use_gold, count)
    local profile = data_handler.profiles[player.UserId]
    if not profile then
        return fail("No profile", 0)
    end

    count = math.max(1, math.floor(tonumber(count) or 1))

    if use_gold then
        if count ~= 1 then
            return fail("Gold rolls are 1x only", profile.Data.gold)
        end
        if profile.Data.gold < catalog.roll_cost then
            return fail("Not enough gold", profile.Data.gold)
        end
        profile.Data.gold -= catalog.roll_cost
    end

    local new_count = 0
    local total_refund = 0
    local rolls = {}

    for _ = 1, count do
        local ability = apply_pity(profile, ability_rates.pick())
        local is_dupe = profile.Data.owned_abilities[ability.id] == true
        local refund = 0

        if is_dupe then
            refund = catalog.refunds[ability.rarity] or 0
            profile.Data.gold += refund
            total_refund += refund
        else
            profile.Data.owned_abilities[ability.id] = true
            new_count += 1
            if equipped_count(profile) < (catalog.max_active or 1) then
                equipped_map(profile)[ability.id] = true
            end
        end

        table.insert(rolls, {
            id = ability.id,
            rarity = ability.rarity,
            is_dupe = is_dupe,
            refund = refund,
        })
    end

    set_gold(player, profile)

    local last = rolls[#rolls]
    local message = "New"
    if count > 1 then
        message = "10x · " .. tostring(new_count) .. " new"
        if total_refund > 0 then
            message ..= " · +" .. tostring(total_refund) .. " gold"
        end
    elseif last and last.is_dupe then
        message = "Duplicate +" .. tostring(last.refund) .. " gold"
    end

    local result = {
        ok = true,
        message = message,
        gold = profile.Data.gold,
        rolls = rolls,
    }

    ability_shop.sync(player)
    network.roll_result.Fire(player, result)
    return result
end

network.roll_ability.On(function(player)
    return ability_shop.roll(player, true, 1)
end)

network.set_equipped.On(function(player, data)
    ability_shop.set_equipped(player, data.id, data.equipped)
end)

return ability_shop
