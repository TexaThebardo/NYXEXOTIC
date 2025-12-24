-- Repo principal (para Library.lua)
local repo = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/"

-- Cargar Library
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

-- Cargar addons directamente desde la raíz (NO en /addons/)
local ThemeManager = loadstring(game:HttpGet(repo .. "ThemeManagerV2.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "SaveManager.lua"))()


local Window = Library:CreateWindow({
    Title = " И  Ξ Ｘ | PRM",
    Icon = 87256533253057,
    Footer = "Versión: 2.5 ¡Beta! | PREMIUM SCRIPT",
    AutoShow = true,
    ShowCustomCursor = false,
    NotifySide = "Right"
})

local Tabs = {
    Combat    = Window:AddTab("Combat", "crosshair"),
    Visuals   = Window:AddTab("Visuals", "eye"),
    Player    = Window:AddTab("Player", "user"),
    ["Auto Farm"] = Window:AddTab("Auto Farm", "zap"),
    Settings  = Window:AddTab("Settings", "settings")
}

local ExploitsBox = Tabs.Player:AddRightGroupbox("Utilities (Mobile)", "phone")
local AutoFarmBox = Tabs["Auto Farm"]:AddLeftGroupbox("Auto Farm", "bot")

-- ============== TUTORIAL ==============
AutoFarmBox:AddLabel("<font color='rgb(230, 163, 33)'><b>Marshmellow Farm Tutorial</b></font>", true)
AutoFarmBox:AddLabel("<b>Required Tools:</b>", true)
AutoFarmBox:AddLabel("• You must have at least <b>2 out of these 3 tools</b>:", true)
AutoFarmBox:AddLabel("   - Water", true)
AutoFarmBox:AddLabel("   - Sugar Block Bag", true)
AutoFarmBox:AddLabel("   - Gelatin", true)
AutoFarmBox:AddLabel("• If 2 or more essential tools are missing → the farm will stop automatically.", true)
AutoFarmBox:AddDivider()

AutoFarmBox:AddLabel("<font color='rgb(230, 163, 33)'><b>Extra Info</b></font>", true)
AutoFarmBox:AddLabel("• Press <b>P</b> or the toggle to turn on/off at any time.", true)
AutoFarmBox:AddLabel("• Stay close to the interaction spot for perfect performance.", true)
AutoFarmBox:AddLabel("• If you die or respawn, the farm resumes automatically.", true)
AutoFarmBox:AddDivider()

getgenv().AutoMarshEnabled = false

-- Wait time AFTER using E
local ToolWaitTimes = {
    ["Water"] = 20,
    ["Sugar Block Bag"] = 0,
    ["Gelatin"] = 45,
    ["Empty Bag"] = 0
}

-- Essential tools for auto-stop
local EssentialTools = {"Water", "Sugar Block Bag", "Gelatin"}

local MainToggleRef

local function CountMissingEssential()
    local player = game.Players.LocalPlayer
    local backpack = player.Backpack
    local character = player.Character or {}
    local missing = 0

    for _, name in ipairs(EssentialTools) do
        local found = false
        for _, tool in backpack:GetChildren() do
            if tool:IsA("Tool") and string.find(string.lower(tool.Name), string.lower(name)) then
                found = true
                break
            end
        end
        if not found then
            for _, tool in character:GetChildren() do
                if tool:IsA("Tool") and string.find(string.lower(tool.Name), string.lower(name)) then
                    found = true
                    break
                end
            end
        end
        if not found then missing = missing + 1 end
    end
    return missing
end

local function EquipToolByName(toolName)
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return false end

    for _, tool in player.Backpack:GetChildren() do
        if tool:IsA("Tool") and string.find(string.lower(tool.Name), string.lower(toolName)) then
            player.Character.Humanoid:EquipTool(tool)
            return true
        end
    end
    return false
end

local function PressE()
    local VIM = game:GetService("VirtualInputManager")
    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.06 + math.random(1,5)/100)
    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function StartAutoMarsh()
    if getgenv().AutoMarshEnabled then return end
    getgenv().AutoMarshEnabled = true
    Library:Notify("Auto Marshmallow → ON", 5)

    task.spawn(function()
        local player = game.Players.LocalPlayer
        local ToolOrder = {"Water", "Sugar Block Bag", "Gelatin", "Empty Bag"}

        while getgenv().AutoMarshEnabled do
            local missing = CountMissingEssential()
            if missing >= 2 then
                getgenv().AutoMarshEnabled = false
                Library:Notify("🛑 Auto Farm OFF - Missing " .. missing .. "/3 essential tools", 6)
                if MainToggleRef then MainToggleRef:SetValue(false) end
                return
            end

            for _, toolName in ipairs(ToolOrder) do
                if not getgenv().AutoMarshEnabled then break end

                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    player.CharacterAdded:Wait()
                    task.wait(3)
                end

                local equipped = EquipToolByName(toolName)

                if equipped then
                    task.wait(0.5)  -- Delay to register equip

                    PressE()
                    task.wait(0.1)

                    -- Main wait
                    local waitTime = ToolWaitTimes[toolName] or 0
                    if waitTime > 0 then
                        Library:Notify("⏳ Starting: " .. toolName .. " (" .. waitTime .. "s)", 2)
                        for i = waitTime, 1, -1 do
                            if not getgenv().AutoMarshEnabled then break end
                            Library:Notify("⏳ " .. toolName .. ": " .. i .. "s remaining", 1)
                            task.wait(1)
                        end
                        Library:Notify("✅ " .. toolName .. " completed", 2)
                    end

                    -- EXTRA WAIT ONLY FOR SUGAR BLOCK BAG (cooldown/change)
                    if toolName == "Sugar Block Bag" then
                        task.wait(0.5)  -- Additional wait after using Sugar
                    end
                end
            end
        end
    end)
end

local function StopAutoMarsh()
    if not getgenv().AutoMarshEnabled then return end
    getgenv().AutoMarshEnabled = false
    Library:Notify("Auto Marshmallow → OFF", 3)
end

MainToggleRef = AutoFarmBox:AddToggle("AutoMarsh", {
    Text = "Marshmallow Auto Farm",
    Default = false,
    Tooltip = "Perfect flow with custom waits",
    Callback = function(state)
        if state then
            StartAutoMarsh()
        else
            StopAutoMarsh()
        end
    end
}):AddKeyPicker("AutoMarshKeybind", {
    Default = "P",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Keybind (P)",
    Tooltip = "Press P to toggle on/off"
})

AutoFarmBox:AddDivider()

local AlarmBox = Tabs["Auto Farm"]:AddRightGroupbox("Player Alarm", "alarm-clock")

AlarmBox:AddDivider()
AlarmBox:AddLabel("<font color='rgb(230, 163, 33)'><b>Information</b></font>")
AlarmBox:AddLabel("Player Alarm detects nearby players")
AlarmBox:AddLabel("and plays a sound + optional notification.")
AlarmBox:AddLabel("Useful for avoiding surprise attacks.")

-- ============== IMPROVED PLAYER ALARM WITH CUSTOM SOUNDS & NOTIFICATIONS ==============
getgenv().PlayerAlarm_Enabled = false
getgenv().PlayerAlarm_Radius = 15
getgenv().PlayerAlarm_SoundId = "rbxassetid://146404205"  -- Default sound (Basic Alarm)
getgenv().PlayerAlarm_Notify = true  -- Notifications enabled by default
getgenv().AlarmConnection = nil
getgenv().AlarmSounds = {}        -- [userId] = sound instance
getgenv().AlarmNotified = {}      -- [userId] = true (anti-spam)

-- 20 alarm sounds (10 original + 10 new)
local AlarmSoundsList = {
    {Name = "Basic Alarm (Default)", Id = "rbxassetid://146404205"},
    {Name = "Fire Alarm", Id = "rbxassetid://497153454"},
    {Name = "Loud Fire Alarm", Id = "rbxassetid://429406046"},
    {Name = "Purge Siren", Id = "rbxassetid://7491350345"},
    {Name = "Simple Beep Alarm", Id = "rbxassetid://9081144733"},
    {Name = "Classic Siren", Id = "rbxassetid://200057767"},
    {Name = "Emergency Siren", Id = "rbxassetid://7142904082"},
    {Name = "Warning Beep", Id = "rbxassetid://147190665"},
    {Name = "Alert Tone", Id = "rbxassetid://535870681"},
    {Name = "Intruder Alert", Id = "rbxassetid://1846368080"},
    
    -- 10 NEW SOUNDS
    {Name = "Police Siren", Id = "rbxassetid://276720840"},
    {Name = "Air Raid Siren", Id = "rbxassetid://1835347026"},
    {Name = "Red Alert (Star Trek)", Id = "rbxassetid://9119699174"},
    {Name = "Nuclear Alarm", Id = "rbxassetid://1837838612"},
    {Name = "High Pitch Alarm", Id = "rbxassetid://1837838739"},
    {Name = "Factory Alarm", Id = "rbxassetid://1837841765"},
    {Name = "Ship Horn Alarm", Id = "rbxassetid://9115982904"},
    {Name = "Car Alarm", Id = "rbxassetid://276709942"},
    {Name = "Sci-Fi Alarm", Id = "rbxassetid://9119699418"},
    {Name = "Intense Beep Loop", Id = "rbxassetid://1839246711"}
}

-- Prepare dropdown values (only names)
local soundNames = {}
for _, sound in ipairs(AlarmSoundsList) do
    table.insert(soundNames, sound.Name)
end

AlarmBox:AddDivider()

AlarmBox:AddToggle("PlayerAlarm", {
    Text = "Player Alarm",
    Default = false,
    Tooltip = "Enable/disable the proximity alarm system",
    Callback = function(state)
        getgenv().PlayerAlarm_Enabled = state

        -- DISABLE
        if not state then
            if getgenv().AlarmConnection then
                getgenv().AlarmConnection:Disconnect()
                getgenv().AlarmConnection = nil
            end
            for _, sound in pairs(getgenv().AlarmSounds) do
                if sound and sound.Parent then
                    sound:Stop()
                    sound:Destroy()
                end
            end
            getgenv().AlarmSounds = {}
            getgenv().AlarmNotified = {}
            Library:Notify("Player Alarm OFF", 3)
            return
        end

        -- ENABLE
        Library:Notify("Player Alarm ON", 3)

        getgenv().AlarmConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not getgenv().PlayerAlarm_Enabled then return end

            local lp = game.Players.LocalPlayer
            if not lp.Character or not lp.Character:FindFirstChild("Head") then return end

            local myHead = lp.Character.Head

            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local root = plr.Character.HumanoidRootPart
                    local dist = (myHead.Position - root.Position).Magnitude
                    local uid = plr.UserId
                    local displayName = plr.DisplayName

                    if dist <= getgenv().PlayerAlarm_Radius then
                        -- Play selected sound
                        if not getgenv().AlarmSounds[uid] then
                            local head = plr.Character:FindFirstChild("Head") or root
                            local sound = Instance.new("Sound")
                            sound.SoundId = getgenv().PlayerAlarm_SoundId
                            sound.Volume = 2
                            sound.Looped = true
                            sound.Parent = head
                            sound:Play()
                            getgenv().AlarmSounds[uid] = sound
                        end

                        -- Notification (if enabled and first detection)
                        if getgenv().PlayerAlarm_Notify and not getgenv().AlarmNotified[uid] then
                            getgenv().AlarmNotified[uid] = true
                            local meters = math.floor(dist)
                            Library:Notify(string.format("⚠️ %s is approaching (%d studs)", displayName, meters), 4)
                        end
                    else
                        -- Player left radius
                        if getgenv().AlarmSounds[uid] then
                            getgenv().AlarmSounds[uid]:Stop()
                            getgenv().AlarmSounds[uid]:Destroy()
                            getgenv().AlarmSounds[uid] = nil
                        end
                        getgenv().AlarmNotified[uid] = nil
                    end
                end
            end
        end)
    end
})

