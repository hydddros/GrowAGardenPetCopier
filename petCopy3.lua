-- ✅ FINAL SCRIPT: Full Grow-a-Garden Style Pet Placement
-- STRUCTURE:
-- 1. Pet Creation + Inventory
-- 2. UI (LocalScript)
-- 3. Garden Click (LocalScript)
-- 4. Server Placement Logic (with camera lock)

-- 🧩 1. PET CREATION (in some ServerScript when player gets pet)
local function createPetForPlayer(player, petTemplate, petName)
    local petClone = petTemplate:Clone()
    petClone.Name = petName
    petClone:SetAttribute("Owner", player.UserId)
    petClone:SetAttribute("PlacedInGarden", false)

    local myPets = player:FindFirstChild("MyPets") or Instance.new("Folder")
    myPets.Name = "MyPets"
    myPets.Parent = player
    petClone.Parent = myPets
end

-- 🖼️ 2. UI INVENTORY SCRIPT (LocalScript in GUI)
local player = game.Players.LocalPlayer
local petsFolder = player:WaitForChild("MyPets")
local petInventoryFrame = script.Parent:WaitForChild("PetInventoryFrame")
local selectedPetName = nil

local function refreshInventory()
    petInventoryFrame:ClearAllChildren()
    for _, pet in ipairs(petsFolder:GetChildren()) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 50)
        button.Text = pet.Name
        button.Parent = petInventoryFrame

        button.MouseButton1Click:Connect(function()
            selectedPetName = pet.Name
        end)
    end
end

petsFolder.ChildAdded:Connect(refreshInventory)
refreshInventory()

-- 🖱️ 3. GARDEN CLICK LOGIC (LocalScript in StarterPlayerScripts)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local placePetEvent = ReplicatedStorage:WaitForChild("PlacePetInGarden")
local camera = workspace.CurrentCamera

local function findClickableGarden()
    local garden = workspace:WaitForChild("Gardens"):FindFirstChild(player.Name)
    return garden and garden:FindFirstChild("MyGardenClickable")
end

local clickableGarden = findClickableGarden()

if clickableGarden then
    clickableGarden.MouseClick:Connect(function()
        if selectedPetName then
            placePetEvent:FireServer(selectedPetName)
        end
    end)
end

-- 🌱 4. SERVER-SIDE PLACEMENT (Script in ServerScriptService)
local placePetEvent = game:GetService("ReplicatedStorage"):WaitForChild("PlacePetInGarden")

placePetEvent.OnServerEvent:Connect(function(player, petName)
    local petsFolder = player:FindFirstChild("MyPets")
    if not petsFolder then return end

    local pet = petsFolder:FindFirstChild(petName)
    if not pet or pet:GetAttribute("PlacedInGarden") then return end

    local garden = workspace:WaitForChild("Gardens"):FindFirstChild(player.Name)
    local spawn = garden and garden:FindFirstChild("PetSpawn")
    if not spawn then return end

    pet.Parent = garden
    if pet:IsA("Model") and pet.PrimaryPart then
        pet:SetPrimaryPartCFrame(spawn.CFrame)
    end
    pet:SetAttribute("PlacedInGarden", true)

    -- 🔒 Lock player's camera and animate
    local camEvent = ReplicatedStorage:FindFirstChild("LockCameraEvent")
    if camEvent then
        camEvent:FireClient(player, pet.PrimaryPart.Position)
    end
end)

-- 🎥 5. CLIENT CAMERA ANIMATION (LocalScript in StarterPlayerScripts)
local camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local camEvent = ReplicatedStorage:WaitForChild("LockCameraEvent")

camEvent.OnClientEvent:Connect(function(targetPosition)
    local TweenService = game:GetService("TweenService")
    local camGoal = CFrame.new(targetPosition + Vector3.new(0, 5, -10), targetPosition)

    local tween = TweenService:Create(camera, TweenInfo.new(1, Enum.EasingStyle.Sine), {
        CFrame = camGoal
    })
    tween:Play()
end)
