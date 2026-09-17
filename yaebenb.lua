local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
-- === CONFIG ===
local SHOW_COMMANDS = true
local SHOW_HUD = true
local HUD_UPDATE_INTERVAL = 0.1  -- seconds
local MAX_COMMANDS_DISPLAY = 50
-- === COMMAND DISCOVERY VIA REMOTE SPY ===
local discoveredCommands = {}
local remoteCache = {}
local function hookRemotes()
-- Hook __namecall to intercept remote invocations
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
local method = getnamecallmethod()
if method == "FireServer" or method == "InvokeServer" then
local remoteName = tostring(self)
local args = {...}
-- Log potential admin commands
if type(args[1]) == "string" then
local cmd = string.lower(args[1])
if not discoveredCommands[cmd] then
discoveredCommands[cmd] = {
remote = remoteName,
firstSeen = os.time(),
sampleArgs = table.concat({unpack(args, 1, math.min(#args, 3))}, ", ")
}
end
end
end
return oldNamecall(self, ...)
end)
end
-- === HUD OVERLAY ===
local hudElements = {}
local function createHUD()
if not SHOW_HUD then return end
-- HP Bar
hudElements.hpBar = Drawing.new("Line")
hudElements.hpBar.Thickness = 4
hudElements.hpBar.Color = Color3.fromRGB(0, 255, 0)
-- HP Text
hudElements.hpText = Drawing.new("Text")
hudElements.hpText.Size = 16
hudElements.hpText.Color = Color3.fromRGB(255, 255, 255)
hudElements.hpText.Outline = true
-- Event Log
hudElements.eventText = Drawing.new("Text")
hudElements.eventText.Size = 14
hudElements.eventText.Color = Color3.fromRGB(255, 255, 0)
hudElements.eventText.Outline = true
end
local function updateHUD()
if not SHOW_HUD then return end
local char = LocalPlayer.Character
local humanoid = char and char:FindFirstChildOfClass("Humanoid")
if humanoid then
local hp = humanoid.Health
local maxHp = humanoid.MaxHealth
local ratio = math.clamp(hp / maxHp, 0, 1)
-- Position HUD relative to viewport
local vp = workspace.CurrentCamera.ViewportSize
local barWidth = 200
local x = vp.X - barWidth - 20
local y = 30
hudElements.hpBar.From = Vector2.new(x, y)
hudElements.hpBar.To = Vector2.new(x + barWidth * ratio, y)
hudElements.hpBar.Color = ratio > 0.5 and Color3.fromRGB(0,255,0) or ratio > 0.25 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0)
hudElements.hpBar.Visible = true
hudElements.hpText.Text = string.format("HP: %d/%d (%.0f%%)", hp, maxHp, ratio*100)
hudElements.hpText.Position = Vector2.new(x, y + 8)
hudElements.hpText.Visible = true
else
hudElements.hpBar.Visible = false
hudElements.hpText.Visible = false
end
-- Show last N discovered commands as event log
local cmdList = {}
for name, info in pairs(discoveredCommands) do
table.insert(cmdList, string.format("[%s] %s", info.remote, name))
end
table.sort(cmdList)
local display = table.concat(cmdList, "\n", 1, math.min(#cmdList, 10))
hudElements.eventText.Text = display ~= "" and ("CMDS:\n" .. display) or "No cmds detected yet"
hudElements.eventText.Position = Vector2.new(20, 30)
hudElements.eventText.Visible = true
end
-- === MAIN ===
if SHOW_COMMANDS then
pcall(hookRemotes)
print("[InfoHub] Remote spy active. Interact with game to discover commands.")
end
createHUD()
RunService.RenderStepped:Connect(function(dt)
updateHUD()
end)
print("[InfoHub] Loaded. HP + Command discovery active.")
