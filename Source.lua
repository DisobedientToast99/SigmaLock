--local gui = script.Parent:FindFirstChild("Lock_Gui").Main or game:GetObjects('rbxassetid://18622836850')[1].Main
--[[  IGNORE: USED FOR DEBUGGING  ]]

--------------------------------------------------------------------------------------

local plrs = game:FindFirstChildOfClass("Players")
local cgui = game:FindFirstChildOfClass("CoreGui")
local runs = game:FindFirstChildOfClass("RunService")
local ts = game:FindFirstChildOfClass("TweenService")
local uis = game:FindFirstChildOfClass("UserInputService")

--------------------------------------------------------------------------------------

local gui = game:GetObjects('rbxassetid://18622836850')[1].Main
gui.Parent.Parent = plrs.LocalPlayer.PlayerGui

--------------------------------------------------------------------------------------

local defaultSettings = {
	["LockBind"] = Enum.KeyCode.LeftShift,
	["ESPBind"] = Enum.KeyCode.LeftAlt,
	["RefreshESPBind"] = Enum.KeyCode.RightAlt,
	["AimSwitchBind"] = Enum.KeyCode.RightShift,
	["FFASwitchBind"] = Enum.KeyCode.RightControl,
	["LockingTypeSwitchBind"] = Enum.KeyCode.Equals,
	["ExitGuiBind"] = Enum.KeyCode.Delete,

	["FreeForAll"] = false,
	["TeamsToSkip"] = {},

	["AllowTargetSwitching"] = false,
	["LockingType"] = "Mouse",
	["LockingOptions"] = {"Mouse", "Character"},

	["LockMaxDistance"] = 10,

	["AimAt"] = "Head",
	["AimAtOptions"] = {"Head", "HumanoidRootPart", "Random"}, -- "Random"

	["ESP"] = true,
	["ESPRefreshInterval"] = 10,

	["ESPDefaultColor"] = Color3.fromRGB(255, 0, 0),
	["ESPDefaultColor_NPC"] = Color3.fromRGB(0, 255, 0),
	["ESPFillTransparency"] = 0.6,
	["ESPOutlineTransparency"] = 0.3,

	["LockEnabledColor"] = Color3.fromRGB(10, 100, 10),
	["LockDisabledColor"] = Color3.fromRGB(100, 10, 10),

	["GuiTransparency"] = 0.4, 
	["TweenInfo"] = TweenInfo.new(0.1, Enum.EasingStyle.Exponential),

	["_currentAimAtPart"] = 0,
	["_currentLockingType"] = 0,
	["_currentLockedCharacter"] = false,
	["_currentLockingAimPartState"] = false,
	
	["_DEBUG"] = false
}

--------------------------------------------------------------------------------------

local data = _G._Aim or {}

for gIndex, gValue in pairs(defaultSettings) do
	if not data[gIndex] then
		data[gIndex] = gValue
	else
		if typeof(data[gIndex]) ~= typeof(gValue) then
			data[gIndex] = gValue
		end
	end
end

--------------------------------------------------------------------------------------

local function ExitSigmaLock()
	print("exit")
	RefreshESP(true)
	script:Destroy()
	gui:FindFirstAncestorOfClass("ScreenGui"):Destroy()
end

--------------------------------------------------------------------------------------

if _G._SigmaLockRan then
	_G._SigmaLockRan()
	_G._SigmaLockRan = ExitSigmaLock
else
	_G._SigmaLockRan = ExitSigmaLock
end

--------------------------------------------------------------------------------------

local player = plrs.LocalPlayer
local mouse = player:GetMouse()
local curCam = workspace.CurrentCamera

--------------------------------------------------------------------------------------

local currentPlayersESP = {}
local currentESPConnections = {}
local currentESP = {}

local lastPlayerESPVisibilityChange = {}
local lastESPToggle = nil

local defaultSizes = {}
local disabledText = `Hold "{data.LockBind.Name}" to Enable`

