-- ============================================
-- W424HUB – TARGET PANEL (FIXED)
-- ============================================
print("=== LOADING W424HUB TARGET PANEL ===")

local Kairo = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzzavi335/Kairo-Ui-Library/refs/heads/main/source.luau"))()
if not Kairo then
    warn("❌ Kairo failed to load!")
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- ============================================
-- WINDOW KAIRO (TANPA ICON DI TAB)
-- ============================================
local Window = Kairo:CreateWindow({
    Title = "W424HUB",
    Theme = "Ocean",
    Size = UDim2.fromOffset(500, 450),
    Center = true,
    Draggable = true,
    Resize = false,
    Badges = {"v3.0"},
    MinimizeKey = Enum.KeyCode.RightShift,
    MinimizeButton = true,
    Config = { Enabled = true, Folder = "W424HUB_Config", AutoLoad = true }
})

if not Window then return end

Window:Notify({
    Title = "W424HUB",
    Description = "Loaded successfully!",
    Content = "Target Panel + ESP + Aimbot",
    Color = Color3.fromRGB(0, 200, 50),
    Delay = 3
})

-- ============================================
-- TARGET PANEL (POJOK KANAN ATAS)
-- ============================================
local targetPanel = Instance.new("ScreenGui")
targetPanel.Name = "TargetPanel"
targetPanel.Parent = CoreGui
targetPanel.ResetOnSpawn = false
targetPanel.IgnoreGuiInset = true

local panelFrame = Instance.new("Frame")
panelFrame.Size = UDim2.new(0, 130, 0, 110)
panelFrame.Position = UDim2.new(1, -145, 0, 10)
panelFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
panelFrame.BackgroundTransparency = 0.15
panelFrame.BorderSizePixel = 0
panelFrame.Visible = true
panelFrame.Parent = targetPanel
local panelCorner = Instance.new("UICorner", panelFrame)
panelCorner.CornerRadius = UDim.new(0, 8)
local panelStroke = Instance.new("UIStroke", panelFrame)
panelStroke.Color = Color3.fromRGB(60, 60, 80)
panelStroke.Thickness = 1

local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, 0, 0, 22)
panelTitle.Position = UDim2.new(0, 0, 0, 2)
panelTitle.BackgroundTransparency = 1
panelTitle.Text = "🎯 TARGET"
panelTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
panelTitle.TextSize = 13
panelTitle.Font = Enum.Font.GothamBold
panelTitle.Parent = panelFrame

getgenv().TargetList = {
    Murderer = false,
    Sheriff = false,
    Innocent = false
}

local function updateTargetDisplay()
    local status = ""
    if getgenv().TargetList.Murderer then status = status .. "M " end
    if getgenv().TargetList.Sheriff then status = status .. "S " end
    if getgenv().TargetList.Innocent then status = status .. "I " end
    if status == "" then status = "None" end
    panelStatus.Text = status
end

-- Tombol M (Murderer)
local btnM = Instance.new("TextButton")
btnM.Size = UDim2.new(0.3, -4, 0, 22)
btnM.Position = UDim2.new(0.02, 0, 0.3, 0)
btnM.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
btnM.BackgroundTransparency = 0.3
btnM.BorderSizePixel = 0
btnM.Text = "M"
btnM.TextColor3 = Color3.fromRGB(255, 100, 100)
btnM.TextSize = 14
btnM.Font = Enum.Font.GothamBold
btnM.Parent = panelFrame
local btnMCorner = Instance.new("UICorner", btnM)
btnMCorner.CornerRadius = UDim.new(0, 4)
btnM.MouseButton1Click:Connect(function()
    getgenv().TargetList.Murderer = not getgenv().TargetList.Murderer
    if getgenv().TargetList.Murderer then
        btnM.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
        btnM.BackgroundTransparency = 0.2
    else
        btnM.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
        btnM.BackgroundTransparency = 0.3
    end
    updateTargetDisplay()
end)

