local mps = game:GetService("MarketplaceService")
local plrs = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")

local Roact = require(rs.Packages.roact)
local corner_frame = require(script.Parent.corner_frame)
local dashed_frame = require(script.Parent.dashed_frame)
local catalog = require(rs.ability_catalog)
local network = require(rs:WaitForChild("network_client"))
local ability_detail = require(script.Parent.ability_detail)
local ability_grid = require(script.Parent.ability_grid)
local assets = require(script.Parent.assets)
local roll_panel = require(script.Parent.roll_panel)

local player = plrs.LocalPlayer

local function format_gold(value)
    local text = tostring(math.floor(tonumber(value) or 0))
    local formatted = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return formatted:gsub("^,", "")
end

local function owned_set(list)
    local owned = {}
    for _, id in list do
        owned[id] = true
    end
    return owned
end

local function tab_button(props)
    local selected = props.selected
    return Roact.createElement("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        FontFace = Font.new(Font.fromEnum(Enum.Font.RobotoCondensed).Family, Enum.FontWeight.Bold),
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.fromOffset(140, 46),
        Text = "",
        ZIndex = 5,
        [Roact.Event.Activated] = props.on_click,
    }, {
        Fill = Roact.createElement("Frame", {
            BackgroundColor3 = if selected then Color3.fromRGB(250, 246, 233) else Color3.fromRGB(62, 56, 46),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(3, 3),
            Size = UDim2.new(1, -6, 1, -6),
            ZIndex = 1,
        }, {
            Texture = Roact.createElement("ImageLabel", {
                BackgroundTransparency = 1,
                Image = assets.image(if selected then "01-cream-dots-tile" else "02-dark-dots-tile"),
                ImageTransparency = if selected then 0.65 else 0.75,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.fromOffset(64, 64),
                Size = UDim2.fromScale(1, 1),
            }),
        }),
        Dash = Roact.createElement(dashed_frame, { selected = selected }),
        Label = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font.new(Font.fromEnum(Enum.Font.RobotoCondensed).Family, Enum.FontWeight.Bold),
            Size = UDim2.fromScale(1, 1),
            Text = props.text,
            TextColor3 = if selected then Color3.fromRGB(30, 28, 23) else Color3.fromRGB(235, 225, 205),
            TextSize = 20,
            ZIndex = 3,
        }),
    })
end

local App = Roact.Component:extend("ShopApp")

function App:init()
    self:setState({
        open = false,
        ui_scale = 1,
        tab = "abilities",
        gold = 0,
        owned = {},
        last_roll = nil,
        rolling = false,
        deal_available = true,
        reset_at = 0,
        now = os.time(),
        deal_price = nil,
        one_price = nil,
        ten_price = nil,
        pity = { rare = 0, epic = 0, mythic = 0 },
        equipped = {},
        selected_id = nil,
    })
end