--------------------------------------------------------------------------------------

local function GetDistanceMagnitude(p1, p2)
	return (p1 - p2).Magnitude
end

local function CanLockCharacter(char)
	local plr = plrs:GetPlayerFromCharacter(char)

	if plr then
		if plr ~= player then
			if plr.Team ~= player.Team then
				return true
			else
				return data.FreeForAll
			end
		end
	else
		if data._DEBUG then
			return true
		end
	end

	return false
end

local function GetRigs()
	local rigs = {}
	for _, rig in pairs(workspace:GetDescendants()) do
		if rig:IsA("Model") and rig:FindFirstChildOfClass("Humanoid") and not plrs:GetPlayerFromCharacter(rig) then
			table.insert(rigs, rig)
		end
	end
	return (data._DEBUG and rigs or {})
end

local function ClearInstanceOfClass(i,c,d)
	for _, o:Instance in pairs(i:GetChildren()) do
		if o:IsA(c) then
			if d and o:IsDescendantOf(d) then
				continue
			end

			o:Destroy()
		end
	end
end

local function ToggleLabel(label, enabled)
	task.spawn(function()
		if enabled then
			if not defaultSizes[label] then
				defaultSizes[label] = label.UITextSizeConstraint.MaxTextSize
			end
			label.Visible = true
		else
			label.Visible = false
		end
	end)
end

