local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

getgenv().NYX_Authorized = getgenv().NYX_Authorized or false
getgenv().NYX_Key = getgenv().NYX_Key or ""
getgenv().NYX_HWID = getgenv().NYX_HWID or nil
getgenv().NYX_Level = getgenv().NYX_Level or "None"

-- ==================== CONFIGURATION ====================
local DISCORD_INVITE = "F3SDzkZa6U"
local SUGGEST_WEBHOOK = "https://discord.com/api/webhooks/1453113715200102531/TRzVhwOYlF921oHphBfNIKP0LCwxcwLBfRCD0D1L00fg07Sofj6eSv-4jgt-xSdWHj6O"

-- ==================== PUBLIC KEY CONFIG ====================
local PublicConfig = {
    PublicKeyRaw = "free2025",
    PublicKeyEnabled = true,
    StartDate = "23/12/2025 00:00",
    EndDate = "26/12/2025 23:59",
}

-- ==================== MAIN CONFIG ====================
local Config = {
    PremiumKeys = {},
    BannedKeys = {},
    AdminHWIDs = {},
    OwnerHWID = nil,
    AuthFile = "NYX_Auth.key",
    FreemiumURL = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/Freemium",
    PremiumURL = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/Premium",
    ConfigURL = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/Config.json",
    PremiumKeysURL = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/PremiumKeys.json",
    BannedKeysURL = "https://raw.githubusercontent.com/TexaThebardo/NYXEXOTIC/refs/heads/main/BannedKeys.json",
}

local FREEMIUM_URL = Config.FreemiumURL
local PREMIUM_URL = Config.PremiumURL

-- ==================== LOAD CONFIGS ====================
local function loadGlobalConfig()
    pcall(function()
        local success, response = pcall(function() return game:HttpGet(Config.ConfigURL .. "?t=" .. tick()) end)
        if success and response then
            local data = HttpService:JSONDecode(response)
            if typeof(data) == "table" then
                Config.OwnerHWID = data.OwnerHWID or nil
                Config.AdminHWIDs = typeof(data.AdminHWIDs) == "table" and data.AdminHWIDs or {}
            end
        end
    end)
end

local function loadPremiumKeys()
    pcall(function()
        local success, response = pcall(function() return game:HttpGet(Config.PremiumKeysURL .. "?t=" .. tick()) end)
        if success and response then
            local jsonData = HttpService:JSONDecode(response)
            if typeof(jsonData) == "table" then
                Config.PremiumKeys = jsonData
            end
        end
    end)
end

local function loadBannedKeys()
    pcall(function()
        local success, response = pcall(function() return game:HttpGet(Config.BannedKeysURL .. "?t=" .. tick()) end)
        if success and response then
            local jsonData = HttpService:JSONDecode(response)
            if typeof(jsonData) == "table" then Config.BannedKeys = jsonData end
        end
    end)
end

loadGlobalConfig()
loadPremiumKeys()
loadBannedKeys()

-- ==================== DATE FUNCTIONS ====================
local function parseDate(str)
    local d, m, y, h, min = str:match("(%d%d)/(%d%d)/(%d%d%d%d) (%d%d):(%d%d)")
    if not d then return os.time() end
    return os.time({year = y, month = m, day = d, hour = h, min = min, sec = 0})
end

local START_TIME = parseDate(PublicConfig.StartDate)
local END_TIME = parseDate(PublicConfig.EndDate)

local function isPublicValid()
    if not PublicConfig.PublicKeyEnabled then return false end
    local now = os.time()
    return now >= START_TIME and now < END_TIME
end

local function getExpireTimeString()
    if not PublicConfig.PublicKeyEnabled then return "<font color='rgb(255, 80, 80)'>Disabled by Admin</font>" end
    local now = os.time()
    if now >= END_TIME then return "<font color='rgb(255, 80, 80)'>Expired</font>" end
    if now < START_TIME then return "<font color='rgb(255, 200, 0)'>Not started yet</font>" end
    local diff = END_TIME - now
    local days = math.floor(diff / 86400)
    local h = math.floor((diff % 86400) / 3600)
    local m = math.floor((diff % 86400 % 3600) / 60)
    local s = diff % 60
    return "<font color='rgb(0, 255, 150)'>" .. days .. "d " .. string.format("%02d", h) .. "h " .. string.format("%02d", m) .. "m " .. string.format("%02d", s) .. "s</font>"
