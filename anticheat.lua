local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TARGET_NAME = "SneakyGolem"

local target = ReplicatedFirst:FindFirstChild(TARGET_NAME)

if target and (target:IsA("Script") or target:IsA("LocalScript") or target:IsA("ModuleScript")) then
    target:Destroy()
else
    print("anti cheat not found")
end
