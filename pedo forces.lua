

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bottomnoah/UI/refs/heads/main/cola.lua"))()
local drawhelper = loadstring(game:HttpGet("https://raw.githubusercontent.com/bottomnoah/UI/refs/heads/main/drawing"))()
local Wait = Library.subs.Wait


local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")


local lastJumpTime = 0
local jumpCooldown = 0.8125

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Join the Server!",
    Text = "dsc.gg/kaotiksoftworks",
    Duration = 6
})

if _G.ScriptIsRunning then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Script Already Running",
        Text = "The script is already executing. Please do not attempt to run it again.",
        Duration = 5
    })
    return
end
_G.ScriptIsRunning = true

local hasMouseMoveRel = type(mousemoverel) == "function"
if not hasMouseMoveRel then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Aimbot Unavailable",
        Text = "This executor does not support mousemoverel. Aimbot functionality is not available.",
        Duration = 6
    })
end


local Settings = {
    Aimbot = {
        Enabled = false,
        HitPart = "Head",
        WallCheck = false,
        AutoTargetSwitch = false,
        MaxDistance = { Enabled = false, Value = 500 },
        Easing = { Strength = 0.1, Sensitivity = Instance.new("NumberValue") }
    },
    ESP = {
        Enabled = false,
        MaxDistance = { Enabled = false, Value = 500 },
        VisibilityCheck = false,
        UseFOV = false,
        Features = {
            Box = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
            Tracer = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
            DistanceText = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
            Name = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) },
            HeadDot = { Enabled = false, Color = Color3.fromRGB(255, 255, 255) }
        }
    },
    FOV = {
        Enabled = false,
        FollowGun = false,
        Radius = 50,
        Circle = drawing.new("Circle"),
        OutlineCircle = drawing.new("Circle"),
        Filled = false,
        FillColor = Color3.fromRGB(0, 0, 0),
        FillTransparency = 0.2,
        OutlineColor = Color3.fromRGB(255, 255, 255),
        OutlineTransparency = 1
    },
    Chams = {
        Enabled = false,
        TeamCheck = true,
        Teammates = false,
        Fill = { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.5 },
        Outline = { Color = Color3.fromRGB(255, 255, 255), Transparency = 0 }
    },
    Player = {
        Bhop = { Enabled = false }
    },
    Misc = {
        Textures = false,
        VotekickRejoiner = false,
        Optimized = false
    },
    Crosshair = {
        Enabled = false,
        Size = 10,
        Thickness = 1,
        Gap = 5,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 1,
        Dot = false,
        TStyle = "Default",
        Drawings = {
            Line1 = drawing.new("Line"),
            Line2 = drawing.new("Line"),
            Line3 = drawing.new("Line"),
            Line4 = drawing.new("Line"),
            CenterDot = drawing.new("Circle")
        }
    }
}


local function initializeCrosshair()
    for _, d in pairs(Settings.Crosshair.Drawings) do d.Visible = false end
end

local function updateCrosshair()
    if not Settings.Crosshair.Enabled then return end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local size, gap, thickness, color, transparency = Settings.Crosshair.Size, Settings.Crosshair.Gap, Settings.Crosshair.Thickness, Settings.Crosshair.Color, Settings.Crosshair.Transparency
    local lines = Settings.Crosshair.Drawings
    if Settings.Crosshair.TStyle == "Default" then
        lines.Line1.Visible = true lines.Line1.From = Vector2.new(center.X, center.Y - gap - size) lines.Line1.To = Vector2.new(center.X, center.Y - gap) lines.Line1.Color = color lines.Line1.Thickness = thickness lines.Line1.Transparency = transparency
        lines.Line2.Visible = true lines.Line2.From = Vector2.new(center.X, center.Y + gap) lines.Line2.To = Vector2.new(center.X, center.Y + gap + size) lines.Line2.Color = color lines.Line2.Thickness = thickness lines.Line2.Transparency = transparency
        lines.Line3.Visible = true lines.Line3.From = Vector2.new(center.X - gap - size, center.Y) lines.Line3.To = Vector2.new(center.X - gap, center.Y) lines.Line3.Color = color lines.Line3.Thickness = thickness lines.Line3.Transparency = transparency
        lines.Line4.Visible = true lines.Line4.From = Vector2.new(center.X + gap, center.Y) lines.Line4.To = Vector2.new(center.X + gap + size, center.Y) lines.Line4.Color = color lines.Line4.Thickness = thickness lines.Line4.Transparency = transparency
        lines.CenterDot.Visible = Settings.Crosshair.Dot lines.CenterDot.Position = center lines.CenterDot.Radius = thickness lines.CenterDot.Color = color lines.CenterDot.Transparency = transparency lines.CenterDot.Filled = true
    else 
        lines.Line1.Visible = true lines.Line1.From = Vector2.new(center.X - size - gap, center.Y) lines.Line1.To = Vector2.new(center.X + size + gap, center.Y) lines.Line1.Color = color lines.Line1.Thickness = thickness lines.Line1.Transparency = transparency
        lines.Line2.Visible = true lines.Line2.From = Vector2.new(center.X, center.Y - size - gap) lines.Line2.To = Vector2.new(center.X, center.Y + size + gap) lines.Line2.Color = color lines.Line2.Thickness = thickness lines.Line2.Transparency = transparency
        lines.Line3.Visible = false lines.Line4.Visible = false
        lines.CenterDot.Visible = Settings.Crosshair.Dot lines.CenterDot.Position = center lines.CenterDot.Radius = thickness lines.CenterDot.Color = color lines.CenterDot.Transparency = transparency lines.CenterDot.Filled = true
    end
