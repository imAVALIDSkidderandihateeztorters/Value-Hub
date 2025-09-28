local function stopFlying()

	local char = player.Character

	if char then

		local hum = char:FindFirstChildOfClass("Humanoid")

		if hum then hum.PlatformStand = false end

	end

	cleanup()

end


-- unified input handler

local keymap = {

	[Enum.KeyCode.W] = "forwards",

	[Enum.KeyCode.S] = "backwards",

	[Enum.KeyCode.A] = "left",

	[Enum.KeyCode.D] = "right",

	[Enum.KeyCode.E] = "up",

	[Enum.KeyCode.Q] = "down",

}


local function onInput(input, state)

	local dir = keymap[input.KeyCode]

	if dir then inputState[dir] = state end

end


-- react to server

flyEvent.OnClientEvent:Connect(function(action)

	if action == "start" then

		startFlying(player.Character or player.CharacterAdded:Wait())

		if not ibConn then

			ibConn = UIS.InputBegan:Connect( function(i,p) if not p then onInput(i,1) end end )

			ieConn = UIS.InputEnded:Connect( function(i,p) if not p then onInput(i,0) end end )

		end

	else

		if ibConn then ibConn:Disconnect() ibConn = nil end

		if ieConn then ieConn:Disconnect() ieConn = nil end

		stopFlying()

	end

end)


-- reset on respawn

player.CharacterAdded:Connect(function()

	stopFlying()

	for k in pairs(inputState) do inputState[k] = 0 end

end)
