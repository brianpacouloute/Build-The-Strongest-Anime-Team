local rs = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Roact = require(rs.Packages.roact)

local AnimatedButton = Roact.Component:extend("ShopAnimatedButton")
local layout_props = { "AnchorPoint", "Position", "Size", "LayoutOrder", "Visible", "ZIndex" }

function AnimatedButton:init()
    self.scale_ref = Roact.createRef()
    self.hovered = false
    self.focused = false
    self.press_input = nil
end

function AnimatedButton:enabled()
    return not self.props.Disabled and self.props.Visible ~= false
end

function AnimatedButton:animate()
    local scale = self.scale_ref:getValue()
    if not scale then
        return
    end
    local target = 1
    if self:enabled() then
        target = if self.press_input then 0.975 elseif self.hovered or self.focused then 1.015 else 1
    end
    if self.tween then
        self.tween:Cancel()
    end
    self.tween = TweenService:Create(scale,
        TweenInfo.new(if self.press_input then 0.08 else 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Scale = target })
    self.tween:Play()
end

function AnimatedButton:reset()
    self.hovered = false
    self.focused = false
    self.press_input = nil
    self:animate()
end

function AnimatedButton:didMount()
    -- A release outside the button must also end a mouse/touch press.
    self.release_connection = UserInputService.InputEnded:Connect(function(input)
        local pressed = self.press_input
        if pressed and (input == pressed or (input.UserInputType == Enum.UserInputType.MouseButton1
            and pressed.UserInputType == Enum.UserInputType.MouseButton1)) then
            self.press_input = nil
            self:animate()
        end
    end)
    self.focus_connection = UserInputService.WindowFocusReleased:Connect(function()
        self:reset()
    end)
end

function AnimatedButton:didUpdate()
    if not self:enabled() then
        self:reset()
    end
end

function AnimatedButton:willUnmount()
    if self.tween then
        self.tween:Cancel()
    end
    self.release_connection:Disconnect()
    self.focus_connection:Disconnect()
end

function AnimatedButton:render()
    local outer = { BackgroundTransparency = 1, BorderSizePixel = 0 }
    local button = table.clone(self.props)
    for _, key in layout_props do
        outer[key] = self.props[key]
        button[key] = nil
    end
    button.Disabled = nil
    button[Roact.Children] = nil
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Position = UDim2.fromScale(0.5, 0.5)
    button.Size = UDim2.fromScale(1, 1)
    button.ZIndex = self.props.ZIndex or 1
    button.AutoButtonColor = false
    button.Active = self:enabled()
    button.Selectable = self:enabled() and self.props.Selectable ~= false
    button[Roact.Event.MouseEnter] = function()
        self.hovered = true
        self:animate()
    end
    button[Roact.Event.MouseLeave] = function()
        self.hovered = false
        self.press_input = nil
        self:animate()
    end
    button[Roact.Event.SelectionGained] = function()
        self.focused = true
        self:animate()
    end
    button[Roact.Event.SelectionLost] = function()
        self.focused = false
        self.press_input = nil
        self:animate()
    end
    button[Roact.Event.InputBegan] = function(_, input)
        if self:enabled() and (input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA) then
            self.press_input = input
            self:animate()
        end
    end
    button[Roact.Event.Activated] = function(...)
        local activate = self.props[Roact.Event.Activated]
        if self:enabled() and activate then
            activate(...)
        end
    end
    local children = table.clone(self.props[Roact.Children] or {})
    children.PressScale = Roact.createElement("UIScale", {
        Scale = 1,
        [Roact.Ref] = self.scale_ref,
    })
    -- The outer frame holds layout steady while the button scales around its center.
    return Roact.createElement("Frame", outer, {
        Button = Roact.createElement("TextButton", button, children),
    })
end

return AnimatedButton
