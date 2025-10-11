-- NameESP_TeamColors.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_G.NameESPEnabled = _G.NameESPEnabled ~= false -- default ON unless set false before this runs

local OFFSET = Vector3.new(0, 2.2, 0)
local TEXT_SIZE = 18
local FONT = Enum.Font.Gotham
local tags = {}

local function makeNameTag(player, head)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameTag"
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = OFFSET
	billboard.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = FONT
	nameLabel.TextSize = TEXT_SIZE
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.Text = player.DisplayName or player.Name
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.Parent = billboard

	local function updateTeamColor()
		if player.Team and player.Team.TeamColor then
			nameLabel.TextColor3 = player.Team.TeamColor.Color
		else
			nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	updateTeamColor()
	player:GetPropertyChangedSignal("Team"):Connect(updateTeamColor)

	tags[player] = billboard
	return billboard
end

local function onCharacterAdded(player, char)
	local head = char:WaitForChild("Head", 5)
	if not head then return end

	local existing = head:FindFirstChild("NameTag")
	if existing then existing:Destroy() end

	local billboard = makeNameTag(player, head)
	billboard.Enabled = _G.NameESPEnabled
end

local function addTag(player)
	if player == LocalPlayer then return end
	player.CharacterAdded:Connect(function(char)
		onCharacterAdded(player, char)
	end)
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	addTag(p)
end
Players.PlayerAdded:Connect(addTag)

-- Watch for global changes
game:GetService("RunService").RenderStepped:Connect(function()
	for _, billboard in pairs(tags) do
		if billboard then
			billboard.Enabled = _G.NameESPEnabled
		end
	end
end)
