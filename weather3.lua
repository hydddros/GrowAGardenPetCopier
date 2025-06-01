local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local WEATHER_DURATION = 60 -- seconds

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

-- UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WeatherSelectorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 380)
Frame.Position = UDim2.new(0.5, -140, 0.5, -190)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Frame.ClipsDescendants = true

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Select Weather (1 min duration)"
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

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ScrollingFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = Frame
UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(60, 60, 80)

-- Cleanup helpers
local currentCleanup = nil
local currentTimer = nil

local function cleanup()
    if currentCleanup then
        currentCleanup()
        currentCleanup = nil
    end
    if currentTimer then
        currentTimer:Disconnect()
        currentTimer = nil
    end
    -- Reset Lighting defaults
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    Lighting.TimeOfDay = "14:00:00"
    Lighting.FogColor = Color3.fromRGB(255, 255, 255)
end

-- Effects implementations:

local function applySunny()
    cleanup()
    Lighting.ClockTime = 14
    Lighting.Brightness = 2.5
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.OutdoorAmbient = Color3.fromRGB(170, 170, 170)
    Lighting.Ambient = Color3.fromRGB(170, 170, 170)
    Lighting.FogColor = Color3.fromRGB(255, 255, 255)

    currentCleanup = function()
        -- revert done in cleanup()
    end
end

local function applyRain()
    cleanup()
    Lighting.ClockTime = 16
    Lighting.Brightness = 1.2
    Lighting.FogStart = 10
    Lighting.FogEnd = 70
    Lighting.FogColor = Color3.fromRGB(100, 100, 110)
    Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 100)
    Lighting.Ambient = Color3.fromRGB(80, 80, 100)

    -- Create rain particle effect attached to the camera
    local rain = Instance.new("ParticleEmitter")
    rain.Texture = "rbxassetid://7712212243" -- raindrop texture
    rain.Rate = 1500
    rain.Lifetime = NumberRange.new(1, 1.5)
    rain.Speed = NumberRange.new(50, 70)
    rain.VelocitySpread = 15
    rain.Parent = workspace.CurrentCamera

    currentCleanup = function()
        rain.Enabled = false
        rain:Destroy()
    end
end

local function applyThunderstorm()
    cleanup()
    Lighting.ClockTime = 17
    Lighting.Brightness = 1
    Lighting.FogStart = 10
    Lighting.FogEnd = 60
    Lighting.FogColor = Color3.fromRGB(60, 60, 70)
    Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 60)
    Lighting.Ambient = Color3.fromRGB(50, 50, 60)

    -- Rain particle effect
    local rain = Instance.new("ParticleEmitter")
    rain.Texture = "rbxassetid://7712212243"
    rain.Rate = 2000
    rain.Lifetime = NumberRange.new(1, 1.5)
    rain.Speed = NumberRange.new(60, 90)
    rain.VelocitySpread = 25
    rain.Parent = workspace.CurrentCamera

    -- Thunder light flashes
    local flash = Instance.new("PointLight")
    flash.Range = 30
    flash.Brightness = 5
    flash.Color = Color3.fromRGB(255, 255, 255)
    flash.Parent = workspace.CurrentCamera

    local running = true
    local flashCoroutine
    flashCoroutine = coroutine.create(function()
        while running do
            wait(math.random(5, 15))
            flash.Enabled = true
            wait(0.2)
            flash.Enabled = false
            wait(0.1)
            flash.Enabled = true
            wait(0.1)
            flash.Enabled = false
        end
    end)
    coroutine.resume(flashCoroutine)

    currentCleanup = function()
        running = false
        rain.Enabled = false
        rain:Destroy()
        flash:Destroy()
    end
end

local function applySnow()
    cleanup()
    Lighting.ClockTime = 14
    Lighting.Brightness = 1.5
    Lighting.FogStart = 10
    Lighting.FogEnd = 70
    Lighting.FogColor = Color3.fromRGB(230, 230, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 200)
    Lighting.Ambient = Color3.fromRGB(180, 180, 200)

    -- Snow particle effect
    local snow = Instance.new("ParticleEmitter")
    snow.Texture = "rbxassetid://4964193777" -- snowflake texture
    snow.Rate = 1200
    snow.Lifetime = NumberRange.new(3, 5)
    snow.Speed = NumberRange.new(5, 8)
    snow.VelocitySpread = 15
    snow.Parent = workspace.CurrentCamera

    currentCleanup = function()
        snow.Enabled = false
        snow:Destroy()
    end
