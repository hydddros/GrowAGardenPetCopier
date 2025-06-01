local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === UI Setup ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DiscoWeatherUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200) -- smaller size
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Disco Event Weather"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Parent = Frame

local ActivateButton = Instance.new("TextButton")
ActivateButton.Size = UDim2.new(0.6, 0, 0, 40)
ActivateButton.Position = UDim2.new(0.2, 0, 0.7, 0)
ActivateButton.BackgroundColor3 = Color3.fromRGB(220, 50, 240)
ActivateButton.TextColor3 = Color3.new(1,1,1)
ActivateButton.Text = "Activate Disco"
ActivateButton.Font = Enum.Font.GothamBold
ActivateButton.TextScaled = true
ActivateButton.Parent = Frame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextScaled = true
CloseButton.Parent = Frame

-- === Variables to store created instances for cleanup ===
local discoFloorModel = nil
local djModel = nil
local discoMusic = nil
local lightTweenConnections = {}
local lightingOriginalSettings = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
}

local DJ_ANIMATION_ID = "rbxassetid://507766666" -- Replace with your own DJ dance animation ID if you want

-- === Functions ===

local function createDiscoFloor()
    local floorModel = Instance.new("Model")
    floorModel.Name = "DiscoFloor"
    floorModel.Parent = workspace

    local size = 6 -- 6x6 tiles
    local tileSize = 4

    for x = 0, size - 1 do
        for z = 0, size - 1 do
            local part = Instance.new("Part")
            part.Anchored = true
            part.Size = Vector3.new(tileSize, 0.5, tileSize)
            part.Position = Vector3.new(x * tileSize, 0, z * tileSize)
            part.Material = Enum.Material.Neon
            part.Color = Color3.new(1, 0, 0)
            part.Name = "Tile"
            part.Parent = floorModel
        end
    end

    -- Position floor near player
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    floorModel:SetPrimaryPartCFrame(CFrame.new(root.Position.X, root.Position.Y - 3, root.Position.Z) * CFrame.new(-12, 0, -12))

    return floorModel
end

local function animateDiscoFloor(floorModel)
    coroutine.wrap(function()
        while floorModel and floorModel.Parent do
            for _, tile in pairs(floorModel:GetChildren()) do
                if tile:IsA("Part") then
                    tile.Color = Color3.fromHSV(math.random(), 1, 1)
                end
            end
            wait(0.5)
        end
    end)()
end

local function spawnDJ()
    -- Simple placeholder DJ model as a humanoid
    local dj = Instance.new("Model")
    dj.Name = "DJBooth"
    dj.Parent = workspace

    -- Create HumanoidRootPart
    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(2, 2, 1)
    rootPart.Anchored = true
    rootPart.Position = Vector3.new(0, 3, 0) -- will be moved later
    rootPart.Parent = dj
    dj.PrimaryPart = rootPart

    -- Create dummy head
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 1, 1)
    head.Position = rootPart.Position + Vector3.new(0, 2.5, 0)
    head.Anchored = true
    head.Parent = dj

    -- Create humanoid to load animations
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = dj

    -- Position DJ near the disco floor (slightly elevated)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    dj:SetPrimaryPartCFrame(root.CFrame * CFrame.new(-6, 0, -6))

    -- Load and play animation
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    local animation = Instance.new("Animation")
    animation.AnimationId = DJ_ANIMATION_ID
    local animationTrack = animator:LoadAnimation(animation)
    animationTrack.Looped = true
    animationTrack:Play()

    return dj
end

local function playDiscoMusic()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://1845443181" -- classic disco track ID or replace with your own
    sound.Volume = 0.7
    sound.Looped = true
    sound.Parent = workspace
    sound:Play()
    return sound
end

local function startLightingEffects()
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)

    -- Ambient and OutdoorAmbient color tweening to random bright colors
    local function tweenColors()
        while true do
            local newAmbient = Color3.fromHSV(math.random(), 1, 1)
            local newOutdoor = Color3.fromHSV(math.random(), 1, 1)

            Lighting.Ambient = newAmbient
            Lighting.OutdoorAmbient = newOutdoor

            wait(1)
        end
    end

    -- Start coroutine for color tweening
    local lightingThread = coroutine.create(tweenColors)
    coroutine.resume(lightingThread)

    -- Store coroutine reference to stop later if needed
    table.insert(lightTweenConnections, lightingThread)
end

local function stopLightingEffects()
    -- Reset lighting
    Lighting.Ambient = lightingOriginalSettings.Ambient
    Lighting.OutdoorAmbient = lightingOriginalSettings.OutdoorAmbient
    Lighting.Brightness = lightingOriginalSettings.Brightness

    -- Stopping coroutines is tricky; here we just rely on discarding references and resetting colors
    lightTweenConnections = {}
end

local function cleanup()
    if discoFloorModel then
        discoFloorModel:Destroy()
        discoFloorModel = nil
    end
    if djModel then
        djModel:Destroy()
        djModel = nil
    end
    if discoMusic then
        discoMusic:Stop()
        discoMusic:Destroy()
        discoMusic = nil
    end
    stopLightingEffects()
end

-- === Button events ===

ActivateButton.MouseButton1Click:Connect(function()
    cleanup() -- cleanup any previous instances

    discoFloorModel = createDiscoFloor()
    animateDiscoFloor(discoFloorModel)
    djModel = spawnDJ()
    discoMusic = playDiscoMusic()
    startLightingEffects()
end)

CloseButton.MouseButton1Click:Connect(function()
    cleanup()
    ScreenGui:Destroy()
end)

-- === Optional: Cleanup on player leaving ===
player.AncestryChanged:Connect(function(_, parent)
    if not parent then
        cleanup()
    end
end)
