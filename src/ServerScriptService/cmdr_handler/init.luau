local sss = game:GetService("ServerScriptService")

local cmdr = (require :: any)(sss:WaitForChild("Packages"):WaitForChild("cmdr"))
local network = require(sss:WaitForChild("network_server"))
local sensitive_list = require(sss:WaitForChild("sensitive_list"))
local cmdr_handler = {}

local command_folder = script.commands
--local types_folder = script.types

cmdr.Registry:RegisterCommandsIn(command_folder, function(cmd)
    return cmd.Name ~= 'template'
end)
--cmdr.Registry:RegisterTypesIn(types_folder)
cmdr.Registry:RegisterHook("BeforeRun", function(context) end)

function cmdr_handler.permission_check(player)
    if table.find(sensitive_list.developers, player.UserId) then
        network.permission.Fire(player)
    end
end

return cmdr_handler