end

initializeCrosshair()


local fov = Settings.FOV
fov.Circle.Visible = false fov.Circle.Filled = fov.Filled fov.Circle.Color = fov.FillColor fov.Circle.Transparency = fov.FillTransparency fov.Circle.Thickness = 0 fov.Circle.Radius = fov.Radius fov.Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
Settings.Aimbot.Easing.Sensitivity.Value = Settings.Aimbot.Easing.Strength
fov.OutlineCircle.Filled = false fov.OutlineCircle.Color = fov.OutlineColor fov.OutlineCircle.Transparency = fov.OutlineTransparency fov.OutlineCircle.Thickness = 1 fov.OutlineCircle.Radius = fov.Radius fov.OutlineCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) fov.OutlineCircle.Visible = fov.Enabled


local State = {
    IsRightClickHeld = false,
    TargetPart = nil,
    OriginalProperties = {},
    CachedProperties = {},
    PlayersToDraw = {},
    Highlights = {},
    Storage = { ESPCache = {} },
    MousePreload = { Active = false, LastTime = 0, Interval = 5, Connection = nil },
    CrosshairUpdate = nil
}

local function toggleCrosshair(state)
    if state then
        State.CrosshairUpdate = RunService.RenderStepped:Connect(updateCrosshair)
    else
        if State.CrosshairUpdate then State.CrosshairUpdate:Disconnect() State.CrosshairUpdate = nil end
        for _, d in pairs(Settings.Crosshair.Drawings) do d.Visible = false end
    end
end


local function getGunBarrel()
    local furthestPart, maxZ = nil, -math.huge
    for _, model in pairs(workspace.Camera:GetChildren()) do
        if model:IsA("Model") and not model.Name:lower():find("arm") then
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen and pos.Z > maxZ then maxZ = pos.Z furthestPart = part end
                end
            end
        end
    end
    return furthestPart
end

local function updateFOVCirclePosition()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if Settings.FOV.Enabled then
        if Settings.FOV.FollowGun then
            local barrel = getGunBarrel()
            if barrel then
                local pos, onScreen = Camera:WorldToViewportPoint(barrel.Position)
                if onScreen then
                    if State.IsRightClickHeld and math.abs(pos.X - center.X) <= 10 then
                        Settings.FOV.Circle.Position = center Settings.FOV.OutlineCircle.Position = center
                    else
                        Settings.FOV.Circle.Position = Vector2.new(pos.X, pos.Y) Settings.FOV.OutlineCircle.Position = Vector2.new(pos.X, pos.Y)
                    end
                else
                    Settings.FOV.Circle.Position = center Settings.FOV.OutlineCircle.Position = center
                end
            else
                Settings.FOV.Circle.Position = center Settings.FOV.OutlineCircle.Position = center
            end
        else
            Settings.FOV.Circle.Position = center Settings.FOV.OutlineCircle.Position = center
        end
    else
        Settings.FOV.Circle.Position = center Settings.FOV.OutlineCircle.Position = center
    end
end

local function getPlayers()
    local entityList = {}
    for _, team in pairs(workspace.Players:GetChildren()) do
        for _, player in pairs(team:GetChildren()) do
            if player:IsA("Model") then table.insert(entityList, player) end
        end
    end
    return entityList
end

local function isEnemy(player)
    local localTeam = Players.LocalPlayer.Team.Name
    local helmet = player:FindFirstChildWhichIsA("Folder") and player:FindFirstChildWhichIsA("Folder"):FindFirstChildOfClass("MeshPart")
    if not helmet then return false end
    local color = helmet.BrickColor.Name
    return (color == "Black" and localTeam == "Ghosts") or (color ~= "Black" and localTeam == "Phantoms")
end

local function cacheObject(object)
    if not State.Storage.ESPCache[object] then
        State.Storage.ESPCache[object] = {
            BoxSquare = drawing.new("Square"),
            BoxOutline = drawing.new("Square"),
            TracerLine = drawing.new("Line"),
            DistanceLabel = drawing.new("Text"),
            NameLabel = drawing.new("Text"),
            HeadDot = drawing.new("Circle")
        }
        for _, e in pairs(State.Storage.ESPCache[object]) do e.Visible = false end
    end
end

local function uncacheObject(object)
    if State.Storage.ESPCache[object] then
        for _, e in pairs(State.Storage.ESPCache[object]) do e:Remove() end
        State.Storage.ESPCache[object] = nil
    end
end

local function getBodyPart(player, name)
    for _, part in pairs(player:GetChildren()) do
        if part:IsA("BasePart") then
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh and ((name == "Head" and mesh.MeshId == "rbxassetid://6179256256") or (name ~= "Head" and mesh.MeshId == "rbxassetid://4049240078")) then
                return part
            end
        end
    end
    return nil
end

