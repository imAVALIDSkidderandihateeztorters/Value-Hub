local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local DEFAULT_RADIUS = 80
local DEFAULT_THICKNESS = 2
local DEFAULT_FOV = 70
local TARGET_PART_NAME = "Head"

local aimEnabled, espEnabled, tracersEnabled = false, false, false
local rmbDown = false
local radius, thickness, fovValue = DEFAULT_RADIUS, DEFAULT_THICKNESS, DEFAULT_FOV
local mouseLocation = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
local guiVisible = true

local brightGreen = Color3.fromRGB(0,255,0)
local hasDrawing = (type(Drawing)=="table")
local drawingCircle, fallbackGui, fallbackCircle

-- Aim Circle
if hasDrawing then
    drawingCircle = Drawing.new("Circle")
    drawingCircle.Filled = false
    drawingCircle.Visible = false
    drawingCircle.Color = brightGreen
    drawingCircle.Transparency = 0.6
    drawingCircle.Radius = radius
    drawingCircle.Thickness = thickness
else
    fallbackGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    fallbackGui.Name = "AimCircle"
    fallbackGui.ResetOnSpawn = false

    fallbackCircle = Instance.new("ImageLabel", fallbackGui)
    fallbackCircle.AnchorPoint = Vector2.new(0.5,0.5)
    fallbackCircle.BackgroundTransparency = 1
    fallbackCircle.Image = "rbxassetid://3570695787"
    fallbackCircle.ImageColor3 = brightGreen
    fallbackCircle.ImageTransparency = 0.6
    fallbackCircle.Size = UDim2.new(0,radius*2,0,radius*2)
end

local function setCircleVisible(v)
    if hasDrawing then
        drawingCircle.Visible = v
    else
        fallbackGui.Enabled = v
    end
end

local function dist(a,b)
    local dx,dy = a.X-b.X, a.Y-b.Y
    return math.sqrt(dx*dx + dy*dy)
end

local function findTarget(cursorPos)
    local best,bestDist
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local part = plr.Character:FindFirstChild(TARGET_PART_NAME)
            if part then
                local screenPos,onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local screenVec = Vector2.new(screenPos.X,screenPos.Y)
                    local d = dist(screenVec,cursorPos)
                    if d <= radius and (not bestDist or d<bestDist) then
                        best,bestDist = part,d
                    end
                end
            end
        end
    end
    return best
end

-- ESP
local espFolder = Instance.new("Folder",LocalPlayer:WaitForChild("PlayerGui"))
espFolder.Name = "ESP_Highlights"

local function clearESP() espFolder:ClearAllChildren() end

local function applyESP(plr)
    if not plr.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = brightGreen
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = brightGreen
    highlight.Adornee = plr.Character
    highlight.Parent = espFolder
end

local function refreshESP()
    clearESP()
    if espEnabled then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr.Character then applyESP(plr) end
        end
    end
end

local function trackPlayer(plr)
    if plr.Character and espEnabled then applyESP(plr) end
    plr.CharacterAdded:Connect(function()
        wait(0.1)
        if espEnabled then applyESP(plr) end
    end)
end

for _,plr in ipairs(Players:GetPlayers()) do trackPlayer(plr) end
Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(refreshESP)

-- Refresh ESP on respawn
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.1)
    refreshESP()
end)

-- Tracers
local tracers = {}
local tracerColor = brightGreen

local function clearTracers()
    for _,line in pairs(tracers) do 
        if line and line.Remove then
            line:Remove()
        end
    end
    tracers = {}
end

local function createTracer(plr)
    if hasDrawing then
        local line = Drawing.new("Line")
        line.Thickness = 3
        line.Color = tracerColor
        line.Visible = true
        tracers[plr] = line
    end
end

local function updateTracers()
    if not tracersEnabled then 
        clearTracers()
        return 
    end

    local camPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Camera.CFrame.Position

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not tracers[plr] then createTracer(plr) end
                if tracers[plr] then
                    local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local fromPos = Vector2.new(Camera:WorldToViewportPoint(camPos).X, Camera:WorldToViewportPoint(camPos).Y)
                        tracers[plr].From = fromPos
                        tracers[plr].To = Vector2.new(rootPos.X, rootPos.Y)
                        tracers[plr].Visible = true
                    else
                        tracers[plr].Visible = false
                    end
                end
            end
        end
    end
end

-- Refresh tracers every 3 seconds
spawn(function()
    while true do
        if tracersEnabled then
            clearTracers()
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then createTracer(plr) end
            end
        end
        wait(1)
    end
end)

-- Input handling
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement then
        mouseLocation = UserInputService:GetMouseLocation()
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton2 then rmbDown=false end
end)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton2 then rmbDown=true end
end)

-- Render loop
RunService.RenderStepped:Connect(function()
    if aimEnabled then
        if hasDrawing then
            drawingCircle.Position = mouseLocation
            drawingCircle.Radius = radius
            drawingCircle.Thickness = thickness
            drawingCircle.Visible = true
        else
            fallbackCircle.Position = UDim2.new(0,mouseLocation.X,0,mouseLocation.Y)
            fallbackCircle.Size = UDim2.new(0,radius*2,0,radius*2)
        end
    else setCircleVisible(false) end

    if aimEnabled and rmbDown then
        local target = findTarget(mouseLocation)
        if target then
            local camPos = Camera.CFrame.Position
            Camera.CFrame = CFrame.new(camPos,target.Position)
        end
    end

    Camera.FieldOfView = fovValue
    if espEnabled then refreshESP() else clearESP() end
    updateTracers()
end)

-- GUI creation
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "AdminPanel"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 220, 0, 380)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0

