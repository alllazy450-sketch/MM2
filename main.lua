-- ============================================================
-- W424HUB – STABLE PLUS (KAIRO UI + HITBOX + LINE ESP)
-- ============================================================
print("=== LOADING W424HUB STABLE PLUS ===")

local Kairo = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzzavi335/Kairo-Ui-Library/refs/heads/main/source.luau"))()
if not Kairo then
    warn("❌ Kairo gagal di-load!")
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
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

-- ============================================================
-- WINDOW KAIRO
-- ============================================================
local Window = Kairo:CreateWindow({
    Title = "W424HUB",
    Theme = "Ocean",
    Size = UDim2.fromOffset(520, 500),
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
    Content = "Stabil + Hitbox + Line ESP",
    Color = Color3.fromRGB(0, 200, 50),
    Delay = 3
})

-- ============================================================
-- FUNGSI GET ROLE (AKURAT)
-- ============================================================
local function getRole(player)
    if not player or not player.Character then return "Innocent" end

    local hasKnife = false
    local hasGun = false

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("knife") or name:find("murderer") or name:find("blade") then
                    hasKnife = true
                end
                if name:find("gun") or name:find("revolver") or name:find("sheriff") or name:find("pistol") then
                    hasGun = true
                end
            end
        end
    end

    local charTool = player.Character:FindFirstChildOfClass("Tool")
    if charTool then
        local name = charTool.Name:lower()
        if name:find("knife") or name:find("murderer") or name:find("blade") then
            hasKnife = true
        end
        if name:find("gun") or name:find("revolver") or name:find("sheriff") or name:find("pistol") then
            hasGun = true
        end
    end

    if hasKnife then return "Murderer" end
    if hasGun then return "Sheriff" end
    return "Innocent"
end

local function isMurderer(player)
    return getRole(player) == "Murderer"
end

local function isSheriff(player)
    return getRole(player) == "Sheriff"
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

local function getShootRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local shoot = remotes:FindFirstChild("ShootGun") or remotes:FindFirstChild("Shoot") or remotes:FindFirstChild("Fire")
        if shoot then return shoot end
    end
    local shoot = ReplicatedStorage:FindFirstChild("ShootGun") or ReplicatedStorage:FindFirstChild("Shoot") or ReplicatedStorage:FindFirstChild("Fire")
    return shoot
end

-- ============================================================
-- TAB SHERIFF (AIMBOT + SILENT AIM)
-- ============================================================
local TabSheriff = Window:CreateTab("Sheriff")
Window:AddParagraph(TabSheriff, "Sheriff Aimbot", "Aktif jika memegang Gun")

local sheriffAimbot = false
local sheriffTrigger = "On Shoot"
local sheriffTargetMode = "Murderer Only"
local sheriffFOV = 150
local sheriffDistance = 300
local sheriffSmooth = 0.5
local sheriffWall = true
local sheriffPrediction = false
local sheriffPredFactor = 0.2
local sheriffAutoShoot = false
local sheriffAutoDelay = 0.1
local sheriffTargetPart = "HumanoidRootPart"
local lastAutoShootTime = 0

Window:AddToggle(TabSheriff, "Enable Aimbot", "Aim ke target", false, function(v) sheriffAimbot = v end)
Window:AddDropdown(TabSheriff, "Trigger", "Kapan aim", {"On Shoot","Always"}, false, "On Shoot", function(v) sheriffTrigger = v end)
Window:AddDropdown(TabSheriff, "Target", "Siapa yang di-aim", {"Murderer Only","All Players","Innocent Only"}, false, "Murderer Only", function(v) sheriffTargetMode = v end)
Window:AddSlider(TabSheriff, "FOV Radius", "30-400", 30, 400, 150, function(v) sheriffFOV = v end)
Window:AddSlider(TabSheriff, "Max Distance", "50-500", 50, 500, 300, function(v) sheriffDistance = v end)
Window:AddSlider(TabSheriff, "Smoothness", "1-10", 1, 10, 5, function(v) sheriffSmooth = v / 10 end)
Window:AddToggle(TabSheriff, "Wall Check", "Tidak menembus tembok", true, function(v) sheriffWall = v end)
Window:AddToggle(TabSheriff, "Prediction", "Aim ke depan target", false, function(v) sheriffPrediction = v end)
Window:AddSlider(TabSheriff, "Pred Factor", "0-100", 0, 100, 20, function(v) sheriffPredFactor = v / 100 end)
Window:AddToggle(TabSheriff, "Auto Shoot", "Tembak otomatis", false, function(v) sheriffAutoShoot = v end)
Window:AddSlider(TabSheriff, "Auto Shoot Delay", "0.05-0.5s", 5, 50, 10, function(v) sheriffAutoDelay = v / 100 end)
Window:AddDropdown(TabSheriff, "Target Part", "Bagian tubuh", {"Head","HumanoidRootPart","Torso"}, false, "HumanoidRootPart", function(v) sheriffTargetPart = v end)

