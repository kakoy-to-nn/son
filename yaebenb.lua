local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local state = {
showCommands = true,
showHUD = true,
discoveredCommands = {},
hasHook = pcall(function() return hookmetamethod end)
}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
screenGui.Parent = gethui and gethui() or game.CoreGui
end)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 340)
mainFrame.Position = UDim2.new(0.5, -130, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ZIndex = 10
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(80, 80, 90)
stroke.Thickness = 1
stroke.ZIndex = 10
local dragging, dragStart, startPos = false, nil, nil
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 11
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)
titleBar.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.Touch then
dragging = true; dragStart = i.Position; startPos = mainFrame.Position
end
end)
titleBar.InputChanged:Connect(function(i)
if dragging and i.UserInputType == Enum.UserInputType.Touch then
local d = i.Position - dragStart
mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
end
end)
UserInputService.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1,-50,1,0); titleLabel.Position = UDim2.new(0,12,0,0)
titleLabel.BackgroundTransparency = 1; titleLabel.Text = "Δ Delta Script"
titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 16
titleLabel.TextColor3 = Color3.fromRGB(220,220,230); titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 12; titleLabel.Parent = titleBar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,32,0,32); closeBtn.Position = UDim2.new(1,-36,0,4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50); closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 16; closeBtn.TextColor3 = Color3.white
closeBtn.BorderSizePixel = 0; closeBtn.ZIndex = 12; closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
local function createToggle(name, yPos, initial, cb)
local c = Instance.new("Frame")
c.Size = UDim2.new(1,-16,0,44); c.Position = UDim2.new(0,8,0,yPos)
c.BackgroundColor3 = Color3.fromRGB(35,35,42); c.BorderSizePixel = 0
c.ZIndex = 11; c.Parent = mainFrame
Instance.new("UICorner", c).CornerRadius = UDim.new(0,6)
local l = Instance.new("TextLabel")
l.Size = UDim2.new(1,-70,1,0); l.Position = UDim2.new(0,12,0,0)
l.BackgroundTransparency = 1; l.Text = name
l.Font = Enum.Font.Gotham; l.TextSize = 15
l.TextColor3 = Color3.fromRGB(200,200,210); l.TextXAlignment = Enum.TextXAlignment.Left
l.ZIndex = 12; l.Parent = c
local b = Instance.new("TextButton")
b.Size = UDim2.new(0,50,0,26); b.Position = UDim2.new(1,-58,0.5,-13)
b.BackgroundColor3 = initial and Color3.fromRGB(50,180,80) or Color3.fromRGB(80,80,90)
b.Text = initial and "ON" or "OFF"
b.Font = Enum.Font.GothamBold; b.TextSize = 13; b.TextColor3 = Color3.white
b.BorderSizePixel = 0; b.ZIndex = 12; b.Parent = c
Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
local en = initial
b.MouseButton1Click:Connect(function()
en = not en
b.BackgroundColor3 = en and Color3.fromRGB(50,180,80) or Color3.fromRGB(80,80,90)
b.Text = en and "ON" or "OFF"
cb(en)
end)
end
createToggle("Command Spy", 48, true, function(v) state.showCommands = v end)
createToggle("HP / Event HUD", 98, true, function(v) state.showHUD = v end)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,-16,0,180)
statusLabel.Position = UDim2.new(0,8,0,150)
statusLabel.BackgroundColor3 = Color3.fromRGB(25,25,30)
statusLabel.BorderSizePixel = 0
statusLabel.Text = "Status: Active\nCmds: 0\nHP: --\n[No Drawing API]"
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(160,220,160)
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.ZIndex = 12
statusLabel.Parent = mainFrame
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0,6)
local pad = Instance.new("UIPadding", statusLabel)
pad.PaddingLeft = UDim.new(0,8); pad.PaddingTop = UDim.new(0,6)
if state.hasHook then
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
local method = getnamecallmethod()
if (method == "FireServer" or method == "InvokeServer") and state.showCommands then
local args = {...}
if type(args[1]) == "string" then
local cmd = string.lower(args[1])
if not state.discoveredCommands[cmd] then
state.discoveredCommands[cmd] = tostring(self)
end
end
end
return oldNamecall(self, ...)
end)
else
statusLabel.Text = statusLabel.Text .. "\n Hook unavailable"
end
RunService.RenderStepped:Connect(function()
local char = LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
local hpStr = "--"
local cmdCount = 0
for _ in pairs(state.discoveredCommands) do cmdCount = cmdCount + 1 end
if state.showHUD and hum then
hpStr = string.format("%d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
end
local st = (state.showCommands or state.showHUD) and "Active" or "Paused"
local extra = state.hasHook and "" or "\n Hook unavailable"
statusLabel.Text = string.format("Status: %s\nCmds: %d\nHP: %s%s", st, cmdCount, hpStr, extra)
end)
