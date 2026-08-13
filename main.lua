-- ============================================================
-- W424HUB – MANUAL UI (NO LIBRARY, WORK IN MM2)
-- ============================================================
print("=== LOADING W424HUB MANUAL ===")

-- Tunggu game siap
task.wait(2)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- ============================================================
-- MANUAL UI FRAME
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "W424HUB_MANUAL"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 400)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(60, 60, 80)
mainStroke.Thickness = 1.5

-- Title Bar (draggable)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 28)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 10)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "W424HUB"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 16
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
closeBtn.BackgroundTransparency = 0.2
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 4)

local function makeDraggable()
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
end
makeDraggable()

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Scrollable content
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -10, 1, -35)
contentFrame.Position = UDim2.new(0, 5, 0, 32)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 4
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 4)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = contentFrame

-- ============================================================
-- UI HELPER FUNCTIONS
-- ============================================================
local function addLabel(parent, text, color, order)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(200, 200, 220)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order or 0
    label.Parent = parent
    return label
end

local function addDivider(parent, text, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 28)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order or 0
    frame.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "──────────"
    label.TextColor3 = Color3.fromRGB(100, 150, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.Parent = frame
    return frame
end

local function addToggle(parent, text, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 32)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order or 0
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 22)
    toggleBtn.Position = UDim2.new(1, -45, 0.5, -11)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(60, 200, 80) or Color3.fromRGB(60, 60, 80)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 10
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame
    local toggleCorner = Instance.new("UICorner", toggleBtn)
    toggleCorner.CornerRadius = UDim.new(0, 4)

    local state = default
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60, 200, 80) or Color3.fromRGB(60, 60, 80)
        toggleBtn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
    return { Set = function(v) state = v; toggleBtn.BackgroundColor3 = v and Color3.fromRGB(60,200,80) or Color3.fromRGB(60,60,80); toggleBtn.Text = v and "ON" or "OFF"; if callback then callback(v) end end }
end

