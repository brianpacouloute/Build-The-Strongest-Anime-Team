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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterCatalog = require(ReplicatedStorage.Shared.CharacterCatalog)
local COUNTDOWN_SECONDS = 5
local BID_SECONDS = 5
local STARTING_CASH = 50
local MAX_ROUNDS = 15
local table_state_event
local table_action_event
local random = Random.new()

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
    record.players = record.players or {}
    record.player_count = record.player_count or 0
    record.state = (record.state or "waiting") :: string
    record.countdown_end = nil
    record.countdown_token = 0
    record.round_number = 0
    record.current_unit = nil
    record.used_character_ids = {}
    record.round_token = 0
    record.round_phase = "waiting"
    record.current_bid = 0
    record.high_bidder = nil
    record.bid_deadline = nil
    record.results = nil
end

local function get_or_create_remote(name)
    local remote = ReplicatedStorage:FindFirstChild(name)

    if remote and remote:IsA("RemoteEvent") then
        return remote
    end

    remote = Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = ReplicatedStorage
    return remote
end

local function get_server_time()
    return workspace:GetServerTimeNow()
end

local function get_player_list(table_record)
    local players = {}

    for player in table_record.players do
        local player_data = instance_handler.players[player]
        local match_data = player_data and player_data.match_data
        local purchased_units = {}

        if match_data then
            for _, unit in match_data.purchased_units do
                table.insert(purchased_units, unit.name)
            end
        end

        table.insert(players, {
            name = player.Name,
            user_id = player.UserId,
            cash = match_data and match_data.cash or STARTING_CASH,
            current_bid = match_data and match_data.current_bid or 0,
            purchased_units = purchased_units,
        })
    end

    return players
end

local function get_match_results(table_record)
    local results = {}

    for player in table_record.players do
        local player_data = instance_handler.players[player]
        local match_data = player_data and player_data.match_data
        local total_rating = 0
        local purchased_units = {}

        if match_data then
            for _, unit in match_data.purchased_units do
                total_rating += unit.rating
                table.insert(purchased_units, {
                    id = unit.id,
                    name = unit.name,
                    rating = unit.rating,
                    image = unit.image,
                })
            end
        end

        table.insert(results, {
            name = player.Name,
            user_id = player.UserId,
            cash = match_data and match_data.cash or STARTING_CASH,
            total_rating = total_rating,
            purchased_units = purchased_units,
        })
    end

    table.sort(results, function(first, second)
        return first.total_rating > second.total_rating
    end)

    return results
end

local function get_table_state(table_record, table_instance, table_type)
    return {
        table_name = table_instance.Name,
        table_type = table_type,
        state = table_record.state,
        player_count = table_record.player_count,
        min_players = table_record.config.min_plrs,
        max_players = table_record.config.max_plrs,
        countdown_end = table_record.countdown_end,
        round_number = table_record.round_number,
        current_unit = table_record.current_unit and {
            id = table_record.current_unit.id,
            name = table_record.current_unit.name,
            image = table_record.current_unit.image,
        } or nil,
        round_phase = table_record.round_phase,
        current_bid = table_record.current_bid,
        high_bidder = table_record.high_bidder and table_record.high_bidder.Name or nil,
        bid_deadline = table_record.bid_deadline,
        results = table_record.results,
        players = get_player_list(table_record),
    }
end

local function reset_round_bids(table_record)
    for player in table_record.players do
        local player_data = instance_handler.players[player]
        if player_data and player_data.match_data then
            player_data.match_data.current_bid = 0
        end
    end
end

