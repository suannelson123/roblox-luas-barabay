-- Settings: Smoothing=0.50, FOV=300, Key=RMB

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local AIMBOT_ENABLED = true
local AIMBOT_SMOOTHING = 0.50
local AIMBOT_FOV = 300
local AIMBOT_KEY = Enum.UserInputType.MouseButton2


local aiming = false

local function getAllTargets()
    local targets = {}
    
    local characters = workspace["characters"]
    if characters then
        
        for _, child in pairs(characters:GetChildren()) do
            if child:IsA("Model") and child ~= LocalPlayer.Character and child.Name ~= LocalPlayer.Name then
                table.insert(targets, child)
            end
        end
    end
    return targets
end


local function getObjectPosition(obj)
    if obj:IsA("Model") then
        local humanoidRootPart = obj:FindFirstChild("HumanoidRootPart")
        local torso = obj:FindFirstChild("Torso")
        local head = obj:FindFirstChild("Head")
        if humanoidRootPart then
            return humanoidRootPart.Position, humanoidRootPart
        elseif torso then
            return torso.Position, torso
        elseif head then
            return head.Position, head
        end
    end
    return obj.Position, obj
end


local function getClosestTarget()
    local targets = getAllTargets()
    local closestTarget = nil
    local closestDistance = math.huge
    
    for _, target in pairs(targets) do
        if target and target.Parent then
            local targetPos, targetPart = getObjectPosition(target)
            if targetPos then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if distance < AIMBOT_FOV and distance < closestDistance then
                        closestDistance = distance
                        closestTarget = targetPart
                    end
                end
            end
        end
    end
    
    return closestTarget
end


local function aimAt(target)
    if not target then return end
    
    local targetPos = target.Position
    local camera = Camera
    local currentCFrame = camera.CFrame
    local targetCFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
    
 
    local newCFrame = currentCFrame:Lerp(targetCFrame, AIMBOT_SMOOTHING)
    camera.CFrame = newCFrame
end


UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)


RunService.Heartbeat:Connect(function()
    if aiming and AIMBOT_ENABLED then
        local target = getClosestTarget()
        if target then
            aimAt(target)
        end
    end
end)
print("Hold RMB to aim!")
