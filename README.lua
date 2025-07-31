local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Флаги чит-функций
local toggles = {
	DeleteWall = false, Noclip = false, Highlight = false,
	Speed = false, JumpBoost = false, AutoPickup = false,
	ESPPlayers = false, AntiStomp = false, FullBright = false,
}

local highlights = {}
local espHighlights = {}

-- Создаём ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "CustomToolMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Вспомогательная функция для градиента
local function applyGradient(frame)
	local gradient = Instance.new("UIGradient", frame)
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
	}
	gradient.Rotation = 45
end

-- Главное окно меню (создаём ДО функций, которые его используют)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 520)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -260)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = gui

applyGradient(mainFrame)
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 16)

-- Функции создания GUI-элементов
local function createThemeTitle(text, posY)
	local title = Instance.new("TextLabel", mainFrame)
	title.Size = UDim2.new(0.9, 0, 0, 30)
	title.Position = UDim2.new(0.05, 0, 0, posY)
	title.BackgroundTransparency = 1
	title.Text = text
	title.Font = Enum.Font.GothamBold
	title.TextColor3 = Color3.fromRGB(180, 180, 180)
	title.TextScaled = true
	title.TextXAlignment = Enum.TextXAlignment.Left
	return title
end

local posY = 10
local function createThemeHeader(titleText)
	local header = Instance.new("TextLabel", mainFrame)
	header.Size = UDim2.new(0.9, 0, 0, 30)
	header.Position = UDim2.new(0.05, 0, 0, posY)
	header.BackgroundTransparency = 1
	header.Text = titleText
	header.Font = Enum.Font.GothamBold
	header.TextColor3 = Color3.fromRGB(200, 200, 200)
	header.TextScaled = true
	header.TextXAlignment = Enum.TextXAlignment.Left
	posY = posY + 40
	return header
end

local buttonY = 50
local buttons = {}
local function makeButton(name, callback)
	local btn = Instance.new("TextButton", mainFrame)
	btn.Size = UDim2.new(0.9, 0, 0, 40)
	btn.Position = UDim2.new(0.05, 0, 0, buttonY)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.Text = name
	btn.AutoButtonColor = false
	applyGradient(btn)
	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 8)

	btn.MouseButton1Click:Connect(callback)
	buttonY = buttonY + 50
	buttons[name] = btn
	return btn
end

local function updateButton(name, state)
	if buttons[name] then
		buttons[name].Text = name:match("^[^:]+") .. ": " .. (state and "Вкл" or "Выкл")
	end
end

-- Кнопки закрытия и сворачивания
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.Text = "✖"
closeBtn.TextScaled = true
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)

local minimizeBtn = Instance.new("TextButton", mainFrame)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -80, 0, 10)
minimizeBtn.Text = "➖"
minimizeBtn.TextScaled = true
minimizeBtn.BackgroundColor3 = Color3.fromRGB(150,150,0)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.AutoButtonColor = false
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0,8)

-- Мини-кнопка для разворачивания
local miniButton = Instance.new("TextButton", gui)
miniButton.Size = UDim2.new(0, 100, 0, 40)
miniButton.Position = UDim2.new(0, 20, 1, -60)
miniButton.Text = "Меню"
miniButton.Visible = false
miniButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
miniButton.TextColor3 = Color3.new(1,1,1)
applyGradient(miniButton)
Instance.new("UICorner", miniButton).CornerRadius = UDim.new(0,12)

