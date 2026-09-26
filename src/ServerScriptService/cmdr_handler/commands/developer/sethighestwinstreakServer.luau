local sss = game:GetService("ServerScriptService")
local data_handler = require(sss.data_handler)
local sensitive_list = require(sss.sensitive_list)

return function(context, amount, player)
    if table.find(sensitive_list.developers, context.Executor.UserId) == nil then
        return "You don't have permission to run this command."
    end

    if player == nil then
        player = context.Executor
    end

    local new_value, err = data_handler.set(player, "best_winstreak", amount)
    if err then
        return err
    end

    return "Set " .. player.Name .. " highest winstreak to " .. tostring(new_value)
end