AlarmBox:AddSlider("AlarmRadius", {
    Text = "Alarm Radius",
    Min = 0,
    Max = 100,
    Default = 0,
    Rounding = 1,
    Callback = function(v)
        getgenv().PlayerAlarm_Radius = v
        Library:Notify("Alarm Radius: " .. v .. " studs", 2)
    end
})

AlarmBox:AddDivider()

AlarmBox:AddToggle("AlarmNotify", {
    Text = "Enable Notifications",
    Default = false,
    Tooltip = "Show a notification when a player enters the radius",
    Callback = function(state)
        getgenv().PlayerAlarm_Notify = state
        Library:Notify(state and "Alarm Notifications Enabled" or "Alarm Notifications Disabled", 3)
    end
})

AlarmBox:AddDropdown("AlarmSoundSelect", {
    Text = "Select Alarm Sound",
    Values = soundNames,
    Default = 1,  -- Points to "Basic Alarm (Default)"
    Tooltip = "Choose the sound played when a player is near",
    Callback = function(selected)
        for _, sound in ipairs(AlarmSoundsList) do
            if sound.Name == selected then
                getgenv().PlayerAlarm_SoundId = sound.Id
                Library:Notify("Alarm Sound Changed: " .. selected, 3)
                break
            end
        end
    end
})

local CharacterBox = Tabs.Player:AddLeftGroupbox("Utilities", "hammer")

-- INFINITE YIELD ADMIN COMMANDS
CharacterBox:AddButton("Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    Library:Notify("Infinite Yield cargado!", 4)
end)

-- FE RESPAWN (mata y respawnea instantáneo)
CharacterBox:AddButton("FE Respawn", function()
    local lp = game.Players.LocalPlayer
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.Health = 0
    end
    Library:Notify("Respawneando...", 2)
end)

local ResetButtonConnection

CharacterBox:AddToggle("EnableReset", {
    Text = "Enable Reset Button",
    Default = false,
    Callback = function(state)
        if state then
            -- Activar el botón de Reset
            ResetButtonConnection = game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
            Library:Notify("Reset Button activado", 3)
        else
            -- Desactivar el botón de Reset (vuelve al estado por defecto: desactivado)
            if ResetButtonConnection then
                pcall(function()
                    game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
                end)
                ResetButtonConnection = nil
            end
            Library:Notify("Reset Button desactivado", 3)
        end
    end
})

