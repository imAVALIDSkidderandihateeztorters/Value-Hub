--// Discord Webhook URL
local WEBHOOK_URL = "https://discord.com/api/webhooks/1426452224049025165/i_wxHlwywVw93a8nYDjDKimn4piyd3Jab83QeWZqyDeEg8ZDRzLfzIj8OhRgnRW7kRtM" -- replace this

--// Services
local HttpService = game:GetService("HttpService")

--// Function to send webhook
local function sendToDiscord()
	local data = {
		["username"] = "script",
		["avatar_url"] = "https://www.roblox.com/favicon.ico",
		["content"] = "Someone Loaded The Script"
	}

	local jsonData = HttpService:JSONEncode(data)

	-- Send webhook
	pcall(function()
		HttpService:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
	end)
end

--// Run automatically when script executes
sendToDiscord()
