local rs = game:GetService("ReplicatedStorage")
local Roact = require(rs.Packages.roact)
local catalog = require(rs.ability_catalog)
local ability_card = require(script.Parent.ability_card)

local function ability_grid(props)
    local cards = {
        Layout = Roact.createElement("UIGridLayout", {
            CellPadding = UDim2.fromOffset(12, 12),
            CellSize = UDim2.fromOffset(115, 180),
            FillDirectionMaxCells = 5,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        Padding = Roact.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }),
    }

    for index, ability in catalog.abilities do
        if not props.owned_only or props.owned[ability.id] then
            cards[ability.id] = Roact.createElement(ability_card, {
                ability = ability,
                equipped = props.equipped and props.equipped[ability.id] == true,
                highlighted = props.last_id == ability.id,
                LayoutOrder = index,
                on_select = props.on_select,
                owned = props.owned[ability.id] == true,
            })
        end
    end

    return Roact.createElement("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ScrollBarImageColor3 = Color3.fromRGB(180, 174, 164),
        ScrollBarThickness = 3,
        Size = UDim2.fromScale(1, 1),
    }, cards)
end

return ability_grid