-- ============================================================
-- SILENT AIM (OVERRIDE REMOTE)
-- ============================================================
Window:AddDivider(TabSheriff, "Silent Aim")
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

Window:AddToggle(TabSheriff, "Enable Silent Aim", "Redirect bullets without moving camera", false, function(v)
    silentEnabled = v
    if v then setupSilentAim() end
end)
Window:AddDropdown(TabSheriff, "Silent Target", "Target", {"Murderer Only","All Players"}, false, "Murderer Only", function(v) silentTargetMode = v end)
Window:AddDropdown(TabSheriff, "Silent Part", "Bagian tubuh", {"Head","HumanoidRootPart","Torso"}, false, "Head", function(v) silentTargetPart = v end)
Window:AddSlider(TabSheriff, "Silent FOV", "30-400", 30, 400, 180, function(v) silentFOV = v end)
Window:AddSlider(TabSheriff, "Silent Max Dist", "50-500", 50, 500, 300, function(v) silentMaxDist = v end)
Window:AddToggle(TabSheriff, "Silent Prediction", "Aim ahead", true, function(v) silentPrediction = v end)
Window:AddSlider(TabSheriff, "Silent Pred Factor", "0-100", 0, 100, 15, function(v) silentPredFactor = v/100 end)
Window:AddToggle(TabSheriff, "Silent Vis Check", "Don't shoot through walls", true, function(v) silentVis = v end)
Window:AddToggle(TabSheriff, "Silent Auto Shoot", "Shoot automatically", false, function(v) silentAutoShoot = v end)
Window:AddSlider(TabSheriff, "Silent Auto Delay", "0.05-0.5s", 5, 50, 10, function(v) silentAutoDelay = v/100 end)

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
-- FUNGSI TARGET FILTER UNTUK SHERIFF
-- ============================================================
local function isSheriffTargetAllowed(player)
    local role = getRole(player)
    if sheriffTargetMode == "Murderer Only" and role == "Murderer" then return true end
    if sheriffTargetMode == "Innocent Only" and role == "Innocent" then return true end
    if sheriffTargetMode == "All Players" then return true end
    return false
end

local function getSheriffTargets()
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

        if not isSheriffTargetAllowed(player) then continue end

        local part = char:FindFirstChild(sheriffTargetPart) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if not part then continue end

        local targetPos = part.Position
        if sheriffPrediction then
            local vel = part.Velocity or Vector3.new()
            targetPos = targetPos + (vel * sheriffPredFactor)
        end

        local dist = (targetPos - myPos).Magnitude
        if dist > sheriffDistance then continue end

        if sheriffWall and not hasClearLOS(myPos, targetPos, myChar, char) then
            continue
        end

        table.insert(targets, {
            Player = player,
            Part = part,
            Position = targetPos,
            Distance = dist
        })
    end

    table.sort(targets, function(a, b) return a.Distance < b.Distance end)
    return targets
end

-- ============================================================
-- AIMBOT SHERIFF LOOP + AUTO SHOOT FIX
-- ============================================================
local function isShooting()
    return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or
           UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch)
end

