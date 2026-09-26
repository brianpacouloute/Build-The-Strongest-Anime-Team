local rs = game:GetService("ReplicatedStorage")
local Roact = require(rs.Packages.roact)
local helpers = require(rs.helpers)

local MINT = Color3.fromRGB(0, 220, 170)
local GOLD_BG = Color3.fromRGB(255, 248, 230)
local GOLD_TEXT = Color3.fromRGB(200, 150, 20)

local function mint_button(props)
    return Roact.createElement("TextButton", {
        AutoButtonColor = true,
        BackgroundColor3 = MINT,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.new(1, 0, 0, 48),
        Text = props.text,
        TextColor3 = Color3.fromRGB(20, 20, 20),
        TextSize = 18,
        [Roact.Event.Activated] = props.on_click,
    }, {
        Corner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
    })
end

local function roll_panel(props)
    local last = props.last_roll
    local result_text = "Roll to unlock an ability"
    if last then
        result_text = last.message
    end

    local remaining = math.max(0, (props.reset_at or 0) - (props.now or os.time()))
    local reset_text = "Resets in " .. helpers.format_time(remaining)

    local one_label = "Deal"
    if props.deal_available then
        if props.deal_price then
            one_label = "R$ " .. tostring(props.deal_price) .. "  ·  Deal"
        end
    else
        one_label = "1x"
        if props.one_price then
            one_label = "R$ " .. tostring(props.one_price) .. "  ·  1x"
        end
    end

    local ten_label = "10x"
    if props.ten_price then
        ten_label = "R$ " .. tostring(props.ten_price) .. "  ·  10x"
    end

    local gold_label = "1,000 Gold"
    if props.rolling then
        gold_label = "Rolling..."
    end

    return Roact.createElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
    }, {
        Corner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 12),
        }),
        Padding = Roact.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 20),
            PaddingLeft = UDim.new(0, 18),
            PaddingRight = UDim.new(0, 18),
            PaddingTop = UDim.new(0, 20),
        }),
        List = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        Title = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            LayoutOrder = 1,
            Size = UDim2.new(1, 0, 0, 26),
            Text = "Roll an Ability",
            TextColor3 = Color3.fromRGB(35, 35, 35),
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        DealLine = Roact.createElement("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            Size = UDim2.new(1, 0, 0, 20),
        }, {
            Left = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(0.55, 0, 1, 0),
                Text = "Daily Deal · 50% off",
                TextColor3 = Color3.fromRGB(120, 120, 120),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Right = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromScale(0.45, 0),
                Size = UDim2.new(0.55, 0, 1, 0),
                Text = reset_text,
                TextColor3 = Color3.fromRGB(120, 120, 120),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
            }),
        }),
        OneButton = Roact.createElement(mint_button, {
            LayoutOrder = 3,
            on_click = props.on_one_roll,
            text = one_label,
        }),
        TenButton = Roact.createElement(mint_button, {
            LayoutOrder = 4,
            on_click = props.on_ten_roll,
            text = ten_label,
        }),
        GoldButton = Roact.createElement("TextButton", {
            AutoButtonColor = not props.rolling,
            BackgroundColor3 = if props.rolling then Color3.fromRGB(220, 220, 220) else GOLD_BG,
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            LayoutOrder = 5,
            Size = UDim2.new(1, 0, 0, 48),
            Text = gold_label,
            TextColor3 = GOLD_TEXT,
            TextSize = 18,
            [Roact.Event.Activated] = function()
                if not props.rolling then
                    props.on_gold_roll()
                end
            end,
        }, {
            Corner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0, 8),
            }),
            Stroke = Roact.createElement("UIStroke", {
                Color = Color3.fromRGB(230, 210, 160),
                Thickness = 1,
            }),
        }),
        Result = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            LayoutOrder = 6,
            Size = UDim2.new(1, 0, 0, 48),
            Text = result_text,
            TextColor3 = Color3.fromRGB(70, 70, 70),
            TextSize = 15,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
        }),
    })
end

return roll_panel
