local rs = game:GetService("ReplicatedStorage")
local Roact = require(rs.Packages.roact)
local animated_button = require(script.Parent.animated_button)
local assets = require(script.Parent.assets)
local ability_card = require(script.Parent.ability_card)
local corner_frame = require(script.Parent.corner_frame)

local BOLD = Font.new(Font.fromEnum(Enum.Font.RobotoCondensed).Family, Enum.FontWeight.Bold)

local function ability_detail(props)
    local ability = props.ability
    if not ability then
        return nil
    end
    local owned = props.owned == true
    local equipped = props.equipped == true

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
    }, {
        Card = Roact.createElement(ability_card, {
            ability = ability,
            art_size = 155,
            owned = owned,
            equipped = equipped,
            show_equipped = false,
        }),
        Description = Roact.createElement("Frame", {
            BackgroundColor3 = Color3.fromRGB(237, 233, 222),
            BackgroundTransparency = 0.12,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(167, 0),
            Size = UDim2.new(1, -167, 1, 0),
        }, {
            Texture = Roact.createElement("ImageLabel", {
                BackgroundTransparency = 1,
                Image = assets.image("01-cream-dots-tile"),
                ImageTransparency = 0.8,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.fromOffset(64, 64),
                Size = UDim2.fromScale(1, 1),
                ZIndex = 0,
            }),
            Corners = Roact.createElement(corner_frame, { transparency = 0.3 }),
            Title = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                FontFace = BOLD,
                Position = UDim2.fromOffset(20, 18),
                Size = UDim2.new(1, -60, 0, 24),
                Text = "Description",
                TextColor3 = Color3.fromRGB(35, 32, 27),
                TextSize = 20,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Text = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.RobotoCondensed,
                Position = UDim2.fromOffset(20, 48),
                Size = UDim2.new(1, -40, 0, 80),
                Text = ability.description or "",
                TextColor3 = Color3.fromRGB(126, 122, 112),
                TextSize = 18,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            }),
            Limit = owned and Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.RobotoCondensed,
                Position = UDim2.new(0, 20, 1, -88),
                Size = UDim2.new(1, -40, 0, 20),
                Text = if equipped then "Currently equipped" else "Equip this to replace your current ability.",
                TextColor3 = Color3.fromRGB(126, 122, 112),
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
            }) or nil,
            Action = owned and Roact.createElement(animated_button, {
                AutoButtonColor = true,
                BackgroundColor3 = Color3.fromRGB(245, 241, 230),
                BorderSizePixel = 0,
                FontFace = BOLD,
                Position = UDim2.new(0, 20, 1, -60),
                Size = UDim2.new(1, -40, 0, 40),
                Text = if equipped then "Unequip" else "Equip",
                TextColor3 = Color3.fromRGB(35, 32, 27),
                TextSize = 24,
                [Roact.Event.Activated] = function()
                    props.on_toggle(ability.id, not equipped)
                end,
            }, {
                Border = Roact.createElement("UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = Color3.fromRGB(255, 251, 238),
                    Thickness = 2,
                }),
            }) or nil,
            Close = Roact.createElement(animated_button, {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -16, 0, 16),
                Size = UDim2.fromOffset(24, 24),
                FontFace = BOLD,
                Text = "×",
                TextColor3 = Color3.fromRGB(96, 89, 75),
                TextSize = 22,
                [Roact.Event.Activated] = props.on_close,
            }),
        }),
    })
end

return ability_detail
