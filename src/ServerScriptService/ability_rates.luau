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

local ability_rates = {}

function ability_rates.weight(ability)
    if use_display_rates then
        return catalog.weight(ability)
    end
    return actual[ability.rarity] or 0
end

function ability_rates.pick()
    local total = 0
    for _, ability in catalog.abilities do
        total += ability_rates.weight(ability)
    end

    local roll = math.random() * total
    local running = 0

    for _, ability in catalog.abilities do
        running += ability_rates.weight(ability)
        if roll <= running then
            return ability
        end
    end

    return catalog.abilities[#catalog.abilities]
end

return ability_rates
