local UILib = {}

local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local UserInputService = cloneref and cloneref(game:GetService("UserInputService")) or game:GetService("UserInputService")
local TweenService = cloneref and cloneref(game:GetService("TweenService")) or game:GetService("TweenService")
local Players = cloneref and cloneref(game:GetService("Players")) or game:GetService("Players")
local HttpService = cloneref and cloneref(game:GetService("HttpService")) or game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

local ColorPicker = loadstring(game:HttpGet("https://raw.githubusercontent.com/k0nkx/ColorPicker.module/refs/heads/main/CPG.lua"))()

local customFont = nil
local fontLoaded = false

local function LoadCustomFont()
	local success, err = pcall(function()
		local fontData = {
			name = "PixelifySans",
			url = "https://github.com/k0nkx/UI-Lib-Tuff/raw/refs/heads/main/PixelifySans-VariableFont_wght.ttf"
		}
		
		if not isfile(fontData.name .. ".ttf") then
			local fontContent = game:HttpGet(fontData.url)
			writefile(fontData.name .. ".ttf", fontContent)
		end
		
		local fontConfig = {
			name = fontData.name,
			faces = {{
				name = "Regular",
				weight = 400,
				style = "normal",
				assetId = getcustomasset(fontData.name .. ".ttf")
			}}
		}
		
		writefile(fontData.name .. ".font", HttpService:JSONEncode(fontConfig))
		customFont = Font.new(getcustomasset(fontData.name .. ".font"), Enum.FontWeight.Regular)
		fontLoaded = true
	end)
	
	if not success then
		fontLoaded = false
	end
end

LoadCustomFont()

local function GetThemeFont()
	if fontLoaded and customFont then
		return customFont
	else
		return Enum.Font.Code
	end
end

local Theme = {
	Main = Color3.fromRGB(12, 12, 12),
	Secondary = Color3.fromRGB(20, 20, 20),
	Accent = Color3.fromRGB(255, 180, 190),
	Text = Color3.fromRGB(255, 255, 255),
	Outline = Color3.fromRGB(45, 45, 45),
	Font = GetThemeFont(),
	FontSize = 25
}

local function AddStroke(obj, color)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Outline
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Thickness = 1
	s.Parent = obj
	return s
end

local function ProtectGui(gui)
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		elseif protectgui then
			protectgui(gui)
		end
	end)
end

