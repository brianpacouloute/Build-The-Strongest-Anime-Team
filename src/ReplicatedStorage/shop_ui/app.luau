local mps = game:GetService("MarketplaceService")
local plrs = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")

local Roact = require(rs.Packages.roact)
local catalog = require(rs.ability_catalog)
local network = require(rs:WaitForChild("network_client"))
local ability_detail = require(script.Parent.ability_detail)
local ability_grid = require(script.Parent.ability_grid)
local pity_bars = require(script.Parent.pity_bars)
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

local App = Roact.Component:extend("ShopApp")

function App:init()
    self:setState({
        open = false,
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

function App:render()
    return Roact.createElement("Folder", {}, {
        OpenButton = Roact.createElement("TextButton", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Color3.fromRGB(43, 47, 54),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            Position = UDim2.new(0, 20, 1, -20),
            Size = UDim2.fromOffset(120, 44),
            Text = "Shop",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            Visible = not self.state.open,
            [Roact.Event.Activated] = function()
                self:setState({ open = true })
            end,
        }, {
            Corner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0, 10),
            }),
        }),
        Window = Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(244, 239, 230),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(0.82, 0.78),
            Visible = self.state.open,
        }, {
            Corner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0, 14),
            }),
            TopBar = Roact.createElement("Frame", {
                BackgroundColor3 = Color3.fromRGB(43, 47, 54),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 64),
            }, {
                Corner = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 14),
                }),
                Cover = Roact.createElement("Frame", {
                    BackgroundColor3 = Color3.fromRGB(43, 47, 54),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, -16),
                    Size = UDim2.new(1, 0, 0, 16),
                }),
                Title = Roact.createElement("TextLabel", {
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Position = UDim2.fromOffset(24, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Text = "Ability Shop",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 24,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
                Gold = Roact.createElement("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Color3.fromRGB(58, 63, 72),
                    BorderSizePixel = 0,
                    Font = Enum.Font.GothamBold,
                    Position = UDim2.new(1, -64, 0.5, 0),
                    Size = UDim2.fromOffset(160, 34),
                    Text = format_gold(self.state.gold) .. " G",
                    TextColor3 = Color3.fromRGB(232, 185, 35),
                    TextSize = 16,
                }, {
                    Corner = Roact.createElement("UICorner", {
                        CornerRadius = UDim.new(0, 8),
                    }),
                }),
                Close = Roact.createElement("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Color3.fromRGB(70, 74, 82),
                    BorderSizePixel = 0,
                    Font = Enum.Font.GothamBold,
                    Position = UDim2.new(1, -16, 0.5, 0),
                    Size = UDim2.fromOffset(36, 36),
                    Text = "X",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 16,
                    [Roact.Event.Activated] = function()
                        self:setState({ open = false })
                    end,
                }, {
                    Corner = Roact.createElement("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                    }),
                }),
            }),
            Body = Roact.createElement("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 64),
                Size = UDim2.new(1, 0, 1, -64),
            }, {
                Padding = Roact.createElement("UIPadding", {
                    PaddingBottom = UDim.new(0, 20),
                    PaddingLeft = UDim.new(0, 20),
                    PaddingRight = UDim.new(0, 20),
                    PaddingTop = UDim.new(0, 16),
                }),
                Header = Roact.createElement("TextLabel", {
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Size = UDim2.new(1, -300, 0, 36),
                    Text = "Available Abilities",
                    TextColor3 = Color3.fromRGB(80, 80, 80),
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
                Grid = Roact.createElement("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(0, 40),
                    Size = UDim2.new(1, -300, 1, -370),
                }, {
                    Cards = Roact.createElement(ability_grid, {
                        last_id = (function()
                            local last = self.state.last_roll
                            if last and last.rolls and #last.rolls > 0 then
                                return last.rolls[#last.rolls].id
                            end
                            return nil
                        end)(),
                        equipped = self.state.equipped,
                        on_select = function(id)
                            self:setState({ selected_id = id })
                        end,
                        owned = self.state.owned,
                        selected_id = self.state.selected_id,
                    }),
                }),
                Detail = Roact.createElement("Frame", {
                    AnchorPoint = Vector2.new(0, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 1, -116),
                    Size = UDim2.new(1, -300, 0, 168),
                }, {
                    Panel = Roact.createElement(ability_detail, {
                        ability = catalog.get(self.state.selected_id),
                        equipped = self.state.equipped[self.state.selected_id] == true,
                        on_toggle = function(id, equipped)
                            self:set_equipped(id, equipped)
                        end,
                        owned = self.state.owned[self.state.selected_id] == true,
                    }),
                }),
                Pity = Roact.createElement("Frame", {
                    AnchorPoint = Vector2.new(0, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(1, -300, 0, 108),
                }, {
                    Bars = Roact.createElement(pity_bars, {
                        pity = self.state.pity,
                    }),
                }),
                Rail = Roact.createElement("Frame", {
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(1, 0),
                    Size = UDim2.new(0, 280, 1, 0),
                }, {
                    Panel = Roact.createElement(roll_panel, {
                        last_roll = self.state.last_roll,
                        rolling = self.state.rolling,
                        deal_available = self.state.deal_available,
                        reset_at = self.state.reset_at,
                        now = self.state.now,
                        deal_price = self.state.deal_price,
                        one_price = self.state.one_price,
                        ten_price = self.state.ten_price,
                        on_gold_roll = function()
                            self:gold_roll()
                        end,
                        on_one_roll = function()
                            self:one_roll()
                        end,
                        on_ten_roll = function()
                            self:ten_roll()
                        end,
                    }),
                }),
            }),
        }),
    })
end

return App
