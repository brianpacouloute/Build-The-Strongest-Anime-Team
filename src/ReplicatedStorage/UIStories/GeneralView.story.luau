local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.roact)
local UILabs = require(ReplicatedStorage.Packages["ui-labs"])

local function text_label(text, size, position, color, text_size)
    return Roact.createElement("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = position,
        Size = size,
        Text = text,
        TextColor3 = color,
        TextSize = text_size,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
end

local function panel(size, position, color)
    return Roact.createElement("Frame", {
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Position = position,
        Size = size,
    })
end

local function button(text, position, color)
    return Roact.createElement("TextButton", {
        AutoButtonColor = true,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Position = position,
        Size = UDim2.fromOffset(120, 38),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
    })
end

local function unit_card(name, position, accent)
    return Roact.createElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(35, 40, 52),
        BorderSizePixel = 0,
        Position = position,
        Size = UDim2.fromOffset(132, 112),
    }, {
        Picture = Roact.createElement("Frame", {
            BackgroundColor3 = accent,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(10, 10),
            Size = UDim2.fromOffset(48, 48),
        }),
        Name = text_label(name, UDim2.new(1, -68, 0, 48), UDim2.fromOffset(68, 10), Color3.fromRGB(245, 245, 240), 13),
        Power = text_label("Power 84", UDim2.new(1, -20, 0, 22), UDim2.fromOffset(10, 74), Color3.fromRGB(164, 174, 192), 12),
    })
end

local function player_row(name, cash, bid, position, accent)
    return Roact.createElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(35, 40, 52),
        BorderSizePixel = 0,
        Position = position,
        Size = UDim2.new(1, -24, 0, 42),
    }, {
        Accent = Roact.createElement("Frame", {
            BackgroundColor3 = accent,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(5, 42),
        }),
        Name = text_label(name, UDim2.fromOffset(130, 42), UDim2.fromOffset(18, 0), Color3.fromRGB(245, 245, 240), 13),
        Cash = text_label("Cash  $" .. cash, UDim2.fromOffset(110, 42), UDim2.fromOffset(150, 0), Color3.fromRGB(164, 174, 192), 12),
        Bid = text_label("Bid  $" .. bid, UDim2.fromOffset(100, 42), UDim2.fromOffset(270, 0), Color3.fromRGB(245, 202, 102), 12),
    })
end

local function render_general_view(props)
    local surface = Color3.fromRGB(26, 31, 42)
    local muted = Color3.fromRGB(164, 174, 192)
    local gold = Color3.fromRGB(245, 202, 102)
    local state = props.controls.State
    local state_text = state == "countdown" and "MATCH STARTING" or state == "in_round" and "IN ROUND" or "WAITING FOR PLAYERS"
    local timer_text = state == "countdown" and "Starting in 5.0" or state == "in_round" and "Round 1" or "Waiting for players"
    local round_text = state == "in_round" and "ROUND 1" or "ROUND 0"
    local player_text = state == "in_round" and "1_on_1_table  ·  2 / 2" or "1_on_1_table  ·  1 / 2"

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
    }, {
        Header = Roact.createElement("Frame", {
            BackgroundColor3 = surface,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 54),
        }, {
            Title = text_label("STRONGEST TEAM", UDim2.fromOffset(240, 28), UDim2.fromOffset(20, 13), Color3.fromRGB(245, 245, 240), 17),
            Cash = text_label("Cash  $50", UDim2.fromOffset(90, 28), UDim2.new(1, -330, 0, 13), gold, 13),
            Shop = button("Shop", UDim2.new(1, -246, 0, 8), Color3.fromRGB(53, 91, 116)),
            Settings = button("Settings", UDim2.new(1, -120, 0, 8), Color3.fromRGB(61, 67, 82)),
        }),

        WaitingPanel = panel(UDim2.fromOffset(258, 92), UDim2.fromOffset(20, 76), surface),
        WaitingTitle = text_label(state_text, UDim2.fromOffset(230, 20), UDim2.fromOffset(36, 88), gold, 12),
        Table = text_label(player_text, UDim2.fromOffset(220, 22), UDim2.fromOffset(36, 111), Color3.fromRGB(245, 245, 240), 15),
        LeaveQueue = button("Leave Queue", UDim2.fromOffset(36, 137), Color3.fromRGB(139, 68, 69)),

        RoundPanel = panel(UDim2.fromOffset(330, 92), UDim2.new(1, -350, 0, 76), surface),
        Round = text_label(round_text, UDim2.fromOffset(120, 20), UDim2.new(1, -330, 0, 88), gold, 12),
        Timer = text_label(timer_text, UDim2.fromOffset(220, 22), UDim2.new(1, -330, 0, 111), Color3.fromRGB(245, 245, 240), 15),
        Bid = text_label("Highest bid  $12", UDim2.fromOffset(150, 20), UDim2.new(1, -330, 0, 139), muted, 12),

        UnitsTitle = text_label("YOUR TEAM", UDim2.fromOffset(160, 22), UDim2.fromOffset(20, 188), Color3.fromRGB(245, 245, 240), 13),
        UnitOne = unit_card("Blade Hero", UDim2.fromOffset(20, 216), Color3.fromRGB(153, 75, 67)),
        UnitTwo = unit_card("Moon Captain", UDim2.fromOffset(162, 216), Color3.fromRGB(70, 114, 143)),
        UnitThree = unit_card("Storm Sage", UDim2.fromOffset(304, 216), Color3.fromRGB(89, 133, 98)),

        PlayersTitle = text_label("PLAYERS", UDim2.fromOffset(160, 22), UDim2.new(1, -390, 0, 188), Color3.fromRGB(245, 245, 240), 13),
        PlayerOne = player_row("You", "50", "12", UDim2.new(1, -390, 0, 216), gold),
        PlayerTwo = player_row("Player 2", "42", "10", UDim2.new(1, -390, 0, 266), Color3.fromRGB(70, 114, 143)),
    })
end

return UILabs.CreateRoactStory({
    name = "General View",
    summary = "Main player HUD with queue, shop, settings, cash, bids, and purchased anime.",
    roact = Roact,
    controls = {
        State = UILabs.Choose({"waiting", "countdown", "in_round"}),
    },
}, render_general_view)
