local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- DETECCIÓN EXACTA DE MOBILE (Touch + sin teclado)
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Crear GUI (siempre en CoreGui para que sea visible)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GiveFloatingGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local GiveFrame = Instance.new("Frame")
GiveFrame.Size = UDim2.new(0, 110, 0, 30)
GiveFrame.Position = UDim2.new(0, 20, 0.5, -100)  -- Posición optimizada Mobile
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

-- Efecto press (morado)
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

-- SIMULAR TECLA Q (humanized)
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

-- TOGGLE EN CHARACTERBOX - SOLO FUNCIONAL EN MOBILE
CharacterBox:AddToggle("ShowGiveFloating", {
    Text = "Show Give (Mobile Only)",
    Default = false,
    Tooltip = "Muestra botón flotante 'Give' - SOLO funciona en Mobile",
    Callback = function(state)
        -- Si es PC → bloquea el toggle y fuerza OFF
        if not isMobile then
            Library.Options.ShowGiveFloating:SetValue(false)  -- Fuerza OFF
            Library:Notify("❌ Esta función SOLO está disponible en Mobile", 5)
            return
        end

        -- Solo en Mobile permite cambiar el estado
        GiveFrame.Visible = state

        if state then
            Library:Notify("Botón Give → ON (Mobile)", 5)
        else
            Library:Notify("Botón Give → OFF", 3)
        end
    end
})

Library:Notify("Botón Give flotante → Toggle bloqueado en PC, solo funciona en Mobile", 7)

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
        task.wait(0.05 + math.random(1,5)/100)  -- Hold ultra corto
        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)

        return true
    else
        return false
    end
end

local function StartAutoSpendSpam()
    if getgenv().AutoSpendSpamEnabled then return end
    getgenv().AutoSpendSpamEnabled = true

    Library:Notify("Auto Spend Spam → ON (consume TODOS los clips RÁPIDO)", 5)

    AutoSpendSpamConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().AutoSpendSpamEnabled then return end

        local hasClip = UseClipSpam()

        if not hasClip then
            getgenv().AutoSpendSpamEnabled = false
            Library.Options.AutoSpendSpamToggle:SetValue(false)
            Library:Notify("Auto Spend Spam → OFF (todos los clips consumidos)", 5)
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

CharacterBox:AddToggle("AutoSpendSpamToggle", {
    Text = "Auto Spend Clip",
    Default = false,
    Tooltip = "Consume TODOS los clips lo más RÁPIDO posible (spam safe). Se apaga solo al terminar",
    Callback = function(state)
        if state then
            StartAutoSpendSpam()
        else
            StopAutoSpendSpam()
        end
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

getgenv().InfAmmoEnabled = false
local InfAmmoConnection = nil
local LastTool = nil
local OriginalMagValues = {} -- Guarda el valor original de cada Mag

local function ApplyInfAmmo()
    local char = LocalPlayer.Character
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then 
        LastTool = nil
        return 
    end

    if tool == LastTool then return end

    local mag = tool:FindFirstChild("Mag")
    if mag and (mag:IsA("IntValue") or mag:IsA("NumberValue")) then
        task.spawn(function()
            task.wait(math.random(5, 15)/100)
            
            if not OriginalMagValues[mag] then
                OriginalMagValues[mag] = mag.Value -- Guardar valor original la primera vez
            end
            
            mag.Value = 1
            LastTool = tool
        end)
    else
        LastTool = tool
    end
end

local function RestoreAllMag()
    for mag, original in pairs(OriginalMagValues) do
        if mag and mag.Parent then
            mag.Value = original
        end
    end
    OriginalMagValues = {}
end

local function StartInfAmmo()
    if getgenv().InfAmmoEnabled then return end
    getgenv().InfAmmoEnabled = true

    InfAmmoConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().InfAmmoEnabled then return end
        ApplyInfAmmo()
    end)

    LocalPlayer.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and getgenv().InfAmmoEnabled then
                task.wait(0.2)
                ApplyInfAmmo()
            end
        end)
    end)
end

local function StopInfAmmo()
    getgenv().InfAmmoEnabled = false
    if InfAmmoConnection then
        InfAmmoConnection:Disconnect()
        InfAmmoConnection = nil
    end
    RestoreAllMag()
    LastTool = nil
end

ExploitsBox:AddToggle("InfAmmoToggle", {
    Text = "Inf Ammo",
    Default = false,
    Tooltip = "Mantiene el Value 'Mag' en 1 mientras está activado - Se restaura al desactivar",
    Callback = function(state)
        if state then
            StartInfAmmo()
            Library:Notify("Inf Ammo → ON", 4)
        else
            StopInfAmmo()
            Library:Notify("Inf Ammo → OFF (valores restaurados)", 4)
        end
    end
})