local function addSlider(parent, text, min, max, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order or 0
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. " (" .. tostring(default) .. ")"
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 6)
    sliderFrame.Position = UDim2.new(0, 5, 0, 20)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = frame
    local sliderCorner = Instance.new("UICorner", sliderFrame)
    sliderCorner.CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 3)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.Parent = frame
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(0, 7)

    local value = default
    local dragging = false

    local function updateSlider(newValue)
        value = math.clamp(newValue, min, max)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -7, 0.5, -7)
        label.Text = text .. " (" .. tostring(math.floor(value * 10) / 10) .. ")"
        if callback then callback(value) end
    end

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local pos = (input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X
            updateSlider(min + pos * (max - min))
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = (input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X
            updateSlider(min + pos * (max - min))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return { Set = updateSlider, Get = function() return value end }
end

local function addDropdown(parent, text, options, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 32)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order or 0
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -5, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(0.45, -5, 0, 24)
    dropdownBtn.Position = UDim2.new(0.55, 0, 0.5, -12)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.Text = default or options[1] or ""
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownBtn.TextSize = 11
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.Parent = frame
    local dropdownCorner = Instance.new("UICorner", dropdownBtn)
    dropdownCorner.CornerRadius = UDim.new(0, 4)

    local selected = default or options[1]
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(0.45, -5, 0, 0)
    dropdownList.Position = UDim2.new(0.55, 0, 1, 2)
    dropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    dropdownList.BorderSizePixel = 0
    dropdownList.ClipsDescendants = true
    dropdownList.Visible = false
    dropdownList.Parent = frame
    local listCorner = Instance.new("UICorner", dropdownList)
    listCorner.CornerRadius = UDim.new(0, 4)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownList

    local function updateDropdown()
        for _, child in ipairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child.TextColor3 = (child.Text == selected) and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(200, 200, 220)
            end
        end
        dropdownBtn.Text = selected
        if callback then callback(selected) end
    end

    for _, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 24)
        optBtn.BackgroundTransparency = 0.5
        optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        optBtn.BorderSizePixel = 0
        optBtn.Text = option
        optBtn.TextColor3 = (option == selected) and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(200, 200, 220)
        optBtn.TextSize = 11
        optBtn.Font = Enum.Font.Gotham
        optBtn.Parent = dropdownList
        optBtn.MouseButton1Click:Connect(function()
            selected = option
            updateDropdown()
            dropdownList.Visible = false
            dropdownList.Size = UDim2.new(0.45, -5, 0, 0)
        end)
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        local isOpen = dropdownList.Visible
        if isOpen then
            dropdownList.Visible = false
            dropdownList.Size = UDim2.new(0.45, -5, 0, 0)
        else
            dropdownList.Visible = true
            local totalHeight = (#options * 26) + 4
            dropdownList.Size = UDim2.new(0.45, -5, 0, math.min(totalHeight, 120))
        end
    end)

    updateDropdown()
    return { Set = function(v) selected = v; updateDropdown() end }
end

local function addButton(parent, text, callback, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order or 0
    btn.Parent = parent
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

-- ============================================================
-- VARIABLES
-- ============================================================
local espEnabled = false
local lineEnabled = false
local aimbotEnabled = false
local aimTrigger = "On Shoot"
local aimTargetMode = "Murderer Only"
local aimFOV = 150
local aimMaxDist = 300
local aimSmooth = 0.5
local aimWall = true
local aimPrediction = false
local aimPredFactor = 0.2
local aimAutoShoot = false
local aimAutoDelay = 0.1
local aimTargetPart = "HumanoidRootPart"
local silentEnabled = false
local silentTargetMode = "Murderer Only"
local silentTargetPart = "Head"
local silentFOV = 180
local silentMaxDist = 300
local silentPrediction = true
local silentPredFactor = 0.15
local silentVis = true
local silentAutoShoot = false
local silentAutoDelay = 0.1
local lastSilentShot = 0
local hitboxEnabled = false
local hitboxSize = 15
local hitboxAlpha = 0.3
local hitboxTarget = "All"
local hitboxLoopRunning = false
local hitboxLoopStop = false
local originalSizes = {}
local reduceMap = false
local noRecoil = false
local noSpread = false
local antiRagdoll = false
local murdererThrow = false
local murdererThrowTarget = "All Players"
local murdererThrowDist = 300
local murdererThrowCD = 2
local murdererThrowPred = false
local murdererThrowPredFactor = 0.2
local murdererThrowWall = true
local murdererAutoEquip = false
local murdererMelee = false
local murdererMeleeRadius = 10
local lastThrowTime = 0

-- ============================================================
-- FUNGSI GET ROLE
-- ============================================================
local function getRole(player)
    if not player or not player.Character then return "Innocent" end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("knife") or name:find("murderer") or name:find("blade") then return "Murderer" end
                if name:find("gun") or name:find("revolver") or name:find("sheriff") or name:find("pistol") then return "Sheriff" end
            end
        end
    end
    local charTool = player.Character:FindFirstChildOfClass("Tool")
    if charTool then
        local name = charTool.Name:lower()
        if name:find("knife") or name:find("murderer") or name:find("blade") then return "Murderer" end
        if name:find("gun") or name:find("revolver") or name:find("sheriff") or name:find("pistol") then return "Sheriff" end
    end
    return "Innocent"
end

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
local function CharacterRayOrigin(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    return (hrp.CFrame * CFrame.new(0,0,hrp.Size.Z/2)).Position
end

local function hasClearLOS(fromPos, toPos, myChar, targetChar)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {myChar, targetChar}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(fromPos, (toPos - fromPos), params)
    if result then
        if not result.Instance:IsDescendantOf(targetChar) then return false end
    end
    return true
end

local function isShooting()
    return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or
           UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch)
end

local function getShootRemote()
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ShootGun")
    if not remote then remote = ReplicatedStorage:FindFirstChild("ShootGun") end
    return remote
end

-- ============================================================
-- ESP
-- ============================================================
local espData = {}
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Holder"
ESPFolder.Parent = CoreGui

local function updateESP(player)
    local data = espData[player]
    if not data or not espEnabled then
        if data then
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Billboard then data.Billboard.Enabled = false end
        end
        return
    end
    local role = getRole(player)
    local color = role == "Murderer" and Color3.new(1,0,0) or role == "Sheriff" and Color3.new(0,0,1) or Color3.new(0,1,0)
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
-- LINE ESP
-- ============================================================
local lineObjects = {}
local lineGui = Instance.new("ScreenGui")
lineGui.Name = "LineESP"
lineGui.Parent = CoreGui
lineGui.ResetOnSpawn = false
lineGui.IgnoreGuiInset = true

local function clearLines()
    for _, obj in pairs(lineObjects) do if obj then obj:Destroy() end end
    lineObjects = {}
end

RunService.Heartbeat:Connect(function()
    if not lineEnabled then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos, on = Camera:WorldToViewportPoint(myRoot.Position)
    if not on then return end
    for player, data in pairs(espData) do
        if player and player.Parent and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local targetPos, on2 = Camera:WorldToViewportPoint(root.Position)
                if on2 then
                    if not lineObjects[player] then
                        local line = Instance.new("Frame")
                        line.BackgroundColor3 = Color3.fromRGB(0,255,255)
                        line.BackgroundTransparency = 0.4
                        line.BorderSizePixel = 0
                        line.Parent = lineGui
                        lineObjects[player] = line
                    end
                    local line = lineObjects[player]
                    local dx = targetPos.X - myPos.X
                    local dy = targetPos.Y - myPos.Y
                    local length = math.sqrt(dx*dx + dy*dy)
                    local angle = math.atan2(dy, dx)
                    line.Position = UDim2.new(0, myPos.X, 0, myPos.Y)
                    line.Size = UDim2.new(0, length, 0, 1.5)
                    line.Rotation = math.deg(angle)
                    line.BackgroundColor3 = Color3.fromRGB(0,255,255)
                    line.Visible = true
                else
                    if lineObjects[player] then lineObjects[player].Visible = false end
                end
            end
        end
    end
end)

-- ============================================================
-- FOV CIRCLE
-- ============================================================
local fovVisible = false
local fovRadius = 150
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "FOVCircleGUI"
fovGui.Parent = CoreGui
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
local fovCircle = Instance.new("Frame")
fovCircle.BackgroundTransparency = 1
fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
fovCircle.Position = UDim2.new(0.5,0,0.5,0)
fovCircle.Size = UDim2.new(0,300,0,300)
fovCircle.Visible = false
fovCircle.Parent = fovGui
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(255,255,255)
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.5
local fovCorner = Instance.new("UICorner", fovCircle)
fovCorner.CornerRadius = UDim.new(1,0)

-- ============================================================
-- FUNGSI GET TARGET
-- ============================================================
local function getAimbotTargets()
    local targets = {}
    local myChar = LocalPlayer.Character
    if not myChar then return targets end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return targets end
    local myPos = myRoot.Position
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local role = getRole(player)
        if aimTargetMode == "Murderer Only" and role ~= "Murderer" then continue end
        local part = char:FindFirstChild(aimTargetPart) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if not part then continue end
        local targetPos = part.Position
        if aimPrediction then
            local vel = part.Velocity or Vector3.new()
            targetPos = targetPos + (vel * aimPredFactor)
        end
        local dist = (targetPos - myPos).Magnitude
        if dist > aimMaxDist then continue end
        if aimWall and not hasClearLOS(myPos, targetPos, myChar, char) then continue end
        table.insert(targets, { Player = player, Part = part, Position = targetPos, Distance = dist })
    end
    table.sort(targets, function(a,b) return a.Distance < b.Distance end)
    return targets
end

-- ============================================================
-- SILENT AIM TARGET
-- ============================================================
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function IsVisibleSilent(targetPart)
    if not silentVis then return true end
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local rootPart = myChar:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    rayParams.FilterDescendantsInstances = {myChar}
    local result = Workspace:Raycast(rootPart.Position, targetPart.Position - rootPart.Position, rayParams)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

local function GetClosestSilentTarget()
    local center = Camera.ViewportSize / 2
    local closest = nil
    local closestDist = silentFOV
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local role = getRole(player)
        if silentTargetMode == "Murderer Only" and role ~= "Murderer" then continue end
        local part = char:FindFirstChild(silentTargetPart) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if not part then continue end
        local targetPos = part.Position
        if silentPrediction then
            local vel = part.Velocity or Vector3.new()
            targetPos = targetPos + (vel * silentPredFactor)
        end
        local dist = (targetPos - myPos).Magnitude
        if dist > silentMaxDist then continue end
        if not IsVisibleSilent(part) then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
        if onScreen then
            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if screenDist < closestDist then
                closestDist = screenDist
                closest = part
            end
        end
    end
    return closest
end

-- ============================================================
-- HITBOX EXPANSION
-- ============================================================
local function getHitboxParts(character)
    local parts = {}
    if not character then return parts end
    local target = hitboxTarget
    if target == "All" or target == "Head" then
        local head = character:FindFirstChild("Head")
        if head then table.insert(parts, head) end
        local headHB = character:FindFirstChild("HeadHB")
        if headHB then table.insert(parts, headHB) end
    end
    if target == "All" or target == "Torso" then
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if torso then table.insert(parts, torso) end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then table.insert(parts, hrp) end
    end
    if target == "All" or target == "Legs" then
        for _, name in pairs({"RightUpperLeg","LeftUpperLeg","RightLowerLeg","LeftLowerLeg"}) do
            local leg = character:FindFirstChild(name)
            if leg then table.insert(parts, leg) end
        end
    end
    return parts
end

local function saveOriginalSize(part)
    if not part then return end
    local key = tostring(part)
    if not originalSizes[key] then
        originalSizes[key] = { Size = part.Size, Transparency = part.Transparency, CanCollide = part.CanCollide }
    end
end

local function restoreOriginalSize(part)
    if not part then return end
    local key = tostring(part)
    local original = originalSizes[key]
    if original then
        pcall(function()
            part.Size = original.Size
            part.Transparency = original.Transparency
            part.CanCollide = original.CanCollide
        end)
        originalSizes[key] = nil
    end
end

local function hitboxLoop()
    while hitboxLoopRunning and not hitboxLoopStop do
        if hitboxEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local parts = getHitboxParts(player.Character)
                    for _, part in ipairs(parts) do
                        pcall(function()
                            saveOriginalSize(part)
                            part.Transparency = hitboxAlpha
                            part.CanCollide = false
                            part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                        end)
                    end
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local parts = getHitboxParts(player.Character)
                    for _, part in ipairs(parts) do
                        pcall(function() restoreOriginalSize(part) end)
                    end
                end
            end
        end
        task.wait(0.3)
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local parts = getHitboxParts(player.Character)
            for _, part in ipairs(parts) do
                pcall(function() restoreOriginalSize(part) end)
            end
        end
    end
end

local function startHitboxLoop()
    if hitboxLoopRunning then return end
    hitboxLoopRunning = true
    hitboxLoopStop = false
    task.spawn(hitboxLoop)
end

local function stopHitboxLoop()
    hitboxLoopStop = true
    task.wait(0.4)
    hitboxLoopRunning = false
end

-- ============================================================
-- MURDERER TOOLS
-- ============================================================
local function equipKnife()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return false end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("blade")) then
            hum:EquipTool(tool)
            return true
        end
    end
    return false
end

local function throwKnifeAt(targetChar, targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or not (tool.Name:lower():find("knife") or tool.Name:lower():find("blade")) then return end
    local rightHandle = tool:FindFirstChild("RightHandle")
    if not rightHandle then return end
    local origin = CharacterRayOrigin(char)
    if not origin then return end
    local direction = (targetPos - origin).Unit
    local throwRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ThrowStart")
    if throwRemote then throwRemote:FireServer(origin, direction)
    else
        local remote = ReplicatedStorage:FindFirstChild("ThrowStart")
        if remote then remote:FireServer(origin, direction) end
    end
    local knifeModule = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("KnifeProjectileController")
    if knifeModule then
        pcall(function()
            require(knifeModule)({
                Speed = tool:GetAttribute("ThrowSpeed") or 50,
                KnifeProjectile = rightHandle:Clone(),
                Direction = direction,
                Origin = origin
            }, function(raycastResult)
                local hitRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ThrowHit")
                if hitRemote then hitRemote:FireServer(raycastResult and raycastResult.Instance, raycastResult and raycastResult.Position)
                else
                    local remote = ReplicatedStorage:FindFirstChild("ThrowHit")
                    if remote then remote:FireServer(raycastResult and raycastResult.Instance, raycastResult and raycastResult.Position) end
                end
            end)
        end)
    else
        local hitRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ThrowHit")
        if hitRemote then hitRemote:FireServer(nil, targetPos)
        else
            local remote = ReplicatedStorage:FindFirstChild("ThrowHit")
            if remote then remote:FireServer(nil, targetPos) end
        end
    end
    lastThrowTime = tick()
end

local function doMeleeAttack()
    local char = LocalPlayer.Character
    if not char then return end
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Melee")
    if remote then remote:FireServer()
    else
        local general = ReplicatedStorage:FindFirstChild("Melee") or ReplicatedStorage:FindFirstChild("Attack")
        if general then general:FireServer() end
    end
end

task.spawn(function()
    while true do
        local char = LocalPlayer.Character
        if not char then task.wait(0.5) continue end
        if getRole(LocalPlayer) ~= "Murderer" then task.wait(0.5) continue end

        if murdererAutoEquip then
            local hasKnife = false
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("blade")) then
                    hasKnife = true; break
                end
            end
            if not hasKnife then equipKnife(); task.wait(0.2) end
        end

        if murdererMelee then
            local myRoot = char:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local myPos = myRoot.Position
                local closest = nil
                local closestDist = murdererMeleeRadius
                for _, player in ipairs(Players:GetPlayers()) do
                    if player == LocalPlayer then continue end
                    local role = getRole(player)
                    if murdererThrowTarget == "Sheriff Only" and role ~= "Sheriff" then continue end
                    if murdererThrowTarget == "Innocent Only" and role ~= "Innocent" then continue end
                    local pChar = player.Character
                    if not pChar then continue end
                    local hum = pChar:FindFirstChildOfClass("Humanoid")
                    if not hum or hum.Health <= 0 then continue end
                    local targetRoot = pChar:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then continue end
                    local dist = (targetRoot.Position - myPos).Magnitude
                    if dist < closestDist and hasClearLOS(myPos, targetRoot.Position, char, pChar) then
                        closestDist = dist; closest = pChar
                    end
                end
                if closest then
                    doMeleeAttack()
                    task.wait(0.3)
                end
            end
        end

        if murdererThrow and (tick() - lastThrowTime) >= murdererThrowCD then
            local targets = {}
            local myRoot = char:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local myPos = myRoot.Position
                for _, player in ipairs(Players:GetPlayers()) do
                    if player == LocalPlayer then continue end
                    local role = getRole(player)
                    if murdererThrowTarget == "Sheriff Only" and role ~= "Sheriff" then continue end
                    if murdererThrowTarget == "Innocent Only" and role ~= "Innocent" then continue end
                    local pChar = player.Character
                    if not pChar then continue end
                    local hum = pChar:FindFirstChildOfClass("Humanoid")
                    if not hum or hum.Health <= 0 then continue end
                    local part = pChar:FindFirstChild("HumanoidRootPart") or pChar:FindFirstChild("Head")
                    if not part then continue end
                    local targetPos = part.Position
                    if murdererThrowPred then
                        local vel = part.Velocity or Vector3.new()
                        targetPos = targetPos + (vel * murdererThrowPredFactor)
                    end
                    local dist = (targetPos - myPos).Magnitude
                    if dist > murdererThrowDist then continue end
                    if murdererThrowWall and not hasClearLOS(myPos, targetPos, char, pChar) then continue end
                    table.insert(targets, { Character = pChar, Position = targetPos, Distance = dist })
                end
                table.sort(targets, function(a,b) return a.Distance < b.Distance end)
                if #targets > 0 then
                    local target = targets[1]
                    throwKnifeAt(target.Character, target.Position)
                end
            end
        end
        task.wait(0.1)
    end
end)

-- ============================================================
-- BUILD UI
-- ============================================================
addDivider(contentFrame, "─── ESP ───", 0)
local espToggle = addToggle(contentFrame, "ESP", false, function(v) espEnabled = v; refreshESP() end, 1)
addToggle(contentFrame, "Line ESP", false, function(v) lineEnabled = v; if not v then clearLines() end end, 2)

addDivider(contentFrame, "─── FOV ───", 3)
addToggle(contentFrame, "Show FOV", false, function(v) fovVisible = v; fovCircle.Visible = v end, 4)
addSlider(contentFrame, "FOV Radius", 30, 400, 150, function(v) fovRadius = v; fovCircle.Size = UDim2.new(0, v*2, 0, v*2) end, 5)

addDivider(contentFrame, "─── AIMBOT ───", 6)
addToggle(contentFrame, "Aimbot (Camera)", false, function(v) aimbotEnabled = v end, 7)
addDropdown(contentFrame, "Trigger", {"On Shoot", "Always"}, "On Shoot", function(v) aimTrigger = v end, 8)
addDropdown(contentFrame, "Target", {"Murderer Only", "All Players"}, "Murderer Only", function(v) aimTargetMode = v end, 9)
addSlider(contentFrame, "FOV", 30, 400, 150, function(v) aimFOV = v end, 10)
addSlider(contentFrame, "Max Distance", 50, 500, 300, function(v) aimMaxDist = v end, 11)
addSlider(contentFrame, "Smoothness", 1, 10, 5, function(v) aimSmooth = v/10 end, 12)
addToggle(contentFrame, "Wall Check", true, function(v) aimWall = v end, 13)
addToggle(contentFrame, "Prediction", false, function(v) aimPrediction = v end, 14)
addSlider(contentFrame, "Pred Factor", 0, 100, 20, function(v) aimPredFactor = v/100 end, 15)
addToggle(contentFrame, "Auto Shoot", false, function(v) aimAutoShoot = v end, 16)
addSlider(contentFrame, "Auto Delay", 5, 50, 10, function(v) aimAutoDelay = v/100 end, 17)
addDropdown(contentFrame, "Target Part", {"Head", "HumanoidRootPart", "Torso"}, "HumanoidRootPart", function(v) aimTargetPart = v end, 18)

addDivider(contentFrame, "─── SILENT AIM ───", 19)
local silentToggle = addToggle(contentFrame, "Silent Aim", false, function(v) silentEnabled = v; if v then setupSilentAim() end end, 20)
addDropdown(contentFrame, "Silent Target", {"Murderer Only", "All Players"}, "Murderer Only", function(v) silentTargetMode = v end, 21)
addDropdown(contentFrame, "Silent Part", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(v) silentTargetPart = v end, 22)
addSlider(contentFrame, "Silent FOV", 30, 400, 180, function(v) silentFOV = v end, 23)
addSlider(contentFrame, "Silent Max Dist", 50, 500, 300, function(v) silentMaxDist = v end, 24)
addToggle(contentFrame, "Silent Prediction", true, function(v) silentPrediction = v end, 25)
addSlider(contentFrame, "Silent Pred Factor", 0, 100, 15, function(v) silentPredFactor = v/100 end, 26)
addToggle(contentFrame, "Silent Vis Check", true, function(v) silentVis = v end, 27)
addToggle(contentFrame, "Silent Auto Shoot", false, function(v) silentAutoShoot = v end, 28)
addSlider(contentFrame, "Silent Auto Delay", 5, 50, 10, function(v) silentAutoDelay = v/100 end, 29)

addDivider(contentFrame, "─── HITBOX ───", 30)
addToggle(contentFrame, "Hitbox Expansion", false, function(v) hitboxEnabled = v; if v then startHitboxLoop() else stopHitboxLoop() end end, 31)
addDropdown(contentFrame, "Target Parts", {"All", "Head", "Torso", "Legs"}, "All", function(v) hitboxTarget = v; if hitboxEnabled then stopHitboxLoop(); task.wait(0.2); startHitboxLoop() end end, 32)
addSlider(contentFrame, "Hitbox Size", 1, 30, 15, function(v) hitboxSize = v end, 33)
addSlider(contentFrame, "Hitbox Alpha", 0, 10, 3, function(v) hitboxAlpha = v/10 end, 34)
addButton(contentFrame, "Reset Hitbox", function()
    stopHitboxLoop()
    hitboxEnabled = false
    task.wait(0.3)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local parts = getHitboxParts(player.Character)
            for _, part in ipairs(parts) do
                pcall(function() restoreOriginalSize(part) end)
            end
        end
    end
end, 35)

addDivider(contentFrame, "─── MURDERER ───", 36)
addToggle(contentFrame, "Auto Throw Knife", false, function(v) murdererThrow = v end, 37)
addDropdown(contentFrame, "Throw Target", {"All Players", "Sheriff Only", "Innocent Only"}, "All Players", function(v) murdererThrowTarget = v end, 38)
addSlider(contentFrame, "Throw Max Dist", 50, 500, 300, function(v) murdererThrowDist = v end, 39)
addSlider(contentFrame, "Throw Cooldown", 5, 100, 20, function(v) murdererThrowCD = v/10 end, 40)
addToggle(contentFrame, "Throw Prediction", false, function(v) murdererThrowPred = v end, 41)
addSlider(contentFrame, "Throw Pred Factor", 0, 100, 20, function(v) murdererThrowPredFactor = v/100 end, 42)
addToggle(contentFrame, "Throw Wall Check", true, function(v) murdererThrowWall = v end, 43)
addToggle(contentFrame, "Auto Equip Knife", false, function(v) murdererAutoEquip = v end, 44)
addToggle(contentFrame, "Auto Melee", false, function(v) murdererMelee = v end, 45)
addSlider(contentFrame, "Melee Radius", 3, 30, 10, function(v) murdererMeleeRadius = v end, 46)

addDivider(contentFrame, "─── PLAYER MODS ───", 47)
addToggle(contentFrame, "No Recoil", false, function(v) noRecoil = v end, 48)
addToggle(contentFrame, "No Spread", false, function(v) noSpread = v end, 49)
addToggle(contentFrame, "Anti Ragdoll", false, function(v) antiRagdoll = v end, 50)

addDivider(contentFrame, "─── OPTIMIZATION ───", 51)
addToggle(contentFrame, "Reduce Map", false, function(v)
    reduceMap = v
    pcall(function()
        if v then
            StarterGui:SetCore("MinimapEnabled", false)
            for _, gui in ipairs(CoreGui:GetChildren()) do
                if gui.Name and gui.Name:lower():find("minimap") then gui.Enabled = false end
            end
            for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                if gui.Name and gui.Name:lower():find("minimap") then gui.Enabled = false end
            end
        else
            StarterGui:SetCore("MinimapEnabled", true)
            for _, gui in ipairs(CoreGui:GetChildren()) do
                if gui.Name and gui.Name:lower():find("minimap") then gui.Enabled = true end
            end
            for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                if gui.Name and gui.Name:lower():find("minimap") then gui.Enabled = true end
            end
        end
    end)
end, 52)

-- ============================================================
-- PLAYER MODS LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return
    if antiRagdoll then
        if hum.PlatformStand or hum.Sit then
            hum.PlatformStand = false; hum.Sit = false
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Velocity = Vector3.new(); hrp.RotVelocity = Vector3.new() end
        end
        if hum.SeatPart then hum.Sit = false end
    end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        if noRecoil then
            for _, prop in ipairs({"Recoil","recoil","Kickback","GunRecoil","Shake","CameraRecoil"}) do
                local success, val = pcall(function() return tool[prop] end)
                if success and val ~= nil and type(val) == "number" then tool[prop] = 0; break end
            end
            if tool:FindFirstChild("Recoil") and tool.Recoil:IsA("NumberValue") then tool.Recoil.Value = 0 end
        end
        if noSpread then
            for _, prop in ipairs({"Spread","spread","Accuracy","Inaccuracy","BulletSpread","Deviation"}) do
                local success, val = pcall(function() return tool[prop] end)
                if success and val ~= nil and type(val) == "number" then tool[prop] = 0; break end
            end
            if tool:FindFirstChild("Spread") and tool.Spread:IsA("NumberValue") then tool.Spread.Value = 0 end
            if tool:FindFirstChild("Inaccuracy") and tool.Inaccuracy:IsA("NumberValue") then tool.Inaccuracy.Value = 0 end
        end
    end
end)