-- Tombol S (Sheriff)
local btnS = Instance.new("TextButton")
btnS.Size = UDim2.new(0.3, -4, 0, 22)
btnS.Position = UDim2.new(0.35, 0, 0.3, 0)
btnS.BackgroundColor3 = Color3.fromRGB(10, 10, 40)
btnS.BackgroundTransparency = 0.3
btnS.BorderSizePixel = 0
btnS.Text = "S"
btnS.TextColor3 = Color3.fromRGB(100, 100, 255)
btnS.TextSize = 14
btnS.Font = Enum.Font.GothamBold
btnS.Parent = panelFrame
local btnSCorner = Instance.new("UICorner", btnS)
btnSCorner.CornerRadius = UDim.new(0, 4)
btnS.MouseButton1Click:Connect(function()
    getgenv().TargetList.Sheriff = not getgenv().TargetList.Sheriff
    if getgenv().TargetList.Sheriff then
        btnS.BackgroundColor3 = Color3.fromRGB(30, 30, 180)
        btnS.BackgroundTransparency = 0.2
    else
        btnS.BackgroundColor3 = Color3.fromRGB(10, 10, 40)
        btnS.BackgroundTransparency = 0.3
    end
    updateTargetDisplay()
end)

-- Tombol I (Innocent)
local btnI = Instance.new("TextButton")
btnI.Size = UDim2.new(0.3, -4, 0, 22)
btnI.Position = UDim2.new(0.68, 0, 0.3, 0)
btnI.BackgroundColor3 = Color3.fromRGB(10, 40, 10)
btnI.BackgroundTransparency = 0.3
btnI.BorderSizePixel = 0
btnI.Text = "I"
btnI.TextColor3 = Color3.fromRGB(100, 255, 100)
btnI.TextSize = 14
btnI.Font = Enum.Font.GothamBold
btnI.Parent = panelFrame
local btnICorner = Instance.new("UICorner", btnI)
btnICorner.CornerRadius = UDim.new(0, 4)
btnI.MouseButton1Click:Connect(function()
    getgenv().TargetList.Innocent = not getgenv().TargetList.Innocent
    if getgenv().TargetList.Innocent then
        btnI.BackgroundColor3 = Color3.fromRGB(30, 180, 30)
        btnI.BackgroundTransparency = 0.2
    else
        btnI.BackgroundColor3 = Color3.fromRGB(10, 40, 10)
        btnI.BackgroundTransparency = 0.3
    end
    updateTargetDisplay()
end)

-- Status target
local panelStatus = Instance.new("TextLabel")
panelStatus.Size = UDim2.new(1, -10, 0, 20)
panelStatus.Position = UDim2.new(0, 5, 0.7, 0)
panelStatus.BackgroundTransparency = 1
panelStatus.Text = "None"
panelStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
panelStatus.TextSize = 12
panelStatus.Font = Enum.Font.Gotham
panelStatus.TextXAlignment = Enum.TextXAlignment.Center
panelStatus.Parent = panelFrame

updateTargetDisplay()

-- ============================================
-- FUNGSI GET ROLE
-- ============================================
local function getRole(player)
    if not player then return "Innocent" end
    local char = player.Character
    if not char then return "Innocent" end
    if char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife") then
        return "Murderer"
    elseif char:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun") then
        return "Sheriff"
    else
        return "Innocent"
    end
end

local function isTargetAllowed(player)
    local role = getRole(player)
    if role == "Murderer" and getgenv().TargetList.Murderer then return true end
    if role == "Sheriff" and getgenv().TargetList.Sheriff then return true end
    if role == "Innocent" and getgenv().TargetList.Innocent then return true end
    return false
end

-- ============================================
-- TAB: MAIN (HANYA TOGGLE SEDERHANA)
-- ============================================
local TabMain = Window:CreateTab("Main")

-- ESP TOGGLE
local espEnabled = false
Window:AddToggle(TabMain, "Enable ESP", "Show ESP based on target selection", false, function(v)
    espEnabled = v
    refreshESP()
end, "ESPToggle")

-- Aimbot TOGGLE
local aimbotEnabled = false
local aimTrigger = "On Shoot"
local fovRadius = 150
local maxDistance = 300
local smoothness = 0.5
local visibilityCheck = true
local usePrediction = false
local predictionFactor = 0.2
local autoShootEnabled = false
local autoShootDelay = 0.1
local targetPartName = "HumanoidRootPart"

