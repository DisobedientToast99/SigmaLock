## Basic Script:
```lua
_G._Aim = {
	["LockBind"] = Enum.KeyCode.LeftShift,
	["ESPBind"] = Enum.KeyCode.LeftAlt,
	["AimSwitchBind"] = Enum.KeyCode.RightShift,
	["FFASwitchBind"] = Enum.KeyCode.RightControl,
	["ExitGuiBind"] = Enum.KeyCode.Delete,
}

wait() loadstring(game:HttpGet("https://raw.githubusercontent.com/DisobedientToast99/sigmalock/refs/heads/main/Main.lua"))()
```

---

## Normal Script:
```lua
_G._Aim = {
	["LockBind"] = Enum.KeyCode.LeftShift,
	["ESPBind"] = Enum.KeyCode.LeftAlt,

	["RefreshESPBind"] = Enum.KeyCode.RightAlt,
	["AimSwitchBind"] = Enum.KeyCode.RightShift,
	["FFASwitchBind"] = Enum.KeyCode.RightControl,
	["LockingTypeSwitchBind"] = Enum.KeyCode.Equals,

	["ExitGuiBind"] = Enum.KeyCode.Delete,

	["ESP"] = true,
	["AllowTargetSwitching"] = false,
}

wait() loadstring(game:HttpGet("https://raw.githubusercontent.com/DisobedientToast99/sigmalock/refs/heads/main/Main.lua"))()
```

---

## Advanced Script:
```lua
_G._Aim = {
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
	
	["LockMaxDistance"] = 500,
	
	["AimAt"] = "Head",
	["AimAtOptions"] = {"Head", "HumanoidRootPart"},

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
}

wait() loadstring(game:HttpGet("https://raw.githubusercontent.com/DisobedientToast99/sigmalock/refs/heads/main/Main.lua"))()
```
