local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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

-- Cleanup variables for weather effects
local currentWeatherCleanup = nil

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WeatherSelectorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Select Weather"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Parent = Frame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextScaled = true
CloseButton.Parent = Frame

-- Scrolling frame for weather buttons
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ScrollingFrame

-- Helper function to cleanup weather effects
local function cleanupWeather()
    if currentWeatherCleanup then
        currentWeatherCleanup()
        currentWeatherCleanup = nil
    end
end

-- Example effect functions (you add your own logic here)

local function applySunny()
    cleanupWeather()
    Lighting.ClockTime = 14 -- sunny day
    Lighting.FogEnd = 100000
    Lighting.Brightness = 2
    -- Add more sunny effect code here

    currentWeatherCleanup = function()
        -- Reset lighting or effects if needed
    end
end

local function applyRain()
    cleanupWeather()
    -- Simple rain effect (you can expand with particle effects, sounds)
    Lighting.FogEnd = 100
    Lighting.Brightness = 1.2
    Lighting.ClockTime = 16

    currentWeatherCleanup = function()
        -- Reset lighting
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2
    end
end

local function applyDiscoEvent()
    cleanupWeather()
    -- Use your disco event code here (from previous response)
    -- For example:

    -- (create floor, spawn DJ, play music, lighting effects)
    -- For demo, just change lighting colors for now

    local running = true
    coroutine.wrap(function()
        while running do
            Lighting.Ambient = Color3.fromHSV(math.random(),1,1)
            Lighting.OutdoorAmbient = Color3.fromHSV(math.random(),1,1)
            wait(0.5)
        end
    end)()

    currentWeatherCleanup = function()
        running = false
        -- Reset lighting here if needed
    end
end

local weatherFunctions = {
    ["Sunny"] = applySunny,
    ["Rain"] = applyRain,
    ["Disco Event"] = applyDiscoEvent,
    -- Add all others similarly...
}

-- Create buttons for each weather
for _, weatherName in ipairs(weathers) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 110)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Text = weatherName
    btn.Parent = ScrollingFrame

    btn.MouseButton1Click:Connect(function()
        print("Applying weather:", weatherName)
        local fn = weatherFunctions[weatherName]
        if fn then
            fn()
        else
            warn("No effect defined for weather:", weatherName)
        end
    end)
end

CloseButton.MouseButton1Click:Connect(function()
    cleanupWeather()
    ScreenGui:Destroy()
end)