function App:didMount()
    -- Keep the asset proportions and five-column layout consistent on every viewport.
    local function bind_camera()
        if self.viewport_conn then
            self.viewport_conn:Disconnect()
        end
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end
        local function resize()
            local viewport = camera.ViewportSize
            self:setState({ ui_scale = math.min(viewport.X * 0.92 / 940, viewport.Y * 0.90 / 540) })
        end
        resize()
        self.viewport_conn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
    end
    self.camera_conn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bind_camera)
    bind_camera()
    self.unsub_state = network.shop_state.On(function(data)
        self:setState({
            gold = data.gold,
            owned = owned_set(data.owned),
            equipped = owned_set(data.equipped),
            deal_available = data.deal_available,
            reset_at = data.reset_at,
            pity = data.pity,
        })
    end)

    self.unsub_roll = network.roll_result.On(function(data)
        local selected_id = self.state.selected_id
        if data.ok and data.rolls and #data.rolls > 0 then
            selected_id = data.rolls[#data.rolls].id
        end
        self:setState({
            last_roll = data,
            gold = data.gold,
            rolling = false,
            selected_id = selected_id,
        })
    end)

    local leaderstats = player:FindFirstChild("leaderstats")
    local gold_stat = leaderstats and leaderstats:FindFirstChild("Gold")
    if gold_stat then
        self:setState({ gold = gold_stat.Value })
        self.gold_conn = gold_stat:GetPropertyChangedSignal("Value"):Connect(function()
            self:setState({ gold = gold_stat.Value })
        end)
    else
        self.leaderstats_conn = player.ChildAdded:Connect(function(child)
            if child.Name ~= "leaderstats" then
                return
            end
            local stat = child:WaitForChild("Gold", 5)
            if stat then
                self:setState({ gold = stat.Value })
                self.gold_conn = stat:GetPropertyChangedSignal("Value"):Connect(function()
                    self:setState({ gold = stat.Value })
                end)
            end
        end)
    end

    self.running = true
    task.spawn(function()
        while self.running do
            self:setState({ now = os.time() })
            task.wait(1)
        end
    end)

    task.spawn(function()
        local function price_of(product_id)
            local ok, info = pcall(function()
                return mps:GetProductInfo(product_id, Enum.InfoType.Product)
            end)
            if ok and info and info.PriceInRobux then
                return info.PriceInRobux
            end
            return nil
        end

        self:setState({
            deal_price = price_of(catalog.products.deal_1x),
            one_price = price_of(catalog.products.full_1x),
            ten_price = price_of(catalog.products.robux_10x),
        })
    end)
end

function App:willUnmount()
    if self.viewport_conn then
        self.viewport_conn:Disconnect()
    end
    if self.camera_conn then
        self.camera_conn:Disconnect()
    end
    if self.unsub_state then
        self.unsub_state()
    end
    if self.unsub_roll then
        self.unsub_roll()
    end
    if self.gold_conn then
        self.gold_conn:Disconnect()
    end
    if self.leaderstats_conn then
        self.leaderstats_conn:Disconnect()
    end
    self.running = false
end

function App:gold_roll()
    if self.state.rolling then
        return
    end

    self:setState({ rolling = true })

    local ok, result = pcall(function()
        return network.roll_ability.Invoke(0)
    end)

    if ok and result then
        local owned = table.clone(self.state.owned)
        if result.ok then
            for _, roll in result.rolls do
                if not roll.is_dupe then
                    owned[roll.id] = true
                end
            end
        end
        local selected_id = self.state.selected_id
        if result.ok and result.rolls and #result.rolls > 0 then
            selected_id = result.rolls[#result.rolls].id
        end
        self:setState({
            last_roll = result,
            gold = result.gold,
            owned = owned,
            rolling = false,
            selected_id = selected_id,
        })
    else
        self:setState({
            last_roll = {
                ok = false,
                message = "Roll failed",
                gold = self.state.gold,
                rolls = {},
            },
            rolling = false,
        })
    end
end

function App:one_roll()
    local product_id = catalog.products.full_1x
    if self.state.deal_available then
        product_id = catalog.products.deal_1x
    end
    network.product_purchase.Fire(product_id)
end

function App:ten_roll()
    network.product_purchase.Fire(catalog.products.robux_10x)
end

function App:set_equipped(id, equipped)
    network.set_equipped.Fire({
        id = id,
        equipped = equipped,
    })
end

function App:last_id()
    local last = self.state.last_roll
    if last and last.rolls and #last.rolls > 0 then
        return last.rolls[#last.rolls].id
    end
    return nil
end

function App:render()
    local tab = self.state.tab
    local selected = catalog.get(self.state.selected_id)
    local body
    if tab == "abilities" then
        local right = Roact.createElement(roll_panel, {
                last_roll = self.state.last_roll,
                rolling = self.state.rolling,
                deal_available = self.state.deal_available,
                reset_at = self.state.reset_at,
                now = self.state.now,
                deal_price = self.state.deal_price,
                one_price = self.state.one_price,
                ten_price = self.state.ten_price,
                pity = self.state.pity,
                on_gold_roll = function()
                    self:gold_roll()
                end,
                on_one_roll = function()
                    self:one_roll()
                end,
                on_ten_roll = function()
                    self:ten_roll()
                end,
            })
        body = Roact.createElement("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
        }, {
            Grid = Roact.createElement("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -282, 1, if selected then -232 else 0),
            }, {
                Cards = Roact.createElement(ability_grid, {
                    equipped = self.state.equipped,
                    last_id = self:last_id(),
                    on_select = function(id)
                        self:setState({ selected_id = if self.state.selected_id == id then Roact.None else id })
                    end,
                    owned = self.state.owned,
                }),
            }),
            Detail = selected and Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, -282, 0, 220),
            }, {
                Panel = Roact.createElement(ability_detail, {
                    ability = selected,
                    owned = self.state.owned[selected.id] == true,
                    equipped = self.state.equipped[selected.id] == true,
                    on_toggle = function(id, equipped)
                        self:set_equipped(id, equipped)
                    end,
                    on_close = function()
                        self:setState({ selected_id = Roact.None })
                    end,
                }),
            }) or nil,
            Rail = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0, 270, 1, 0),
            }, { Panel = right }),
        })
    end

    return Roact.createElement("Folder", {}, {
        OpenButton = Roact.createElement("TextButton", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Color3.fromRGB(26, 25, 22),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 20, 1, -20),
            Size = UDim2.fromOffset(164, 54),
            Text = "",
            Visible = not self.state.open,
            [Roact.Event.Activated] = function()
                self:setState({ open = true, tab = "abilities" })
            end,
        }, {
            Texture = Roact.createElement("ImageLabel", {
                BackgroundTransparency = 1,
                Image = assets.image("02-dark-dots-tile"),
                ImageTransparency = 0.3,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.fromOffset(48, 48),
                Size = UDim2.fromScale(1, 1),
            }),
            Border = Roact.createElement(dashed_frame, {}),
            Label = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                FontFace = Font.new(Font.fromEnum(Enum.Font.RobotoCondensed).Family, Enum.FontWeight.Bold),
                Text = "Shop",
                TextColor3 = Color3.fromRGB(251, 242, 219),
                TextSize = 22,
                ZIndex = 3,
            }),
        }),
        Window = Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(248, 244, 236),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(940, 540),
            Visible = self.state.open,
        }, {
            Scale = Roact.createElement("UIScale", {
                Scale = self.state.ui_scale,
            }),
            Cream = Roact.createElement("ImageLabel", {
                BackgroundTransparency = 1,
                Image = assets.image("01-cream-dots-tile"),
                ImageTransparency = 0.65,
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromScale(1, 1),
                TileSize = UDim2.fromOffset(48, 48),
                ZIndex = 0,
            }),
            TopBar = Roact.createElement("Frame", {
                BackgroundColor3 = Color3.fromRGB(34, 31, 26),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 64),
                ZIndex = 2,
            }, {
                Dark = Roact.createElement("ImageLabel", {
                    BackgroundTransparency = 1,
                    Image = assets.image("02-dark-dots-tile"),
                    ImageTransparency = 0.75,
                    ScaleType = Enum.ScaleType.Tile,
                    Size = UDim2.fromScale(1, 1),
                    TileSize = UDim2.fromOffset(48, 48),
                    ZIndex = 1,
                }),
                Tabs = Roact.createElement("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, 9),
                    Size = UDim2.new(0.6, 0, 0, 46),
                    ZIndex = 5,
                }, {
                    List = Roact.createElement("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    }),
                    Abilities = Roact.createElement(tab_button, {
                        LayoutOrder = 1,
                        on_click = function()
                            self:setState({ tab = "abilities" })
                        end,
                        selected = tab == "abilities",
                        text = "Abilities",
                    }),
                    Store = Roact.createElement(tab_button, {
                        LayoutOrder = 2,
                        on_click = function()
                            self:setState({ tab = "store" })
                        end,
                        selected = tab == "store",
                        text = "Store",
                    }),
                }),
                Gold = Roact.createElement("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -72, 0.5, 0),
                    Size = UDim2.fromOffset(160, 32),
                    ZIndex = 5,
                }, {
                    Coin = Roact.createElement("Frame", {
                        BackgroundColor3 = Color3.fromRGB(232, 185, 35),
                        BorderSizePixel = 0,
                        Size = UDim2.fromOffset(18, 18),
                        Position = UDim2.new(0, 0, 0.5, -9),
                    }, {
                        Corner = Roact.createElement("UICorner", {
                            CornerRadius = UDim.new(1, 0),
                        }),
                    }),
                    Amount = Roact.createElement("TextLabel", {
                        BackgroundTransparency = 1,
                        FontFace = Font.new(Font.fromEnum(Enum.Font.RobotoCondensed).Family, Enum.FontWeight.Bold),
                        Position = UDim2.fromOffset(24, 0),
                        Size = UDim2.new(1, -24, 1, 0),
                        Text = format_gold(self.state.gold),
                        TextColor3 = Color3.fromRGB(232, 185, 35),
                        TextSize = 18,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }),
                }),
                Close = Roact.createElement("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    AutoButtonColor = true,
                    BackgroundColor3 = Color3.fromRGB(251, 247, 233),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -18, 0.5, 0),
                    Size = UDim2.fromOffset(36, 36),
                    Text = "",
                    ZIndex = 5,
                    [Roact.Event.Activated] = function()
                        self:setState({ open = false })
                    end,
                }, {
                    Texture = Roact.createElement("ImageLabel", {
                        BackgroundTransparency = 1,
                        Image = assets.image("01-cream-dots-tile"),
                        ImageTransparency = 0.65,
                        ScaleType = Enum.ScaleType.Tile,
                        TileSize = UDim2.fromOffset(48, 48),
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 1,
                    }),
                    -- A crisp cross remains visible even when image assets fail to load.
                    CrossLeft = Roact.createElement("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(28, 26, 22),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Rotation = 45,
                        Size = UDim2.fromOffset(21, 4),
                        ZIndex = 3,
                    }),
                    CrossRight = Roact.createElement("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(28, 26, 22),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Rotation = -45,
                        Size = UDim2.fromOffset(21, 4),
                        ZIndex = 3,
                    }),
                    Corners = Roact.createElement(corner_frame, {
                        asset = "05-corners-tan",
                        Position = UDim2.fromOffset(-12, -12),
                        Size = UDim2.new(1, 24, 1, 24),
                    }),
                }),
            }),
            Body = Roact.createElement("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 64),
                Size = UDim2.new(1, 0, 1, -64),
                ZIndex = 2,
            }, {
                Padding = Roact.createElement("UIPadding", {
                    PaddingBottom = UDim.new(0, 12),
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                    PaddingTop = UDim.new(0, 12),
                }),
                Content = body,
            }),
        }),
    })
end

return App
