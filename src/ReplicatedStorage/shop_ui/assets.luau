local ids = {
    ["01-cream-dots-tile"] = 136492730109370,
    ["02-dark-dots-tile"] = 117438322257069,
    ["03-card-common-beige"] = 71212444163541,
    ["03-card-uncommon-mint"] = 137201167352763,
    ["03-card-rare-blue"] = 719301428758224,
    ["03-card-epic-purple"] = 106302049034913,
    ["03-card-mythic-red"] = 103881782563733,
    ["04-tab-dashed-tan"] = 126238330295977,
    ["04-tab-dashed-cream"] = 1038383487662066,
    ["05-corners-soft-tan"] = 916273264033988,
    ["05-corners-tan"] = 927618280502337,
    ["05-corners-white"] = 1293282210596808,
    ["10-close-dark"] = 1377908068952981,
    ["10-cross-white"] = 117500152906862,
    ["10-check-mint"] = 76174377121015,
    ["10-check-white"] = 1195859828598033,
}

local card_by_rarity = {
    Common = "03-card-common-beige",
    Uncommon = "03-card-uncommon-mint",
    Rare = "03-card-rare-blue",
    Epic = "03-card-epic-purple",
    Mythic = "03-card-mythic-red",
}

local assets = {}

function assets.image(id)
    local asset_id = ids[id]
    if not asset_id or asset_id == 0 then
        return ""
    end
    return "rbxassetid://" .. tostring(asset_id)
end

function assets.card(rarity)
    return assets.image(card_by_rarity[rarity] or "03-card-common-beige")
end

return assets
