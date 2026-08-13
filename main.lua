-- ============================================
-- W424HUB – FINAL FIX (Sheriff & Murderer)
-- ============================================
print("=== LOADING W424HUB FIX ===")

local Kairo = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzzavi335/Kairo-Ui-Library/refs/heads/main/source.luau"))()
if not Kairo then warn("❌ Kairo failed to load!") return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- ============================================
-- WINDOW KAIRO
-- ============================================
local Window = Kairo:CreateWindow({
    Title = "W424HUB",
    Theme = "Ocean",
    Size = UDim2.fromOffset(500, 450),
    Center = true,
    Draggable = true,
    Resize = false,
    Badges = {"v3.1"},
    MinimizeKey = Enum.KeyCode.RightShift,
    MinimizeButton = true,
    Config = { Enabled = true, Folder = "W424HUB_Config", AutoLoad = true }
})

Window:Notify({
    Title = "W424HUB",
    Description = "Loaded!",
    Content = "Sheriff & Murderer Tools",
    Color = Color3.fromRGB(0,200,50),
    Delay = 3
})

-- ============================================
-- FUNGSI GET ROLE (PAKAI WEAPON DETECTION + ATTRIBUTE)
-- ============================================
local function getRole(player)
    if not player or not player.Character then return "Innocent" end

    -- Cek attribute (jika ada)
    local roleAttr = player:GetAttribute("Role")
    if roleAttr then
        if roleAttr == "Murderer" or roleAttr == "Sheriff" then return roleAttr end
    end

    -- Cek tool
    local hasKnife = false
    local hasGun = false

    local function checkTool(tool)
        if not tool or not tool:IsA("Tool") then return end
        local name = tool.Name:lower()
        if name:find("knife") or name:find("murderer") or name:find("blade") or name:find("throw") then
            hasKnife = true
        end
        if name:find("gun") or name:find("revolver") or name:find("sheriff") or name:find("pistol") then
            hasGun = true
        end
    end

    -- Cek di Character
    local char = player.Character
    for _, tool in ipairs(char:GetChildren()) do
        checkTool(tool)
    end

    -- Cek di Backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            checkTool(tool)
        end
    end

    if hasKnife then return "Murderer" end
    if hasGun then return "Sheriff" end
    return "Innocent"
end

local function isMurderer(player) return getRole(player) == "Murderer" end
local function isSheriff(player) return getRole(player) == "Sheriff" end

-- ============================================
-- HELPERS
-- ============================================
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

-- ============================================
-- WEAPONSERVICE HOOK (ALTERNATIF AIM)
-- ============================================
local WeaponService = nil
local oldGetMouseTargetCFrame = nil

pcall(function()
    WeaponService = require(ReplicatedStorage:FindFirstChild("ClientServices"):FindFirstChild("WeaponService"))
    if WeaponService then
        oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame
    end
end)

local aimbotEnabled = false
local aimbotTargetMode = "Murderer Only"
local aimbotFOV = 150
local aimbotDistance = 300
local aimbotSmooth = 0.5
local aimbotWall = true
local aimbotPrediction = false
local aimbotPredFactor = 0.2
local aimbotAutoShoot = false
local aimbotAutoDelay = 0.1
local aimbotTargetPart = "HumanoidRootPart"
local lastAutoShootTime = 0

-- Fungsi target filter
local function isTargetAllowed(player)
    local role = getRole(player)
    if aimbotTargetMode == "Murderer Only" and role == "Murderer" then return true end
    if aimbotTargetMode == "Innocent Only" and role == "Innocent" then return true end
    if aimbotTargetMode == "All Players" then return true end
    return false
end

local function getAimbotTarget()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position
    local bestTarget = nil
    local bestScore = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        if not isTargetAllowed(player) then continue end

        local part = char:FindFirstChild(aimbotTargetPart) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if not part then continue end

        local targetPos = part.Position
        if aimbotPrediction then
            local vel = part.Velocity or Vector3.new()
            targetPos = targetPos + (vel * aimbotPredFactor)
        end

        local dist = (targetPos - myPos).Magnitude
        if dist > aimbotDistance then continue end

        if aimbotWall and not hasClearLOS(myPos, targetPos, myChar, char) then
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
        if not onScreen then continue end
        local center = Camera.ViewportSize / 2
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if screenDist > aimbotFOV then continue end

        -- Score: jarak layar + jarak dunia
        local score = screenDist + dist * 0.1
        if score < bestScore then
            bestScore = score
            bestTarget = {
                Player = player,
                Part = part,
                Position = targetPos,
                Distance = dist,
                ScreenDist = screenDist
            }
        end
    end
    return bestTarget
end

