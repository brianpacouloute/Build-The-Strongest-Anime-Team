local plrs = game:GetService("Players")
local sss = game:GetService("ServerScriptService")

local data_handler = require(sss.data_handler)
require(sss.data_handler.product_handler)
local cmdr_handler = require(sss.cmdr_handler)

for _, player in plrs:GetPlayers() do
    data_handler.load_profile(player)
end

plrs.PlayerAdded:Connect(function(player)
    data_handler.load_profile(player)
    cmdr_handler.permission_check(player)
end)

plrs.PlayerRemoving:Connect(function(player)
    data_handler.unload_profile(player)
end)