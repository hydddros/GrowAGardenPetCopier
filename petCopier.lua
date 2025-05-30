local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetCopierUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 220)
frame.Position = UDim2.new(0.5, -160, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local petNameBox = Instance.new("TextBox")
petNameBox.Size = UDim2.new(0, 300, 0, 40)
petNameBox.Position = UDim2.new(0, 10, 0, 10)
petNameBox.PlaceholderText = "Enter pet name (e.g. Raccoon)"
petNameBox.TextColor3 = Color3.new(1,1,1)
petNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
petNameBox.Font = Enum.Font.SourceSansBold
petNameBox.TextSize = 22
petNameBox.ClearTextOnFocus = false
petNameBox.Parent = frame

local kgBox = Instance.new("TextBox")
kgBox.Size = UDim2.new(0, 140, 0, 40)
kgBox.Position = UDim2.new(0, 10, 0, 60)
kgBox.PlaceholderText = "Kilogram (e.g. 7.5)"
kgBox.TextColor3 = Color3.new(1,1,1)
kgBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
kgBox.Font = Enum.Font.SourceSansBold
kgBox.TextSize = 20
kgBox.ClearTextOnFocus = false
kgBox.Parent = frame

local ageBox = Instance.new("TextBox")
ageBox.Size = UDim2.new(0, 140, 0, 40)
ageBox.Position = UDim2.new(0, 170, 0, 60)
ageBox.PlaceholderText = "Age (e.g. 2)"
ageBox.TextColor3 = Color3.new(1,1,1)
ageBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ageBox.Font = Enum.Font.SourceSansBold
ageBox.TextSize = 20
ageBox.ClearTextOnFocus = false
ageBox.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 300, 0, 45)
button.Position = UDim2.new(0, 10, 0, 110)
button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 26
button.TextColor3 = Color3.new(1,1,1)
button.Text = "Copy Pet"
button.Parent = frame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 300, 0, 50)
infoLabel.Position = UDim2.new(0, 10, 0, 160)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(220,220,220)
infoLabel.Font = Enum.Font.SourceSansItalic
infoLabel.TextSize = 18
infoLabel.Text = ""
infoLabel.Parent = frame

local function parseNumberInput(inputText, defaultValue)
    local num = tonumber(inputText)
    return num or defaultValue
end

local function findPetModelByNameRecursive(container, petName)
    for _, child in ipairs(container:GetChildren()) do
        if child.Name:lower() == petName:lower() and child:IsA("Model") then
            return child
        end
        if child:IsA("Folder") or child:IsA("Model") then
            local found = findPetModelByNameRecursive(child, petName)
            if found then return found end
        end
    end
    return nil
end

local function findPetModelByName(petName)
    local searchContainers = {
        workspace,
        game:GetService("ReplicatedStorage"),
        game:GetService("ServerStorage"),
    }
    for _, container in ipairs(searchContainers) do
        local pet = findPetModelByNameRecursive(container, petName)
        if pet then return pet end
    end
    return nil
end

local function setupPetGrowth(petModel, initialKg, initialAge)
    if not petModel then return end

    local kg = petModel:FindFirstChild("Kilogram")
    if not kg then
        kg = Instance.new("NumberValue")
        kg.Name = "Kilogram"
        kg.Value = initialKg or math.random(5, 10)
        kg.Parent = petModel
    else
        kg.Value = initialKg or kg.Value
    end

    local age = petModel:FindFirstChild("Age")
    if not age then
        age = Instance.new("NumberValue")
        age.Name = "Age"
        age.Value = initialAge or math.random(1, 3)
        age.Parent = petModel
    else
        age.Value = initialAge or age.Value
    end

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

        spawn(function()
            while petModel.Parent do
                label.Text = string.format("Kg: %.1f\nAge: %d", kg.Value, age.Value)
                wait(1)
            end
        end)
    end

    spawn(function()
        while petModel.Parent do
            wait(10)
            kg.Value += 0.5
            age.Value += 1
        end
    end)
end

-- Copy pet logic only, no P key usage
button.MouseButton1Click:Connect(function()
    local petName = petNameBox.Text
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

    -- Set PrimaryPart if missing
    if not petClone.PrimaryPart then
        petClone.PrimaryPart = petClone:FindFirstChild("HumanoidRootPart") or petClone:FindFirstChildWhichIsA("BasePart")
        if not petClone.PrimaryPart then
            infoLabel.Text = "Pet model has no usable primary part."
            return
        end
    end

    local inputKg = parseNumberInput(kgBox.Text, math.random(5, 10))
    local inputAge = parseNumberInput(ageBox.Text, math.random(1, 3))

    petClone.Parent = workspace

    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart", 3)
    if root then
        petClone:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 0, -5))
    end

    setupPetGrowth(petClone, inputKg, inputAge)

    infoLabel.Text = string.format("Copied and placed '%s' with %.1f kg and age %d.", petName, inputKg, inputAge)
end)
