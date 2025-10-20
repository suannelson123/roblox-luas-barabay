--[[
-- add esp for claymores.
-- a,dd aimbot for Players, drones, claymores (OPTIONAL! can disable aimbot for drones/claymores if desired).
-- aimbot uses bounding box center for aiming (more reliable than head/torso). im just suck at lua i cant find head at the moment and torso is buns. 
]]


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")


if typeof(Drawing) ~= "table" and typeof(Drawing) ~= "userdata" and typeof(Drawing) ~= "function" then
	warn("Drawing API not detected. Aborting ESP/Aimbot.")
	return
end


if shared.__ESP_AIMBOT then
	local prev = shared.__ESP_AIMBOT
	if prev._cleanup then pcall(prev._cleanup) end
	if prev._drawings then
		for _, d in pairs(prev._drawings) do
			pcall(function() d:Remove() end)
		end
	end
end

shared.__ESP_AIMBOT = shared.__ESP_AIMBOT or {}
local GLOBAL = shared.__ESP_AIMBOT
GLOBAL._drawings = GLOBAL._drawings or {}


local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
local camera = Workspace.CurrentCamera


local function safeRemove(d)
	if not d then return end
	pcall(function() d:Remove() end)
end
local function safeSetVisible(d, v)
	if not d then return end
	pcall(function() d.Visible = v end)
end
local function storeGlobalDrawing(key, drawObj)
	if not drawObj then return end
	GLOBAL._drawings[key] = drawObj
end
local function getGlobalDrawing(key) return GLOBAL._drawings[key] end

local settings = {
	-- ESP
	espoverall = true,
	espbox = true,
	espboxoutline = true,
	espname = true,
	espdrone = true,
	espdroneoutline = true,
	espclaymore = true,
	espclaymoreoutline = true,

	aimbotEnabled = true,
	aimHoldToLock = true,                      
	aimKeyInputType = Enum.UserInputType.MouseButton2,
	aimKeyCode = Enum.KeyCode.P,
	aimSmoothnessPlayers = 0.95,              
	aimSmoothnessDrones = 0.85,                 
	aimSmoothnessClaymores = 0.85,                            
	fovRadius = 50,                          
	drawFOV = false,
	drawAimIndicator = true,
	aimTargetPriority = {"Player","Claymore","Drone"},  
	aimOnlyWhenVisible = true,
	
	espMaxDistance = 500,
}
GLOBAL.settings = settings

local function applySettings(new)
	if type(new) == "table" then
		for k,v in pairs(new) do
			settings[k] = v
			GLOBAL.settings[k] = v
		end
	end

	local fov = getGlobalDrawing("fovCircle")
	local fovOut = getGlobalDrawing("fovCircleOutline")
	if settings.drawFOV then
		if not fov then
			fov = Drawing.new("Circle")
			fov.Filled = false
			fov.Thickness = 1
			fov.Transparency = 0.6
			fov.NumSides = 16
			storeGlobalDrawing("fovCircle", fov)
		end
		if not fovOut then
			fovOut = Drawing.new("Circle")
			fovOut.Filled = false
			fovOut.Thickness = 2
			fovOut.Transparency = 0.6
			fovOut.NumSides = 16
			storeGlobalDrawing("fovCircleOutline", fovOut)
		end
		pcall(function()
			fov.Radius = settings.fovRadius
			fovOut.Radius = settings.fovRadius + 1
			fov.Visible = true
			fovOut.Visible = true
		end)
	else
		if fov then safeRemove(fov); GLOBAL._drawings["fovCircle"] = nil end
		if fovOut then safeRemove(fovOut); GLOBAL._drawings["fovCircleOutline"] = nil end
	end

	local aimInd = getGlobalDrawing("aimIndicator")
	if settings.drawAimIndicator then
		if not aimInd then
			aimInd = Drawing.new("Circle")
			aimInd.Filled = false
			aimInd.Thickness = 2
			aimInd.Transparency = 0.9
			aimInd.NumSides = 16
			aimInd.Radius = 6
			aimInd.Visible = false
			storeGlobalDrawing("aimIndicator", aimInd)
		end
	else
		if aimInd then safeRemove(aimInd); GLOBAL._drawings["aimIndicator"] = nil end
	end
end

GLOBAL.updateSettings = applySettings
applySettings({}) 

local espboxes = {}          
local espboxoutlines = {}
local espnames = {}

