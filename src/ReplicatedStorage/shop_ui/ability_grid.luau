local rs = game:GetService("ReplicatedStorage")
local Roact = require(rs.Packages.roact)
local catalog = require(rs.ability_catalog)

local function ability_card(props)
    local ability = props.ability
    local owned = props.owned
    local highlighted = props.highlighted
    local rarity = catalog.rarities[ability.rarity]
    local color = rarity and rarity.color or Color3.fromRGB(120, 120, 120)
    local percent = string.format("%.1f%%", catalog.drop_percent(ability))

    return Roact.createElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.fromOffset(148, 172),
    }, {
        Corner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 10),
        }),
        Stroke = Roact.createElement("UIStroke", {
            Color = if highlighted then Color3.fromRGB(232, 185, 35) else Color3.fromRGB(220, 214, 204),
            Thickness = if highlighted then 3 else 1,
        }),
        Icon = Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0, 12),
            Size = UDim2.fromOffset(56, 56),
        }, {
            Corner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0, 10),
            }),
            Letter = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Size = UDim2.fromScale(1, 1),
                Text = string.sub(ability.name, 1, 1),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 24,
            }),
        }),
        Name = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Position = UDim2.fromOffset(8, 76),
            Size = UDim2.new(1, -16, 0, 36),
            Text = ability.name,
            TextColor3 = Color3.fromRGB(40, 40, 40),
            TextSize = 14,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
        }),
        Rarity = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Position = UDim2.fromOffset(8, 114),
            Size = UDim2.new(1, -16, 0, 18),
            Text = ability.rarity .. " · " .. percent,
            TextColor3 = color,
            TextSize = 12,
        }),
        Owned = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Position = UDim2.fromOffset(8, 138),
            Size = UDim2.new(1, -16, 0, 22),
            Text = if owned then "Owned" else "Not owned",
            TextColor3 = if owned then Color3.fromRGB(70, 150, 80) else Color3.fromRGB(150, 150, 150),
            TextSize = 13,
        }),
    })
end

local function ability_grid(props)
    local cards = {
        Layout = Roact.createElement("UIGridLayout", {
            CellPadding = UDim2.fromOffset(12, 12),
            CellSize = UDim2.fromOffset(148, 172),
            FillDirectionMaxCells = 5,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        Padding = Roact.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 4),
        }),
    }

    for index, ability in catalog.abilities do
        cards[ability.id] = Roact.createElement(ability_card, {
            ability = ability,
            highlighted = props.last_id == ability.id,
            LayoutOrder = index,
            owned = props.owned[ability.id] == true,
        })
    end

    return Roact.createElement("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ScrollBarImageColor3 = Color3.fromRGB(180, 174, 164),
        ScrollBarThickness = 6,
        Size = UDim2.fromScale(1, 1),
    }, cards)
end

return ability_grid
