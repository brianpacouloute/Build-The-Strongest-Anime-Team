local rs = game:GetService("ReplicatedStorage")
local Roact = require(rs.Packages.roact)
local assets = require(script.Parent.assets)

-- Nine-slicing preserves the supplied corner artwork on wide and square panels.
local CornerFrame = Roact.Component:extend("ShopCornerFrame")

function CornerFrame:init()
    self:setState({ loaded = false })
end

function CornerFrame:render()
    local props = self.props
    local color = props.color or Color3.fromRGB(174, 159, 131)
    local children = {
        Artwork = Roact.createElement("ImageLabel", {
            BackgroundTransparency = 1,
            Image = assets.image(props.asset or "05-corners-tan"),
            ImageTransparency = props.transparency or 0,
            ImageColor3 = props.color or Color3.new(1, 1, 1),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(54, 54, 458, 458),
            SliceScale = 0.4,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 2,
            [Roact.Change.IsLoaded] = function(image)
                self:setState({ loaded = image.IsLoaded })
            end,
        }),
    }
    -- Keep the frame legible while Roblox downloads or rejects a decorative asset.
    if not self.state.loaded then
        for index, corner in { Vector2.new(0, 0), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(1, 1) } do
            children["Corner" .. index] = Roact.createElement("Frame", {
                AnchorPoint = corner,
                BackgroundTransparency = 1,
                Position = UDim2.new(corner.X, if corner.X == 0 then 8 else -8, corner.Y, if corner.Y == 0 then 8 else -8),
                Size = UDim2.fromOffset(10, 10),
            }, {
                Horizontal = Roact.createElement("Frame", {
                    BackgroundColor3 = color,
                    BackgroundTransparency = props.transparency or 0,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, corner.Y, -corner.Y),
                    Size = UDim2.new(1, 0, 0, 1),
                }),
                Vertical = Roact.createElement("Frame", {
                    BackgroundColor3 = color,
                    BackgroundTransparency = props.transparency or 0,
                    BorderSizePixel = 0,
                    Position = UDim2.new(corner.X, -corner.X, 0, 0),
                    Size = UDim2.new(0, 1, 1, 0),
                }),
            })
        end
    end
    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Position = props.Position or UDim2.new(),
        Size = props.Size or UDim2.fromScale(1, 1),
        ZIndex = props.ZIndex or 4,
    }, children)
end

return CornerFrame
