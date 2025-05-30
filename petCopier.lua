-- Client-side LocalScript

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- RemoteEvent for syncing with server (create in ReplicatedStorage)
local PetAddEvent = ReplicatedStorage:WaitForChild("PetAddEvent")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetCopierUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 270)  -- Increased height to fit everything
frame.Position = UDim2.new(0.5, -160, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Pet Copier"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 24
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Parent = frame

-- Dropdown Frame for pets
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0, 300, 0, 30)
dropdownFrame.Position = UDim2.new(0, 10, 0, 40)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownFrame.Parent = frame

-- Selected Text (shows selected pet)
local selectedText = Instance.new("TextLabel")
selectedText.Size = UDim2.new(1, -30, 1, 0)
selectedText.Position = UDim2.new(0, 5, 0, 0)
selectedText.BackgroundTransparency = 1
selectedText.Text = "Select a pet"
selectedText.TextColor3 = Color3.new(1, 1, 1)
selectedText.TextXAlignment = Enum.TextXAlignment.Left
selectedText.Parent = dropdownFrame

-- Dropdown arrow button
local arrowButton = Instance.new("TextButton")
arrowButton.Size = UDim2.new(0, 30, 1, 0)
arrowButton.Position = UDim2.new(1, -30, 0, 0)
arrowButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
arrowButton.Text = "▼"
arrowButton.TextColor3 = Color3.new(1,1,1)
arrowButton.Font = Enum.Font.SourceSansBold
arrowButton.TextSize = 18
arrowButton.Parent = dropdownFrame

-- Dropdown list (hidden initially)
local dropdownList = Instance.new("ScrollingFrame")
dropdownList.Size = UDim2.new(0, 300, 0, 100)
dropdownList.Position = UDim2.new(0, 10, 0, 70)
dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownList.BorderSizePixel = 0
dropdownList.Visible = false
dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownList.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = dropdownList

-- Age TextBox
local ageBox = Instance.new("TextBox")
ageBox.Size = UDim2.new(0, 140, 0, 30)
ageBox.Position = UDim2.new(0, 10, 0, 180)
ageBox.PlaceholderText = "Age (default 1)"
ageBox.TextColor3 = Color3.new(1, 1, 1)
ageBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ageBox.Font = Enum.Font.SourceSansBold
ageBox.TextSize = 20
ageBox.ClearTextOnFocus = false
ageBox.Parent = frame

-- Kilogram TextBox
local kiloBox = Instance.new("TextBox")
kiloBox.Size = UDim2.new(0, 140, 0, 30)
kiloBox.Position = UDim2.new(0, 170, 0, 180)
kiloBox.PlaceholderText = "Kilograms (default 1)"
kiloBox.TextColor3 = Color3.new(1, 1, 1)
kiloBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
kiloBox.Font = Enum.Font.SourceSansBold
kiloBox.TextSize = 20
kiloBox.ClearTextOnFocus = false
kiloBox.Parent = frame

-- Copy Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 300, 0, 40)
button.Position = UDim2.new(0, 10, 0, 220)
button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
button.Text = "Copy Pet"
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 22
button.Parent = frame

-- Helper function to populate dropdown list
local function populateDropdown()
    dropdownList:ClearAllChildren()
    local petFolder = ReplicatedStorage:WaitForChild("PetModels")
    local petNames = {}

    for _, petModel in pairs(petFolder:GetChildren()) do
        if petModel:IsA("Model") then
            table.insert(petNames, petModel.Name)
        end
    end
    table.sort(petNames)

    for i, petName in ipairs(petNames) do
        local petButton = Instance.new("TextButton")
        petButton.Size = UDim2.new(1, 0, 0, 30)
        petButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        petButton.Text = petName
        petButton.TextColor3 = Color3.new(1, 1, 1)
        petButton.Font = Enum.Font.SourceSans
        petButton.TextSize = 18
        petButton.Parent = dropdownList

        petButton.MouseButton1Click:Connect(function()
            selectedText.Text = petName
            dropdownList.Visible = false
        end)
    end

    -- Adjust canvas size to fit all items
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, #petNames * 30)
end

-- Show/hide dropdown when arrow clicked
arrowButton.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
end)

-- Hide dropdown if clicked outside using UserInputService
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if dropdownList.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local guiPos = dropdownList.AbsolutePosition
            local guiSize = dropdownList.AbsoluteSize

            local insideX = mousePos.X >= guiPos.X and mousePos.X <= guiPos.X + guiSize.X
            local insideY = mousePos.Y >= guiPos.Y and mousePos.Y <= guiPos.Y + guiSize.Y

            if not (insideX and insideY) then
                dropdownList.Visible = false
            end
        end
    end
end)

-- Initial population of dropdown
populateDropdown()

-- Button click: send data to server
button.MouseButton1Click:Connect(function()
    local petName = selectedText.Text
    if petName == "Select a pet" or petName == "" then
        warn("Please select a pet from the dropdown.")
        return
    end

    local age = tonumber(ageBox.Text) or 1
    local kilo = tonumber(kiloBox.Text) or 1

    -- Fire RemoteEvent to server with data
    PetAddEvent:FireServer(petName, age, kilo)
end)
