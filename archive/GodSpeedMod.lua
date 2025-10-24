local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local screenGui = nil
local mainFrame = nil
local speedInput = nil
local speedValue = 50
local isSpeedActive = false
local isGodModeActive = false

local TOGGLE_KEY = Enum.KeyCode.Insert

-- Variables pour vitesse
local originalWalkSpeed = 16
local originalJumpPower = 50

function createGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GodSpeedMod"
    screenGui.Parent = player.PlayerGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 180)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    -- Border effect
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 2, 1, 2)
    border.Position = UDim2.new(0, -1, 0, -1)
    border.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    border.ZIndex = -1
    border.Parent = mainFrame
    
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, 16)
    borderCorner.Parent = border
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 35)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "GOD SPEED MOD"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 12)
    closeCorner.Parent = closeBtn
    
    -- Speed section
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 80, 0, 25)
    speedLabel.Position = UDim2.new(0, 20, 0, 50)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Vitesse:"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.GothamMedium
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = mainFrame
    
    speedInput = Instance.new("TextBox")
    speedInput.Size = UDim2.new(0, 100, 0, 35)
    speedInput.Position = UDim2.new(0, 110, 0, 45)
    speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    speedInput.BorderSizePixel = 0
    speedInput.Text = tostring(speedValue)
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.TextSize = 16
    speedInput.Font = Enum.Font.GothamMedium
    speedInput.PlaceholderText = "Vitesse"
    speedInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    speedInput.Parent = mainFrame
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 8)
    speedCorner.Parent = speedInput
    
    -- Speed input border
    local speedBorder = Instance.new("Frame")
    speedBorder.Size = UDim2.new(1, 2, 1, 2)
    speedBorder.Position = UDim2.new(0, -1, 0, -1)
    speedBorder.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    speedBorder.ZIndex = -1
    speedBorder.Parent = speedInput
    
    local speedBorderCorner = Instance.new("UICorner")
    speedBorderCorner.CornerRadius = UDim.new(0, 9)
    speedBorderCorner.Parent = speedBorder
    
    -- Speed toggle button
    local speedToggleBtn = Instance.new("TextButton")
    speedToggleBtn.Size = UDim2.new(0, 100, 0, 35)
    speedToggleBtn.Position = UDim2.new(0, 220, 0, 45)
    speedToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    speedToggleBtn.BorderSizePixel = 0
    speedToggleBtn.Text = "SPEED OFF"
    speedToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggleBtn.TextSize = 12
    speedToggleBtn.Font = Enum.Font.GothamBold
    speedToggleBtn.Parent = mainFrame
    
    local speedToggleCorner = Instance.new("UICorner")
    speedToggleCorner.CornerRadius = UDim.new(0, 8)
    speedToggleCorner.Parent = speedToggleBtn
    
    -- God mode section
    local godLabel = Instance.new("TextLabel")
    godLabel.Size = UDim2.new(0, 80, 0, 25)
    godLabel.Position = UDim2.new(0, 20, 0, 90)
    godLabel.BackgroundTransparency = 1
    godLabel.Text = "God Mode:"
    godLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    godLabel.TextSize = 14
    godLabel.Font = Enum.Font.GothamMedium
    godLabel.TextXAlignment = Enum.TextXAlignment.Left
    godLabel.Parent = mainFrame
    
    local godToggleBtn = Instance.new("TextButton")
    godToggleBtn.Size = UDim2.new(0, 120, 0, 35)
    godToggleBtn.Position = UDim2.new(0, 110, 0, 85)
    godToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    godToggleBtn.BorderSizePixel = 0
    godToggleBtn.Text = "GOD MODE OFF"
    godToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    godToggleBtn.TextSize = 12
    godToggleBtn.Font = Enum.Font.GothamBold
    godToggleBtn.Parent = mainFrame
    
    local godToggleCorner = Instance.new("UICorner")
    godToggleCorner.CornerRadius = UDim.new(0, 8)
    godToggleCorner.Parent = godToggleBtn
    
    -- Action buttons
    local forceBtn = Instance.new("TextButton")
    forceBtn.Size = UDim2.new(0, 80, 0, 35)
    forceBtn.Position = UDim2.new(0, 20, 0, 130)
    forceBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    forceBtn.BorderSizePixel = 0
    forceBtn.Text = "FORCER"
    forceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    forceBtn.TextSize = 13
    forceBtn.Font = Enum.Font.GothamBold
    forceBtn.Parent = mainFrame
    
    local forceCorner = Instance.new("UICorner")
    forceCorner.CornerRadius = UDim.new(0, 8)
    forceCorner.Parent = forceBtn
    
    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0, 80, 0, 35)
    stopBtn.Position = UDim2.new(0, 110, 0, 130)
    stopBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    stopBtn.BorderSizePixel = 0
    stopBtn.Text = "ARRÊTER"
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.TextSize = 13
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.Parent = mainFrame
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 8)
    stopCorner.Parent = stopBtn
    
    local infoBtn = Instance.new("TextButton")
    infoBtn.Size = UDim2.new(0, 80, 0, 35)
    infoBtn.Position = UDim2.new(0, 200, 0, 130)
    infoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
    infoBtn.BorderSizePixel = 0
    infoBtn.Text = "INFO"
    infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoBtn.TextSize = 13
    infoBtn.Font = Enum.Font.GothamBold
    infoBtn.Parent = mainFrame
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoBtn
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -40, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 0, 175)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: TOUT INACTIF"
    statusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    -- Connexions des boutons
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    speedToggleBtn.MouseButton1Click:Connect(function()
        toggleSpeed()
    end)
    
    godToggleBtn.MouseButton1Click:Connect(function()
        toggleGodMode()
    end)
    
    forceBtn.MouseButton1Click:Connect(function()
        forceAll()
    end)
    
    stopBtn.MouseButton1Click:Connect(function()
        stopAll()
    end)
    
    infoBtn.MouseButton1Click:Connect(function()
        showInfo()
    end)
    
    -- Validation automatique de l'input vitesse
    speedInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            updateSpeedValue()
        end
    end)
    
    -- Hover effects
    addHoverEffect(speedToggleBtn, Color3.fromRGB(50, 50, 50), Color3.fromRGB(70, 70, 70))
    addHoverEffect(godToggleBtn, Color3.fromRGB(50, 50, 50), Color3.fromRGB(70, 70, 70))
    addHoverEffect(forceBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(40, 120, 40))
    addHoverEffect(stopBtn, Color3.fromRGB(150, 50, 50), Color3.fromRGB(120, 40, 40))
    addHoverEffect(infoBtn, Color3.fromRGB(50, 50, 150), Color3.fromRGB(40, 40, 120))
    addHoverEffect(closeBtn, Color3.fromRGB(200, 50, 50), Color3.fromRGB(160, 40, 40))