local dragBar = Instance.new("Frame", frame)
dragBar.Size = UDim2.new(1,0,0,20)
dragBar.Position = UDim2.new(0,0,0,0)
dragBar.BackgroundColor3 = Color3.fromRGB(50,50,50)

local dragLabel = Instance.new("TextLabel", dragBar)
dragLabel.Size = UDim2.new(1,0,1,0)
dragLabel.BackgroundTransparency = 1
dragLabel.Text="Ricks AimLock"
dragLabel.TextColor3=Color3.new(1,1,1)

local dragging=false
local dragStart=Vector2.new()
local startPos=UDim2.new()
dragBar.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true
        dragStart=input.Position
        startPos=frame.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then dragging=false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        local delta=input.Position-dragStart
        frame.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
    end
end)

local function makeToggle(name,yPos,callback)
    local button=Instance.new("TextButton",frame)
    button.Size=UDim2.new(1,-20,0,30)
    button.Position=UDim2.new(0,10,0,yPos)
    button.Text=name..": OFF"
    button.TextColor3=Color3.new(0,0,0)
    button.BackgroundColor3=Color3.fromRGB(0,255,0)
    button.MouseButton1Click:Connect(function()
        local state=callback()
        button.Text=name..(state and ": ON" or ": OFF")
    end)
end

makeToggle("AimLock",30,function() aimEnabled=not aimEnabled setCircleVisible(aimEnabled) return aimEnabled end)
makeToggle("ESP",70,function() espEnabled=not espEnabled refreshESP() return espEnabled end)
makeToggle("Tracers",110,function() tracersEnabled=not tracersEnabled if not tracersEnabled then clearTracers() end return tracersEnabled end)

local function createSlider(labelText,yPos,maxVal,initialVal,callback)
    local label=Instance.new("TextLabel",frame)
    label.Size=UDim2.new(1,-20,0,15)
    label.Position=UDim2.new(0,10,0,yPos)
    label.Text=labelText
    label.TextColor3=brightGreen
    label.BackgroundTransparency=1
    label.TextXAlignment=Enum.TextXAlignment.Left

    local back=Instance.new("Frame",frame)
    back.Size=UDim2.new(1,-20,0,10)
    back.Position=UDim2.new(0,10,0,yPos+20)
    back.BackgroundColor3=Color3.fromRGB(0,0,0)

    local fill=Instance.new("Frame",back)
    fill.Size=UDim2.new(initialVal/maxVal,0,1,0)
    fill.BackgroundColor3=brightGreen

    local dragging=false
    back.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    back.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local relX=math.clamp(input.Position.X-back.AbsolutePosition.X,0,back.AbsoluteSize.X)
            fill.Size=UDim2.new(0,relX,1,0)
            local val=(relX/back.AbsoluteSize.X)*maxVal
            callback(val)
        end
    end)
    return fill
end

local radiusFill = createSlider("Radius",150,200,radius,function(val) radius=val end)
local thickFill = createSlider("Thickness",185,10,thickness,function(val) thickness=val end)
local fovFill = createSlider("FOV",220,140,fovValue,function(val) fovValue=val end)

local resetFOVButton = Instance.new("TextButton",frame)
resetFOVButton.Size=UDim2.new(1,-20,0,30)
resetFOVButton.Position=UDim2.new(0,10,0,255)
resetFOVButton.Text="Reset FOV"
resetFOVButton.TextColor3=Color3.new(0,0,0)
resetFOVButton.BackgroundColor3=brightGreen
resetFOVButton.MouseButton1Click:Connect(function()
    fovValue=70
    fovFill.Size=UDim2.new(fovValue/140,0,1,0)
end)

-- Target Dropdown
local targetLabel = Instance.new("TextLabel", frame)
targetLabel.Size = UDim2.new(1,-20,0,20)
targetLabel.Position = UDim2.new(0,10,0,295)
targetLabel.Text = "Target"
targetLabel.TextColor3 = brightGreen
targetLabel.BackgroundTransparency = 1
targetLabel.TextXAlignment = Enum.TextXAlignment.Left

local targetDropdown = Instance.new("TextButton", frame)
targetDropdown.Size = UDim2.new(1,-20,0,30)
targetDropdown.Position = UDim2.new(0,10,0,320)
targetDropdown.Text = TARGET_PART_NAME
targetDropdown.TextColor3 = Color3.new(0,0,0)
targetDropdown.BackgroundColor3 = brightGreen

local dropdownOpen = false
local optionsFrame = Instance.new("Frame", frame)
optionsFrame.Size = UDim2.new(1,-20,0,0)
optionsFrame.Position = UDim2.new(0,10,0,350)
optionsFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
optionsFrame.ClipsDescendants = true

local function createOption(name)
    local btn = Instance.new("TextButton", optionsFrame)
    btn.Size = UDim2.new(1,0,0,30)
    btn.Position = UDim2.new(0,0,0,#optionsFrame:GetChildren()*30-30)
    btn.Text = name
    btn.TextColor3 = Color3.new(0,0,0)
    btn.BackgroundColor3 = brightGreen
    btn.MouseButton1Click:Connect(function()
        TARGET_PART_NAME = name
        targetDropdown.Text = name
        optionsFrame.Size = UDim2.new(1,-20,0,0)
        dropdownOpen = false
    end)
end

createOption("Head")
createOption("Torso")

targetDropdown.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    if dropdownOpen then
        optionsFrame.Size = UDim2.new(1,-20,0,60) -- 2 options * 30 height each
    else
        optionsFrame.Size = UDim2.new(1,-20,0,0)
    end
end)

-- F4 GUI toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
    end
end)
