-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Pet List for Randomizer
local petNames = {
    "Mutant Dog", "Gamma Bunny", "Electro Bear",
    "Toxic Cat", "Void Dragon", "Crystal Fox",
    "Fire Piggy", "Radioactive Corgi", "Plasma Panda"
}

-- Mutation Check Simulation
local mutatablePets = {"Dog", "Cat", "Dragon"} -- Simulated base pet names

-- Create GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "PetScriptUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 300)
frame.Position = UDim2.new(0.5, -150, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local uiListLayout = Instance.new("UIListLayout", frame)
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.FillDirection = Enum.FillDirection.Vertical
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createButton(text)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 40)
	button.Position = UDim2.new(0, 10, 0, 0)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 20
	button.Text = text
	button.Parent = frame
	return button
end

local resultLabel = Instance.new("TextLabel", frame)
resultLabel.Size = UDim2.new(1, -20, 0, 50)
resultLabel.Position = UDim2.new(0, 10, 0, 0)
resultLabel.Text = "Choose an action"
resultLabel.TextColor3 = Color3.new(1, 1, 1)
resultLabel.Font = Enum.Font.SourceSans
resultLabel.TextSize = 18
resultLabel.BackgroundTransparency = 1
resultLabel.TextWrapped = true

-- 🥚 Random Egg Button
local eggButton = createButton("🥚 Random Egg")
eggButton.MouseButton1Click:Connect(function()
	resultLabel.Text = "Hatching..."
	wait(2)
	math.randomseed(tick())
	local chosenPet = petNames[math.random(1, #petNames)]
	resultLabel.Text = "You got: " .. chosenPet
end)

-- 🧬 Mutate Pet Button
local mutateButton = createButton("🧬 Mutate Pet")
mutateButton.MouseButton1Click:Connect(function()
	resultLabel.Text = "Attempting mutation..."
	wait(1.5)
	local success = math.random() > 0.5
	if success then
		resultLabel.Text = "Mutation Successful! Pet evolved!"
	else
		resultLabel.Text = "Mutation Failed. Try again."
	end
end)

-- 🔍 Mutation Finder Button
local finderButton = createButton("🔍 Find Mutatable Pets")
finderButton.MouseButton1Click:Connect(function()
	resultLabel.Text = "Scanning for mutatable pets..."
	wait(1)
	local found = {}
	for i = 1, math.random(1, 5) do
		local pet = mutatablePets[math.random(1, #mutatablePets)]
		table.insert(found, pet)
	end
	resultLabel.Text = "Mutatable Pets: " .. table.concat(found, ", ")
end)
