-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Remove existing GUI if present
local existingGui = PlayerGui:FindFirstChild("WeatherSimulatorGUI")
if existingGui then
    existingGui:Destroy()
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeatherSimulatorGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Create Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(34, 139, 34) -- Forest Green
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Create Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 0, 50)
titleLabel.Position = UDim2.new(0, 20, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🌦️ Weather Simulator"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 24
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Create Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 10)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = mainFrame

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Weather List
local weathers = {
    "Sunny",
    "Rain",
    "Thunderstorm",
    "Snow",
    "Blood Moon",
    "Lunar Moon",
    "Meteor Shower",
    "Sheckle Rain",
    "Disco Event",
    "Black Hole",
    "Tornado",
    "Bee Swarm"
}

-- Function to reset Lighting to default
local function resetLighting()
    Lighting:ClearAllChildren()
    Lighting.TimeOfDay = "14:00:00"
    Lighting.Brightness = 2
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.FogColor = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
end

-- Function to simulate weather effects
local function simulateWeather(weather)
    resetLighting()
    
    if weather == "Sunny" then
        -- Default settings
    elseif weather == "Rain" then
        Lighting.FogEnd = 300
        Lighting.FogColor = Color3.fromRGB(100, 100, 100)
        -- Add rain particle effect
        local rain = Instance.new("ParticleEmitter")
        rain.Texture = "rbxassetid://484289967" -- Replace with desired rain texture
        rain.Rate = 1000
        rain.Lifetime = NumberRange.new(0.5, 0.5)
        rain.Speed = NumberRange.new(20, 20)
        rain.VelocitySpread = 180
        rain.Parent = Lighting
    elseif weather == "Thunderstorm" then
        Lighting.FogEnd = 200
        Lighting.FogColor = Color3.fromRGB(80, 80, 80)
        -- Simulate lightning flashes
        spawn(function()
            while true do
                wait(math.random(5,10))
                local originalBrightness = Lighting.Brightness
                Lighting.Brightness = 10
                wait(0.1)
                Lighting.Brightness = originalBrightness
            end
        end)
    elseif weather == "Snow" then
        Lighting.FogEnd = 400
        Lighting.FogColor = Color3.fromRGB(200, 200, 255)
        -- Add snow particle effect
        local snow = Instance.new("ParticleEmitter")
        snow.Texture = "rbxassetid://484289967" -- Replace with desired snow texture
        snow.Rate = 500
        snow.Lifetime = NumberRange.new(1, 1)
        snow.Speed = NumberRange.new(5, 5)
        snow.VelocitySpread = 180
        snow.Parent = Lighting
    elseif weather == "Blood Moon" then
        Lighting.TimeOfDay = "00:00:00"
        Lighting.FogEnd = 300
        Lighting.FogColor = Color3.fromRGB(255, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 0, 0)
    elseif weather == "Lunar Moon" then
        Lighting.TimeOfDay = "00:00:00"
        Lighting.FogEnd = 300
        Lighting.FogColor = Color3.fromRGB(0, 0, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 100)
    elseif weather == "Meteor Shower" then
        Lighting.FogEnd = 500
        Lighting.FogColor = Color3.fromRGB(150, 75, 0)
        -- Add meteor particle effects (placeholder)
        -- For actual meteors, you'd need to spawn parts with trails
    elseif weather == "Sheckle Rain" then
        Lighting.FogEnd = 300
        Lighting.FogColor = Color3.fromRGB(255, 223, 0)
        -- Add coin particle effects (placeholder)
    elseif weather == "Disco Event" then
        Lighting.FogEnd = 400
        Lighting.FogColor = Color3.fromRGB(255, 0, 255)
        -- Add disco lights and music (placeholder)
    elseif weather == "Black Hole" then
        Lighting.FogEnd = 100
        Lighting.FogColor = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        -- Add black hole visual effects (placeholder)
    elseif weather == "Tornado" then
        Lighting.FogEnd = 200
        Lighting.FogColor = Color3.fromRGB(128, 128, 128)
        -- Add tornado visual effects (placeholder)
    elseif weather == "Bee Swarm" then
        Lighting.FogEnd = 300
        Lighting.FogColor = Color3.fromRGB(255, 255, 0)
        -- Add bee swarm particle effects (placeholder)
    end
end

-- Create Buttons for each weather
for i, weather in ipairs(weathers) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -40, 0, 30)
    button.Position = UDim2.new(0, 20, 0, 70 + (i - 1) * 35)
    button.Text = "Simulate: " .. weather
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = mainFrame

    button.MouseButton1Click:Connect(function()
        simulateWeather(weather)
    end)
end
