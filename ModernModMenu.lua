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

function createGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernModMenu"
    screenGui.Parent = player.PlayerGui
    
    -- Main container avec design moderne
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 180)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame
    
    -- Effet de glow moderne
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 4, 1, 4)
    glow.Position = UDim2.new(0, -2, 0, -2)
    glow.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    glow.BackgroundTransparency = 0.3
    glow.ZIndex = -1
    glow.Parent = mainFrame
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 18)
    glowCorner.Parent = glow
    
    -- Header avec gradient
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    -- Gradient header
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 200))
    }
    headerGradient.Rotation = 45
    headerGradient.Parent = header
    
    -- Titre moderne
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "MODERN MOD"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Bouton close moderne
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- Content area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -55)
    content.Position = UDim2.new(0, 10, 0, 50)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Section Speed avec design moderne
    local speedSection = createModernSection("SPEED BOOST", 0, content)
    local speedInput = createModernInput("Vitesse", tostring(speedValue), speedSection, 0)
    local speedToggle = createModernToggle("SPEED", false, speedSection, 1)
    local speedIndicator = createIndicator("SPEED", false, speedSection, 2)
    
    -- Section God Mode
    local godSection = createModernSection("GOD MODE", 1, content)
    local godToggle = createModernToggle("GOD", false, godSection, 0)
    local godIndicator = createIndicator("GOD", false, godSection, 1)
    
    -- Status moderne
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 30)
    statusBar.Position = UDim2.new(0, 0, 1, -30)
    statusBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    statusBar.BorderSizePixel = 0
    statusBar.Parent = content
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusBar
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 1, 0)
    statusLabel.Position = UDim2.new(0, 5, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: ALL INACTIVE"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 13
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusBar
    
    -- Connexions des boutons
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    speedToggle.MouseButton1Click:Connect(function()
        toggleSpeed()
    end)
    
    godToggle.MouseButton1Click:Connect(function()
        toggleGodMode()
    end)
    
    -- Validation automatique de l'input vitesse
    speedInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            updateSpeedValue()
        end
    end)
    
    -- Hover effects modernes
    addModernHoverEffect(closeBtn, Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 100, 100))
    addModernHoverEffect(speedToggle, Color3.fromRGB(40, 40, 40), Color3.fromRGB(60, 60, 60))
    addModernHoverEffect(godToggle, Color3.fromRGB(40, 40, 40), Color3.fromRGB(60, 60, 60))
end

-- Fonction pour créer une section moderne
function createModernSection(title, index, parent)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 35)
    section.Position = UDim2.new(0, 0, 0, index * 40)
    section.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 10)
    sectionCorner.Parent = section
    
    -- Titre de section
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 80, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    titleLabel.TextSize = 11
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    return section
end

-- Fonction pour créer un input moderne
function createModernInput(placeholder, text, parent, index)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, 70, 0, 25)
    input.Position = UDim2.new(0, 10 + index * 80, 0, 8)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    input.BorderSizePixel = 0
    input.Text = text
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 13
    input.Font = Enum.Font.Gotham
    input.PlaceholderText = placeholder
    input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    input.Parent = parent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    
    -- Border moderne
    local inputBorder = Instance.new("Frame")
    inputBorder.Size = UDim2.new(1, 2, 1, 2)
    inputBorder.Position = UDim2.new(0, -1, 0, -1)
    inputBorder.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    inputBorder.ZIndex = -1
    inputBorder.Parent = input
    
    local inputBorderCorner = Instance.new("UICorner")
    inputBorderCorner.CornerRadius = UDim.new(0, 7)
    inputBorderCorner.Parent = inputBorder
    
    return input
end

-- Fonction pour créer un toggle moderne
function createModernToggle(text, initialState, parent, index)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 70, 0, 25)
    toggle.Position = UDim2.new(0, 10 + index * 80, 0, 8)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.BorderSizePixel = 0
    toggle.Text = text .. " OFF"
    toggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggle.TextSize = 11
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = parent
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggle
    
    return toggle
end

-- Fonction pour créer un indicateur
function createIndicator(type, initialState, parent, index)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 60, 0, 25)
    indicator.Position = UDim2.new(0, 10 + index * 80, 0, 8)
    indicator.BackgroundColor3 = initialState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 60)
    indicator.BorderSizePixel = 0
    indicator.Parent = parent
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 6)
    indicatorCorner.Parent = indicator
    
    local indicatorText = Instance.new("TextLabel")
    indicatorText.Size = UDim2.new(1, 0, 1, 0)
    indicatorText.Position = UDim2.new(0, 0, 0, 0)
    indicatorText.BackgroundTransparency = 1
    indicatorText.Text = initialState and "ACTIF" or "INACTIF"
    indicatorText.TextColor3 = Color3.fromRGB(255, 255, 255)
    indicatorText.TextSize = 11
    indicatorText.Font = Enum.Font.GothamBold
    indicatorText.Parent = indicator
    
    return indicator
end

