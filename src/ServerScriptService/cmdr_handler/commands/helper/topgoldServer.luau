local sss = game:GetService("ServerScriptService")
local leaderboard = require(sss.data_handler.leaderboard)
local sensitive_list = require(sss.sensitive_list)

return function(context, count)
    if table.find(sensitive_list.developers, context.Executor.UserId) == nil then
        return "You don't have permission to run this command."
    end

    return leaderboard.get_top("gold", count)
end
