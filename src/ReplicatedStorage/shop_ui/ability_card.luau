local rs = game:GetService("ReplicatedStorage")
local Roact = require(rs.Packages.roact)
local corner_frame = require(script.Parent.corner_frame)
local catalog = require(rs.ability_catalog)
local assets = require(script.Parent.assets)

local card_tint = {
    Common = Color3.fromRGB(236, 228, 214),
    Uncommon = Color3.fromRGB(198, 232, 210),
    Rare = Color3.fromRGB(206, 222, 242),
    Epic = Color3.fromRGB(224, 208, 242),
    Mythic = Color3.fromRGB(242, 214, 198),
}

local function ability_card(props)
    local art_size = props.art_size or 115
    local ability = props.ability
    local owned = props.owned
    local equipped = props.equipped
    local show_equipped = equipped and props.show_equipped ~= false
    local highlighted = props.highlighted
    local rarity = catalog.rarities[ability.rarity]
    local color = rarity and rarity.color or Color3.fromRGB(120, 120, 120)
    local tint = card_tint[ability.rarity] or Color3.fromRGB(236, 228, 214)
    local details_tint = tint:Lerp(Color3.fromRGB(248, 244, 236), 0.45):Lerp(Color3.fromRGB(0, 0, 0), 0.025)
    local percent = string.format("%.1f%%", catalog.drop_percent(ability))

    local owned_text = "Not owned"
    local owned_icon = assets.image("10-cross-white")
    if owned or equipped then
        owned_text = "Owned"
        owned_icon = assets.image("10-check-mint")
    end

    local stroke_color = nil
    if show_equipped then
        stroke_color = Color3.fromRGB(40, 40, 40)
    elseif highlighted then
        stroke_color = Color3.fromRGB(232, 185, 35)
    end

    return Roact.createElement("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = Enum.Font.RobotoCondensed,
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.fromOffset(art_size, art_size + 65),
        Text = "",
        [Roact.Event.Activated] = function()
            if props.on_select then
                props.on_select(ability.id)
            end
        end,
    }, {
        DetailsBackground = Roact.createElement("Frame", {
            BackgroundColor3 = details_tint,
            BackgroundTransparency = 0.12,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, art_size),
            Size = UDim2.new(1, 0, 0, 65),
            ZIndex = 0,
        }),
        EquippedOutline = show_equipped and Roact.createElement("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(52, 47, 37),
            Thickness = 2,
        }) or nil,
        EquippedLabel = show_equipped and Roact.createElement("TextLabel", {
            BackgroundColor3 = Color3.fromRGB(52, 47, 37),
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, 0, 0, 18),
            Font = Enum.Font.RobotoCondensed,
            Text = "EQUIPPED",
            TextColor3 = Color3.fromRGB(255, 248, 231),
            TextSize = 11,
            ZIndex = 6,
        }) or nil,
        Art = Roact.createElement("Frame", {
            BackgroundColor3 = tint,
            BackgroundTransparency = 0.65,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, art_size),
        }, {
            Wash = Roact.createElement("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.15),
                    NumberSequenceKeypoint.new(0.65, 0.35),
                    NumberSequenceKeypoint.new(1, 1),
                }),
            }),
            Card = Roact.createElement("ImageLabel", {
                BackgroundTransparency = 1,
                Image = assets.card(ability.rarity),
                ImageTransparency = 0.72,
                ScaleType = Enum.ScaleType.Stretch,
                Size = UDim2.fromScale(1, 1),
            }),
            Corners = not show_equipped and Roact.createElement(corner_frame, {
                asset = "05-corners-tan",
                color = stroke_color or color:Lerp(Color3.fromRGB(155, 143, 120), 0.55),
                transparency = if stroke_color then 0 else 0.15,
                ZIndex = 4,
            }) or nil,
            Icon = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = color,
                BackgroundTransparency = 0.88,
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(56, 56),
                ZIndex = 3,
            }, {
                Corner = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
                Outline = Roact.createElement("UIStroke", {
                    Color = color,
                    Transparency = 0.65,
                    Thickness = 1,
                }),
                Letter = Roact.createElement("TextLabel", {
                    BackgroundTransparency = 1,
                    FontFace = Font.new(Font.fromEnum(Enum.Font.RobotoCondensed).Family, Enum.FontWeight.Bold),
                    Size = UDim2.fromScale(1, 1),
                    Text = string.sub(ability.name, 1, 1),
                    TextColor3 = color,
                    TextSize = 24,
                }),
            }),
        }),
        Name = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font.new(Font.fromEnum(Enum.Font.RobotoCondensed).Family, Enum.FontWeight.Bold),
            Position = UDim2.fromOffset(8, art_size + 6),
            Size = UDim2.new(1, -16, 0, 20),
            Text = ability.name,
            TextColor3 = Color3.fromRGB(35, 35, 35),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }),
        Rarity = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.RobotoCondensed,
            Position = UDim2.fromOffset(8, art_size + 26),
            Size = UDim2.new(1, -16, 0, 16),
            Text = ability.rarity .. "  ·  " .. percent,
            TextColor3 = Color3.fromRGB(105, 103, 95),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Owned = Roact.createElement("Frame", {
            BackgroundColor3 = if owned then Color3.fromRGB(35, 239, 160) else Color3.fromRGB(246, 242, 230),
            BackgroundTransparency = 0.8,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(8, art_size + 45),
            Size = UDim2.fromOffset(if owned or equipped then 54 else 74, 16),
        }, {
            Badge = Roact.createElement("Frame", {
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(3, 3),
                Size = UDim2.fromOffset(10, 10),
            }, {
                Fallback = Roact.createElement("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Font = Enum.Font.GothamBold,
                    Text = if owned then "✓" else "×",
                    TextSize = 10,
                    TextColor3 = Color3.fromRGB(226, 250, 230),
                }),
                Icon = Roact.createElement("ImageLabel", {
                    BackgroundTransparency = 1,
                    Image = owned_icon,
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 2,
                }),
            }),
            Label = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.RobotoCondensed,
                Position = UDim2.fromOffset(17, 0),
                Size = UDim2.new(1, -19, 1, 0),
                Text = owned_text,
                TextColor3 = Color3.fromRGB(42, 42, 36),
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
        }),
    })
end

return ability_card
