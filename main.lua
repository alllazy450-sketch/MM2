-- ============================================================
-- W424 HUB | MM2 ULTIMATE PRO v4.5
-- UI Framework: Oxidelib (Theme: Midnight)
-- Integrated: Bullet TP, Kill All, Gun TP, Fixes
-- ============================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Naellx/Oxidelib/main/Oxidelib.lua"))()
-- Tema diganti ke Midnight (Hitam/Gelap)
Library:SetTheme("Midnight")

local MY_LOGO = "rbxassetid://70773874533764"

-- [ SERVICES ]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- [ STATE & SETTINGS ]
local Toggles = {
    SheriffSilent = false, SheriffAutoShoot = false, GunDropTP = false,
    MurdThrow = false, MurdKillAll = false, MurdMelee = false,
    HitboxExp = false, ESP_Enabled = false, Noclip = false, Invisible = false
}
local Settings = {
    HitboxSize = 2, SheriffFOV = 150, MurdRadius = 15, ThrowDelay = 1
}

-- [ FUNCTIONS ]
local function getRole(player)
    if not player or not player.Character then return "Innocent" end
    local knife = player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife")
    local gun = player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun")
    if knife then return "Murderer" end
    if gun then return "Sheriff" end
    return "Innocent"
end

local function getMurderer()
    for _, plr in pairs(Players:GetPlayers()) do
        if getRole(plr) == "Murderer" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            return plr.Character
        end
    end
    return nil
end

-- ============================================================
-- UI SETUP (MIDNIGHT THEME)
-- ============================================================
local Window = Library:CreateWindow({
    Name = "W424 HUB",
    BrandSubtitle = "Murder Mystery 2 PRO v4.5",
    Logo = MY_LOGO,
    LogoZoom = 1.5,
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(720, 550),
})

local TabSheriff = Window:AddTab({ Name = "Sheriff", Icon = "target" })
local TabMurd    = Window:AddTab({ Name = "Murderer", Icon = "skull" })
local TabMisc    = Window:AddTab({ Name = "Innocent/Misc", Icon = "user" })
local TabVis     = Window:AddTab({ Name = "Visuals", Icon = "eye" })

-- ===== SHERIFF TAB =====
local SubSheriff = TabSheriff:AddSubTab("Gun Mods")
SubSheriff:AddSection("SILENT AIM / BULLET TP")
SubSheriff:AddToggle({ 
    Name = "Silent Aim (Bullet TP)", 
    Default = false, 
    Callback = function(v) Toggles.SheriffSilent = v end 
})
SubSheriff:AddToggle({ 
    Name = "Auto Shoot Murderer", 
    Default = false, 
    Callback = function(v) Toggles.SheriffAutoShoot = v end 
})
SubSheriff:AddToggle({ 
    Name = "Auto TP Gun Drop", 
    Default = false, 
    Callback = function(v) Toggles.GunDropTP = v end 
})

-- ===== MURDERER TAB =====
local SubMurd = TabMurd:AddSubTab("Knife Mods")
SubMurd:AddSection("RAGE FEATURES")
SubMurd:AddButton({ 
    Name = "KILL ALL PLAYERS", 
    Callback = function()
        local knife = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")
        if knife and knife:FindFirstChild("Events") then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    knife.Events.HandleTouched:FireServer(v.Character.HumanoidRootPart)
                end
            end
            Library:Notify({ Title = "Murderer", Content = "Kill All Executed", Type = "success" })
        else
            Library:Notify({ Title = "Error", Content = "Hold your knife!", Type = "error" })
        end
    end 
})
SubMurd:AddToggle({ Name = "Auto Throw Knife", Default = false, Callback = function(v) Toggles.MurdThrow = v end })

SubMurd:AddSection("HITBOX EXPANSION")
SubMurd:AddToggle({ Name = "Expand Hitbox", Default = false, Callback = function(v) Toggles.HitboxExp = v end })
SubMurd:AddSlider({ Name = "Hitbox Size", Min = 2, Max = 20, Default = 2, Callback = function(v) Settings.HitboxSize = v end })

-- ===== MISC TAB =====
local SubMisc = TabMisc:AddSubTab("Character")
SubMisc:AddToggle({ 
    Name = "Noclip (Walk Thru Walls)", 
    Default = false, 
    Callback = function(v) Toggles.Noclip = v end 
})
SubMisc:AddToggle({ 
    Name = "Improved Invisibility", 
    Default = false, 
    Callback = function(v) 
        Toggles.Invisible = v 
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = v and 0.5 or 0 -- Kamu tetap bisa lihat dirimu sendiri sedikit
                end
            end
        end
    end 
})

-- ============================================================
-- CORE ENGINE LOGIC
-- ============================================================

-- 1. Noclip Implementation
RunService.Stepped:Connect(function()
    if Toggles.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 2. Gun Drop TP Implementation
Workspace.ChildAdded:Connect(function(child)
    if Toggles.GunDropTP and child.Name == "GunDrop" then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = child.CFrame + Vector3.new(0, 2, 0)
            Library:Notify({ Title = "Gun Dropped!", Content = "Teleported to Gun", Type = "success" })
        end
    end
end)

-- 3. Bullet TP (Silent Aim Hook)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Toggles.SheriffSilent and self.Name == "ShootGun" and method == "FireServer" then
        local target = getMurderer()
        if target and target:FindFirstChild("HumanoidRootPart") then
            args[1] = target.HumanoidRootPart.Position
            args[2] = target.HumanoidRootPart.Position
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- 4. Auto Shoot Loop
task.spawn(function()
    while task.wait(0.2) do
        if Toggles.SheriffAutoShoot and getRole(LocalPlayer) == "Sheriff" then
            local target = getMurderer()
            if target and target:FindFirstChild("HumanoidRootPart") then
                local remote = ReplicatedStorage:FindFirstChild("ShootGun", true)
                if remote then
                    remote:FireServer(target.HumanoidRootPart.Position, target.HumanoidRootPart.Position)
                end
            end
        end
    end
end)

-- 5. Hitbox Expansion Loop
task.spawn(function()
    while task.wait(1) do
        if Toggles.HitboxExp then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = plr.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                end
            end
        end
    end
end)

-- ============================================================
-- VISUALS (Migrated)
-- ============================================================
local SubESP = TabVis:AddSubTab("Visual ESP")
SubESP:AddToggle({ Name = "Enable Highlights", Default = false, Callback = function(v) Toggles.ESP_Enabled = v end })

RunService.RenderStepped:Connect(function()
    if Toggles.ESP_Enabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hl = plr.Character:FindFirstChildOfClass("Highlight") or Instance.new("Highlight", plr.Character)
                local role = getRole(plr)
                hl.FillColor = (role == "Murderer" and Color3.new(1,0,0)) or (role == "Sheriff" and Color3.new(0,0,1)) or Color3.new(0,1,0)
                hl.Enabled = true
            end
        end
    end
end)

Window:Notify({ Title = "W424 HUB", Content = "PRO v4.5 Loaded (Midnight)", Type = "success" })
