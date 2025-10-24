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

local TOGGLE_KEY = Enum.KeyCode.Insert

-- Variables pour vitesse
local originalWalkSpeed = 16
local originalJumpPower = 50

function createGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedModMenuV4"
    screenGui.Parent = player.PlayerGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 140)
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
    title.Text = "SPEED MOD V4 - FORCE"
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
    
    -- Toggle button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.Position = UDim2.new(0, 220, 0, 45)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "ACTIVER"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 13
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = mainFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn
    
    -- Action buttons
    local speedOnlyBtn = Instance.new("TextButton")
    speedOnlyBtn.Size = UDim2.new(0, 80, 0, 35)
    speedOnlyBtn.Position = UDim2.new(0, 20, 0, 90)
    speedOnlyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    speedOnlyBtn.BorderSizePixel = 0
    speedOnlyBtn.Text = "FORCER"
    speedOnlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedOnlyBtn.TextSize = 13
    speedOnlyBtn.Font = Enum.Font.GothamBold
    speedOnlyBtn.Parent = mainFrame
    
    local speedOnlyCorner = Instance.new("UICorner")
    speedOnlyCorner.CornerRadius = UDim.new(0, 8)
    speedOnlyCorner.Parent = speedOnlyBtn
    
    local restoreBtn = Instance.new("TextButton")
    restoreBtn.Size = UDim2.new(0, 80, 0, 35)
    restoreBtn.Position = UDim2.new(0, 110, 0, 90)
    restoreBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    restoreBtn.BorderSizePixel = 0
    restoreBtn.Text = "ARRÊTER"
    restoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    restoreBtn.TextSize = 13
    restoreBtn.Font = Enum.Font.GothamBold
    restoreBtn.Parent = mainFrame
    
    local restoreCorner = Instance.new("UICorner")
    restoreCorner.CornerRadius = UDim.new(0, 8)
    restoreCorner.Parent = restoreBtn
    
    local infoBtn = Instance.new("TextButton")
    infoBtn.Size = UDim2.new(0, 80, 0, 35)
    infoBtn.Position = UDim2.new(0, 200, 0, 90)
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
    statusLabel.Position = UDim2.new(0, 20, 0, 135)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: INACTIF"
    statusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    -- Connexions des boutons
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    toggleBtn.MouseButton1Click:Connect(function()
        toggleSpeed()
    end)
    
    speedOnlyBtn.MouseButton1Click:Connect(function()
        forceSpeed()
    end)
    
    restoreBtn.MouseButton1Click:Connect(function()
        stopSpeed()
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
    addHoverEffect(toggleBtn, Color3.fromRGB(50, 50, 50), Color3.fromRGB(70, 70, 70))
    addHoverEffect(speedOnlyBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(40, 120, 40))
    addHoverEffect(restoreBtn, Color3.fromRGB(150, 50, 50), Color3.fromRGB(120, 40, 40))
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

-- Fonction pour forcer la vitesse (une seule fois)
function forceSpeed()
    updateSpeedValue()
    applySpeedOnce()
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

-- Fonction pour activer/désactiver le mode force continu
function toggleSpeed()
    isSpeedActive = not isSpeedActive
    local statusLabel = mainFrame:FindFirstChild("statusLabel")
    local toggleBtn = mainFrame:FindFirstChild("toggleBtn")
    
    if isSpeedActive then
        print("🔄 Mode force activé - vitesse maintenue en continu")
        if statusLabel then statusLabel.Text = "Status: ACTIF - FORCE CONTINUE" end
        if toggleBtn then 
            toggleBtn.Text = "DÉSACTIVER"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    else
        print("⏹️ Mode force désactivé")
        if statusLabel then statusLabel.Text = "Status: INACTIF" end
        if toggleBtn then 
            toggleBtn.Text = "ACTIVER"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end
end

-- Fonction pour arrêter complètement
function stopSpeed()
    isSpeedActive = false
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = originalWalkSpeed
        char.Humanoid.JumpPower = originalJumpPower
        print("🐌 Vitesse restaurée:", originalWalkSpeed)
    end
    
    local statusLabel = mainFrame:FindFirstChild("statusLabel")
    local toggleBtn = mainFrame:FindFirstChild("toggleBtn")
    if statusLabel then statusLabel.Text = "Status: INACTIF" end
    if toggleBtn then 
        toggleBtn.Text = "ACTIVER"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end

-- Fonction pour afficher les infos
function showInfo()
    print("📊 SPEED MOD MENU V4 - FORCE")
    print("🎛️ Vitesse configurée: " .. speedValue)
    print("🔄 Mode force: " .. (isSpeedActive and "ACTIF" or "INACTIF"))
    print("⌨️ Touches: INSERT = Menu")
    print("🚀 Vitesse normale: " .. originalWalkSpeed)
    
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        print("👤 Vitesse actuelle du personnage: " .. char.Humanoid.WalkSpeed)
        print("🦘 Saut actuel du personnage: " .. char.Humanoid.JumpPower)
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
        if isSpeedActive then
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = speedValue
                char.Humanoid.JumpPower = speedValue * 2
            end
        end
        task.wait(0.1) -- Force toutes les 0.1 secondes
    end
end)

print("Speed Mod Menu V4 chargé! Mode force continu pour contrer les resets")