local function toggleMinimize()
	if mainFrame.Visible then
		TweenService:Create(mainFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
		for _, obj in pairs(mainFrame:GetChildren()) do
			if obj:IsA("TextButton") or obj:IsA("TextLabel") then
				TweenService:Create(obj, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
			end
		end
		task.delay(0.4, function()
			mainFrame.Visible = false
			for _, obj in pairs(mainFrame:GetChildren()) do
				if obj:IsA("TextButton") or obj:IsA("TextLabel") then
					obj.TextTransparency = 0
				end
			end
			miniButton.Visible = true
		end)
	else
		miniButton.Visible = false
		mainFrame.Visible = true
		mainFrame.BackgroundTransparency = 1
		for _, obj in pairs(mainFrame:GetChildren()) do
			if obj:IsA("TextButton") or obj:IsA("TextLabel") then
				obj.TextTransparency = 1
			end
		end
		TweenService:Create(mainFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0.2}):Play()
		for _, obj in pairs(mainFrame:GetChildren()) do
			if obj:IsA("TextButton") or obj:IsA("TextLabel") then
				TweenService:Create(obj, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
			end
		end
	end
end

closeBtn.MouseButton1Click:Connect(function()
	TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	for _, obj in pairs(mainFrame:GetChildren()) do
		if obj:IsA("TextButton") or obj:IsA("TextLabel") then
			TweenService:Create(obj, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		end
	end
	task.delay(0.3, function()
		mainFrame.Visible = false
		miniButton.Visible = false
	end)
end)
minimizeBtn.MouseButton1Click:Connect(toggleMinimize)
miniButton.MouseButton1Click:Connect(toggleMinimize)

-- Перемещение (для сенсорных)
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
		                               startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Загрузка библиотек с прогресс-баром
local loadingFrame = Instance.new("Frame", gui)
loadingFrame.Size = UDim2.new(0, 220, 0, 80)
loadingFrame.Position = UDim2.new(0.5, -110, 0.4, -40)
loadingFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
loadingFrame.BorderSizePixel = 0
loadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
Instance.new("UICorner", loadingFrame).CornerRadius = UDim.new(0,16)

local loadingLabel = Instance.new("TextLabel", loadingFrame)
loadingLabel.Size = UDim2.new(1, -20, 0, 30)
loadingLabel.Position = UDim2.new(0, 10, 0, 10)
loadingLabel.BackgroundTransparency = 1
loadingLabel.TextColor3 = Color3.new(1,1,1)
loadingLabel.TextScaled = true
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.Text = "Установка библиотек... 0%"

local progressBarBackground = Instance.new("Frame", loadingFrame)
progressBarBackground.Size = UDim2.new(0.9, 0, 0, 20)
progressBarBackground.Position = UDim2.new(0.05, 0, 0, 50)
progressBarBackground.BackgroundColor3 = Color3.fromRGB(40,40,40)
progressBarBackground.BorderSizePixel = 0
Instance.new("UICorner", progressBarBackground).CornerRadius = UDim.new(0,12)

local progressBar = Instance.new("Frame", progressBarBackground)
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(0,170,255)
progressBar.BorderSizePixel = 0
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(0,12)

coroutine.wrap(function()
	local progress = 0
	while progress < 100 do
		progress = progress + math.random(4, 9)
		if progress > 100 then progress = 100 end
		loadingLabel.Text = "Установка библиотек... " .. progress .. "%"
		TweenService:Create(progressBar, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			Size = UDim2.new(progress/100, 0, 1, 0)
		}):Play()
		wait(0.25)
	end
	wait(0.5)
	loadingFrame:Destroy()
	mainFrame.Visible = true
end)()

-- Реализация чит-функций (DeleteWall, Noclip, Highlight, Speed и т.д.)
local function toggleDeleteWall()
	toggles.DeleteWall = not toggles.DeleteWall
	updateButton("DeleteWall", toggles.DeleteWall)
	if toggles.DeleteWall then
		spawn(function()
			while toggles.DeleteWall do
				for _, part in pairs(workspace:GetChildren()) do
					if part:IsA("BasePart") and part.Name == "Wall" then
						if (part.Position - character.HumanoidRootPart.Position).Magnitude < 10 then
							part:Destroy()
						end
					end
				end
				wait(1)
			end
		end)
	end
end

local function toggleNoclip()
	toggles.Noclip = not toggles.Noclip
	updateButton("Noclip", toggles.Noclip)
	if toggles.Noclip then
		RunService.Stepped:Connect(function()
			if toggles.Noclip and character and character:FindFirstChild("HumanoidRootPart") then
				for _, part in pairs(character:GetChildren()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
	else
		for _, part in pairs(character:GetChildren()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end
end

local function toggleHighlight()
	toggles.Highlight = not toggles.Highlight
	updateButton("Highlight", toggles.Highlight)
	if toggles.Highlight then
		spawn(function()
			while toggles.Highlight do
				for _, h in pairs(highlights) do h:Destroy() end
				highlights = {}
				for _, obj in pairs(workspace:GetChildren()) do
					if obj:IsA("BasePart") and obj.Name == "Pickup" and
					   (obj.Position - character.HumanoidRootPart.Position).Magnitude < 20 then
						local hl = Instance.new("Highlight")
						hl.Adornee = obj
						hl.FillColor = Color3.fromRGB(0,170,255)
						hl.OutlineColor = Color3.fromRGB(255,255,255)
						hl.Parent = gui
						table.insert(highlights, hl)
					end
				end
				wait(2)
			end
			for _, h in pairs(highlights) do h:Destroy() end
			highlights = {}
		end)
	else
		for _, h in pairs(highlights) do h:Destroy() end
		highlights = {}
	end
end

local function toggleSpeed()
	toggles.Speed = not toggles.Speed
	updateButton("Speed", toggles.Speed)
	if toggles.Speed then
		character.Humanoid.WalkSpeed = 50
	else
		character.Humanoid.WalkSpeed = 16
	end
end

local function toggleJumpBoost()
	toggles.JumpBoost = not toggles.JumpBoost
	updateButton("JumpBoost", toggles.JumpBoost)
	if toggles.JumpBoost then
		character.Humanoid.JumpPower = 100
	else
		character.Humanoid.JumpPower = 50
	end
end

local function toggleAutoPickup()
	toggles.AutoPickup = not toggles.AutoPickup
	updateButton("AutoPickup", toggles.AutoPickup)
	if toggles.AutoPickup then
		spawn(function()
			while toggles.AutoPickup do
				for _, obj in pairs(workspace:GetChildren()) do
					if obj:IsA("BasePart") and obj.Name == "Pickup" and
					   (obj.Position - character.HumanoidRootPart.Position).Magnitude < 5 then
						obj.CFrame = character.HumanoidRootPart.CFrame
					end
				end
				wait(1)
			end
		end)
	end
end

local function toggleESPPlayers()
	toggles.ESPPlayers = not toggles.ESPPlayers
	updateButton("ESPPlayers", toggles.ESPPlayers)
	if toggles.ESPPlayers then
		spawn(function()
			while toggles.ESPPlayers do
				for plr, hl in pairs(espHighlights) do
					if not plr.Parent or plr == player then
						hl:Destroy()
						espHighlights[plr] = nil
					end
				end
				for _, plr in pairs(Players:GetPlayers()) do
					if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
						if not espHighlights[plr] then
							local hl = Instance.new("Highlight")
							hl.Adornee = plr.Character
							hl.FillColor = Color3.fromRGB(255,0,0)
							hl.OutlineColor = Color3.fromRGB(255,255,255)
							hl.Parent = gui
							espHighlights[plr] = hl
						end
					end
				end
				wait(2)
			end
			for _, hl in pairs(espHighlights) do hl:Destroy() end
			espHighlights = {}
		end)
	else
		for _, hl in pairs(espHighlights) do hl:Destroy() end
		espHighlights = {}
	end
end

local function toggleAntiStomp()
	toggles.AntiStomp = not toggles.AntiStomp
	updateButton("AntiStomp", toggles.AntiStomp)
	if toggles.AntiStomp then
		character.Humanoid.StateChanged:Connect(function(_, new)
			if toggles.AntiStomp and new == Enum.HumanoidStateType.Freefall then
				character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
			end
		end)
	end
end

local function toggleFullBright()
	toggles.FullBright = not toggles.FullBright
	updateButton("FullBright", toggles.FullBright)
	if toggles.FullBright then
		Lighting.ClockTime = 14
		Lighting.Brightness = 3
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
	else
		Lighting.ClockTime = 14
		Lighting.Brightness = 1
		Lighting.FogEnd = 1000
		Lighting.GlobalShadows = true
	end
end

-- Добавляем кнопки в меню
createThemeHeader("Основные функции")
makeButton("DeleteWall", toggleDeleteWall)
makeButton("Noclip", toggleNoclip)
makeButton("Highlight", toggleHighlight)
makeButton("Speed", toggleSpeed)
makeButton("JumpBoost", toggleJumpBoost)

createThemeHeader("Авто")
makeButton("AutoPickup", toggleAutoPickup)

createThemeHeader("Защита и ESP")
makeButton("ESPPlayers", toggleESPPlayers)
makeButton("AntiStomp", toggleAntiStomp)
makeButton("FullBright", toggleFullBright)
