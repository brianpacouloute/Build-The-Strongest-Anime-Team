local data_handler = {
    profiles = {},
    functions = {},
}

local sss = game:GetService("ServerScriptService")
local plrs = game:GetService("Players")
local sensitive_list = require(sss.sensitive_list)
local profile_store = require(script.profile_store)

local data_template = require(sss.data_handler.data_template)
local leaderboard = require(script.leaderboard)

local data_key = sensitive_list.data_key
local player_store = profile_store.New(data_key, data_template)

local function start_playtime_session(profile)
    local info = profile.Data.playtime_info
    local now = os.time()

    if info.first_played < 0 then
        info.first_played = now
    end

    info.session_start = now
end

local function end_playtime_session(profile)
    local info = profile.Data.playtime_info
    local now = os.time()

    if info.session_start > 0 then
        info.playtime += math.max(0, now - info.session_start)
        info.session_start = 0
    end

    info.last_played = now
end

local function setup_leaderstats(player, profile)
    if player:FindFirstChild("leaderstats") then return end

    local folder = Instance.new("Folder")
    folder.Name = "leaderstats"

    local gold = Instance.new("IntValue")
    gold.Name = "Gold"
    gold.Value = profile.Data.gold
    gold.Parent = folder

    local wins = Instance.new("IntValue")
    wins.Name = "Wins"
    wins.Value = profile.Data.wins
    wins.Parent = folder

    local winstreak = Instance.new("IntValue")
    winstreak.Name = "Winstreak"
    winstreak.Value = profile.Data.winstreak
    winstreak.Parent = folder

    folder.Parent = player
end

local function init_data(player)
    local profile = data_handler.profiles[player.UserId]
    if not profile then
        warn(("[DataHandler] Profile not found for player %s (ID: %d)"):format(player.Name, player.UserId))
    end

    start_playtime_session(profile)
    setup_leaderstats(player, profile)
    leaderboard.update("wins", player.UserId, profile.Data.wins)
end

local function cleanup_data(player)
    local profile = data_handler.profiles[player.UserId]
    if not profile then
        warn(("[DataHandler] Profile not found for player %s (ID: %d)"):format(player.Name, player.UserId))
    end

    end_playtime_session(profile)
    print("[DataHandler] Cleaned up profile: ", profile.Data)
end

function data_handler.load_profile(player)
    local profile = player_store:StartSessionAsync("player_" .. player.UserId, {
        Cancel = function()
            return player.Parent ~= plrs
        end
    })

    if profile then
		profile:AddUserId(player.UserId)
		profile:Reconcile() -- Fills in missing data from the data templates


		profile.OnSessionEnd:Connect(function()
			if data_handler.profiles[player.UserId] ~= profile then return end

			end_playtime_session(profile)
			data_handler.profiles[player.UserId] = nil
			player:Kick('A data error occured. Please rejoin')
		end)

		if player.Parent == plrs then
            data_handler.profiles[player.UserId] = profile
            local success, err = pcall(init_data, player)

            if not success then
                player:Kick('A data error occured. Please rejoin')
                warn(("[DataHandler] Error initializing data for player %s (ID: %d): %s"):format(player.Name, player.UserId, err))
            end
		else
			profile:EndSession()
            warn(("[DataHandler] Player %s (ID: %d) is not in the player service. Ending session"):format(player.Name, player.UserId))
		end
	else
		player:Kick('A data error occured. Please rejoin.')
        warn(("[DataHandler] Player %s (ID: %d) is not in the player service. Ending session"):format(player.Name, player.UserId))
	end
end

function data_handler.unload_profile(player)
    local profile = data_handler.profiles[player.UserId]
    if not profile then 
        warn(("[DataHandler] Profile not found for player %s (ID: %d)"):format(player.Name, player.UserId))
    end

    local success, err = pcall(cleanup_data, player)

    if not success then
        warn(("[DataHandler] Error cleaning up data for player %s (ID: %d): %s"):format(player.Name, player.UserId, err))
    end

    data_handler.profiles[player.UserId] = nil
    profile:EndSession()
end

return data_handler