Window:AddToggle(TabMain, "Aimbot", "Enable aimbot (auto-detects Sheriff)", false, function(v) aimbotEnabled = v end, "AimbotToggle")
Window:AddDropdown(TabMain, "Trigger", "When to aim", {"On Shoot","Always"}, false, "On Shoot", function(v) aimTrigger = v end, "AimTriggerDrop")
Window:AddSlider(TabMain, "FOV Radius", "30-400", 30, 400, 150, function(v)
    fovRadius = v
    if fovCircle then fovCircle.Size = UDim2.new(0, v * 2, 0, v * 2) end
end, "FOVRadius", true)
Window:AddSlider(TabMain, "Max Distance", "50-500", 50, 500, 300, function(v) maxDistance = v end, "MaxDist", true)
Window:AddSlider(TabMain, "Smoothness", "1-10", 1, 10, 5, function(v) smoothness = v / 10 end, "Smoothness", true)
Window:AddToggle(TabMain, "Wall Check", "Don't aim through walls", true, function(v) visibilityCheck = v end, "VisCheckToggle")
Window:AddToggle(TabMain, "Prediction", "Aim ahead", false, function(v) usePrediction = v end, "PredictToggle")
Window:AddSlider(TabMain, "Pred Factor", "0-100", 0, 100, 20, function(v) predictionFactor = v / 100 end, "PredictFactor", true)
Window:AddToggle(TabMain, "Auto Shoot", "Shoot automatically", false, function(v) autoShootEnabled = v end, "AutoShootToggle")
Window:AddSlider(TabMain, "Auto Shoot Delay", "0.05-0.5s", 5, 50, 10, function(v) autoShootDelay = v / 100 end, "AutoShootDelay", true)
Window:AddDropdown(TabMain, "Target Part", "Body part", {"Head","HumanoidRootPart","Torso"}, false, "HumanoidRootPart", function(v) targetPartName = v end, "TargetPartDrop")

-- Murderer Tools
Window:AddDivider(TabMain, "Murderer Tools")
local murdererAutoThrow = false
local throwTargetMode = "All Players"
local maxThrowDistance = 300
local throwCooldown = 2
local throwPrediction = false
local throwPredFactor = 0.2
local throwVisibility = true
local autoEquipKnife = false
local autoMeleeEnabled = false
local meleeRadius = 10
local lastThrowTime = 0

Window:AddToggle(TabMain, "Auto Throw Knife", "Throw knife automatically", false, function(v) murdererAutoThrow = v end, "AutoThrowToggle")
Window:AddDropdown(TabMain, "Throw Target", "Who to target", {"All Players","Sheriff Only"}, false, "All Players", function(v) throwTargetMode = v end, "ThrowTargetDrop")
Window:AddSlider(TabMain, "Max Throw Distance", "50-500", 50, 500, 300, function(v) maxThrowDistance = v end, "ThrowDist", true)
Window:AddSlider(TabMain, "Throw Cooldown", "0.5-10s", 0.5, 10, 2, function(v) throwCooldown = v end, "ThrowCD", true)
Window:AddToggle(TabMain, "Throw Prediction", "Aim ahead", false, function(v) throwPrediction = v end, "ThrowPredict")
Window:AddSlider(TabMain, "Throw Pred Factor", "0-100", 0, 100, 20, function(v) throwPredFactor = v / 100 end, "ThrowPredFactor", true)
Window:AddToggle(TabMain, "Throw Wall Check", "Don't throw through walls", true, function(v) throwVisibility = v end, "ThrowVis")
Window:AddToggle(TabMain, "Auto Equip Knife", "Equip knife automatically", false, function(v) autoEquipKnife = v end, "AutoEquipKnife")
Window:AddDivider(TabMain, "Auto Melee Attack")
Window:AddToggle(TabMain, "Auto Melee", "Attack nearby enemies", false, function(v) autoMeleeEnabled = v end, "AutoMeleeToggle")
Window:AddSlider(TabMain, "Melee Radius", "3-30 studs", 3, 30, 10, function(v) meleeRadius = v end, "MeleeRadius", true)

-- ============================================
-- FOV CIRCLE
-- ============================================
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "W424_FOV"
fovGui.Parent = CoreGui
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true

local fovCircle = Instance.new("Frame")
fovCircle.BackgroundTransparency = 1
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, 300, 0, 300)
fovCircle.Visible = false
fovCircle.Parent = fovGui
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.5
local fovCorner = Instance.new("UICorner", fovCircle)
fovCorner.CornerRadius = UDim.new(1, 0)

-- Toggle FOV
Window:AddToggle(TabMain, "Show FOV Circle", "Display aim FOV", false, function(v)
    fovCircle.Visible = v
end, "FovCircleToggle")

