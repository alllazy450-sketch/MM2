-- ============================================
-- MURDER MYSTERY 2 OP – V1
-- ============================================
print("=== LOADING MM2 OP ===")

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
-- WINDOW KAIRO (Tanpa Icon di Tab)
-- ============================================
local Window = Kairo:CreateWindow({
    Title = "MM2 OP Hub",
    Theme = "Ocean",
    Size = UDim2.fromOffset(500, 450),
    Center = true,
    Draggable = true,
    Resize = false,
    Badges = {"v3.0"},
    MinimizeKey = Enum.KeyCode.RightShift,
    MinimizeButton = true,
    Config = { Enabled = true, Folder = "MM2OP_Config", AutoLoad = true }
})

if not Window then
    warn("❌ Gagal membuat window!")
    return
end

Window:Notify({
    Title = "MM2 OP Hub",
    Description = "Loaded successfully!",
    Content = "Aimbot, Auto Throw, Auto Melee",
    Color = Color3.fromRGB(0, 200, 50),
    Delay = 3
})

-- ============================================
-- TAB: TRADING (Hanya Title, tanpa Icon)
-- ============================================
local TabTrade = Window:CreateTab("Trading")
Window:AddParagraph(TabTrade, "Trade Stuff", "Force trade with anyone")

local playerNameTextbox = ""
Window:AddInput(TabTrade, "Player Name", "Enter player name...", "", function(v)
    playerNameTextbox = v
end, "TradeInput")

Window:AddButton(TabTrade, "Force Trade", "Send trade request & accept", function()
    if playerNameTextbox and playerNameTextbox ~= "" then
        local player = Players:FindFirstChild(playerNameTextbox)
        if player then
            local args = { [1] = player }
            local success, err = pcall(function()
                ReplicatedStorage:WaitForChild("Trade"):WaitForChild("SendRequest"):InvokeServer(unpack(args))
                task.wait(0.5)
                ReplicatedStorage:WaitForChild("Trade"):WaitForChild("AcceptRequest"):FireServer()
            end)
            if success then
                Window:Notify({
                    Title = "Trade System",
                    Description = "Force Traded Player: " .. playerNameTextbox,
                    Color = Color3.fromRGB(0, 255, 0),
                    Delay = 3
                })
            else
                Window:Notify({
                    Title = "Trade System",
                    Description = "Error: " .. err,
                    Color = Color3.fromRGB(255, 0, 0),
                    Delay = 3
                })
            end
        else
            Window:Notify({
                Title = "Trade System",
                Description = "Player not found.",
                Color = Color3.fromRGB(255, 255, 0),
                Delay = 3
            })
        end
    else
        Window:Notify({
            Title = "Trade System",
            Description = "Please enter a valid player name.",
            Color = Color3.fromRGB(255, 255, 0),
            Delay = 3
        })
    end
end, "ForceTradeBtn")

-- ============================================
-- TAB: ROLES & ESP
-- ============================================
local TabRoles = Window:CreateTab("Roles & ESP")

Window:AddParagraph(TabRoles, "Role Exposure", "Chat roles")
Window:AddButton(TabRoles, "Chat Expose Roles", "Say who has knife/gun in chat", function()
    local allPlayers = Players:GetPlayers()
    for _, player in ipairs(allPlayers) do
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            if backpack:FindFirstChild("Knife") then
                ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(
                    player.Name .. ": Has The Knife", "normalchat"
                )
            end
            if backpack:FindFirstChild("Gun") then
                ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(
                    player.Name .. ": Has The Gun", "normalchat"
                )
            end
        end
    end
    Window:Notify({
        Title = "Roles Exposed",
        Description = "Check chat!",
        Color = Color3.fromRGB(0, 200, 255),
        Delay = 3
    })
end, "ExposeRolesBtn")

-- Gun Drop Status
Window:AddDivider(TabRoles, "Gun Drop Status")
local gunLabel = Window:AddLabel(TabRoles, "Gun Drop Status: Unknown", "GunLabel")
task.spawn(function()
    local gunDropped = false
    while true do
        local gunExists = Workspace:FindFirstChild("GunDrop")
        if gunExists then
            gunLabel:SetText("Gun Drop Status: Dropped ✔️")
            if not gunDropped then
                gunDropped = true
                Window:Notify({
                    Title = "Gun Status",
                    Description = "Gun Dropped!",
                    Color = Color3.fromRGB(255, 200, 0),
                    Delay = 5
                })
            end
        else
            gunLabel:SetText("Gun Drop Status: Not Dropped ❌")
            gunDropped = false
        end
        task.wait(1)
    end
end)

