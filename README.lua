-- // ROBLOX Custom Script with Enhanced UI & Effects
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Toggle states
local toggles = {
	DeleteWall = false,
	Noclip = false,
	Highlight = false
}

-- Create GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "CustomToolMenu"
gui.ResetOnSpawn = false

-- Загрузка (анимация)
local loadingFrame = Instance.new("Frame", gui)
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local loadingLabel = Instance.new("TextLabel", loadingFrame)
loadingLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
loadingLabel.Position = UDim2.new(0.25, 0, 0.45, 0)
loadingLabel.Text = "Загрузка..."
loadingLabel.TextScaled = true
loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingLabel.BackgroundTransparency = 1

-- Плавное исчезновение загрузки
task.wait(1.2)
TweenService:Create(loadingFrame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
TweenService:Create(loadingLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
task.wait(1)
loadingFrame:Destroy()

-- Главное меню
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 180)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0, 0)
frame.BackgroundTransparency = 1

-- Анимация появления меню
TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()

-- Buttons
local buttons = {}
local function makeButton(text, y, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 20
	btn.Font = Enum.Font.GothamSemibold
	btn.AutoButtonColor = true
	btn.BorderSizePixel = 0

	local uiCorner = Instance.new("UICorner", btn)
	uiCorner.CornerRadius = UDim.new(0, 8)

	btn.MouseButton1Click:Connect(callback)
	table.insert(buttons, btn)
	return btn
end

-- Удаление объектов
local function toggleDelete()
	toggles.DeleteWall = not toggles.DeleteWall
	buttons[1].Text = "Удалять: " .. (toggles.DeleteWall and "Вкл" or "Выкл")
end

-- Noclip
local function toggleNoclip()
	toggles.Noclip = not toggles.Noclip
	buttons[2].Text = "Noclip: " .. (toggles.Noclip and "Вкл" or "Выкл")
end

-- Highlight
local highlights = {}
local function toggleHighlight()
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

				TweenService:Create(h, TweenInfo.new(0.6), {FillTransparency = 0.25, OutlineTransparency = 0}):Play()
				table.insert(highlights, h)
			end
		end
	else
		for _, h in ipairs(highlights) do
			if h and h:IsDescendantOf(game) then
				TweenService:Create(h, TweenInfo.new(0.5), {FillTransparency = 1, OutlineTransparency = 1}):Play()
				task.delay(0.5, function() if h then h:Destroy() end end)
			end
		end
		highlights = {}
	end
end

makeButton("Удалять: Выкл", 0, toggleDelete)
makeButton("Noclip: Выкл", 45, toggleNoclip)
makeButton("Подсветка: Выкл", 90, toggleHighlight)

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

-- Удаление при клике на любой BasePart
UserInputService.InputBegan:Connect(function(input)
	if toggles.DeleteWall and input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mouse = player:GetMouse()
		local target = mouse.Target
		if target and target:IsA("BasePart") then
			target:Destroy()
		end
	end
end)
