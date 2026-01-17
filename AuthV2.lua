local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer

getgenv().NYX_Authorized = getgenv().NYX_Authorized or false
getgenv().NYX_Key = getgenv().NYX_Key or ""
getgenv().NYX_UserID = getgenv().NYX_UserID or Player.UserId
getgenv().NYX_Level = getgenv().NYX_Level or "None"
getgenv().NYX_TempExpiry = getgenv().NYX_TempExpiry or nil -- Nueva variable para expiración temporal

-- ==================== CONFIGURATION ====================
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1453113715200102531/TRzVhwOYlF921oHphBfNIKP0LCwxcwLBfRCD0D1L00fg07Sofj6eSv-4jgt-xSdWHj6O"
local OWNER_USERID = "" -- Reemplaza con tu UserID de Roblox
local DISCORD_INVITE = "F3SDzkZa6U"

-- URLs para los sistemas de claves
local TEMP_KEYS_URL = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/TemporaryKey.json"
local PREMIUM_KEYS_URL = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/PremiumKeys.json"

-- Configuración de duraciones temporales
local TEMP_DURATIONS = {
    ["1d"] = 86400,        -- 1 día
    ["3d"] = 259200,       -- 3 días
    ["7d"] = 604800,       -- 7 días
    ["14d"] = 1209600,     -- 14 días
    ["1w"] = 604800,       -- 1 semana
    ["1 month"] = 2592000  -- 1 mes (aproximado)
}

-- ==================== DETECTAR EXECUTOR ====================
local function getExecutorName()
    if identifyexecutor then
        local name, _ = identifyexecutor()
        return name or "Unknown"
    elseif getexecutorname then
        return getexecutorname()
    elseif syn then
        return "Synapse X"
    elseif KRNL_LOADED then
        return "Krnl"
    elseif fluxus then
        return "Fluxus"
    elseif gethwid then
        return "Solara / Codex"
    end
    return "Unknown Executor"
end

-- ==================== FECHA FORMATEADA ====================
local function getFormattedDate()
    return os.date("%d/%m/%Y • %H:%M:%S")
end

-- ==================== FORMATO DE TIEMPO LEGIBLE ====================
local function formatTimeRemaining(seconds)
    if not seconds or seconds <= 0 then return "Expired" end
    
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    if days > 0 then
        return string.format("%d days, %02d:%02d:%02d", days, hours, minutes, secs)
    else
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    end
end