end

local function applyBloodMoon()
    cleanup()
    Lighting.ClockTime = 20
    Lighting.Brightness = 1.1
    Lighting.FogStart = 10
    Lighting.FogEnd = 90
    Lighting.FogColor = Color3.fromRGB(150, 20, 20)
    Lighting.OutdoorAmbient = Color3.fromRGB(90, 10, 10)
    Lighting.Ambient = Color3.fromRGB(90, 10, 10)

    currentCleanup = function() end
end

local function applyLunarMoon()
    cleanup()
    Lighting.ClockTime = 22
    Lighting.Brightness = 1.3
    Lighting.FogStart = 0
    Lighting.FogEnd = 100
    Lighting.FogColor = Color3.fromRGB(200, 200, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(130, 130, 190)
    Lighting.Ambient = Color3.fromRGB(130, 130, 190)

    currentCleanup = function() end
end

local function applyMeteorShower()
    cleanup()
    Lighting.ClockTime = 1
    Lighting.Brightness = 1.3
    Lighting.FogStart = 0
    Lighting.FogEnd = 100
    Lighting.FogColor = Color3.fromRGB(50, 50, 100)
    Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 110)
    Lighting.Ambient = Color3.fromRGB(70, 70, 110)

    -- Meteor effect: create fast shooting particles from sky to ground
    local meteorFolder = Instance.new("Folder", workspace)
    meteorFolder.Name = "MeteorShowerFolder"

    local running = true
    local function spawnMeteor()
        if not running then return end
        local meteor = Instance.new("Part")
        meteor.Size = Vector3.new(0.3, 0.3, 2)
        meteor.Anchored = true
        meteor.CanCollide = false
        meteor.BrickColor = BrickColor.new("Really red")
        meteor.Material = Enum.Material.Neon
        meteor.CFrame = CFrame.new(
            math.random(-100, 100),
            100,
            math.random(-100, 100)
        ) * CFrame.Angles(math.rad(90), 0, 0)
        meteor.Parent = meteorFolder

        local velocity = Vector3.new(0, -150, 0)
        local time = 0

        local connection
        connection = RunService.Heartbeat:Connect(function(dt)
            time += dt
            if time > 1 or not running then
                meteor:Destroy()
                connection:Disconnect()
                return
            end
            meteor.CFrame = meteor.CFrame * CFrame.new(0, velocity.Y * dt, 0)
        end)
    end

    local meteorSpawner = RunService.Heartbeat:Connect(function()
        if running then
            if math.random() < 0.03 then -- 3% chance per frame
                spawnMeteor()
            end
        end
    end)

    currentCleanup = function()
        running = false
        meteorSpawner:Disconnect()
        if meteorFolder then meteorFolder:Destroy() end
    end
end

local function applySheckleRain()
    cleanup()
    Lighting.ClockTime = 16
    Lighting.Brightness = 1.4
    Lighting.FogStart = 10
    Lighting.FogEnd = 70
    Lighting.FogColor = Color3.fromRGB(100, 100, 110)
    Lighting.OutdoorAmbient = Color3.fromRGB(90, 90, 120)
    Lighting.Ambient = Color3.fromRGB(90, 90, 120)

    -- Shekle Rain = Rain + some gold coins falling
    local rain = Instance.new("ParticleEmitter")
    rain.Texture = "rbxassetid://7712212243"
    rain.Rate = 1200
    rain.Lifetime = NumberRange.new(1, 1.5)
    rain.Speed = NumberRange.new(50, 70)
    rain.VelocitySpread = 15
    rain.Parent = workspace.CurrentCamera

    local coinFolder = Instance.new("Folder", workspace)
    coinFolder.Name = "SheckleRainCoins"

    local running = true
    local function spawnCoin()
        if not running then return end
        local coin = Instance.new("Part")
        coin.Size = Vector3.new(0.5, 0.5, 0.1)
        coin.Shape = Enum.PartType.Cylinder
        coin.BrickColor = BrickColor.new("Bright yellow")
        coin.Material = Enum.Material.Neon
        coin.Anchored = false
        coin.CanCollide = false
        coin.CFrame = CFrame.new(
            math.random(-100, 100),
            60,
            math.random(-100, 100)
        )
        coin.Parent = coinFolder
        coin.Velocity = Vector3.new(0, -50, 0)

        Debris:AddItem(coin, 4)
    end

    local coinSpawner = RunService.Heartbeat:Connect(function()
        if running then
            if math.random() < 0.1 then -- 10% chance per frame
                spawnCoin()
            end
        end
    end)

    currentCleanup = function()
        running = false
        rain.Enabled = false
        rain:Destroy()
        coinSpawner:Disconnect()
        if coinFolder then coinFolder:Destroy() end
    end
