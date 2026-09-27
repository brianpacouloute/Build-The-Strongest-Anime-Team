local rs = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Roact = require(rs.Packages.roact)

local AnimatedPanel = Roact.Component:extend("ShopAnimatedPanel")

function AnimatedPanel:init()
    self.group_ref = Roact.createRef()
    self.scale_ref = Roact.createRef()
    self.tweens = {}
end

function AnimatedPanel:cancel()
    if self.completion then
        self.completion:Disconnect()
        self.completion = nil
    end
    for _, tween in self.tweens do
        tween:Cancel()
    end
    table.clear(self.tweens)
end

function AnimatedPanel:reveal(from_current)
    self:cancel()
    local group = self.group_ref:getValue()
    local scale = self.scale_ref:getValue()
    if not group or not scale then
        return
    end
    if not from_current then
        group.GroupTransparency = 1
        group.Position = UDim2.new(0.5, 0, 0.5, self.props.Offset or 10)
        scale.Scale = self.props.StartScale or 1
    end
    local info = TweenInfo.new(self.props.Duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    self.tweens = {
        TweenService:Create(group, info, {
            GroupTransparency = 0,
            Position = UDim2.fromScale(0.5, 0.5),
        }),
        TweenService:Create(scale, info, { Scale = 1 }),
    }
    for _, tween in self.tweens do
        tween:Play()
    end
end

function AnimatedPanel:conceal()
    self:cancel()
    local group = self.group_ref:getValue()
    local scale = self.scale_ref:getValue()
    if not group or not scale then
        return
    end
    local info = TweenInfo.new(self.props.CloseDuration or 0.34, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    self.tweens = {
        TweenService:Create(group, info, {
            GroupTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, (self.props.Offset or 10) * 0.65),
        }),
        TweenService:Create(scale, info, { Scale = 0.99 }),
    }
    self.completion = self.tweens[1].Completed:Connect(function(status)
        if status == Enum.PlaybackState.Completed and self.props.Closing and self.props.OnClosed then
            self.props.OnClosed()
        end
    end)
    for _, tween in self.tweens do
        tween:Play()
    end
end

function AnimatedPanel:didMount()
    if self.props.Visible ~= false then
        if self.props.Closing then
            self:conceal()
        else
            self:reveal()
        end
    end
end

function AnimatedPanel:didUpdate(previous)
    if self.props.Visible == false then
        self:cancel()
    elseif self.props.Closing then
        if not previous.Closing then
            self:conceal()
        end
    elseif previous.Visible == false or previous.Closing or previous.RevealKey ~= self.props.RevealKey then
        self:reveal(previous.Closing == true)
    end
end

function AnimatedPanel:willUnmount()
    self:cancel()
end

function AnimatedPanel:render()
    local props = self.props
    local children = table.clone(props[Roact.Children] or {})
    children.EntranceScale = Roact.createElement("UIScale", {
        Scale = 1,
        [Roact.Ref] = self.scale_ref,
    })
    return Roact.createElement("Frame", {
        AnchorPoint = props.AnchorPoint,
        Position = props.Position,
        Size = props.Size,
        LayoutOrder = props.LayoutOrder,
        Visible = props.Visible,
        ZIndex = props.ZIndex,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, {
        ViewportScale = Roact.createElement("UIScale", {
            Scale = props.ViewportScale or 1,
        }),
        Content = Roact.createElement("CanvasGroup", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = props.BackgroundColor3,
            BackgroundTransparency = props.BackgroundTransparency or 0,
            BorderSizePixel = 0,
            GroupTransparency = 1,
            Interactable = not props.Closing,
            [Roact.Ref] = self.group_ref,
        }, children),
    })
end

return AnimatedPanel
