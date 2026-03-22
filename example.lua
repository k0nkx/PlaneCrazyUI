local UILib = loadstring(game:HttpGet("https://github.com/k0nkx/PlaneCrazyUI/raw/refs/heads/main/source.lua"))()

local Window = UILib:CreateWindow("My Script")
local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")

MainTab:CreateToggle("Auto Farm", false, function(state)
	print("Auto Farm:", state)
end)

MainTab:CreateSlider("Speed", 0, 100, 50, function(val)
	print("Speed:", val)
end)

MainTab:CreateButtonRow({
	{Name = "Click Me", Callback = function() print("Clicked") end},
	{Name = "Reset", Callback = function() print("Reset") end}
})

MainTab:CreateTextbox("Enter value...", function(text)
	print("Input:", text)
end)

SettingsTab:CreateToggleWithKeybind("Toggle Keybind", false, function(key)
	print("Keybind set to:", key)
end, function(state)
	print("Toggle state:", state)
end)

SettingsTab:CreateKeybind("Fire Key", function(key)
	print("Keybind:", key)
end)

SettingsTab:CreateColorPicker("Pick Color", Color3.fromRGB(255, 100, 100), 0, function(color, transparency)
	print("Color selected:", color)
end)
