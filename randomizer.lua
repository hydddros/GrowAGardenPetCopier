-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Player and Mouse
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Egg categories and possible pets
local petPool = {
    ["Common Egg"] = {"Dog", "Bunny", "Golden Lab"},
    ["Uncommon Egg"] = {"Chicken", "Black Bunny", "Cat", "Deer"},
    ["Rare Egg"] = {"Pig", "Monkey", "Rooster", "Orange Tabby", "Spotted Deer"},
    ["Legendary Egg"] = {"Cow", "Polar Bear", "Sea Otter", "Turtle", "Silver Monkey"},
    ["Mythical Egg"] = {"Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant"},
    ["Bug Egg"] = {"Snail", "Caterpillar", "Giant Ant", "Praying Mantis"},
    ["Night Egg"] = {"Frog", "Hedgehog", "Mole", "Echo Frog", "Night Owl"},
    ["Bee Egg"] = {"Bee", "Honey Bee", "Bear Bee", "Petal Bee"},
    ["Anti Bee Egg"] = {"Wasp", "Moth", "Tarantula Hawk"},
    ["Oasis Egg"] = {"Meerkat", "Sand Snake", "Axolotl"},
    ["Paradise Egg"] = {"Ostrich", "Peacock", "Capybara"},
    ["Dinosaur Egg"] = {"Raptor", "Triceratops", "Stegosaurus"},
    ["Primal Egg"] = {"Parasaurolophus", "Iguanodon", "Pachycephalosaurus"}
}

-- Game state
local ESPEnabled = true
local randomizedPets = {}

-- Flash Text Effect
local function flashText(label)
    coroutine.wrap(function()
        local originalColor = label.TextColor3
        for i = 1, 2 do
            label.TextColor3 = Color3.new(1, 0, 0)
            wait(0.07)
            label.TextColor3 = originalColor
            wait(0.07)
        end
    end)()
end

-- Add ESP and UI to pet model
local function addPetESP(pet, petName)
    -- Check if base part exists
    local basePart = pet:FindFirstChildWhichIsA("BasePart")
    if not ESPEnabled or not basePart then return end

    -- Clean existing ESP
    local existingLabel = pet:FindFirstChild("PetBillboard", true)
    if existingLabel then existingLabel:Destroy() end
    local existingHighlight = pet:FindFirstChild("ESPHighlight")
    if existingHighlight then existingHighlight:Destroy() end

    -- Check hatch readiness
    local hatchTime = pet:FindFirstChild("HatchTime")
    local readyToHatch = pet:FindFirstChild("ReadyToHatch")
    local ready = true
    if hatchTime and hatchTime:IsA("NumberValue") and hatchTime.Value > 0 then ready = false end
    if readyToHatch and readyToHatch:IsA("BoolValue") and not readyToHatch.Value then ready = false end

    -- Billboard UI
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetBillboard"
    billboard.Size = UDim2.new(0, 270, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 500
    billboard.Parent = basePart

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = ready and pet.Name .. " | " .. petName or pet.Name .. " | " .. petName .. " (Not Ready)"
    textLabel.TextColor3 = ready and Color3.new(0, 1, 1) or Color3.fromRGB(160, 160, 160)
    textLabel.TextStrokeTransparency = ready and 0 or 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.FredokaOne
    textLabel.Parent = billboard
    flashText(textLabel)

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillColor = Color3.fromRGB(255, 200, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.7
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = pet
    highlight.Parent = pet
end

-- Remove ESP and UI from pet model
local function removePetESP(pet)
    local label = pet:FindFirstChild("PetBillboard", true)
    if label then label:Destroy() end
    local highlight = pet:FindFirstChild("ESPHighlight")
    if highlight then highlight:Destroy() end
end

-- Find all pet models in the workspace
local function findPets(radius)
    local foundPets = {}
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return foundPets end

    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and petPool[model.Name] then
            local distance = (model:GetModelCFrame().Position - hrp.Position).Magnitude
            if distance <= (radius or 50) then
                if not randomizedPets[model] then
                    local pool = petPool[model.Name]
                    randomizedPets[model] = pool[math.random(1, #pool)]
                end
                table.insert(foundPets, model)
            end
        end
    end
    return foundPets
end
