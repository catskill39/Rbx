local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local character = player.Character or player.CharacterAdded:Wait()

local toggles = {
	DeleteWall = false,
	Noclip = false,
	Highlight = false
}

-- UI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "CustomToolMenu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 160)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local buttons = {}

local function makeButton(text, y, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 20
	btn.MouseButton1Click:Connect(callback)
	table.insert(buttons, btn)
	return btn
end

-- Удаление стены
local function toggleDelete()
	toggles.DeleteWall = not toggles.DeleteWall
	buttons[1].Text = "Удалять стену: " .. (toggles.DeleteWall and "Вкл" or "Выкл")
end

-- Noclip
local function toggleNoclip()
	toggles.Noclip = not toggles.Noclip
	buttons[2].Text = "Noclip: " .. (toggles.Noclip and "Вкл" or "Выкл")
end

-- Подсветка
local function toggleHighlight()
	toggles.Highlight = not toggles.Highlight
	buttons[3].Text = "Подсветка: " .. (toggles.Highlight and "Вкл" or "Выкл")
	if toggles.Highlight then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and not obj:FindFirstChild("Highlight") then
				local h = Instance.new("Highlight", obj)
				h.FillColor = Color3.fromRGB(255, 255, 0)
				h.OutlineColor = Color3.fromRGB(255, 0, 0)
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			end
		end
	else
		for _, obj in pairs(workspace:GetDescendants()) do
			local h = obj:FindFirstChild("Highlight")
			if h then h:Destroy() end
		end
	end
end

makeButton("Удалять стену: Выкл", 0, toggleDelete)
makeButton("Noclip: Выкл", 45, toggleNoclip)
makeButton("Подсветка: Выкл", 90, toggleHighlight)

-- Noclip логика
RunService.Stepped:Connect(function()
	if toggles.Noclip and character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- ClickDetector логика
for _, cd in pairs(workspace:GetDescendants()) do
	if cd:IsA("ClickDetector") then
		cd.MouseClick:Connect(function()
			if toggles.DeleteWall and cd.Parent then
				cd.Parent:Destroy()
			end
		end)
	end
end

workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("ClickDetector") then
		desc.MouseClick:Connect(function()
			if toggles.DeleteWall and desc.Parent then
				desc.Parent:Destroy()
			end
		end)
	end
end)