-- ============================================
-- ESP (HIGHLIGHT + BILLBOARD)
-- ============================================
if CoreGui:FindFirstChild("ESP_Holder") then CoreGui.ESP_Holder:Destroy() end
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Holder"
ESPFolder.Parent = CoreGui

local espData = {}

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
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    distanceLabel.Parent = billboard

    espData[player] = {
        Highlight = highlight,
        Billboard = billboard
    }

    updateESP(player)
end

local function updateESP(player)
    local data = espData[player]
    if not data or not espEnabled then
        if data and data.Highlight then data.Highlight.Enabled = false end
        if data and data.Billboard then data.Billboard.Enabled = false end
        return
    end

    local role = getRole(player)
    local color = role == "Murderer" and Color3.new(1, 0, 0) or
                  role == "Sheriff" and Color3.new(0, 0, 1) or
                  Color3.new(0, 1, 0)
    data.Highlight.FillColor = color
    data.Highlight.OutlineColor = color
    data.Highlight.Enabled = isTargetAllowed(player)
    data.Billboard.Enabled = isTargetAllowed(player)
end

local function refreshESP()
    for player, _ in pairs(espData) do
        if player and player.Parent then
            updateESP(player)
        end
    end
end

local function setupPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then
        createESP(player)
    end
    player.CharacterAdded:Connect(function()
        createESP(player)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    local data = espData[player]
    if data then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        espData[player] = nil
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
                if distLabel and distLabel.Text and distLabel.Text:match("m$") then
                    distLabel.Text = string.format("%.0fm", dist)
                end
            end
        end
    end
end)

-- ============================================
-- FUNGSI UTAMA AIMBOT
-- ============================================
local function isMurderer(player)
    if not player then return false end
    local char = player.Character
    if not char then return false end
    return char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
end

local function isSheriff(player)
    if not player then return false end
    local char = player.Character
    if not char then return false end
    return char:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
end

local function equipKnife()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return false end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == "Knife" then
            hum:EquipTool(tool)
            return true
        end
    end
    return false
end

local function CharacterRayOrigin(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    return (hrp.CFrame * CFrame.new(0, 0, hrp.Size.Z / 2)).Position
end

local function hasClearLOS(fromPos, toPos, myChar, targetChar)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {myChar, targetChar}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(fromPos, (toPos - fromPos), params)
    if result then
        if not result.Instance:IsDescendantOf(targetChar) then
            return false
        end
    end
    return true
end

local function getTargets()
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

        if not isTargetAllowed(player) then continue end

        local part = char:FindFirstChild(targetPartName) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if not part then continue end

        local targetPos = part.Position
        if usePrediction then
            local vel = part.Velocity or Vector3.new()
            targetPos = targetPos + (vel * predictionFactor)
        end

        local dist = (targetPos - myPos).Magnitude
        if dist > maxDistance then continue end

        if visibilityCheck and not hasClearLOS(myPos, targetPos, myChar, char) then
            continue
        end

        table.insert(targets, {
            Player = player,
            Part = part,
            Position = targetPos,
            Distance = dist
        })
    end

    table.sort(targets, function(a, b)
        return a.Distance < b.Distance
    end)
    return targets
end

local function isShooting()
    return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or
           UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch)
end

