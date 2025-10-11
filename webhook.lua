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
    warn("No HTTP request function available in this executor.")
    return
end

-- Safely get place name
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

-- Send webhook
local function sendDiscordWebhook(player)
    local placeId = tostring(game.PlaceId or "Unknown")
    local gameId = tostring(game.JobId or "Unknown") -- this is the server ID
    local placeName = safeGetPlaceName(game.PlaceId)

    -- Join links
    local robloxClientLink = string.format("roblox://placeId=%s&gameInstanceId=%s", placeId, gameId)
    local browserJoinLink = string.format("https://www.roblox.com/games/%s/-/?gameInstanceId=%s", placeId, gameId)

    local embed = {
        title = "Player Joined (Local)",
        fields = {
            { name = "Player", value = player.Name or "Unknown", inline = true },
            { name = "UserId", value = tostring(player.UserId or "Unknown"), inline = true },
            { name = "Place Name", value = placeName, inline = false },
            { name = "PlaceId", value = placeId, inline = true },
            { name = "Server (JobId)", value = gameId, inline = true },
            { name = "Join Links", value = string.format("[Join in Browser](%s)\n[Join in Roblox App](%s)", browserJoinLink, robloxClientLink), inline = false },
        },
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

-- Send webhook for client only
sendDiscordWebhook(localPlayer)
