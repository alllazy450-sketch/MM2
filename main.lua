-- ============================================
-- W424HUB – SILENT AIM (MM2 ADAPTATION)
-- ============================================
print("=== LOADING SILENT AIM ===")

-- Pastikan Kairo UI sudah di-load (jika dijalankan terpisah)
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
-- WINDOW KAIRO (Jika belum ada)
-- ============================================
-- Jika script ini digabung dengan W424HUB, gunakan Window yang sudah ada.
-- Jika standalone, buat window baru.
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
    Content = "Silent Aim + Aimbot + Auto Tools",
    Color = Color3.fromRGB(0, 200, 50),
    Delay = 3
})

-- ============================================
-- SILENT AIM SETTINGS
-- ============================================
local SilentAim = {
    Enabled = false,
    TargetMode = "Murderer Only",  -- "Murderer Only" / "All Players"
    TargetPart = "Head",           -- "Head" / "HumanoidRootPart" / "Torso"
    FOV = 180,
    MaxDistance = 300,
    Prediction = true,
    PredictionFactor = 0.15,
    VisibilityCheck = true,
    AutoShoot = false,
    AutoShootDelay = 0.1,
}

local LastSilentShot = 0
local SilentTarget = nil
local CachedShootRemote = nil

-- ============================================
-- TAB: AIM (Tambahkan Silent Aim di sini)
-- ============================================
local TabAim = Window:CreateTab("Aim")
Window:AddParagraph(TabAim, "Silent Aim", "Arahkan peluru ke target tanpa gerakkan kamera")

Window:AddToggle(TabAim, "Enable Silent Aim", "Aktifkan Silent Aim (khusus Sheriff)", false, function(v)
    SilentAim.Enabled = v
end, "SilentAimToggle")

Window:AddDropdown(TabAim, "Target Mode", "Siapa yang di-aim", {"Murderer Only","All Players"}, false, "Murderer Only", function(v)
    SilentAim.TargetMode = v
end, "SilentTargetMode")

Window:AddDropdown(TabAim, "Target Part", "Bagian tubuh target", {"Head","HumanoidRootPart","Torso"}, false, "Head", function(v)
    SilentAim.TargetPart = v
end, "SilentTargetPart")

Window:AddSlider(TabAim, "FOV Radius", "30-400", 30, 400, 180, function(v)
    SilentAim.FOV = v
end, "SilentFOV", true)

Window:AddSlider(TabAim, "Max Distance", "50-500", 50, 500, 300, function(v)
    SilentAim.MaxDistance = v
end, "SilentMaxDist", true)

Window:AddToggle(TabAim, "Prediction", "Aim ke depan gerakan target", true, function(v)
    SilentAim.Prediction = v
end, "SilentPredict")

Window:AddSlider(TabAim, "Pred Factor", "0-100", 0, 100, 15, function(v)
    SilentAim.PredictionFactor = v / 100
end, "SilentPredFactor", true)

Window:AddToggle(TabAim, "Visibility Check", "Tidak menembus tembok", true, function(v)
    SilentAim.VisibilityCheck = v
end, "SilentVis")

Window:AddToggle(TabAim, "Auto Shoot", "Tembak otomatis", false, function(v)
    SilentAim.AutoShoot = v
end, "SilentAutoShoot")

Window:AddSlider(TabAim, "Auto Shoot Delay", "0.05-0.5s", 5, 50, 10, function(v)
    SilentAim.AutoShootDelay = v / 100
end, "SilentAutoDelay", true)

-- ============================================
-- FUNGSI GET ROLE (Sama seperti sebelumnya)
-- ============================================
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

-- ============================================
-- VISIBILITY CHECK
-- ============================================
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function IsVisible(targetPart)
    if not SilentAim.VisibilityCheck then return true end
    local localChar = LocalPlayer.Character
    if not localChar then return false end
    local rootPart = localChar:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    rayParams.FilterDescendantsInstances = {localChar}
    local result = workspace:Raycast(rootPart.Position, targetPart.Position - rootPart.Position, rayParams)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

