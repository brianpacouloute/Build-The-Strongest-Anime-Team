local plrs = game:GetService("Players")
local sss = game:GetService("ServerScriptService")

local instance_handler = require(game.ServerScriptService.instance_handler)

local data_handler = require(sss.data_handler)
require(sss.data_handler.product_handler)

for _, player in plrs:GetPlayers() do
    data_handler.load_profile(player)
end

plrs.PlayerAdded:Connect(function(player)
    data_handler.load_profile(player)
end)

plrs.PlayerRemoving:Connect(function(player)
    data_handler.unload_profile(player)
end)

instance_handler.functions.connect_signal(nil, "player_added", game.Players.PlayerAdded, instance_handler.functions.player_added)
instance_handler.functions.connect_signal(nil, "player_removed", game.Players.PlayerRemoving, instance_handler.functions.player_removed)

instance_handler.functions.table_init()
