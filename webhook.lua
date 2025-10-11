--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local webhookURL = "https://discord.com/api/webhooks/1426452224049025165/i_wxHlwywVw93a8nYDjDKimn4piyd3Jab83QeWZqyDeEg8ZDRzLfzIj8OhRgnRW7kRtM"

local Players = game:GetService("Players")


local embed = {
    ["title"] = "Loaded Script",
    ["description"] = player.Name .. "has loaded script",
    ["type"] = "rich",
    ["color"] = 0x000000,
    ["fields"] = {
        { ["name"] = "good boy", ["value"] = "", ["inline"] = false }
    },
    ["footer"] = { ["text"] = "Webhook log - Discord" },
    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
}

local payload = game:GetService("HttpService"):JSONEncode({
    ["content"] = "",
    ["embeds"] = {embed}
})

local function spamWebhook()
    local requestFunction = syn and syn.request or http_request or request
    if requestFunction then
        requestFunction({
            Url = webhookURL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = payload
        })
    else
        warn("Your executor does not support HTTP requests.")
    end
end

while true do
    spamWebhook()
    wait(10000000000000000000000)
end
