local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer

local WEBHOOK_URL = "https://discord.com/api/webhooks/1426452224049025165/i_wxHlwywVw93a8nYDjDKimn4piyd3Jab83QeWZqyDeEg8ZDRzLfzIj8OhRgnRW7kRtM"

local requestFunc =
    (syn and syn.request) or
    (http and http.request) or
    http_request or
    request

if not requestFunc then
    warn("no HTTP request function available in this executor, sorry")
    return
end

local function safeGetPlaceName(placeId)
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(placeId)
    end)
    if success and info and info.Name then
        return info.Name
    else
        return "Unknown Place"
    end
end

local function getAvatarUrl(userId)
    local url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..userId.."&size=420x420&format=Png&isCircular=false"
    local response = requestFunc({Url = url, Method = "GET"})
    if response and response.Body then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.data and data.data[1] and data.data[1].imageUrl then
            return data.data[1].imageUrl
        end
    end
    return nil
end

local function sendDiscordWebhook(player)
    local placeId = tostring(game.PlaceId or "Unknown")
    local gameId = tostring(game.GameId or "Unknown")
    local placeName = safeGetPlaceName(game.PlaceId)
    
    local avatarUrl = getAvatarUrl(player.UserId) or ""

    local embed = {
        title = "Player Loaded Script",
        fields = {
            { name = "Player", value = player.Name or "Unknown", inline = true },
            { name = "UserId", value = tostring(player.UserId or "Unknown"), inline = true },
            { name = "Place Name", value = placeName, inline = false },
            { name = "PlaceId", value = placeId, inline = true },
            { name = "GameId", value = gameId, inline = true },
        },
        thumbnail = { url = avatarUrl },  -- working avatar URL
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    local payload = {
        username = "Roblox Client",
        embeds = { embed }
    }

    requestFunc({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload)
    })
end

sendDiscordWebhook(localPlayer)
