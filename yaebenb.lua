local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local state = {
showCommands = true,
showHUD = true,
discoveredCommands = {},
hudElements = {}
}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaMenu"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = gethui and gethui() or game.CoreGui end)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 300)
mainFrame.Position = UDim2.new(0.5, -130, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(80, 80, 90)
stroke.Thickness = 1
-- Manual drag for mobile (Frame.Draggable unreliable on touch)
local dragging = false
local dragStart = nil
local startPos = nil
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)
titleBar.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = mainFrame.Position
end
end)
titleBar.InputChanged:Connect(function(input)
if dragging and input.UserInputType == Enum.UserInputType.Touch then
local delta = input.Position - dragStart
mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
end)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Δ Delta Script"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.white
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
local function createToggle(name, yPos, initial, cb)
local c = Instance.new("Frame")
c.Size = UDim2.new(1, -16, 0, 44)
c.Position = UDim2.new(0, 8, 0, yPos)
c.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
c.BorderSizePixel = 0
c.Parent = mainFrame
Instance.new("UICorner", c).CornerRadius = UDim.new(0, 6)
local l = Instance.new("TextLabel")
l.Size = UDim2.new(1, -70, 1, 0)
l.Position = UDim2.new(0, 12, 0, 0)
l.BackgroundTransparency = 1
l.Text = name
l.Font = Enum.Font.Gotham
l.TextSize = 15