end

-- ==================== HWID ====================
local function getHWID()
    if gethwid then return gethwid() end
    if syn and syn.get_hwid then return syn.get_hwid() end
    if identifyexecutor then local _, id = identifyexecutor() if id then return tostring(id) end end
    if getexecutorname then return getexecutorname() end
    local success, hwid = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
    if success and hwid and hwid ~= "" then return hwid end
    return "UNKNOWN_" .. game.Players.LocalPlayer.UserId
end

local HWID = getHWID()

-- ==================== ROLES (FRESH CHECK) ====================
local function isOwner()
    loadGlobalConfig()
    return Config.OwnerHWID and HWID == Config.OwnerHWID
end

local function isAdmin()
    loadGlobalConfig()
    return Config.AdminHWIDs[HWID] == true or isOwner()
end

-- ==================== AUTH FILE ====================
local function saveAuth(key)
    if writefile then writefile(Config.AuthFile, key .. "|" .. HWID) end
end

local function loadAuth()
    if isfile and isfile(Config.AuthFile) and readfile then
        local data = readfile(Config.AuthFile)
        local key, linkedHWID = data:match("^(.-)|(.+)$")
        if key and linkedHWID == HWID then
            loadPremiumKeys()
            loadBannedKeys()
            if Config.BannedKeys[key] then return nil end
            if Config.PremiumKeys[key] and Config.PremiumKeys[key] == HWID then return key end
            if delfile then delfile(Config.AuthFile) end
        end
    end
    return nil
end

