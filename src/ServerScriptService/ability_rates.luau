local rs = game:GetService("ReplicatedStorage")
local catalog = require(rs.ability_catalog)

local use_display_rates = false

local actual = {
    Common = 47,
    Uncommon = 30,
    Rare = 13,
    Epic = 7,
    Mythic = 3,
}

local ranks = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Mythic = 5,
}

local ability_rates = {}

function ability_rates.weight(ability)
    if use_display_rates then
        return catalog.weight(ability)
    end
    return actual[ability.rarity] or 0
end

function ability_rates.rank(rarity)
    return ranks[rarity] or 0
end

function ability_rates.pick(min_rarity, exact)
    local min_rank = ability_rates.rank(min_rarity)
    local max_rank = min_rank
    if not exact then
        max_rank = 99
    end

    local total = 0
    local last = nil

    for _, ability in catalog.abilities do
        local rank = ability_rates.rank(ability.rarity)
        if rank >= min_rank and rank <= max_rank then
            total += ability_rates.weight(ability)
            last = ability
        end
    end

    local roll = math.random() * total
    local running = 0

    for _, ability in catalog.abilities do
        local rank = ability_rates.rank(ability.rarity)
        if rank >= min_rank and rank <= max_rank then
            running += ability_rates.weight(ability)
            if roll <= running then
                return ability
            end
        end
    end

    return last or catalog.abilities[#catalog.abilities]
end

return ability_rates