local espdrones = {}         
local espdroneoutlines = {}

local espclaymores = {}      
local espclaymoreoutlines = {}

local function getenemies()
	local team = lp and lp.Team
	local enemies = {}
	for _,plr in pairs(Players:GetPlayers()) do
		if settings.espoverall and plr.Character and plr.Team ~= team then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				table.insert(enemies, plr.Character)
			end
		end
	end

	local drones = {}
	local claymores = {}
	for _,v in pairs(Workspace:GetChildren()) do
		if v:IsA("Model") then
			if v.Name == "Drone" then table.insert(drones, v)
			elseif v.Name == "Claymore" then table.insert(claymores, v)
			end
		end
	end

	return enemies, drones, claymores
end

local function getCharMinMax(model)
	if not camera or not model then return nil end

	local minX, maxX = math.huge, -math.huge
	local minY, maxY = math.huge, -math.huge
	local found = false

	for _,part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local cf = part.CFrame
			local size = part.Size * 0.5
			local corners = {
				Vector3.new(-size.X, -size.Y, -size.Z),
				Vector3.new(-size.X, -size.Y,  size.Z),
				Vector3.new(-size.X,  size.Y, -size.Z),
				Vector3.new(-size.X,  size.Y,  size.Z),
				Vector3.new( size.X, -size.Y, -size.Z),
				Vector3.new( size.X, -size.Y,  size.Z),
				Vector3.new( size.X,  size.Y, -size.Z),
				Vector3.new( size.X,  size.Y,  size.Z),
			}
			for _,off in pairs(corners) do
				local worldPoint = cf:PointToWorldSpace(off)
				local screenVec3 = camera:WorldToViewportPoint(worldPoint)
				if screenVec3.Z > 0 then
					found = true
					minX = math.min(minX, screenVec3.X)
					maxX = math.max(maxX, screenVec3.X)
					minY = math.min(minY, screenVec3.Y)
					maxY = math.max(maxY, screenVec3.Y)
				end
			end
		end
	end

	if not found then return nil end
	return maxX, maxY, minX, minY
end

local function getModelWorldPosition(model)
	if not model then return nil end
	if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then return model.PrimaryPart.Position end
	local tryNames = {"Handle","Base","Root","Head","Humanoid"}
	for _,n in ipairs(tryNames) do
		local p = model:FindFirstChild(n)
		if p and p:IsA("BasePart") then return p.Position end
	end
	-- average
	local sum = Vector3.new(0,0,0); local count = 0
	for _,d in pairs(model:GetDescendants()) do
		if d:IsA("BasePart") then sum = sum + d.Position; count = count + 1 end
	end
	if count > 0 then return sum / count end
	return nil
end

local function getOrCreateBoxForPlayer(name)
	if espboxes[name] then return espboxes[name] end
	local sq = Drawing.new("Square")
	sq.Visible = false
	sq.Filled = false
	sq.Thickness = 1
	espboxes[name] = sq
	return sq
end
local function getOrCreateBoxOutlineForPlayer(name)
	if espboxoutlines[name] then return espboxoutlines[name] end
	local sq = Drawing.new("Square")
	sq.Visible = false
	sq.Filled = false
	sq.Thickness = 2
	espboxoutlines[name] = sq
	return sq
end
local function getOrCreateNameText(name)
	if espnames[name] then return espnames[name] end
	local t = Drawing.new("Text")
	t.Visible = false
	t.Center = true
	t.Outline = true
	espnames[name] = t
	return t
end

local function getOrCreateBoxForModelMap(tbl, model, defaultColor)
	if tbl[model] then return tbl[model] end
	local sq = Drawing.new("Square")
	sq.Visible = false
	sq.Filled = false
	sq.Thickness = 1
	if defaultColor then pcall(function() sq.Color = defaultColor end) end
	tbl[model] = sq
	return sq
end
local function getOrCreateOutlineForModelMap(tbl, model)
	if tbl[model] then return tbl[model] end
	local sq = Drawing.new("Square")
	sq.Visible = false
	sq.Filled = false
	sq.Thickness = 2
	tbl[model] = sq
	return sq
end

local function removeplr(name)
	if espboxes[name] then safeRemove(espboxes[name]); espboxes[name] = nil end
	if espboxoutlines[name] then safeRemove(espboxoutlines[name]); espboxoutlines[name] = nil end
	if espnames[name] then safeRemove(espnames[name]); espnames[name] = nil end
