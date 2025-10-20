
--player esp
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local camera = game.Workspace.Camera
local UIS = game:GetService("UserInputService")

local espoverall = true

local espbox = true
local espboxoutline = true

local esptracer = false
local esptraceroutline = false
local tracertype = 3 -- 1: bottom of screen, 2: center of screen:, 3: top of screen

local esphealthbar = false
local esphealthbaroutline = false

local espname = true

local espdrone = true
local espdroneoutline = true
local espclaymore = true
local espclaymoreoutline = true

local espboxes = {}
local espboxoutlines = {}
local esptracers = {}
local esptraceroutlines = {}
local esphealthbars = {}
local esphealthbaroutlines = {}
local espnames = {}
local espdrones = {}
local espdroneoutlines = {}
local espclaymores = {}
local espclaymoreoutlines = {}




local screensize = game.Workspace.CurrentCamera.ViewportSize
local screenpositions = {Vector2.new(screensize.X / 2, screensize.Y), Vector2.new(screensize.X / 2, screensize.Y / 2), Vector2.new(screensize.X / 2, 0)}

-- AIM ASSIST CONFIG
local aimOffsetPercent = -0.3 -- negative = aim higher; e.g., -0.3 = 30% above center
local aimAssistEnabled = true
local aimSmoothness = 0.1 -- higher = faster aim snap
local aimOffsetY = -20 -- positive = aim lower, negative = aim higher
local aimKey = Enum.UserInputType.MouseButton2 -- Right-click to aim assist

local aiming = false
UIS.InputBegan:Connect(function(input)
	if input.UserInputType == aimKey then
		aiming = true
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == aimKey then
		aiming = false
	end
end)

-- 🔧 ADJUST AIM SMOOTHNESS IN-GAME
local smoothnessText = Drawing.new("Text")
smoothnessText.Visible = false
smoothnessText.Color = Color3.new(0, 1, 0)
smoothnessText.Size = 16
smoothnessText.Center = true
smoothnessText.Outline = true
smoothnessText.OutlineColor = Color3.new(0, 0, 0)
smoothnessText.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y * 0.1)

local function showSmoothness()
	smoothnessText.Text = string.format("Aim Smoothness: %.2f", aimSmoothness)
	smoothnessText.Visible = true
	task.delay(1.5, function()
		smoothnessText.Visible = false
	end)
end

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end

	-- Decrease smoothness
	if input.KeyCode == Enum.KeyCode.LeftBracket then
		aimSmoothness = math.clamp(aimSmoothness - 0.1, 0, 1)
		showSmoothness()
	end

	-- Increase smoothness
	if input.KeyCode == Enum.KeyCode.RightBracket then
		aimSmoothness = math.clamp(aimSmoothness + 0.1, 0, 1)
		showSmoothness()
	end
end)





local function removeplr(name)
	if espboxes[name] then espboxes[name].Visible = false; espboxes[name]:Remove(); espboxes[name] = nil end
	if espboxoutlines[name] then espboxoutlines[name].Visible = false; espboxoutlines[name]:Remove(); espboxoutlines[name] = nil end
	if esptracers[name] then esptracers[name].Visible = false; esptracers[name]:Remove(); esptracers[name] = nil end
	if esptraceroutlines[name] then esptraceroutlines[name].Visible = false; esptraceroutlines[name]:Remove(); esptraceroutlines[name] = nil end
	if esphealthbars[name] then esphealthbars[name].Visible = false; esphealthbars[name]:Remove(); esphealthbars[name] = nil end
	if esphealthbaroutlines[name] then esphealthbaroutlines[name].Visible = false; esphealthbaroutlines[name]:Remove(); esphealthbaroutlines[name] = nil end
	if espnames[name] then espnames[name].Visible = false; espnames[name]:Remove(); espnames[name] = nil end
end

local function removedrone(drone)
	if espdrones[drone] then espdrones[drone].Visible = false; espdrones[drone]:Remove(); espdrones[drone] = nil end
	if espdroneoutlines[drone] then espdroneoutlines[drone].Visible = false; espdroneoutlines[drone]:Remove(); espdroneoutlines[drone] = nil end
end

local function removeclaymore(claymore)
	if espclaymores[claymore] then
		espclaymores[claymore].Visible = false
		espclaymores[claymore]:Remove()
		espclaymores[claymore] = nil
	end
	if espclaymoreoutlines[claymore] then
		espclaymoreoutlines[claymore].Visible = false
		espclaymoreoutlines[claymore]:Remove()
		espclaymoreoutlines[claymore] = nil
	end