local function isAlly(player)
    local helmet = player:FindFirstChildWhichIsA("Folder") and player:FindFirstChildWhichIsA("Folder"):FindFirstChildOfClass("MeshPart")
    if not helmet then return false end
    return helmet.BrickColor.Name == "Black" and Players.LocalPlayer.Team == Teams.Phantoms or helmet.BrickColor.Name ~= "Black" and Players.LocalPlayer.Team == Teams.Ghosts
end

local function getClosestPlayer()
    local closest, shortestDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(getPlayers()) do
        if not player:IsDescendantOf(workspace.Ignore.DeadBody) then
            local ally = isAlly(player)
            if not (Settings.Chams.TeamCheck and ally) then
                local part = getBodyPart(player, Settings.Aimbot.HitPart)
                if part then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distToCenter = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        local distToCam = (part.Position - Camera.CFrame.Position).Magnitude
                        if not (Settings.Aimbot.MaxDistance.Enabled and distToCam > Settings.Aimbot.MaxDistance.Value) then
                            if Settings.FOV.Enabled then
                                if distToCenter <= Settings.FOV.Radius then
                                    if distToCam <= 30 then return part end
                                    if distToCenter < shortestDist then closest = part shortestDist = distToCenter end
                                end
                            else
                                if distToCam <= 30 then return part end
                                if distToCenter < shortestDist then closest = part shortestDist = distToCenter end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function safeMouseMoveRel(x, y)
    if hasMouseMoveRel then
        pcall(mousemoverel, x, y)
    end
end

local function preloadMouse()
    local t = tick()
    if t - State.MousePreload.LastTime >= State.MousePreload.Interval then
        safeMouseMoveRel(0.01, 0.01)
        State.MousePreload.LastTime = t
    end
end

local function startMousePreload()
    if not hasMouseMoveRel then return end
    if State.MousePreload.Active then return end
    State.MousePreload.Active = true
    State.MousePreload.Connection = RunService.Heartbeat:Connect(preloadMouse)
end

local function stopMousePreload()
    if not hasMouseMoveRel then return end
    if not State.MousePreload.Active then return end
    State.MousePreload.Active = false
    if State.MousePreload.Connection then
        State.MousePreload.Connection:Disconnect()
        State.MousePreload.Connection = nil
    end
end

local function aimAt()
    if not Settings.Aimbot.Easing.Strength or not State.TargetPart or not State.TargetPart:IsDescendantOf(workspace.Players) then return end
    if State.IsRightClickHeld then
        if Settings.Aimbot.AutoTargetSwitch and not State.TargetPart then
            State.TargetPart = getClosestPlayer()
            if not State.TargetPart then State.IsRightClickHeld = false return end
        end
        local pos, onScreen = Camera:WorldToViewportPoint(State.TargetPart.Position)
        if onScreen then
            local mouse = UserInputService:GetMouseLocation()
            local delta = Vector2.new(pos.X - mouse.X, pos.Y - mouse.Y)
            local dist = delta.Magnitude
            if dist > 1 then safeMouseMoveRel(delta.X * Settings.Aimbot.Easing.Sensitivity.Value, delta.Y * Settings.Aimbot.Easing.Sensitivity.Value) end
        end
    end
end

local function updateSensitivity(val)
    local tween = TweenService:Create(Settings.Aimbot.Easing.Sensitivity, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Value = val})
    tween:Play()
end

local function storeOriginalProperties(inst)
    if inst:IsA("BasePart") or inst:IsA("UnionOperation") or inst:IsA("MeshPart") then
        State.OriginalProperties[inst] = {
            Material = inst.Material,
            Reflectance = inst.Reflectance,
            CastShadow = inst.CastShadow,
            TextureId = inst:FindFirstChild("TextureId") and inst.TextureId or nil
        }
    end
end

local function optimizeMap()
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    for _, inst in pairs(map:GetDescendants()) do
        storeOriginalProperties(inst)
        if inst:IsA("BasePart") or inst:IsA("UnionOperation") or inst:IsA("MeshPart") then
            inst.Material = Enum.Material.SmoothPlastic inst.Reflectance = 0 inst.CastShadow = false
            if inst:IsA("MeshPart") and inst:FindFirstChild("TextureId") then inst.TextureId = "" end
        end
    end
    Settings.Misc.Optimized = true
end

local function revertMap()
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    for _, inst in pairs(map:GetDescendants()) do
        local props = State.OriginalProperties[inst]
        if props then
            inst.Material = props.Material inst.Reflectance = props.Reflectance inst.CastShadow = props.CastShadow
            if inst:IsA("MeshPart") and inst:FindFirstChild("TextureId") then inst.TextureId = props.TextureId or "" end
        end
    end
    Settings.Misc.Optimized = false
end

local function isVisible(part, check)
    if check then
        local hit = workspace:FindPartOnRayWithIgnoreList(Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000), {Players.LocalPlayer.Character}, false, true)
        return hit == part
    end
    return true
end

local function isValidPlayer(player) return player and player.Parent and player:IsDescendantOf(workspace.Players) end

local function initializeESP()
    for p in pairs(State.Storage.ESPCache) do uncacheObject(p) end
    State.PlayersToDraw = {} State.CachedProperties = {}
end