RunService.RenderStepped:Connect(function(dt)
    if not aimbotEnabled then return end

    local myChar = LocalPlayer.Character
    if not myChar then return end
    local hasGun = false
    for _, tool in ipairs(myChar:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Fire") then
            hasGun = true
            break
        end
    end
    if not hasGun then return end

    local canAim = (aimTrigger == "Always") or (aimTrigger == "On Shoot" and isShooting())
    if not canAim then return end

    local targets = getTargets()
    if #targets == 0 then return end

    local target = targets[1]
    local targetPos = target.Position
    local currentCF = Camera.CFrame
    local targetCF = CFrame.new(currentCF.Position, targetPos)

    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if onScreen then
        local center = Camera.ViewportSize / 2
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist > fovRadius then return end
    else
        return
    end

    if smoothness < 1 then
        local lerpFactor = 1 - math.exp(-smoothness * dt * 5)
        Camera.CFrame = currentCF:Lerp(targetCF, lerpFactor)
    else
        Camera.CFrame = targetCF
    end

    if autoShootEnabled and target then
        local center = Camera.ViewportSize / 2
        local pos, on = Camera:WorldToViewportPoint(target.Position)
        if on and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 15 then
            pcall(function()
                local origin = CharacterRayOrigin(myChar)
                if origin and target.Part then
                    local hitPart = target.Part
                    local targetPos2 = hitPart.Position
                    ReplicatedStorage.Remotes.ShootGun:FireServer(origin, targetPos2, hitPart, targetPos2)
                    local tool = myChar:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Fire") then
                        tool.Fire:Play()
                    end
                    task.wait(autoShootDelay)
                end
            end)
        end
    end
end)

local function getThrowTargets()
    local targets = {}
    local char = LocalPlayer.Character
    if not char then return targets end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return targets end
    local myPos = myRoot.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local pChar = player.Character
        if not pChar then continue end
        local hum = pChar:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        if not isTargetAllowed(player) then continue end

        if throwTargetMode == "Sheriff Only" and not isSheriff(player) then continue end

        local part = pChar:FindFirstChild("HumanoidRootPart") or pChar:FindFirstChild("Head")
        if not part then continue end

        local targetPos = part.Position
        if throwPrediction then
            local vel = part.Velocity or Vector3.new()
            targetPos = targetPos + (vel * throwPredFactor)
        end

        local dist = (targetPos - myPos).Magnitude
        if dist > maxThrowDistance then continue end
        if throwVisibility and not hasClearLOS(myPos, targetPos, char, pChar) then continue end

        table.insert(targets, { Character = pChar, Position = targetPos, Distance = dist })
    end

    table.sort(targets, function(a, b) return a.Distance < b.Distance end)
    return targets
end

local function throwKnifeAt(targetChar, targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or tool.Name ~= "Knife" then return end
    local rightHandle = tool:FindFirstChild("RightHandle")
    if not rightHandle then return end

    local origin = CharacterRayOrigin(char)
    if not origin then return end

    local direction = (targetPos - origin).Unit
    ReplicatedStorage.Remotes.ThrowStart:FireServer(origin, direction)
    local knifeModule = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("KnifeProjectileController")
    if knifeModule then
        pcall(function()
            require(knifeModule)({
                Speed = tool:GetAttribute("ThrowSpeed") or 50,
                KnifeProjectile = rightHandle:Clone(),
                Direction = direction,
                Origin = origin
            }, function(raycastResult)
                ReplicatedStorage.Remotes.ThrowHit:FireServer(raycastResult and raycastResult.Instance,
                    raycastResult and raycastResult.Position)
            end)
        end)
    else
        ReplicatedStorage.Remotes.ThrowHit:FireServer(nil, targetPos)
    end
    lastThrowTime = tick()
end

local function doMeleeAttack()
    local char = LocalPlayer.Character
    if not char then return end
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Melee")
    if remote then
        remote:FireServer()
    else
        local general = ReplicatedStorage:FindFirstChild("Melee") or ReplicatedStorage:FindFirstChild("Attack")
        if general then general:FireServer() end
    end
end

task.spawn(function()
    while true do
        local char = LocalPlayer.Character
        if not char then task.wait(0.5) continue end

        if not isMurderer(LocalPlayer) then task.wait(0.5) continue end

        if autoEquipKnife then
            local has = false
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == "Knife" then has = true break end
            end
            if not has then equipKnife(); task.wait(0.2) end
        end

        if autoMeleeEnabled then
            local myRoot = char:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local myPos = myRoot.Position
                local closest = nil
                local closestDist = meleeRadius
                for _, player in ipairs(Players:GetPlayers()) do
                    if player == LocalPlayer then continue end
                    if not isTargetAllowed(player) then continue end
                    local pChar = player.Character
                    if not pChar then continue end
                    local hum = pChar:FindFirstChildOfClass("Humanoid")
                    if not hum or hum.Health <= 0 then continue end
                    local targetRoot = pChar:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then continue end
                    local dist = (targetRoot.Position - myPos).Magnitude
                    if dist < closestDist and hasClearLOS(myPos, targetRoot.Position, char, pChar) then
                        closestDist = dist
                        closest = pChar
                    end
                end
                if closest then
                    doMeleeAttack()
                    task.wait(0.3)
                end
            end
        end

        if murdererAutoThrow and (tick() - lastThrowTime) >= throwCooldown then
            local targets = getThrowTargets()
            if #targets > 0 then
                local target = targets[1]
                throwKnifeAt(target.Character, target.Position)
            end
        end

        task.wait(0.1)
    end
end)

print("✅ W424HUB Target Panel loaded! Click M, S, I buttons to select targets.")