end


local function getenemies()
	local team = lp.Team
	local enemies = {}
	for _,plr in pairs(Players:GetChildren()) do
		if espoverall and plr.Character and Players[plr.Name].Team ~= team then
			local hum = plr.Character:FindFirstChild("Humanoid")
			if hum and hum.Health > 0 then
				table.insert(enemies, plr.Character)
			end
		end
	end
		local drones = {}
	local claymores = {}
	for _,v in pairs(game.Workspace:GetChildren()) do
		if v.Name == "Drone" then
			table.insert(drones, v)
		elseif v.Name == "Claymore" then
			table.insert(claymores, v)
		end
	end
	return enemies, drones, claymores

end



local function getCharMinMax(char)
	local minX, maxX = math.huge, -math.huge
	local minY, maxY = math.huge, -math.huge

	for _, part in pairs(char:GetChildren()) do
		if part:IsA("BasePart") then
			local cf = part.CFrame
			local size = part.Size / 2

			-- Generate the 8 corners of the bounding box
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

			for _, offset in pairs(corners) do
				local worldPoint = cf:PointToWorldSpace(offset)
				local screenPos, onScreen = camera:WorldToViewportPoint(worldPoint)
				if onScreen then
					minX = math.min(minX, screenPos.X)
					maxX = math.max(maxX, screenPos.X)
					minY = math.min(minY, screenPos.Y)
					maxY = math.max(maxY, screenPos.Y)
				end
			end
		end
	end

	return maxX, maxY, minX, minY
end

local function getBoundingBoxCenter(char)
	local maxX, maxY, minX, minY = getCharMinMax(char)
	if not maxX or not minX or minX == math.huge or maxX == -math.huge or minY == math.huge or maxY == -math.huge then
		return nil
	end

	-- Box dimensions
	local boxHeight = maxY - minY
	local boxCenterY = (maxY + minY) / 2

	-- Apply percentage-based vertical offset
	local offsetY = boxHeight * aimOffsetPercent

	return Vector2.new((maxX + minX) / 2, boxCenterY + offsetY)
end



local function screenToWorldDirection(screenPos)
	local viewportSize = camera.ViewportSize
	local unitRay = camera:ViewportPointToRay(screenPos.X, screenPos.Y)
	return unitRay.Direction
end



local function torture(char) -- healthbar position calculations
	local maxX, maxY, minX, minY = getCharMinMax(char)
	local topleft = Vector2.new(minX, minY)

	local boxCFrame, boxSize = char:GetBoundingBox()
	local topCenterWorld = boxCFrame.Position + boxCFrame.UpVector * (boxSize.Y / 2)

	local camLeft = -camera.CFrame.RightVector -- big thanks to roblox devforums
	local p0, on0 = camera:WorldToViewportPoint(topCenterWorld)
	local pL, onL = camera:WorldToViewportPoint(topCenterWorld + camLeft * 0.3)

	if not (on0 and onL) then
		return topleft, topleft
	end

	local LOffset = Vector2.new(pL.X - p0.X, pL.Y - p0.Y)

	local left2d = topleft + LOffset

	return topleft, left2d
end

