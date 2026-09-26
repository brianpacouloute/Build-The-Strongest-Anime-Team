local sss = game:GetService("ServerScriptService")
local leaderboard = require(sss.data_handler.leaderboard)

return function(context, count)
    return leaderboard.get_top("best_winstreak", count)
end
