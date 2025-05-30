-- Universal Pet Copier & Growth System for Grow a Garden pets (client-side, testing/learning only)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetCopierUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 160)
frame.Position = UDim2.new(0.5, -160, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local textbox = Instance.new("TextBox")
textbox.Size = UDim2.new(0, 300, 0, 50)
textbox.Position = UDim2.new(0, 10, 0, 10)
textbox.PlaceholderText = "Enter pet name (e.g. Raccoon)"
textbox.TextColor3 = Color3.new(1,1,1)
textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textbox.Font = Enum.Font.SourceSansBold
textbox.TextSize = 22
textbox.ClearTextOnFocus = false
textbox.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 300, 0, 45)
button.Position = UDim2.new(0, 10, 0, 70)
button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 26
button.TextColor3 = Color3.new(1,1,1)
button.Text = "Copy Pet"
button.Parent = frame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 300, 0, 40)
infoLabel.Position = UDim2.new(0, 10, 0, 120)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(220,220,220)
infoLabel.Font = Enum.Font.SourceSansItalic
infoLabel.TextSize = 18
infoLabel.Text = ""
infoLabel.Parent = frame

-- Function to add Kilogram and Age attributes and growth to pet model
local function setupPetGrowth(petModel)
    if not petModel then return end

    -- Create or get Kilogram and Age NumberValues
    local kg = petModel:FindFirstChild("Kilogram")
    if not kg then
        kg = Instance.new("NumberValue")
        kg.Name = "Kilogram"
        kg.Value = math.random(5, 10) -- start weight
        kg.Parent = petModel
    end

    local age = petModel:FindFirstChild("Age")
    if not age then
        age = Instance.new("NumberValue")
        age.Name = "Age"
        age.Value = math.random(1, 3) -- start age
        age.Parent = petModel
    end

    -- Add BillboardGui to show Kilogram and Age above pet
    local primaryPart = petModel.PrimaryPart or petModel:FindFirstChild("HumanoidRootPart") or petModel:FindFirstChildWhichIsA("BasePart")
    if primaryPart and not petModel:FindFirstChild("PetBillboardGui") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PetBillboardGui"
        billboard.Adornee = primaryPart
        billboard.Size = UDim2.new(0, 140, 0, 55)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = petModel

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.6
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 18
        label.Parent = billboard

        -- Update the label every second
        spawn(function()
            while petModel.Parent do
                label.Text = string.format("Kg: %.1f\nAge: %d", kg.Value, age.Value)
                wait(1)
            end
        end)
    end

    -- Growth loop (increments weight and age every 10 seconds)
    spawn(function()
        while petModel.Parent do
            wait(10)
            kg.Value = kg.Value + 0.5
            age.Value = age.Value + 1
        end
    end)
end

-- Find pet anywhere in common storage places
local function findPetModelByName(petName)
    -- Search order: workspace, ReplicatedStorage, ServerStorage
    local placesToSearch = {
        workspace,
        game:FindFirstChild("ReplicatedStorage"),
        game:FindFirstChild("ServerStorage"),
    }

    for _, container in ipairs(placesToSearch) do
        if container then
            local pet = container:FindFirstChild(petName)
            if pet and pet:IsA("Model") then
                return pet
            end
        end
    end
    return nil
end

-- Button click: copy pet
button.MouseButton1Click:Connect(function()
    local petName = textbox.Text
    if petName == "" then
        infoLabel.Text = "Please enter a pet name."
        return
    end

    local petTemplate = findPetModelByName(petName)
    if not petTemplate then
        infoLabel.Text = "Pet not found in the game."
        return
    end

    local petClone = petTemplate:Clone()
    petClone.Name = petTemplate.Name

    -- Ensure PrimaryPart exists for placement & BillboardGui
    if not petClone.PrimaryPart then
        petClone.PrimaryPart = petClone:FindFirstChild("HumanoidRootPart") or petClone:FindFirstChildWhichIsA("BasePart")
        if not petClone.PrimaryPart then
            infoLabel.Text = "Pet model has no usable primary part."
            return
        end
    end

    -- Put pet clone in player's Backpack (simulate inventory)
    local backpack = player:WaitForChild("Backpack")
    petClone.Parent = backpack

    -- Setup growth and UI
    setupPetGrowth(petClone)

    infoLabel.Text = "Copied pet '"..petName.."'. Press 'P' to place in garden."
end)

-- Press P to place pet from Backpack into workspace in front of player
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.P then
        local backpack = player:WaitForChild("Backpack")
        local petToPlace = nil
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Model") then
                petToPlace = item
                break
            end
        end

        if petToPlace then
            petToPlace.Parent = workspace
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and petToPlace.PrimaryPart then
                petToPlace:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(0, 0, 5))
            end
            infoLabel.Text = "Placed pet '"..petToPlace.Name.."' in garden."
        else
            infoLabel.Text = "No pet in Backpack to place."
        end
    end
end)