local function GetAimPart(aimPart)
	if aimPart == "Head" then
		return "Head"
	elseif aimPart == "HumanoidRootPart" then
		return "HumanoidRootPart"
	elseif aimPart == "Random" then
		return data.AimAtOptions[math.random(1,#data.AimAtOptions-1)]
	end
end

local function CycleAimPart()
	local function add()
		if data._currentAimAtPart+1 > #data.AimAtOptions then 
			data._currentAimAtPart = 1 
		else
			data._currentAimAtPart+=1
		end
	end

	add()

	if not player.Character:FindFirstChild(GetAimPart(data.AimAtOptions[data._currentAimAtPart])) then 
		repeat add() until player.Character:FindFirstChild(GetAimPart(data.AimAtOptions[data._currentAimAtPart]))
	end

	data.AimAt = data.AimAtOptions[data._currentAimAtPart]
end

local function CycleLockingType()
	if data._currentLockingType+1 > #data.LockingOptions then 
		data._currentLockingType = 1 
	else
		data._currentLockingType+=1
	end

	data.LockingType = data.LockingOptions[data._currentLockingType]
end

local function CharacterIsVisible(char)
	local c = char:FindFirstChild(GetAimPart(data.AimAt))

	local _, visible = curCam:WorldToScreenPoint(c.CFrame.Position)

	return visible
end

--------------------------------------------------------------------------------------

local function GetCharacterToLock()
	local visibleCharacters = {}

	for _, plr in pairs(plrs:GetPlayers()) do
		if CanLockCharacter(plr.Character) then
			local dis = nil

			if data.LockingType == data.LockingOptions[1] then
				dis = GetDistanceMagnitude(plr.Character.HumanoidRootPart.Position, mouse.Hit.Position)
			else
				dis = GetDistanceMagnitude(plr.Character.HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position)
			end

			if CharacterIsVisible(plr.Character) then
				table.insert(visibleCharacters, {char = plr.Character, dis = dis,})
			end
		end
	end

	if data._DEBUG then
		for _, rig in pairs(GetRigs()) do
			if CanLockCharacter(rig) then
				local dis = nil

				if data.LockingType == data.LockingOptions[1] then
					dis = GetDistanceMagnitude(rig.HumanoidRootPart.Position, mouse.Hit.Position)
				else
					dis = GetDistanceMagnitude(rig.HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position)
				end

				if CharacterIsVisible(rig) then
					table.insert(visibleCharacters, {char = rig, dis = dis,})
				end
			end
		end
	end

	table.sort(visibleCharacters, function(a, b) return math.floor(a.dis + 0.5) < math.floor(b.dis + 0.5) end)

	--print(string.rep("-",10))
	--print(data.LockingType)
	--print(visibleCharacters)

	for _, entry in pairs(visibleCharacters) do
		return entry.char, entry.dis
	end
end

--------------------------------------------------------------------------------------

local function ToggleESP(enabled)
	if lastESPToggle ~= enabled then
		lastESPToggle = enabled
		for _, folder in pairs(currentESP) do
			folder.ESP_Highlight.Enabled = enabled
			folder.ESP_Billboard.Enabled = enabled
		end
	end
end

local function RemoveESP(char)
	if currentESP[char] then
		currentESP[char]:Destroy()
		currentESP[char] = nil
	end
end

local function AddESP(char)
	if CanLockCharacter(char) then
		RemoveESP(char)

		local plr = plrs:GetPlayerFromCharacter(char)
		local espFolder = gui.ESP:Clone()

		espFolder.Name = char.Name
		espFolder.Parent = gui.CurrentESP
		espFolder.ESP_Billboard.Title.Text = char.Name

		currentESP[char] = espFolder

		if plr and plr.Team then
			espFolder.ESP_Highlight.FillColor = plr.TeamColor.Color
			espFolder.ESP_Highlight.OutlineColor = plr.TeamColor.Color
			espFolder.ESP_Billboard.Title.TextColor3 = plr.TeamColor.Color
		else
			if plr then
				espFolder.ESP_Highlight.FillColor = data.ESPDefaultColor
				espFolder.ESP_Highlight.OutlineColor = data.ESPDefaultColor
				espFolder.ESP_Billboard.Title.TextColor3 = data.ESPDefaultColor
			else
				espFolder.ESP_Highlight.FillColor = data.ESPDefaultColor_NPC
				espFolder.ESP_Highlight.OutlineColor = data.ESPDefaultColor_NPC
				espFolder.ESP_Billboard.Title.TextColor3 = data.ESPDefaultColor_NPC
			end
		end


		espFolder.ESP_Highlight.FillTransparency = data.ESPFillTransparency
		espFolder.ESP_Highlight.OutlineTransparency = data.ESPOutlineTransparency

		espFolder.ESP_Billboard.Enabled = data.ESP
		espFolder.ESP_Highlight.Enabled = data.ESP
		espFolder.ESP_Billboard.Adornee = char
		espFolder.ESP_Highlight.Adornee = char
	end
end

local function LoadESP()
	local function loadPlr(plr)
		if not currentPlayersESP[plr.Character] then
			local char = plr.Character
			AddESP(char)
			currentESPConnections[#currentESPConnections+1] = plr.CharacterAdded:Connect(function(c)
				char = c
				AddESP(char)
			end)
			currentESPConnections[#currentESPConnections+1] = plr:GetPropertyChangedSignal("Team"):Connect(function()
				AddESP(char)
			end)
			currentPlayersESP[char] = true
		end
	end
	local function deloadPlr(plr)
		RemoveESP(plr.Character)
		currentPlayersESP[plr.Character] = nil
	end

	for _, rig in pairs(GetRigs()) do
		if not currentPlayersESP[rig] then
			AddESP(rig)
			currentPlayersESP[rig] = true
		end
	end

	for _, plr in pairs(plrs:GetPlayers()) do
		loadPlr(plr)
	end

	currentESPConnections[#currentESPConnections+1] = plrs.PlayerAdded:Connect(function(plr)
		loadPlr(plr)
	end)

	currentESPConnections[#currentESPConnections+1] = plrs.PlayerRemoving:Connect(function(plr)
		deloadPlr(plr)
	end)
end

local function RefreshESP(del: boolean)
	if player.PlayerGui:FindFirstChildOfClass("Highlight") then
		ClearInstanceOfClass(player.PlayerGui,"Highlight",gui)
	end

	for char, _ in pairs(currentESP) do
		RemoveESP(char)
	end
	for _, c in pairs(currentESPConnections) do
		c:Disconnect()
	end

	currentESP = {}
	currentESPConnections = {}
	currentPlayersESP = {}

	if not del then
		LoadESP()
	end
end

--------------------------------------------------------------------------------------

local function EnableLock(target, aim)
	curCam.CFrame = CFrame.lookAt(curCam.CFrame.Position, aim.CFrame.Position)
	data._currentLockedCharacter = target

	ts:Create(gui.Main, data.TweenInfo, {BackgroundColor3 = data.LockEnabledColor}):Play()
	gui.Main.Target.Text = target.Name
	ToggleLabel(gui.Main.Target, true)
	ToggleLabel(gui.Main.DisabledWarning, false)
end

local function DisableLock()
	data._currentLockedCharacter = false
	data._currentLockingAimPartState = false

	ts:Create(gui.Main, data.TweenInfo, {BackgroundColor3 = data.LockDisabledColor}):Play()
	ToggleLabel(gui.Main.Target, false)
	ToggleLabel(gui.Main.DisabledWarning, true)
end

local function CheckLock()
	local target, distance = GetCharacterToLock()
	if target then
		if not data._currentLockingAimPartState then
			data._currentLockingAimPartState = GetAimPart(data.AimAt)
		end
		
		EnableLock((data.AllowTargetSwitching and data._currentLockedCharacter) or target, target:FindFirstChild(data._currentLockingAimPartState))
	else
		DisableLock()
	end
end

--------------------------------------------------------------------------------------

local function RunLock()
	if uis:IsKeyDown(data.LockBind) then
		CheckLock()
	else
		DisableLock()
	end
end

local function RunGui()
	gui.Main.DisabledWarning.Text = disabledText
	gui.Info.AimAt.Text = "AimAt: "..(data.AimAt == "HumanoidRootPart" and "Torso" or data.AimAt)
	gui.Info.ESP.Text = "ESP: "..(data.ESP and "On" or "Off")
	gui.Info.FreeForAll.Text = "FFA: "..(data.FreeForAll and "On" or "Off")
	gui.Info.LockingType.Text = "Type: "..data.LockingType

	for _, frame in pairs(gui:GetChildren()) do
		if frame:IsA("Frame") and frame.BackgroundTransparency ~= data.GuiTransparency then
			ts:Create(frame, data.TweenInfo, {BackgroundTransparency = data.GuiTransparency}):Play()
		end
	end
end

local function RunTriggerBot()
	if data.TriggerBot and mouse.Target and game.Players:GetPlayerFromCharacter(mouse.Target.Parent) and CanLockCharacter(mouse.Target.Parent) then

	end
end

--------------------------------------------------------------------------------------

CycleAimPart()
CycleLockingType()
RefreshESP()

--------------------------------------------------------------------------------------

uis.InputBegan:connect(function(input, gm)
	if not gm then
		if input.KeyCode == data.AimSwitchBind then
			CycleAimPart()

		elseif input.KeyCode == data.ESPBind then
			data.ESP = not data.ESP

		elseif input.KeyCode == data.FFASwitchBind then
			data.FreeForAll = not data.FreeForAll

		elseif input.KeyCode == data.RefreshESPBind then
			RefreshESP()

		elseif input.KeyCode == data.TriggerBotSwitchBind then
			data.TriggerBot = not data.TriggerBot

		elseif input.KeyCode == data.LockingTypeSwitchBind then
			CycleLockingType()

		elseif input.KeyCode == data.ExitGuiBind then
			ExitSigmaLock()

		end
	end
end)

task.spawn(function()
	while wait(data.ESPRefreshInterval) do
		RefreshESP()
	end
end)

runs.Heartbeat:connect(function()
	RunLock()
	RunGui()
	ToggleESP(data.ESP)
	RunTriggerBot()
end)