RunService.RenderStepped:Connect(function(dt)
    if not sheriffAimbot then return end

    local myChar = LocalPlayer.Character
    if not myChar then return end

    local hasGun = false
    local gunTool = nil
    for _, tool in ipairs(myChar:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("gun") or name:find("revolver") or name:find("pistol") or name:find("sheriff") then
                hasGun = true
                gunTool = tool
                break
            end
        end
    end
    if not hasGun then return end

    local canAim = (sheriffTrigger == "Always") or (sheriffTrigger == "On Shoot" and isShooting())
    if not canAim then return end

    local targets = getSheriffTargets()
    if #targets == 0 then return end

    local target = targets[1]
    local targetPos = target.Position
    local currentCF = Camera.CFrame
    local targetCF = CFrame.new(currentCF.Position, targetPos)

    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if onScreen then
        local center = Camera.ViewportSize / 2
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist > sheriffFOV then return end
    else
        return
    end

    if sheriffSmooth < 1 then
        local lerpFactor = 1 - math.exp(-sheriffSmooth * dt * 5)
        Camera.CFrame = currentCF:Lerp(targetCF, lerpFactor)
    else
        Camera.CFrame = targetCF
    end

    if sheriffAutoShoot and target then
        local pos, on = Camera:WorldToViewportPoint(target.Position)
        if on then
            local center = Camera.ViewportSize / 2
            local crosshairDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            if crosshairDist < 40 and (tick() - lastAutoShootTime) > sheriffAutoDelay then
                lastAutoShootTime = tick()
                pcall(function()
                    local origin = CharacterRayOrigin(myChar)
                    if origin and target.Part then
                        local hitPart = target.Part
                        local targetPos2 = hitPart.Position
                        local shootRemote = getShootRemote()
                        if shootRemote then
                            shootRemote:FireServer(origin, targetPos2, hitPart, targetPos2)
                            if gunTool and gunTool:FindFirstChild("Fire") then
                                gunTool.Fire:Play()
                            end
                        else
                            local remote = ReplicatedStorage:FindFirstChild("ShootGun") or ReplicatedStorage:FindFirstChild("Shoot")
                            if remote then
                                remote:FireServer(origin, targetPos2, hitPart, targetPos2)
                            end
                        end
                    end
                end)
            end
        end
    end
end)

-- ============================================================
-- TAB MURDERER
-- ============================================================
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

-- ============================================================
-- FUNGSI TARGET FILTER UNTUK MURDERER
-- ============================================================
local function isMurdererTargetAllowed(player)
    local role = getRole(player)
    if murdererThrowTarget == "Sheriff Only" and role == "Sheriff" then return true end
    if murdererThrowTarget == "Innocent Only" and role == "Innocent" then return true end
    if murdererThrowTarget == "All Players" then return true end
    return false
end

local function getMurdererTargets()
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

        if not isMurdererTargetAllowed(player) then continue end

        local part = pChar:FindFirstChild("HumanoidRootPart") or pChar:FindFirstChild("Head")
        if not part then continue end

        local targetPos = part.Position
        if murdererThrowPred then
            local vel = part.Velocity or Vector3.new()
            targetPos = targetPos + (vel * murdererThrowPredFactor)
        end

        local dist = (targetPos - myPos).Magnitude
        if dist > murdererThrowDist then continue end

        if murdererThrowWall and not hasClearLOS(myPos, targetPos, char, pChar) then
            continue
        end

        table.insert(targets, { Character = pChar, Position = targetPos, Distance = dist })
    end

    table.sort(targets, function(a, b) return a.Distance < b.Distance end)
    return targets
end

-- ============================================================
-- MURDERER AUTO THROW + AUTO MELEE LOOP
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
    if throwRemote then
        throwRemote:FireServer(origin, direction)
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
                if hitRemote then
                    hitRemote:FireServer(raycastResult and raycastResult.Instance, raycastResult and raycastResult.Position)
                else
                    local remote = ReplicatedStorage:FindFirstChild("ThrowHit")
                    if remote then remote:FireServer(raycastResult and raycastResult.Instance, raycastResult and raycastResult.Position) end
                end
            end)
        end)
    else
        local hitRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ThrowHit")
        if hitRemote then
            hitRemote:FireServer(nil, targetPos)
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

        if not isMurderer(LocalPlayer) then
            task.wait(0.5)
            continue
        end

        if murdererAutoEquip then
            local hasKnife = false
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("blade")) then
                    hasKnife = true
                    break
                end
            end
            if not hasKnife then
                equipKnife()
                task.wait(0.2)
            end
        end

        if murdererMelee then
            local myRoot = char:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local myPos = myRoot.Position
                local closest = nil
                local closestDist = murdererMeleeRadius
                for _, player in ipairs(Players:GetPlayers()) do
                    if player == LocalPlayer then continue end
                    if not isMurdererTargetAllowed(player) then continue end
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

        if murdererThrow and (tick() - lastThrowTime) >= murdererThrowCD then
            local targets = getMurdererTargets()
            if #targets > 0 then
                local target = targets[1]
                throwKnifeAt(target.Character, target.Position)
            end
        end

        task.wait(0.1)
    end
end)

-- ============================================================
-- TAB VISUAL (ESP + LINE + FOV + HITBOX)
-- ============================================================
local TabVisual = Window:CreateTab("Visual")
Window:AddParagraph(TabVisual, "ESP & FOV", "Toggle visual")

-- ===== ESP =====
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
        if player and player.Parent then
            updateESPVisual(player)
        end
    end
end

Window:AddToggle(TabVisual, "Enable ESP", "Tampilkan nama + jarak + highlight", false, function(v)
    espEnabled = v
    refreshESP()
end)