-- ==================== WEBHOOK SEND FUNCTION ====================
local function sendToWebhook(data)
    spawn(function()
        local payload = HttpService:JSONEncode(data)
        local attempt = 0
        local maxAttempts = 3
        local success = false

        while attempt < maxAttempts and not success do
            attempt = attempt + 1
            local reqSuccess, response = pcall(function()
                if request then
                    return request({Url = SUGGEST_WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
                elseif syn and syn.request then
                    return syn.request({Url = SUGGEST_WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
                end
            end)

            if reqSuccess and response and (response.StatusCode == 204 or response.StatusCode == 200) then
                success = true
            elseif reqSuccess and response.StatusCode == 429 then
                local retryAfter = tonumber(response.Headers["Retry-After"]) or 5
                task.wait(retryAfter + 1)
            else
                task.wait(3)
            end
        end
    end)
end

-- ==================== LOGIN LOG ====================
local function sendLoginLog()
    spawn(function()
        local player = game.Players.LocalPlayer
        local username = player.Name
        local displayName = player.DisplayName
        local userId = player.UserId

        local thumbnailUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=720&height=720&format=png"
        pcall(function()
            local apiUrl = "https://thumbnails.roblox.com/v1/users/avatar?userIds=" .. userId .. "&size=720x720&format=Png&isCircular=false"
            local success, resp = pcall(game.HttpGet, game, apiUrl)
            if success and resp then
                local json = HttpService:JSONDecode(resp)
                if json.data and json.data[1] and json.data[1].imageUrl then
                    thumbnailUrl = json.data[1].imageUrl
                end
            end
        end)

        local executor = "Unknown"
        if syn then executor = "Synapse X"
        elseif Krnl then executor = "Krnl"
        elseif Fluxus then executor = "Fluxus"
        elseif identifyexecutor then local name = identifyexecutor() executor = name or "Unknown"
        elseif getexecutorname then executor = getexecutorname() end

        local role = "🟢 Freemium"
        local color = 3447003
        if isOwner() then role = "👑 Owner"; color = 16766720
        elseif isAdmin() then role = "🛡️ Admin"; color = 16766720
        elseif getgenv().NYX_Level == "Premium" then role = "🔴 Premium"; color = 16711680 end

        local embedData = {
            username = "NYX Login Logger",
            embeds = {{
                title = "New Login Detected",
                description = "**@" .. displayName .. "** has logged into NYX Exotic",
                color = color,
                fields = {
                    {name = "User Info", value = "**Display:** @" .. displayName .. "\n**Username:** `" .. username .. "`\n**ID:** `" .. userId .. "`", inline = true},
                    {name = "Access Level", value = role, inline = true},
                    {name = "Executor", value = "`" .. executor .. "`", inline = true},
                    {name = "HWID", value = "||" .. HWID .. "||", inline = false},
                    {name = "Time", value = os.date("%d/%m/%Y %H:%M:%S"), inline = false}
                },
                thumbnail = {url = thumbnailUrl},
                footer = {text = "NYX Exotic • Security"},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        sendToWebhook(embedData)
    end)
end

-- ==================== SEND SUGGESTION ====================
local function sendSuggestion(message)
    spawn(function()
        local player = game.Players.LocalPlayer
        local username = player.Name
        local displayName = player.DisplayName
        local userId = player.UserId

        local thumbnailUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=720&height=720&format=png"
        pcall(function()
            local apiUrl = "https://thumbnails.roblox.com/v1/users/avatar?userIds=" .. userId .. "&size=720x720&format=Png&isCircular=false"
            local success, resp = pcall(game.HttpGet, game, apiUrl)
            if success and resp then
                local json = HttpService:JSONDecode(resp)
                if json.data and json.data[1] and json.data[1].imageUrl then
                    thumbnailUrl = json.data[1].imageUrl
                end
            end
        end)

        local executor = "Unknown"
        if syn then executor = "Synapse X" elseif Krnl then executor = "Krnl" elseif Fluxus then executor = "Fluxus"
        elseif identifyexecutor then local name = identifyexecutor() executor = name or "Unknown"
        elseif getexecutorname then executor = getexecutorname() end

        local role = getgenv().NYX_Level == "Premium" and "🔴 Premium" or "🟢 Freemium"
        if isOwner() then role = "👑 Owner" elseif isAdmin() then role = "🛡️ Admin" end

        local embedData = {
            username = "NYX Suggestions",
            embeds = {{
                title = "New Suggestion from @" .. displayName,
                description = message .. "\n\n**Thank you for your feedback!** 🔥",
                color = 9442303,
                fields = {
                    {name = "User Info", value = "**Display:** @" .. displayName .. "\n**Username:** `" .. username .. "`\n**ID:** `" .. userId .. "`", inline = true},
                    {name = "Access Level", value = role, inline = true},
                    {name = "Executor", value = "`" .. executor .. "`", inline = true},
                    {name = "HWID", value = "||" .. HWID .. "||", inline = false},
                    {name = "Sent At", value = os.date("%d/%m/%Y %H:%M:%S"), inline = false}
                },
                thumbnail = {url = thumbnailUrl},
                footer = {text = "NYX Exotic • Suggestions"},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }

        sendToWebhook(embedData)
        Library:Notify("Suggestion sent successfully! ✅", 6)
    end)
end

-- ==================== LOAD SCRIPT ====================
local function loadScript(isPremium)
    task.wait(1)
    pcall(function()
        loadstring(game:HttpGet(isPremium and PREMIUM_URL or FREEMIUM_URL))()
    end)
    task.spawn(function()
        task.wait(0.8)
        Library:Unload()
    end)
end

-- ==================== UI ====================
local AuthWindow = Library:CreateWindow({
    Title = " И Ξ Ｘ",
    Icon = 94564569718126,
    Footer = "SYSTEM AUTH KEY - NYX @xSh4dow",
    AutoShow = true,
    ShowCustomCursor = false,
    NotifySide = "Right"
})

local AuthTab = AuthWindow:AddTab("Auth", "key")

local AuthBox = AuthTab:AddLeftGroupbox("Key Verification", "lock")

local ActiveKeyLabel = AuthBox:AddLabel("Active Key: Loading...")
local ExpireLabel = AuthBox:AddLabel("Expires in: Calculating...")

RunService.Heartbeat:Connect(function()
    if Library.Unloaded then return end
    local keyText = PublicConfig.PublicKeyEnabled and PublicConfig.PublicKeyRaw or "Disabled by Admin"
    local keyColor = PublicConfig.PublicKeyEnabled and "rgb(0, 255, 150)" or "rgb(255, 80, 80)"
    ActiveKeyLabel:SetText("Active Key: <font color='" .. keyColor .. "'>" .. keyText .. "</font>")
    ExpireLabel:SetText("Expires in: " .. getExpireTimeString())
    
    if tick() % 30 < 1 then
        loadGlobalConfig()
        loadPremiumKeys()
        loadBannedKeys()
    end
end)

local KeyInput = AuthBox:AddInput("KeyInput", {Text = "Enter Key", Placeholder = "Type your key here (case sensitive for premium)"})

AuthBox:AddButton("Verify & Load", function()
    local input = KeyInput.Value:match("^%s*(.-)%s*$")  -- Solo quita espacios al inicio/final

    if input == "" then
        Library:Notify("Please enter a key", 4)
        return
    end

    -- Reload fresh data
    loadPremiumKeys()
    loadBannedKeys()

    if Config.BannedKeys[input] then
        Library:Notify("This key is permanently banned", 10)
        return
    end

    -- PREMIUM KEY: EXACT MATCH (case sensitive, with hyphens, symbols, etc.)
    if Config.PremiumKeys[input] then
        if Config.PremiumKeys[input] == HWID then
            saveAuth(input)
            getgenv().NYX_Level = "Premium"
            Library:Notify("Premium activated successfully", 10)
            sendLoginLog()
            task.wait(1.5)
            loadScript(true)
        else
            Library:Notify("This key belongs to another HWID", 10)
            Library:Notify("Unauthorized use attempt detected", 8)
        end
        return
    end

    -- PUBLIC KEY: Flexible (ignore spaces, hyphens, dots, case)
    local cleanInput = input:gsub("[%s%-%.]", ""):upper()
    local cleanPublic = PublicConfig.PublicKeyRaw:gsub("[%s%-%.]", ""):upper()

    if cleanInput == cleanPublic and isPublicValid() then
        getgenv().NYX_Level = "Freemium"
        Library:Notify("Freemium activated", 8)
        sendLoginLog()
        task.wait(1.5)
        loadScript(false)
        return
    end

    Library:Notify("Invalid key", 6)
end)

AuthBox:AddButton("Close Manually", function() Library:Unload() end)

AuthBox:AddButton("Join Discord", function()
    local success = pcall(function()
        request({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json", ["Origin"] = "https://discord.com"},
            Body = HttpService:JSONEncode({
                cmd = "INVITE_BROWSER",
                args = {code = DISCORD_INVITE},
                nonce = HttpService:GenerateGUID(false)
            })
        })
    end)
    if success then
        Library:Notify("Opening Discord...", 4)
    else
        setclipboard("https://discord.gg/" .. DISCORD_INVITE)
        Library:Notify("Link copied to clipboard", 6)
    end
end)

local HWIDBox = AuthTab:AddRightGroupbox("HWID Information", "fingerprint")
HWIDBox:AddButton("Copy My HWID", function()
    setclipboard(HWID)
    Library:Notify("HWID copied to clipboard", 8)
end)
HWIDBox:AddLabel("Your current HWID:")
HWIDBox:AddLabel(HWID)
HWIDBox:AddDivider()
HWIDBox:AddLabel("<font color='rgb(0, 255, 150)'><b>How to get Premium?</b></font>")
HWIDBox:AddLabel("1. Copy your HWID")
HWIDBox:AddLabel("2. Join the Discord")
HWIDBox:AddLabel("3. Send your HWID to the owner")
HWIDBox:AddLabel("4. Buy your key and enjoy 🔥")

-- Suggest Tab
pcall(function()
    local SuggestTab = AuthWindow:AddTab("Suggest", "lightbulb")
    local SuggestBox = SuggestTab:AddLeftGroupbox("Send Suggestion", "message_square")
    SuggestBox:AddLabel("Write your suggestion below and send it to the developers:")
    local SuggestionInput = SuggestBox:AddInput("SuggestionInput", {Text = "Your suggestion", Placeholder = "Type your suggestion here...", Multiline = true})
    SuggestBox:AddButton("Send Suggestion", function()
        local text = SuggestionInput.Value
        if not text or text:match("^%s*$") then
            Library:Notify("Please write a suggestion first", 5)
            return
        end
        sendSuggestion(text)
        SuggestionInput.Value = ""
    end)
end)

-- Admin Panel
task.spawn(function()
    task.wait(2)
    loadGlobalConfig()
    if isOwner() or isAdmin() then
        pcall(function()
            local AdminTab = AuthWindow:AddTab("Admin", "shield")

            local PublicControlBox = AdminTab:AddLeftGroupbox("Public Key Control", "key")
            PublicControlBox:AddToggle("PublicKeyToggle", {Text = "Public Key Enabled", Default = PublicConfig.PublicKeyEnabled, Callback = function(state)
                PublicConfig.PublicKeyEnabled = state
                Library:Notify("Public key " .. (state and "enabled" or "disabled"), 6)
            end})
            PublicControlBox:AddInput("PublicKeyInput", {Text = "Public Key", Placeholder = PublicConfig.PublicKeyRaw, Callback = function(value)
                if value ~= "" then
                    PublicConfig.PublicKeyRaw = value
                    Library:Notify("Public key updated to: " .. value, 8)
                end
            end})
            PublicControlBox:AddInput("StartDateInput", {Text = "Start Date", Placeholder = PublicConfig.StartDate, Callback = function(value)
                if value ~= "" then
                    PublicConfig.StartDate = value
                    START_TIME = parseDate(value)
                    Library:Notify("Start date updated", 6)
                end
            end})
            PublicControlBox:AddInput("EndDateInput", {Text = "End Date", Placeholder = PublicConfig.EndDate, Callback = function(value)
                if value ~= "" then
                    PublicConfig.EndDate = value
                    END_TIME = parseDate(value)
                    Library:Notify("End date updated", 6)
                end
            end})

            local BanKeyBox = AdminTab:AddLeftGroupbox("Ban Premium Key", "ban")
            local BanKeyInput = BanKeyBox:AddInput("BanKeyInput", {Text = "Key to ban", Placeholder = "Paste exact key here"})
            BanKeyBox:AddButton("Copy Ban Format", function()
                local key = BanKeyInput.Value
                if key == "" then
                    Library:Notify("Enter a key first", 5)
                    return
                end
                setclipboard("\"" .. key .. "\": true")
                Library:Notify("Ban format copied for BannedKeys.json", 10)
            end)

            local ToolsBox = AdminTab:AddRightGroupbox("Admin Tools", "tools")
            ToolsBox:AddButton("Reload All Data", function()
                loadGlobalConfig()
                loadPremiumKeys()
                loadBannedKeys()
                Library:Notify("All data reloaded", 5)
            end)
            ToolsBox:AddButton("Load Premium Script", function() loadScript(true) end)
            ToolsBox:AddButton("Load Freemium Script", function() loadScript(false) end)
            ToolsBox:AddButton("Close GUI", function() Library:Unload() end)
        end)
    end
end)

-- Auto-login
local savedKey = loadAuth()
if savedKey then
    getgenv().NYX_Level = "Premium"
    Library:Notify("Premium auto-login", 8)
    sendLoginLog()
    task.wait(1.5)
    loadScript(true)
end

-- Owner/Admin login log
task.spawn(function()
    task.wait(4)
    loadGlobalConfig()
    if (isOwner() or isAdmin()) and getgenv().NYX_Level == "None" then
        getgenv().NYX_Level = isOwner() and "Owner" or "Admin"
        sendLoginLog()
    end
end)

Library:OnUnload(function()
    getgenv().NYX_Authorized = nil
    getgenv().NYX_Key = nil
    getgenv().NYX_HWID = nil
    getgenv().NYX_Level = nil
end)