local Lighting = game:GetService("Lighting")
local OldLighting = {
    Brightness = Lighting.Brightness,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local FullbrightConnection
CharacterBox:AddToggle("Fullbright", {
    Text = "Fullbright",
    Default = false,
    Callback = function(state)
        if state then
            -- Aplicar Fullbright
            Lighting.Brightness = 3
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
            Lighting.ClockTime = 12
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)

            -- Eliminar efectos de oscuridad
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("Atmosphere") then
                    v.Enabled = false
                end
            end

            -- Mantener Fullbright aunque el juego intente cambiarlo
            FullbrightConnection = Lighting.ChildAdded:Connect(function(child)
                if state and (child:IsA("BloomEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("SunRaysEffect") or child:IsA("Atmosphere")) then
                    child.Enabled = false
                end
            end)

            Library:Notify("Fullbright Activado", 3)
        else
            -- Restaurar iluminación original
            Lighting.Brightness = OldLighting.Brightness
            Lighting.GlobalShadows = OldLighting.GlobalShadows
            Lighting.FogEnd = OldLighting.FogEnd
            Lighting.FogStart = OldLighting.FogStart
            Lighting.ClockTime = OldLighting.ClockTime
            Lighting.Ambient = OldLighting.Ambient
            Lighting.OutdoorAmbient = OldLighting.OutdoorAmbient

            -- Reactivar efectos
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                    v.Enabled = true
                end
            end

            if FullbrightConnection then
                FullbrightConnection:Disconnect()
                FullbrightConnection = nil
            end

            Library:Notify("Fullbright Desactivado", 3)
        end
    end
})

local ESPV2Box = Tabs.Visuals:AddRightGroupbox("ESP V2 (New)", "anvil")

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TextService     = game:GetService("TextService")
local Camera          = workspace.CurrentCamera
local LocalPlayer     = Players.LocalPlayer

-- Configuración
local ToolsESP_Enabled = false
local TEXT_SIZE        = 10
local MAX_WIDTH        = 380

local espDrawings = {}

-- Herramientas que NO se muestran
local HIDDEN_TOOLS = {
    "empty bag","marshmallow","small marshmallow bag","medium marshmallow bag","large marshmallow bag",
    "hot chips","jason mask","bandana","black gloves","potato chips","potato","ghost skull face half mask",
    "black surgical mask","black surgical","skimask","flour","card","gelatin","lockpick","sugar block bag",
    "crowbar","water","fake id","fist","phone","standard clip","speed loader","extended clip",
    "heavy magazine","drum magazine","crate"
}

-- Armas peligrosas → COLOR MORADO
local SPECIAL_TOOLS = {
    "prl-16","arp9","g21s drum","mpx","honey badger pistol","ddm4 v7 pistol","ar pistol","draco","tec-9","mcx",
    ".308 ar-10","honey badger","m&p-15 sport ii","300 blackout","micro draco","micro arp","ak draco",
    "suppressed mcx","suppressed arp","whiteout ar9","whiteout arp9","fn57","g19xext","machete",
    "springfieldxd mod",".308 ar-10 drum","honey badger drum","m&p-15 sport ii drum","micro draco drum",
    "300 blackout drum","micro arp drum","ak draco drum","tan 300 blk mcx","springfieldxd drum","mcx drum",
    "g19xdrum","tec-9 drum","fn57drum","arp drum","taurus drum","five seven drum","five-seven drum",
    "plr-16 drum","g23 drum","vp9 drum","p80 drum","glocks drum","draco drum","glock 20 drum",
    "hi-point drum","g22drum","binary black draco","binary g17 gen 5","binary 300 blackout arp",
    "binary 6in ar9","ddm4 v7 drum","mpx drum","g26 clear drum","black micro drac","arp9 clear drum",
    "black micro draco"
}

-- Convertimos a minúsculas una sola vez (más rápido)
local hidden  = {}
local special = {}
for _,v in ipairs(HIDDEN_TOOLS)  do hidden[string.lower(v)]  = true end
for _,v in ipairs(SPECIAL_TOOLS) do special[string.lower(v)] = true end

-- Crear Drawing una sola vez por jugador
local function createESP(plr)
    if plr == LocalPlayer or espDrawings[plr] then return end

    local txt = Drawing.new("Text")
    txt.Size         = TEXT_SIZE
    txt.Center       = true
    txt.Outline      = true
    txt.OutlineColor = Color3.new(0,0,0)
    txt.Font         = Drawing.Fonts.GothamBold or 2
    txt.Visible      = false
    txt.Color        = Color3.fromRGB(230,230,230)

    espDrawings[plr] = { text = txt }
end

-- Obtiene el texto y color de las herramientas (optimizado)
local function getToolsText(plr)
    local tools = {}

    -- Herramienta equipada
    local char = plr.Character
    if char then
        local eq = char:FindFirstChildOfClass("Tool")
        if eq and not hidden[string.lower(eq.Name)] then
            table.insert(tools, eq.Name)
        end
    end

    -- Backpack
    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and not hidden[string.lower(tool.Name)] then
                table.insert(tools, tool.Name)
            end
        end
    end

    if #tools == 0 then return nil end

    -- Detectar si tiene arma peligrosa
    local hasSpecial = false
    for _, name in ipairs(tools) do
        if special[string.lower(name)] then
            hasSpecial = true
            break
        end
    end

    local color = hasSpecial and Color3.fromRGB(169, 39, 245) or Color3.fromRGB(255, 255, 255)

    -- Si son pocas herramientas → mostrar todas
    if #tools <= 5 then
        return table.concat(tools, ", "), color
    end

    -- Si son muchas → abreviar
    local short = {}
    for i = 1, 4 do table.insert(short, tools[i]) end
    table.insert(short, tools[5] .. " | +" .. (#tools - 4) .. " Más")
    return table.concat(short, ", "), color
end

-- Heartbeat principal (muy optimizado)
RunService.Heartbeat:Connect(function()
    if not ToolsESP_Enabled then
        for _, obj in pairs(espDrawings) do
            obj.text.Visible = false
        end
        return
    end

    for plr, obj in pairs(espDrawings) do
        local line, color = getToolsText(plr)

        local head = plr.Character and plr.Character:FindFirstChild("Head")
        if not line or not head then
            obj.text.Visible = false
            continue
        end

        local headPos = head.Position + Vector3.new(0, 3.6, 0)
        local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
        if not onScreen then
            obj.text.Visible = false
            continue
        end

        -- Ajuste automático de tamaño si el texto es muy ancho
        local size = TEXT_SIZE
        if size > 11 then
            local bounds = TextService:GetTextSize(line, size, Enum.Font.GothamBold, Vector2.new(1e5, 50))
            while bounds.X > MAX_WIDTH and size > 11 do
                size -= 0.5
                bounds = TextService:GetTextSize(line, size, Enum.Font.GothamBold, Vector2.new(1e5, 50))
            end
        end

        local txt = obj.text
        txt.Size     = size
        txt.Text     = line
        txt.Color    = color
        txt.Position = Vector2.new(screenPos.X, screenPos.Y)
        txt.Visible  = true
    end
end)

-- Limpiar al salir del juego
Players.PlayerRemoving:Connect(function(plr)
    local data = espDrawings[plr]
    if data then
        data.text:Remove()
        espDrawings[plr] = nil
    end
end)

-- Crear ESP para jugadores existentes y nuevos
for _, p in Players:GetPlayers() do
    if p ~= LocalPlayer then createESP(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then createESP(p) end
end)

-- TOGGLE + SLIDER (sin spam y más limpio)
ESPV2Box:AddToggle("ToolsESP", {
    Text = "ESP Show Guns",
    Default = false,
    Callback = function(state)
        ToolsESP_Enabled = state
        Library:Notify(state and "ESP Tools V2 Activado" or "ESP Tools V2 Desactivado", 3)
    end
})

ESPV2Box:AddSlider("ESPToolsSize", {
    Text = "Guns Size",
    Min = 0,
    Max = 100,
    Default = 0,
    Rounding = 1,
    Callback = function(v)
        TEXT_SIZE = v
    end
})

local ESPNameBox = Tabs.Visuals:AddLeftGroupbox("ESP Name", "type")

-- ==================== ESP BOX (CUADRADO 2D - SIN TRACER) ====================
local ESP_Box_Enabled = false
local ESP_Box_Settings = {
    BoxColor = Color3.fromRGB(255, 255, 255),
    FriendColor = Color3.fromRGB(0, 255, 0),
    Thickness = 2,
    TeamCheck = false,
    AnimationSpeed = 0.3  -- Velocidad de la animación (igual que en ESP Name)
}
local FriendsList = {} -- Usa la misma lista de amigos que en ESP Name
local ESPBoxes = {} -- [player] = { box = Drawing.Square, currentTrans = 0, targetTrans = 0, currentSize = Vector2.new(0,0) }
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Crear el box para cada jugador
local function CreateESPBox(plr)
    if plr == LocalPlayer or ESPBoxes[plr] then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESP_Box_Settings.BoxColor
    box.Thickness = ESP_Box_Settings.Thickness
    box.Filled = false
    box.Transparency = 0  -- Empezamos en 0 (invisible)
    
    ESPBoxes[plr] = {
        box = box,
        currentTrans = 0,
        targetTrans = 0,
        currentSize = Vector2.new(0, 0),
        targetSize = Vector2.new(0, 0)
    }
end

-- Limpiar al salir del servidor
Players.PlayerRemoving:Connect(function(plr)
    if ESPBoxes[plr] then
        ESPBoxes[plr].box:Remove()
        ESPBoxes[plr] = nil
    end
end)

-- Crear para jugadores actuales y nuevos
for _, plr in Players:GetPlayers() do
    if plr ~= LocalPlayer then CreateESPBox(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then CreateESPBox(plr) end
end)

-- Bucle principal con animación suave (igual que ESP Name)
RunService.RenderStepped:Connect(function()
    if not ESP_Box_Enabled then
        for _, data in pairs(ESPBoxes) do
            data.targetTrans = 0
            data.targetSize = Vector2.new(0, 0)
        end
        -- No return aquí para que siga animando la desaparición
    end

    for plr, data in pairs(ESPBoxes) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")

        local box = data.box

        if not ESP_Box_Enabled 
            or not char or not hrp or not head 
            or not humanoid or humanoid.Health <= 0 
            or (ESP_Box_Settings.TeamCheck and plr.Team == LocalPlayer.Team) then
            
            data.targetTrans = 0
            data.targetSize = Vector2.new(0, 0)
        else
            -- Color amigo
            local isFriend = table.find(FriendsList, plr.Name) or table.find(FriendsList, plr.DisplayName)
            box.Color = isFriend and ESP_Box_Settings.FriendColor or ESP_Box_Settings.BoxColor

            -- Posiciones
            local headPos = head.Position + Vector3.new(0, 0.5, 0)
            local legPos = hrp.Position - Vector3.new(0, 3, 0)
            local headScreen, headOnScreen = Camera:WorldToViewportPoint(headPos)
            local legScreen, legOnScreen = Camera:WorldToViewportPoint(legPos)
            local rootScreen, rootOnScreen = Camera:WorldToViewportPoint(hrp.Position)

            if headOnScreen or legOnScreen or rootOnScreen then
                local boxHeight = math.abs(headScreen.Y - legScreen.Y)
                local boxWidth = boxHeight / 2
                local boxX = rootScreen.X - boxWidth / 2
                local boxY = headScreen.Y

                data.targetTrans = 1
                data.targetSize = Vector2.new(boxWidth, boxHeight)
                box.Position = Vector2.new(boxX, boxY)
                box.Thickness = ESP_Box_Settings.Thickness
            else
                data.targetTrans = 0
                data.targetSize = Vector2.new(0, 0)
            end
        end

        -- Animación suave (igual que en ESP Name)
        data.currentTrans = data.currentTrans + (data.targetTrans - data.currentTrans) * ESP_Box_Settings.AnimationSpeed
        data.currentSize = data.currentSize:Lerp(data.targetSize, ESP_Box_Settings.AnimationSpeed)

        box.Size = Vector2.new(math.floor(data.currentSize.X + 0.5), math.floor(data.currentSize.Y + 0.5))
        box.Transparency = math.clamp(data.currentTrans, 0, 1)

        -- Ocultar completamente si está casi invisible
        box.Visible = data.currentTrans > 0.01
    end
end)

-- ==================== UI DEL ESP BOX ====================
local ESPBoxGroup = Tabs.Visuals:AddRightGroupbox("ESP Box", "square")
ESPBoxGroup:AddToggle("ESPBoxEnabled", {
    Text = "ESP Box",
    Default = false,
    Tooltip = "Cuadrado 2D alrededor de jugadores",
    Callback = function(state)
        ESP_Box_Enabled = state
        Library:Notify(state and "ESP Box → ON" or "ESP Box → OFF", 4)
    end
}):AddColorPicker("BoxColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Color Normal",
    Callback = function(color)
        ESP_Box_Settings.BoxColor = color
    end
})
ESPBoxGroup:AddSlider("BoxThickness", {
    Text = "Thickness",
    Min = 0,
    Max = 6,
    Default = 0,
    Rounding = 1,
    Callback = function(v)
        ESP_Box_Settings.Thickness = v
    end
})
ESPBoxGroup:AddToggle("BoxTeamCheck", {
    Text = "Team Check",
    Default = false,
    Callback = function(state)
        ESP_Box_Settings.TeamCheck = state
    end
})

-- ==================== ESP NAME + FRIENDLY CHECK (DROPDOWN CON "----" POR DEFECTO) ====================
local ESP_Name_Enabled = false
local ESP_Settings = {
    NameColor = Color3.fromRGB(255, 255, 255),
    FriendColor = Color3.fromRGB(0, 255, 0),
    NameSize = 14,
    AnimationSpeed = 0.3
}

local FriendsList = {}
local ESPNameTexts = {}
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Crear texto ESP
local function CreateNameText(plr)
    if plr == LocalPlayer then return end
    if ESPNameTexts[plr] then 
        ESPNameTexts[plr].text:Remove() 
    end

    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = ESP_Settings.NameColor
    text.Size = 0
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.new(0, 0, 0)
    text.Font = 2
    text.Transparency = 0

    ESPNameTexts[plr] = {
        text = text,
        currentTrans = 0,
        targetTrans = 0,
        currentSize = 0
    }
end

-- Bucle principal del ESP
RunService.RenderStepped:Connect(function()
    for plr, data in pairs(ESPNameTexts) do
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")

        if not ESP_Name_Enabled then
            data.targetTrans = 0
        else
            if char and head and humanoid and humanoid.Health > 0 then
                local headPos = head.Position + Vector3.new(0, 2.8, 0)
                local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)

                if onScreen and screenPos.Z > 0 then
                    data.targetTrans = 1
                    data.text.Text = plr.DisplayName
                    data.text.Position = Vector2.new(screenPos.X, screenPos.Y)

                    local isFriend = table.find(FriendsList, plr.Name) or table.find(FriendsList, plr.DisplayName)
                    data.text.Color = isFriend and ESP_Settings.FriendColor or ESP_Settings.NameColor

                    data.text.Visible = true
                else
                    data.targetTrans = 0
                    data.text.Visible = false
                end
            else
                data.targetTrans = 0
                data.text.Visible = false
            end
        end

        data.currentTrans = data.currentTrans + (data.targetTrans - data.currentTrans) * ESP_Settings.AnimationSpeed
        data.currentSize = data.currentSize + ((data.targetTrans == 1 and ESP_Settings.NameSize or 0) - data.currentSize) * ESP_Settings.AnimationSpeed

        data.text.Transparency = math.clamp(data.currentTrans, 0, 1)
        data.text.Size = math.floor(data.currentSize + 0.5)

        if data.currentTrans < 0.01 then
            data.text.Visible = false
        end
    end
end)

-- Setup jugadores
local function SetupPlayer(plr)
    if plr == LocalPlayer then return end
    CreateNameText(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.6)
        CreateNameText(plr)
    end)
end

for _, plr in Players:GetPlayers() do SetupPlayer(plr) end
Players.PlayerAdded:Connect(SetupPlayer)
Players.PlayerRemoving:Connect(function(plr)
    if ESPNameTexts[plr] then
        ESPNameTexts[plr].text:Remove()
        ESPNameTexts[plr] = nil
    end
end)

-- ==================== UI CON DROPDOWN QUE EMPIEZA EN "----" ====================

ESPNameBox:AddToggle("ESPName", {
    Text = "ESP Name",
    Default = false,
    Tooltip = "Nombres con animación + Friendly Check",
    Callback = function(state)
        ESP_Name_Enabled = state
        Library:Notify(state and "ESP Name → ON" or "ESP Name → OFF", 4)
    end
}):AddColorPicker("NameColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Color Normal",
    Callback = function(color)
        ESP_Settings.NameColor = color
    end
}):AddColorPicker("FriendNameColor", {
    Default = Color3.fromRGB(0, 255, 0),
    Title = "Color Amigos",
    Callback = function(color)
        ESP_Settings.FriendColor = color
    end
})

-- Dropdown con "----" por defecto
local playerDropdown = ESPNameBox:AddDropdown("FriendPlayerSelect", {
    Text = "Select Player",
    Values = {"----"},  -- Empieza con esto para indicar que no hay selección
    Default = 1,        -- Selecciona "----" por defecto
    Callback = function() end
})

-- Función para actualizar la lista de jugadores
local function UpdatePlayerDropdown()
    local values = {"----"}  -- Siempre mantiene "----" como primera opción
    
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer then
            table.insert(values, plr.DisplayName .. " (" .. plr.Name .. ")")
        end
    end
    
    if #values == 1 then  -- Solo "----"
        values = {"---- (No hay jugadores)"}
    end
    
    playerDropdown:SetValues(values)
    
    -- IMPORTANTE: Forzar que siga seleccionado "----" si no había selección previa
    -- Solo cambia si el usuario selecciona manualmente
    if playerDropdown.Value == "----" or playerDropdown.Value == nil or not table.find(values, playerDropdown.Value) then
        playerDropdown:SetValue("----")
    end
end

-- Actualizar al cargar
UpdatePlayerDropdown()

-- Actualizar cuando entren/salgan jugadores
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        task.wait(0.1)
        UpdatePlayerDropdown()
    end
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    UpdatePlayerDropdown()
end)

-- Botón Confirmar amigo
ESPNameBox:AddButton("Confirm Friend (Green Name)", function()
    local selected = playerDropdown.Value
    
    if not selected or selected == "----" or selected == "---- (No hay jugadores)" then
        Library:Notify("Selecciona un jugador primero", 3)
        return
    end

    local username = selected:match("%((.-)%)")
    local displayname = selected:match("(.-)%s%(") or selected
    local targetName = username or displayname

    if not table.find(FriendsList, targetName) then
        table.insert(FriendsList, targetName)
        Library:Notify("Amigo añadido: " .. selected .. " → nombre en verde", 4)
        -- Opcional: volver a "----" después de confirmar
        playerDropdown:SetValue("----")
    else
        Library:Notify("Ya está en la lista de amigos", 3)
    end
end)