local function mainESP(target)
	if target == nil or (not target) then
		return
	end
	if not target:IsA("Model") then
		return
	end

	local maxX, maxY, minX, minY = getCharMinMax(target)
	local outline

	-- BOX & OUTLINE
	local box

	if espboxoutlines[target.Name] then
		outline = espboxoutlines[target.Name]
	else
		outline = Drawing.new("Square")
		outline.Visible = true
		outline.Transparency = 0.5
		outline.Color = Color3.new(0,0,0)
		outline.Thickness = 2
		outline.Filled = false
		espboxoutlines[target.Name] = outline
	end

	if espboxes[target.Name] then
		box = espboxes[target.Name]
	else
		box = Drawing.new("Square")
		box.Visible = true
		box.Transparency = 0.5
		box.Color = Color3.new(1,1,1)
		box.Thickness = 1
		box.Filled = false
		espboxes[target.Name] = box
	end

	box.Size = Vector2.new(maxX - minX, maxY - minY)
	box.Position = Vector2.new(minX, minY)

	outline.Size = Vector2.new(maxX - minX, maxY - minY)
	outline.Position = Vector2.new(minX, minY)
	-- BOX & OUTLINE DONE

	-- TRACER & OUTLINE
	local line
	--outlines first cuz we love drawing zindex!!
	if esptraceroutlines[target.Name] then -- use old one
		outline = esptraceroutlines[target.Name]
	else -- make new one
		outline = Drawing.new("Line")
		outline.Visible = false
		outline.Color = Color3.new(0,0,0)
		outline.Thickness = 2 -- or the outline wont show :(
		esptraceroutlines[target.Name] = outline
	end
	-- ok and NOW we do the tracer
	if esptracers[target.Name] then -- tracer exists lets use old
		line = esptracers[target.Name]
	else -- new one baby!!
		line = Drawing.new("Line")
		line.Visible = false
		line.Color = Color3.new(1,1,1)
		line.Thickness = 1 -- make it not cover the outline
		esptracers[target.Name] = line
	end

	--now we update position stuff :)
	outline.From = screenpositions[tracertype]
	line.From = screenpositions[tracertype]

	outline.To = Vector2.new(minX + (maxX - minX)/2, minY) -- center top of the player box
	line.To = Vector2.new(minX + (maxX - minX)/2, minY)
	-- TRACER & OUTLINE DONE

	-- HEALTHBAR & OUTLINE

	local healthbar

	if esphealthbaroutlines[target.Name] then
		outline = esphealthbaroutlines[target.Name]
	else
		outline = Drawing.new("Square")
		outline.Visible = false
		outline.Color = Color3.new(0,0,0)
		outline.Thickness = 2
		outline.Filled = false
		esphealthbaroutlines[target.Name] = outline
	end

	if esphealthbars[target.Name] then
		healthbar = esphealthbars[target.Name]
	else
		healthbar = Drawing.new("Square")
		healthbar.Visible = true
		healthbar.Color = Color3.new(0,1,0)
		healthbar.Thickness = 1
		healthbar.Filled = true
		esphealthbars[target.Name] = healthbar
	end

	local topleft, width = torture(target)
	local hWidth = (topleft - width).Magnitude
	local targethealthloss = Vector2.new(0, (maxY - minY) * (1 - target.Humanoid.Health/100))

	healthbar.Size = Vector2.new(hWidth, (maxY - minY)) - targethealthloss
	healthbar.Position = Vector2.new(topleft.X - hWidth, minY) + targethealthloss

	outline.Size = Vector2.new(hWidth, (maxY - minY)) - targethealthloss
	outline.Position = Vector2.new(topleft.X - hWidth, minY) + targethealthloss
	-- HEALTHBAR & OUTLINE (finally) DONE

	--NAME ESP
	local name

	if espnames[target.Name] then
		name = espnames[target.Name]
	else
		name = Drawing.new("Text")
		name.Visible = true
		name.Color = Color3.new(1,1,1)
		name.Text = target.Name
		name.Size = 12
		name.Center = true
		name.Outline = true
		name.OutlineColor = Color3.new(0,0,0)
		espnames[target.Name] = name
	end

	name.Position = Vector2.new(minX + (maxX - minX)/2, minY - name.TextBounds.Y - 3)
	--NAME ESP DONE
end

local function drone_esp(target)
	if target == nil or (not target) then
		return
	end
	if not target:IsDescendantOf(game.Workspace) then
		removedrone(target)
		return
	end
	if not target:IsA("Model") then
		return
	end

	local maxX, maxY, minX, minY = getCharMinMax(target)
	local outline

	-- BOX & OUTLINE
	local box

	if espdroneoutlines[target] then
		outline = espdroneoutlines[target]
	else
		outline = Drawing.new("Square")
		outline.Visible = true
		outline.Transparency = 0.5
		outline.Color = Color3.new(0,0,0)
		outline.Thickness = 2
		outline.Filled = false
		espdroneoutlines[target] = outline
	end

	if espdrones[target] then
		box = espdrones[target]
	else
		box = Drawing.new("Square")
		box.Visible = true
		box.Transparency = 0.5
		box.Color = Color3.new(1,0,0)
		box.Thickness = 1
		box.Filled = false
		espdrones[target] = box
	end

	box.Size = Vector2.new(maxX - minX, maxY - minY)
	box.Position = Vector2.new(minX, minY)

	outline.Size = Vector2.new(maxX - minX, maxY - minY)
	outline.Position = Vector2.new(minX, minY)
	-- BOX & OUTLINE DONE