local function get_next_character(table_record)
    local available_characters = {}

    for _, character in CharacterCatalog do
        if not table_record.used_character_ids[character.id] then
            table.insert(available_characters, character)
        end
    end

    if #available_characters == 0 then
        table_record.used_character_ids = {}
        available_characters = CharacterCatalog
    end

    local character = available_characters[random:NextInteger(1, #available_characters)]
    table_record.used_character_ids[character.id] = true

    return {
        id = character.id,
        name = character.name,
        rating = character.rating,
        image = character.image,
    }
end

local function broadcast_table_state(table_record, table_instance, table_type)
    if not table_state_event then
        return
    end

    local state = get_table_state(table_record, table_instance, table_type)

    for player in table_record.players do
        table_state_event:FireClient(player, state)
    end
end

local function reset_table(table_record, table_instance, table_type)
    table_record.countdown_token += 1
    table_record.countdown_end = nil
    table_record.round_number = 0
    table_record.current_unit = nil
    table_record.used_character_ids = {}
    table_record.round_token += 1
    table_record.round_phase = "waiting"
    table_record.current_bid = 0
    table_record.high_bidder = nil
    table_record.bid_deadline = nil
    table_record.state = "waiting"
    table_record.results = nil

    for player in table_record.players do
        local player_data = instance_handler.players[player]
        if player_data then
            player_data.match_data = {
                cash = STARTING_CASH,
                current_bid = 0,
                purchased_units = {},
            }
        end
    end

    broadcast_table_state(table_record, table_instance, table_type)
end

local resolve_bid

local function start_round(table_record, table_instance, table_type)
    if table_record.player_count < table_record.config.min_plrs then
        reset_table(table_record, table_instance, table_type)
        return
    end

    table_record.countdown_end = nil
    table_record.round_number = 1
    table_record.current_unit = get_next_character(table_record)
    table_record.round_phase = "bidding"
    table_record.current_bid = 0
    table_record.high_bidder = nil
    table_record.bid_deadline = get_server_time() + BID_SECONDS
    reset_round_bids(table_record)
    table_record.round_token += 1
    local round_token = table_record.round_token
    table_record.state = "in_round"

    print(string.format(
        "Started round 1 at %s with %s (rating %d)",
        table_instance:GetFullName(),
        table_record.current_unit.name,
        table_record.current_unit.rating
    ))
    broadcast_table_state(table_record, table_instance, table_type)

    task.spawn(function()
        while table_record.round_token == round_token and table_record.state == "in_round" do
            if table_record.player_count < table_record.config.min_plrs then
                reset_table(table_record, table_instance, table_type)
                return
            end

            local remaining = table_record.bid_deadline - get_server_time()
            if remaining <= 0 then
                resolve_bid(table_record, table_instance, table_type)
                return
            end

            task.wait(math.min(0.1, remaining))
        end
    end)
end

resolve_bid = function(table_record, table_instance, table_type)
    if table_record.state ~= "in_round" or table_record.round_phase ~= "bidding" then
        return
    end

    table_record.round_phase = "resolving"
    table_record.bid_deadline = nil

    if table_record.high_bidder then
        local winner_data = instance_handler.players[table_record.high_bidder]
        local match_data = winner_data and winner_data.match_data

        if match_data then
            match_data.cash -= table_record.current_bid
            table.insert(match_data.purchased_units, table_record.current_unit)
            print(string.format(
                "%s won %s for $%d",
                table_record.high_bidder.Name,
                table_record.current_unit.name,
                table_record.current_bid
            ))
        end
    else
        print("No bids for " .. table_record.current_unit.name .. "; skipping character")
    end

    if table_record.round_number >= MAX_ROUNDS then
        table_record.round_phase = "complete"
        table_record.state = "complete"
        table_record.results = get_match_results(table_record)
        broadcast_table_state(table_record, table_instance, table_type)
        return
    end

    table_record.round_number += 1
    table_record.current_unit = get_next_character(table_record)
    table_record.current_bid = 0
    table_record.high_bidder = nil
    table_record.round_phase = "bidding"
    table_record.bid_deadline = get_server_time() + BID_SECONDS
    reset_round_bids(table_record)
    table_record.round_token += 1
    local round_token = table_record.round_token

    broadcast_table_state(table_record, table_instance, table_type)

    task.spawn(function()
        while table_record.round_token == round_token and table_record.state == "in_round" do
            if table_record.player_count < table_record.config.min_plrs then
                reset_table(table_record, table_instance, table_type)
                return
            end

            local remaining = table_record.bid_deadline - get_server_time()
            if remaining <= 0 then
                resolve_bid(table_record, table_instance, table_type)
                return
            end

            task.wait(math.min(0.1, remaining))
        end
    end)
end

local function start_countdown(table_record, table_instance, table_type)
    if table_record.state ~= "waiting" or table_record.player_count < table_record.config.min_plrs then
        return
    end

    table_record.state = "countdown"
    table_record.countdown_end = get_server_time() + COUNTDOWN_SECONDS
    table_record.countdown_token += 1
    local countdown_token = table_record.countdown_token

    print("Starting countdown at " .. table_instance:GetFullName())
    broadcast_table_state(table_record, table_instance, table_type)

    task.spawn(function()
        while table_record.countdown_token == countdown_token and (table_record.state :: string) == "countdown" do
            if table_record.player_count < table_record.config.min_plrs then
                reset_table(table_record, table_instance, table_type)
                return
            end

            local remaining = table_record.countdown_end - get_server_time()
            if remaining <= 0 then
                start_round(table_record, table_instance, table_type)
                return
            end

            task.wait(math.min(0.1, remaining))
        end
    end)
end

local function print_table_update(table_record, table_instance)
    local player_names = {}

    for player in table_record.players do
        table.insert(player_names, player.Name)
    end

    print(string.format(
        "Updated table %s: %d/%d players [%s]",
        table_instance:GetFullName(),
        table_record.player_count,
        table_record.config.max_plrs,
        table.concat(player_names, ", ")
    ))
end

local function print_instance_tables()
    print("Updated instance table:")

    for table_type, tables in instance_handler.tables do
        for table_instance, table_record in tables do
            local player_names = {}

            for player in table_record.players do
                table.insert(player_names, player.Name)
            end

            print(string.format(
                "  %s [%s] %d/%d [%s]",
                table_instance:GetFullName(),
                table_type,
                table_record.player_count,
                table_record.config.max_plrs,
                table.concat(player_names, ", ")
            ))
        end
    end
end

local function connect_table_prompt(table_record, table_instance)
    local prompt = table_instance:FindFirstChildWhichIsA("ProximityPrompt", true)

    if not prompt then
        warn("No ProximityPrompt found for " .. table_instance:GetFullName())
        return
    end

    prompt.Triggered:Connect(function(player)
        instance_handler.functions.request_join_table(player, table_instance)
    end)

    local leave_prompt = table_instance:FindFirstChild("LeavePrompt", true)

    if leave_prompt then
        leave_prompt.Triggered:Connect(function(player)
            instance_handler.functions.leave_table(player)
        end)
    end
end

local function initialize_networking()
    if table_state_event then
        return
    end

    table_state_event = get_or_create_remote("TableState")
    table_action_event = get_or_create_remote("TableAction")

    table_action_event.OnServerEvent:Connect(function(player, action)
        if action == "leave_table" then
            instance_handler.functions.leave_table(player)
        elseif action == "bid" then
            instance_handler.functions.request_bid(player)
        end
    end)
end


instance_handler.functions.table_init = function()
    initialize_networking()
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
                connect_table_prompt(tables[table_instance], table_instance)
                print_table_update(tables[table_instance], table_instance)
            end
        end
    end

    print_instance_tables()
end

function instance_handler.functions.request_join_table(player, table_instance)
    local player_data = instance_handler.players[player]

    if not player_data then
        warn(player.Name .. " tried to join before player data was initialized")
        return
    end

    local table_category = table_instance.Parent
    local table_type = get_table_type(table_category.Name)

    if not table_type then
        warn("Invalid table category for " .. table_instance:GetFullName())
        return
    end

    local table_record = instance_handler.tables[table_type][table_instance]

    if not table_record then
        warn("Unregistered table: " .. table_instance:GetFullName())
        return
    end

    if table_record.state ~= "waiting" then
        print(player.Name .. " cannot join " .. table_instance.Name .. ": table is not waiting")
        return
    end

    if table_record.players[player] then
        print(player.Name .. " is already in " .. table_instance.Name)
        return
    end

    if player_data.current_table then
        print(player.Name .. " cannot join another table while already in a table")
        return
    end

    if table_record.player_count >= table_record.config.max_plrs then
        print(player.Name .. " cannot join " .. table_instance.Name .. ": table is full")
        return
    end

    table_record.players[player] = true
    table_record.player_count += 1
    player_data.current_table = table_instance
    player_data.current_table_type = table_type
    player_data.match_data = {
        cash = STARTING_CASH,
        current_bid = 0,
        purchased_units = {},
    }

    print(player.Name .. " joined " .. table_instance:GetFullName())
    print_table_update(table_record, table_instance)
    print_instance_tables()

    broadcast_table_state(table_record, table_instance, table_type)
    if table_record.player_count >= table_record.config.min_plrs then
        start_countdown(table_record, table_instance, table_type)
    end
end

function instance_handler.functions.request_bid(player)
    local player_data = instance_handler.players[player]

    if not player_data or not player_data.current_table then
        return
    end

    local table_instance = player_data.current_table
    local table_type = player_data.current_table_type
    local table_record = table_type and instance_handler.tables[table_type][table_instance]

    if not table_record or table_record.state ~= "in_round" or table_record.round_phase ~= "bidding" then
        return
    end

    if table_record.bid_deadline <= get_server_time() then
        resolve_bid(table_record, table_instance, table_type)
        return
    end

    local match_data = player_data.match_data
    local next_bid = table_record.current_bid + 1

    if not match_data or next_bid > match_data.cash then
        print(player.Name .. " cannot afford bid " .. next_bid)
        return
    end

    if table_record.high_bidder == player then
        print(player.Name .. " is already the highest bidder")
        return
    end

    table_record.current_bid = next_bid
    table_record.high_bidder = player
    match_data.current_bid = next_bid
    table_record.bid_deadline = get_server_time() + BID_SECONDS

    print(string.format("%s bid $%d on %s", player.Name, next_bid, table_record.current_unit.name))
    broadcast_table_state(table_record, table_instance, table_type)
end

function instance_handler.functions.leave_table(player)
    local player_data = instance_handler.players[player]

    if not player_data or not player_data.current_table then
        return
    end

    local table_instance = player_data.current_table
    local table_type = get_table_type(table_instance.Parent.Name)
    local table_record = table_type and instance_handler.tables[table_type][table_instance]

    if table_record and table_record.players[player] then
        table_record.players[player] = nil
        table_record.player_count -= 1
        print(player.Name .. " left " .. table_instance:GetFullName())
        print_table_update(table_record, table_instance)
        print_instance_tables()

        if table_record.state == "countdown" and table_record.player_count < table_record.config.min_plrs then
            reset_table(table_record, table_instance, table_type)
        elseif table_record.state == "in_round" and table_record.player_count < table_record.config.min_plrs then
            reset_table(table_record, table_instance, table_type)
        elseif table_record.state == "complete" and table_record.player_count == 0 then
            reset_table(table_record, table_instance, table_type)
        else
            broadcast_table_state(table_record, table_instance, table_type)
        end
    end

    player_data.current_table = nil
    player_data.current_chair = nil
    player_data.current_table_type = nil
    player_data.match_data = nil

    if table_state_event then
        table_state_event:FireClient(player, {
            state = "none",
            table_name = nil,
            players = {},
        })
    end
end

function instance_handler.functions.leave_queue(player)
    instance_handler.functions.leave_table(player)
end

function instance_handler.functions.player_added(player)
    instance_handler.players[player] = {
        connections = {},
        current_table = nil,
        current_chair = nil,
        current_table_type = nil,
        match_data = nil,
    }
end

function instance_handler.functions.player_removed(player)
    instance_handler.functions.leave_table(player)
    instance_handler.players[player] = nil
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
