-- PRESS J TO TOGGLE THE BLOCK TELEPORTING
-- PRESS K TO TOGGLE THE BLOCK

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local function modifyGun(gunFolder)
    if not gunFolder then return end
    local gun = gunFolder:FindFirstChild("Gun")
    if not gun then return end

    local function setValues()
        local recoilSide = gun:FindFirstChild("recoil_side")
        local recoilUp = gun:FindFirstChild("recoil_up")
        local fireRate = gun:FindFirstChild("firerate")
        local spread = gun:FindFirstChild("spread")
        local accuracy = gun:FindFirstChild("accuracy")

        if recoilSide and recoilSide:IsA("NumberValue") then
            recoilSide.Value = 0
            recoilSide.Changed:Connect(function() recoilSide.Value = 0 end)
        end

        if recoilUp and recoilUp:IsA("NumberValue") then
            recoilUp.Value = 0
            recoilUp.Changed:Connect(function() recoilUp.Value = 0 end)
        end

        if fireRate and fireRate:IsA("NumberValue") then
            fireRate.Value = 9999
            fireRate.Changed:Connect(function() fireRate.Value = 9999 end)
        end

        if spread and spread:IsA("NumberValue") then
            spread.Value = 0
            spread.Changed:Connect(function() spread.Value = 0 end)
        end

        if accuracy and accuracy:IsA("NumberValue") then
            accuracy.Value = 3
            accuracy.Changed:Connect(function() accuracy.Value = 3 end)
        end
    end

    setValues()
end

local function monitorItems(itemsFolder)
    for _, item in ipairs(itemsFolder:GetChildren()) do
        modifyGun(item)
    end
    itemsFolder.ChildAdded:Connect(modifyGun)
end

LocalPlayer.CharacterAdded:Connect(function()
    local itemsFolder = LocalPlayer:WaitForChild("Items")
    monitorItems(itemsFolder)
end)

if LocalPlayer.Character then
    local itemsFolder = LocalPlayer:WaitForChild("Items")
    monitorItems(itemsFolder)
end