end

-- Fonction pour les effets de hover
function addHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor})
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor})
        tween:Play()
    end)
end

-- Fonction pour mettre à jour la valeur de vitesse
function updateSpeedValue()
    local newSpeed = tonumber(speedInput.Text)
    if newSpeed and newSpeed > 0 and newSpeed <= 200 then
        speedValue = newSpeed
        print("✅ Vitesse mise à jour:", speedValue)
    else
        print("❌ Vitesse invalide (1-200)")
        speedInput.Text = tostring(speedValue)
    end
end

-- Fonction pour activer/désactiver le speed
function toggleSpeed()
    isSpeedActive = not isSpeedActive
    local speedToggleBtn = mainFrame:FindFirstChild("speedToggleBtn")
    
    if isSpeedActive then
        print("🚀 Speed activé")
        if speedToggleBtn then 
            speedToggleBtn.Text = "SPEED ON"
            speedToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        end
    else
        print("⏹️ Speed désactivé")
        if speedToggleBtn then 
            speedToggleBtn.Text = "SPEED OFF"
            speedToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end
    updateStatus()
end

-- Fonction pour activer/désactiver le god mode
function toggleGodMode()
    isGodModeActive = not isGodModeActive
    local godToggleBtn = mainFrame:FindFirstChild("godToggleBtn")
    
    if isGodModeActive then
        print("🛡️ God Mode activé")
        if godToggleBtn then 
            godToggleBtn.Text = "GOD MODE ON"
            godToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        end
    else
        print("⏹️ God Mode désactivé")
        if godToggleBtn then 
            godToggleBtn.Text = "GOD MODE OFF"
            godToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end
    updateStatus()
