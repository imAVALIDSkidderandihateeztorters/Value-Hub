local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Universal Menu",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Vaule Hub",
   LoadingSubtitle = "by Viper",
   ShowText = "Rayfield", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Vaule Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Universal Menu",
      Subtitle = "Key System",
      Note = "The Key Is PIZZA ALL CAPS", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"PIZZA"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("Player", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main CANT TURN OFF")


local EspTab = Window:CreateTab("Esp", nil) -- Title, Image
local EspSection = EspTab:CreateSection("Esp CANT TURN OFF")

Rayfield:Notify({
   Title = "Script Executed Successfully!",
   Content = "Have Fun.",
   Duration = 2.5,
   Image = "rewind",
})

local Button = MainTab:CreateButton({
   Name = "Infinite Jump",
   Callback = function()
      local Player = game:GetService'Players'.LocalPlayer;
local UIS = game:GetService'UserInputService';
 
_G.JumpHeight = 50;
 
function Action(Object, Function) if Object ~= nil then Function(Object); end end
 
UIS.InputBegan:connect(function(UserInput)
    if UserInput.UserInputType == Enum.UserInputType.Keyboard and UserInput.KeyCode == Enum.KeyCode.Space then
        Action(Player.Character.Humanoid, function(self)
            if self:GetState() == Enum.HumanoidStateType.Jumping or self:GetState() == Enum.HumanoidStateType.Freefall then
                Action(self.Parent.HumanoidRootPart, function(self)
                    self.Velocity = Vector3.new(0, _G.JumpHeight, 0);
                end)
            end
        end)
    end
end)
   end,
})


local OutlinePlayerToggle = EspTab:CreateToggle({
   Name = "Outline Player",
   CurrentValue = false,
   Flag = "Toggle Outline Player", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local runService = game:GetService("RunService")

-- Function to create the ESP box with team color
local function createESPBox(player)
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_ESP"
    highlight.Adornee = player.Character
    highlight.FillTransparency = 1 -- Makes the fill of the box invisible
    
    -- Check if the player is on a team and apply the team color
    if player.Team then
        highlight.OutlineColor = player.Team.TeamColor.Color -- Set the box color to the team's color
    else
        highlight.OutlineColor = Color3.new(1, 1, 1) -- Default color (white) if not in a team
    end
    
    highlight.OutlineTransparency = 0 -- Fully visible outline
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Can be seen through walls
    highlight.Parent = player.Character
end

-- Add ESP to all players
local function addESP()
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Check if ESP already exists to avoid duplication
            if not player.Character:FindFirstChild(player.Name .. "_ESP") then
                createESPBox(player)
            end
        end
    end
end

-- Run the ESP adding function continuously
runService.RenderStepped:Connect(function()
    addESP()
end)

-- Remove ESP if a player leaves
players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild(player.Name .. "_ESP") then
        player.Character[player.Name .. "_ESP"]:Destroy()
    end
end)
   end,
})
