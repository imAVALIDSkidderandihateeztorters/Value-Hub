-- TracerESP_TeamColors.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
_G.TracerESPEnabled = _G.TracerESPEnabled ~= false -- default ON unless set false before this runs

local lines = {}

local function getTeamColor(player)
	if player.Team and player.Team.TeamColor then
		return player.Team.TeamColor.Color
	else
		return Color3.fromRGB(255, 255, 255)
	end
end

local function createLine(player)
	local line = Drawing.new("Line")
	line.Thickness = 1.5
	line.Color = getTeamColor(player)
	line.Transparency = 1
	line.Visible = false

	lines[player] = line
	return line
end

local function removeLine(player)
	if lines[player] then
		lines[player]:Remove()
		lines[player] = nil
	end
end

RunService.RenderStepped:Connect(function()
	local cam = workspace.CurrentCamera
	local myChar = LocalPlayer.Character
	local origin
	if myChar and myChar:FindFirstChild("HumanoidRootPart") then
		origin = cam:WorldToViewportPoint(myChar.HumanoidRootPart.Position)
	else
		-- fallback: screen bottom center
		origin = Vector3.new(cam.ViewportSize.X/2, cam.ViewportSize.Y, 0)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			local line = lines[player] or createLine(player)
			local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)

			if _G.TracerESPEnabled and onScreen then
				line.From = Vector2.new(origin.X, origin.Y)
				line.To = Vector2.new(screenPos.X, screenPos.Y)
				line.Color = getTeamColor(player)
				line.Visible = true
			else
				line.Visible = false
			end
		end
	end
end)

Players.PlayerRemoving:Connect(removeLine)
