local sss = game:GetService("ServerScriptService")
local data_handler = require(sss.data_handler)

return function(context, player, amount)
    local new_value, err = data_handler.set(player, "wins", amount)
    if err then
        return err
    end

    return "Set " .. player.Name .. " wins to " .. tostring(new_value)
end
