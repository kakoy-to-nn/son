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
pcall(function()
screenGui.Parent = gethui and gethui() or game.CoreGui
end)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 300)
mainFrame.Position = UDim2.new(0.5, -130, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 8)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(80, 80, 90)
mainStroke.Thickness = 1
local dragging = false
local dragStart = nil
local startPos = nil
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 8)
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
mainFrame.Position = UDim2.new(
startPos.X.Scale, startPos.X.Offset + delta.X,
startPos.Y.Scale, startPos.Y.Offset + delta.Y
)
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
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
screenGui:Destroy()
end)
local function createToggle(name, yPos, initial, callback)
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -16, 0, 44)
container.Position = UDim2.new(0, 8, 0, yPos)
container.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
container.BorderSizePixel = 0
container.Parent = mainFrame
local cCorner = Instance.new("UICorner", container)
cCorner.CornerRadius = UDim.new(0, 6)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -70, 1, 0)
label.Position = UDim2.new(0, 12, 0, 0)
label.BackgroundTransparency = 1
label.Text = name
label.Font = Enum.Font.Gotham
label.TextSize = 15
label.TextColor3 = Color3.fromRGB(200, 200, 210)
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = container
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 50, 0, 26)
btn.Position = UDim2.new(1, -58, 0.5, -13)
btn.BackgroundColor3 = initial and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(80, 80, 90)
btn.Text = initial and "ON" or "OFF"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 13
btn.TextColor3 = Color3.white
btn.BorderSizePixel = 0
btn.Parent = container
local bCorner = Instance.new("UICorner", btn)
bCorner.CornerRadius = UDim.new(0, 4)
local enabled = initial
btn.MouseButton1Click:Connect(function()
enabled = not enabled
btn.BackgroundColor3 = enabled and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(80, 80, 90)
btn.Text = enabled and "ON" or "OFF"
callback(enabled)
end)
return container
end
createToggle("Command Spy", 48, true, function(v)
state.showCommands = v
end)
createToggle("HP / Event HUD", 98, true, function(v)
state.showHUD = v
end)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 0, 140)
statusLabel.Position = UDim2.new(0, 8, 0, 150)
statusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
statusLabel.BorderSizePixel = 0
statusLabel.Text = "Status: Active\nCmds: 0\nHP: --"
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(160, 220, 160)
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.Parent = mainFrame
local sCorner = Instance.new("UICorner", statusLabel)
sCorner.CornerRadius = UDim.new(0, 6)
local sPad = Instance.new("UIPadding", statusLabel)
sPad.PaddingLeft = UDim.new(0, 8)
sPad.PaddingTop = UDim.new(0, 6)
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
state.hudElements.hpBar = Drawing.new("Line")
state.hudElements.hpBar.Thickness = 4
state.hudElements.hpText = Drawing.new("Text")
state.hudElements.hpText.Size = 16
state.hudElements.hpText.Color = Color3.fromRGB(255, 255, 255)
state.hudElements.hpText.Outline = true
RunService.RenderStepped:Connect(function()
local char = LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
local hpStr = "--"
local cmdCount = 0
for _ in pairs(state.discoveredCommands) do
cmdCount = cmdCount + 1
end
if state.showHUD and hum then
local hp = hum.Health
local maxHp = hum.MaxHealth
local ratio = math.clamp(hp / maxHp, 0, 1)
hpStr = string.format("%d/%d", math.floor(hp), math.floor(maxHp))
local vp = workspace.CurrentCamera.ViewportSize
local x = vp.X - 220
local y = 30
state.hudElements.hpBar.From = Vector2.new(x, y)
state.hudElements.hpBar.To = Vector2.new(x + 200 * ratio, y)
if ratio > 0.5 then
state.hudElements.hpBar.Color = Color3.fromRGB(0, 255, 0)
elseif ratio > 0.25 then
state.hudElements.hpBar.Color = Color3.fromRGB(255, 255, 0)
else
state.hudElements.hpBar.Color = Color3.fromRGB(255, 0, 0)
end
state.hudElements.hpBar.Visible = true
state.hudElements.hpText.Text = "HP: " .. hpStr
state.hudElements.hpText.Position = Vector2.new(x, y + 8)
state.hudElements.hpText.Visible = true
else
state.hudElements.hpBar.Visible = false
state.hudElements.hpText.Visible = false
end
local statusText = "Status: "
if state.showCommands or state.showHUD then
statusText = statusText .. "Active"
else
statusText = statusText .. "Paused"
end
statusText = statusText .. "\nCmds: " .. tostring(cmdCount)
statusText = statusText .. "\nHP: " .. hpStr
statusLabel.Text = statusText
end)
