local rs = game:GetService("ReplicatedStorage")
local Roact = require(rs.Packages.roact)
local animated_button = require(script.Parent.animated_button)
local helpers = require(rs.helpers)
local pity_bars = require(script.Parent.pity_bars)

local MINT = Color3.fromRGB(135, 232, 187)
local PANEL = Color3.fromRGB(233, 229, 218)

local function mint_button(props)
    return Roact.createElement(animated_button, {
        AutoButtonColor = true,
        BackgroundColor3 = MINT,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Position = props.Position,
        Size = UDim2.new(1, 0, 0, 42),
        Text = "",
        [Roact.Event.Activated] = props.on_click,
    }, {
        Wash = Roact.createElement("UIGradient", {
            Rotation = 0,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.45),
                NumberSequenceKeypoint.new(0.5, 0),
                NumberSequenceKeypoint.new(1, 0.45),
            }),
        }),
        Content = Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(0, 26),
        }, {
            List = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
            }),
            Price = Roact.createElement("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                FontFace = Font.new(Font.fromEnum(Enum.Font.RobotoCondensed).Family, Enum.FontWeight.Bold),
                LayoutOrder = 1,
                Size = UDim2.fromOffset(0, 26),
                Text = props.price and ("R$ " .. tostring(props.price)) or "",
                TextColor3 = Color3.fromRGB(24, 27, 24),
                TextSize = 22,
            }),
            Badge = Roact.createElement("TextLabel", {
                BackgroundColor3 = Color3.fromRGB(28, 30, 26),
                BorderSizePixel = 0,
                FontFace = Font.new(Font.fromEnum(Enum.Font.RobotoCondensed).Family, Enum.FontWeight.Bold),
                LayoutOrder = 2,
                Size = UDim2.fromOffset(42, 26),
                Text = props.badge,
                TextColor3 = Color3.fromRGB(251, 247, 235),
                TextSize = 17,
            }),
        }),
    })
end

local function roll_panel(props)
    local remaining = math.max(0, (props.reset_at or 0) - (props.now or os.time()))
    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
    }, {
        Purchase = Roact.createElement("Frame", {
            BackgroundColor3 = PANEL,
            BackgroundTransparency = 0.72,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 218),
        }, {
            Padding = Roact.createElement("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 10),
            }),
            Title = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.RobotoCondensed,
                Size = UDim2.new(1, 0, 0, 22),
                Text = "Roll an Item",
                TextColor3 = Color3.fromRGB(126, 122, 112),
                TextSize = 19,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Deal = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.RobotoCondensed,
                Position = UDim2.fromOffset(0, 24),
                Size = UDim2.new(0.5, 0, 0, 18),
                Text = "Daily Deal · 50% off",
                TextColor3 = Color3.fromRGB(117, 114, 105),
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Reset = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.RobotoCondensed,
                Position = UDim2.new(0.5, 0, 0, 24),
                Size = UDim2.new(0.5, 0, 0, 18),
                AnchorPoint = Vector2.new(0, 0),
                Text = "Resets in " .. helpers.format_time(remaining),
                TextColor3 = Color3.fromRGB(117, 114, 105),
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
            }),
            One = Roact.createElement(mint_button, {
                Position = UDim2.fromOffset(0, 48),
                price = if props.deal_available then props.deal_price else props.one_price,
                badge = if props.deal_available then "Deal" else "1x",
                on_click = props.on_one_roll,
            }),
            Ten = Roact.createElement(mint_button, {
                Position = UDim2.fromOffset(0, 100),
                price = props.ten_price,
                badge = "10x",
                on_click = props.on_ten_roll,
            }),
            Gold = Roact.createElement(animated_button, {
                Disabled = props.rolling,
                BackgroundColor3 = Color3.fromRGB(252, 249, 238),
                BackgroundTransparency = 0.45,
                BorderSizePixel = 0,
                FontFace = Font.new(Font.fromEnum(Enum.Font.RobotoCondensed).Family, Enum.FontWeight.Bold),
                Position = UDim2.fromOffset(0, 152),
                Size = UDim2.new(1, 0, 0, 42),
                Text = if props.rolling then "Rolling..." else "1,000",
                TextColor3 = Color3.fromRGB(211, 172, 63),
                TextSize = 22,
                [Roact.Event.Activated] = function()
                    if not props.rolling then
                        props.on_gold_roll()
                    end
                end,
            }, {
                Stroke = Roact.createElement("UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = Color3.fromRGB(232, 218, 170),
                    Thickness = 1,
                    Transparency = 0.65,
                }),
            }),
        }),
        Pity = Roact.createElement("Frame", {
            BackgroundColor3 = PANEL,
            BackgroundTransparency = 0.72,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, 230),
            Size = UDim2.new(1, 0, 0, 118),
        }, {
            Padding = Roact.createElement("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 10),
            }),
            Bars = Roact.createElement(pity_bars, { pity = props.pity }),
        }),
        Result = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.RobotoCondensed,
            Position = UDim2.fromOffset(0, 360),
            Size = UDim2.new(1, 0, 0, 70),
            Text = if props.last_roll then props.last_roll.message else "",
            TextColor3 = Color3.fromRGB(90, 87, 79),
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
        }),
    })
end

return roll_panel
