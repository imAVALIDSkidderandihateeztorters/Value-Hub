ocal RS, RunService, UIS, Players = 

game:GetService("ReplicatedStorage"),

game:GetService("RunService"),

game:GetService("UserInputService"),

game:GetService("Players")


local player     = Players.LocalPlayer

local flyEvent   = RS:WaitForChild("FlyRequestEvent")

local FLY_SPEED  = 50


local inputState = {forwards=0, backwards=0, left=0, right=0, up=0, down=0}

local isFlying, flyConn, ibConn, ieConn, bg, bv


-- teardown

local function cleanup()

	if flyConn then flyConn:Disconnect() flyConn = nil end

	if bg     then bg:Destroy()          bg = nil     end

	if bv     then bv:Destroy()          bv = nil     end

	isFlying = false

end


-- start flight

local function startFlying(char)

	if isFlying then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")

	local hum = char:FindFirstChildOfClass("Humanoid")

	if not (hrp and hum) then return end


	isFlying = true

	hum.PlatformStand = true


	bg = Instance.new("BodyGyro",     hrp)

	bg.MaxTorque = Vector3.new(1e9,1e9,1e9)

	bg.P         = 9e4

	bg.CFrame    = hrp.CFrame


	bv = Instance.new("BodyVelocity", hrp)

	bv.MaxForce = Vector3.new(1e9,1e9,1e9)

	bv.Velocity = Vector3.zero


	flyConn = RunService.RenderStepped:Connect(function()

		local cam = workspace.CurrentCamera

		if not cam then return end


		local mv = cam.CFrame.LookVector  * (inputState.forwards - inputState.backwards)

			+ cam.CFrame.RightVector * (inputState.right    - inputState.left)

			+ Vector3.new(0,1,0)        * (inputState.up       - inputState.down)


		bv.Velocity = (mv.Magnitude > 0 and mv.Unit * FLY_SPEED) or Vector3.zero

		bg.CFrame   = CFrame.lookAt(hrp.Position, hrp.Position + cam.CFrame.LookVector)

	end)

end
