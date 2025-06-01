-- Admin Weather Control UI Script for Grow a Garden

-- Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeatherControlUI"
screenGui.Parent = PlayerGui

-- Create Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Parent = screenGui

-- Create Title Label
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
title.Text = "Weather Control"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

-- Weather Options
local weatherTypes = {
    "Sunny",
    "Rain",
    "Thunderstorm",
    "Snow",
    "Blood Moon",
    "Lunar Moon",
    "Meteor Shower",
    "Sheckle Rain",
    "Disco Event"
}

-- Function to create buttons
local function createButton(weather, index)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 25)
    button.Position = UDim2.new(0, 10, 0, 30 + (index - 1) * 30)
    button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    button.Text = weather
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = frame

    button.MouseButton1Click:Connect(function()
        -- Open the console and set the weather
        -- This assumes you have a function to send commands to the server
        -- Replace 'setWeather' with the actual command used in your game
        local command = "/setweather " .. weather
        game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(command, "All")
    end)
end

-- Create buttons for each weather type
for i, weather in ipairs(weatherTypes) do
    createButton(weather, i)
end
