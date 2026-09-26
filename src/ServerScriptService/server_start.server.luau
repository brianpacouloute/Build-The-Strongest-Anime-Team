local plrs = game:GetService("Players")
local sss = game:GetService("ServerScriptService")

local instance_handler = require(game.ServerScriptService.instance_handler)

local data_handler = require(sss.data_handler)
require(sss.data_handler.product_handler)
local cmdr_handler = require(sss.cmdr_handler)
local ability_shop = require(sss.ability_shop)

local function on_player_added(player)
    data_handler.load_profile(player)
    cmdr_handler.permission_check(player)
    ability_shop.sync(player)
end

-- this is to handle players that were already in the game when the script started
for _, player in plrs:GetPlayers() do
    on_player_added(player)
end

plrs.PlayerAdded:Connect(on_player_added)

plrs.PlayerRemoving:Connect(function(player)
    data_handler.unload_profile(player)
end)

instance_handler.functions.connect_signal(nil, "player_added", game.Players.PlayerAdded, instance_handler.functions.player_added)
instance_handler.functions.connect_signal(nil, "player_removed", game.Players.PlayerRemoving, instance_handler.functions.player_removed)

instance_handler.functions.table_init()