-- Fonction pour les effets de hover modernes
function addModernHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = hoverColor})
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = normalColor})
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
    local speedToggle = mainFrame:FindFirstChild("speedToggle")
    local speedIndicator = mainFrame:FindFirstChild("speedIndicator")
    
    if isSpeedActive then
        print("🚀 Speed activé")
        if speedToggle then 
            speedToggle.Text = "SPEED ON"
            speedToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        end
        if speedIndicator then
            speedIndicator.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            speedIndicator:FindFirstChild("TextLabel").Text = "ACTIF"
        end
    else
        print("⏹️ Speed désactivé")
        if speedToggle then 
            speedToggle.Text = "SPEED OFF"
            speedToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
        if speedIndicator then
            speedIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            speedIndicator:FindFirstChild("TextLabel").Text = "INACTIF"
        end
    end
    updateStatus()
    updateMiniIcons()
end

-- Fonction pour activer/désactiver le god mode
function toggleGodMode()
    isGodModeActive = not isGodModeActive
    local godToggle = mainFrame:FindFirstChild("godToggle")
    local godIndicator = mainFrame:FindFirstChild("godIndicator")
    
    if isGodModeActive then
        print("🛡️ God Mode activé")
        if godToggle then 
            godToggle.Text = "GOD ON"
            godToggle.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end
        if godIndicator then
            godIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            godIndicator:FindFirstChild("TextLabel").Text = "ACTIF"
        end
    else
        print("⏹️ God Mode désactivé")
        if godToggle then 
            godToggle.Text = "GOD OFF"
            godToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
        if godIndicator then
            godIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            godIndicator:FindFirstChild("TextLabel").Text = "INACTIF"
        end
    end
    updateStatus()
    updateMiniIcons()
end

-- Fonction pour créer les mini icônes
function createMiniIcons()
    -- Mini icône Speed
    local speedIcon = Instance.new("Frame")
    speedIcon.Size = UDim2.new(0, 40, 0, 40)
    speedIcon.Position = UDim2.new(1, -50, 1, -50)
    speedIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    speedIcon.BorderSizePixel = 0
    speedIcon.Visible = false
    speedIcon.Parent = screenGui
    
    local speedIconCorner = Instance.new("UICorner")
    speedIconCorner.CornerRadius = UDim.new(0, 8)
    speedIconCorner.Parent = speedIcon
    
    local speedIconText = Instance.new("TextLabel")
    speedIconText.Size = UDim2.new(1, 0, 1, 0)
    speedIconText.Position = UDim2.new(0, 0, 0, 0)
    speedIconText.BackgroundTransparency = 1
    speedIconText.Text = "⚡"
    speedIconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedIconText.TextSize = 20
    speedIconText.Font = Enum.Font.GothamBold
    speedIconText.Parent = speedIcon
    
    -- Mini icône God Mode
    local godIcon = Instance.new("Frame")
    godIcon.Size = UDim2.new(0, 40, 0, 40)
    godIcon.Position = UDim2.new(1, -100, 1, -50)
    godIcon.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    godIcon.BorderSizePixel = 0
    godIcon.Visible = false
    godIcon.Parent = screenGui
    
    local godIconCorner = Instance.new("UICorner")
    godIconCorner.CornerRadius = UDim.new(0, 8)
    godIconCorner.Parent = godIcon
    
    local godIconText = Instance.new("TextLabel")
    godIconText.Size = UDim2.new(1, 0, 1, 0)
    godIconText.Position = UDim2.new(0, 0, 0, 0)
    godIconText.BackgroundTransparency = 1
    godIconText.Text = "🛡️"
    godIconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    godIconText.TextSize = 20
    godIconText.Font = Enum.Font.GothamBold
    godIconText.Parent = godIcon
end

-- Fonction pour mettre à jour les mini icônes
function updateMiniIcons()
    local speedIcon = screenGui:FindFirstChild("speedIcon")
    local godIcon = screenGui:FindFirstChild("godIcon")
    
    if speedIcon then
        speedIcon.Visible = isSpeedActive
    end
    if godIcon then
        godIcon.Visible = isGodModeActive
    end
end

-- Fonction pour appliquer la vitesse une seule fois
function applySpeedOnce()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedValue
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
            status = status .. "SPEED + GOD ACTIVE"
        elseif isSpeedActive then
            status = status .. "SPEED ACTIVE"
        elseif isGodModeActive then
            status = status .. "GOD ACTIVE"
        else
            status = status .. "ALL INACTIVE"
        end
        statusLabel.Text = status
    end
end

-- Fonction pour mettre à jour le status
function updateStatus()
    local statusLabel = mainFrame:FindFirstChild("statusLabel")
    if statusLabel then
        local status = "Status: "
        if isSpeedActive and isGodModeActive then
            status = status .. "SPEED + GOD ACTIVE"
        elseif isSpeedActive then
            status = status .. "SPEED ACTIVE"
        elseif isGodModeActive then
            status = status .. "GOD ACTIVE"
        else
            status = status .. "ALL INACTIVE"
        end
        statusLabel.Text = status
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

-- Créer les mini icônes en bas à droite
createMiniIcons()

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
            end
            
            if isGodModeActive then
                char.Humanoid.MaxHealth = math.huge
                char.Humanoid.Health = math.huge
            end
        end
        task.wait(0.1) -- Force toutes les 0.1 secondes
    end
end)

print("Modern Mod Menu chargé! Design moderne et épuré")
