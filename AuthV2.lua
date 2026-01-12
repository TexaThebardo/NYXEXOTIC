local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
getgenv().NYX_Authorized = getgenv().NYX_Authorized or false
getgenv().NYX_Key = getgenv().NYX_Key or ""
getgenv().NYX_UserID = getgenv().NYX_UserID or Player.UserId
getgenv().NYX_Level = getgenv().NYX_Level or "None"
-- ==================== CONFIGURATION ====================
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1453113715200102531/TRzVhwOYlF921oHphBfNIKP0LCwxcwLBfRCD0D1L00fg07Sofj6eSv-4jgt-xSdWHj6O"
local OWNER_USERID = "3665809170" -- Reemplaza con tu UserID de Roblox
local DISCORD_INVITE = "F3SDzkZa6U"
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
-- ==================== EMBED AVANZADO ====================
local function sendAdvancedEmbed(title, description, color, accessLevel, keyUsed, extraFields)
    local embed = {
        title = title,
        description = description,
        color = color,
        fields = {
            {name = "👤 Usuario", value = "**Display:** @" .. Player.DisplayName .. "\n**Username:** " .. Player.Name .. "\n**ID:** " .. Player.UserId, inline = false},
            {name = "🛡️ Nivel de Acceso", value = (accessLevel == "Premium" and "🔑" or accessLevel == "Freemium" and "🔓" or accessLevel == "Owner" and "👑" or "❌") .. " **" .. accessLevel .. "**", inline = true},
            {name = "⚙️ Executor", value = "**" .. getExecutorName() .. "**", inline = true},
            {name = "🆔 UserID", value = "```" .. Player.UserId .. "```", inline = false},
            {name = "⏰ Fecha y Hora", value = getFormattedDate(), inline = false}
        },
        footer = {text = "NYX Exotic • Security System"},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    if extraFields then
        for _, f in pairs(extraFields) do table.insert(embed.fields, f) end
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
    PublicKeyRaw = "NewYear2026!",
    PublicKeyClean = "",
    StartDate = "01/01/2026 00:00",
    EndDate = "15/01/2026 23:59",
    AuthFile = "NYX_Auth.key",
    FreemiumURL = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/Freemium",
    PremiumURL = "https://raw.githubusercontent.com/TexaThebardo/nyx/refs/heads/main/premium",
    PremiumKeysURL = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/PremiumKeys.json",
}
Config.PublicKeyClean = Config.PublicKeyRaw:gsub("[%s%-%.]", ""):upper()
local FREEMIUM_URL = Config.FreemiumURL
local PREMIUM_URL = Config.PremiumURL
local PublicKeyEnabled = true
local BannedUserIDs = {}
local ActiveUsers = {}
-- ==================== LOAD PREMIUM KEYS ====================
local function loadPremiumKeys()
    pcall(function()
        local success, response = pcall(game.HttpGet, game, Config.PremiumKeysURL)
        if success and response then
            local jsonData = HttpService:JSONDecode(response)
            if typeof(jsonData) == "table" then Config.PremiumKeys = jsonData end
        end
    end)
end
loadPremiumKeys()
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
-- ==================== USERID (REEMPLAZA HWID) ====================
local USERID = tostring(Player.UserId)
-- ==================== AUTH FILE ====================
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
local function loadScript(isPremium)
    task.wait(1)
    local url = isPremium and PREMIUM_URL or FREEMIUM_URL
    pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    task.wait(1.2)
    if not Library.Unloaded then Library:Unload() end
