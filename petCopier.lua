--// ReplicatedStorage Setup (Ensure this is in the game)
-- RemoteEvent: AddPetToInventory
-- Folder: PetModels (contains pet model instances)

--// LocalScript (e.g., inside StarterPlayerScripts or ScreenGui)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetCopierUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 260)
frame.Position = UDim2.new(0.5, -160, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Dropdown (Pet List)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0, 300, 0, 40)
dropdown.Position = UDim2.new(0, 10, 0, 10)
dropdown.Text = "Select Pet"
dropdown.TextColor3 = Color3.new(1,1,1)
dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdown.Parent = frame

local selectedPetName = ""

-- Dropdown functionality
local petListFrame = Instance.new("Frame")
petListFrame.Size = UDim2.new(0, 300, 0, 120)
petListFrame.Position = UDim2.new(0, 10, 0, 50)
petListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
petListFrame.Visible = false
petListFrame.Parent = frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = petListFrame

local function refreshPetList()
	petListFrame:ClearAllChildren()
	UIListLayout.Parent = petListFrame

	for _, model in ipairs(ReplicatedStorage:WaitForChild("PetModels"):GetChildren()) do
		if model:IsA("Model") then
			local petButton = Instance.new("TextButton")
			petButton.Size = UDim2.new(1, 0, 0, 30)
			petButton.Text = model.Name
			petButton.TextColor3 = Color3.new(1,1,1)
			petButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			petButton.Parent = petListFrame

			petButton.MouseButton1Click:Connect(function()
				selectedPetName = model.Name
				dropdown.Text = "Pet: " .. selectedPetName
				petListFrame.Visible = false
			end)
		end
	end
end

refreshPetList()

dropdown.MouseButton1Click:Connect(function()
	petListFrame.Visible = not petListFrame.Visible
end)

-- Kilogram Input
local kgBox = Instance.new("TextBox")
kgBox.Size = UDim2.new(0, 140, 0, 40)
kgBox.Position = UDim2.new(0, 10, 0, 180)
kgBox.PlaceholderText = "Kilogram (e.g. 7.5)"
kgBox.TextColor3 = Color3.new(1,1,1)
kgBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
kgBox.Font = Enum.Font.SourceSansBold
kgBox.TextSize = 20
kgBox.ClearTextOnFocus = false
kgBox.Parent = frame

-- Age Input
local ageBox = Instance.new("TextBox")
ageBox.Size = UDim2.new(0, 140, 0, 40)
ageBox.Position = UDim2.new(0, 170, 0, 180)
ageBox.PlaceholderText = "Age (e.g. 2)"
ageBox.TextColor3 = Color3.new(1,1,1)
ageBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ageBox.Font = Enum.Font.SourceSansBold
ageBox.TextSize = 20
ageBox.ClearTextOnFocus = false
ageBox.Parent = frame

-- Copy Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 300, 0, 45)
button.Position = UDim2.new(0, 10, 0, 230)
button.Text = "Add Pet"
button.TextColor3 = Color3.new(1,1,1)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 22
button.Parent = frame

-- Remote call
button.MouseButton1Click:Connect(function()
	if selectedPetName == "" then
		warn("Please select a pet from the dropdown.")
		return
	end

	local age = tonumber(ageBox.Text) or 1
	local kilo = tonumber(kgBox.Text) or 1

	ReplicatedStorage:WaitForChild("AddPetToInventory"):FireServer(selectedPetName, age, kilo)
end)


--// ServerScript (ServerScriptService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("AddPetToInventory")

local function getFirstEmptySlot(folder)
	for _, slot in ipairs(folder:GetChildren()) do
		if not slot:FindFirstChild("Pet") then
			return slot
		end
	end
	return nil
end

remote.OnServerEvent:Connect(function(player, petName, age, kilo)
	local petFolder = ReplicatedStorage:WaitForChild("PetModels")
	local petModel = petFolder:FindFirstChild(petName)
	if not petModel then
		warn("Invalid pet name from client: " .. petName)
		return
	end

	age = tonumber(age) or 1
	kilo = tonumber(kilo) or 1

	local inventory = player:FindFirstChild("Inventory")
	if not inventory then warn("Inventory not found for player") return end

	local quickSlots = inventory:FindFirstChild("QuickSlots")
	local backpackSlots = inventory:FindFirstChild("BackpackSlots")

	local petClone = petModel:Clone()
	petClone.Name = "Pet"
	petClone:SetAttribute("Age", age)
	petClone:SetAttribute("Kilograms", kilo)

	local slot = getFirstEmptySlot(quickSlots) or getFirstEmptySlot(backpackSlots)
	if slot then
		petClone.Parent = slot
	else
		warn("No available inventory slot.")
		petClone:Destroy()
	end
end)