end

local function mainESP(model)
	if not model or not model:IsA("Model") then return end
	
	if settings.espMaxDistance > 0 then
		local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
		if root and camera and (root.Position - camera.CFrame.Position).Magnitude > settings.espMaxDistance then
			local nameKey = model.Name or tostring(model)
			if espboxes[nameKey] then safeSetVisible(espboxes[nameKey], false) end
			if espboxoutlines[nameKey] then safeSetVisible(espboxoutlines[nameKey], false) end
			if espnames[nameKey] then safeSetVisible(espnames[nameKey], false) end
			return
		end
	end
	
	local nameKey = model.Name or tostring(model)

	local ok, boundsOrErr = pcall(function() return getCharMinMax(model) end)
	if not ok or not boundsOrErr then
		if espboxes[nameKey] then safeSetVisible(espboxes[nameKey], false) end
		if espboxoutlines[nameKey] then safeSetVisible(espboxoutlines[nameKey], false) end
		if espnames[nameKey] then safeSetVisible(espnames[nameKey], false) end
		return
	end

	local maxX, maxY, minX, minY = getCharMinMax(model)
	if not maxX then
		if espboxes[nameKey] then safeSetVisible(espboxes[nameKey], false) end
		if espboxoutlines[nameKey] then safeSetVisible(espboxoutlines[nameKey], false) end
		if espnames[nameKey] then safeSetVisible(espnames[nameKey], false) end
		return
	end

	if settings.espboxoutline then
		local outline = getOrCreateBoxOutlineForPlayer(nameKey)
		outline.Color = Color3.new(0,0,0)
		outline.Transparency = 0.5
		outline.Visible = true
		outline.Size = Vector2.new(maxX - minX, maxY - minY)
		outline.Position = Vector2.new(minX, minY)
	else
		if espboxoutlines[nameKey] then safeSetVisible(espboxoutlines[nameKey], false) end
	end

	if settings.espbox then
		local box = getOrCreateBoxForPlayer(nameKey)
		box.Color = Color3.new(1,1,1)
		box.Transparency = 0.5
		box.Visible = true
		box.Size = Vector2.new(maxX - minX, maxY - minY)
		box.Position = Vector2.new(minX, minY)
	else
		if espboxes[nameKey] then safeSetVisible(espboxes[nameKey], false) end
	end

	if settings.espname then
		local nameDraw = getOrCreateNameText(nameKey)
		nameDraw.Color = Color3.new(1,1,1)
		nameDraw.Text = model.Name or tostring(model)
		nameDraw.Size = 12
		nameDraw.Visible = true
		local ok2, tb = pcall(function() return nameDraw.TextBounds end)
		local textY = 0
		if ok2 and tb and tb.Y then textY = tb.Y end
		nameDraw.Position = Vector2.new(minX + (maxX - minX)/2, minY - textY - 3)
	else
		if espnames[nameKey] then safeSetVisible(espnames[nameKey], false) end
	end
end

local function removedrone(model)
	if model == nil then return end
	if espdrones[model] then safeRemove(espdrones[model]); espdrones[model] = nil end
	if espdroneoutlines[model] then safeRemove(espdroneoutlines[model]); espdroneoutlines[model] = nil end
end

local function drone_esp(model)
	if not model or not model:IsDescendantOf(Workspace) or not model:IsA("Model") then
		removedrone(model)
		return
	end
	
	if settings.espMaxDistance > 0 then
		local pos = getModelWorldPosition(model)
		if pos and camera and (pos - camera.CFrame.Position).Magnitude > settings.espMaxDistance then
			if espdrones[model] then safeSetVisible(espdrones[model], false) end
			if espdroneoutlines[model] then safeSetVisible(espdroneoutlines[model], false) end
			return
		end
	end
	
	local maxX, maxY, minX, minY = getCharMinMax(model)
	if not maxX then
		if espdrones[model] then safeSetVisible(espdrones[model], false) end
		if espdroneoutlines[model] then safeSetVisible(espdroneoutlines[model], false) end
		return
	end

	if settings.espdroneoutline then
		local outline = getOrCreateOutlineForModelMap(espdroneoutlines, model)
		outline.Color = Color3.new(0,0,0)
		outline.Transparency = 0.5
		outline.Visible = true
		outline.Size = Vector2.new(maxX - minX, maxY - minY)
		outline.Position = Vector2.new(minX, minY)
	else
		if espdroneoutlines[model] then safeSetVisible(espdroneoutlines[model], false) end
	end

	if settings.espdrone then
		local box = getOrCreateBoxForModelMap(espdrones, model, Color3.new(1,0,0))
		box.Color = Color3.new(1,0,0)
		box.Transparency = 0.5
		box.Visible = true
		box.Size = Vector2.new(maxX - minX, maxY - minY)
		box.Position = Vector2.new(minX, minY)
	else
		if espdrones[model] then safeSetVisible(espdrones[model], false) end
	end
