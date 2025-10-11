--// Discord Webhook URL
local WEBHOOK_URL = "https://discord.com/api/webhooks/1426452224049025165/i_wxHlwywVw93a8nYDjDKimn4piyd3Jab83QeWZqyDeEg8ZDRzLfzIj8OhRgnRW7kRtM" -- replace with your webhook

--// Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

--// Function to send message
local function sendToDiscord(player)
	local data = {
		["username"] = "script",
		["avatar_url"] = "https://www.roblox.com/favicon.ico",
		["embeds"] = {{
			["title"] = "User Loaded Script",
			["description"] = player.Name .. " ColdWare On Top",
			["color"] = 65280, -- green
			["fields"] = {
				{
					["name"] = "User ID",
					["value"] = tostring(player.UserId),
					["inline"] = true
				},
				{
					["name"] = "Time",
					["value"] = os.date("%Y-%m-%d %H:%M:%S"),
					["inline"] = true
				}
			}
		}}
	}

	local jsonData = HttpService:JSONEncode(data)

	-- Use pcall to prevent game errors if webhook fails
	pcall(function()
		HttpService:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
	end)
end

--// Connect to PlayerAdded
Players.PlayerAdded:Connect(sendToDiscord)