-- Botón Limpiar lista
ESPNameBox:AddButton("Clear Friends List", function()
    FriendsList = {}
    Library:Notify("Lista de amigos limpiada", 4)
    playerDropdown:SetValue("----")
end)

local ESPV1Box = Tabs.Visuals:AddLeftGroupbox("ESP Tracer", "target")

-- === TRACER ESP PRO - IMPROVED & FIXED ===
local Tracer = {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    Thickness = 2,
    From = "Bottom",
    Part = "Head",
    TeamCheck = false,
    AliveCheck = true,
    MaxDistance = 0,
    CircleEnabled = true,
    CircleRadius = 8,
    CircleThickness = 2,
    CircleFilled = false,
    AnimationSpeed = 0.3
}

local TracerLines = {} -- [player] = { line, circle, currentTrans = 0, targetTrans = 0 }
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function CreateTracer(plr)
    if plr == LocalPlayer or TracerLines[plr] then return end

    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Tracer.Color
    line.Thickness = Tracer.Thickness
    line.Transparency = 0  -- Inicia invisible

    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Color = Tracer.Color
    circle.Thickness = Tracer.CircleThickness
    circle.Radius = Tracer.CircleRadius
    circle.Filled = Tracer.CircleFilled
    circle.NumSides = 20
    circle.Transparency = 0

    TracerLines[plr] = {
        line = line,
        circle = circle,
        currentTrans = 0,
        targetTrans = 0
    }
end

Players.PlayerRemoving:Connect(function(plr)
    if TracerLines[plr] then
        TracerLines[plr].line:Remove()
        TracerLines[plr].circle:Remove()
        TracerLines[plr] = nil
    end
end)

for _, plr in Players:GetPlayers() do
    if plr ~= LocalPlayer then CreateTracer(plr) end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then CreateTracer(plr) end
end)

-- Forzar todo invisible al inicio (solución definitiva contra líneas visibles al cargar)
for _, data in pairs(TracerLines) do
    data.line.Visible = false
    data.circle.Visible = false
    data.line.Transparency = 0
    data.circle.Transparency = 0
    data.currentTrans = 0
    data.targetTrans = 0
end

-- Bucle principal
RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    local screenCenterX = viewportSize.X / 2
    local fromY = Tracer.From == "Bottom" and viewportSize.Y
               or Tracer.From == "Middle" and viewportSize.Y / 2
               or 0

    for plr, data in pairs(TracerLines) do
        local line = data.line
        local circle = data.circle

        -- Siempre forzar desaparición si está desactivado
        data.targetTrans = 0

        if Tracer.Enabled then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if not (Tracer.AliveCheck and (not humanoid or humanoid.Health <= 0))
                    and not (Tracer.TeamCheck and plr.Team == LocalPlayer.Team) then

                    local targetPart = char:FindFirstChild(Tracer.Part) or char:FindFirstChild("Head")
                    if targetPart then
                        local distOk = true
                        if Tracer.MaxDistance > 0 then
                            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if myRoot then
                                distOk = (myRoot.Position - targetPart.Position).Magnitude <= Tracer.MaxDistance
                            end
                        end

                        if distOk then
                            local targetPos = targetPart.Position
                            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                            if onScreen and screenPos.Z > 0 then
                                data.targetTrans = 1

                                line.From = Vector2.new(screenCenterX, fromY)
                                line.To = Vector2.new(screenPos.X, screenPos.Y)
                                line.Color = Tracer.Color
                                line.Thickness = Tracer.Thickness

                                if Tracer.CircleEnabled then
                                    circle.Position = Vector2.new(screenPos.X, screenPos.Y)
                                    circle.Radius = Tracer.CircleRadius
                                    circle.Thickness = Tracer.CircleThickness
                                    circle.Color = Tracer.Color
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Animación suave
        data.currentTrans = data.currentTrans + (data.targetTrans - data.currentTrans) * Tracer.AnimationSpeed

        line.Transparency = math.clamp(data.currentTrans, 0, 1)
        circle.Transparency = math.clamp(data.currentTrans, 0, 1)

        line.Visible = data.currentTrans > 0.01
        circle.Visible = Tracer.CircleEnabled and data.currentTrans > 0.01
    end
end)

-- === UI ===
ESPV1Box:AddToggle("TracerESP", {
    Text = "ESP Tracer",
    Default = false,
    Tooltip = "Precise tracers + circle on target",
    Callback = function(state)
        Tracer.Enabled = state
        Library:Notify(state and "Tracer Pro → ON" or "Tracer Pro → OFF", 3)
    end
}):AddColorPicker("TracerColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Tracer Color",
    Callback = function(col)
        Tracer.Color = col
    end
})

-- (El resto de la UI queda exactamente igual que antes)
ESPV1Box:AddDropdown("TracerPart", {
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Default = 1,
    Text = "Target Part",
    Callback = function(value)
        Tracer.Part = value
    end
})

ESPV1Box:AddDropdown("TracerFrom", {
    Values = {"Bottom", "Middle", "Top"},
    Default = 1,
    Text = "Tracer Origin",
    Callback = function(value)
        Tracer.From = value
    end
})

ESPV1Box:AddSlider("TracerThickness", {
    Text = "Line Thickness",
    Min = 0,
    Max = 8,
    Default = 0,
    Rounding = 1,
    Callback = function(v)
        Tracer.Thickness = v
    end
})

ESPV1Box:AddToggle("TracerCircle", {
    Text = "Circle on Target",
    Default = true,
    Callback = function(state)
        Tracer.CircleEnabled = state
    end
})

ESPV1Box:AddSlider("TracerCircleSize", {
    Text = "Circle Size",
    Min = 0,
    Max = 25,
    Default = 0,
    Rounding = 1,
    Callback = function(v)
        Tracer.CircleRadius = v
    end
})

ESPV1Box:AddSlider("TracerCircleThick", {
    Text = "Circle Thickness",
    Min = 0,
    Max = 6,
    Default = 0,
    Rounding = 1,
    Callback = function(v)
        Tracer.CircleThickness = v
    end
})

ESPV1Box:AddToggle("TracerTeamCheck", {
    Text = "Team Check",
    Default = false,
    Callback = function(state)
        Tracer.TeamCheck = state
    end
})

ESPV1Box:AddSlider("TracerMaxDist", {
    Text = "Distance",
    Min = 0,
    Max = 1000,
    Default = 0,
    Rounding = 1,
    Callback = function(v)
        Tracer.MaxDistance = v
    end
})

local ESPV3Box = Tabs.Visuals:AddRightGroupbox("ESP Skeleton", "git-branch")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Skeleton_Enabled = false
local Skeleton_Color = Color3.fromRGB(255, 255, 255)
local Skeleton_Thickness = 2
local Skeleton_AnimationSpeed = 0.3  -- Smooth fade speed

local Skeleton_Lines = {} -- [player] = { lines = {}, used = 0, currentTrans = 0, targetTrans = 0 }

-- Bone mapping compatible with both R6 and R15
local Bones = {
    {"Head", {"Head"}},                                   -- Head
    {"Head", {"UpperTorso", "Torso"}},                    -- Neck
    {"UpperTorso", {"LowerTorso", "Torso"}},              -- Spine
    {"UpperTorso", {"LeftUpperArm", "Left Arm"}},         -- Left Shoulder
    {"LeftUpperArm", {"LeftLowerArm", "Left Arm"}},       -- Left Elbow
    {"LeftLowerArm", {"LeftHand", "Left Arm"}},           -- Left Wrist
    {"UpperTorso", {"RightUpperArm", "Right Arm"}},       -- Right Shoulder
    {"RightUpperArm", {"RightLowerArm", "Right Arm"}},    -- Right Elbow
    {"RightLowerArm", {"RightHand", "Right Arm"}},        -- Right Wrist
    {"LowerTorso", {"LeftUpperLeg", "Left Leg"}},         -- Left Hip
    {"LeftUpperLeg", {"LeftLowerLeg", "Left Leg"}},       -- Left Knee
    {"LeftLowerLeg", {"LeftFoot", "Left Leg"}},           -- Left Ankle
    {"LowerTorso", {"RightUpperLeg", "Right Leg"}},       -- Right Hip
    {"RightUpperLeg", {"RightLowerLeg", "Right Leg"}},    -- Right Knee
    {"RightLowerLeg", {"RightFoot", "Right Leg"}}         -- Right Ankle
}

local function GetPart(char, names)
    for _, name in ipairs(names) do
        local part = char:FindFirstChild(name)
        if part then return part end
    end
    return nil
end

-- Create reusable lines per player
local function CreateSkeleton(plr)
    if plr == LocalPlayer or Skeleton_Lines[plr] then return end

    local lines = {}
    for i = 1, #Bones do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Skeleton_Color
        line.Thickness = Skeleton_Thickness
        line.Transparency = 0
        table.insert(lines, line)
    end

    Skeleton_Lines[plr] = {
        lines = lines,
        used = 0,
        currentTrans = 0,
        targetTrans = 0
    }
end

-- Cleanup when player leaves
Players.PlayerRemoving:Connect(function(plr)
    if Skeleton_Lines[plr] then
        for _, line in pairs(Skeleton_Lines[plr].lines) do
            line:Remove()
        end
        Skeleton_Lines[plr] = nil
    end
end)

-- Create for current and future players
for _, plr in Players:GetPlayers() do
    if plr ~= LocalPlayer then CreateSkeleton(plr) end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then CreateSkeleton(plr) end
end)

-- Force everything invisible on script load
for _, data in pairs(Skeleton_Lines) do
    for _, line in pairs(data.lines) do
        line.Visible = false
        line.Transparency = 0
    end
    data.currentTrans = 0
    data.targetTrans = 0
    data.used = 0
end

-- Main loop: optimized, safe and smooth (no nil errors)
RunService.Heartbeat:Connect(function()
    for plr, data in pairs(Skeleton_Lines) do
        -- Safety check: skip if player or character is missing
        if not plr or not plr.Parent or not plr.Character then
            data.targetTrans = 0
        else
            local char = plr.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")

            if not Skeleton_Enabled 
                or not char:FindFirstChild("HumanoidRootPart") 
                or not char:FindFirstChild("Head")
                or (humanoid and humanoid.Health <= 0) then
                data.targetTrans = 0
            else
                data.targetTrans = 1
            end
        end

        -- Smooth fade animation
        data.currentTrans = data.currentTrans + (data.targetTrans - data.currentTrans) * Skeleton_AnimationSpeed
        local trans = math.clamp(data.currentTrans, 0, 1)

        -- Reset previously used lines
        for i = 1, data.used do
            data.lines[i].Visible = false
        end
        data.used = 0

        -- Only draw if visible enough and ESP is enabled
        if trans > 0.01 and data.targetTrans > 0.5 and plr.Character then
            local char = plr.Character
            for i, bone in ipairs(Bones) do
                local part1 = GetPart(char, {bone[1]})
                local part2 = GetPart(char, bone[2])
                if part1 and part2 then
                    local screen1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
                    local screen2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)
                    if onScreen1 or onScreen2 then
                        data.used = data.used + 1
                        if data.used > #data.lines then break end
                        local line = data.lines[data.used]
                        line.From = Vector2.new(screen1.X, screen1.Y)
                        line.To = Vector2.new(screen2.X, screen2.Y)
                        line.Color = Skeleton_Color
                        line.Thickness = Skeleton_Thickness
                        line.Transparency = trans
                        line.Visible = true
                    end
                end
            end
        end

        -- Apply transparency to all lines (including unused ones)
        for _, line in pairs(data.lines) do
            line.Transparency = trans
        end
    end