-- Role Labels
Window:AddDivider(TabRoles, "Role Detector")
local murdererLabel = Window:AddLabel(TabRoles, "Murderer: Unknown", "MurdererLabel")
local sheriffLabel = Window:AddLabel(TabRoles, "Sheriff: Unknown", "SheriffLabel")

task.spawn(function()
    while true do
        local players = Players:GetPlayers()
        local murderer, sheriff = "Unknown", "Unknown"
        for _, player in ipairs(players) do
            if player.Character then
                local backpack = player.Backpack
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            if tool.Name == "Knife" then murderer = player.Name
                            elseif tool.Name == "Gun" then sheriff = player.Name end
                        end
                    end
                end
            end
        end
        murdererLabel:SetText("Murderer: " .. murderer)
        sheriffLabel:SetText("Sheriff: " .. sheriff)
        task.wait(1)
    end
end)

-- ESP
Window:AddDivider(TabRoles, "ESP (Billboard)")
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Holder"
ESPFolder.Parent = CoreGui

getgenv().AllEsp = false
getgenv().MurderEsp = false
getgenv().SheriffEsp = false

local function AddBillboard(player)
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = player.Name .. "_ESP"
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.ExtentsOffset = Vector3.new(0, 3, 0)
    Billboard.Enabled = false
    Billboard.Parent = ESPFolder

    local TextLabel = Instance.new("TextLabel")
    TextLabel.TextSize = 20
    TextLabel.Text = player.Name
    TextLabel.Font = Enum.Font.FredokaOne
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.TextStrokeTransparency = 0
    TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    TextLabel.Parent = Billboard

    local con
    con = RunService.Heartbeat:Connect(function()
        if not player.Parent then
            con:Disconnect()
            Billboard:Destroy()
            return
        end
        pcall(function()
            Billboard.Adornee = player.Character and player.Character:FindFirstChild("Head")
            if player.Character and (player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")) then
                TextLabel.TextColor3 = Color3.new(1, 0, 0)
                Billboard.Enabled = getgenv().MurderEsp
            elseif player.Character and (player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")) then
                TextLabel.TextColor3 = Color3.new(0, 0, 1)
                Billboard.Enabled = getgenv().SheriffEsp
            else
                TextLabel.TextColor3 = Color3.new(0, 1, 0)
                Billboard.Enabled = getgenv().AllEsp
            end
        end)
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        task.spawn(AddBillboard, player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        task.spawn(AddBillboard, player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local bill = ESPFolder:FindFirstChild(player.Name .. "_ESP")
    if bill then bill:Destroy() end
end)

Window:AddToggle(TabRoles, "All ESP", "Show every player (green)", false, function(v)
    getgenv().AllEsp = v
    if v then
        getgenv().MurderEsp = false
        getgenv().SheriffEsp = false
    end
    for _, bill in ipairs(ESPFolder:GetChildren()) do
        if bill:IsA("BillboardGui") then
            local pName = bill.Name:gsub("_ESP", "")
            local player = Players:FindFirstChild(pName)
            if player then
                local hasKnife = player.Character and (player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife"))
                local hasGun = player.Character and (player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun"))
                if not (hasKnife or hasGun) then
                    bill.Enabled = v
                end
            end
        end
    end
end, "AllESPToggle")

Window:AddToggle(TabRoles, "Murder ESP", "Show murderer (red)", false, function(v)
    getgenv().MurderEsp = v
    if v then
        getgenv().AllEsp = false
    end
    for _, bill in ipairs(ESPFolder:GetChildren()) do
        if bill:IsA("BillboardGui") then
            local pName = bill.Name:gsub("_ESP", "")
            local player = Players:FindFirstChild(pName)
            if player and (player.Character and player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")) then
                bill.Enabled = v
            end
        end
    end
end, "MurderESPToggle")

Window:AddToggle(TabRoles, "Sheriff ESP", "Show sheriff (blue)", false, function(v)
    getgenv().SheriffEsp = v
    if v then
        getgenv().AllEsp = false
    end
    for _, bill in ipairs(ESPFolder:GetChildren()) do
        if bill:IsA("BillboardGui") then
            local pName = bill.Name:gsub("_ESP", "")
            local player = Players:FindFirstChild(pName)
            if player and (player.Character and player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")) then
                bill.Enabled = v
            end
        end
    end
end, "SheriffESPToggle")

-- ============================================
-- TAB: AIM (AIMBOT + MURDERER TOOLS)
-- ============================================
local TabAim = Window:CreateTab("Aim")

Window:AddParagraph(TabAim, "Sheriff Aimbot", "For Sheriff (Gun)")

-- Aimbot variables
local aimbotEnabled = false
local aimTrigger = "On Shoot"
local targetMode = "Murderer Only"
local fovRadius = 150
local maxDistance = 300
local smoothness = 0.5
local visibilityCheck = true
local usePrediction = false
local predictionFactor = 0.2
local autoShootEnabled = false
local autoShootDelay = 0.1
local targetPartName = "HumanoidRootPart"
local fovCircleVisible = false

-- UI Aimbot
Window:AddToggle(TabAim, "Aimbot", "Enable aimbot (Sheriff only)", false, function(v) aimbotEnabled = v end, "AimbotToggle")
Window:AddDropdown(TabAim, "Trigger", "When to aim", {"On Shoot","Always"}, false, "On Shoot", function(v) aimTrigger = v end, "AimTriggerDrop")
Window:AddDropdown(TabAim, "Target Mode", "Who to target", {"Murderer Only","All Players"}, false, "Murderer Only", function(v) targetMode = v end, "TargetModeDrop")
Window:AddToggle(TabAim, "FOV Circle", "Show aim FOV", false, function(v)
    fovCircleVisible = v
    if fovCircle then fovCircle.Visible = v end
end, "FOVCircleToggle")
Window:AddSlider(TabAim, "FOV Radius", "30-400", 30, 400, 150, function(v)
    fovRadius = v
    if fovCircle then fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2) end
end, "FOVRadius", true)
Window:AddSlider(TabAim, "Max Distance", "50-500", 50, 500, 300, function(v) maxDistance = v end, "MaxDist", true)
Window:AddSlider(TabAim, "Smoothness", "1-10", 1, 10, 5, function(v) smoothness = v / 10 end, "Smoothness", true)
Window:AddToggle(TabAim, "Wall Check", "Don't aim through walls", true, function(v) visibilityCheck = v end, "VisCheckToggle")
Window:AddToggle(TabAim, "Prediction", "Aim ahead of moving target", false, function(v) usePrediction = v end, "PredictToggle")
Window:AddSlider(TabAim, "Pred Factor", "0-100", 0, 100, 20, function(v) predictionFactor = v / 100 end, "PredictFactor", true)
Window:AddToggle(TabAim, "Auto Shoot", "Shoot automatically when on target", false, function(v) autoShootEnabled = v end, "AutoShootToggle")
Window:AddSlider(TabAim, "Auto Shoot Delay", "0.05-0.5s", 5, 50, 10, function(v) autoShootDelay = v / 100 end, "AutoShootDelay", true)
Window:AddDropdown(TabAim, "Target Part", "Body part", {"Head","HumanoidRootPart","Torso"}, false, "HumanoidRootPart", function(v) targetPartName = v end, "TargetPartDrop")

-- FOV Circle
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "MM2_FOV"
fovGui.Parent = CoreGui
fovGui.ResetOnSpawn = false
local fovCircle = Instance.new("Frame")
fovCircle.BackgroundTransparency = 1
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovCircle.Visible = false
fovCircle.Parent = fovGui
local stroke = Instance.new("UIStroke", fovCircle)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5
local corner = Instance.new("UICorner", fovCircle)
corner.CornerRadius = UDim.new(1, 0)

-- ===== MURDERER TOOLS =====
Window:AddDivider(TabAim, "Murderer Tools")
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

Window:AddToggle(TabAim, "Auto Throw Knife", "Throw knife automatically", false, function(v) murdererAutoThrow = v end, "AutoThrowToggle")
Window:AddDropdown(TabAim, "Throw Target", "Who to target", {"All Players","Sheriff Only"}, false, "All Players", function(v) throwTargetMode = v end, "ThrowTargetDrop")
Window:AddSlider(TabAim, "Max Throw Distance", "50-500", 50, 500, 300, function(v) maxThrowDistance = v end, "ThrowDist", true)
Window:AddSlider(TabAim, "Throw Cooldown", "0.5-10s", 0.5, 10, 2, function(v) throwCooldown = v end, "ThrowCD", true)
Window:AddToggle(TabAim, "Throw Prediction", "Aim ahead", false, function(v) throwPrediction = v end, "ThrowPredict")
Window:AddSlider(TabAim, "Throw Pred Factor", "0-100", 0, 100, 20, function(v) throwPredFactor = v / 100 end, "ThrowPredFactor", true)
Window:AddToggle(TabAim, "Throw Wall Check", "Don't throw through walls", true, function(v) throwVisibility = v end, "ThrowVis")
Window:AddToggle(TabAim, "Auto Equip Knife", "Equip knife automatically", false, function(v) autoEquipKnife = v end, "AutoEquipKnife")

-- Auto Melee
Window:AddDivider(TabAim, "Auto Melee Attack")
Window:AddToggle(TabAim, "Auto Melee", "Attack nearby enemies with knife", false, function(v) autoMeleeEnabled = v end, "AutoMeleeToggle")
Window:AddSlider(TabAim, "Melee Radius", "3-30 studs", 3, 30, 10, function(v) meleeRadius = v end, "MeleeRadius", true)

-- ============================================
-- FUNGSI-FUNGSI UTAMA (Sama seperti sebelumnya)
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

-- Aimbot getTargets
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

        local isMur = isMurderer(player)
        if targetMode == "Murderer Only" and not isMur then continue end

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
            Distance = dist,
            IsMurderer = isMur
        })
    end

    table.sort(targets, function(a, b)
        if a.IsMurderer and not b.IsMurderer then return true end
        if not a.IsMurderer and b.IsMurderer then return false end
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

    -- Auto Shoot
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

-- Auto Throw & Melee loop
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

        -- Auto Melee
        if autoMeleeEnabled then
            local myRoot = char:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local myPos = myRoot.Position
                local closest = nil
                local closestDist = meleeRadius
                for _, player in ipairs(Players:GetPlayers()) do
                    if player == LocalPlayer then continue end
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

        -- Auto Throw
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

-- ============================================
-- TAB: MISC
-- ============================================
local TabMisc = Window:CreateTab("Misc")

Window:AddParagraph(TabMisc, "Emotes", "Unlock all free emotes")
Window:AddButton(TabMisc, "Get Every Emote", "Add all free emotes", function()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local Emotes = PlayerGui:WaitForChild("MainGUI"):WaitForChild("Game"):FindFirstChild("Emotes")
    if Emotes then
        local success, err = pcall(function()
            require(ReplicatedStorage.Modules.EmoteModule).GeneratePage({"headless","zombie","zen","ninja","floss","dab","sit"}, Emotes, "Free Emotes")
        end)
        if success then
            Window:Notify({
                Title = "Emotes",
                Description = "Successfully added emotes!",
                Color = Color3.fromRGB(0, 255, 0),
                Delay = 3
            })
        else
            Window:Notify({
                Title = "Emotes",
                Description = "Error: " .. err,
                Color = Color3.fromRGB(255, 0, 0),
                Delay = 3
            })
        end
    else
        Window:Notify({
            Title = "Emotes",
            Description = "Emotes folder not found.",
            Color = Color3.fromRGB(255, 255, 0),
            Delay = 3
        })
    end
end, "GetEmotesBtn")

Window:AddDivider(TabMisc, "Weapons")
Window:AddButton(TabMisc, "Get Every Gun/Knife", "Attempt to unlock all weapons (client-side)", function()
    local success, result = pcall(function()
        local Database = getrenv()._G.Database
        local PlayerData = getrenv()._G.PlayerData
        if not Database or not PlayerData then
            error("Database or PlayerData not found.")
        end
        local newOwned = {}
        for weapon, _ in pairs(Database.Item) do
            newOwned[weapon] = 999999999
        end
        local PlayerWeapons = PlayerData.Weapons
        local bind
        bind = RunService:BindToRenderStep("InventoryUpdate", 0, function()
            PlayerWeapons.Owned = newOwned
        end)
        task.wait(1)
        RunService:UnbindFromRenderStep("InventoryUpdate")
        return "Weapons updated (client-side). You may need to respawn."
    end)
    if success then
        Window:Notify({ Title = "Weapons", Description = tostring(result), Color = Color3.fromRGB(0,255,0), Delay = 5 })
    else
        Window:Notify({ Title = "Weapons", Description = "Failed: " .. tostring(result), Color = Color3.fromRGB(255,0,0), Delay = 5 })
    end
end, "GetWeaponsBtn")

print("✅ MM2 OP Hub LOADED!")