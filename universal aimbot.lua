
getgenv().l = {
    bind = 'Q',
    aimpart = 'Head',
    smoothness = 1,
    fov = 180,
    pred_per_ping = 0.001
}

local rs, plrs, workspace, uis = game:GetService('RunService'), game:GetService('Players'), game:GetService('Workspace'), game:GetService('UserInputService')
local target
local istoggled = false
local localplr = plrs.LocalPlayer
local cycle
local camera = workspace.CurrentCamera
local m = localplr:GetMouse()

local function gettarget()
    local closest, dist = nil, getgenv().l.fov
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= localplr and p.Character and p.Character[getgenv().l.aimpart] and p.Character['HumanoidRootPart'] then
            local sp = camera:WorldToScreenPoint(p.Character[getgenv().l.aimpart].Position)
            sp = Vector2.new(sp.X, sp.Y)
            local mp = Vector2.new(m.X, m.Y)
            local diff = (sp-mp).Magnitude
            if diff < dist then
                dist = diff
                closest = p
            end
        end
    end
    return closest
end

local function main()
    target = gettarget()
    cycle = rs.RenderStepped:Connect(function()
        if target and target.Character and target.Character[getgenv().l.aimpart] and target.Character['HumanoidRootPart'] then
            local lookat = target.Character[getgenv().l.aimpart].Position + target.Character['HumanoidRootPart'].Velocity * game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue() // 0.01 / 100 * getgenv().l.pred_per_ping
            lookat = CFrame.new(camera.CFrame.Position, lookat)
            camera.CFrame = camera.CFrame:Lerp(lookat, getgenv().l.smoothness)
        else
            if cycle then cycle:Disconnect() end
            cycle = nil
            target = nil
            istoggled = false
        end
    end)
end

uis.InputBegan:Connect(function(k,e)
    if e then return end
    if k.KeyCode == Enum.KeyCode[getgenv().l.bind] then
        if not istoggled then
            main()
            istoggled = not istoggled
        else
            if cycle then cycle:Disconnect() end
            cycle = nil
            target = nil
            istoggled = false
        end
    end
end)