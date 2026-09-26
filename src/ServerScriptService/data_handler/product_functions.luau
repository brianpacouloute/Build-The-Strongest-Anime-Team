local sss = game:GetService("ServerScriptService")
local rs = game:GetService("ReplicatedStorage")
local ability_shop = require(sss.ability_shop)
local catalog = require(rs.ability_catalog)

local product_functions = {
    -- Grants 1000 gold
    [3714901953] = function(receipt_info, player, profile)
        profile.Data.gold += 1000
        profile.Data.robux_spent += receipt_info.CurrencySpent
        player.leaderstats.Gold.Value = profile.Data.gold
    end,

    -- Grants 1 ability roll
    [catalog.products.full_1x] = function(receipt_info, player, profile)
        profile.Data.robux_spent += receipt_info.CurrencySpent
        ability_shop.roll(player, false, 1)
    end,

    -- Grants 10 ability rolls
    [catalog.products.robux_10x] = function(receipt_info, player, profile)
        profile.Data.robux_spent += receipt_info.CurrencySpent
        ability_shop.roll(player, false, 10)
    end,

        -- Grants 1 ability roll (50% off)
        [catalog.products.deal_1x] = function(receipt_info, player, profile)
            profile.Data.robux_spent += receipt_info.CurrencySpent
            ability_shop.claim_deal(profile)
            ability_shop.roll(player, false, 1)
        end,
}

return product_functions
