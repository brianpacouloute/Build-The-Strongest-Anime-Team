local sss = game:GetService("ServerScriptService")

local cmdr = require(sss:WaitForChild("Packages"):WaitForChild("cmdr"))
local network = require(sss:WaitForChild("network_server"))
local sensitive_list = require(sss:WaitForChild("sensitive_list"))
local cmdr_handler = {}

local command_folder = script.commands
local types_folder = script.types

cmdr:RegisterCommandsIn(command_folder, function(cmd)
    return cmd.Name ~= 'template'
end)
cmdr:RegisterTypesIn(types_folder)
cmdr.Registry:RegisterHook("BeforeRun", function(context) end)

function cmdr_handler.permission_check(player)
    for i,perm_table in sensitive_list.developers do
         if table.find(perm_table, player.UserId) then
            network.permission.Fire(player)
            return
        end
    end
end

return cmdr_handler