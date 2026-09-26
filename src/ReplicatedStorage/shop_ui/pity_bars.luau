local rs = game:GetService("ReplicatedStorage")
local Roact = require(rs.Packages.roact)
local catalog = require(rs.ability_catalog)

local rows = { "Rare", "Epic", "Mythic" }

local function pity_row(props)
    local rarity = props.rarity
    local current = props.current or 0
    local max = catalog.pity[rarity] or 1
    local color = catalog.rarities[rarity] and catalog.rarities[rarity].color or Color3.fromRGB(120, 120, 120)
    local fill = math.clamp(current / max, 0, 1)

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.new(1, 0, 0, 28),
    }, {
        Label = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(0.7, 0, 0, 16),
            Text = "Guaranteed " .. rarity,
            TextColor3 = Color3.fromRGB(40, 40, 40),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Count = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0.7, 0, 0, 0),
            Size = UDim2.new(0.3, 0, 0, 16),
            Text = tostring(current) .. "/" .. tostring(max),
            TextColor3 = Color3.fromRGB(40, 40, 40),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
        }),
        Track = Roact.createElement("Frame", {
            BackgroundColor3 = Color3.fromRGB(230, 226, 218),
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, 20),
            Size = UDim2.new(1, 0, 0, 4),
        }, {
            Corner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(1, 0),
            }),
            Fill = Roact.createElement("Frame", {
                BackgroundColor3 = color,
                BorderSizePixel = 0,
                Size = UDim2.new(fill, 0, 1, 0),
            }, {
                Corner = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
            }),
        }),
    })
end

local function pity_bars(props)
    local pity = props.pity or {}
    local counts = {
        Rare = pity.rare or 0,
        Epic = pity.epic or 0,
        Mythic = pity.mythic or 0,
    }

    local children = {
        List = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    }

    for index, rarity in rows do
        children[rarity] = Roact.createElement(pity_row, {
            LayoutOrder = index,
            current = counts[rarity],
            rarity = rarity,
        })
    end

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
    }, children)
end

return pity_bars