-- ============================================
-- HOOK WEAPONSERVICE (JALUR UTAMA AIM)
-- ============================================
local function HookWeaponService()
    if not WeaponService then return end
    if oldGetMouseTargetCFrame then
        WeaponService.GetMouseTargetCFrame = function(self)
            if not aimbotEnabled then
                return oldGetMouseTargetCFrame(self)
            end
            local target = getAimbotTarget()
            if target then
                local targetPos = target.Position
                local finalPos = targetPos + Vector3.new(0, 0.5, 0)
                return CFrame.new(finalPos)
            end
            return oldGetMouseTargetCFrame(self)
        end
    end
end

-- Panggil hook
pcall(HookWeaponService)

-- ============================================
-- UI SHERIFF (AIMBOT)
-- ============================================
local TabSheriff = Window:CreateTab("Sheriff")
Window:AddParagraph(TabSheriff, "Sheriff Aimbot", "Aktif jika memegang Gun")

Window:AddToggle(TabSheriff, "Enable Aimbot", "Aim ke target via WeaponService", false, function(v) aimbotEnabled = v end)
Window:AddDropdown(TabSheriff, "Target", "Siapa yang di-aim", {"Murderer Only","All Players","Innocent Only"}, false, "Murderer Only", function(v) aimbotTargetMode = v end)
Window:AddSlider(TabSheriff, "FOV Radius", "30-400", 30, 400, 150, function(v) aimbotFOV = v end)
Window:AddSlider(TabSheriff, "Max Distance", "50-500", 50, 500, 300, function(v) aimbotDistance = v end)
Window:AddSlider(TabSheriff, "Smoothness", "1-10", 1, 10, 5, function(v) aimbotSmooth = v / 10 end)
Window:AddToggle(TabSheriff, "Wall Check", "Tidak menembus tembok", true, function(v) aimbotWall = v end)
Window:AddToggle(TabSheriff, "Prediction", "Aim ke depan target", false, function(v) aimbotPrediction = v end)
Window:AddSlider(TabSheriff, "Pred Factor", "0-100", 0, 100, 20, function(v) aimbotPredFactor = v / 100 end)
Window:AddToggle(TabSheriff, "Auto Shoot", "Tembak otomatis (menggunakan remote)", false, function(v) aimbotAutoShoot = v end)
Window:AddSlider(TabSheriff, "Auto Shoot Delay", "0.05-0.5s", 5, 50, 10, function(v) aimbotAutoDelay = v / 100 end)
Window:AddDropdown(TabSheriff, "Target Part", "Bagian tubuh", {"Head","HumanoidRootPart","Torso"}, false, "HumanoidRootPart", function(v) aimbotTargetPart = v end)

-- ============================================
-- AUTO SHOOT LOOP (MENGGUNAKAN REMOTE)
-- ============================================
local shootRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ShootGun")
if not shootRemote then
    shootRemote = ReplicatedStorage:FindFirstChild("ShootGun")
end
if not shootRemote then
    warn("ShootGun remote not found! Auto shoot may not work.")
end

RunService.RenderStepped:Connect(function(dt)
    if not aimbotEnabled or not aimbotAutoShoot then return end
    if not shootRemote then return end

    local myChar = LocalPlayer.Character
    if not myChar then return end
    local gun = myChar:FindFirstChildOfClass("Tool")
    if not gun or not (gun.Name:lower():find("gun") or gun.Name:lower():find("revolver") or gun.Name:lower():find("pistol")) then
        return
    end

    local target = getAimbotTarget()
    if not target then return end

    local center = Camera.ViewportSize / 2
    local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
    if not onScreen then return end
    local crosshairDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
    if crosshairDist > 30 then return end

    if (tick() - lastAutoShootTime) >= aimbotAutoDelay then
        lastAutoShootTime = tick()
        local origin = CharacterRayOrigin(myChar)
        if origin then
            pcall(function()
                shootRemote:FireServer(origin, target.Position, target.Part, target.Position)
            end)
        end
    end
end)

-- ============================================
-- MURDERER TAB (SAMA SEPERTI SEBELUMNYA, TETAP ADA)
-- ============================================
local TabMurderer = Window:CreateTab("Murderer")
Window:AddParagraph(TabMurderer, "Murderer Tools", "Aktif jika memegang Knife")

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

