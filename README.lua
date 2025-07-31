local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local toggles = {
	DeleteWall = false,
	Noclip = false,
	Highlight = false,
	Speed = false,
	JumpBoost = false,
	AutoPickup = false,
	ESPPlayers = false,
	AntiStomp = false,
	FullBright = false,
}

local highlights = {}
local espHighlights = {}

-- UI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "CustomToolMenu"
gui.ResetOnSpawn = false

local function applyGradient(frame)
	local gradient = Instance.new("UIGradient", frame)
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
	}
	gradient.Rotation = 45
end

-- Имитация загрузки библиотек (иконка с прогрессом)
local loadingFrame = Instance.new("Frame", gui)
loadingFrame.Size = UDim2.new(0, 200, 0, 80)
loadingFrame.Position = UDim2.new(0.5, -100, 0.4, -40)
loadingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
loadingFrame.BorderSizePixel = 0
loadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
local loadingCorner = Instance.new("UICorner", loadingFrame)
loadingCorner.CornerRadius = UDim.new(0, 12)

local loadingLabel = Instance.new("TextLabel", loadingFrame)
loadingLabel.Size = UDim2.new(1, -20, 0, 30)
loadingLabel.Position = UDim2.new(0, 10, 0, 10)
loadingLabel.BackgroundTransparency = 1
loadingLabel.TextColor3 = Color3.new(1,1,1)
loadingLabel.TextScaled = true
loadingLabel.Font = Enum.Font.Gotham

local progressBarBackground = Instance.new("Frame", loadingFrame)
progressBarBackground.Size = UDim2.new(0.9, 0, 0, 20)
progressBarBackground.Position = UDim2.new(0.05, 0, 0, 45)
progressBarBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
progressBarBackground.BorderSizePixel = 0
local progressBarCorner = Instance.new("UICorner", progressBarBackground)
progressBarCorner.CornerRadius = UDim.new(0, 10)

local progressBar = Instance.new("Frame", progressBarBackground)
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
progressBar.BorderSizePixel = 0
local progressCorner = Instance.new("UICorner", progressBar)
progressCorner.CornerRadius = UDim.new(0, 10)

coroutine.wrap(function()
	local progress = 0
	while progress < 100 do
		progress = progress + math.random(2, 6)
		if progress > 100 then progress = 100 end
		loadingLabel.Text = "Установка библиотек... " .. progress .. "%"
		TweenService:Create(progressBar, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {Size = UDim2.new(progress/100, 0, 1, 0)}):Play()
		wait(0.3)
	end
	wait(0.5)
	loadingFrame:Destroy()
	mainFrame.Visible = true
end)()

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 320, 0, 500)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -250)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
applyGradient(mainFrame)

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 16)

local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.Text = "✖"
closeBtn.TextScaled = true
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", closeBtn)

local minimizeBtn = Instance.new("TextButton", mainFrame)
minimizeBtn.Size = UDim2.new(0, 34, 0, 34)
minimizeBtn.Position = UDim2.new(1, -80, 0, 10)
minimizeBtn.Text = "➖"
minimizeBtn.TextScaled = true
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 0)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", minimizeBtn)

local miniButton = Instance.new("TextButton", gui)
miniButton.Size = UDim2.new(0, 120, 0, 44)
miniButton.Position = UDim2.new(0, 20, 1, -80)
miniButton.Text = "Открыть меню"
miniButton.Visible = false
miniButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
miniButton.TextColor3 = Color3.new(1, 1, 1)
applyGradient(miniButton)
Instance.new("UICorner", miniButton)

local function tweenCloseMenu()
	local tween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 320, 0, 0)})
	tween:Play()
	tween.Completed:Wait()
	mainFrame.Visible = false
	miniButton.Visible = true
	mainFrame.Size = UDim2.new(0, 320, 0, 500)
end

local function tweenOpenMenu()
	mainFrame.Visible = true
	miniButton.Visible = false
	mainFrame.Size = UDim2.new(0, 320, 0, 0)
	local tween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 320, 0, 500)})
	tween:Play()
end

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	miniButton.Visible = false
end)

minimizeBtn.MouseButton1Click:Connect(tweenCloseMenu)
miniButton.MouseButton1Click:Connect(tweenOpenMenu)

local currentY = 50

local function createThemeTitle(text)
	local label = Instance.new("TextLabel", mainFrame)
	label.Size = UDim2.new(0.9, 0, 0, 28)
	label.Position = UDim2.new(0.05, 0, 0, currentY)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	currentY = currentY + 32
	return label
end

local function makeButton(name, callback)
	local btn = Instance.new("TextButton", mainFrame)
	btn.Size = UDim2.new(0.9, 0, 0, 40)
	btn.Position = UDim2.new(0.05, 0, 0, currentY)
	btn.Text = name
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.TextColor3 = Color3.new(1, 1, 1)
	applyGradient(btn)
	Instance.new("UICorner", btn)
	btn.MouseButton1Click:Connect(callback)
	currentY = currentY + 50
	return btn
end

-- Основные функции
createThemeTitle("Основные функции")