end)

-- ==================== UI ====================
ESPV3Box:AddToggle("SkeletonESP", {
    Text = "ESP Skeleton",
    Default = false,
    Callback = function(v)
        Skeleton_Enabled = v
        Library:Notify(v and "Skeleton ESP Enabled" or "Skeleton ESP Disabled", 3)
    end
}):AddColorPicker("SkeletonColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Skeleton Color",
    Callback = function(c)
        Skeleton_Color = c
    end
})

ESPV3Box:AddSlider("SkeletonThickness", {
    Text = "Thickness",
    Min = 0,
    Max = 5,
    Default = 0,
    Rounding = 1,
    Callback = function(v)
        Skeleton_Thickness = v
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

getgenv().OffscreenArrows = {
    Enabled = false,
    Distance = 80,
    Size = 16,
    Filled = true,
    Transparency = 0,
    Thickness = 1,
    Color = Color3.fromRGB(255, 255, 255),
    TeamCheck = false
}

local Arrows = {}

local function CreateArrow()
    local arrow = Drawing.new("Triangle")
    arrow.Filled = getgenv().OffscreenArrows.Filled
    arrow.Thickness = getgenv().OffscreenArrows.Thickness
    arrow.Transparency = 1 - getgenv().OffscreenArrows.Transparency
    arrow.Color = getgenv().OffscreenArrows.Color
    arrow.Visible = false
    return arrow
end

local function GetRelative(pos)
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return Vector2.new(0, 0) end
    local root = char.PrimaryPart.Position
    local camPos = Camera.CFrame.Position
    local relative = CFrame.new(Vector3.new(root.X, camPos.Y, root.Z), camPos):PointToObjectSpace(pos)
    return Vector2.new(relative.X, relative.Z)
end

local function RelativeToCenter(v)
    return Camera.ViewportSize / 2 - v
end

local function RotateVector(v, angle)
    local rad = math.rad(angle)
    local cos = math.cos(rad)
    local sin = math.sin(rad)
    return Vector2.new(v.X * cos - v.Y * sin, v.X * sin + v.Y * cos)
end

local function UpdateArrows()
    if not getgenv().OffscreenArrows.Enabled then
        for _, arrow in pairs(Arrows) do
            arrow.Visible = false
        end
        return
    end

    for plr, arrow in pairs(Arrows) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.PrimaryPart and plr.Character.Humanoid.Health > 0 then
            local rootPos = plr.Character.PrimaryPart.Position
            local _, onScreen = Camera:WorldToViewportPoint(rootPos)

            if not onScreen then
                local rel = GetRelative(rootPos)
                local direction = rel.Unit
                local dist = getgenv().OffscreenArrows.Distance
                local size = getgenv().OffscreenArrows.Size / 2

                local base = direction * dist
                local left = base + RotateVector(direction, 90) * size
                local right = base + RotateVector(direction, -90) * size
                local tip = direction * (dist + getgenv().OffscreenArrows.Size)

                arrow.PointA = RelativeToCenter(left)
                arrow.PointB = RelativeToCenter(right)
                arrow.PointC = RelativeToCenter(tip)
                arrow.Visible = true

                -- Color por equipo
                if getgenv().OffscreenArrows.TeamCheck and plr.Team == LocalPlayer.Team then
                    arrow.Color = Color3.fromRGB(0, 255, 0) -- Verde = aliado
                else
                    arrow.Color = Color3.fromRGB(255, 0, 0) -- Rojo = enemigo
                end
            else
                arrow.Visible = false
            end
        else
            arrow.Visible = false
        end
    end
end

-- Crear flechas para jugadores
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        Arrows[plr] = CreateArrow()
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        Arrows[plr] = CreateArrow()
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if Arrows[plr] then
        Arrows[plr]:Remove()
        Arrows[plr] = nil
    end
end)

-- Loop principal
RunService.RenderStepped:Connect(UpdateArrows)

local ArrowsBox = Tabs.Visuals:AddRightGroupbox("Offscreen Arrows", "arrow-up")

ArrowsBox:AddToggle("ArrowsEnabled", {
    Text = "Offscreen Arrows",
    Default = false,
    Tooltip = "Flechas fuera de pantalla",
    Callback = function(state)
        getgenv().OffscreenArrows.Enabled = state
        Library:Notify(state and "Offscreen Arrows Activado" or "Offscreen Arrows Desactivado", 3)
    end
})

ArrowsBox:AddSlider("ArrowsDistance", {
    Text = "Distance center",
    Min = 9,
    Max = 200,
    Default = 9,
    Rounding = 1,
    Callback = function(value)
        getgenv().OffscreenArrows.Distance = value
    end
})

ArrowsBox:AddSlider("ArrowsSize", {
    Text = "Size Arrow",
    Min = 0,
    Max = 60,
    Default = 0,
    Rounding = 1,
    Callback = function(value)
        getgenv().OffscreenArrows.Size = value
    end
})

ArrowsBox:AddToggle("ArrowsTeamCheck", {
    Text = "Team Check",
    Default = false,
    Tooltip = "Verde = aliado, Rojo = enemigo",
    Callback = function(state)
        getgenv().OffscreenArrows.TeamCheck = state
    end
})

-- === HEALTH BAR ESP PRO - DEGRADADO ULTRA SUAVE Y BONITO ===
local HealthBar = {
    Enabled = false,
    BarWidth = 4,             -- Ancho fijo
    BarHeight = 50,           -- Altura fija
    TeamCheck = false,
    MaxDistance = 0
}

local Drawings = {}  -- [player] = { bg, segments = {}, text }
local CurrentHeight = {}
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Crear dibujos
local function CreateHealthBar(plr)
    if plr == LocalPlayer or Drawings[plr] then return end

    local bg = Drawing.new("Square")
    bg.Filled = true
    bg.Color = Color3.new(0, 0, 0)
    bg.Transparency = 0.5
    bg.Visible = false

    local segments = {}
    for i = 1, 20 do  -- 20 segmentos = degradado ULTRA suave
        local seg = Drawing.new("Square")
        seg.Filled = true
        seg.Visible = false
        table.insert(segments, seg)
    end

    local text = Drawing.new("Text")
    text.Size = 13
    text.Center = true
    text.Outline = true
    text.Color = Color3.new(1, 1, 1)
    text.Font = 2
    text.Visible = false

    Drawings[plr] = { bg = bg, segments = segments, text = text }
    CurrentHeight[plr] = 0
end

-- Limpieza
Players.PlayerRemoving:Connect(function(plr)
    if Drawings[plr] then
        Drawings[plr].bg:Remove()
        for _, seg in pairs(Drawings[plr].segments) do
            seg:Remove()
        end
        Drawings[plr].text:Remove()
        Drawings[plr] = nil
        CurrentHeight[plr] = nil
    end
end)

-- Crear para todos
for _, plr in Players:GetPlayers() do
    if plr ~= LocalPlayer then CreateHealthBar(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then CreateHealthBar(plr) end
end)

-- Bucle principal
RunService.RenderStepped:Connect(function()
    if not HealthBar.Enabled then
        for _, objs in pairs(Drawings) do
            objs.bg.Visible = false
            for _, seg in pairs(objs.segments) do seg.Visible = false end
            objs.text.Visible = false
        end
        return
    end

    for plr, objs in pairs(Drawings) do
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            objs.bg.Visible = false
            for _, seg in pairs(objs.segments) do seg.Visible = false end
            objs.text.Visible = false
            continue
        end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            objs.bg.Visible = false
            for _, seg in pairs(objs.segments) do seg.Visible = false end
            objs.text.Visible = false
            continue
        end

        if HealthBar.TeamCheck and plr.Team == LocalPlayer.Team then
            objs.bg.Visible = false
            for _, seg in pairs(objs.segments) do seg.Visible = false end
            objs.text.Visible = false
            continue
        end

        local rootPos = char.HumanoidRootPart.Position
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)

        if not onScreen or screenPos.Z < 0 then
            objs.bg.Visible = false
            for _, seg in pairs(objs.segments) do seg.Visible = false end
            objs.text.Visible = false
            continue
        end

        -- Offset dinámico para pegar al jugador
        local headPos = char:FindFirstChild("Head") and char.Head.Position or rootPos
        local headScreen, _ = Camera:WorldToViewportPoint(headPos + Vector3.new(2, 0, 0))
        local approximateWidth = math.abs(headScreen.X - screenPos.X) * 1.8
        local dynamicOffset = approximateWidth + 8

        local x = screenPos.X + dynamicOffset
        local y = screenPos.Y - HealthBar.BarHeight / 2

        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local filledHeight = HealthBar.BarHeight * healthPercent
        CurrentHeight[plr] = (CurrentHeight[plr] or 0) + (filledHeight - (CurrentHeight[plr] or 0)) * 0.3

        -- Fondo
        objs.bg.Position = Vector2.new(x - 2, y)
        objs.bg.Size = Vector2.new(HealthBar.BarWidth + 2, HealthBar.BarHeight)
        objs.bg.Visible = true

        -- Degradado ultra suave con 20 segmentos
        local segmentHeight = HealthBar.BarHeight / #objs.segments
        for i, seg in ipairs(objs.segments) do
            local segmentTop = (i - 1) * segmentHeight
            local segmentBottom = i * segmentHeight

            -- Porcentaje del segmento (1 = arriba, 0 = abajo)
            local segmentPercent = 1 - ((i - 0.5) / #objs.segments)

            local r, g, b

            if segmentPercent >= 0.7 then
                -- Verde brillante → Verde lima
                r = math.floor(100 + (segmentPercent - 0.7) / 0.3 * 155)  -- 100 → 255
                g = 255
                b = math.floor((segmentPercent - 0.7) / 0.3 * 100)       -- 0 → 100
            elseif segmentPercent >= 0.4 then
                -- Verde lima → Amarillo dorado
                local t = (segmentPercent - 0.4) / 0.3
                r = 255
                g = 255
                b = math.floor(100 * t)
            elseif segmentPercent >= 0.2 then
                -- Amarillo → Naranja cálido
                local t = (segmentPercent - 0.2) / 0.2
                r = 255
                g = math.floor(255 - 140 * t)  -- 255 → 115 (naranja bonito)
                b = math.floor(80 * t)
            else
                -- Naranja → Rojo intenso
                local t = segmentPercent / 0.2
                r = 255
                g = math.floor(115 * t)
                b = 0
            end

            seg.Color = Color3.fromRGB(r, g, b)

            -- Mostrar solo si está dentro de la vida actual
            if segmentBottom <= CurrentHeight[plr] then
                seg.Position = Vector2.new(x - 1, y + HealthBar.BarHeight - segmentBottom)
                seg.Size = Vector2.new(HealthBar.BarWidth, segmentHeight)
                seg.Visible = true
            else
                seg.Visible = false
            end
        end

        -- Texto porcentaje
        objs.text.Text = math.floor(healthPercent * 100) .. "%"
        objs.text.Position = Vector2.new(x, y - 18)
        objs.text.Visible = true
    end
end)

-- === UI ===
ESPV2Box:AddToggle("HealthBarPro", {
    Text = "Health Bar",
    Default = false,
    Tooltip = "Barra pegada con degradado ULTRA suave y bonito",
    Callback = function(value)
        HealthBar.Enabled = value
        Library:Notify(value and "Health Bar Premium → ON" or "Health Bar → OFF", 3)
    end
})

ESPV2Box:AddToggle("HealthTeamCheck", {
    Text = "Team Check",
    Default = false,
    Callback = function(state)
        HealthBar.TeamCheck = state
    end
})


getgenv().Aimlock = {
    Enabled = false,
    Aiming = false,
    Part = "Head",
    OldPart = "Head",
    Radius = 80,
    TeamCheck = false,
    Predict = true,
    Prediction = 15,
    Smooth = 0.14,
    AliveCheck = false,
    Airshot = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Target = nil

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = 80
FOVCircle.Color = Color3.fromRGB(255, 0, 70)
FOVCircle.Thickness = 1.6
FOVCircle.NumSides = 16
FOVCircle.Filled = false
FOVCircle.Transparency = 0.9
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
end)

local function GetClosest()
    local closest = nil
    local dist = getgenv().Aimlock.Radius

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if getgenv().Aimlock.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            local part = plr.Character:FindFirstChild(getgenv().Aimlock.Part) or plr.Character:FindFirstChild("Head")
            if part then
                local sp, onscreen = Camera:WorldToViewportPoint(part.Position)
                if onscreen then
                    local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(Mouse.X, Mouse.Y + 36)).Magnitude
                    if d < dist then
                        dist = d
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

