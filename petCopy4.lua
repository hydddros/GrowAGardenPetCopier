-- LocalScript (place this in StarterPlayerScripts or StarterGui)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("Script started")

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetCopierUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create UI elements
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 5
mainFrame.Parent = screenGui
print("Created mainFrame")

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Copy Pet"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.ZIndex = 6
titleLabel.Parent = mainFrame

local petNameBox = Instance.new("TextBox")
petNameBox.PlaceholderText = "Enter Pet Name"
petNameBox.Size = UDim2.new(0.9, 0, 0, 30)
petNameBox.Position = UDim2.new(0.05, 0, 0, 40)
petNameBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
petNameBox.ZIndex = 6
petNameBox.Parent = mainFrame
print("Created petNameBox")

local kgBox = Instance.new("TextBox")
kgBox.PlaceholderText = "Enter KG"
kgBox.Size = UDim2.new(0.9, 0, 0, 30)
kgBox.Position = UDim2.new(0.05, 0, 0, 80)
kgBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
kgBox.ZIndex = 6
kgBox.Parent = mainFrame
print("Created kgBox")

local copyButton = Instance.new("TextButton")
copyButton.Text = "Copy"
copyButton.Size = UDim2.new(0.9, 0, 0, 30)
copyButton.Position = UDim2.new(0.05, 0, 0, 120)
copyButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
copyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
copyButton.ZIndex = 6
copyButton.Parent = mainFrame
print("Created copyButton")

local placementNotice = Instance.new("TextLabel")
placementNotice.Text = "Click your garden to place the pet"
placementNotice.Size = UDim2.new(1, 0, 0, 30)
placementNotice.Position = UDim2.new(0, 0, 1, 10)
placementNotice.BackgroundTransparency = 1
placementNotice.TextColor3 = Color3.fromRGB(255, 255, 255)
placementNotice.TextScaled = true
placementNotice.Visible = false
placementNotice.ZIndex = 6
placementNotice.Parent = mainFrame
print("Created placementNotice")

-- Simulated pet template
local function createPetModel(name, kg)
    local pet = Instance.new("Model")
    pet.Name = name

    local body = Instance.new("Part")
    body.Size = Vector3.new(2, 2, 2)
    body.BrickColor = BrickColor.Random()
    body.Anchored = true
    body.CanCollide = false
    body.Parent = pet

    local label = Instance.new("BillboardGui")
    label.Size = UDim2.new(0, 100, 0, 40)
    label.Adornee = body
    label.AlwaysOnTop = true

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = name .. " (" .. kg .. "kg)"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.Parent = label

    label.Parent = body
    return pet
end

local copiedPet = nil
local placing = false

copyButton.MouseButton1Click:Connect(function()
    local name = petNameBox.Text
    local kg = kgBox.Text
    if name ~= "" and kg ~= "" then
        copiedPet = createPetModel(name, kg)
        placementNotice.Visible = true
        placing = true
        print("Pet copied and waiting for placement")
    end
end)

workspace.MouseClickDetector.MouseClick:Connect(function(hit)
    if placing and copiedPet then
        local garden = hit:FindFirstAncestor("OwnGarden")
        if garden and garden:IsA("Model") then
            copiedPet:SetPrimaryPartCFrame(CFrame.new(hit.Position + Vector3.new(0, 1, 0)))
            copiedPet.Parent = garden

            -- Lock camera to the pet placement
            local camera = workspace.CurrentCamera
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.new(hit.Position + Vector3.new(0, 5, 10), hit.Position)

            TweenService:Create(camera, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
                CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 6), hit.Position)
            }):Play()

            wait(2)
            camera.CameraType = Enum.CameraType.Custom
            placing = false
            placementNotice.Visible = false
            print("Pet placed in garden")
        else
            warn("You can only place in your own garden!")
        end
    end
end)

print("PetCopierUI is ready")
