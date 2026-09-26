local product_functions = {
    -- Grants 1000 gold to the player
    [3714901953] = function(receipt_info, player, profile)
        profile.Data.gold += 1000
        profile.Data.robux_spent += receipt_info.CurrencySpent
    end,
}

return product_functions