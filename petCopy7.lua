-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Player and GUI references
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- UI elements (adjust names to your UI hierarchy)
local ui = playerGui:WaitForChild("YourPetUI") -- your main UI container
ui.Enabled = true

local inventorySlot = ui:WaitForChild("InventorySlot") -- UI frame to show pet image
local copyButton = ui:WaitForChild("CopyButton") -- button to copy pet
local petNameBox = ui:WaitForChild("PetNameBox") -- textbox where player inputs pet name
local infoLabel = ui:WaitForChild("InfoLabel") -- label for feedback

-- Folder to store quick access pet models, NOT UI
local quickAccessSlot = player:FindFirstChild("QuickAccessSlot")
if not quickAccessSlot then
    quickAccessSlot = Instance.new("Folder")
    quickAccessSlot.Name = "QuickAccessSlot"
    quickAccessSlot.Parent = player
end

-- Utility: Clear quick access slot
local function clearQuickAccessSlot()
    for _, child in pairs(quickAccessSlot:GetChildren()) do
        child:Destroy()
    end
end

-- Find pet model by name (adjust path to your pets storage)
local petsFolder = workspace:WaitForChild("Pets") -- where pet templates are stored

local function findPetModelByName(name)
    return petsFolder:FindFirstChild(name)
end

-- Show pet icon in inventory slot UI
local function showPetIcon(petModel)
    inventorySlot:ClearAllChildren()

    local petIcon = Instance.new("ImageLabel")
    petIcon.Size = UDim2.new(1, 0, 1, 0)
    petIcon.BackgroundTransparency = 1
    petIcon.Image = "rbxassetid://12345678" -- Replace with real asset ID
    petIcon.ZIndex = 10

    petIcon.Parent = inventorySlot
end

-- Show pet model in front of player (in workspace)
local function showPetInHand(petModel)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")

    if not petModel.PrimaryPart then
        petModel.PrimaryPart = petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChildWhichIsA("BasePart")
        if not petModel.PrimaryPart then
            warn("Pet model has no PrimaryPart; cannot place in world")
            return
        end
    end

    petModel:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 0, -2))
    petModel.Parent = workspace
end

-- Lock camera during placement animation
local function lockCameraForPlacement(duration)
    local camera = workspace.CurrentCamera
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")

    local targetCFrame = root.CFrame * CFrame.new(0, 0, -2)
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.new(targetCFrame.Position + Vector3.new(0, 2, 5), targetCFrame.Position)

    delay(duration, function()
        if camera then
            camera.CameraType = Enum.CameraType.Custom
        end
    end)
end

-- On Copy button clicked
copyButton.MouseButton1Click:Connect(function()
    ui.Enabled = true

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
    for _, obj in pairs(workspace:GetChildren()) do
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

    infoLabel.Text = "Pet copied to quick access and visible."
end)

-- Initial state
ui.Enabled = true
clearQuickAccessSlot()
inventorySlot:ClearAllChildren()
infoLabel.Text = "Enter a pet name and click Copy."