-- ESP Implementation
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
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.new(1,1,1)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.new(0,0,0)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    distanceLabel.Parent = billboard

    espData[player] = {
        Highlight = highlight,
        Billboard = billboard
    }

    updateESPVisual(player)
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

-- Update jarak & role secara periodik
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

-- ===== LINE ESP =====
Window:AddDivider(TabVisual, "Line ESP")
local lineEnabled = false
local lineColor = Color3.fromRGB(0,255,255)
local lineThick = 1.5
local lineObjects = {}
local lineGui = Instance.new("ScreenGui")
lineGui.Name = "LineESP"
lineGui.Parent = CoreGui
lineGui.ResetOnSpawn = false
lineGui.IgnoreGuiInset = true

Window:AddToggle(TabVisual, "Enable Line ESP", "Draw tracers", false, function(v)
    lineEnabled = v
    if not v then clearLines() end
end)
Window:AddColorPicker(TabVisual, "Line Color", "", lineColor, function(c) lineColor = c end)
Window:AddSlider(TabVisual, "Line Thickness", "1-5", 1, 5, 1.5, function(v) lineThick = v end)

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
                        line.BackgroundColor3 = lineColor
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
                    line.Size = UDim2.new(0, length, 0, lineThick)
                    line.Rotation = math.deg(angle)
                    line.BackgroundColor3 = lineColor
                    line.Visible = true
                else
                    if lineObjects[player] then lineObjects[player].Visible = false end
                end
            end
        end
    end
end)

-- ===== FOV CIRCLE =====
Window:AddDivider(TabVisual, "FOV Circle")
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

Window:AddToggle(TabVisual, "Show FOV Circle", "Tampilkan lingkaran FOV", false, function(v)
    fovCircle.Visible = v
end)
Window:AddSlider(TabVisual, "FOV Radius", "30-400", 30, 400, 150, function(v)
    fovCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
end)

-- ===== HITBOX EXPANSION =====
Window:AddDivider(TabVisual, "Hitbox Expansion")
local hitboxEnabled = false
local hitboxSize = 15
local hitboxAlpha = 0.3
local hitboxTarget = "All"
local hitboxLoopRunning = false
local hitboxLoopStop = false
local originalSizes = {}

Window:AddToggle(TabVisual, "Enable Hitbox Expansion", "Perbesar hitbox musuh", false, function(v)
    hitboxEnabled = v
    if v then startHitboxLoop() else stopHitboxLoop() end
end)
Window:AddDropdown(TabVisual, "Target Parts", "Pilih bagian tubuh", {"All","Head","Torso","Legs"}, false, "All", function(v)
    hitboxTarget = v
    if hitboxEnabled then
        stopHitboxLoop()
        task.wait(0.2)
        startHitboxLoop()
    end
end)
Window:AddSlider(TabVisual, "Hitbox Size", "1-30", 1, 30, 15, function(v) hitboxSize = v end)
Window:AddSlider(TabVisual, "Hitbox Alpha", "0-10", 0, 10, 3, function(v) hitboxAlpha = v/10 end)
Window:AddButton(TabVisual, "Reset Hitbox", "Kembalikan ukuran asli", function()
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
    Window:Notify({ Title = "Hitbox Reset", Description = "Hitbox dikembalikan ke default", Color = Color3.fromRGB(255,255,0), Delay = 2 })
end)

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
-- TAB PLAYER (NO RECOIL, NO SPREAD, ANTI RAGDOLL)
-- ============================================================
local TabPlayer = Window:CreateTab("Player")
Window:AddParagraph(TabPlayer, "Player Mods", "No recoil, no spread, anti-ragdoll")
local noRecoil = false
local noSpread = false
local antiRagdoll = false
Window:AddToggle(TabPlayer, "No Recoil", "Remove shake", false, function(v) noRecoil = v end)
Window:AddToggle(TabPlayer, "No Spread", "Perfect accuracy", false, function(v) noSpread = v end)
Window:AddToggle(TabPlayer, "Anti Ragdoll", "Prevent falling", false, function(v) antiRagdoll = v end)

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
-- REDUCE MAP
-- ============================================================
local reduceMap = false
Window:AddToggle(TabPlayer, "Reduce Map", "Disable minimap", false, function(v)
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
end)

-- ============================================================
-- FINISH
-- ============================================================
Window:Notify({
    Title = "W424HUB",
    Description = "Semua fitur siap!",
    Content = "Aimbot | Silent Aim | ESP | Hitbox | Auto Tools",
    Color = Color3.fromRGB(0, 255, 255),
    Delay = 5
})

print("✅ W424HUB STABLE PLUS loaded – All features ready!")