local function sendAdvancedEmbed(title, description, color, accessLevel, keyUsed, extraFields)
    -- Función para obtener la mejor URL de imagen
    local function getBestImageUrl()
        local urls = {
            -- CDN de Roblox (más rápido y confiable)
            string.format("https://tr.rbxcdn.com/%s/150/150/AvatarHeadshot/Png", Player.UserId),
            string.format("https://tr.rbxcdn.com/%s/150/150/Avatar/Png", Player.UserId),
            -- API de Roblox
            string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=Png", Player.UserId),
            string.format("https://www.roblox.com/bust-thumbnail/image?userId=%d&width=150&height=150&format=Png", Player.UserId),
            string.format("https://www.roblox.com/avatar-thumbnail/image?userId=%d&width=150&height=150&format=Png", Player.UserId)
        }
        
        return urls[1]  -- Usar el CDN primero
    end
    
    local imageUrl = getBestImageUrl()
    
    local embed = {
        title = "🔐 " .. title,
        description = description,
        color = color,
        thumbnail = {
            url = imageUrl
        },
        author = {
            name = Player.DisplayName .. " (" .. Player.Name .. ")",
            url = "https://www.roblox.com/users/" .. Player.UserId .. "/profile"
        },
        fields = {},
        footer = {
            text = "NYX Exotic • Security System",
            icon_url = "https://img.icons8.com/color/96/000000/security-checked.png"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    -- Campo de usuario
    table.insert(embed.fields, {
        name = "👤 Información del Usuario",
        value = "**Display:** @" .. Player.DisplayName .. 
                "\n**Username:** " .. Player.Name .. 
                "\n**UserID:** `" .. Player.UserId .. "`",
        inline = false
    })
    
    -- Campo de key si existe
    if keyUsed and keyUsed ~= "N/A" and keyUsed ~= "Public" and keyUsed ~= "Owner UserID" then
        table.insert(embed.fields, {
            name = "🔑 Clave Usada",
            value = "```" .. keyUsed .. "```",
            inline = false
        })
    end
    
    -- Campo de categoría
    local categoryText = ""
    if accessLevel == "Premium" then
        categoryText = "🔑 **Premium**"
    elseif accessLevel == "Freemium" then
        categoryText = "🔓 **Freemium**"
    elseif accessLevel == "Owner" then
        categoryText = "👑 **Owner**"
    elseif accessLevel == "Temporal" then
        categoryText = "⏳ **Temporal**"
    else
        categoryText = "❌ **None**"
    end
    
    table.insert(embed.fields, {
        name = "🛡️ Categoría de Acceso",
        value = categoryText,
        inline = true
    })
    
    -- Campo de executor
    table.insert(embed.fields, {
        name = "⚙️ Executor",
        value = "**" .. getExecutorName() .. "**",
        inline = true
    })
    
    -- Campo de fecha
    table.insert(embed.fields, {
        name = "⏰ Fecha y Hora",
        value = getFormattedDate(),
        inline = false
    })
    
    -- Agregar campos extras
    if extraFields then
        for _, f in pairs(extraFields) do 
            table.insert(embed.fields, f) 
        end
    end
    
    -- Enviar el embed
    local body = HttpService:JSONEncode({embeds = {embed}})
    
    spawn(function()
        pcall(function()
            local req = syn and syn.request or request or http_request or http.request
            if req then
                req({
                    Url = DISCORD_WEBHOOK,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = body
                })
            end
        end)
    end)
end

-- ==================== CONFIG ====================
local Config = {
    PremiumKeys = {},
    TemporaryKeys = {},
    PublicKeyRaw = "NYX-FREEMIUM.Fix",
    PublicKeyClean = "",
    StartDate = "01/01/2026 00:00",
    EndDate = "20/01/2026 23:59",
    AuthFile = "NYX_Auth.key",
    TempAuthFile = "NYX_TempAuth.key", -- Nueva archivo para auth temporal
    FreemiumURL = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/Freemium",
    PremiumURL = "https://raw.githubusercontent.com/TexaThebardo/nyx/refs/heads/main/premium",
    PremiumKeysURL = PREMIUM_KEYS_URL,
    TempKeysURL = TEMP_KEYS_URL,
}

Config.PublicKeyClean = Config.PublicKeyRaw:gsub("[%s%-%.]", ""):upper()
local FREEMIUM_URL = Config.FreemiumURL
local PREMIUM_URL = Config.PremiumURL
local PublicKeyEnabled = true
local BannedUserIDs = {}
local ActiveUsers = {}

-- ==================== LOAD KEYS FROM GITHUB ====================
local function loadPremiumKeys()
    pcall(function()
        local success, response = pcall(game.HttpGet, game, Config.PremiumKeysURL)
        if success and response then
            local jsonData = HttpService:JSONDecode(response)
            if typeof(jsonData) == "table" then 
                Config.PremiumKeys = jsonData 
            end
        end
    end)
end

local function loadTemporaryKeys()
    pcall(function()
        local success, response = pcall(game.HttpGet, game, Config.TempKeysURL)
        if success and response then
            local jsonData = HttpService:JSONDecode(response)
            if typeof(jsonData) == "table" then 
                Config.TemporaryKeys = jsonData 
            end
        end
    end)
end

local function loadAllKeys()
    loadPremiumKeys()
    loadTemporaryKeys()
end

loadAllKeys()

-- ==================== DATES ====================
local function parseDate(str)
    local d, m, y, h, min = str:match("(%d%d)/(%d%d)/(%d%d%d%d) (%d%d):(%d%d)")
    if not d then return os.time() end
    return os.time({year = y, month = m, day = d, hour = h, min = min, sec = 0})
end

local START_TIME = parseDate(Config.StartDate)
local END_TIME = parseDate(Config.EndDate)

local function isPublicValid()
    if not PublicKeyEnabled then return false end
    return os.time() >= START_TIME and os.time() < END_TIME
end

local function getExpireTimeString()
    local now = os.time()
    local color = (PublicKeyEnabled and isPublicValid()) and "rgb(0, 255, 150)" or "rgb(255, 80, 80)"
    if not PublicKeyEnabled then return "<font color='rgb(255, 80, 80)'>Disabled by Admin</font>" end
    local diff = now < START_TIME and (START_TIME - now) or now >= END_TIME and 0 or (END_TIME - now)
    local days = math.floor(diff / 86400)
    local h = math.floor((diff % 86400) / 3600)
    local m = math.floor((diff % 86400 % 3600) / 60)
    local s = diff % 60
    return "<font color='" .. color .. "'>" .. days .. "d " .. string.format("%02d", h) .. "h " .. string.format("%02d", m) .. "m " .. string.format("%02d", s) .. "s</font>"
end

-- ==================== USERID ====================
local USERID = tostring(Player.UserId)

-- ==================== TEMPORARY KEY MANAGEMENT ====================
local function saveTempAuth(key, expiryTime)
    if writefile then 
        local data = {
            key = key,
            userid = USERID,
            expiry = expiryTime,
            savedAt = os.time()
        }
        writefile(Config.TempAuthFile, HttpService:JSONEncode(data))
    end 
end

local function loadTempAuth()
    if isfile and isfile(Config.TempAuthFile) and readfile then
        local data = readfile(Config.TempAuthFile)
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, data)
        if success and decoded and decoded.userid == USERID then
            if decoded.expiry and os.time() < decoded.expiry then
                return decoded.key, decoded.expiry
            else
                -- Clave expirada, eliminar archivo
                if delfile then delfile(Config.TempAuthFile) end
            end
        end
    end
    return nil
end

local function activateTemporaryKey(key)
    if not Config.TemporaryKeys[key] then return false end
    
    local keyData = Config.TemporaryKeys[key]
    
    -- Verificar si la clave ya fue activada
    if keyData.ActivatedAt then
        -- Verificar expiración
        if keyData.ExpiresAt and os.time() > keyData.ExpiresAt then
            return false, "Key expired"
        end
    else
        -- Primera activación
        keyData.ActivatedAt = os.time()
        keyData.ExpiresAt = os.time() + keyData.Duration
    end
    
    -- Guardar en archivo local
    saveTempAuth(key, keyData.ExpiresAt)
    
    return true, keyData.ExpiresAt
end

local function checkTemporaryKeyExpiry()
    if getgenv().NYX_TempExpiry then
        local remaining = getgenv().NYX_TempExpiry - os.time()
        if remaining <= 0 then
            getgenv().NYX_Level = "None"
            getgenv().NYX_TempExpiry = nil
            if delfile and isfile(Config.TempAuthFile) then
                delfile(Config.TempAuthFile)
            end
            return false
        end
        return true, remaining
    end
    return false
end

-- ==================== AUTH FILE (PREMIUM) ====================
local function saveAuth(key) 
    if writefile then 
        writefile(Config.AuthFile, key .. "|" .. USERID) 
    end 
end

local function deleteAuth() 
    if delfile and isfile(Config.AuthFile) then 
        delfile(Config.AuthFile) 
    end 
end

local function loadAuth()
    if isfile and isfile(Config.AuthFile) and readfile then
        local data = readfile(Config.AuthFile)
        local key, linkedUserID = data:match("^(.-)|(.+)$")
        if key and linkedUserID == USERID then
            loadPremiumKeys()
            if Config.PremiumKeys[key] and Config.PremiumKeys[key] == USERID then 
                return key 
            else 
                deleteAuth() 
            end
        end
    end
    return nil
end

-- ==================== LOAD SCRIPT ====================
local function loadScript(isPremium, isTemporal)
    task.wait(1)
    local url = isPremium and PREMIUM_URL or FREEMIUM_URL
    -- Si es temporal, también cargar premium
    if isTemporal then
        url = PREMIUM_URL
    end
    pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    task.wait(1.2)
    if not Library.Unloaded then Library:Unload() end
end

-- Y en la función de activación temporal, cambiar:
local function temporaryAuthSequence(expiryTime)
    local remaining = expiryTime - os.time()
    local timeStr = formatTimeRemaining(remaining)
    Library:Notify("Clave Temporal Activada! Expira en: " .. timeStr, 10)
    
    -- Actualizar información de expiración en tiempo real
    spawn(function()
        while getgenv().NYX_Level == "Temporal" and not Library.Unloaded do
            if getgenv().NYX_TempExpiry then
                local rem = getgenv().NYX_TempExpiry - os.time()
                if rem <= 0 then
                    Library:Notify("¡Tu clave temporal ha expirado!", 10)
                    break
                end
            end
            task.wait(30)
        end
    end)
end

-- Y en la verificación de key temporal, asegurar que cargue premium:
if Config.TemporaryKeys[input] then
    -- ... validaciones ...
    
    if success then
        getgenv().NYX_Level = "Temporal"
        getgenv().NYX_TempExpiry = expiryTime
        
        temporaryAuthSequence(expiryTime)
        
        sendAdvancedEmbed("⏳ Clave Temporal Activada", "Acceso Temporal Premium concedido", 10181046, "Temporal", input, {
            {name = "🔑 Key Usada", value = "`"..input.."`", inline = false},
            {name = "📊 Tipo", value = keyData.Type or "Temporal", inline = true},
            {name = "⏰ Expira", value = os.date("%d/%m/%Y %H:%M:%S", expiryTime), inline = false},
            {name = "⏱️ Tiempo Restante", value = formatTimeRemaining(expiryTime - os.time()), inline = true}
        })
        
        task.wait(2)
        loadScript(false, true) -- true para temporal = premium
        return
    end
end

-- ==================== UI ====================
pcall(function()
    local AuthWindow = Library:CreateWindow({
        Title = " И Ξ Ｘ",
        Icon = 94564569718126,
        Footer = "SYSTEM AUTH KEY - NYX @xSh4dow",
        AutoShow = true,
        ShowCustomCursor = false,
        NotifySide = "Right"
    })

    -- Timer
    task.spawn(function()
        local startTime = tick()
        repeat
            local remaining = math.max(0, 60 - math.floor(tick() - startTime))
            if remaining > 0 and not Library.Unloaded then
                pcall(function() AuthWindow:SetFooter("Closing in " .. remaining .. " seconds...") end)
            end
            task.wait(1)
        until Library.Unloaded or remaining <= 0
        if not Library.Unloaded then
            sendAdvancedEmbed("⏰ Time Expired", "No autenticación en 60s", 16711680, "None", "N/A")
            Library:Unload()
        end
    end)

    -- ==================== OWNER DETECTION & ADMIN TAB ====================
    local isOwner = (USERID == OWNER_USERID)
    local AdminTab

    if isOwner then
        getgenv().NYX_Level = "Owner"
        sendAdvancedEmbed("👑 Owner Login", "El owner ha iniciado sesión", 16755200, "Owner", "Owner UserID")
        Library:Notify("Welcome back, Owner! 👑", 10)

        AdminTab = AuthWindow:AddTab("Admin", "shield")

        -- Ban Management
        local BanBox = AdminTab:AddLeftGroupbox("Ban Management", "ban")
        local BanInput = BanBox:AddInput("BanUserID", {Text = "UserID to ban", Placeholder = "Paste UserID here..."})
        BanBox:AddButton("Ban UserID", function()
            local userid = BanInput.Value:match("^%s*(.-)%s*$")
            if userid == "" then Library:Notify("Enter a valid UserID", 5) return end
            BannedUserIDs[userid] = true
            Library:Notify("UserID banned: " .. userid, 8)
            sendAdvancedEmbed("🔨 UserID Banned by Owner", "Owner banned a UserID", 16711680, "Owner", "N/A", {
                {name = "🔨 Banned UserID", value = "`"..userid.."`", inline = false}
            })
        end)

        local UnbanInput = BanBox:AddInput("UnbanUserID", {Text = "UserID to unban", Placeholder = "Paste UserID here..."})
        BanBox:AddButton("Unban UserID", function()
            local userid = UnbanInput.Value:match("^%s*(.-)%s*$")
            if userid == "" then Library:Notify("Enter a valid UserID", 5) return end
            BannedUserIDs[userid] = nil
            Library:Notify("UserID unbanned: " .. userid, 8)
            sendAdvancedEmbed("🔓 UserID Unbanned by Owner", "Owner unbanned a UserID", 65280, "Owner", "N/A", {
                {name = "🔓 Unbanned UserID", value = "`"..userid.."`", inline = false}
            })
        end)

        -- Owner Tools
        local ToolsBox = AdminTab:AddRightGroupbox("Owner Tools", "tools")
        ToolsBox:AddButton("Reload All Keys", function()
            loadAllKeys()
            Library:Notify("All keys reloaded from GitHub", 6)
        end)

        ToolsBox:AddButton("Disable Public Key", function()
            PublicKeyEnabled = false
            Library:Notify("Public key disabled globally", 8)
            sendAdvancedEmbed("🔒 Public Key Disabled", "Owner disabled public access", 16711680, "Owner", "N/A")
        end)

        ToolsBox:AddButton("Enable Public Key", function()
            PublicKeyEnabled = true
            Library:Notify("Public key enabled globally", 8)
            sendAdvancedEmbed("🔓 Public Key Enabled", "Owner enabled public access", 65280, "Owner", "N/A")
        end)

        ToolsBox:AddButton("View Temp Keys", function()
            local count = 0
            for _ in pairs(Config.TemporaryKeys) do count = count + 1 end
            Library:Notify("Temporary Keys: " .. count .. " total", 8)
        end)

        -- Loader Script
        local LoaderBox = AdminTab:AddRightGroupbox("Loader Script", "upload")
        LoaderBox:AddButton("Load Premium", function()
            getgenv().NYX_Level = "Premium"
            sendAdvancedEmbed("🔐 Owner Load Premium", "Owner cargó Premium manualmente", 65280, "Owner", "Owner")
            Library:Notify("Loading Premium Script...", 6)
            task.wait(1)
            loadScript(true)
        end)

        LoaderBox:AddButton("Load Freemium", function()
            if isPublicValid() then
                getgenv().NYX_Level = "Freemium"
                sendAdvancedEmbed("🔓 Owner Load Freemium", "Owner cargó Freemium manualmente", 3447003, "Owner", "Public")
                Library:Notify("Loading Freemium Script...", 6)
                task.wait(1)
                loadScript(false)
            else
                Library:Notify("Public key is disabled or expired", 8)
            end
        end)
        
        LoaderBox:AddButton("Load Temporal", function()
            getgenv().NYX_Level = "Temporal"
            getgenv().NYX_TempExpiry = os.time() + 86400 -- 1 día por defecto
            sendAdvancedEmbed("⏳ Owner Load Temporal", "Owner cargó Temporal manualmente", 10181046, "Owner", "Temporal")
            Library:Notify("Loading Temporal Script...", 6)
            task.wait(1)
            loadScript(false, true)
        end)
    end

    -- Main Auth Tab
    local AuthTab = AuthWindow:AddTab("Auth", "key")
    local AuthBox = AuthTab:AddLeftGroupbox("Key Verification", "lock")
    
    -- Labels dinámicos
    local ActiveKeyLabel = AuthBox:AddLabel("Active Key: Loading...")
    local ExpireLabel = AuthBox:AddLabel("Key Expires: Calculating...")
    local TempExpireLabel = AuthBox:AddLabel("Temporal Expiry: None")

    -- Actualizar información de expiración temporal
    spawn(function()
        while not Library.Unloaded do
            if getgenv().NYX_Level == "Temporal" and getgenv().NYX_TempExpiry then
                local remaining = getgenv().NYX_TempExpiry - os.time()
                if remaining > 0 then
                    local timeStr = formatTimeRemaining(remaining)
                    local color = remaining > 3600 and "rgb(0, 255, 150)" or "rgb(255, 165, 0)" -- Verde si >1h, naranja si menos
                    if remaining < 300 then color = "rgb(255, 80, 80)" end -- Rojo si <5min
                    TempExpireLabel:SetText("Temporal Expiry: <font color='" .. color .. "'>" .. timeStr .. "</font>")
                else
                    TempExpireLabel:SetText("Temporal Expiry: <font color='rgb(255, 80, 80)'>Expired</font>")
                end
            else
                TempExpireLabel:SetText("Temporal Expiry: None")
            end
            task.wait(1)
        end
    end)

    RunService.Heartbeat:Connect(function()
        if Library.Unloaded then return end
        local keyText = PublicKeyEnabled and Config.PublicKeyRaw or "Disabled by Admin"
        local keyColor = PublicKeyEnabled and "rgb(0, 255, 150)" or "rgb(255, 80, 80)"
        ActiveKeyLabel:SetText("Active Key: <font color='" .. keyColor .. "'>" .. keyText .. "</font>")
        ExpireLabel:SetText("Key Expires: " .. getExpireTimeString())
        if tick() % 30 < 1 then loadAllKeys() end
    end)

    local KeyInput = AuthBox:AddInput("KeyInput", {Text = "Enter Key", Placeholder = "NYX-XXX-XXX-XXX or NYX-TEMP-XXX-XXX-XXX"})
    
    AuthBox:AddButton("Verify & Load Script", function()
        local input = KeyInput.Value:match("^%s*(.-)%s*$")
        if input == "" then
            Library:Notify("Please enter a key", 4)
            sendAdvancedEmbed("⚠️ Empty Key Field", "Usuario dejó el campo vacío", 16776960, "None", "N/A")
            return
        end
        if BannedUserIDs[USERID] then
            Library:Notify("Your UserID is banned", 10)
            sendAdvancedEmbed("❌ Banned UserID", "Intento de acceso con UserID baneado", 16711680, "Banned", "N/A")
            return
        end

        loadAllKeys()

        -- 1. Verificar si es clave premium
        if Config.PremiumKeys[input] then
            if Config.PremiumKeys[input] == USERID then
                saveAuth(input)
                getgenv().NYX_Level = "Premium"
                premiumAuthSequence(false)
                sendAdvancedEmbed("🔐 New Login Detected", "Premium access granted", 65280, "Premium", input, {
                    {name = "🔑 Key Used", value = "`"..input.."`", inline = false},
                    {name = "📊 Type", value = "Premium Key", inline = true}
                })
                task.wait(2)
                loadScript(true)
                return
            else
                BannedUserIDs[USERID] = true
                Library:Notify("Shared key detected. Your UserID has been banned.", 15)
                sendAdvancedEmbed("🚫 Key Shared + Auto-Ban", "Usuario intentó usar key premium de otro UserID → Baneado automáticamente", 16711680, "Banned", input, {
                    {name = "⚠️ Key Attempted", value = "`"..input.."`", inline = false},
                    {name = "👤 Registered UserID", value = "`"..Config.PremiumKeys[input].."`", inline = false},
                    {name = "👤 Banned UserID", value = "`"..USERID.."`", inline = false}
                })
                task.wait(3)
                Library:Unload()
                return
            end
        end

        -- 2. Verificar si es clave temporal
        if Config.TemporaryKeys[input] then
            local keyData = Config.TemporaryKeys[input]
            
            -- Verificar si la clave es para este usuario
            if keyData.UserID and keyData.UserID ~= USERID then
                Library:Notify("This temporary key is not assigned to your UserID", 8)
                sendAdvancedEmbed("❌ Invalid Temporary Key", "Clave temporal asignada a otro usuario", 16711680, "None", input, {
                    {name = "❌ Key Entered", value = "`"..input.."`", inline = false},
                    {name = "👤 Assigned UserID", value = "`"..keyData.UserID.."`", inline = false},
                    {name = "👤 Your UserID", value = "`"..USERID.."`", inline = false}
                })
                return
            end

            -- Activar la clave temporal
            local success, expiryTime = activateTemporaryKey(input)
            if success then
                getgenv().NYX_Level = "Temporal"
                getgenv().NYX_TempExpiry = expiryTime
                
                temporaryAuthSequence(expiryTime)
                
                sendAdvancedEmbed("⏳ Temporary Key Activated", "Temporal access granted", 10181046, "Temporal", input, {
                    {name = "🔑 Key Used", value = "`"..input.."`", inline = false},
                    {name = "📊 Type", value = keyData.Type or "Temporal", inline = true},
                    {name = "⏰ Expires", value = os.date("%d/%m/%Y %H:%M:%S", expiryTime), inline = false},
                    {name = "⏱️ Time Left", value = formatTimeRemaining(expiryTime - os.time()), inline = true}
                })
                
                task.wait(2)
                loadScript(false, true)
                return
            else
                Library:Notify("Temporary key expired or invalid", 8)
                sendAdvancedEmbed("❌ Invalid Temporary Key", "Clave temporal expirada o inválida", 16711680, "None", input, {
                    {name = "❌ Key Entered", value = "`"..input.."`", inline = false}
                })
                return
            end
        end

        -- 3. Verificar clave pública (Freemium)
        local clean = input:gsub("[%s%-%.]", ""):upper()
        if clean == Config.PublicKeyClean and isPublicValid() then
            getgenv().NYX_Level = "Freemium"
            sendAdvancedEmbed("🔐 New Login Detected", "Freemium access with public key", 3447003, "Freemium", "Public", {
                {name = "📊 Type", value = "Public Key", inline = true}
            })
            Library:Notify("Freemium activated", 8)
            task.wait(1.5)
            loadScript(false)
            return
        end

        -- 4. Clave inválida
        Library:Notify("Invalid or expired key", 8)
        sendAdvancedEmbed("❌ Invalid Key", "Key inválida, expirada o no existente", 16711680, "None", input, {
            {name = "❌ Key Entered", value = "`"..input.."`", inline = false},
            {name = "🔍 Key Type", value = "Not found in Premium/Temporary/Public keys", inline = false}
        })
    end)

    AuthBox:AddButton("Close Manually", function()
        sendAdvancedEmbed("🔴 Manual Close", "Cierre manual de la UI", 10181046, getgenv().NYX_Level or "None", "N/A")
        Library:Unload()
    end)

    AuthBox:AddButton("Join Discord", function()
        pcall(function()
            request({Url = "http://127.0.0.1:6463/rpc?v=1", Method = "POST", Headers = {["Content-Type"] = "application/json", ["Origin"] = "https://discord.com"},
                Body = HttpService:JSONEncode({cmd = "INVITE_BROWSER", args = {code = DISCORD_INVITE}, nonce = HttpService:GenerateGUID(false)})})
        end)
        setclipboard("https://discord.gg/" .. DISCORD_INVITE)
        Library:Notify("Discord invite copied / opening", 6)
        sendAdvancedEmbed("📩 Discord Join", "Usuario intentó unirse al servidor", 3447003, getgenv().NYX_Level or "None", "N/A")
    end)

    -- Information Box
    local UserIDBox = AuthTab:AddRightGroupbox("Account Information", "fingerprint")
    UserIDBox:AddButton("Copy my UserID", function()
        setclipboard(USERID)
        Library:Notify("UserID copied to clipboard", 8)
        sendAdvancedEmbed("📋 UserID Copied", "Usuario copió su UserID", 3447003, getgenv().NYX_Level or "None", "N/A")
    end)
    UserIDBox:AddLabel("Your current UserID:")
    UserIDBox:AddLabel(USERID)
    UserIDBox:AddLabel("Username: " .. Player.Name)
    UserIDBox:AddLabel("Display Name: " .. Player.DisplayName)
    
    -- Mostrar información de expiración si es temporal
    if getgenv().NYX_Level == "Temporal" and getgenv().NYX_TempExpiry then
        UserIDBox:AddDivider()
        local remaining = getgenv().NYX_TempExpiry - os.time()
        local color = remaining > 3600 and "rgb(0, 255, 150)" or "rgb(255, 165, 0)"
        if remaining < 300 then color = "rgb(255, 80, 80)" end
        UserIDBox:AddLabel("<font color='" .. color .. "'><b>Temporal Key Active</b></font>")
        UserIDBox:AddLabel("Expires: " .. os.date("%d/%m/%Y %H:%M:%S", getgenv().NYX_TempExpiry))
        UserIDBox:AddLabel("Time Left: " .. formatTimeRemaining(remaining))
    end
    
    UserIDBox:AddDivider()
    UserIDBox:AddLabel("<font color='rgb(0, 255, 150)'><b>💰 MÉTODOS DE ACCESO PREMIUM</b></font>")
    
    UserIDBox:AddLabel("<font color='rgb(255, 215, 0)'>[MÉTODO 1] EFECTIVO:</font>")
    UserIDBox:AddLabel("• 80k EFECTIVO en South Bronx")
    UserIDBox:AddLabel("• Contacta a Nyx @xSh4dow en Discord")
    
    UserIDBox:AddLabel("<font color='rgb(138, 43, 226)'>[MÉTODO 2] DISCORD:</font>")
    UserIDBox:AddLabel("• Invita 6+ usuarios activos (3d+ stay)")
    UserIDBox:AddLabel("• O Boostea el server con Nitro (2x 6d)")
    
    UserIDBox:AddLabel("<font color='rgb(255, 69, 0)'>[KEYS TEMPORALES]:</font>")
    UserIDBox:AddLabel("• 1d / 3d / 7d / 14d / 1w disponibles")
    UserIDBox:AddLabel("• DM para precios & activación instantánea")
    
    UserIDBox:AddLabel("<font color='rgb(255, 0, 0)'>⚠️ NO HAY REEMBOLSOS - TODAS LAS VENTAS SON FINALES</font>")

    -- Suggest Tab
    local SuggestTab = AuthWindow:AddTab("Suggest", "lightbulb")
    local SuggestBox = SuggestTab:AddLeftGroupbox("Send Suggestion", "message")
    local SuggestInput = SuggestBox:AddInput("SuggestText", {Text = "Write your suggestion", Placeholder = "Minimum 20 characters, maximum 300..."})
    SuggestBox:AddButton("Send Suggestion", function()
        local text = SuggestInput.Value:match("^%s*(.-)%s*$")
        local length = #text
        if length < 20 then
            Library:Notify("Suggestion too short (min 20 characters)", 6)
            return
        end
        if length > 300 then
            Library:Notify("Suggestion too long (max 300 characters)", 6)
            return
        end
        sendAdvancedEmbed("💡 New Suggestion", "Usuario envió una sugerencia", 16776960, getgenv().NYX_Level or "None", "N/A", {
            {name = "📝 Suggestion", value = text, inline = false}
        })
        Library:Notify("Suggestion sent successfully!", 8)
        SuggestInput:SetValue("")
    end)
    SuggestBox:AddLabel("Min: 20 characters | Max: 300 characters")
end)

-- ==================== AUTO-LOGIN ====================
-- Primero verificar clave temporal
local tempKey, tempExpiry = loadTempAuth()
if tempKey and tempExpiry and os.time() < tempExpiry and not BannedUserIDs[USERID] then
    getgenv().NYX_Level = "Temporal"
    getgenv().NYX_TempExpiry = tempExpiry
    temporaryAuthSequence(tempExpiry)
    sendAdvancedEmbed("⏳ Temporary Auto-Login", "Temporal access auto-login", 10181046, "Temporal", tempKey, {
        {name = "🔄 Type", value = "Auto-Login", inline = true},
        {name = "⏰ Expires", value = os.date("%d/%m/%Y %H:%M:%S", tempExpiry), inline = false},
        {name = "⏱️ Time Left", value = formatTimeRemaining(tempExpiry - os.time()), inline = true}
    })
    task.wait(3)
    loadScript(false, true)
-- Luego verificar clave premium
else
    local savedKey = loadAuth()
    if savedKey and not BannedUserIDs[USERID] then
        getgenv().NYX_Level = "Premium"
        premiumAuthSequence(true)
        sendAdvancedEmbed("🔐 New Login Detected", "Premium Auto-Login", 65280, "Premium", savedKey, {
            {name = "🔄 Type", value = "Auto-Login", inline = true}
        })
        task.wait(3)
        loadScript(true)
    end
end