RunService.Heartbeat:Connect(function()
    if not getgenv().Aimlock.Enabled or not getgenv().Aimlock.Aiming then return end

    Target = GetClosest()

    if getgenv().Aimlock.AliveCheck and Target and Target.Character and Target.Character:FindFirstChild("Humanoid") and Target.Character.Humanoid.Health <= 0 then
        Target = nil
    end

    if getgenv().Aimlock.Airshot and Target and Target.Character:FindFirstChild("Humanoid") then
        if Target.Character.Humanoid.FloorMaterial == Enum.Material.Air then
            getgenv().Aimlock.Part = "RightFoot"
        else
            getgenv().Aimlock.Part = getgenv().Aimlock.OldPart
        end
    end

    if Target and Target.Character and Target.Character:FindFirstChild(getgenv().Aimlock.Part) then
        local pos = Target.Character[getgenv().Aimlock.Part].Position
        if getgenv().Aimlock.Predict then
            pos = pos + (Target.Character[getgenv().Aimlock.Part].Velocity / getgenv().Aimlock.Prediction)
        end
        if getgenv().Aimlock.Smooth > 0 then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), getgenv().Aimlock.Smooth)
        else
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
        end
    end
end)

local AimBox = Tabs.Combat:AddLeftGroupbox("Aimlock (PC Only)", "sword")

-- Toggle principal + KeyPicker encadenado (esto sí funciona en tu versión)
AimBox:AddToggle("AimlockEnabled", {  -- ← Aquí va el índice
    Text = "Aim Assist",
    Default = false,
    Tooltip = "Activa el aimlock",
    Callback = function(v)
        getgenv().Aimlock.Enabled = v
    end
}):AddKeyPicker("AimlockKey", {  -- ← Aquí va el índice del KeyPicker
    Default = "B",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Aimlock Key",
    Callback = function(v)
        getgenv().Aimlock.Aiming = v
    end
})

AimBox:AddDropdown("AimPart", {
    Values = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"},
    Default = 1,
    Text = "Aim Part",
    Callback = function(v)
        getgenv().Aimlock.Part = v
        getgenv().Aimlock.OldPart = v
    end
})

AimBox:AddToggle("TeamCheck", { Text = "Team Check", Default = false, Callback = function(v) getgenv().Aimlock.TeamCheck = v end })
AimBox:AddToggle("AliveCheck", { Text = "Alive Check", Default = false, Callback = function(v) getgenv().Aimlock.AliveCheck = v end })
AimBox:AddToggle("Prediction", { Text = "Prediction", Default = false, Callback = function(v) getgenv().Aimlock.Predict = v end })
AimBox:AddToggle("Airshot", { Text = "Airshot Function", Default = false, Callback = function(v) getgenv().Aimlock.Airshot = v end })

AimBox:AddSlider("Smoothness", {
    Text = "Smoothness",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v)
        getgenv().Aimlock.Smooth = v
    end
})

AimBox:AddSlider("PredictionPower", {
    Text = "Prediction Movement",
    Default = 0,
    Min = 0,
    Max = 50,
    Rounding = 1,
    Callback = function(v)
        getgenv().Aimlock.Prediction = v
    end
})

-- FOV
local FOVBox = Tabs.Combat:AddRightGroupbox("FOV", "circle")

FOVBox:AddToggle("ShowFOV", {
    Text = "Show FOV Circle",
    Default = false,
    Callback = function(v)
        FOVCircle.Visible = v
    end
})

FOVBox:AddSlider("FOVSize", {
    Text = "FOV Radius",
    Default = 0,
    Min = 0,
    Max = 300,
    Rounding = 1,
    Callback = function(v)
        getgenv().Aimlock.Radius = v
        FOVCircle.Radius = v
    end
})

FOVBox:AddLabel("FOV Color"):AddColorPicker("FOVColor", {
    Default = Color3.fromRGB(255, 0, 70),
    Callback = function(v)
        FOVCircle.Color = v
    end
})

