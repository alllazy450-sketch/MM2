-- ============================================================
-- W424HUB – MINIMAL (AIMBOT + ESP + FPS COUNTER)
-- ============================================================
print("=== LOADING W424HUB MINIMAL ===")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local StarterGui = game:GetService("StarterGui")

-- ============================================================
-- 1. AIMBOT (WEAPONSERVICE HOOK) – DARI SOURCE KAMU
-- ============================================================
pcall(function()
    local players = Players
    local lp = LocalPlayer
    local camera = Camera
    local uis = UserInputService
    local WeaponService = require(game:GetService("ReplicatedStorage").ClientServices.WeaponService)

    local function hasTool(player, name)
        for _, loc in ipairs({player.Character, player.Backpack}) do
            if loc then
                for _, item in ipairs(loc:GetChildren()) do
                    if item.Name == name and item:IsA("Tool") then
                        return true
                    end
                end
            end
        end
        return false
    end

    local function getLocalTool()
        for _, loc in ipairs({lp.Character, lp.Backpack}) do
            if loc then
                for _, item in ipairs(loc:GetChildren()) do
                    if item:IsA("Tool") and (item.Name == "Gun" or item.Name == "Knife") then
                        return item.Name
                    end
                end
            end
        end
        return nil
    end

    local function isValidTarget(player, localTool)
        if localTool == "Gun" then
            return hasTool(player, "Knife")
        elseif localTool == "Knife" then
            return hasTool(player, "Gun") or not hasTool(player, "Knife")
        end
        return false
    end

    local function getTarget()
        local localTool = getLocalTool()
        if not localTool then return nil end
        local mousePos = uis:GetMouseLocation()
        local closest, dist = nil, math.huge
        for _, p in ipairs(players:GetPlayers()) do
            if p ~= lp and p.Character and isValidTarget(p, localTool) then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChild("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local d = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if d < dist then
                            dist = d
                            closest = hrp
                        end
                    end
                end
            end
        end
        return closest
    end

    local oldGet = WeaponService.GetMouseTargetCFrame
    WeaponService.GetMouseTargetCFrame = function(self)
        local hrp = getTarget()
        if hrp then
            return CFrame.new(hrp.Position + Vector3.new(0, 0.5, 0))
        end
        return oldGet(self)
    end

    print("✅ Aimbot (WeaponService) AKTIF!")
end)

-- ============================================================
-- 2. ESP SEDERHANA (HIGHLIGHT + BILLBOARD)
-- ============================================================
local espEnabled = false
local espData = {}
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Holder"
ESPFolder.Parent = CoreGui

-- Fungsi hasTool sudah didefinisikan di aimbot, kita gunakan ulang
-- Tapi karena di dalam pcall, kita definisikan ulang di sini untuk ESP
local function hasTool(player, name)
    for _, loc in ipairs({player.Character, player.Backpack}) do
        if loc then
            for _, item in ipairs(loc:GetChildren()) do
                if item.Name == name and item:IsA("Tool") then
                    return true
                end
            end
        end
    end
    return false
end

local function getRole(player)
    if hasTool(player, "Knife") then return "Murderer" end
    if hasTool(player, "Gun") then return "Sheriff" end
    return "Innocent"
end

local function updateESP(player)
    local data = espData[player]
    if not data or not espEnabled then
        if data and data.Highlight then data.Highlight.Enabled = false end
        if data and data.Billboard then data.Billboard.Enabled = false end
        return
    end
    local role = getRole(player)
    local color = role == "Murderer" and Color3.new(1,0,0) or
                  role == "Sheriff" and Color3.new(0,0,1) or
                  Color3.new(0,1,0)
    data.Highlight.FillColor = color
    data.Highlight.OutlineColor = color
    data.Highlight.Enabled = true
    data.Billboard.Enabled = true
end

local function refreshESP()
    for player, _ in pairs(espData) do
        if player and player.Parent then updateESP(player) end
    end
end

local function createESP(player)
    if player == LocalPlayer then return end
    if espData[player] then
        if espData[player].Highlight then espData[player].Highlight:Destroy() end
        if espData[player].Billboard then espData[player].Billboard:Destroy() end
        espData[player] = nil
    end
    local char = player.Character
    if not char then return end

    local highlight = Instance.new("Highlight")
    highlight.Parent = char
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0.2
    highlight.Enabled = false

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.ExtentsOffset = Vector3.new(0, 2.5, 0)
    billboard.Enabled = false
    local head = char:FindFirstChild("Head")
    billboard.Parent = head or char
    if head then billboard.Adornee = head end

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.new(1,1,1)
    distLabel.TextStrokeTransparency = 0
    distLabel.TextStrokeColor3 = Color3.new(0,0,0)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.Parent = billboard

    espData[player] = { Highlight = highlight, Billboard = billboard }
    updateESP(player)
end

local function setupPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then createESP(player) end
    player.CharacterAdded:Connect(function() createESP(player) end)
end

for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(p)
    local data = espData[p]
    if data then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        espData[p] = nil
    end
end)

-- Update jarak
RunService.Heartbeat:Connect(function()
    local myChar = LocalPlayer.Character
    local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position
    for player, data in pairs(espData) do
        if player and player.Parent and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head and myPos and data.Billboard then
                local dist = (head.Position - myPos).Magnitude
                local distLabel = data.Billboard:FindFirstChildWhichIsA("TextLabel")
                if distLabel and distLabel.Text:match("m$") then
                    distLabel.Text = string.format("%.0fm", dist)
                end
            end
        end
    end
end)

-- ============================================================
-- 3. UI MANUAL (TOGGLE ESP + FPS COUNTER)
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "W424HUB_UI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

-- Frame utama
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 120)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(60, 60, 80)
stroke.Thickness = 1.5

-- Title (draggable)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 24)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "W424HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -24, 0, 2)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ESP Toggle button
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0, 80, 0, 26)
espBtn.Position = UDim2.new(0, 10, 0, 35)
espBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
espBtn.BorderSizePixel = 0
espBtn.Text = "ESP: OFF"
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.TextSize = 12
espBtn.Font = Enum.Font.GothamBold
espBtn.Parent = mainFrame
local btnCorner = Instance.new("UICorner", espBtn)
btnCorner.CornerRadius = UDim.new(0, 4)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(60, 200, 80) or Color3.fromRGB(50, 50, 80)
    refreshESP()
end)

-- FPS & Ping label
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -10, 0, 20)
statsLabel.Position = UDim2.new(0, 5, 0, 70)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "FPS: 0  Ping: 0ms"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
statsLabel.TextSize = 12
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Center
statsLabel.Parent = mainFrame

-- FPS counter loop
local frameCount = 0
local lastUpdate = tick()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastUpdate >= 1 then
        local ping = 0
        pcall(function() ping = LocalPlayer:GetNetworkPing() * 1000 end)
        statsLabel.Text = string.format("FPS: %d  Ping: %.0fms", frameCount, ping)
        frameCount = 0
        lastUpdate = now
    end
end)

-- Draggable functionality
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
    end
end)

-- ============================================================
-- NOTIFIKASI
-- ============================================================
StarterGui:SetCore("SendNotification", {
    Title = "W424HUB",
    Text = "Aimbot aktif! | ESP toggle di UI",
    Duration = 4
})

print("✅ W424HUB MINIMAL loaded – Aimbot + ESP + FPS counter!")