end

local function applyDiscoEvent()
    cleanup()
    Lighting.ClockTime = 20
    Lighting.Brightness = 2
    Lighting.FogStart = 0
    Lighting.FogEnd = 100
    Lighting.FogColor = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)

    local light = Instance.new("PointLight")
    light.Brightness = 4
    light.Range = 50
    light.Parent = workspace.CurrentCamera

    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 0, 255),
    }

    local running = true
    local index = 1

    currentTimer = RunService.Heartbeat:Connect(function(dt)
        if not running then return end
        index += 1
        if index > #colors then index = 1 end
        light.Color = colors[index]
        wait(0.2)
    end)

    currentCleanup = function()
        running = false
        currentTimer:Disconnect()
        light:Destroy()
    end
end

local function applyBlackHole()
    cleanup()
    Lighting.ClockTime = 0
    Lighting.Brightness = 0.3
    Lighting.FogStart = 0
    Lighting.FogEnd = 20
    Lighting.FogColor = Color3.fromRGB(0, 0, 0)
    Lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 10)
    Lighting.Ambient = Color3.fromRGB(10, 10, 10)

    -- Black hole effect: slow swirling particles
    local blackHoleFolder = Instance.new("Folder", workspace)
    blackHoleFolder.Name = "BlackHoleParticles"

    local running = true

    local function spawnParticle()
        if not running then return end
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.2,0.2,0.2)
        part.Shape = Enum.PartType.Ball
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.BrickColor = BrickColor.new("Really black")
        part.Transparency = 0.5
        part.Parent = blackHoleFolder

        -- Swirl around center (0, 50, 0)
        local center = Vector3.new(0, 50, 0)
        local angle = 0
        local radius = math.random(3,7)
        local height = math.random(45, 55)
        local time = 0

        local connection
        connection = RunService.Heartbeat:Connect(function(dt)
            if not running then
                part:Destroy()
                connection:Disconnect()
                return
            end
            time += dt
            angle += dt * math.pi * 2
            local x = center.X + math.cos(angle) * radius
            local z = center.Z + math.sin(angle) * radius
            local y = height - time * 2
            part.Position = Vector3.new(x, y, z)
            if y < 40 then
                part:Destroy()
                connection:Disconnect()
            end
        end)
    end

    local particleSpawner = RunService.Heartbeat:Connect(function()
        if running and math.random() < 0.05 then
            spawnParticle()
        end
    end)

    currentCleanup = function()
        running = false
        particleSpawner:Disconnect()
        if blackHoleFolder then blackHoleFolder:Destroy() end
    end
end