makeButton("Удалять: Выкл", function()
	toggles.DeleteWall = not toggles.DeleteWall
	if toggles.DeleteWall then
		-- Пример удаления стены с именем "Wall"
		for _, part in pairs(workspace:GetChildren()) do
			if part.Name == "Wall" then
				part:Destroy()
			end
		end
	end
	mainFrame:FindFirstChild("Удалять: Выкл").Text = toggles.DeleteWall and "Удалять: Вкл" or "Удалять: Выкл"
end)

makeButton("Ноклип: Выкл", function()
	toggles.Noclip = not toggles.Noclip
	mainFrame:FindFirstChild("Ноклип: Выкл").Text = toggles.Noclip and "Ноклип: Вкл" or "Ноклип: Выкл"
end)

makeButton("Подсветка: Выкл", function()
	toggles.Highlight = not toggles.Highlight
	if toggles.Highlight then
		for _, part in pairs(workspace:GetChildren()) do
			if part:IsA("BasePart") and part.Name == "SpecialItem" then
				local hl = Instance.new("Highlight")
				hl.Adornee = part
				hl.FillColor = Color3.fromRGB(255, 0, 0)
				hl.FillTransparency = 0.5
				hl.OutlineTransparency = 0
				hl.Parent = part
				table.insert(highlights, hl)
			end
		end
	else
		for _, hl in pairs(highlights) do
			hl:Destroy()
		end
		highlights = {}
	end
	mainFrame:FindFirstChild("Подсветка: Выкл").Text = toggles.Highlight and "Подсветка: Вкл" or "Подсветка: Выкл"
end)

createThemeTitle("Игровые моды")

makeButton("Ускорение: Выкл", function()
	toggles.Speed = not toggles.Speed
	if toggles.Speed then
		character.Humanoid.WalkSpeed = 50
	else
		character.Humanoid.WalkSpeed = 16
	end
	mainFrame:FindFirstChild("Ускорение: Выкл").Text = toggles.Speed and "Ускорение: Вкл" or "Ускорение: Выкл"
end)

makeButton("Прыжок: Выкл", function()
	toggles.JumpBoost = not toggles.JumpBoost
	if toggles.JumpBoost then
		character.Humanoid.JumpPower = 100
	else
		character.Humanoid.JumpPower = 50
	end
	mainFrame:FindFirstChild("Прыжок: Выкл").Text = toggles.JumpBoost and "Прыжок: Вкл" or "Прыжок: Выкл"
end)

makeButton("Авто подбор предметов: Выкл", function()
	toggles.AutoPickup = not toggles.AutoPickup
	mainFrame:FindFirstChild("Авто подбор предметов: Выкл").Text = toggles.AutoPickup and "Авто подбор предметов: Вкл" or "Авто подбор предметов: Выкл"
end)

makeButton("ESP игроков: Выкл", function()
	toggles.ESPPlayers = not toggles.ESPPlayers
	if not toggles.ESPPlayers then
		for _, hl in pairs(espHighlights) do
			hl:Destroy()
		end
		espHighlights = {}
	else
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local highlight = Instance.new("Highlight")
				highlight.Adornee = plr.Character
				highlight.FillColor = Color3.fromRGB(0, 255, 0)
				highlight.FillTransparency = 0.5
				highlight.OutlineTransparency = 0
				highlight.Parent = plr.Character
				table.insert(espHighlights, highlight)
			end
		end
	end
	mainFrame:FindFirstChild("ESP игроков: Выкл").Text = toggles.ESPPlayers and "ESP игроков: Вкл" or "ESP игроков: Выкл"
end)

makeButton("Антистомп: Выкл", function()
	toggles.AntiStomp = not toggles.AntiStomp
	mainFrame:FindFirstChild("Антистомп: Выкл").Text = toggles.AntiStomp and "Антистомп: Вкл" or "Антистомп: Выкл"
end)

makeButton("FullBright: Выкл", function()
	toggles.FullBright = not toggles.FullBright
	if toggles.FullBright then
		Lighting.Ambient = Color3.new(1, 1, 1)
		Lighting.Brightness = 2
		Lighting.TimeOfDay = "14:00:00"
	else
		Lighting.Ambient = Color3.fromRGB(128, 128, 128)
		Lighting.Brightness = 1
		Lighting.TimeOfDay = "12:00:00"
	end
	mainFrame:FindFirstChild("FullBright: Выкл").Text = toggles.FullBright and "FullBright: Вкл" or "FullBright: Выкл"
end)

-- Функции цикла (для работы некоторых функций)

RunService.Stepped:Connect(function()
	if toggles.Noclip then
		for _, part in pairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	else
		for _, part in pairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end

	if toggles.AutoPickup then
		for _, item in pairs(workspace:GetChildren()) do
			if item:IsA("BasePart") and item.Name == "PickupItem" then
				local distance = (item.Position - character.HumanoidRootPart.Position).Magnitude
				if distance < 15 then
					character.HumanoidRootPart.CFrame = item.CFrame
					wait(0.3)
					-- Возможно нужна функция взаимодействия с предметом
				end
			end
		end
	end

	if toggles.AntiStomp then
		-- Простая антистомп: при приземлении быстро подпрыгивает обратно
		if character.Humanoid.FloorMaterial ~= Enum.Material.Air and character.Humanoid:GetState() == Enum.HumanoidStateType.Landed then
			character.Humanoid.Jump = true
		end
	end
end)