Window:AddToggle(TabMurderer, "Auto Throw Knife", "Lempar pisau otomatis", false, function(v) murdererThrow = v end)
Window:AddDropdown(TabMurderer, "Throw Target", "Target lemparan", {"All Players","Sheriff Only","Innocent Only"}, false, "All Players", function(v) murdererThrowTarget = v end)
Window:AddSlider(TabMurderer, "Max Throw Distance", "50-500", 50, 500, 300, function(v) murdererThrowDist = v end)
Window:AddSlider(TabMurderer, "Throw Cooldown", "0.5-10s", 0.5, 10, 2, function(v) murdererThrowCD = v end)
Window:AddToggle(TabMurderer, "Throw Prediction", "Lempar ke depan target", false, function(v) murdererThrowPred = v end)
Window:AddSlider(TabMurderer, "Throw Pred Factor", "0-100", 0, 100, 20, function(v) murdererThrowPredFactor = v / 100 end)
Window:AddToggle(TabMurderer, "Throw Wall Check", "Tidak lempar tembus tembok", true, function(v) murdererThrowWall = v end)
Window:AddToggle(TabMurderer, "Auto Equip Knife", "Equip pisau otomatis", false, function(v) murdererAutoEquip = v end)
Window:AddDivider(TabMurderer, "Auto Melee Attack")
Window:AddToggle(TabMurderer, "Auto Melee", "Serang musuh di dekat", false, function(v) murdererMelee = v end)
Window:AddSlider(TabMurderer, "Melee Radius", "3-30 studs", 3, 30, 10, function(v) murdererMeleeRadius = v end)

-- ============================================
-- ESP (SAMA SEPERTI SEBELUMNYA)
-- ============================================
local TabVisual = Window:CreateTab("Visual")
Window:AddParagraph(TabVisual, "ESP & FOV", "Toggle visual")

if CoreGui:FindFirstChild("ESP_Holder") then CoreGui.ESP_Holder:Destroy() end
local espEnabled = false
local espData = {}

local function updateESPVisual(player)
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
    data.Highlight.Enabled = true
    data.Billboard.Enabled = true
end

local function refreshESP()
    for player, _ in pairs(espData) do
        if player and player.Parent then updateESPVisual(player) end
    end
end

Window:AddToggle(TabVisual, "Enable ESP", "Tampilkan nama + jarak + highlight", false, function(v)
    espEnabled = v
    refreshESP()
end)

-- FOV Circle
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

Window:AddToggle(TabVisual, "Show FOV Circle", "Tampilkan lingkaran FOV", false, function(v)
    fovCircle.Visible = v
end)

Window:AddSlider(TabVisual, "FOV Radius", "30-400", 30, 400, 150, function(v)
    fovCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
end)

-- ============================================
-- ESP IMPLEMENTASI
-- ============================================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Holder"
ESPFolder.Parent = CoreGui

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

    espData[player] = { Highlight = highlight, Billboard = billboard }
    updateESPVisual(player)
end

local function setupPlayer(player)
    if player == LocalPlayer then return end
    if player.Character then createESP(player) end
    player.CharacterAdded:Connect(function() createESP(player) end)
end

for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    local data = espData[player]
    if data then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        espData[player] = nil
    end
end)

task.spawn(function()
    local lastRoles = {}
    while true do
        for player, data in pairs(espData) do
            if player and player.Parent then
                local newRole = getRole(player)
                if lastRoles[player] ~= newRole then
                    lastRoles[player] = newRole
                    updateESPVisual(player)
                end
            end
        end
        task.wait(0.5)
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
                if distLabel and distLabel.Text and distLabel.Text:match("m$") then
                    distLabel.Text = string.format("%.0fm", dist)
                end
            end
        end
    end
end)

-- ============================================
-- MURDERER LOGIC (SAMA)
-- ============================================
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
    local origin = CharacterRayOrigin(char)
    if not origin then return end
    local direction = (targetPos - origin).Unit
    local throwRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ThrowStart")
    if throwRemote then
        throwRemote:FireServer(origin, direction)
    else
        local remote = ReplicatedStorage:FindFirstChild("ThrowStart")
        if remote then remote:FireServer(origin, direction) end
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
        if LocalPlayer.Character and isMurderer(LocalPlayer) then
            if murdererAutoEquip then
                local hasKnife = false
                for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("blade")) then
                        hasKnife = true
                        break
                    end
                end
                if not hasKnife then equipKnife()
            end

            if murdererMelee then
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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
                        local targetRoot = pChar:FindFirstChild("HumanoidRootPart")
                        if not targetRoot then continue end
                        local dist = (targetRoot.Position - myPos).Magnitude
                        if dist < murdererMeleeRadius and hasClearLOS(myPos, targetRoot.Position, LocalPlayer.Character, pChar) then
                            doMeleeAttack()
                            task.wait(0.3)
                        end
                    end
                end
            end

            if murdererThrow and (tick() - lastThrowTime) >= murdererThrowCD then
                -- Cari target terdekat
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local myPos = myRoot.Position
                    local best = nil
                    local bestDist = murdererThrowDist
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
                        if dist < bestDist and hasClearLOS(myPos, targetRoot.Position, LocalPlayer.Character, pChar) then
                            bestDist = dist
                            best = pChar
                        end
                    end
                    if best then
                        local targetPos = best:FindFirstChild("HumanoidRootPart") and best.HumanoidRootPart.Position
                        if targetPos then
                            throwKnifeAt(best, targetPos)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

print("✅ W424HUB FINAL FIX loaded – aimbot menggunakan WeaponService hook + auto shoot remote.")