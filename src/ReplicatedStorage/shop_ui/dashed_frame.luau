local rs = game:GetService("ReplicatedStorage")
local Roact = require(rs.Packages.roact)
local assets = require(script.Parent.assets)

local DashedFrame = Roact.Component:extend("ShopDashedFrame")
function DashedFrame:init()
    self:setState({ loaded = false })
end

function DashedFrame:render()
    local selected = self.props.selected
    local children = {
        Asset = Roact.createElement("ImageLabel", {
            BackgroundTransparency = 1,
            Image = assets.image(if selected then "04-tab-dashed-cream" else "04-tab-dashed-tan"),
            ScaleType = Enum.ScaleType.Fit,
            Size = UDim2.fromScale(1, 1),
            [Roact.Change.IsLoaded] = function(image)
                self:setState({ loaded = image.IsLoaded })
            end,
        }),
    }
    -- Match the dashed asset while it loads, without substituting corner brackets.
    if not self.state.loaded then
        local color = if selected then Color3.fromRGB(251, 243, 222) else Color3.fromRGB(173, 155, 124)
        for index = 0, 23 do
            for _, bottom in { false, true } do
                children["H" .. index .. tostring(bottom)] = Roact.createElement("Frame", {
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Position = UDim2.new(index / 24, 1, if bottom then 1 else 0, if bottom then -2 else 1),
                    Size = UDim2.new(1 / 48, 0, 0, 1),
                })
            end
        end
        for index = 0, 7 do
            for _, right in { false, true } do
                children["V" .. index .. tostring(right)] = Roact.createElement("Frame", {
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Position = UDim2.new(if right then 1 else 0, if right then -2 else 1, index / 8, 1),
                    Size = UDim2.new(0, 1, 1 / 16, 0),
                })
            end
        end
    end
    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
    }, children)
end

return DashedFrame