local function cleanupStalePlayers()
    for p in pairs(State.Storage.ESPCache) do
        if not isValidPlayer(p) then uncacheObject(p) State.CachedProperties[p] = nil end
    end
end

local function updatePlayerCache()
    cleanupStalePlayers()
    State.PlayersToDraw = {}
    for _, p in pairs(getPlayers()) do
        if isValidPlayer(p) and isEnemy(p) then
            local torso, head = getBodyPart(p, "Torso"), getBodyPart(p, "Head")
            if torso and head then
                local dist = (head.Position - Camera.CFrame.Position).Magnitude
                if not Settings.ESP.MaxDistance.Enabled or dist <= Settings.ESP.MaxDistance.Value then
                    cacheObject(p)
                    table.insert(State.PlayersToDraw, p)
                    local gui = head:FindFirstChildOfClass("BillboardGui")
                    local label = gui and gui:FindFirstChildOfClass("TextLabel")
                    if gui and label then State.CachedProperties[p] = { Name = label.Text } end
                else
                    uncacheObject(p) State.CachedProperties[p] = nil
                end
            else
                uncacheObject(p) State.CachedProperties[p] = nil
            end
        end
    end
end

local function applyHighlight(p)
    if State.Highlights[p] then return State.Highlights[p] end
    local h = Instance.new("Highlight")
    h.FillColor = Settings.Chams.Fill.Color h.OutlineColor = Settings.Chams.Outline.Color h.FillTransparency = Settings.Chams.Fill.Transparency h.OutlineTransparency = Settings.Chams.Outline.Transparency
    h.Adornee = p h.Parent = game.CoreGui
    State.Highlights[p] = h
    return h
end

local function removeHighlight(p) if State.Highlights[p] then State.Highlights[p]:Destroy() State.Highlights[p] = nil end end

local function updateChams()
    if not Settings.Chams.Enabled then
        for p in pairs(State.Highlights) do removeHighlight(p) end return
    end
    for _, p in pairs(getPlayers()) do
        if isValidPlayer(p) then
            local ally = isAlly(p)
            if ally and not Settings.Chams.Teammates then removeHighlight(p)
            else
                local torso = getBodyPart(p, "Torso")
                if not torso then removeHighlight(p)
                else
                    local dist = (torso.Position - Camera.CFrame.Position).Magnitude
                    if Settings.ESP.MaxDistance.Enabled and dist > Settings.ESP.MaxDistance.Value then removeHighlight(p)
                    else
                        local h = applyHighlight(p)
                        local vis = isVisible(torso, Settings.ESP.VisibilityCheck)
                        if Settings.ESP.VisibilityCheck and not vis then
                            h.FillColor = Color3.fromRGB(255, 0, 0) h.OutlineColor = Color3.fromRGB(255, 0, 0) h.FillTransparency = 0.5 h.OutlineTransparency = 0.2
                        else
                            h.FillColor = Settings.Chams.Fill.Color h.OutlineColor = Settings.Chams.Outline.Color h.FillTransparency = Settings.Chams.Fill.Transparency h.OutlineTransparency = Settings.Chams.Outline.Transparency
                        end
                    end
                end
            end
        end
    end
    for p in pairs(State.Highlights) do if not isValidPlayer(p) then removeHighlight(p) end end
end

