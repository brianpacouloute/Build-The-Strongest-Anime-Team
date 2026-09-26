local instance_handler = {
    tables = {
        two_player = {},
        single_player = {},
        six_player = {},
    },
    players = {},
    connections = {},
    functions = {},
}

local function get_table_type(table_name: string)
    if string.find(table_name, "two_player") then
        return "two_player"
    elseif string.find(table_name, "single_player") then
        return "single_player"
    elseif string.find(table_name, "six_player") then
        return "six_player"
    else
        return nil
    end
end

local function get_table_config(table_type: string)
    if table_type == "two_player" then
        return {
            min_plrs = 2,
            max_plrs = 2,
        }
    elseif table_type == "single_player" then
        return {
            min_plrs = 1,
            max_plrs = 1,
        }
    elseif table_type == "six_player" then
        return {
            min_plrs = 3,
            max_plrs = 6,
        }
    else
        return nil
    end
end

local function get_table_chairs(instance)
    local chairs = {}
    for _, chair in pairs(instance:GetChildren()) do
        print("Checking chair: ", instance)
        if string.find(chair.Name, "chair") then
            table.insert(chairs, chair)
        end
    end
    return chairs
end

local function set_tables(record, source, configs)
    record.config = configs
    record.chairs = get_table_chairs(source)
end


instance_handler.functions.table_init = function()
    local table_storage = game.Workspace.table_storage
    for _, table_category in pairs(table_storage:GetChildren()) do
        print("Initializing table category: " .. table_category.Name)

        local table_type = get_table_type(table_category.Name)

        if table_type then
            local table_config = get_table_config(table_type)
            local tables = instance_handler.tables[table_type]

            for _, table_instance in pairs(table_category:GetChildren()) do
                tables[table_instance] = tables[table_instance] or {}
                set_tables(tables[table_instance], table_instance, table_config)
            end
        end
    end
    
    print(instance_handler.tables)
end

function instance_handler.functions.player_added(player)
    instance_handler.players[player] = {
        connections = {},
        current_table = nil,
        current_chair = nil,
    }
end

function instance_handler.functions.player_removed(player)
    instance_handler.players[player] = nil
    -- disconnect all leftover connections
    for _, connection in pairs(instance_handler.connections) do
        connection:Disconnect()
    end
end


function instance_handler.functions.return_player_folder(player)
	return instance_handler.players[player.UserId]
end

-- this is so we can store listener events to the player instance
function instance_handler.functions.connect_signal(player,name,signal,callback)
	local connection = signal:Connect(callback)
	if player then
		repeat task.wait() until instance_handler.players[player.UserId]
		instance_handler.players[player.UserId].connections[name] = connection
	else
		instance_handler.connections[name] = connection
	end
	return connection
end

return instance_handler