end

-- Fonction pour forcer tout
function forceAll()
    updateSpeedValue()
    applySpeedOnce()
    applyGodMode()
    print("🔥 Tout forcé!")
end

-- Fonction pour arrêter tout
function stopAll()
    isSpeedActive = false
    isGodModeActive = false
    
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = originalWalkSpeed
        char.Humanoid.JumpPower = originalJumpPower
        char.Humanoid.MaxHealth = 100
        char.Humanoid.Health = 100
        print("🐌 Tout restauré")
    end
    
    -- Reset des boutons
    local speedToggleBtn = mainFrame:FindFirstChild("speedToggleBtn")
    local godToggleBtn = mainFrame:FindFirstChild("godToggleBtn")
    
    if speedToggleBtn then 
        speedToggleBtn.Text = "SPEED OFF"
        speedToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
    if godToggleBtn then 
        godToggleBtn.Text = "GOD MODE OFF"
        godToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
    
    updateStatus()
end

-- Fonction pour appliquer la vitesse une seule fois
function applySpeedOnce()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedValue
        char.Humanoid.JumpPower = speedValue * 2
        print("🚀 Vitesse forcée:", speedValue)
    end
end

-- Fonction pour appliquer le god mode
function applyGodMode()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.MaxHealth = math.huge
        char.Humanoid.Health = math.huge
        print("🛡️ God Mode appliqué")
    end
end

-- Fonction pour mettre à jour le status
function updateStatus()
    local statusLabel = mainFrame:FindFirstChild("statusLabel")
    if statusLabel then
        local status = "Status: "
        if isSpeedActive and isGodModeActive then
            status = status .. "SPEED + GOD ACTIFS"
        elseif isSpeedActive then
            status = status .. "SPEED ACTIF"
        elseif isGodModeActive then
            status = status .. "GOD ACTIF"
        else
            status = status .. "TOUT INACTIF"
        end
        statusLabel.Text = status
    end
end

-- Fonction pour afficher les infos
function showInfo()
    print("📊 GOD SPEED MOD")
    print("🎛️ Vitesse configurée: " .. speedValue)
    print("🚀 Speed: " .. (isSpeedActive and "ACTIF" or "INACTIF"))
    print("🛡️ God Mode: " .. (isGodModeActive and "ACTIF" or "INACTIF"))
    print("⌨️ Touches: INSERT = Menu")
    
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        print("👤 Vitesse actuelle: " .. char.Humanoid.WalkSpeed)
        print("🦘 Saut actuel: " .. char.Humanoid.JumpPower)
        print("❤️ Santé actuelle: " .. char.Humanoid.Health)
    end
end

function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

createGUI()
makeDraggable(mainFrame)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == TOGGLE_KEY then
        if mainFrame.Visible then
            mainFrame.Visible = false
        else
            mainFrame.Visible = true
        end
    end
end)

-- Boucle de force continue
task.spawn(function()
    while true do
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            if isSpeedActive then
                char.Humanoid.WalkSpeed = speedValue
                char.Humanoid.JumpPower = speedValue * 2
            end
            
            if isGodModeActive then
                char.Humanoid.MaxHealth = math.huge
                char.Humanoid.Health = math.huge
            end
        end
        task.wait(0.1) -- Force toutes les 0.1 secondes
    end
end)

print("God Speed Mod chargé! God Mode + Speed Boost avec force continue")
