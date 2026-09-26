local plrs = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")

local Roact = require(rs.Packages.roact)
local App = require(rs.shop_ui.app)

local player = plrs.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")

local screen = Instance.new("ScreenGui")
screen.Name = "AbilityShop"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = player_gui

Roact.mount(Roact.createElement(App), screen)