-- ============================================================
-- AIMBOT LOOP
-- ============================================================
local function getAimbotTargets()
    local targets = {}
    local myChar = LocalPlayer.Character
    if not myChar then return targets end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return targets end
    local myPos = myRoot.Position
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local role = getRole(player)
        if aimTargetMode == "Murderer Only" and role ~= "Murderer" then continue end
        local part = char:FindFirstChild(aimTargetPart) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if not part then continue end
        local targetPos = part.Position
        if aimPrediction then
            local vel = part.Velocity or Vector3.new()
            targetPos = targetPos + (vel * aimPredFactor)
        end
        local dist = (targetPos - myPos).Magnitude
        if dist > aimMaxDist then continue end
        if aimWall and not hasClearLOS(myPos, targetPos, myChar, char) then continue end
        table.insert(targets, { Player = player, Part = part, Position = targetPos, Distance = dist })
    end
    table.sort(targets, function(a,b) return a.Distance < b.Distance end)
    return targets
end

RunService.RenderStepped:Connect(function(dt)
    if not aimbotEnabled then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local hasGun = false
    for _, tool in ipairs(myChar:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("gun") or tool.Name:lower():find("revolver") or tool.Name:lower():find("pistol") or tool.Name:lower():find("sheriff")) then
            hasGun = true; break
        end
    end
    if not hasGun then return end
    local canAim = (aimTrigger == "Always") or (aimTrigger == "On Shoot" and isShooting())
    if not canAim then return end
    local targets = getAimbotTargets()
    if #targets == 0 then return end
    local target = targets[1]
    local targetPos = target.Position
    local currentCF = Camera.CFrame
    local targetCF = CFrame.new(currentCF.Position, targetPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if onScreen then
        local center = Camera.ViewportSize / 2
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist > aimFOV then return end
    else return end
    if aimSmooth < 1 then
        local lerpFactor = 1 - math.exp(-aimSmooth * dt * 5)
        Camera.CFrame = currentCF:Lerp(targetCF, lerpFactor)
    else
        Camera.CFrame = targetCF
    end
    if aimAutoShoot then
        local center = Camera.ViewportSize / 2
        local pos, on = Camera:WorldToViewportPoint(target.Position)
        if on and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 15 then
            pcall(function()
                local origin = CharacterRayOrigin(myChar)
                if origin and target.Part then
                    local hitPart = target.Part
                    local targetPos2 = hitPart.Position
                    local remote = getShootRemote()
                    if remote then remote:FireServer(origin, targetPos2, hitPart, targetPos2) end
                    local tool = myChar:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Fire") then tool.Fire:Play() end
                    task.wait(aimAutoDelay)
                end
            end)
        end
    end
end)

-- ============================================================
-- SILENT AIM (OVERRIDE REMOTE)
-- ============================================================
local shootRemote = nil
local originalFire = nil

local function setupSilentAim()
    shootRemote = getShootRemote()
    if not shootRemote then return end
    if originalFire then return end
    originalFire = shootRemote.FireServer
    shootRemote.FireServer = function(self, ...)
        if silentEnabled then
            local args = {...}
            local myChar = LocalPlayer.Character
            if myChar then
                local hasGun = false
                for _, tool in ipairs(myChar:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("gun") or tool.Name:lower():find("revolver") or tool.Name:lower():find("pistol") or tool.Name:lower():find("sheriff")) then
                        hasGun = true
                        break
                    end
                end
                if hasGun and #args >= 4 then
                    local targetPart = GetClosestSilentTarget()
                    if targetPart then
                        local origin = args[1]
                        if origin and typeof(origin) == "Vector3" then
                            local newTargetPos = targetPart.Position
                            args[2] = newTargetPos
                            args[3] = targetPart
                            args[4] = newTargetPos
                            return originalFire(self, unpack(args))
                        end
                    end
                end
            end
        end
        return originalFire(self, ...)
    end
end

RunService.RenderStepped:Connect(function()
    if not silentEnabled or not silentAutoShoot then return end
    local now = tick()
    if now - lastSilentShot < silentAutoDelay then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local hasGun = false
    for _, tool in ipairs(myChar:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("gun") or tool.Name:lower():find("revolver") or tool.Name:lower():find("pistol") or tool.Name:lower():find("sheriff")) then
            hasGun = true
            break
        end
    end
    if not hasGun then return end
    local targetPart = GetClosestSilentTarget()
    if not targetPart then return end
    local center = Camera.ViewportSize / 2
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if onScreen then
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist > silentFOV then return end
    else return end
    local remote = getShootRemote()
    if remote then
        local origin = Camera.CFrame.Position
        local targetPos = targetPart.Position
        pcall(function()
            remote:FireServer(origin, targetPos, targetPart, targetPos)
            local tool = myChar:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Fire") then tool.Fire:Play() end
            lastSilentShot = tick()
        end)
    end
end)

-- ============================================================
-- FINISH
-- ============================================================
print("✅ W424HUB MANUAL loaded – No external library!")