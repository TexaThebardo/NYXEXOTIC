local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer

getgenv().NYX_Authorized = getgenv().NYX_Authorized or false
getgenv().NYX_Key = getgenv().NYX_Key or ""
getgenv().NYX_UserID = getgenv().NYX_UserID or Player.UserId
getgenv().NYX_Level = getgenv().NYX_Level or "None"
getgenv().NYX_TempExpiry = getgenv().NYX_TempExpiry or nil

-- ==================== CONFIGURATION ====================
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1453113715200102531/TRzVhwOYlF921oHphBfNIKP0LCwxcwLBfRCD0D1L00fg07Sofj6eSv-4jgt-xSdWHj6O"
local OWNER_USERID = "" -- Reemplaza con tu UserID de Roblox
local DISCORD_INVITE = "F3SDzkZa6U"

-- URLs para los sistemas de claves
local TEMP_KEYS_URL = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/TemporaryKey.json"
local PREMIUM_KEYS_URL = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/PremiumKeys.json"

-- Configuración de duraciones temporales
local TEMP_DURATIONS = {
    ["1d"] = 86400,
    ["3d"] = 259200,
    ["7d"] = 604800,
    ["14d"] = 1209600,
    ["1w"] = 604800,
    ["1 month"] = 2592000
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
    local function getBestImageUrl()
        local urls = {
            string.format("https://tr.rbxcdn.com/%s/150/150/AvatarHeadshot/Png", Player.UserId),
            string.format("https://tr.rbxcdn.com/%s/150/150/Avatar/Png", Player.UserId),
            string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=Png", Player.UserId),
            string.format("https://www.roblox.com/bust-thumbnail/image?userId=%d&width=150&height=150&format=Png", Player.UserId),
            string.format("https://www.roblox.com/avatar-thumbnail/image?userId=%d&width=150&height=150&format=Png", Player.UserId)
        }
        
        return urls[1]
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
    
    table.insert(embed.fields, {
        name = "👤 Información del Usuario",
        value = "**Display:** @" .. Player.DisplayName .. 
                "\n**Username:** " .. Player.Name .. 
                "\n**UserID:** `" .. Player.UserId .. "`",
        inline = false
    })
    
    if keyUsed and keyUsed ~= "N/A" and keyUsed ~= "Public" and keyUsed ~= "Owner UserID" then
        table.insert(embed.fields, {
            name = "🔑 Clave Usada",
            value = "```" .. keyUsed .. "```",
            inline = false
        })
    end
    
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
    
    table.insert(embed.fields, {
        name = "⚙️ Executor",
        value = "**" .. getExecutorName() .. "**",
        inline = true
    })
    
    table.insert(embed.fields, {
        name = "⏰ Fecha y Hora",
        value = getFormattedDate(),
        inline = false
    })
    
    if extraFields then
        for _, f in pairs(extraFields) do 
            table.insert(embed.fields, f) 
        end
    end
    
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
    TempAuthFile = "NYX_TempAuth.key",
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
                print("[NYX] Premium keys loaded successfully")
                print("[NYX] Total premium keys: " .. tostring(#jsonData))
                -- Debug: mostrar primeras 3 claves
                local count = 0
                for key, value in pairs(jsonData) do
                    if count < 3 then
                        print("[NYX] Key: " .. key .. " -> UserID: " .. value)
                        count = count + 1
                    end
                end
            else
                print("[NYX] Error: Premium keys JSON is not a table")
            end
        else
            print("[NYX] Error loading premium keys from: " .. Config.PremiumKeysURL)
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
                print("[NYX] Temporary keys loaded successfully")
                print("[NYX] Total temporary keys: " .. tostring(#jsonData))
            end
        else
            print("[NYX] Error loading temporary keys from: " .. Config.TempKeysURL)
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
print("[NYX] Current UserID: " .. USERID)
print("[NYX] Username: " .. Player.Name)

-- ==================== VERIFICACIÓN DE CLAVES ====================
local function verifyPremiumKey(key, userId)
    if Config.PremiumKeys[key] then
        local storedUserId = tostring(Config.PremiumKeys[key])
        local inputUserId = tostring(userId)
        
        print("[NYX] Verifying premium key: " .. key)
        print("[NYX] Stored UserID: " .. storedUserId)
        print("[NYX] Input UserID: " .. inputUserId)
        print("[NYX] Match: " .. tostring(storedUserId == inputUserId))
        
        return storedUserId == inputUserId
    end
    print("[NYX] Key not found: " .. key)
    return false
end

local function isUserIDInPremiumKeys(userId)
    local inputUserId = tostring(userId)
    print("[NYX] Searching UserID in premium keys: " .. inputUserId)
    
    for key, storedUserId in pairs(Config.PremiumKeys) do
        if tostring(storedUserId) == inputUserId then
            print("[NYX] Found UserID in key: " .. key)
            return true, key
        end
    end
    
    print("[NYX] UserID not found in premium keys")
    return false, nil
end

local function isUserIDInTempKeys(userId)
    local inputUserId = tostring(userId)
    
    for key, keyData in pairs(Config.TemporaryKeys) do
        if keyData.UserID and tostring(keyData.UserID) == inputUserId then
            if keyData.ExpiresAt and os.time() < keyData.ExpiresAt then
                return true, key
            end
        end
    end
    return false, nil
end

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
                if delfile then delfile(Config.TempAuthFile) end
                return nil
            end
        end
    end
    return nil
end

local function activateTemporaryKey(key)
    if not Config.TemporaryKeys[key] then return false end
    
    local keyData = Config.TemporaryKeys[key]
    
    if keyData.ActivatedAt then
        if keyData.ExpiresAt and os.time() > keyData.ExpiresAt then
            return false, "Key expired"
        end
    else
        keyData.ActivatedAt = os.time()
        keyData.ExpiresAt = os.time() + keyData.Duration
    end
    
    saveTempAuth(key, keyData.ExpiresAt)
    
    return true, keyData.ExpiresAt
end

local function checkTemporaryAccess()
    if getgenv().NYX_Level == "Temporal" and getgenv().NYX_TempExpiry then
        if os.time() >= getgenv().NYX_TempExpiry then
            getgenv().NYX_Level = "None"
            getgenv().NYX_TempExpiry = nil
            if delfile and isfile(Config.TempAuthFile) then
                delfile(Config.TempAuthFile)
            end
            return false, "Tiempo expirado"
        end
        
        loadTemporaryKeys()
        local userInKeys, userKey = isUserIDInTempKeys(USERID)
        
        if not userInKeys then
            getgenv().NYX_Level = "None"
            getgenv().NYX_TempExpiry = nil
            if delfile and isfile(Config.TempAuthFile) then
                delfile(Config.TempAuthFile)
            end
            return false, "UserID removido de las claves temporales"
        end
        
        return true, getgenv().NYX_TempExpiry - os.time()
    end
    return false, "No es temporal"
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
            
            if verifyPremiumKey(key, USERID) then
                return key 
            else 
                deleteAuth()
                return nil
            end
        end
    end
    return nil
end

-- ==================== SEQUENCES ====================
local function premiumAuthSequence(isAutoLogin)
    local message = isAutoLogin and "Premium auto-login successful!" or "Premium key activated!"
    Library:Notify(message, 10)
end

local function temporaryAuthSequence(expiryTime)
    local remaining = expiryTime - os.time()
    local timeStr = formatTimeRemaining(remaining)
    Library:Notify("Clave Temporal Activada! Expira en: " .. timeStr, 10)
    
    spawn(function()
        while getgenv().NYX_Level == "Temporal" and not Library.Unloaded do
            local hasAccess, reason = checkTemporaryAccess()
            if not hasAccess then
                getgenv().NYX_Level = "None"
                Library:Notify("¡Tu acceso temporal ha sido revocado! Razón: " .. reason, 10)
                sendAdvancedEmbed("🔒 Temporal Access Revoked", "Temporal access was revoked", 16711680, "None", "N/A", {
                    {name = "👤 UserID", value = "`"..USERID.."`", inline = false},
                    {name = "📊 Reason", value = reason, inline = false}
                })
                break
            end
            task.wait(10)
        end
    end)
end

-- ==================== LOAD SCRIPT ====================
local function loadScript(isPremium, isTemporal)
    task.wait(1)
    local url = isPremium and PREMIUM_URL or FREEMIUM_URL
    if isTemporal then
        url = PREMIUM_URL
    end
    pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    task.wait(1.2)
    if not Library.Unloaded then Library:Unload() end
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
            getgenv().NYX_TempExpiry = os.time() + 86400
            sendAdvancedEmbed("⏳ Owner Load Temporal", "Owner cargó Temporal manualmente", 10181046, "Owner", "Temporal")
            Library:Notify("Loading Temporal Script...", 6)
            task.wait(1)
            loadScript(false, true)
        end)
    end

    -- Main Auth Tab
    local AuthTab = AuthWindow:AddTab("Auth", "key")
    local AuthBox = AuthTab:AddLeftGroupbox("Key Verification", "lock")
    
    local ActiveKeyLabel = AuthBox:AddLabel("Active Key: Loading...")
    local ExpireLabel = AuthBox:AddLabel("Key Expires: Calculating...")
    local TempExpireLabel = AuthBox:AddLabel("<font color='rgb(255, 80, 80)'>Temporal Expiry: None</font>")

    spawn(function()
        while not Library.Unloaded do
            if getgenv().NYX_Level == "Temporal" then
                local hasAccess, timeLeft = checkTemporaryAccess()
                
                if hasAccess then
                    local timeStr = formatTimeRemaining(timeLeft)
                    local color = timeLeft > 3600 and "rgb(0, 255, 150)" or "rgb(255, 165, 0)"
                    if timeLeft < 300 then color = "rgb(255, 80, 80)" end
                    TempExpireLabel:SetText("Temporal Expiry: <font color='" .. color .. "'>" .. timeStr .. "</font>")
                else
                    getgenv().NYX_Level = "None"
                    TempExpireLabel:SetText("<font color='rgb(255, 80, 80)'>Temporal Expiry: None (Revoked)</font>")
                    Library:Notify("Tu acceso temporal ha sido revocado", 10)
                end
            else
                TempExpireLabel:SetText("<font color='rgb(255, 80, 80)'>Temporal Expiry: None</font>")
            end
            task.wait(5)
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

    local KeyInput = AuthBox:AddInput("KeyInput", {Text = "Enter Key", Placeholder = "Enter your premium or temporal key"})
    
    AuthBox:AddButton("Verify & Load Script", function()
        local input = KeyInput.Value:match("^%s*(.-)%s*$")
        print("[NYX] User entered key: " .. input)
        
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

        -- 1. Verificar clave temporal
        if Config.TemporaryKeys[input] then
            print("[NYX] Found in temporary keys")
            local keyData = Config.TemporaryKeys[input]
            
            if keyData.UserID and keyData.UserID ~= USERID then
                Library:Notify("This temporary key is not assigned to your UserID", 8)
                sendAdvancedEmbed("❌ Invalid Temporary Key", "Clave temporal asignada a otro usuario", 16711680, "None", input, {
                    {name = "❌ Key Entered", value = "`"..input.."`", inline = false},
                    {name = "👤 Assigned UserID", value = "`"..keyData.UserID.."`", inline = false},
                    {name = "👤 Your UserID", value = "`"..USERID.."`", inline = false}
                })
                return
            end

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

        -- 2. Verificar clave premium
        print("[NYX] Checking premium key...")
        if verifyPremiumKey(input, USERID) then
            print("[NYX] Premium key verified successfully!")
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
            -- Si la clave existe pero no es para este usuario
            if Config.PremiumKeys[input] then
                print("[NYX] Key exists but for different UserID")
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

        -- 3. Verificar clave pública
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
        print("[NYX] Key not found in any system")
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
local tempKey, tempExpiry = loadTempAuth()
if tempKey and tempExpiry and os.time() < tempExpiry and not BannedUserIDs[USERID] then
    loadTemporaryKeys()
    local userInKeys, userKey = isUserIDInTempKeys(USERID)
    
    if userInKeys then
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
    else
        if delfile and isfile(Config.TempAuthFile) then
            delfile(Config.TempAuthFile)
        end
        getgenv().NYX_Level = "None"
        Library:Notify("Tu acceso temporal ha sido revocado", 10)
        sendAdvancedEmbed("🔒 Temporal Access Revoked", "User removed from temporary keys", 16711680, "None", "N/A", {
            {name = "👤 UserID", value = "`"..USERID.."`", inline = false},
            {name = "📊 Reason", value = "Removed from TemporaryKey.json", inline = false}
        })
    end
else
    local savedKey = loadAuth()
    if savedKey and not BannedUserIDs[USERID] then
        loadPremiumKeys()
        if verifyPremiumKey(savedKey, USERID) then
            getgenv().NYX_Level = "Premium"
            premiumAuthSequence(true)
            sendAdvancedEmbed("🔐 New Login Detected", "Premium Auto-Login", 65280, "Premium", savedKey, {
                {name = "🔄 Type", value = "Auto-Login", inline = true}
            })
            task.wait(3)
            loadScript(true)
        else
            getgenv().NYX_Level = "None"
            Library:Notify("Tu acceso premium ha sido revocado", 10)
            sendAdvancedEmbed("🔒 Premium Access Revoked", "User removed from premium keys", 16711680, "None", "N/A", {
                {name = "👤 UserID", value = "`"..USERID.."`", inline = false},
                {name = "📊 Reason", value = "Removed from PremiumKeys.json", inline = false}
            })
        end
    end
end
