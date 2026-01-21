-- Repo principal
local repo = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = " И Ξ Ｘ | FREE",
    Icon = 126669385928299,
    Footer = "Versión: 2.5 ¡Beta! | FREEMIUM SCRIPT",
    AutoShow = true,
    ShowCustomCursor = false,
    NotifySide = "Right"
})

local Tabs = {
    Combat = Window:AddTab("Combat", "crosshair"),
    Settings = Window:AddTab("Settings", "settings")
}

-- ==================== VARIABLES GLOBALES ====================
getgenv().AimPart = "Head"
getgenv().OldAimPart = "HumanoidRootPart"
getgenv().AimlockKey = "V"
getgenv().AimRadius = 150
getgenv().TeamCheck = false
getgenv().FriendsCheck = false
getgenv().AliveCheck = true
getgenv().PredictMovement = true
getgenv().PredictionVelocity = 0.14
getgenv().CheckIfJumped = false
getgenv().Smoothness = 0.27

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local AimlockEnabled = false
local Aiming = false
local LockedTarget = nil

local FriendsList = {}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = getgenv().AimRadius
FOVCircle.Filled = false
FOVCircle.Transparency = 0.85
FOVCircle.Color = Color3.fromRGB(255, 20, 100)
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = getgenv().AimRadius
end)

-- ==================== GET NEAREST TARGET ====================
local function GetNearestTarget()
    local closest = nil
    local shortest = getgenv().AimRadius + 1

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end

        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if getgenv().AliveCheck and (not hum or hum.Health <= 0) then continue end
        if getgenv().TeamCheck and player.Team == LocalPlayer.Team then continue end
        if getgenv().FriendsCheck and table.find(FriendsList, player.Name) then continue end

        local part = player.Character:FindFirstChild(getgenv().AimPart) or player.Character:FindFirstChild("Head")
        if not part then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y + 36)).Magnitude
        if dist < shortest then
            shortest = dist
            closest = player
        end
    end

    return closest
end

-- ==================== TECLA AIMLOCK ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    local keyPressed = input.KeyCode.Name
    if keyPressed == getgenv().AimlockKey and AimlockEnabled then
        Aiming = not Aiming
        if Aiming then
            LockedTarget = GetNearestTarget()
        else
            LockedTarget = nil
        end
    end
end)

-- ==================== LOOP PRINCIPAL ====================
RunService.RenderStepped:Connect(function()
    if not AimlockEnabled or not Aiming then return end

    if not LockedTarget or not LockedTarget.Character or not LockedTarget.Character:FindFirstChild(getgenv().AimPart) then
        LockedTarget = GetNearestTarget()
        if not LockedTarget then return end
    end

    local targetPart = LockedTarget.Character:FindFirstChild(getgenv().AimPart) or LockedTarget.Character.Head
    if not targetPart then return end

    local targetPos = targetPart.Position

    if getgenv().PredictMovement then
        local velocity = targetPart.AssemblyLinearVelocity or targetPart.Velocity
        targetPos = targetPos + velocity * getgenv().PredictionVelocity
    end

    -- Airshot
    if getgenv().CheckIfJumped and LockedTarget.Character:FindFirstChild("Humanoid") then
        local state = LockedTarget.Character.Humanoid:GetState()
        if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
            getgenv().AimPart = "RightFoot"
        else
            getgenv().AimPart = getgenv().OldAimPart
        end
    end

    -- Smoothness
    if getgenv().Smoothness > 0 then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), getgenv().Smoothness)
    else
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    end
end)

-- ==================== UI COMBAT ====================
local CombatBox = Tabs.Combat:AddLeftGroupbox("Aim Assistent", "crosshair")

CombatBox:AddToggle("AimlockEnabled", {
    Text = "Aimlock",
    Default = false,
    Callback = function(state)
        AimlockEnabled = state
        if not state then
            Aiming = false
            LockedTarget = nil
        end
    end
}):AddKeyPicker("AimlockKeyPicker", {
    Default = "V",
    Mode = "Toggle",
    Text = "Tecla Aimlock",
    ChangedCallback = function(key)  -- ← IMPORTANTE: ChangedCallback
        getgenv().AimlockKey = key
    end
})