local function renderESP()
    local camPos = Camera.CFrame.Position
    local viewSize = Camera.ViewportSize
    local center = Vector2.new(viewSize.X / 2, viewSize.Y)
    local fovRad = Settings.FOV.OutlineCircle.Radius
    for _, p in pairs(State.PlayersToDraw) do
        if not isValidPlayer(p) then uncacheObject(p) State.CachedProperties[p] = nil
        else
            local cache = State.Storage.ESPCache[p] or (cacheObject(p) and State.Storage.ESPCache[p])
            local torso, head = getBodyPart(p, "Torso"), getBodyPart(p, "Head")
            if not torso or not head then for _, e in pairs(cache) do e.Visible = false end
            else
                local torsoPos, torsoOn = Camera:WorldToViewportPoint(torso.Position)
                local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
                if not torsoOn then for _, e in pairs(cache) do e.Visible = false end
                else
                    local distCam = (torso.Position - camPos).Magnitude
                    local screenPos = Vector2.new(torsoPos.X, torsoPos.Y)
                    local distCenter = (screenPos - center).Magnitude
                    if Settings.ESP.UseFOV and distCenter > fovRad then for _, e in pairs(cache) do e.Visible = false end
                    else
                        local scale = 1000 / distCam * 80 / Camera.FieldOfView
                        local boxW, boxH = math.floor(3 * scale), math.floor(4 * scale)
                        local boxPos = Vector2.new(torsoPos.X - boxW / 2, torsoPos.Y - boxH / 2)
                        local vis = isVisible(head, Settings.ESP.VisibilityCheck)
                        local boxCol = vis and Settings.ESP.Features.Box.Color or Color3.fromRGB(255, 0, 0)

                        cache.BoxSquare.Visible = Settings.ESP.Features.Box.Enabled if Settings.ESP.Features.Box.Enabled then cache.BoxSquare.Color = boxCol cache.BoxSquare.Position = boxPos cache.BoxSquare.Size = Vector2.new(boxW, boxH) cache.BoxOutline.Position = Vector2.new(boxPos.X - 1, boxPos.Y - 1) cache.BoxOutline.Size = Vector2.new(boxW + 2, boxH + 2) end
                        cache.TracerLine.Visible = Settings.ESP.Features.Tracer.Enabled if Settings.ESP.Features.Tracer.Enabled then cache.TracerLine.Color = vis and Settings.ESP.Features.Tracer.Color or Color3.fromRGB(255, 0, 0) cache.TracerLine.From = Vector2.new(viewSize.X / 2, viewSize.Y) cache.TracerLine.To = screenPos end
                        cache.NameLabel.Visible = Settings.ESP.Features.Name.Enabled and State.CachedProperties[p] if Settings.ESP.Features.Name.Enabled and State.CachedProperties[p] then cache.NameLabel.Text = State.CachedProperties[p].Name cache.NameLabel.Color = Settings.ESP.Features.Name.Color cache.NameLabel.Size = math.max(12, math.min(16, scale * 2.5)) cache.NameLabel.Center = true cache.NameLabel.Position = Vector2.new(boxPos.X + (boxW / 2), boxPos.Y - 15) cache.NameLabel.Outline = true end
                        cache.DistanceLabel.Visible = Settings.ESP.Features.DistanceText.Enabled if Settings.ESP.Features.DistanceText.Enabled then local dist = math.floor(distCam) cache.DistanceLabel.Text = dist .. " studs" cache.DistanceLabel.Color = Settings.ESP.Features.DistanceText.Color cache.DistanceLabel.Size = math.max(14, math.min(18, scale * 2.5)) cache.DistanceLabel.Position = Vector2.new(boxPos.X + (boxW / 2), boxPos.Y + boxH + 5) cache.DistanceLabel.Outline = true end
                        cache.HeadDot.Visible = Settings.ESP.Features.HeadDot.Enabled and headOn if Settings.ESP.Features.HeadDot.Enabled and headOn then cache.HeadDot.Color = Settings.ESP.Features.HeadDot.Color cache.HeadDot.Radius = (boxH / 20) cache.HeadDot.Position = Vector2.new(headPos.X, headPos.Y) end
                    end
                end
            end
        end
    end
end

local function refreshPlayerCache() if Library.Flags.ESPEnabled then updatePlayerCache() end end

local function getCharacter()
    local char
    while not char do char = workspace.Ignore:FindFirstChildWhichIsA("Model") task.wait() end
    return char
end

local function kickAndRejoin()
    Players.LocalPlayer:Kick("[THIS IS NOT A VOTEKICK!] You've been blocked from being votekicked, Rejoining...")
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end

local function initializeVotekickRejoiner()
    local displayVoteKick = Players.LocalPlayer.PlayerGui.ChatScreenGui.Main.DisplayVoteKick
    displayVoteKick:GetPropertyChangedSignal("Visible"):Connect(function()
        if displayVoteKick.Visible and Settings.Misc.VotekickRejoiner then
            local words = {}
            for w in displayVoteKick.TextTitle.Text:gmatch("%S+") do table.insert(words, w) end
            if words[2] == Players.LocalPlayer.Name then kickAndRejoin() end
        end
    end)
end


local Window = Library:CreateWindow({ Name = "Nullwave", Themeable = { Info = "dsc.gg/kaotiksoftworks" } })
local Tabs = { Main = Window:CreateTab({Name = "Main"}), Visuals = Window:CreateTab({Name = "Visuals"}), Player = Window:CreateTab({Name = "Player"}), Misc = Window:CreateTab({Name = "Misc"}) }


local CrosshairGroup = Tabs.Misc:CreateSection({Name = "Crosshair"})
CrosshairGroup:AddToggle({ Name = "Enabled", Flag = "CrosshairEnabled", Value = Settings.Crosshair.Enabled, Callback = function(s) Settings.Crosshair.Enabled = s toggleCrosshair(s) end })
CrosshairGroup:AddDropdown({ Name = "Style", Flag = "CrosshairStyle", List = {"Default", "Plus"}, Value = Settings.Crosshair.TStyle, Callback = function(v) Settings.Crosshair.TStyle = v end })
CrosshairGroup:AddToggle({ Name = "Center Dot", Flag = "CrosshairDot", Value = Settings.Crosshair.Dot, Callback = function(s) Settings.Crosshair.Dot = s end })
CrosshairGroup:AddSlider({ Name = "Size", Flag = "CrosshairSize", Value = Settings.Crosshair.Size, Min = 1, Max = 30, Rounding = 0, Callback = function(v) Settings.Crosshair.Size = v end })
CrosshairGroup:AddSlider({ Name = "Thickness", Flag = "CrosshairThickness", Value = Settings.Crosshair.Thickness, Min = 1, Max = 5, Rounding = 0, Callback = function(v) Settings.Crosshair.Thickness = v end })
CrosshairGroup:AddSlider({ Name = "Gap", Flag = "CrosshairGap", Value = Settings.Crosshair.Gap, Min = 0, Max = 20, Rounding = 0, Callback = function(v) Settings.Crosshair.Gap = v end })
CrosshairGroup:AddColorPicker({ Name = "Color", Flag = "CrosshairColor", Color = Settings.Crosshair.Color, Transparency = 0, Callback = function(v) Settings.Crosshair.Color = v end })
CrosshairGroup:AddSlider({ Name = "Transparency", Flag = "CrosshairTransparency", Value = Settings.Crosshair.Transparency, Min = 0, Max = 1, Rounding = 2, Callback = function(v) Settings.Crosshair.Transparency = v end })