end

local function removeclaymore(model)
	if model == nil then return end
	if espclaymores[model] then safeRemove(espclaymores[model]); espclaymores[model] = nil end
	if espclaymoreoutlines[model] then safeRemove(espclaymoreoutlines[model]); espclaymoreoutlines[model] = nil end
end

local function claymore_esp(model)
	if not model or not model:IsDescendantOf(Workspace) or not model:IsA("Model") then
		removeclaymore(model)
		return
	end
	
	if settings.espMaxDistance > 0 then
		local pos = getModelWorldPosition(model)
		if pos and camera and (pos - camera.CFrame.Position).Magnitude > settings.espMaxDistance then
			if espclaymores[model] then safeSetVisible(espclaymores[model], false) end
			if espclaymoreoutlines[model] then safeSetVisible(espclaymoreoutlines[model], false) end
			return
		end
	end
	
	local maxX, maxY, minX, minY = getCharMinMax(model)
	if not maxX then
		if espclaymores[model] then safeSetVisible(espclaymores[model], false) end
		if espclaymoreoutlines[model] then safeSetVisible(espclaymoreoutlines[model], false) end
		return
	end

	if settings.espclaymoreoutline then
		local outline = getOrCreateOutlineForModelMap(espclaymoreoutlines, model)
		outline.Color = Color3.new(0,0,0)
		outline.Transparency = 0.5
		outline.Visible = true
		outline.Size = Vector2.new(maxX - minX, maxY - minY)
		outline.Position = Vector2.new(minX, minY)
	else
		if espclaymoreoutlines[model] then safeSetVisible(espclaymoreoutlines[model], false) end
	end

	if settings.espclaymore then
		local box = getOrCreateBoxForModelMap(espclaymores, model, Color3.new(1,0.3,0))
		box.Color = Color3.new(1, 0.3, 0)
		box.Transparency = 0.6
		box.Visible = true
		box.Size = Vector2.new(maxX - minX, maxY - minY)
		box.Position = Vector2.new(minX, minY)
	else
		if espclaymores[model] then safeSetVisible(espclaymores[model], false) end
	end
end

local function charhook(plr)
	if not plr then return end
	plr.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid", 5)
		if hum then
			hum.Died:Connect(function() removeplr(plr.Name) end)
		end
	end)
	if plr.Character then
		local hum = plr.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.Died:Connect(function() removeplr(plr.Name) end) end
	end
end

Players.PlayerAdded:Connect(charhook)
for _,p in ipairs(Players:GetPlayers()) do charhook(p) end

local function getBoundingBoxCenter(model)
    if not model or not model:IsA("Model") then return nil end
    
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
    local found = false

    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local cf = part.CFrame
            local size = part.Size
            local corners = {
                Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
                Vector3.new(-size.X/2, -size.Y/2,  size.Z/2),
                Vector3.new(-size.X/2,  size.Y/2, -size.Z/2),
                Vector3.new(-size.X/2,  size.Y/2,  size.Z/2),
                Vector3.new( size.X/2, -size.Y/2, -size.Z/2),
                Vector3.new( size.X/2, -size.Y/2,  size.Z/2),
                Vector3.new( size.X/2,  size.Y/2, -size.Z/2),
                Vector3.new( size.X/2,  size.Y/2,  size.Z/2)
            }

            for _, corner in pairs(corners) do
                local worldCorner = cf:PointToWorldSpace(corner)
                minX = math.min(minX, worldCorner.X)
                minY = math.min(minY, worldCorner.Y)
                minZ = math.min(minZ, worldCorner.Z)
                maxX = math.max(maxX, worldCorner.X)
                maxY = math.max(maxY, worldCorner.Y)
                maxZ = math.max(maxZ, worldCorner.Z)
                found = true
            end
        end
    end

    if found then
        return Vector3.new((minX + maxX)/2, (minY + maxY)/2, (minZ + maxZ)/2)
    end
    
    return nil
