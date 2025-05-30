local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Quick Access Slot (outside backpack, visible pet "in hand")
local quickAccessSlot = Instance.new("Folder")
quickAccessSlot.Name = "QuickAccessSlot"
quickAccessSlot.Parent = player -- You can parent elsewhere depending on your game's structure

-- Function to check if quick access slot is full (let's say max 1 pet)
local function isQuickAccessFull()
    return #quickAccessSlot:GetChildren() >= 1
end

-- Function to clear quick access slot pet (when placing or swapping)
local function clearQuickAccessSlot()
    for _, child in pairs(quickAccessSlot:GetChildren()) do
        child:Destroy()
    end
end

-- Function to show pet "in hand" (positioned in front of player)
local function showPetInHand(petModel)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local root = character.HumanoidRootPart

    -- Position petModel in front of player
    petModel.Parent = workspace
    petModel:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 0, -2)) -- 2 studs in front

    -- Optional: Weld pet to hand or HumanoidRootPart for preview attachment
    -- This depends on your rig, adjust accordingly:
    --[[
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = character:FindFirstChild("RightHand") or root
    weld.Part1 = petModel.PrimaryPart
    weld.Parent = petModel.PrimaryPart
    ]]

    -- Could add a highlight or transparency here for visual effect
end

-- Copy button logic revised
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

    -- Clone pet to add to quick access slot or backpack
    local petClone = petTemplate:Clone()
    petClone.Name = petTemplate.Name

    if not petClone.PrimaryPart then
        petClone.PrimaryPart = petClone:FindFirstChild("HumanoidRootPart") or petClone:FindFirstChildWhichIsA("BasePart")
        if not petClone.PrimaryPart then
            infoLabel.Text = "Pet model has no usable primary part."
            return
        end
    end

    local inputKg = parseNumberInput(kgBox.Text, math.random(5, 10))
    local inputAge = parseNumberInput(ageBox.Text, math.random(1, 3))

    setupPetGrowth(petClone, inputKg, inputAge)

    if not isQuickAccessFull() then
        -- Put pet in quick access slot (visible "in hand")
        clearQuickAccessSlot() -- clear existing if any
        petClone.Parent = quickAccessSlot

        -- Show in hand preview
        showPetInHand(petClone)

        infoLabel.Text = string.format("Pet '%s' copied to quick access slot. Select and place in your garden.", petName)
    else
        -- Add to backpack if quick access full
        petClone.Parent = player:WaitForChild("Backpack")
        infoLabel.Text = string.format("Quick access full. Pet '%s' copied to backpack.", petName)
    end
end)