local function GetKeyName(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		return "LMB"
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		return "RMB"
	elseif input.UserInputType == Enum.UserInputType.Keyboard then
		local key = input.KeyCode.Name
		if key == "Unknown" then return nil end
		return key
	end
	return nil
end

function UILib:CreateWindow(title)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "UILibz"
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ResetOnSpawn = false
	ProtectGui(ScreenGui)
	
	local success, err = pcall(function()
		ScreenGui.Parent = CoreGui
	end)
	
	if not success then
		local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
		if PlayerGui then
			ScreenGui.Parent = PlayerGui
		else
			ScreenGui:Destroy()
			return
		end
	end

	local MainFrame = Instance.new("Frame", ScreenGui)
	MainFrame.Size = UDim2.new(0, 320, 0, 480)
	MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
	MainFrame.BackgroundColor3 = Theme.Main
	MainFrame.BorderSizePixel = 0
	AddStroke(MainFrame)

	local dragging, dragStart, startPos
	local Header = Instance.new("Frame", MainFrame)
	Header.Size = UDim2.new(1, 0, 0, 40)
	Header.BackgroundColor3 = Theme.Main
	Header.BorderSizePixel = 0
	AddStroke(Header)

	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	local TitleLabel = Instance.new("TextLabel", Header)
	TitleLabel.Size = UDim2.new(1, -50, 1, 0)
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = title:upper()
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.FontFace = Theme.Font
	TitleLabel.TextSize = Theme.FontSize
	TitleLabel.TextXAlignment = "Left"

	local CloseBtn = Instance.new("TextButton", Header)
	CloseBtn.Size = UDim2.new(0, 40, 0, 40)
	CloseBtn.Position = UDim2.new(1, -40, 0, 0)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = "X"
	CloseBtn.FontFace = Theme.Font
	CloseBtn.TextSize = 20
	CloseBtn.TextColor3 = Theme.Text
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

	local PageContainer = Instance.new("Frame", MainFrame)
	PageContainer.Size = UDim2.new(1, 0, 1, -100)
	PageContainer.Position = UDim2.new(0, 0, 0, 45)
	PageContainer.BackgroundTransparency = 1

	local TabBtnHolder = Instance.new("Frame", MainFrame)
	TabBtnHolder.Size = UDim2.new(1, -20, 0, 35)
	TabBtnHolder.Position = UDim2.new(0, 10, 1, -45)
	TabBtnHolder.BackgroundTransparency = 1
	local TabLayout = Instance.new("UIListLayout", TabBtnHolder)
	TabLayout.FillDirection = "Horizontal"
	TabLayout.Padding = UDim.new(0, 8)

	local Tabs = {}
	local firstPage = true
	local keybindListeners = {}

	function Tabs:CreateTab(name)
		local Page = Instance.new("ScrollingFrame", PageContainer)
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = firstPage
		Page.ScrollBarThickness = 0
		Page.AutomaticCanvasSize = "Y"
		
		local Pad = Instance.new("UIPadding", Page)
		Pad.PaddingLeft = UDim.new(0, 15); Pad.PaddingRight = UDim.new(0, 15); Pad.PaddingTop = UDim.new(0, 10)

		local PageLayout = Instance.new("UIListLayout", Page)
		PageLayout.Padding = UDim.new(0, 15)
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local TabBtn = Instance.new("TextButton", TabBtnHolder)
		TabBtn.Size = UDim2.new(0.5, -4, 1, 0)
		TabBtn.BackgroundColor3 = Theme.Secondary
		TabBtn.Text = name:upper()
		TabBtn.FontFace = Theme.Font
		TabBtn.TextSize = 14
		TabBtn.TextColor3 = firstPage and Theme.Accent or Theme.Text
		local bStroke = AddStroke(TabBtn, firstPage and Theme.Accent or Theme.Outline)

		TabBtn.MouseButton1Click:Connect(function()
			for _, v in pairs(PageContainer:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
			for _, v in pairs(TabBtnHolder:GetChildren()) do 
				if v:IsA("TextButton") then 
					v.TextColor3 = Theme.Text 
					v:FindFirstChildOfClass("UIStroke").Color = Theme.Outline
				end 
			end
			Page.Visible = true
			TabBtn.TextColor3 = Theme.Accent
			bStroke.Color = Theme.Accent
		end)

		firstPage = false
		local Elements = {}
		local layoutCount = 0
		
		local function stepOrder(obj)
			layoutCount = layoutCount + 1
			obj.LayoutOrder = layoutCount
		end

		function Elements:CreateButtonRow(buttonData)
			local Row = Instance.new("Frame", Page)
			stepOrder(Row)
			Row.Size = UDim2.new(1, 0, 0, 32)
			Row.BackgroundTransparency = 1
			
			local buttonCount = #buttonData
			if buttonCount == 0 then return end
			
			local ButtonLayout = Instance.new("UIListLayout", Row)
			ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
			ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			ButtonLayout.Padding = UDim.new(0, 6)
			
			local buttons = {}
			for i, data in ipairs(buttonData) do
				local b = Instance.new("TextButton", Row)
				b.BackgroundColor3 = Theme.Secondary
				b.Text = data.Name
				b.TextColor3 = Theme.Text
				b.FontFace = Theme.Font
				b.TextSize = 14
				AddStroke(b)
				
				local mode = data.Mode or "Normal"
				local toggled = false
				local originalText = data.Name
				local toggledText = data.ToggledText or originalText .. " ✓"
				
				if mode == "Toggle" then
					b.MouseButton1Click:Connect(function()
						toggled = not toggled
						b.Text = toggled and toggledText or originalText
						b.BackgroundColor3 = toggled and Theme.Accent or Theme.Secondary
						if data.Callback then
							data.Callback(toggled)
						end
					end)
				elseif mode == "Hold" then
					local holding = false
					
					b.MouseButton1Down:Connect(function()
						holding = true
						b.BackgroundColor3 = Theme.Accent
						if data.Callback then
							data.Callback(true)
						end
					end)
					
					UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 and holding then
							holding = false
							b.BackgroundColor3 = Theme.Secondary
							if data.Callback then
								data.Callback(false)
							end
						end
					end)
				else
					b.MouseButton1Click:Connect(data.Callback)
				end
				
				buttons[i] = b
			end
			
			task.wait()
			local rowWidth = Row.AbsoluteSize.X
			local totalPadding = (buttonCount - 1) * 6
			local availableWidth = rowWidth - totalPadding
			local buttonWidth = availableWidth / buttonCount
			
			for _, button in ipairs(buttons) do
				button.Size = UDim2.new(0, buttonWidth, 1, 0)
			end
		end

		function Elements:CreateButtonWithMode(name, mode, callback, toggledText)
			local Row = Instance.new("Frame", Page)
			stepOrder(Row)
			Row.Size = UDim2.new(1, 0, 0, 32)
			Row.BackgroundTransparency = 1
			
			local b = Instance.new("TextButton", Row)
			b.Size = UDim2.new(1, 0, 1, 0)
			b.BackgroundColor3 = Theme.Secondary
			b.Text = name
			b.TextColor3 = Theme.Text
			b.FontFace = Theme.Font
			b.TextSize = 14
			AddStroke(b)
			
			local toggled = false
			local originalText = name
			local toggledTextValue = toggledText or name .. " ✓"
			
			if mode == "Toggle" then
				b.MouseButton1Click:Connect(function()
					toggled = not toggled
					b.Text = toggled and toggledTextValue or originalText
					b.BackgroundColor3 = toggled and Theme.Accent or Theme.Secondary
					if callback then
						callback(toggled)
					end
				end)
			elseif mode == "Hold" then
				local holding = false
				
				b.MouseButton1Down:Connect(function()
					holding = true
					b.BackgroundColor3 = Theme.Accent
					if callback then
						callback(true)
					end
				end)
				
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and holding then
						holding = false
						b.BackgroundColor3 = Theme.Secondary
						if callback then
							callback(false)
						end
					end
				end)
			else
				b.MouseButton1Click:Connect(callback)
			end
			
			return Row
		end

		function Elements:CreateToggleWithKeybind(text, default, keybindCallback, callback)
			local enabled = default or false
			local currentKey = nil
			local listening = false
			
			local TFrame = Instance.new("Frame", Page)
			stepOrder(TFrame)
			TFrame.Size = UDim2.new(1, 0, 0, 32)
			TFrame.BackgroundTransparency = 1
			
			local TogglePart = Instance.new("TextButton", TFrame)
			TogglePart.Size = UDim2.new(0, 18, 0, 18)
			TogglePart.Position = UDim2.new(0, 0, 0.5, -9)
			TogglePart.BackgroundColor3 = enabled and Theme.Accent or Theme.Secondary
			TogglePart.BackgroundTransparency = 0
			TogglePart.Text = ""
			AddStroke(TogglePart)
			
			local Label = Instance.new("TextLabel", TFrame)
			Label.Position = UDim2.new(0, 28, 0, 0)
			Label.Size = UDim2.new(1, -120, 1, 0)
			Label.Text = text
			Label.FontFace = Theme.Font
			Label.TextSize = Theme.FontSize
			Label.TextColor3 = Theme.Text
			Label.TextXAlignment = "Left"
			Label.BackgroundTransparency = 1
			
			local KeybindBtn = Instance.new("TextButton", TFrame)
			KeybindBtn.Size = UDim2.new(0, 70, 1, 0)
			KeybindBtn.Position = UDim2.new(1, -75, 0, 0)
			KeybindBtn.BackgroundColor3 = Theme.Secondary
			KeybindBtn.Text = "[ . . ]"
			KeybindBtn.FontFace = Theme.Font
			KeybindBtn.TextSize = 12
			KeybindBtn.TextColor3 = Theme.Text
			KeybindBtn.TextXAlignment = Enum.TextXAlignment.Center
			AddStroke(KeybindBtn)
			
			local function toggleState()
				enabled = not enabled
				TogglePart.BackgroundColor3 = enabled and Theme.Accent or Theme.Secondary
				callback(enabled)
			end
			
			local function updateKeybindDisplay()
				if currentKey then
					local displayKey = currentKey
					if currentKey == "LMB" then
						displayKey = "LMB"
					elseif currentKey == "RMB" then
						displayKey = "RMB"
					end
					KeybindBtn.Text = "[" .. displayKey .. "]"
					
					local textBounds = KeybindBtn.TextBounds
					local newWidth = math.max(50, math.min(120, textBounds.X + 20))
					KeybindBtn.Size = UDim2.new(0, newWidth, 1, 0)
					KeybindBtn.Position = UDim2.new(1, -(newWidth + 5), 0, 0)
					Label.Size = UDim2.new(1, -(newWidth + 35), 1, 0)
				else
					KeybindBtn.Text = "[ . . ]"
					KeybindBtn.Size = UDim2.new(0, 70, 1, 0)
					KeybindBtn.Position = UDim2.new(1, -75, 0, 0)
					Label.Size = UDim2.new(1, -105, 1, 0)
				end
			end
			
			local function startListening()
				listening = true
				KeybindBtn.BackgroundColor3 = Theme.Accent
				KeybindBtn.Text = "[ ... ]"
			end
			
			local function stopListening()
				listening = false
				KeybindBtn.BackgroundColor3 = Theme.Secondary
				updateKeybindDisplay()
			end
			
			KeybindBtn.MouseButton1Click:Connect(function()
				if listening then
					stopListening()
				else
					startListening()
				end
			end)
			
			local keybindConnection
			keybindConnection = UserInputService.InputBegan:Connect(function(input)
				if listening then
					local key = GetKeyName(input)
					if key then
						if currentKey == key then
							currentKey = nil
							keybindCallback(nil)
						else
							currentKey = key
							keybindCallback(key)
						end
						stopListening()
					end
				elseif currentKey then
					local key = GetKeyName(input)
					if key == currentKey then
						toggleState()
					end
				end
			end)
			
			table.insert(keybindListeners, keybindConnection)
			
			TogglePart.MouseButton1Click:Connect(toggleState)
			
			return TFrame
		end

		function Elements:CreateKeybind(text, callback)
			local currentKey = nil
			local listening = false
			
			local KFrame = Instance.new("Frame", Page)
			stepOrder(KFrame)
			KFrame.Size = UDim2.new(1, 0, 0, 32)
			KFrame.BackgroundTransparency = 1
			
			local Label = Instance.new("TextLabel", KFrame)
			Label.Size = UDim2.new(1, -90, 1, 0)
			Label.Position = UDim2.new(0, 0, 0, 0)
			Label.Text = text
			Label.FontFace = Theme.Font
			Label.TextSize = Theme.FontSize
			Label.TextColor3 = Theme.Text
			Label.TextXAlignment = "Left"
			Label.BackgroundTransparency = 1
			
			local KeybindBtn = Instance.new("TextButton", KFrame)
			KeybindBtn.Size = UDim2.new(0, 70, 1, 0)
			KeybindBtn.Position = UDim2.new(1, -75, 0, 0)
			KeybindBtn.BackgroundColor3 = Theme.Secondary
			KeybindBtn.Text = "[ . . ]"
			KeybindBtn.FontFace = Theme.Font
			KeybindBtn.TextSize = 12
			KeybindBtn.TextColor3 = Theme.Text
			KeybindBtn.TextXAlignment = Enum.TextXAlignment.Center
			AddStroke(KeybindBtn)
			
			local function updateKeybindDisplay()
				if currentKey then
					local displayKey = currentKey
					if currentKey == "LMB" then
						displayKey = "LMB"
					elseif currentKey == "RMB" then
						displayKey = "RMB"
					end
					KeybindBtn.Text = "[" .. displayKey .. "]"
					
					local textBounds = KeybindBtn.TextBounds
					local newWidth = math.max(50, math.min(120, textBounds.X + 20))
					KeybindBtn.Size = UDim2.new(0, newWidth, 1, 0)
					KeybindBtn.Position = UDim2.new(1, -(newWidth + 5), 0, 0)
					Label.Size = UDim2.new(1, -(newWidth + 15), 1, 0)
				else
					KeybindBtn.Text = "[ . . ]"
					KeybindBtn.Size = UDim2.new(0, 70, 1, 0)
					KeybindBtn.Position = UDim2.new(1, -75, 0, 0)
					Label.Size = UDim2.new(1, -90, 1, 0)
				end
			end
			
			local function startListening()
				listening = true
				KeybindBtn.BackgroundColor3 = Theme.Accent
				KeybindBtn.Text = "[ ... ]"
			end
			
			local function stopListening()
				listening = false
				KeybindBtn.BackgroundColor3 = Theme.Secondary
				updateKeybindDisplay()
			end
			
			KeybindBtn.MouseButton1Click:Connect(function()
				if listening then
					stopListening()
				else
					startListening()
				end
			end)
			
			local keybindConnection
			keybindConnection = UserInputService.InputBegan:Connect(function(input)
				if listening then
					local key = GetKeyName(input)
					if key then
						if currentKey == key then
							currentKey = nil
							callback(nil)
						else
							currentKey = key
							callback(key)
						end
						stopListening()
					end
				end
			end)
			
			table.insert(keybindListeners, keybindConnection)
			
			return KFrame
		end

		function Elements:CreateTextbox(placeholder, callback)
			local TBFrame = Instance.new("Frame", Page)
			stepOrder(TBFrame)
			TBFrame.Size = UDim2.new(1, 0, 0, 32)
			TBFrame.BackgroundTransparency = 1
			
			local TextBox = Instance.new("TextBox", TBFrame)
			TextBox.Size = UDim2.new(1, 0, 1, 0)
			TextBox.Position = UDim2.new(0, 0, 0, 0)
			TextBox.BackgroundColor3 = Theme.Secondary
			TextBox.Text = ""
			TextBox.PlaceholderText = placeholder
			TextBox.FontFace = Theme.Font
			TextBox.TextSize = Theme.FontSize
			TextBox.TextColor3 = Theme.Text
			TextBox.TextXAlignment = Enum.TextXAlignment.Center
			TextBox.TextTruncate = Enum.TextTruncate.None
			TextBox.ClearTextOnFocus = false
			AddStroke(TextBox)
			
			TextBox.TextScaled = true
			TextBox.TextWrapped = true
			
			local textCleared = false
			
			TextBox.Focused:Connect(function()
				if not textCleared and TextBox.Text ~= "" then
					TextBox.Text = ""
					textCleared = true
				end
			end)
			
			TextBox.FocusLost:Connect(function(enterPressed)
				if enterPressed and TextBox.Text ~= "" then
					callback(TextBox.Text)
					textCleared = false
				elseif not enterPressed and TextBox.Text == "" then
					textCleared = false
				end
			end)
			
			return TBFrame
		end

		function Elements:CreateToggle(text, default, callback)
			local enabled = default or false
			local TFrame = Instance.new("Frame", Page)
			stepOrder(TFrame)
			TFrame.Size = UDim2.new(1, 0, 0, 18)
			TFrame.BackgroundTransparency = 1
			
			local TogglePart = Instance.new("TextButton", TFrame)
			TogglePart.Size = UDim2.new(0, 18, 0, 18)
			TogglePart.Position = UDim2.new(0, 0, 0.5, -9)
			TogglePart.BackgroundColor3 = enabled and Theme.Accent or Theme.Secondary
			TogglePart.BackgroundTransparency = 0
			TogglePart.Text = ""
			AddStroke(TogglePart)
			
			local Label = Instance.new("TextLabel", TFrame)
			Label.Position = UDim2.new(0, 28, 0, 0)
			Label.Size = UDim2.new(1, -28, 1, 0)
			Label.Text = text
			Label.FontFace = Theme.Font
			Label.TextSize = Theme.FontSize
			Label.TextColor3 = Theme.Text
			Label.TextXAlignment = "Left"
			Label.BackgroundTransparency = 1
			
			TogglePart.MouseButton1Click:Connect(function()
				enabled = not enabled
				TogglePart.BackgroundColor3 = enabled and Theme.Accent or Theme.Secondary
				callback(enabled)
			end)
		end

		function Elements:CreateSlider(text, min, max, default, callback)
			local SFrame = Instance.new("Frame", Page)
			stepOrder(SFrame)
			SFrame.Size = UDim2.new(1, 0, 0, 25)
			SFrame.BackgroundTransparency = 1
			
			local Label = Instance.new("TextLabel", SFrame)
			Label.Size = UDim2.new(1, 0, 0, 15)
			Label.Text = text .. ": " .. default
			Label.FontFace = Theme.Font
			Label.TextSize = Theme.FontSize
			Label.TextColor3 = Theme.Text
			Label.BackgroundTransparency = 1
			Label.TextXAlignment = "Left"
			
			local Bar = Instance.new("TextButton", SFrame)
			Bar.Position = UDim2.new(0, 0, 0, 20)
			Bar.Size = UDim2.new(1, 0, 0, 8)
			Bar.BackgroundColor3 = Theme.Secondary
			Bar.Text = ""
			Bar.AutoButtonColor = false
			AddStroke(Bar)
			
			local Fill = Instance.new("Frame", Bar)
			local defaultRel = math.clamp((default - min) / (max - min), 0, 1)
			Fill.Size = UDim2.new(defaultRel, 0, 1, 0)
			Fill.BackgroundColor3 = Theme.Accent
			Fill.BorderSizePixel = 0
			
			local Grip = Instance.new("TextButton", Bar)
			Grip.Size = UDim2.new(0, 12, 0, 12)
			Grip.Position = UDim2.new(defaultRel, -6, 0.5, -6)
			Grip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Grip.Text = ""
			Grip.AutoButtonColor = false
			AddStroke(Grip, Color3.fromRGB(100, 100, 100))
			
			local gripCorner = Instance.new("UICorner", Grip)
			gripCorner.CornerRadius = UDim.new(1, 0)
			
			local sliding = false
			
			local function updateSlide(skipAnimation)
				local mousePos = UserInputService:GetMouseLocation()
				local barPos = Bar.AbsolutePosition
				local barSize = Bar.AbsoluteSize
				local relPos = math.clamp((mousePos.X - barPos.X) / barSize.X, 0, 1)
				
				local val = math.floor(min + (max - min) * relPos)
				Label.Text = text .. ": " .. val
				
				if skipAnimation then
					Fill.Size = UDim2.new(relPos, 0, 1, 0)
					Grip.Position = UDim2.new(relPos, -6, 0.5, -6)
				else
					local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local fillTween = TweenService:Create(Fill, tweenInfo, {Size = UDim2.new(relPos, 0, 1, 0)})
					local gripTween = TweenService:Create(Grip, tweenInfo, {Position = UDim2.new(relPos, -6, 0.5, -6)})
					fillTween:Play()
					gripTween:Play()
				end
				
				callback(val)
			end
			
			local function onMouseMove()
				if sliding then
					updateSlide(false)
				end
			end
			
			Bar.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					sliding = true
					updateSlide(true)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					sliding = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(i)
				if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
					onMouseMove()
				end
			end)
			
			Grip.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					sliding = true
				end
			end)
			
			return SFrame
		end

		function Elements:CreateColorPicker(text, defaultColor, defaultTransparency, callback)
			local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)
			local currentTransparency = defaultTransparency or 0
			
			local CPFrame = Instance.new("Frame", Page)
			stepOrder(CPFrame)
			CPFrame.Size = UDim2.new(1, 0, 0, 32)
			CPFrame.BackgroundTransparency = 1
			
			local PreviewBtn = Instance.new("TextButton", CPFrame)
			PreviewBtn.Size = UDim2.new(0, 40, 0, 28)
			PreviewBtn.Position = UDim2.new(0, 0, 0.5, -14)
			PreviewBtn.BackgroundColor3 = currentColor
			PreviewBtn.BackgroundTransparency = currentTransparency
			PreviewBtn.Text = ""
			AddStroke(PreviewBtn)
			
			local Label = Instance.new("TextLabel", CPFrame)
			Label.Position = UDim2.new(0, 50, 0, 0)
			Label.Size = UDim2.new(1, -50, 1, 0)
			Label.Text = text
			Label.FontFace = Theme.Font
			Label.TextSize = Theme.FontSize
			Label.TextColor3 = Theme.Text
			Label.TextXAlignment = "Left"
			Label.BackgroundTransparency = 1
			
			PreviewBtn.MouseButton1Click:Connect(function()
				ColorPicker.Show(function(color, transparency)
					currentColor = color
					currentTransparency = transparency
					PreviewBtn.BackgroundColor3 = color
					PreviewBtn.BackgroundTransparency = transparency
					if callback then
						callback(color, transparency)
					end
				end, currentColor, currentTransparency)
			end)
			
			return CPFrame
		end

		return Elements
	end

	return Tabs
end

return UILib
