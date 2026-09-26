local ability_catalog = {
    roll_cost = 1000,
    products = {
        deal_1x = 3714926677,
        full_1x = 3714926725,
        robux_10x = 3714926835,
    },
    refunds = {
        Common = 200,
        Uncommon = 350,
        Rare = 500,
        Epic = 700,
        Mythic = 900,
    },
    rarities = {
        Common = { weight = 50, color = Color3.fromRGB(140, 140, 140) },
        Uncommon = { weight = 28, color = Color3.fromRGB(80, 170, 90) },
        Rare = { weight = 14, color = Color3.fromRGB(70, 130, 220) },
        Epic = { weight = 6, color = Color3.fromRGB(160, 80, 220) },
        Mythic = { weight = 2, color = Color3.fromRGB(230, 160, 40) },
    },
    abilities = {
        { id = "safe_guard", name = "Safe Guard", rarity = "Common" },
        { id = "power_surge", name = "Power Surge", rarity = "Common" },
        { id = "last_stand", name = "Last Stand", rarity = "Common" },
        { id = "gold_sense", name = "Gold Sense", rarity = "Common" },
        { id = "dispel", name = "Dispel", rarity = "Uncommon" },
        { id = "time_skip", name = "Time Skip", rarity = "Uncommon" },
        { id = "double_down", name = "Double Down", rarity = "Uncommon" },
        { id = "shadow_bid", name = "Shadow Bid", rarity = "Rare" },
        { id = "counter_draft", name = "Counter Draft", rarity = "Rare" },
        { id = "chunibyo_eye", name = "Chunibyo Eye", rarity = "Epic" },
        { id = "steal", name = "Steal", rarity = "Epic" },
        { id = "fate_rewrite", name = "Fate Rewrite", rarity = "Mythic" },
    },
}

function ability_catalog.get(id)
    for _, ability in ability_catalog.abilities do
        if ability.id == id then
            return ability
        end
    end
    return nil
end

function ability_catalog.weight(ability)
    local rarity = ability_catalog.rarities[ability.rarity]
    if not rarity then
        return 0
    end
    return rarity.weight
end

function ability_catalog.total_weight()
    local total = 0
    for _, ability in ability_catalog.abilities do
        total += ability_catalog.weight(ability)
    end
    return total
end

function ability_catalog.drop_percent(ability)
    local total = ability_catalog.total_weight()
    if total <= 0 then
        return 0
    end
    return ability_catalog.weight(ability) / total * 100
end

return ability_catalog
