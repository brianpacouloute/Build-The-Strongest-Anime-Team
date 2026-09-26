local rs = game:GetService("ReplicatedStorage")
local Roact = require(rs.Packages.roact)
local catalog = require(rs.ability_catalog)

local function ability_detail(props)
    local ability = props.ability
    if not ability then
        return Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Size = UDim2.fromScale(1, 1),
            Text = "Select an ability",
            TextColor3 = Color3.fromRGB(140, 140, 140),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
    end

    local rarity = catalog.rarities[ability.rarity]
    local color = rarity and rarity.color or Color3.fromRGB(120, 120, 120)
    local percent = string.format("%.1f%%", catalog.drop_percent(ability))
    local owned = props.owned == true
    local equipped = props.equipped == true
    local max_active = catalog.max_active or 1

    local button_text = "Enable"
    if equipped then
        button_text = "Disable"
    end
    if not owned then
        button_text = "Not owned"
    end

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
    }, {
        Left = Roact.createElement("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 160, 1, 0),
        }, {
            Icon = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = color,
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 0, 0, 4),
                Size = UDim2.fromOffset(72, 72),
            }, {
                Corner = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
                Letter = Roact.createElement("TextLabel", {
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Size = UDim2.fromScale(1, 1),
                    Text = string.sub(ability.name, 1, 1),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 28,
                }),
            }),
            Name = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Position = UDim2.fromOffset(0, 84),
                Size = UDim2.new(1, 0, 0, 22),
                Text = ability.name,
                TextColor3 = Color3.fromRGB(30, 30, 30),
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Rarity = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(0, 106),
                Size = UDim2.new(1, 0, 0, 18),
                Text = ability.rarity .. "  ·  " .. percent,
                TextColor3 = Color3.fromRGB(130, 130, 130),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Owned = Roact.createElement("TextLabel", {
                BackgroundColor3 = if owned then Color3.fromRGB(0, 214, 163) else Color3.fromRGB(210, 210, 210),
                BorderSizePixel = 0,
                Font = Enum.Font.GothamBold,
                Position = UDim2.fromOffset(0, 132),
                Size = UDim2.fromOffset(78, 22),
                Text = if owned then "Owned" else "Locked",
                TextColor3 = if owned then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(90, 90, 90),
                TextSize = 12,
            }, {
                Corner = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                }),
            }),
        }),
        Right = Roact.createElement("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(176, 0),
            Size = UDim2.new(1, -176, 1, 0),
        }, {
            DescTitle = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Size = UDim2.new(1, 0, 0, 18),
                Text = "Description",
                TextColor3 = Color3.fromRGB(30, 30, 30),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Desc = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(0, 22),
                Size = UDim2.new(1, 0, 0, 40),
                Text = ability.description or "",
                TextColor3 = Color3.fromRGB(120, 120, 120),
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            }),
            MinActive = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(0, 70),
                Size = UDim2.new(1, 0, 0, 18),
                Text = tostring(max_active) .. " item active",
                TextColor3 = Color3.fromRGB(150, 150, 150),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Action = Roact.createElement("TextButton", {
                AutoButtonColor = owned,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Font = Enum.Font.GothamBold,
                Position = UDim2.fromOffset(0, 94),
                Size = UDim2.new(1, 0, 0, 48),
                Text = button_text,
                TextColor3 = Color3.fromRGB(20, 20, 20),
                TextSize = 18,
                [Roact.Event.Activated] = function()
                    if owned then
                        props.on_toggle(ability.id, not equipped)
                    end
                end,
            }, {
                Corner = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                }),
                Stroke = Roact.createElement("UIStroke", {
                    Color = Color3.fromRGB(230, 226, 218),
                    Thickness = 1,
                }),
            }),
        }),
    })
end

return ability_detail