end
-- ==================== PREMIUM SEQUENCE ====================
local function premiumAuthSequence(isAutoLogin)
    if isAutoLogin then
        Library:Notify("Validating your premium key, please wait 5s", 6)
        task.wait(5)
        Library:Notify("Key validated successfully", 6)
        task.wait(1.5)
        Library:Notify("Auto-Login", 8)
    else
        Library:Notify("Premium Accessed", 8)
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
    local AdminTab -- Declaramos aquí para usar después

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
        ToolsBox:AddButton("Reload Premium Keys", function()
            loadPremiumKeys()
            Library:Notify("Premium keys reloaded from GitHub", 6)
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

        ToolsBox:AddButton("Force Close All Users", function()
            Library:Notify("This would kick all users (webhook only log)", 8)
            sendAdvancedEmbed("🚪 Force Close", "Owner requested force close for all users", 16711680, "Owner", "N/A")
        end)

        -- === NUEVO GRUPO DENTRO DE ADMIN: LOADER SCRIPT ===
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
    end

    -- Tabs normales (visibles para todos)
    local AuthTab = AuthWindow:AddTab("Auth", "key")

    local AuthBox = AuthTab:AddLeftGroupbox("Key Verification", "lock")
    local ActiveKeyLabel = AuthBox:AddLabel("Active Key: Loading...")
    local ExpireLabel = AuthBox:AddLabel("Key Expires: Calculating...")

    RunService.Heartbeat:Connect(function()
        if Library.Unloaded then return end
        local keyText = PublicKeyEnabled and Config.PublicKeyRaw or "Disabled by Admin"
        local keyColor = PublicKeyEnabled and "rgb(0, 255, 150)" or "rgb(255, 80, 80)"
        ActiveKeyLabel:SetText("Active Key: <font color='" .. keyColor .. "'>" .. keyText .. "</font>")
        ExpireLabel:SetText("Key Expires: " .. getExpireTimeString())
        if tick() % 30 < 1 then loadPremiumKeys() end
    end)

    local KeyInput = AuthBox:AddInput("KeyInput", {Text = "Enter Key", Placeholder = "Enter your key here..."})
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

        loadPremiumKeys()

        -- === DETECCIÓN DE KEY COMPARTIDA + AUTO-BAN ===
        if Config.PremiumKeys[input] then
            if Config.PremiumKeys[input] == USERID then
                saveAuth(input)
                getgenv().NYX_Level = "Premium"
                premiumAuthSequence(false)
                sendAdvancedEmbed("🔐 New Login Detected", "Premium access granted", 65280, "Premium", input, {{name = "🔑 Key Used", value = "`"..input.."`", inline = false}})
                task.wait(2)
                loadScript(true)
            else
                -- KEY PREMIUM DE OTRO USERID → AUTO-BAN
                BannedUserIDs[USERID] = true
                Library:Notify("Shared key detected. Your UserID has been banned.", 15)
                sendAdvancedEmbed("🚫 Key Shared + Auto-Ban", "Usuario intentó usar key premium de otro UserID → Baneado automáticamente", 16711680, "Banned", input, {
                    {name = "⚠️ Key Attempted", value = "`"..input.."`", inline = false},
                    {name = "👤 Registered UserID", value = "`"..Config.PremiumKeys[input].."`", inline = false},
                    {name = "👤 Banned UserID", value = "`"..USERID.."`", inline = false}
                })
                task.wait(3)
                Library:Unload()
            end
            return
        end

        -- Public Key (Freemium)
        local clean = input:gsub("[%s%-%.]", ""):upper()
        if clean == Config.PublicKeyClean and isPublicValid() then
            getgenv().NYX_Level = "Freemium"
            sendAdvancedEmbed("🔐 New Login Detected", "Freemium access with public key", 3447003, "Freemium", "Public")
            Library:Notify("Freemium activated", 8)
            task.wait(1.5)
            loadScript(false)
            return
        end

        Library:Notify("Invalid or expired key", 8)
        sendAdvancedEmbed("❌ Invalid Key", "Key inválida, expirada o no existente", 16711680, "None", input, {{name = "❌ Key Entered", value = "`"..input.."`", inline = false}})
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
    UserIDBox:AddLabel("<font color='rgb(0, 255, 150)'><b>How to get Premium?</b></font>")
    UserIDBox:AddLabel("1. Copy your UserID")
    UserIDBox:AddLabel("2. Join Discord")
    UserIDBox:AddLabel("3. Send your UserID")
    UserIDBox:AddLabel("4. Buy and enjoy")

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
local savedKey = loadAuth()
if savedKey and not BannedUserIDs[USERID] then
    getgenv().NYX_Level = "Premium"
    premiumAuthSequence(true)
    sendAdvancedEmbed("🔐 New Login Detected", "Premium Auto-Login", 65280, "Premium", savedKey, {{name = "🔄 Type", value = "Auto-Login", inline = true}})
    task.wait(3)
    loadScript(true)
end