local function applyTornado()
    cleanup()
    Lighting.ClockTime = 15
    Lighting.Brightness = 1.3
    Lighting.FogStart = 0
    Lighting.FogEnd = 60
    Lighting.FogColor = Color3.fromRGB(150, 150, 160)
    Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 130)
    Lighting.Ambient = Color3.fromRGB(120, 120, 130)

    -- Tornado effect: swirling debris

    local tornadoFolder = Instance.new("Folder", workspace)
    tornadoFolder.Name = "TornadoDebris"

    local running = true
    local center = Vector3.new(0, 0, 0)
    local debrisParts = {}

    local function spawnDebris()
        if not running then return end
        local debris = Instance.new("Part")
        debris.Size = Vector3.new(1, 1, 1)
        debris.Anchored = false
        debris.CanCollide = false
        debris.BrickColor = BrickColor.new("Dark stone grey")
        debris.Material = Enum.Material.Concrete
        debris.Position = center + Vector3.new(math.random(-10, 10), math.random(1, 20), math.random(-10, 10))
        debris.Velocity = Vector3.new(0, 0, 0)
        debris.Parent = tornadoFolder
        table.insert(debrisParts, debris)
        Debris:AddItem(debris, 8)
    end

    local debrisSpawner = RunService.Heartbeat:Connect(function()
        if running and math.random() < 0.1 then
            spawnDebris()
        end
    end)

    -- Swirl debris around a point
    local swirlTime = 0
    currentTimer = RunService.Heartbeat:Connect(function(dt)
        if not running then return end
        swirlTime += dt * 10
        for i, part in pairs(debrisParts) do
            if part and part.Parent then
                local radius = 10
                local angle = swirlTime + i
                local y = part.Position.Y + 0.05
                part.CFrame = CFrame.new(center.X + math.cos(angle) * radius, y, center.Z + math.sin(angle) * radius)
            end
        end
    end)

    currentCleanup = function()
        running = false
        debrisSpawner:Disconnect()
        if currentTimer then currentTimer:Disconnect() end
        if tornadoFolder then tornadoFolder:Destroy() end
    end
end

local function applyBeeSwarm()
    cleanup()
    Lighting.ClockTime = 12
    Lighting.Brightness = 2
    Lighting.FogStart = 0
    Lighting.FogEnd = 70
    Lighting.FogColor = Color3.fromRGB(150, 180, 50)
    Lighting.OutdoorAmbient = Color3.fromRGB(170, 190, 70)
    Lighting.Ambient = Color3.fromRGB(170, 190, 70)

    local beeFolder = Instance.new("Folder", workspace)
    beeFolder.Name = "BeeSwarmFolder"

    local running = true

    local function spawnBee()
        if not running then return end
        local bee = Instance.new("Part")
        bee.Size = Vector3.new(0.3, 0.3, 0.3)
        bee.Shape = Enum.PartType.Ball
        bee.BrickColor = BrickColor.new("Bright yellow")
        bee.Material = Enum.Material.SmoothPlastic
        bee.Anchored = false
        bee.CanCollide = false
        bee.Position = workspace.CurrentCamera.CFrame.Position + Vector3.new(math.random(-20,20), math.random(1,10), math.random(-20,20))
        bee.Parent = beeFolder

        local velocity = Vector3.new(math.random(-10, 10), math.random(-5, 5), math.random(-10, 10))
        bee.Velocity = velocity

        Debris:AddItem(bee, 5)
    end

    local beeSpawner = RunService.Heartbeat:Connect(function()
        if running and math.random() < 0.2 then
            spawnBee()
        end
    end)

    currentCleanup = function()
        running = false
        beeSpawner:Disconnect()
        if beeFolder then beeFolder:Destroy() end
    end
end

local weatherFunctions = {
    Sunny = applySunny,
    Rain = applyRain,
    Thunderstorm = applyThunderstorm,
    Snow = applySnow,
    ["Blood Moon"] = applyBloodMoon,
    ["Lunar Moon"] = applyLunarMoon,
    ["Meteor Shower"] = applyMeteorShower,
    ["Sheckle Rain"] = applySheckleRain,
    ["Disco Event"] = applyDiscoEvent,
    ["Black Hole"] = applyBlackHole,
    Tornado = applyTornado,
    ["Bee Swarm"] = applyBeeSwarm
}

local function startWeather(weatherName)
    if not weatherFunctions[weatherName] then
        warn("No function for weather: " .. weatherName)
        return
    end

    -- Clean previous effects
    cleanup()

    -- Apply new weather
    weatherFunctions[weatherName]()

    -- Start timer to reset after WEATHER_DURATION seconds
    local WEATHER_DURATION = 60 -- seconds

    delay(WEATHER_DURATION, function()
        cleanup()
    end)
end

return {
    startWeather = startWeather,
    cleanup = cleanup,
}