if hasMouseMoveRel then
    local AimbotGroup = Tabs.Main:CreateSection({Name = "Aimbot"})
    AimbotGroup:AddToggle({
        Name = "Enabled",
        Flag = "AimbotEnabled",
        Value = Settings.Aimbot.Enabled,
        Callback = function(s)
            Settings.Aimbot.Enabled = s
            if s then
                startMousePreload()
                State.InputBeganConnection = UserInputService.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton2 then
                        State.IsRightClickHeld = true
                        State.TargetPart = getClosestPlayer()
                    end
                end)
                State.InputEndedConnection = UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton2 then
                        State.IsRightClickHeld = false
                        State.TargetPart = nil
                    end
                end)
                State.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
                    if State.IsRightClickHeld and State.TargetPart then
                        if Settings.Aimbot.WallCheck then
                            if isVisible(State.TargetPart, true) then
                                aimAt()
                            end
                        else
                            aimAt()
                        end
                    end
                end)
            else
                stopMousePreload()
                if State.InputBeganConnection then State.InputBeganConnection:Disconnect() end
                if State.InputEndedConnection then State.InputEndedConnection:Disconnect() end
                if State.RenderSteppedConnection then State.RenderSteppedConnection:Disconnect() end
            end
        end
    })
    AimbotGroup:AddDropdown({ Name = "Hit Part", Flag = "AimbotHitPart", List = {"Head", "Torso"}, Value = Settings.Aimbot.HitPart, Callback = function(v) Settings.Aimbot.HitPart = v end })
    AimbotGroup:AddToggle({ Name = "Wall Check", Flag = "AimbotWallCheck", Value = Settings.Aimbot.WallCheck, Callback = function(s) Settings.Aimbot.WallCheck = s end })
    AimbotGroup:AddToggle({ Name = "Auto Target Switch", Flag = "AimbotAutoTargetSwitch", Value = Settings.Aimbot.AutoTargetSwitch, Callback = function(s) Settings.Aimbot.AutoTargetSwitch = s end })
    AimbotGroup:AddToggle({ Name = "Use Max Distance", Flag = "AimbotMaxDistanceEnabled", Value = Settings.Aimbot.MaxDistance.Enabled, Callback = function(s) Settings.Aimbot.MaxDistance.Enabled = s end })
    AimbotGroup:AddSlider({ Name = "Max Distance", Flag = "AimbotMaxDistance", Value = Settings.Aimbot.MaxDistance.Value, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) Settings.Aimbot.MaxDistance.Value = v end })
    AimbotGroup:AddSlider({ Name = "Strength", Flag = "AimbotEasingStrength", Value = Settings.Aimbot.Easing.Strength, Min = 0.1, Max = 1.5, Decimals = 1, Rounding = 1, Callback = function(v) Settings.Aimbot.Easing.Strength = v updateSensitivity(v) end })
end

local ESPGroup = Tabs.Visuals:CreateSection({Name = "ESP"})
ESPGroup:AddToggle({ Name = "Enabled", Flag = "ESPEnabled", Value = Settings.ESP.Enabled, Callback = function(s)
    Settings.ESP.Enabled = s
    if s then
        initializeESP()
        State.PlayerCacheUpdate = RunService.Heartbeat:Connect(updatePlayerCache)
        local last = tick() local interval = 1 / 240
        State.ESPLoop = RunService.Heartbeat:Connect(function() local now = tick() if now - last >= interval then renderESP() last = now end end)
    else
        if State.PlayerCacheUpdate then State.PlayerCacheUpdate:Disconnect() end
        if State.ESPLoop then State.ESPLoop:Disconnect() end
        for p in pairs(State.Storage.ESPCache) do uncacheObject(p) end
        State.PlayersToDraw = {} State.CachedProperties = {}
    end
end })
local function updateESPFeature(f, s) Settings.ESP.Features[f].Enabled = s for _, c in pairs(State.Storage.ESPCache) do if f == "Box" then c.BoxSquare.Visible = s c.BoxOutline.Visible = s elseif f == "Tracer" then c.TracerLine.Visible = s elseif f == "HeadDot" then c.HeadDot.Visible = s elseif f == "DistanceText" then c.DistanceLabel.Visible = s elseif f == "Name" then c.NameLabel.Visible = s end end end
ESPGroup:AddToggle({ Name = "Box", Flag = "ESPBox", Value = Settings.ESP.Features.Box.Enabled, Callback = function(s) updateESPFeature("Box", s) end })
ESPGroup:AddToggle({ Name = "Tracer", Flag = "ESPTracer", Value = Settings.ESP.Features.Tracer.Enabled, Callback = function(s) updateESPFeature("Tracer", s) end })
ESPGroup:AddToggle({ Name = "Head Dot", Flag = "ESPHeadDot", Value = Settings.ESP.Features.HeadDot.Enabled, Callback = function(s) updateESPFeature("HeadDot", s) end })
ESPGroup:AddToggle({ Name = "Distance", Flag = "ESPDistance", Value = Settings.ESP.Features.DistanceText.Enabled, Callback = function(s) updateESPFeature("DistanceText", s) end })
ESPGroup:AddToggle({ Name = "Name", Flag = "ESPName", Value = Settings.ESP.Features.Name.Enabled, Callback = function(s) updateESPFeature("Name", s) end })
ESPGroup:AddToggle({ Name = "Wall Check", Flag = "ESPVisibilityCheck", Value = Settings.ESP.VisibilityCheck, Callback = function(s) Settings.ESP.VisibilityCheck = s end })