end

local function getBoundingBoxAimPosition(model, kind)
    if not model then return nil end
    
    local bboxCenter = getBoundingBoxCenter(model)
    if bboxCenter then
        return bboxCenter
    end
    
    return getModelWorldPosition(model)
end

local function pickAimbotTarget(drones, claymores)
    if not camera then camera = Workspace.CurrentCamera end
    if not camera then return nil end
    local cx = camera.ViewportSize.X / 2
    local cy = camera.ViewportSize.Y / 2
    local center = Vector2.new(cx, cy)

    local function pickFromList(list, kind)
        local best = nil
        local bestDist = math.huge
        for _,m in pairs(list) do
            if m and m:IsDescendantOf(Workspace) then
                local worldPos = getBoundingBoxAimPosition(m, kind)
                if worldPos then
                    local screenVec3 = camera:WorldToViewportPoint(worldPos)
                    if settings.aimOnlyWhenVisible and screenVec3.Z <= 0 then
                    else
                        local screenVec = Vector2.new(screenVec3.X, screenVec3.Y)
                        local dist = (screenVec - center).Magnitude
                        if dist <= settings.fovRadius and dist < bestDist then
                            bestDist = dist
                            best = {
                                model = m, 
                                screen = screenVec, 
                                world = worldPos, 
                                kind = kind,
                                bboxCenter = getBoundingBoxCenter(m)
                            }
                        end
                    end
                end
            end
        end
        return best
    end

    local enemiesList = {}
    do
        local myTeam = lp and lp.Team
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character and plr.Team ~= myTeam then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    table.insert(enemiesList, plr.Character)
                end
            end
        end
    end

    for _,kind in ipairs(settings.aimTargetPriority) do
        if kind == "Player" then
            local v = pickFromList(enemiesList, "Player")
            if v then return v, "Player" end
        elseif kind == "Claymore" then
            local v = pickFromList(claymores, "Claymore")
            if v then return v, "Claymore" end
        elseif kind == "Drone" then
            local v = pickFromList(drones, "Drone")
            if v then return v, "Drone" end
        end
    end
    return nil, nil
end

local function smoothLookAt(currentCFrame, targetPos, targetKind)
    local smoothness = 0.5 
    
    if targetKind == "Player" then
        smoothness = settings.aimSmoothnessPlayers or 0.90
    elseif targetKind == "Drone" then
        smoothness = settings.aimSmoothnessDrones or 0.50
    elseif targetKind == "Claymore" then
        smoothness = settings.aimSmoothnessClaymores or 0.50
    end
    
    local t = math.clamp(1 - smoothness, 0, 1)
    local camPos = currentCFrame.Position
    local goal = CFrame.new(camPos, targetPos)
    return currentCFrame:Lerp(goal, t)
end

local aiming = false
local aimToggleState = false

local function onInputBegan(input, gp)
    if gp then return end
    if settings.aimHoldToLock then
        if input.UserInputType == settings.aimKeyInputType or (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == settings.aimKeyCode) then
            aiming = true
        end
    else
        if input.UserInputType == settings.aimKeyInputType or (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == settings.aimKeyCode) then
            aimToggleState = not aimToggleState
        end
    end
end
local function onInputEnded(input, gp)
    if gp then return end
    if settings.aimHoldToLock then
        if input.UserInputType == settings.aimKeyInputType or (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == settings.aimKeyCode) then
            aiming = false
        end
    end
end

UIS.InputBegan:Connect(onInputBegan)
UIS.InputEnded:Connect(onInputEnded)

local espAccumulator = 0
local espUpdateRate = 1/20

local function cleanupOnStop()
    for k,d in pairs(GLOBAL._drawings) do
        pcall(function() d:Remove() end)
        GLOBAL._drawings[k] = nil
    end
    for k,v in pairs(espboxes) do safeRemove(v); espboxes[k] = nil end
    for k,v in pairs(espboxoutlines) do safeRemove(v); espboxoutlines[k] = nil end
    for k,v in pairs(espnames) do safeRemove(v); espnames[k] = nil end
    for k,v in pairs(espdrones) do safeRemove(v); espdrones[k] = nil end
    for k,v in pairs(espdroneoutlines) do safeRemove(v); espdroneoutlines[k] = nil end
    for k,v in pairs(espclaymores) do safeRemove(v); espclaymores[k] = nil end
    for k,v in pairs(espclaymoreoutlines) do safeRemove(v); espclaymoreoutlines[k] = nil end