-- ============================================
-- GET CLOSEST SILENT TARGET
-- ============================================
local function GetClosestSilentTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local center = Camera.ViewportSize / 2
    local closest = nil
    local closestDist = SilentAim.FOV
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

        -- Filter target mode
        local role = getRole(player)
        if SilentAim.TargetMode == "Murderer Only" and role ~= "Murderer" then continue end

        local part = char:FindFirstChild(SilentAim.TargetPart) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
        if not part then continue end

        local targetPos = part.Position
        if SilentAim.Prediction then
            local vel = part.Velocity or Vector3.new()
            targetPos = targetPos + (vel * SilentAim.PredictionFactor)
        end

        local dist = (targetPos - myPos).Magnitude
        if dist > SilentAim.MaxDistance then continue end

        if not IsVisible(part) then continue end

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

-- ============================================
-- HOOK SHOOT REMOTE (SILENT AIM)
-- ============================================
local function GetShootRemote()
    if CachedShootRemote and CachedShootRemote.Parent then
        return CachedShootRemote
    end
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ShootGun")
    if remote then
        CachedShootRemote = remote
        return remote
    end
    remote = ReplicatedStorage:FindFirstChild("ShootGun")
    if remote then
        CachedShootRemote = remote
        return remote
    end
    return nil
end

-- Hook menggunakan __namecall (metode yang sudah dipakai di W424HUB)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and SilentAim.Enabled then
        local remote = GetShootRemote()
        if self == remote then
            local args = {...}
            -- Cek apakah player memegang gun (Sheriff)
            local myChar = LocalPlayer.Character
            if myChar then
                local hasGun = false
                for _, tool in ipairs(myChar:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("gun") or tool.Name:lower():find("revolver") or tool.Name:lower():find("pistol") or tool.Name:lower():find("sheriff")) then
                        hasGun = true
                        break
                    end
                end
                if hasGun then
                    local targetPart = GetClosestSilentTarget()
                    if targetPart then
                        -- Ubah arah tembakan ke target
                        -- Format args: (origin, targetPos, hitPart, targetPos2)
                        if #args >= 4 then
                            local origin = args[1]
                            if origin and typeof(origin) == "Vector3" then
                                local newTargetPos = targetPart.Position
                                args[2] = newTargetPos
                                args[3] = targetPart
                                args[4] = newTargetPos
                                -- Jika auto shoot aktif, kita tembak otomatis (tapi di sini kita hanya modifikasi parameter)
                                -- Auto shoot di-handle di loop terpisah
                            end
                        end
                        return oldNamecall(self, unpack(args))
                    end
                end
            end
        end
    end
    return oldNamecall(self, ...)
end))

-- ============================================
-- AUTO SHOOT (Jika diaktifkan)
-- ============================================
RunService.RenderStepped:Connect(function(dt)
    if not SilentAim.Enabled or not SilentAim.AutoShoot then return end

    local now = tick()
    if now - LastSilentShot < SilentAim.AutoShootDelay then return end

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

    -- Cek FOV
    local center = Camera.ViewportSize / 2
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if onScreen then
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist > SilentAim.FOV then return end
    else
        return
    end

    -- Kirim tembakan
    local remote = GetShootRemote()
    if remote then
        local origin = Camera.CFrame.Position
        local targetPos = targetPart.Position
        pcall(function()
            remote:FireServer(origin, targetPos, targetPart, targetPos)
            -- Mainkan suara tembakan
            local tool = myChar:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Fire") then
                tool.Fire:Play()
            end
            LastSilentShot = tick()
        end)
    end
end)

-- ============================================
-- CLEANUP
-- ============================================
task.spawn(function()
    while task.wait(1) do
        if not getgenv().QUANTUM_RUNNING and not SilentAim.Enabled then
            -- Hapus hook jika tidak digunakan (optional)
        end
    end
end)

print("✅ Silent Aim adaptasi untuk MM2 berhasil dimuat!")