local ESPCustomization = Tabs.Visuals:CreateSection({Name = "ESP Colors", Side = "Right"})
local function updateESPColor(f, c) Settings.ESP.Features[f].Color = c for _, cache in pairs(State.Storage.ESPCache) do if f == "Box" then cache.BoxSquare.Color = c elseif f == "Tracer" then cache.TracerLine.Color = c elseif f == "HeadDot" then cache.HeadDot.Color = c elseif f == "DistanceText" then cache.DistanceLabel.Color = c elseif f == "Name" then cache.NameLabel.Color = c end end end
ESPCustomization:AddColorPicker({ Name = "Box Color", Flag = "ESPBoxColor", Color = Settings.ESP.Features.Box.Color, Callback = function(v) updateESPColor("Box", v) end })
ESPCustomization:AddColorPicker({ Name = "Tracer Color", Flag = "ESPTracerColor", Color = Settings.ESP.Features.Tracer.Color, Callback = function(v) updateESPColor("Tracer", v) end })
ESPCustomization:AddColorPicker({ Name = "Distance Color", Flag = "ESPDistanceColor", Color = Settings.ESP.Features.DistanceText.Color, Callback = function(v) updateESPColor("DistanceText", v) end })
ESPCustomization:AddColorPicker({ Name = "Head Dot Color", Flag = "ESPHeadDotColor", Color = Settings.ESP.Features.HeadDot.Color, Callback = function(v) updateESPColor("HeadDot", v) end })
ESPCustomization:AddColorPicker({ Name = "Name Color", Flag = "ESPNameColor", Color = Settings.ESP.Features.Name.Color, Callback = function(v) updateESPColor("Name", v) end })


local DistanceCustomization = Tabs.Visuals:CreateSection({Name = "Distance Settings", Side = "Right"})
DistanceCustomization:AddToggle({ Name = "Use Max Distance", Flag = "ESPMaxDistanceEnabled", Value = Settings.ESP.MaxDistance.Enabled, Callback = function(s) Settings.ESP.MaxDistance.Enabled = s refreshPlayerCache() end })
DistanceCustomization:AddSlider({ Name = "Max Distance", Flag = "ESPMaxDistance", Value = Settings.ESP.MaxDistance.Value, Min = 50, Max = 1000, Rounding = 0, Callback = function(v) Settings.ESP.MaxDistance.Value = v refreshPlayerCache() end })


local FOVGroup = Tabs.Main:CreateSection({Name = "FOV", Side = "Right"})
FOVGroup:AddToggle({ Name = "Show FOV Circle", Flag = "FOVEnabled", Value = Settings.FOV.Enabled, Callback = function(s) Settings.FOV.Enabled = s Settings.FOV.Circle.Visible = s Settings.FOV.OutlineCircle.Visible = s end })
FOVGroup:AddToggle({ Name = "Follow Gun", Flag = "FOVFollowGun", Value = Settings.FOV.FollowGun, Callback = function(s) Settings.FOV.FollowGun = s end })
FOVGroup:AddToggle({ Name = "Fill FOV Circle", Flag = "FOVFilled", Value = Settings.FOV.Filled, Callback = function(s) Settings.FOV.Filled = s Settings.FOV.Circle.Filled = s Settings.FOV.Circle.Color = s and Settings.FOV.FillColor or Settings.FOV.OutlineColor Settings.FOV.Circle.Transparency = s and Settings.FOV.FillTransparency or Settings.FOV.OutlineTransparency Settings.FOV.Circle.Thickness = s and 0 or 1 end })
FOVGroup:AddColorPicker({ Name = "Inline Color", Flag = "FOVFillColor", Color = Settings.FOV.FillColor, Transparency = Settings.FOV.FillTransparency, Callback = function(v) Settings.FOV.FillColor = v if Settings.FOV.Filled then Settings.FOV.Circle.Color = v end end })
FOVGroup:AddSlider({ Name = "Inline Transparency", Flag = "FOVFillTransparency", Value = Settings.FOV.FillTransparency, Min = 0, Max = 1, Rounding = 2, Callback = function(v) Settings.FOV.FillTransparency = v if Settings.FOV.Filled then Settings.FOV.Circle.Transparency = v end end })
FOVGroup:AddColorPicker({ Name = "Outline Color", Flag = "FOVOutlineColor", Color = Settings.FOV.OutlineColor, Transparency = Settings.FOV.OutlineTransparency, Callback = function(v) Settings.FOV.OutlineColor = v Settings.FOV.OutlineCircle.Color = v if not Settings.FOV.Filled then Settings.FOV.Circle.Color = v end end })
FOVGroup:AddSlider({ Name = "Outline Transparency", Flag = "FOVOutlineTransparency", Value = Settings.FOV.OutlineTransparency, Min = 0, Max = 1, Rounding = 2, Callback = function(v) Settings.FOV.OutlineTransparency = v Settings.FOV.OutlineCircle.Transparency = v if not Settings.FOV.Filled then Settings.FOV.Circle.Transparency = v end end })
FOVGroup:AddSlider({ Name = "FOV Radius", Flag = "FOVRadius", Value = Settings.FOV.Radius, Min = 50, Max = 1000, Rounding = 0, Callback = function(v) Settings.FOV.Radius = v Settings.FOV.Circle.Radius = v Settings.FOV.OutlineCircle.Radius = v end })