getgenv().Hardlock = {
    Enabled = false,
    Key = "Z",
    Part = "Head",
    FOV = 150,
    Predict = true,
    Airshot = false,
    TeamCheck = false,
    Strength = 160,
    AliveCheck = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Target = nil
local LockConnection = nil
local MouseLocked = false
local LockStartTime = 0
local RampFrames = 15

local HardlockFOVCircle = Drawing.new("Circle")
HardlockFOVCircle.Visible = false
HardlockFOVCircle.Thickness = 2
HardlockFOVCircle.Color = Color3.fromRGB(255, 0, 50)
HardlockFOVCircle.Filled = false
HardlockFOVCircle.Radius = getgenv().Hardlock.FOV
HardlockFOVCircle.Transparency = 0.8

RunService.RenderStepped:Connect(function()
    HardlockFOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    HardlockFOVCircle.Radius = getgenv().Hardlock.FOV
end)

local function GetBestPart(char, desiredPart)
    if desiredPart == "Head" then
        local head = char:FindFirstChild("Head")
        if head then return head end
    end
    local part = char:FindFirstChild(desiredPart)
    if part then return part end
    local head = char:FindFirstChild("Head")
    if head then return head end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function GetAirshotPart(char)
    local lowerTorso = char:FindFirstChild("LowerTorso")
    if lowerTorso then return lowerTorso end
    local upperTorso = char:FindFirstChild("UpperTorso")
    if upperTorso then return upperTorso end
    local torso = char:FindFirstChild("Torso")
    if torso then return torso end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = getgenv().Hardlock.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
        local humanoid = plr.Character:FindFirstChild("Humanoid")
        if getgenv().Hardlock.AliveCheck and (not humanoid or humanoid.Health <= 0) then continue end
        if getgenv().Hardlock.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        local part = GetBestPart(plr.Character, getgenv().Hardlock.Part)
        if not part then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local distance = (Vector2.new(Mouse.X, Mouse.Y + 36) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            closest = plr
        end
    end
    return closest
end

local function HardlockLoop()
    if not MouseLocked or not Target or not Target.Character then
        StopLock()
        return
    end
    if getgenv().Hardlock.AliveCheck then
        local humanoid = Target.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            StopLock()
            return
        end
    end
    local part = GetBestPart(Target.Character, getgenv().Hardlock.Part)
    if not part then
        StopLock()
        return
    end
    local humanoid = Target.Character:FindFirstChild("Humanoid")
    if getgenv().Hardlock.Airshot and humanoid and humanoid.FloorMaterial == Enum.Material.Air then
        part = GetAirshotPart(Target.Character)
    end
    local velocity = part.AssemblyLinearVelocity
    local prediction = getgenv().Hardlock.Predict and (velocity * 0.142) or Vector3.new(0, 0, 0)
    local targetPos = part.Position + prediction + Vector3.new(0, 0.1, 0)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPos)
    if not onScreen then return end
    local target2D = Vector2.new(screenPoint.X, screenPoint.Y)
    local mouse2D = Vector2.new(Mouse.X, Mouse.Y + 36)
    local difference = target2D - mouse2D
    local distance = difference.Magnitude
    local baseDeadzone = math.clamp(distance / 28, 3, 8)
    local rampProgress = math.clamp((tick() - LockStartTime) * 60 / RampFrames, 0, 1)
    local dynamicDeadzone = baseDeadzone + (4 * (1 - rampProgress))
    if distance < dynamicDeadzone then return end
    local baseStrength = getgenv().Hardlock.Strength / 100
    local rampMultiplier = rampProgress ^ 1.5
    local strength = baseStrength * rampMultiplier
    if rampProgress >= 1 then strength = baseStrength end
    local smoothFactor = math.clamp(0.15 + (300 / (distance + 70)), 0.12, 0.45)
    local distFactor = math.clamp(1.0 + (distance / 400), 1.0, 2.4)
    local verticalComp = math.clamp(1.0 + (distance / 320) + (screenPoint.Z / 270), 1.0, 2.7)
    local upwardBias = 0
    if distance > 90 then upwardBias = math.clamp((distance - 80) / 12, 0, 9) end
    if screenPoint.Z > 140 then upwardBias = upwardBias + 3.5 end
    local moveX = difference.X * smoothFactor * strength * distFactor
    local moveY = (difference.Y * smoothFactor * verticalComp * strength * distFactor) - upwardBias
    local maxMove = math.clamp(25 + (distance / 18) + (baseStrength * 2.5), 22, 50)
    if rampProgress < 0.5 then maxMove = maxMove * 0.65 end
    moveX = math.clamp(moveX, -maxMove, maxMove)
    moveY = math.clamp(moveY, -maxMove * 0.95, maxMove * 0.95)
    mousemoverel(moveX, moveY)
    mousemoverel(moveX * 0.85, moveY * 0.80)
    mousemoverel(moveX * 0.60, moveY * 0.55)
    mousemoverel(moveX * 0.30, moveY * 0.25)
    if math.abs(difference.X) > 10 then
        mousemoverel(math.clamp(difference.X * 0.65 * distFactor, -28, 28), 0)
    end
    if math.abs(difference.Y) > 8 or distance > 100 then
        local vertCorrection = math.clamp(difference.Y * 0.65 * verticalComp - upwardBias, -32, 32)
        mousemoverel(0, vertCorrection)
    end
end

local function StartLock()
    Target = GetClosestPlayer()
    if not Target then return end
    MouseLocked = true
    LockStartTime = tick()
    if LockConnection then LockConnection:Disconnect() end
    LockConnection = RunService.RenderStepped:Connect(HardlockLoop)
end

local function StopLock()
    MouseLocked = false
    if LockConnection then
        LockConnection:Disconnect()
        LockConnection = nil
    end
    Target = nil
end

UserInputService.InputBegan:Connect(function(input)
    if not getgenv().Hardlock.Enabled then return end
    local keyStr = getgenv().Hardlock.Key:upper()
    local keyCode = Enum.KeyCode[keyStr]
    if keyCode and input.KeyCode == keyCode then
        if MouseLocked then
            StopLock()
        else
            StartLock()
        end
    end
end)

local HardlockBox = Tabs.Combat:AddRightGroupbox("Hardlock", "mouse")

HardlockBox:AddToggle("HardlockEnabled", {
    Text = "MouseLock",
    Default = false,
    Tooltip = "Must be ON to use the keybind",
    Callback = function(state)
        getgenv().Hardlock.Enabled = state
        if not state then StopLock() end
    end
}):AddKeyPicker("HardlockKeybind", {
    Default = "Z",
    SyncToggleState = false,
    Mode = "Toggle",
    Text = "Hardlock Key",
    Callback = function(Value)
        getgenv().Hardlock.Key = Value.Name
    end
})

HardlockBox:AddDropdown("HardlockPart", {
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso"},
    Default = 1,
    Text = "Target Part",
    Callback = function(v) getgenv().Hardlock.Part = v end
})

HardlockBox:AddToggle("HardlockPredict", {Text = "Prediction", Default = true, Callback = function(v) getgenv().Hardlock.Predict = v end})
HardlockBox:AddToggle("HardlockAirshot", {Text = "Airshot Function", Default = false, Callback = function(v) getgenv().Hardlock.Airshot = v end})
HardlockBox:AddToggle("HardlockAliveCheck", {Text = "Alive Check", Default = false, Callback = function(v) getgenv().Hardlock.AliveCheck = v end})
HardlockBox:AddToggle("HardlockTeamCheck", {Text = "Team Check", Default = false, Callback = function(v) getgenv().Hardlock.TeamCheck = v end})
HardlockBox:AddSlider("HardlockFOV", {Text = "FOV Size", Default = 150, Min = 0, Max = 600, Rounding = 1, Callback = function(v) getgenv().Hardlock.FOV = v end})
HardlockBox:AddSlider("HardlockStrength", {
    Text = "Lock Strength",
    Default = 160,
    Min = 0,
    Max = 350,
    Rounding = 1,
    Callback = function(v) getgenv().Hardlock.Strength = v end
})

HardlockBox:AddDivider()

HardlockBox:AddToggle("HardlockShowFOV", {Text = "Show FOV Circle", Default = false, Callback = function(v) HardlockFOVCircle.Visible = v end})
HardlockBox:AddToggle("HardlockFOVFilled", {Text = "FOV Filled", Default = false, Callback = function(v) HardlockFOVCircle.Filled = v end})
HardlockBox:AddSlider("HardlockFOVTransparency", {Text = "FOV Transparency", Default = 20, Min = 0, Max = 100, Rounding = 1, Callback = function(v) HardlockFOVCircle.Transparency = 1 - (v / 100) end})
HardlockBox:AddLabel("FOV Border Color"):AddColorPicker("HardlockFOVColor", {Default = Color3.fromRGB(255, 0, 50), Callback = function(c) HardlockFOVCircle.Color = c end})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Variables principales
local hitboxEnabled = false
local hitboxSize = 5
local selectedPart = "Head"
local connection = nil
local originalData = {}
local highlights = {}
local friendsTeam = {}  -- Lista de amigos (por Name o DisplayName)

-- Toggles
local aliveCheckEnabled = true
local highlightOnlyHead = false

-- Highlight settings
local highlightSettings = {
    FillColor = Color3.fromRGB(255, 170, 100),
    OutlineColor = Color3.fromRGB(255, 120, 0),
    FillTransparency = 0.5
}

local availableParts = {"Head", "UpperTorso", "RightUpperLeg", "LeftUpperLeg", "RightFoot", "LeftFoot"}

local function isPlayerAlive(plr)
    if not plr.Character then return false end
    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function isFriend(plr)
    if not plr then return false end
    return table.find(friendsTeam, plr.Name) or table.find(friendsTeam, plr.DisplayName)
end

local function expand()
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer and plr.Character and not isFriend(plr) then
            if aliveCheckEnabled and not isPlayerAlive(plr) then continue end

            local part = plr.Character:FindFirstChild(selectedPart)
            if part and part:IsA("BasePart") then
                if not originalData[plr] then
                    originalData[plr] = {Size = part.Size, Transparency = part.Transparency, CanCollide = part.CanCollide, Massless = part.Massless}
                end

                part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                part.Transparency = 0.6
                part.CanCollide = false
                part.Massless = true

                if not highlights[plr] then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = highlightSettings.FillColor
                    highlight.OutlineColor = highlightSettings.OutlineColor
                    highlight.FillTransparency = highlightSettings.FillTransparency
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = highlightOnlyHead and (plr.Character:FindFirstChild("Head") or plr.Character) or plr.Character
                    highlight.Parent = plr.Character
                    highlights[plr] = highlight
                else
                    local hl = highlights[plr]
                    hl.FillColor = highlightSettings.FillColor
                    hl.OutlineColor = highlightSettings.OutlineColor
                    hl.FillTransparency = highlightSettings.FillTransparency
                    hl.Adornee = highlightOnlyHead and (plr.Character:FindFirstChild("Head") or plr.Character) or plr.Character
                end
            end
        end
    end
end

local function restoreAll()
    for plr, data in pairs(originalData) do
        if plr.Character and plr.Character:FindFirstChild(selectedPart) then
            local part = plr.Character[selectedPart]
            if part then
                part.Size = data.Size
                part.Transparency = data.Transparency
                part.CanCollide = data.CanCollide
                part.Massless = data.Massless
            end
        end
        if highlights[plr] then highlights[plr]:Destroy() highlights[plr] = nil end
    end
    originalData = {}
end

-- ======================= UI =======================
local HitboxBox = Tabs.Combat:AddLeftGroupbox("Hitbox Expander", "target")

HitboxBox:AddToggle("HitboxPC", {Text = "Hitbox Expander", Default = false, Callback = function(state)
    hitboxEnabled = state
    if hitboxEnabled then
        if connection then connection:Disconnect() end
        connection = RunService.Heartbeat:Connect(expand)
        Library:Notify("Hitbox Expander ➜ ON", 3)
    else
        if connection then connection:Disconnect() connection = nil end
        restoreAll()
        Library:Notify("Hitbox Expander ➜ OFF", 3)
    end
end})

HitboxBox:AddToggle("AliveCheck", {Text = "Alive Check", Default = true, Callback = function(state)
    aliveCheckEnabled = state
    if hitboxEnabled then restoreAll() task.wait(0.05) expand() end
end})

HitboxBox:AddToggle("HighlightOnlyHead", {Text = "Highlight Only on Head", Default = false, Callback = function(state)
    highlightOnlyHead = state
    if hitboxEnabled then restoreAll() task.wait(0.05) expand() end
end})

HitboxBox:AddDivider()
HitboxBox:AddLabel("Highlight Settings")

HitboxBox:AddLabel("Fill Color"):AddColorPicker("HighlightFillColor", {Default = highlightSettings.FillColor, Callback = function(color)
    highlightSettings.FillColor = color
    if hitboxEnabled then task.spawn(expand) end
end})

HitboxBox:AddLabel("Outline Color"):AddColorPicker("HighlightOutlineColor", {Default = highlightSettings.OutlineColor, Callback = function(color)
    highlightSettings.OutlineColor = color
    if hitboxEnabled then task.spawn(expand) end
end})

HitboxBox:AddSlider("HighlightTransparency", {Text = "Fill Transparency", Default = 0, Min = 0, Max = 100, Rounding = 1, Callback = function(value)
    highlightSettings.FillTransparency = value / 100
    if hitboxEnabled then task.spawn(expand) end
end})

HitboxBox:AddDropdown("HitboxPart", {Values = availableParts, Default = 1, Text = "Target Body Part", Callback = function(part)
    if hitboxEnabled then restoreAll() selectedPart = part task.wait(0.05) expand() else selectedPart = part end
    Library:Notify("Target Part: " .. part, 2)
end})

HitboxBox:AddSlider("HitboxSize", {Text = "Hitbox Size", Default = 5, Min = 0, Max = 30, Rounding = 1, Callback = function(value)
    hitboxSize = value
    if hitboxEnabled then task.spawn(expand) end
end})

-- ======================= FRIENDS TEAM (IGUAL QUE EN ESP NAME) =======================
HitboxBox:AddDivider()
HitboxBox:AddLabel("Friends Team")

-- Dropdown con "----" por defecto (igual que en tu ESP Name)
local playerDropdown = HitboxBox:AddDropdown("FriendPlayerSelect", {
    Text = "Select Player",
    Values = {"----"},
    Default = 1,
    Callback = function() end
})

-- Función para actualizar la lista (copia exacta del ESP Name)
local function UpdatePlayerDropdown()
    local values = {"----"} -- Siempre mantiene "----" como primera opción
    for _, plr in Players:GetPlayers() do
        if plr ~= LocalPlayer then
            table.insert(values, plr.DisplayName .. " (" .. plr.Name .. ")")
        end
    end
    if #values == 1 then
        values = {"---- (No players)"}
    end

    playerDropdown:SetValues(values)

    -- Forzar que siga seleccionado "----" si no había selección válida
    if playerDropdown.Value == "----" or playerDropdown.Value == nil or not table.find(values, playerDropdown.Value) then
        playerDropdown:SetValue("----")
    end
end

-- Actualizar al cargar
UpdatePlayerDropdown()

-- Actualizar cuando entren/salgan jugadores
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        task.wait(0.1)
        UpdatePlayerDropdown()
    end
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    UpdatePlayerDropdown()
end)

-- Botón Confirmar amigo
HitboxBox:AddButton("Add to Friends Team", function()
    local selected = playerDropdown.Value
    if not selected or selected == "----" or selected == "---- (No players)" then
        Library:Notify("Select a player first", 3)
        return
    end

    local username = selected:match("%((.-)%)")
    local displayname = selected:match("(.-)%s%(") or selected
    local targetName = username or displayname

    if not table.find(friendsTeam, targetName) then
        table.insert(friendsTeam, targetName)
        Library:Notify("Friend added: " .. selected .. " → Immune", 4)

        if hitboxEnabled then
            restoreAll()
            task.wait(0.05)
            expand()
        end

        -- Volver a "----" después de confirmar
        playerDropdown:SetValue("----")
    else
        Library:Notify("Already in Friends Team", 3)
    end
end)

-- Botón Clear Friends
HitboxBox:AddButton("Clear Friends Team", function()
    friendsTeam = {}
    Library:Notify("Friends Team cleared", 4)

    if hitboxEnabled then
        restoreAll()
        task.wait(0.05)
        expand()
    end

    playerDropdown:SetValue("----")
end)