CombatBox:AddDropdown("AimPart", {
    Values = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "RightFoot"},
    Default = 1,
    Text = "BodyPart",
    Callback = function(v)
        getgenv().AimPart = v
        getgenv().OldAimPart = v
    end
})
CombatBox:AddToggle("TeamCheck", {Text = "Team Check", Default = false, Callback = function(v) getgenv().TeamCheck = v end})
CombatBox:AddToggle("FriendsCheck", {Text = "Ignore Friends", Default = false, Callback = function(v) getgenv().FriendsCheck = v end})
CombatBox:AddToggle("AliveCheck", {Text = "Alive Check", Default = true, Callback = function(v) getgenv().AliveCheck = v end})
CombatBox:AddToggle("Prediction", {Text = "Prediction", Default = true, Callback = function(v) getgenv().PredictMovement = v end})
CombatBox:AddToggle("Airshot", {Text = "Airshot Function", Default = false, Callback = function(v) getgenv().CheckIfJumped = v end})
CombatBox:AddSlider("Smoothness", {Text = "Smoothness", Min = 0, Max = 1, Default = 0.27, Rounding = 3, Callback = function(v) getgenv().Smoothness = v end})
CombatBox:AddSlider("PredictionVel", {Text = "Prediction Movement", Min = 0.05, Max = 0.3, Default = 0.14, Rounding = 3, Callback = function(v) getgenv().PredictionVelocity = v end})
CombatBox:AddSlider("AimRadius", {Text = "FOV Radius", Min = 30, Max = 400, Default = 150, Rounding = 0, Callback = function(v) getgenv().AimRadius = v end})

-- ==================== FRIENDS LIST ====================
local FriendsGroup = Tabs.Combat:AddRightGroupbox("Friends List (Ignore)", "users")
local PlayerDropdown = FriendsGroup:AddDropdown("SelectPlayer", {
    Text = "Select Player",
    Values = {"Ninguno"},
    Default = 1
})

local function UpdatePlayerList()
    local list = {}
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    table.sort(list)
    PlayerDropdown:SetValues(#list > 0 and list or {"No hay jugadores"})
end

spawn(function()
    while wait(0.5) do
        UpdatePlayerList()
    end
end)
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()

FriendsGroup:AddButton("Add to Friends", function()
    local selected = PlayerDropdown.Value
    if not selected or selected == "Cargando..." or selected == "No hay jugadores" then
        Library:Notify("Selecciona un jugador válido", 3)
        return
    end
    if not table.find(FriendsList, selected) then
        table.insert(FriendsList, selected)
        Library:Notify("Añadido: " .. selected, 4)
    else
        Library:Notify("Ya está en la lista", 3)
    end
end)

FriendsGroup:AddButton("Clear List", function()
    FriendsList = {}
    Library:Notify("Lista limpiada", 4)
end)

-- ==================== FOV UI ====================
local FOVBox = Tabs.Combat:AddRightGroupbox("FOV", "circle")
FOVBox:AddToggle("ShowFOV", {Text = "Show FOV Circle", Default = false, Callback = function(v) FOVCircle.Visible = v end})
FOVBox:AddLabel("FOV Color"):AddColorPicker("FOVColor", {
    Default = Color3.fromRGB(255, 20, 100),
    Callback = function(color)
        FOVCircle.Color = color
    end
})

-- ==================== SETTINGS (ADDONS) ====================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("NyxExotic")
ThemeManager:SetFolder("NyxExotic")
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Tabs.Settings:AddLeftGroupbox("Menu"):AddToggle("CustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(v) Library.ShowCustomCursor = v end
})

Tabs.Settings:AddLeftGroupbox("Menu"):AddLabel("Menu Bind: M (Fixed)")
Tabs.Settings:AddLeftGroupbox("Menu"):AddButton("Unload", function() Library:Unload() end)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.M then
        Library:Toggle()
    end
end)

Library:Notify("Nyx Exotic cargado correctamente", 5)
SaveManager:LoadAutoloadConfig()