end

GLOBAL._cleanup = cleanupOnStop

applySettings({})

RunService.RenderStepped:Connect(function(dt)
    if not camera or not camera.Parent then camera = Workspace.CurrentCamera end
    if not camera then return end

    local screen = camera.ViewportSize
    local fov = getGlobalDrawing("fovCircle")
    local fovOut = getGlobalDrawing("fovCircleOutline")
    if fov then
        pcall(function()
            fov.Position = Vector2.new(screen.X/2, screen.Y/2)
            fov.Radius = settings.fovRadius
            fov.Visible = settings.drawFOV
        end)
    end
    if fovOut then
        pcall(function()
            fovOut.Position = Vector2.new(screen.X/2, screen.Y/2)
            fovOut.Radius = settings.fovRadius + 1
            fovOut.Visible = settings.drawFOV
        end)
    end

    local aimInd = getGlobalDrawing("aimIndicator")
    if aimInd then aimInd.Visible = false end

    if not settings.aimHoldToLock then aiming = aimToggleState end

    local enemies, drones, claymores = getenemies()

    if settings.aimbotEnabled then
        local ok, targetInfo, kind = pcall(function() return pickAimbotTarget(drones, claymores) end)
        if ok and targetInfo then
            if settings.drawAimIndicator then
                local ind = getGlobalDrawing("aimIndicator")
                if ind then
                    pcall(function()
                        ind.Position = targetInfo.screen
                        ind.Visible = true
                        if kind == "Claymore" then ind.Color = Color3.fromRGB(255,140,0) 
                        elseif kind == "Drone" then ind.Color = Color3.fromRGB(0,255,0)
                        else ind.Color = Color3.fromRGB(255,255,255) end
                    end)
                end
            end

if aiming then
    local current = camera.CFrame
    local newCF = smoothLookAt(current, targetInfo.world, kind)
    pcall(function() camera.CFrame = newCF end)
end
        else
            local ind = getGlobalDrawing("aimIndicator")
            if ind then safeSetVisible(ind, false) end
        end
    end

    espAccumulator = espAccumulator + dt
    if espAccumulator >= espUpdateRate then
        espAccumulator = 0

        local entitiesToProcess = {}
        
        for _, e in pairs(enemies) do
            if e and e.Name then
                table.insert(entitiesToProcess, {type = "player", entity = e})
            end
        end
        
        local maxDrones = 8 
        local maxClaymores = 5
        
        for i = 1, math.min(maxDrones, #drones) do
            table.insert(entitiesToProcess, {type = "drone", entity = drones[i]})
        end
        
        for i = 1, math.min(maxClaymores, #claymores) do
            table.insert(entitiesToProcess, {type = "claymore", entity = claymores[i]})
        end
        
        for _, data in pairs(entitiesToProcess) do
            pcall(function()
                if data.type == "player" then
                    mainESP(data.entity)
                elseif data.type == "drone" then
                    drone_esp(data.entity)
                elseif data.type == "claymore" then
                    claymore_esp(data.entity)
                end
            end)
        end

        local alive = {}
        for _,e in pairs(enemies) do
            if e and e.Name then
                alive[e.Name] = true
            end
        end

        for name,_ in pairs(espboxes) do
            if not alive[name] then
                if espboxes[name] then safeSetVisible(espboxes[name], false) end
                if espboxoutlines[name] then safeSetVisible(espboxoutlines[name], false) end
                if espnames[name] then safeSetVisible(espnames[name], false) end
            end
        end

        for model,_ in pairs(espdrones) do
            if not model or not model:IsDescendantOf(Workspace) then
                if espdrones[model] then safeRemove(espdrones[model]); espdrones[model] = nil end
                if espdroneoutlines[model] then safeRemove(espdroneoutlines[model]); espdroneoutlines[model] = nil end
            end
        end
        for model,_ in pairs(espclaymores) do
            if not model or not model:IsDescendantOf(Workspace) then
                if espclaymores[model] then safeRemove(espclaymores[model]); espclaymores[model] = nil end
                if espclaymoreoutlines[model] then safeRemove(espclaymoreoutlines[model]); espclaymoreoutlines[model] = nil end
            end
        end
    end
end)


GLOBAL.stop = function()
    cleanupOnStop()
    shared.__ESP_AIMBOT = nil
end

