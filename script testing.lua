
local baylib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local flying = false
local bv
local bg 
local humanoid


local Window = baylib:MakeWindow({
	Title = "Testing ko lang mga Boss : Universal",
	SubTitle = "by BIsakol na taga Manila",
})

local Tab1 = Window:MakeTab({
	"Um",
	"cherry"
})
local Section = Tab1:AddSection({
	"Section 1"
})
local Paragraph = Tab1:AddParagraph({
	"Omsim tooooool",
	"Omsim tol number 2"
})


Tab1:AddDiscordInvite({
	Name = "Bisakol na Hub",
	Description = "Join server",
	Logo = "rbxassetid://18751483361",
	Invite = "discord.gg/pinayFlix"
})
local Toggle1 = Tab1:AddToggle({
	Name = "Testing sa Toggle",
	Description = "This is a <font color='rgb(88, 101, 242)'>Toggle</font> Example",
	Default = false 
})
Toggle1:Callback(function(Value)
end)


Tab1:AddSlider({
	Name = "Speed",
	Min = 1,
	Max = 100,
	Increase = 1,
	Default = 16,
	Callback = function(Value)
		local function setSpeed(character)
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.WalkSpeed = Value
		end
		player.CharacterAdded:Connect(setSpeed)
		if player.Character then
			setSpeed(player.Character)
		end
	end
})
Tab1:AddButton({
	"Fly",
	function()
		local function startFly()
			local character = player.Character or player.CharacterAdded:Wait()
			local hrp = character:WaitForChild("HumanoidRootPart")
			humanoid = character:WaitForChild("Humanoid")
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			bv = Instance.new("BodyVelocity")
			bv.Velocity = Vector3.zero
			bv.MaxForce = Vector3.new(4000, 4000, 4000)
			bv.Parent = hrp
			bg = Instance.new("BodyGyro")
			bg.CFrame = hrp.CFrame
			bg.MaxTorque = Vector3.new(4000, 4000, 4000)
			bg.Parent = hrp
			flying = true
		end
		local function stopFly()
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
			if bv then
				bv:Destroy()
			end
			if bg then
				bg:Destroy()
			end
			flying = false
		end
		RunService.RenderStepped:Connect(function()
			if flying and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = player.Character.HumanoidRootPart
				local cam = workspace.CurrentCamera
				local moveDirection = Vector3.zero
				if UIS:IsKeyDown(Enum.KeyCode.W) then
					moveDirection += cam.CFrame.LookVector
				end
				if UIS:IsKeyDown(Enum.KeyCode.S) then
					moveDirection -= cam.CFrame.LookVector
				end
				if UIS:IsKeyDown(Enum.KeyCode.A) then
					moveDirection -= cam.CFrame.RightVector
				end
				if UIS:IsKeyDown(Enum.KeyCode.D) then
					moveDirection += cam.CFrame.RightVector
				end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then
					moveDirection += Vector3.yAxis
				end
				if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
					moveDirection -= Vector3.yAxis
				end
				if moveDirection.Magnitude > 0 then
					bv.Velocity = moveDirection.Unit * humanoid.WalkSpeed
					print("tis humanoid walkspeed", bv.Velocity)
				else
					bv.Velocity = Vector3.zero
				end
				bg.CFrame = cam.CFrame
			end
		end)
		UIS.InputBegan:Connect(function(input, gp)
			if gp then
				return
			end
			if input.KeyCode == Enum.KeyCode.F then
				if flying then
					stopFly()
				else
					startFly()
				end
			end
		end)
		local Dialog = Window:Dialog({
			Title = "Info to Fly",
			Text = "Press F to turn on fly and off",
			Options = {
				{
					"Ok",
					function()
					end
				}
			}
		})
	end
})

local P = {}
for _, player in ipairs(Players:GetPlayers()) do
	table.insert(P, player)
end

Players.PlayerAdded:Connect(function(player)
	table.insert(P, player)
end)

Players.PlayerRemoving:Connect(function(player)
	for i, plr in ipairs(P) do
		if plr == player then
			table.remove(P, i)
			break
		end
	end
end)

local Dropdown = Tab1:AddDropdown({
	Name = "Players List",
	Description = "Select the <font color='rgb(88, 101, 242)'>Number</font>",
	Options = P,
	Default = player,
	Flag = "dropdown teste",
	Callback = function(Value)
		print(Value)
	end
})


Tab1:AddTextBox({
	Name = "Name item",
	Description = "1 Item on 1 Server",
	PlaceholderText = "item only",
	Callback = function(Value)
		print(Value)
	end
})


local Tab2 = Window:MakeTab({
	"Tab 2",
	"cherry"
})


Window:AddMinimizeButton({
	Button = {
		Image = "rbxassetid://71014873973869",
		BackgroundTransparency = 0
	},
	Corner = {
		CornerRadius = UDim.new(35, 1)
	},
})