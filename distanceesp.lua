-- DistanceESP_TeamColors.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
_G.DistanceESPEnabled = _G.DistanceESPEnabled ~= false -- default ON unless set false before this runs

local MAX_DISTANCE = 200
local FONT = Enum.Font.Gotham
local TEXT_SIZE = 16
local NAME_HEIGHT_OFFSET = 0.25
local OFFSET = Vector3.new(0, 2.2, 0)

local function getTeamColor(player)
	if player.Team and player.Team.TeamColor then
		return player.Team.TeamColor.Color
	else
		return Color3.fromRGB(255, 255, 255)
	end
end

local function ensureTag(player, head)
	local tag = head:FindFirstChild("DistanceTag")
	if not tag then
		tag = Instance.new("BillboardGui")
		tag.Name = "DistanceTag"
		tag.AlwaysOnTop = true
		tag.Size = UDim2.new(0, 200, 0, 60)
		tag.StudsOffset = OFFSET
		tag.Parent = head
	end

	local label = tag:FindFirstChild("DistanceLabel")
	if not label then
		label = Instance.new("TextLabel")
		label.Name = "DistanceLabel"
		label.Size = UDim2.new(1, 0, 0.4, 0)
		label.Position = UDim2.new(0, 0, 0.6 + NAME_HEIGHT_OFFSET, 0)
		label.BackgroundTransparency = 1
		label.Font = FONT
		label.TextSize = TEXT_SIZE
		label.TextStrokeTransparency = 0.5
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Parent = tag
	end

	return tag, label
end

RunService.RenderStepped:Connect(function()
	if not _G.DistanceESPEnabled then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
				local tag = player.Character.Head:FindFirstChild("DistanceTag")
				if tag then tag.Enabled = false end
			end
		end
		return
	end

	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
			local head = player.Character.Head
			local tag, label = ensureTag(player, head)
			local dist = (myChar.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude

			if dist <= MAX_DISTANCE then
				tag.Enabled = true
				label.Visible = true
				label.Text = string.format("%dm", math.floor(dist))
				label.TextColor3 = getTeamColor(player)
			else
				tag.Enabled = false
			end
		end
	end
end)
