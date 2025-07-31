local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local toggles = {
	DeleteWall = false,
	Noclip = false,
	Highlight = false
}

-- UI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "CustomToolMenu"
gui.ResetOnSpawn = false

-- Градиент
local function applyGradient(frame)
	local gradient = Instance.new("UIGradient", frame)
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
	}
	gradient.Rotation = 45
end

-- Центральное окно
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 300, 0, 260)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -130)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
applyGradient(mainFrame)

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)

-- Перемещение
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

-- Крестик и сворачивание
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "✖"
closeBtn.TextScaled = true
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", closeBtn)

local minimizeBtn = Instance.new("TextButton", mainFrame)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
minimizeBtn.Text = "➖"
minimizeBtn.TextScaled = true
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 0)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", minimizeBtn)

-- Мини кнопка
local miniButton = Instance.new("TextButton", gui)
miniButton.Size = UDim2.new(0, 100, 0, 40)
miniButton.Position = UDim2.new(0, 20, 1, -60)
miniButton.Text = "Меню"
miniButton.Visible = false
miniButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
miniButton.TextColor3 = Color3.new(1, 1, 1)
applyGradient(miniButton)
Instance.new("UICorner", miniButton)

-- Функции меню
local buttonY = 50
local buttons = {}

local function makeButton(name, callback)
	local btn = Instance.new("TextButton", mainFrame)
	btn.Size = UDim2.new(0.9, 0, 0, 40)
	btn.Position = UDim2.new(0.05, 0, 0, buttonY)
	btn.Text = name
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.TextColor3 = Color3.new(1, 1, 1)
	applyGradient(btn)
	Instance.new("UICorner", btn)

	btn.MouseButton1Click:Connect(callback)
	buttonY = buttonY + 50
	table.insert(buttons, btn)
end

makeButton("Удалять: Выкл", function()
	toggles.DeleteWall = not toggles.DeleteWall
	buttons[1].Text = "Удалять: " .. (toggles.DeleteWall and "Вкл" or "Выкл")
end)

makeButton("Noclip: Выкл", function()
	toggles.Noclip = not toggles.Noclip
	buttons[2].Text = "Noclip: " .. (toggles.Noclip and "Вкл" or "Выкл")
end)

local highlights = {}
makeButton("Подсветка: Выкл", function()
	toggles.Highlight = not toggles.Highlight
	buttons[3].Text = "Подсветка: " .. (toggles.Highlight and "Вкл" or "Выкл")
	if toggles.Highlight then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and not obj:FindFirstChild("Highlight") then
				local h = Instance.new("Highlight")
				h.Name = "Highlight"
				h.FillColor = Color3.fromRGB(255, 255, 120)
				h.OutlineColor = Color3.fromRGB(255, 70, 70)
				h.FillTransparency = 1
				h.OutlineTransparency = 1
				h.Adornee = obj
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.Parent = obj
				TweenService:Create(h, TweenInfo.new(0.6), {FillTransparency = 0.2, OutlineTransparency = 0.1}):Play()
				table.insert(highlights, h)
			end
		end
	else
		for _, h in ipairs(highlights) do
			if h and h:IsDescendantOf(game) then
				TweenService:Create(h, TweenInfo.new(0.4), {FillTransparency = 1, OutlineTransparency = 1}):Play()
				task.delay(0.5, function() if h then h:Destroy() end end)
			end
		end
		highlights = {}
	end
end)

-- Noclip система
RunService.Stepped:Connect(function()
	if toggles.Noclip and character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Удаление по нажатию на объект
UserInputService.InputBegan:Connect(function(input)
	if toggles.DeleteWall and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
		local mouse = player:GetMouse()
		local target = mouse.Target
		if target and target:IsA("BasePart") then
			target:Destroy()
		end
	end
end)

-- Закрытие и сворачивание
closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

minimizeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	miniButton.Visible = true
end)

miniButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	miniButton.Visible = false
end)