local AntiAFKConnection
CharacterBox:AddToggle("Anti-AFK", {
    Text = "Anti-AFK",
    Default = false,
    Callback = function(state)
        if state then
            AntiAFKConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                game:GetService("VirtualUser"):ClickButton2(Vector2.new())
            end)
            Library:Notify("Anti-AFK Activado", 3)
        else
            if AntiAFKConnection then
                AntiAFKConnection:Disconnect()
                AntiAFKConnection = nil
            end
            Library:Notify("Anti-AFK Desactivado", 3)
        end
    end
})
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GiveFloatingGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local GiveFrame = Instance.new("Frame")
GiveFrame.Size = UDim2.new(0, 110, 0, 30)
GiveFrame.Position = UDim2.new(0, 20, 0.5, -100)
GiveFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
GiveFrame.BorderSizePixel = 0
GiveFrame.Visible = false
GiveFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = GiveFrame

local Border = Instance.new("UIStroke")
Border.Color = Color3.fromRGB(105, 9, 179)
Border.Thickness = 1
Border.Parent = GiveFrame

local GiveLabel = Instance.new("TextLabel")
GiveLabel.Size = UDim2.new(1, 0, 1, 0)
GiveLabel.BackgroundTransparency = 1
GiveLabel.Text = "Give"
GiveLabel.TextSize = 14
GiveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
GiveLabel.Font = Enum.Font.GothamBold
GiveLabel.Parent = GiveFrame

GiveFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(GiveFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(141, 35, 222)}):Play()
    end
end)

GiveFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(GiveFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
    end
end)

local function SimulateQ()
    local hold = math.random(60, 140) / 1000
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(hold)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
end

GiveFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        SimulateQ()
    end
end)

ExploitsBox:AddToggle("ShowGiveFloating", {
    Text = "Show Give Button (Mobile Only)",
    Default = false,
    Tooltip = "Shows floating 'Give' button - Works only on Mobile",
    Callback = function(state)
        if not isMobile then
            Library.Options.ShowGiveFloating:SetValue(false)
            Library:Notify("This feature is only available on Mobile", 5)
            return
        end
        GiveFrame.Visible = state
        if state then
            Library:Notify("Give Button ON (Mobile)", 5)
        else
            Library:Notify("Give Button OFF", 3)
        end
    end
})

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CLIPS = {"Drum Magazine","Heavy Magazine","Speed Loader","Extended Clip","Standard Clip"}
getgenv().AutoSpendSpamEnabled = false
local AutoSpendSpamConnection = nil

local function UseClipSpam()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return false end
    local tool = nil
    local bp = LocalPlayer.Backpack
    for i = 1, #CLIPS do
        tool = bp:FindFirstChild(CLIPS[i])
        if tool then break end
    end
    if not tool then
        for i = 1, #CLIPS do
            tool = char:FindFirstChild(CLIPS[i])
            if tool then break end
        end
    end
    if tool then
        if tool.Parent == bp then
            char.Humanoid:EquipTool(tool)
            task.wait(0.1)
        end
        VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
        task.wait(0.05 + math.random(1,5)/100)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
        return true
    else
        return false
    end
end

local function StartAutoSpendSpam()
    if getgenv().AutoSpendSpamEnabled then return end
    getgenv().AutoSpendSpamEnabled = true
    Library:Notify("Auto Spend Spam → ON (consumes ALL clips FAST)", 5)
    AutoSpendSpamConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().AutoSpendSpamEnabled then return end
        local hasClip = UseClipSpam()
        if not hasClip then
            getgenv().AutoSpendSpamEnabled = false
            Library.Options.AutoSpendSpamToggle:SetValue(false)
            Library:Notify("Auto Spend Spam → OFF (all clips consumed)", 5)
            if AutoSpendSpamConnection then
                AutoSpendSpamConnection:Disconnect()
                AutoSpendSpamConnection = nil
            end
        end
    end)
end

local function StopAutoSpendSpam()
    getgenv().AutoSpendSpamEnabled = false
    if AutoSpendSpamConnection then
        AutoSpendSpamConnection:Disconnect()
        AutoSpendSpamConnection = nil
    end
    Library:Notify("Auto Spend Spam → OFF", 3)
end

ExploitsBox:AddToggle("AutoSpendSpamToggle", {
    Text = "Auto Spend Clip",
    Default = false,
    Tooltip = "Consumes ALL clips as FAST as possible (safe spam). Turns off automatically when finished",
    Callback = function(state)
        if state then
            StartAutoSpendSpam()
        else
            StopAutoSpendSpam()
        end
    end
})
local FPSBoosterBox = Tabs.Player:AddRightGroupbox("FPS Booster", "zap")

getgenv().TargetFPS = 60
getgenv().UltraLowEnabled = false

local function ClearEffects(parent)
    for _, obj in pairs(parent:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or 
           obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Beam") then
            obj:Destroy()
        end
        if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
            obj:Destroy()
        end
        if obj:IsA("MeshPart") then
            obj.TextureID = ""
            obj.Material = Enum.Material.SmoothPlastic
        end
        if obj:IsA("SpecialMesh") or obj:IsA("BlockMesh") or obj:IsA("CylinderMesh") then
            obj.TextureId = ""
        end
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
        end
    end
end

local function UltraLowGraphics()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    game.Lighting.GlobalShadows = false
    game.Lighting.FogEnd = 9e9
    game.Lighting.Brightness = 1
    if game.Lighting:FindFirstChild("Atmosphere") then game.Lighting.Atmosphere:Destroy() end
    for _, e in pairs(game.Lighting:GetChildren()) do
        if e:IsA("PostEffect") then e.Enabled = false end
    end
    ClearEffects(workspace)
    ClearEffects(game.Lighting)
end

local function ApplyFPSLimit(fps)
    getgenv().TargetFPS = fps
    if setfpscap then setfpscap(fps == 0 and 9999 or fps) end
end

FPSBoosterBox:AddSlider("FPSLimit", {
    Text = "FPS Limit",
    Min = 0,
    Max = 244,
    Default = 60,
    Rounding = 1,
    Callback = ApplyFPSLimit
})

FPSBoosterBox:AddButton("Low Graphics", function()
    getgenv().UltraLowEnabled = not getgenv().UltraLowEnabled
    if getgenv().UltraLowEnabled then
        UltraLowGraphics()
        spawn(function()
            while getgenv().UltraLowEnabled do
                task.wait(2)
                ClearEffects(workspace)
            end
        end)
    end
end)

local SpawnBox = Tabs.Player:AddLeftGroupbox("Custom Spawn Point", "map-pin")

getgenv().CustomSpawnPos = nil
getgenv().SpawnOnDeathEnabled = false  -- Died Spawn toggle
local SAFE_OFFSET_Y = 4

-- Predefined locations
local PredefinedLocations = {
    ["Default Spawn"] = Vector3.new(0, 0, 0),
    ["DealerShip"] = Vector3.new(704.38, 3.35, 419.68),
    ["Gun Store1"] = Vector3.new(192.75, 3.38, -174.21),
    ["Gun Store2"] = Vector3.new(-460.47, 3.38, 342.11),
    ["Bank"] = Vector3.new(-42.90, 3.63, -347.81),
    ["Apartments"] = Vector3.new(1189.84, 3.35, -254.32),
    ["Casino"] = Vector3.new(1131.65, 3.00, -37.64),
}

local function CopyCurrentPosition()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        Library:Notify("No character found", 4)
        return
    end
    local hrp = char.HumanoidRootPart
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {char}
    local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -800, 0), params)
    local groundY = ray and ray.Position.Y or hrp.Position.Y - 4
    local spawnY = groundY + 3
    local posStr = string.format("%.2f, %.2f, %.2f", hrp.Position.X, spawnY, hrp.Position.Z)
    if setclipboard then setclipboard(posStr) end
    Library.Options.SpawnCoords:SetValue(posStr)
    Library:Notify("Position copied and pasted into coordinates", 5)
end

local function SetSpawnPosition(posText)
    local x, y, z = posText:match("([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)")
    if not (x and y and z) then
        Library:Notify("Invalid coordinates format", 4)
        return false
    end
    getgenv().CustomSpawnPos = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
    Library:Notify("Custom spawn point SET - Die to test", 5)
    return true
end

local function SetPredefinedSpawn(locationName)
    if locationName == "Default Spawn" then
        getgenv().CustomSpawnPos = nil
        Library:Notify("Spawn point cleared (default spawn)", 4)
        return
    end
    local pos = PredefinedLocations[locationName]
    if pos then
        getgenv().CustomSpawnPos = pos
        Library:Notify("Spawn set to: " .. locationName, 5)
    end
end

local function ClearSpawnPosition()
    getgenv().CustomSpawnPos = nil
    Library.Options.SpawnCoords:SetValue("")
    Library:Notify("Spawn point cleared", 4)
end

-- Died Spawn: Save position on death
local function OnDied()
    if not getgenv().SpawnOnDeathEnabled then return end
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {char}
    local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -800, 0), params)
    local groundY = ray and ray.Position.Y or hrp.Position.Y - 4
    getgenv().CustomSpawnPos = Vector3.new(hrp.Position.X, groundY + 3, hrp.Position.Z)
    Library:Notify("Died Spawn ACTIVE - Next respawn at death location", 5)
end

-- Auto respawn at custom position (or death position if enabled)
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    if not getgenv().CustomSpawnPos then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hrp then return end
    task.wait(0.15)
    hrp.CFrame = CFrame.new(getgenv().CustomSpawnPos + Vector3.new(0, SAFE_OFFSET_Y, 0))
    Library:Notify("Respawned at saved spawn point", 4)
end)

-- Detect death to save position
game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Died:Connect(OnDied)
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").Died:Connect(OnDied)
end)

-- UI
SpawnBox:AddToggle("DiedSpawn", {
    Text = "Died Spawn",
    Default = false,
    Callback = function(state)
        getgenv().SpawnOnDeathEnabled = state
        if state then
            Library:Notify("Died Spawn ENABLED - Next death will save position", 5)
        else
            Library:Notify("Died Spawn DISABLED", 4)
        end
    end
})

SpawnBox:AddButton("Copy Coord", function()
    CopyCurrentPosition()
end)

SpawnBox:AddInput("SpawnCoords", {
    Text = "Coordinates (x, y, z)",
    Default = "",
    Placeholder = "Example: -145.32, 48.50, -320.67",
    Callback = function() end
})

SpawnBox:AddButton("Set Spawn", function()
    local text = Library.Options.SpawnCoords.Value
    if text == "" and getclipboard then text = getclipboard() end
    if text ~= "" then
        SetSpawnPosition(text)
    else
        Library:Notify("No coordinates to set", 4)
    end
end)

SpawnBox:AddDivider()

SpawnBox:AddDropdown("LocationMap", {
    Text = "Location Map",
    Values = {"Default Spawn", "DealerShip", "Gun Store1", "Gun Store2", "Bank", "Apartments", "Casino"},
    Default = 1,
    Callback = function(value)
        SetPredefinedSpawn(value)
    end
})

SpawnBox:AddButton("Clear Spawn Point", function()
    ClearSpawnPosition()
    Library.Options.LocationMap:SetValue("Default Spawn")
end)

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

game:GetService("UserInputService").InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.M then Library:Toggle() end
end)

Library:Notify("Nyx Exotic, [Open Menu] (M)", 6)
SaveManager:LoadAutoloadConfig()