end

local function claymore_esp(target)
	if target == nil or (not target) then return end
	if not target:IsDescendantOf(game.Workspace) then
		removeclaymore(target)
		return
	end
	if not target:IsA("Model") then return end

	local maxX, maxY, minX, minY = getCharMinMax(target)
	local outline

	-- BOX & OUTLINE
	local box
	if espclaymoreoutlines[target] then
		outline = espclaymoreoutlines[target]
	else
		outline = Drawing.new("Square")
		outline.Visible = true
		outline.Transparency = 0.5
		outline.Color = Color3.new(0,0,0)
		outline.Thickness = 2
		outline.Filled = false
		espclaymoreoutlines[target] = outline
	end

	if espclaymores[target] then
		box = espclaymores[target]
	else
		box = Drawing.new("Square")
		box.Visible = true
		box.Transparency = 0.5
		box.Color = Color3.new(1, 0.5, 0) -- orange for claymore
		box.Thickness = 1
		box.Filled = false
		espclaymores[target] = box
	end

	box.Size = Vector2.new(maxX - minX, maxY - minY)
	box.Position = Vector2.new(minX, minY)
	outline.Size = Vector2.new(maxX - minX, maxY - minY)
	outline.Position = Vector2.new(minX, minY)
end



Players.PlayerRemoving:Connect(function(plr)
	removeplr(plr.Name)
end)

local function charhook(plr)
	local char = plr.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.Died:Connect(function()
			removeplr(plr.Name)
		end)
	end
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		charhook(plr)
	end)
end)

for _,plr in ipairs(Players:GetPlayers()) do
	if plr.Character then charhook(plr) end
end

game:GetService("RunService").RenderStepped:Connect(function()
		local enemies, drones, claymores = getenemies()


	local alive = {}
	for _,e in pairs(enemies) do
		alive[e.Name] = true
		mainESP(e)
	end

	for _,d in pairs(drones) do
		drone_esp(d)
	end
		for _,c in pairs(claymores) do
		claymore_esp(c)
	end

		for claymore,_ in pairs(espclaymores) do
		if not claymore or not claymore:IsDescendantOf(game.Workspace) then
			removeclaymore(claymore)
		end
	end
	for claymore,_ in pairs(espclaymoreoutlines) do
		if not claymore or not claymore:IsDescendantOf(game.Workspace) then
			removeclaymore(claymore)
		end
	end



	-- 🔫 AIM ASSIST (with activation radius)
	if aimAssistEnabled and aiming and #enemies > 0 then
		local closestEnemy, closestDist, targetCenter = nil, math.huge, nil
		local screenCenter = Vector2.new(screensize.X / 2, screensize.Y / 2)
		local aimActivationRadius = 50 -- pixels; tweak this

		for _, enemy in pairs(enemies) do
			local center = getBoundingBoxCenter(enemy)
			if center then
				local dist = (center - screenCenter).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestEnemy = enemy
					targetCenter = center
				end
			end
		end

		-- Only aim if the closest enemy is within radius
		if closestEnemy and targetCenter and closestDist <= aimActivationRadius then
			local aimDirection = screenToWorldDirection(targetCenter)
			local newCFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + aimDirection)
			camera.CFrame = camera.CFrame:Lerp(newCFrame, aimSmoothness)
		end
	end



	for name,_ in pairs(espboxes) do
		if not alive[name] then removeplr(name) end
	end
	for name,_ in pairs(espboxoutlines) do
	if not alive[name] then removeplr(name) end
	end
	for name,_ in pairs(esptracers) do
		if not alive[name] then removeplr(name) end
	end
	for name,_ in pairs(esptraceroutlines) do
		if not alive[name] then removeplr(name) end
	end
	for name,_ in pairs(esphealthbars) do
		if not alive[name] then removeplr(name) end
	end
	for name,_ in pairs(esphealthbaroutlines) do
		if not alive[name] then removeplr(name) end
	end
	for name,_ in pairs(espnames) do
		if not alive[name] then removeplr(name) end
	end

	for drone,_ in pairs(espdrones) do
		if not drone or not drone:IsDescendantOf(game.Workspace) then
			removedrone(drone)
		end
	end
	for drone,_ in pairs(espdroneoutlines) do
		if not drone or not drone:IsDescendantOf(game.Workspace) then
			removedrone(drone)
		end
	end
end)