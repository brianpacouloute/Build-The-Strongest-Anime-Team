local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")
local table_state_event = ReplicatedStorage:WaitForChild("TableState")
local table_action_event = ReplicatedStorage:WaitForChild("TableAction")

local muted_color = Color3.fromRGB(126, 126, 121)
local text_color = Color3.fromRGB(45, 49, 56)
local header_text_color = Color3.fromRGB(245, 245, 240)
local gold_color = Color3.fromRGB(214, 157, 42)
local surface_color = Color3.fromRGB(246, 241, 232)
local header_color = Color3.fromRGB(43, 47, 55)
local action_color = Color3.fromRGB(0, 207, 166)

local screen_gui = Instance.new("ScreenGui")
screen_gui.Name = "TableHud"
screen_gui.IgnoreGuiInset = true
screen_gui.ResetOnSpawn = false
screen_gui.Parent = player_gui

local function create_label(name, parent, position, size, text_size, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.Position = position
	label.Size = size
	label.TextColor3 = color
	label.TextSize = text_size
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function add_corner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = header_color
header.BackgroundTransparency = 0.15
header.BorderSizePixel = 0
header.Size = UDim2.new(1, 0, 0, 54)
header.Parent = screen_gui

local title_label = create_label("Title", header, UDim2.fromOffset(20, 13), UDim2.fromOffset(240, 28), 17, header_text_color)
title_label.Text = "STRONGEST TEAM"

local cash_label = create_label("Cash", header, UDim2.new(1, -150, 0, 13), UDim2.fromOffset(120, 28), 13, gold_color)
cash_label.Text = "Cash  $50"

local team_label = create_label("Team", screen_gui, UDim2.new(0, 20, 1, -118), UDim2.fromOffset(360, 82), 13, text_color)
team_label.TextWrapped = true
team_label.TextYAlignment = Enum.TextYAlignment.Top

local result_panel = Instance.new("Frame")
result_panel.Name = "Results"
result_panel.BackgroundColor3 = surface_color
result_panel.BackgroundTransparency = 0.05
result_panel.BorderSizePixel = 0
result_panel.Position = UDim2.new(0.5, -190, 0.5, -120)
result_panel.Size = UDim2.fromOffset(380, 240)
result_panel.Parent = screen_gui
add_corner(result_panel, 10)

local result_title = create_label("Title", result_panel, UDim2.fromOffset(20, 16), UDim2.fromOffset(340, 28), 20, gold_color)
local result_label = create_label("Summary", result_panel, UDim2.fromOffset(20, 54), UDim2.fromOffset(340, 160), 13, text_color)
result_label.TextWrapped = true
result_label.TextYAlignment = Enum.TextYAlignment.Top

local status_panel = Instance.new("Frame")
status_panel.Name = "TableStatus"
status_panel.BackgroundColor3 = surface_color
status_panel.BackgroundTransparency = 0.1
status_panel.BorderSizePixel = 0
status_panel.Position = UDim2.fromOffset(20, 76)
status_panel.Size = UDim2.fromOffset(286, 116)
status_panel.Parent = screen_gui
add_corner(status_panel, 10)

local state_label = create_label("State", status_panel, UDim2.fromOffset(16, 12), UDim2.fromOffset(250, 20), 12, gold_color)
local table_label = create_label("Table", status_panel, UDim2.fromOffset(16, 38), UDim2.fromOffset(250, 24), 16, text_color)
local players_label = create_label("Players", status_panel, UDim2.fromOffset(16, 66), UDim2.fromOffset(250, 20), 12, muted_color)

local leave_button = Instance.new("TextButton")
leave_button.Name = "LeaveTable"
leave_button.AutoButtonColor = true
leave_button.BackgroundColor3 = Color3.fromRGB(139, 87, 72)
leave_button.BorderSizePixel = 0
leave_button.Font = Enum.Font.GothamBold
leave_button.Position = UDim2.fromOffset(16, 88)
leave_button.Size = UDim2.fromOffset(120, 24)
leave_button.Text = "Leave Queue"
leave_button.TextColor3 = text_color
leave_button.TextSize = 12
leave_button.Parent = status_panel
add_corner(leave_button, 7)

local round_label = create_label("Round", screen_gui, UDim2.new(1, -270, 0, 88), UDim2.fromOffset(240, 22), 13, gold_color)
local timer_label = create_label("Timer", screen_gui, UDim2.new(1, -270, 0, 114), UDim2.fromOffset(240, 24), 16, text_color)

local unit_panel = Instance.new("Frame")
unit_panel.Name = "CurrentUnit"
unit_panel.BackgroundColor3 = surface_color
unit_panel.BackgroundTransparency = 0.1
unit_panel.BorderSizePixel = 0
unit_panel.Position = UDim2.new(0.5, -180, 1, -132)
unit_panel.Size = UDim2.fromOffset(360, 110)
unit_panel.Parent = screen_gui
add_corner(unit_panel, 10)

local unit_image = Instance.new("ImageLabel")
unit_image.Name = "Image"
unit_image.BackgroundColor3 = Color3.fromRGB(53, 91, 116)
unit_image.BorderSizePixel = 0
unit_image.Position = UDim2.fromOffset(12, 22)
unit_image.Size = UDim2.fromOffset(66, 66)
unit_image.Parent = unit_panel
add_corner(unit_image, 8)

local unit_name = create_label("Name", unit_panel, UDim2.fromOffset(92, 20), UDim2.fromOffset(125, 24), 17, text_color)
local bid_label = create_label("Bid", unit_panel, UDim2.fromOffset(92, 78), UDim2.fromOffset(125, 20), 13, muted_color)
local high_bid_label = create_label("HighBidder", unit_panel, UDim2.fromOffset(230, 18), UDim2.fromOffset(120, 22), 12, muted_color)

local bid_button = Instance.new("TextButton")
bid_button.Name = "Bid"
bid_button.AutoButtonColor = true
bid_button.BackgroundColor3 = action_color
bid_button.BorderSizePixel = 0
bid_button.Font = Enum.Font.GothamBold
bid_button.Position = UDim2.fromOffset(230, 48)
bid_button.Size = UDim2.fromOffset(112, 38)
bid_button.Text = "+1 Bid"
bid_button.TextColor3 = text_color
bid_button.TextSize = 14
bid_button.Parent = unit_panel
add_corner(bid_button, 7)
local current_state

local function set_visible(visible)
	header.Visible = visible
	status_panel.Visible = visible
	round_label.Visible = visible
	timer_label.Visible = visible
	unit_panel.Visible = visible
	bid_button.Visible = visible
	team_label.Visible = visible
	result_panel.Visible = false
end

local function render_state(state)
	current_state = state

	if state.state == "none" then
		set_visible(false)
		return
	end

	set_visible(true)
	result_panel.Visible = state.state == "complete"
	team_label.Visible = state.state ~= "complete"
	unit_panel.Visible = state.state == "in_round"
	bid_button.Visible = state.state == "in_round"
	table_label.Text = state.table_name or "Table"
	players_label.Text = string.format("Players  %d / %d", state.player_count or 0, state.max_players or 0)
	round_label.Text = string.format("ROUND  %d", state.round_number or 0)

	local local_player_state
	for _, player_state in state.players or {} do
		if player_state.user_id == player.UserId then
			local_player_state = player_state
			break
		end
	end

	if local_player_state then
		cash_label.Text = string.format("Cash  $%d", local_player_state.cash or 0)
		local team_names = {}
		for _, unit in local_player_state.purchased_units or {} do
			table.insert(team_names, unit)
		end
		team_label.Text = #team_names > 0 and ("YOUR TEAM\n" .. table.concat(team_names, "  |  ")) or "YOUR TEAM\nNo anime purchased yet"
	end

	if state.current_unit then
		unit_name.Text = state.current_unit.name or "Current unit"
		unit_image.Image = state.current_unit.image or ""
		bid_label.Text = string.format("Bid  $%d", state.current_bid or 0)
		high_bid_label.Text = state.high_bidder and ("Leader  " .. state.high_bidder) or "No bids yet"
	else
		unit_name.Text = "No unit selected"
		unit_image.Image = ""
		bid_label.Text = ""
		high_bid_label.Text = ""
	end

	if state.state == "waiting" then
		status_panel.Position = UDim2.fromOffset(20, 76)
		status_panel.Size = UDim2.fromOffset(286, 116)
		state_label.Visible = true
		table_label.Visible = true
		players_label.Visible = true
		leave_button.Position = UDim2.fromOffset(16, 88)
		round_label.Position = UDim2.new(1, -270, 0, 88)
		timer_label.Position = UDim2.new(1, -270, 0, 114)
		state_label.Text = "WAITING FOR PLAYERS"
		timer_label.Text = "Waiting for players"
		leave_button.Text = "Leave Queue"
	elseif state.state == "countdown" then
		status_panel.Position = UDim2.fromOffset(20, 76)
		status_panel.Size = UDim2.fromOffset(286, 116)
		state_label.Visible = true
		table_label.Visible = true
		players_label.Visible = true
		leave_button.Position = UDim2.fromOffset(16, 88)
		round_label.Position = UDim2.new(1, -270, 0, 88)
		timer_label.Position = UDim2.new(1, -270, 0, 114)
		state_label.Text = "MATCH STARTING"
		leave_button.Text = "Leave Queue"
	elseif state.state == "in_round" then
		status_panel.Position = UDim2.new(0, 20, 1, -70)
		status_panel.Size = UDim2.fromOffset(180, 50)
		state_label.Visible = false
		table_label.Visible = false
		players_label.Visible = false
		leave_button.Position = UDim2.fromOffset(16, 13)
		round_label.Position = UDim2.new(1, -270, 1, -132)
		timer_label.Position = UDim2.new(1, -270, 1, -104)
		state_label.Text = "IN ROUND"
		timer_label.Text = "Bidding"
		leave_button.Text = "Leave Round"
	elseif state.state == "complete" then
		status_panel.Visible = false
		unit_panel.Visible = false
		bid_button.Visible = false
		round_label.Visible = false
		timer_label.Visible = false
		result_title.Text = "MATCH COMPLETE"
		local result_lines = {}
		for index, result in state.results or {} do
			table.insert(result_lines, string.format("%d. %s  |  %d power  |  $%d", index, result.name, result.total_rating, result.cash))
		end
		result_label.Text = table.concat(result_lines, "\n")
	end
end

leave_button.Activated:Connect(function()
	if current_state and current_state.state ~= "none" then
		table_action_event:FireServer("leave_table")
	end
end)

bid_button.Activated:Connect(function()
	if current_state and current_state.state == "in_round" then
		table_action_event:FireServer("bid")
	end
end)

table_state_event.OnClientEvent:Connect(render_state)

RunService.RenderStepped:Connect(function()
	if not current_state then
		return
	end

	if current_state.state == "countdown" and current_state.countdown_end then
		local remaining = math.max(0, current_state.countdown_end - workspace:GetServerTimeNow())
		timer_label.Text = string.format("Starting in %.1f", remaining)
	elseif current_state.state == "in_round" and current_state.bid_deadline then
		local remaining = math.max(0, current_state.bid_deadline - workspace:GetServerTimeNow())
		timer_label.Text = string.format("Bid ends in %.1f", remaining)
	end
end)

set_visible(false)
