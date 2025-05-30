local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- UI elements - make sure these match your actual UI hierarchy
local ui = playerGui:WaitForChild("YourPetUI")
ui.Enabled = true -- force visible on load

local inventorySlot = ui:WaitForChild("InventorySlot")
local copyButton = ui:WaitForChild("CopyButton")
local petNameBox = ui:WaitForChild("PetNameBox")
local infoLabel = ui:WaitForChild("InfoLabel")

-- Quick Access Slot (non-UI folder to hold cloned pet)
local quickAccessSlot = player:FindFirstChild("QuickAccessSlot") or Instance.new("Folder", player)
quickAccessSlot.Name = "QuickAccessSlot"

-- Clear old models
local function clearQuickAccessSlot()
	for _, child in pairs(quickAccessSlot:GetChildren()) do
		child:Destroy()
	end
end

-- Pet templates stored in workspace.Pets
local petsFolder = workspace:WaitForChild("Pets")

local function findPetModelByName(name)
	return petsFolder:FindFirstChild(name)
end

-- UI Pet icon (you must manually match asset ID to your pet image)
local function showPetIcon(petModel)
	inventorySlot:ClearAllChildren()

	local petIcon = Instance.new("ImageLabel")
	petIcon.Size = UDim2.new(1, 0, 1, 0)
	petIcon.BackgroundTransparency = 1

	-- You must assign your icon correctly here:
	local assetId = "rbxassetid://INSERT_PET_IMAGE_ID_HERE"
	petIcon.Image = assetId

	petIcon.Parent = inventorySlot
end

-- Show pet model in front of player (visual placement only)
local function showPetInHand(petModel)
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	if not petModel.PrimaryPart then
		petModel.PrimaryPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChildWhichIsA("BasePart")
	end
	if not petModel.PrimaryPart then
		warn("No PrimaryPart in pet model.")
		return
	end

	petModel.Parent = workspace
	petModel:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 0, -2))
end

-- Lock camera briefly like Grow a Garden
local function lockCameraForPlacement(duration)
	local camera = workspace.CurrentCamera
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	camera.CameraType = Enum.CameraType.Scriptable
	local pos = root.Position + Vector3.new(0, 2, -2)
	camera.CFrame = CFrame.new(pos + Vector3.new(0, 2, 5), pos)

	delay(duration, function()
		camera.CameraType = Enum.CameraType.Custom
	end)
end

-- Copy button logic
copyButton.MouseButton1Click:Connect(function()
	local petName = petNameBox.Text
	if petName == "" then
		infoLabel.Text = "Please enter a pet name."
		return
	end

	local petTemplate = findPetModelByName(petName)
	if not petTemplate then
		infoLabel.Text = "Pet not found."
		return
	end

	clearQuickAccessSlot()

	-- Clean duplicates from workspace
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj.Name == petTemplate.Name and obj:IsA("Model") then
			obj:Destroy()
		end
	end

	local petClone = petTemplate:Clone()
	petClone.Name = petTemplate.Name
	petClone.Parent = quickAccessSlot

	showPetIcon(petClone)
	showPetInHand(petClone)
	lockCameraForPlacement(3)

	infoLabel.Text = petName .. " is ready!"
end)

-- Force visible UI and clean init
ui.Enabled = true
clearQuickAccessSlot()
inventorySlot:ClearAllChildren()
infoLabel.Text = "Enter pet name and click Copy."