local ChamsGroup = Tabs.Visuals:CreateSection({Name = "Chams"})
ChamsGroup:AddToggle({ Name = "Enabled", Flag = "ChamsEnabled", Value = Settings.Chams.Enabled, Callback = function(s)
    Settings.Chams.Enabled = s
    if s then State.ChamsUpdateConnection = RunService.RenderStepped:Connect(updateChams)
    else if State.ChamsUpdateConnection then State.ChamsUpdateConnection:Disconnect() State.ChamsUpdateConnection = nil end for p in pairs(State.Highlights) do removeHighlight(p) end
    end
end })
ChamsGroup:AddColorPicker({ Name = "Fill Color", Flag = "ChamsFillColor", Color = Settings.Chams.Fill.Color, Transparency = 0, Callback = function(v) Settings.Chams.Fill.Color = v for _, h in pairs(State.Highlights) do h.FillColor = v end end })
ChamsGroup:AddColorPicker({ Name = "Outline Color", Flag = "ChamsOutlineColor", Color = Settings.Chams.Outline.Color, Transparency = 0, Callback = function(v) Settings.Chams.Outline.Color = v for _, h in pairs(State.Highlights) do h.OutlineColor = v end end })
ChamsGroup:AddSlider({ Name = "Fill Transparency", Flag = "ChamsFillTransparency", Value = Settings.Chams.Fill.Transparency, Min = 0, Max = 1, Rounding = 1, Callback = function(v) Settings.Chams.Fill.Transparency = v for _, h in pairs(State.Highlights) do h.FillTransparency = v end end })
ChamsGroup:AddSlider({ Name = "Outline Transparency", Flag = "ChamsOutlineTransparency", Value = Settings.Chams.Outline.Transparency, Min = 0, Max = 1, Rounding = 1, Callback = function(v) Settings.Chams.Outline.Transparency = v for _, h in pairs(State.Highlights) do h.OutlineTransparency = v end end })


local PlayerGroup = Tabs.Player:CreateSection({Name = "Player"})
PlayerGroup:AddToggle({ Name = "Bunny Hop", Flag = "BhopEnabled", Value = Settings.Player.Bhop.Enabled, Callback = function(s) Settings.Player.Bhop.Enabled = s end })


local Optimizations = Tabs.Misc:CreateSection({Name = "Miscellaneous"})
Optimizations:AddToggle({ Name = "Toggle Textures", Flag = "MiscTextures", Value = Settings.Misc.Textures, Callback = function(s) Settings.Misc.Textures = s if s then optimizeMap() else revertMap() end end })

local Safety = Tabs.Misc:CreateSection({Name = "Safety", Side = "Right"})
Safety:AddToggle({ Name = "Rejoin on Votekick", Flag = "VotekickRejoiner", Value = Settings.Misc.VotekickRejoiner, Callback = function(s) Settings.Misc.VotekickRejoiner = s if s then initializeVotekickRejoiner() end end })


Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateFOVCirclePosition)
RunService.Heartbeat:Connect(updateFOVCirclePosition)

local function handleBhop()
    if Settings.Player.Bhop.Enabled then
        local t = tick()
        if (t - lastJumpTime) < jumpCooldown then
            local hum = getCharacter():FindFirstChildOfClass("Humanoid")
            if hum then hum.Jump = true end
        end
        lastJumpTime = t
    end
end

UserInputService.InputBegan:Connect(function(i, gp) if gp then return end if i.KeyCode == Enum.KeyCode.Space then handleBhop() end end)


Library:OnUnload(function()
    for p in pairs(State.Storage.ESPCache) do uncacheObject(p) end
    for p in pairs(State.Highlights) do removeHighlight(p) end
    if State.PlayerCacheUpdate then State.PlayerCacheUpdate:Disconnect() end
    if State.ESPLoop then State.ESPLoop:Disconnect() end
    if State.ChamsUpdateConnection then State.ChamsUpdateConnection:Disconnect() end
    if State.InputBeganConnection then State.InputBeganConnection:Disconnect() end
    if State.InputEndedConnection then State.InputEndedConnection:Disconnect() end
    if State.RenderSteppedConnection then State.RenderSteppedConnection:Disconnect() end
    if State.CrosshairUpdate then State.CrosshairUpdate:Disconnect() end
    for _, d in pairs(Settings.Crosshair.Drawings) do d:Remove() end
    Settings.FOV.Circle:Remove() Settings.FOV.OutlineCircle:Remove()
    stopMousePreload()
    revertMap()
    _G.ScriptIsRunning = false
end)
