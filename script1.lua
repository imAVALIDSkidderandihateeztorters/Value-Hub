local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local initialTeleports = {
	Red = Vector3.new(-1, 20, -144),
	Blue = Vector3.new(3, 36, 90)
}

local respawnTeleports = {
	Red = Vector3.new(-3, 38, 390),
	Blue = Vector3.new(-3, 38, -444)
}

local function teleportTo(character, position)
	local hrp = character:WaitForChild("HumanoidRootPart")
	hrp.CFrame = CFrame.new(position)
end

if LocalPlayer.Team and initialTeleports[LocalPlayer.Team.Name] then
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	teleportTo(character, initialTeleports[LocalPlayer.Team.Name])
end

LocalPlayer.CharacterAdded:Connect(function(character)
	task.wait(0.5) -- short delay to ensure character loads
	if LocalPlayer.Team and respawnTeleports[LocalPlayer.Team.Name] then
		teleportTo(character, respawnTeleports[LocalPlayer.Team.Name])
	end
end)
