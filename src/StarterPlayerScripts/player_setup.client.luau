local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")
local table_state_event = ReplicatedStorage:WaitForChild("TableState")
local table_action_event = ReplicatedStorage:WaitForChild("TableAction")

local muted_color = Color3.fromRGB(164, 174, 192)
local text_color = Color3.fromRGB(245, 245, 240)
local gold_color = Color3.fromRGB(245, 202, 102)
local surface_color = Color3.fromRGB(26, 31, 42)

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

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = surface_color
header.BackgroundTransparency = 0.15
header.BorderSizePixel = 0
header.Size = UDim2.new(1, 0, 0, 54)
header.Parent = screen_gui

local title_label = create_label("Title", header, UDim2.fromOffset(20, 13), UDim2.fromOffset(240, 28), 17, text_color)
title_label.Text = "STRONGEST TEAM"

local cash_label = create_label("Cash", header, UDim2.new(1, -150, 0, 13), UDim2.fromOffset(120, 28), 13, gold_color)
cash_label.Text = "Cash  $50"

local status_panel = Instance.new("Frame")
status_panel.Name = "TableStatus"
status_panel.BackgroundColor3 = surface_color
status_panel.BackgroundTransparency = 0.1
status_panel.BorderSizePixel = 0
status_panel.Position = UDim2.fromOffset(20, 76)
status_panel.Size = UDim2.fromOffset(286, 116)
status_panel.Parent = screen_gui

local state_label = create_label("State", status_panel, UDim2.fromOffset(16, 12), UDim2.fromOffset(250, 20), 12, gold_color)
local table_label = create_label("Table", status_panel, UDim2.fromOffset(16, 38), UDim2.fromOffset(250, 24), 16, text_color)
local players_label = create_label("Players", status_panel, UDim2.fromOffset(16, 66), UDim2.fromOffset(250, 20), 12, muted_color)

local leave_button = Instance.new("TextButton")
leave_button.Name = "LeaveTable"
leave_button.AutoButtonColor = true
leave_button.BackgroundColor3 = Color3.fromRGB(139, 68, 69)
leave_button.BorderSizePixel = 0
leave_button.Font = Enum.Font.GothamBold
leave_button.Position = UDim2.fromOffset(16, 88)
leave_button.Size = UDim2.fromOffset(120, 24)
leave_button.Text = "Leave Queue"
leave_button.TextColor3 = text_color
leave_button.TextSize = 12
leave_button.Parent = status_panel

local round_label = create_label("Round", screen_gui, UDim2.new(1, -270, 0, 88), UDim2.fromOffset(240, 22), 13, gold_color)
local timer_label = create_label("Timer", screen_gui, UDim2.new(1, -270, 0, 114), UDim2.fromOffset(240, 24), 16, text_color)
local current_state

local function set_visible(visible)
	header.Visible = visible
	status_panel.Visible = visible
	round_label.Visible = visible
	timer_label.Visible = visible
end

local function render_state(state)
	current_state = state

	if state.state == "none" then
		set_visible(false)
		return
	end

	set_visible(true)
	table_label.Text = state.table_name or "Table"
	players_label.Text = string.format("Players  %d / %d", state.player_count or 0, state.max_players or 0)
	round_label.Text = string.format("ROUND  %d", state.round_number or 0)

	if state.state == "waiting" then
		state_label.Text = "WAITING FOR PLAYERS"
		timer_label.Text = "Waiting for players"
		leave_button.Text = "Leave Queue"
	elseif state.state == "countdown" then
		state_label.Text = "MATCH STARTING"
		leave_button.Text = "Leave Queue"
	elseif state.state == "in_round" then
		state_label.Text = "IN ROUND"
		timer_label.Text = "Round 1"
		leave_button.Text = "Leave Round"
	end
end

leave_button.Activated:Connect(function()
	if current_state and current_state.state ~= "none" then
		table_action_event:FireServer("leave_table")
	end
end)

table_state_event.OnClientEvent:Connect(render_state)

RunService.RenderStepped:Connect(function()
	if not current_state or current_state.state ~= "countdown" or not current_state.countdown_end then
		return
	end

	local remaining = math.max(0, current_state.countdown_end - workspace:GetServerTimeNow())
	timer_label.Text = string.format("Starting in %.1f", remaining)
end)

set_visible(false)
