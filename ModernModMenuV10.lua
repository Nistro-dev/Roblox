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
local originalMaxHealth = 100
local originalHealth = 100

-- Variables globales pour les éléments
local speedToggle = nil
local speedIndicator = nil
local godToggle = nil
local godIndicator = nil

-- Compteur de kills
local killCount = 0

-- Variables pour god mode
local godModeConnection = nil
local healthConnection = nil

function createGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernModMenuV10"
    screenGui.Parent = player.PlayerGui
    
    -- Main container avec design moderne
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 320)
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
    title.Text = "MODERN MOD V9"
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
    speedInput = createModernInput("Vitesse", tostring(speedValue), speedSection, 0)
    speedToggle = createModernToggle("SPEED", false, speedSection, 1)
    speedIndicator = createIndicator("SPEED", false, speedSection, 2)
    
    -- Section God Mode
    local godSection = createModernSection("GOD MODE", 1, content)
    godToggle = createModernToggle("GOD", false, godSection, 0)
    godIndicator = createIndicator("GOD", false, godSection, 1)
    
    -- Section Level
    local levelSection = createModernSection("LEVEL", 2, content)
    local levelBtn = createModernButton("+1 LVL", Color3.fromRGB(255, 200, 0), levelSection, 0)
    local levelDisplay = createModernButton("LVL: 150", Color3.fromRGB(100, 100, 100), levelSection, 1)
    
    -- Section Enemies
    local enemySection = createModernSection("ENEMIES", 3, content)
    local enemyBtn = createModernButton("1HP", Color3.fromRGB(255, 100, 100), enemySection, 0)
    local enemyBtn2 = createModernButton("0DMG", Color3.fromRGB(100, 255, 100), enemySection, 1)
    
    -- Section Debug
    local debugSection = createModernSection("DEBUG", 4, content)
    local debugBtn = createModernButton("INFO", Color3.fromRGB(100, 150, 255), debugSection, 0)
    local exploreBtn = createModernButton("EXPLORE", Color3.fromRGB(255, 150, 100), debugSection, 1)
    local modulesBtn = createModernButton("MODULES", Color3.fromRGB(150, 100, 255), debugSection, 2)
    local remotesBtn = createModernButton("REMOTES", Color3.fromRGB(255, 100, 255), debugSection, 3)
    local interceptBtn = createModernButton("INTERCEPT", Color3.fromRGB(255, 200, 0), debugSection, 4)
    local tryModifyBtn = createModernButton("TRY MOD", Color3.fromRGB(0, 255, 100), debugSection, 5)
    local analyzeBtn = createModernButton("ANALYZE", Color3.fromRGB(255, 100, 200), debugSection, 6)
    local testBtn = createModernButton("TEST", Color3.fromRGB(100, 200, 255), debugSection, 7)
    
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
    statusLabel.Text = "Status: ALL INACTIVE | Kills: 0"
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
    
    debugBtn.MouseButton1Click:Connect(function()
        showDebugInfo()
    end)
    
    exploreBtn.MouseButton1Click:Connect(function()
        exploreGameStructure()
    end)
    
    levelBtn.MouseButton1Click:Connect(function()
        addLevel()
    end)
    
    enemyBtn.MouseButton1Click:Connect(function()
        setEnemies1HP()
    end)
    
    enemyBtn2.MouseButton1Click:Connect(function()
        setEnemies0DMG()
    end)
    
    modulesBtn.MouseButton1Click:Connect(function()
        exploreModules()
    end)
    
    remotesBtn.MouseButton1Click:Connect(function()
        exploreRemotes()
    end)
    
    interceptBtn.MouseButton1Click:Connect(function()
        interceptRemotes()
    end)
    
    tryModifyBtn.MouseButton1Click:Connect(function()
        tryModifyData()
    end)
    
    analyzeBtn.MouseButton1Click:Connect(function()
        analyzeRemoteParameters()
    end)
    
    testBtn.MouseButton1Click:Connect(function()
        testRemoteEvents()
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
    addModernHoverEffect(debugBtn, Color3.fromRGB(100, 150, 255), Color3.fromRGB(120, 170, 255))
    addModernHoverEffect(exploreBtn, Color3.fromRGB(255, 150, 100), Color3.fromRGB(255, 170, 120))
    addModernHoverEffect(levelBtn, Color3.fromRGB(255, 200, 0), Color3.fromRGB(255, 220, 50))
    addModernHoverEffect(enemyBtn, Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 120, 120))
    addModernHoverEffect(enemyBtn2, Color3.fromRGB(100, 255, 100), Color3.fromRGB(120, 255, 120))
    addModernHoverEffect(modulesBtn, Color3.fromRGB(150, 100, 255), Color3.fromRGB(170, 120, 255))
    addModernHoverEffect(remotesBtn, Color3.fromRGB(255, 100, 255), Color3.fromRGB(255, 120, 255))
    addModernHoverEffect(interceptBtn, Color3.fromRGB(255, 200, 0), Color3.fromRGB(255, 220, 50))
    addModernHoverEffect(tryModifyBtn, Color3.fromRGB(0, 255, 100), Color3.fromRGB(50, 255, 120))
    addModernHoverEffect(analyzeBtn, Color3.fromRGB(255, 100, 200), Color3.fromRGB(255, 120, 220))
    addModernHoverEffect(testBtn, Color3.fromRGB(100, 200, 255), Color3.fromRGB(120, 220, 255))
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

-- Fonction pour créer un bouton moderne
function createModernButton(text, color, parent, index)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 60, 0, 25)
    button.Position = UDim2.new(0, 10 + index * 70, 0, 8)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 10
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    return button
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
    if newSpeed and newSpeed > 0 and newSpeed <= 5000 then
        speedValue = newSpeed
        print("✅ Vitesse mise à jour:", speedValue)
    else
        print("❌ Vitesse invalide (1-5000)")
        speedInput.Text = tostring(speedValue)
    end
end

-- Fonction pour activer/désactiver le speed
function toggleSpeed()
    isSpeedActive = not isSpeedActive
    print("🔧 DEBUG: toggleSpeed appelé, isSpeedActive =", isSpeedActive)
    
    if isSpeedActive then
        print("🚀 Speed activé")
        if speedToggle then 
            speedToggle.Text = "SPEED ON"
            speedToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            print("🔧 DEBUG: speedToggle mis à jour")
        else
            print("❌ DEBUG: speedToggle est nil")
        end
        if speedIndicator then
            speedIndicator.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            local textLabel = speedIndicator:FindFirstChild("TextLabel")
            if textLabel then
                textLabel.Text = "ACTIF"
                print("🔧 DEBUG: speedIndicator mis à jour vers ACTIF")
            else
                print("❌ DEBUG: TextLabel dans speedIndicator non trouvé")
            end
        else
            print("❌ DEBUG: speedIndicator est nil")
        end
    else
        print("⏹️ Speed désactivé")
        if speedToggle then 
            speedToggle.Text = "SPEED OFF"
            speedToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            print("🔧 DEBUG: speedToggle remis à OFF")
        end
        if speedIndicator then
            speedIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            local textLabel = speedIndicator:FindFirstChild("TextLabel")
            if textLabel then
                textLabel.Text = "INACTIF"
                print("🔧 DEBUG: speedIndicator mis à jour vers INACTIF")
            end
        end
    end
    updateStatus()
    updateMiniIcons()
end

-- Fonction pour activer/désactiver le god mode avec protection renforcée
function toggleGodMode()
    isGodModeActive = not isGodModeActive
    print("🔧 DEBUG: toggleGodMode appelé, isGodModeActive =", isGodModeActive)
    
    if isGodModeActive then
        print("🛡️ God Mode activé")
        if godToggle then 
            godToggle.Text = "GOD ON"
            godToggle.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            print("🔧 DEBUG: godToggle mis à jour")
        else
            print("❌ DEBUG: godToggle est nil")
        end
        if godIndicator then
            godIndicator.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            local textLabel = godIndicator:FindFirstChild("TextLabel")
            if textLabel then
                textLabel.Text = "ACTIF"
                print("🔧 DEBUG: godIndicator mis à jour vers ACTIF")
            else
                print("❌ DEBUG: TextLabel dans godIndicator non trouvé")
            end
        else
            print("❌ DEBUG: godIndicator est nil")
        end
        
        -- Activer la protection renforcée
        enableGodModeProtection()
    else
        print("⏹️ God Mode désactivé")
        if godToggle then 
            godToggle.Text = "GOD OFF"
            godToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            print("🔧 DEBUG: godToggle remis à OFF")
        end
        if godIndicator then
            godIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            local textLabel = godIndicator:FindFirstChild("TextLabel")
            if textLabel then
                textLabel.Text = "INACTIF"
                print("🔧 DEBUG: godIndicator mis à jour vers INACTIF")
            end
        end
        
        -- Désactiver la protection
        disableGodModeProtection()
        restoreHealth()
    end
    updateStatus()
    updateMiniIcons()
end

-- Fonction pour activer la protection god mode
function enableGodModeProtection()
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") then
        print("❌ Personnage non trouvé pour la protection")
        return
    end
    
    local humanoid = char.Humanoid
    
    -- Sauvegarder les valeurs originales
    if originalMaxHealth == 100 then
        originalMaxHealth = humanoid.MaxHealth
        originalHealth = humanoid.Health
    end
    
    -- Déconnecter les anciennes connexions
    if godModeConnection then
        godModeConnection:Disconnect()
    end
    if healthConnection then
        healthConnection:Disconnect()
    end
    
    -- Protection continue avec RunService
    godModeConnection = RunService.Heartbeat:Connect(function()
        if isGodModeActive and humanoid then
            humanoid.MaxHealth = 999999
            humanoid.Health = 999999
        end
    end)
    
    -- Protection contre les changements de santé
    healthConnection = humanoid.HealthChanged:Connect(function(newHealth)
        if isGodModeActive then
            if newHealth < 999999 then
                humanoid.Health = 999999
                print("🛡️ DEBUG: Santé restaurée à 999999 (était " .. newHealth .. ")")
            end
        end
    end)
    
    print("🛡️ Protection God Mode activée avec interception des dégâts")
end

-- Fonction pour désactiver la protection god mode
function disableGodModeProtection()
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    if healthConnection then
        healthConnection:Disconnect()
        healthConnection = nil
    end
    print("🛡️ Protection God Mode désactivée")
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
        print("🔧 DEBUG: speedIcon visible =", isSpeedActive)
    end
    if godIcon then
        godIcon.Visible = isGodModeActive
        print("🔧 DEBUG: godIcon visible =", isGodModeActive)
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

-- Fonction pour restaurer la santé normale
function restoreHealth()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.MaxHealth = originalMaxHealth
        char.Humanoid.Health = originalHealth
        print("❤️ Santé restaurée:", originalHealth .. "/" .. originalMaxHealth)
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
        status = status .. " | Kills: " .. killCount
        statusLabel.Text = status
        print("🔧 DEBUG: Status mis à jour:", status)
    else
        print("❌ DEBUG: statusLabel non trouvé")
    end
end

-- Fonction pour écouter les événements de mort d'ennemis
function setupKillListener()
    print("🔍 DEBUG: Configuration de l'écoute des kills...")
    
    -- Écouter les changements de santé de tous les modèles
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Écouter la mort
                humanoid.Died:Connect(function()
                    print("💀 DEBUG: Ennemi mort détecté:", obj.Name)
                    killCount = killCount + 1
                    updateStatus()
                    
                    -- Debug des événements
                    print("🔍 DEBUG: Événements disponibles sur", obj.Name)
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("BindableEvent") or child:IsA("RemoteEvent") then
                            print("  📡 Événement trouvé:", child.Name, "(" .. child.ClassName .. ")")
                        end
                    end
                end)
                
                -- Écouter les changements de santé
                humanoid.HealthChanged:Connect(function(health)
                    if health <= 0 then
                        print("💀 DEBUG: Santé de", obj.Name, "est à 0")
                    end
                end)
            end
        end
    end
    
    -- Écouter les nouveaux objets ajoutés
    workspace.ChildAdded:Connect(function(obj)
        if obj:IsA("Model") then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Died:Connect(function()
                    print("💀 DEBUG: Nouvel ennemi mort:", obj.Name)
                    killCount = killCount + 1
                    updateStatus()
                end)
            end
        end
    end)
end

-- Fonction pour explorer complètement la structure du jeu
function exploreGameStructure()
    print("🔍 ========== EXPLORATION COMPLÈTE DU JEU ==========")
    
    -- Explorer le joueur
    print("\n👤 EXPLORATION DU JOUEUR:")
    print("  📁 Nom:", player.Name)
    print("  📁 DisplayName:", player.DisplayName)
    print("  📁 UserId:", player.UserId)
    
    local playerChildren = player:GetChildren()
    print("  📋 Enfants du joueur (" .. #playerChildren .. "):")
    for _, child in ipairs(playerChildren) do
        print("    📄 " .. child.Name .. " (" .. child.ClassName .. ")")
        
        -- Explorer les enfants des enfants
        if child:IsA("Folder") or child:IsA("Configuration") then
            local subChildren = child:GetChildren()
            if #subChildren > 0 and #subChildren < 20 then
                for _, subChild in ipairs(subChildren) do
                    print("      📄 " .. subChild.Name .. " (" .. subChild.ClassName .. ")")
                    
                    -- Explorer les valeurs
                    if subChild:IsA("IntValue") or subChild:IsA("StringValue") or subChild:IsA("NumberValue") or subChild:IsA("BoolValue") then
                        print("        📊 Valeur: " .. tostring(subChild.Value))
                    end
                end
            else
                print("      📄 " .. #subChildren .. " éléments")
            end
        end
    end
    
    -- Explorer Workspace
    print("\n🌍 EXPLORATION WORKSPACE:")
    local workspaceChildren = workspace:GetChildren()
    print("  📁 Enfants de Workspace (" .. #workspaceChildren .. "):")
    for _, child in ipairs(workspaceChildren) do
        print("    📄 " .. child.Name .. " (" .. child.ClassName .. ")")
        
        -- Explorer les dossiers importants
        if child:IsA("Folder") then
            local folderChildren = child:GetChildren()
            print("      📁 " .. #folderChildren .. " éléments dans " .. child.Name)
            
            -- Explorer les premiers éléments
            for i = 1, math.min(10, #folderChildren) do
                local item = folderChildren[i]
                print("        📄 " .. item.Name .. " (" .. item.ClassName .. ")")
                
                -- Explorer les valeurs des objets
                if item:IsA("IntValue") or item:IsA("StringValue") or item:IsA("NumberValue") or item:IsA("BoolValue") then
                    print("          📊 Valeur: " .. tostring(item.Value))
                end
                
                -- Explorer les propriétés des modèles
                if item:IsA("Model") then
                    local modelChildren = item:GetChildren()
                    print("          📁 " .. #modelChildren .. " éléments dans " .. item.Name)
                    
                    -- Chercher des Humanoids
                    for _, modelChild in ipairs(modelChildren) do
                        if modelChild:IsA("Humanoid") then
                            print("            👤 Humanoid trouvé!")
                            print("              ❤️ Santé: " .. modelChild.Health .. "/" .. modelChild.MaxHealth)
                            print("              🚀 Vitesse: " .. modelChild.WalkSpeed)
                        end
                    end
                end
            end
            
            if #folderChildren > 10 then
                print("        📄 ... et " .. (#folderChildren - 10) .. " autres éléments")
            end
        end
    end
    
    print("🔍 ========== FIN EXPLORATION ==========")
end

-- Fonction de debug complète avec exploration des dossiers
function showDebugInfo()
    print("🔍 ========== DEBUG INFO V7 ==========")
    
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        print("👤 PERSONNAGE:")
        print("  🚀 Vitesse: " .. humanoid.WalkSpeed)
        print("  ❤️ Santé: " .. humanoid.Health .. "/" .. humanoid.MaxHealth)
        print("  🦘 Saut: " .. humanoid.JumpPower)
        print("  🏃 État: " .. tostring(humanoid:GetState()))
    else
        print("❌ Personnage non trouvé")
    end
    
    print("\n🎒 INVENTAIRE:")
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tools = backpack:GetChildren()
        print("  📦 Outils dans le sac: " .. #tools)
        for _, tool in ipairs(tools) do
            if tool:IsA("Tool") then
                print("    🔧 " .. tool.Name)
            end
        end
    end
    
    print("\n⚔️ ARMES ÉQUIPÉES:")
    if char then
        local tools = char:GetChildren()
        for _, tool in ipairs(tools) do
            if tool:IsA("Tool") then
                print("    ⚔️ " .. tool.Name)
                -- Vérifier les propriétés de l'arme
                if tool:FindFirstChild("Damage") then
                    print("      💥 Dégâts: " .. tool.Damage.Value)
                end
                if tool:FindFirstChild("Cooldown") then
                    print("      ⏱️ Cooldown: " .. tool.Cooldown.Value)
                end
            end
        end
    end
    
    print("\n📊 EXPLORATION LEADERSTATS:")
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        print("  📁 Dossier leaderstats trouvé!")
        local stats = leaderstats:GetChildren()
        print("  📋 Nombre de stats: " .. #stats)
        for _, stat in ipairs(stats) do
            if stat:IsA("IntValue") or stat:IsA("StringValue") or stat:IsA("NumberValue") then
                print("    📊 " .. stat.Name .. " = " .. tostring(stat.Value))
            elseif stat:IsA("Folder") then
                print("    📁 " .. stat.Name .. " (dossier)")
                local subItems = stat:GetChildren()
                for _, subItem in ipairs(subItems) do
                    if subItem:IsA("IntValue") or subItem:IsA("StringValue") or subItem:IsA("NumberValue") then
                        print("      📊 " .. subItem.Name .. " = " .. tostring(subItem.Value))
                    end
                end
            end
        end
    else
        print("  ❌ Aucun dossier leaderstats trouvé")
    end
    
    print("\n🎁 EFFETS DE POSITION:")
    local effects = char and char:FindFirstChild("Effects") or nil
    if effects then
        local activeEffects = effects:GetChildren()
        print("  ✨ Effets actifs: " .. #activeEffects)
        for _, effect in ipairs(activeEffects) do
            print("    🌟 " .. effect.Name)
        end
    else
        print("  ❌ Aucun effet de position trouvé")
    end
    
    print("\n🎮 MOD MENU:")
    print("  🚀 Speed: " .. (isSpeedActive and "ACTIF" or "INACTIF"))
    print("  🛡️ God Mode: " .. (isGodModeActive and "ACTIF" or "INACTIF"))
    print("  ⚙️ Vitesse configurée: " .. speedValue)
    print("  💀 Kills comptés: " .. killCount)
    
    print("🔍 ========== FIN DEBUG V7 ==========")
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

-- Configurer l'écoute des kills
setupKillListener()

-- Intercepter automatiquement les RemoteEvents au démarrage
interceptRemotes()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == TOGGLE_KEY then
        if mainFrame.Visible then
            mainFrame.Visible = false
        else
            mainFrame.Visible = true
        end
    end
end)

-- Boucle de force continue avec god mode réaliste
task.spawn(function()
    while true do
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            if isSpeedActive then
                char.Humanoid.WalkSpeed = speedValue
            end
        end
        task.wait(0.1) -- Force toutes les 0.1 secondes
    end
end)

-- Fonction pour ajouter +1 niveau
function addLevel()
    print("📈 Tentative d'augmentation du niveau...")
    
    -- Méthode 1: Modifier directement la valeur
    local dataFolder = player:FindFirstChild("Data")
    if dataFolder then
        local levelValue = dataFolder:FindFirstChild("Level")
        if levelValue and levelValue:IsA("IntValue") then
            local currentLevel = levelValue.Value
            levelValue.Value = currentLevel + 1
            print("📈 Niveau augmenté: " .. currentLevel .. " → " .. levelValue.Value)
            
            -- Mettre à jour l'affichage
            local levelDisplay = mainFrame:FindFirstChild("levelDisplay")
            if levelDisplay then
                levelDisplay.Text = "LVL: " .. levelValue.Value
            end
        else
            print("❌ Level IntValue non trouvé")
        end
    else
        print("❌ Dossier Data non trouvé")
    end
    
    -- Méthode 2: Utiliser les RemoteEvents
    local replicatedStorage = game:GetService("ReplicatedStorage")
    if replicatedStorage then
        local shared = replicatedStorage:FindFirstChild("Shared")
        if shared then
            local data = shared:FindFirstChild("Data")
            if data then
                print("🔍 Exploration des RemoteEvents Data...")
                for _, remote in ipairs(data:GetChildren()) do
                    print("  📡 " .. remote.Name .. " (" .. remote.ClassName .. ")")
                end
            end
        end
    end
end

-- Fonction pour mettre tous les ennemis à 1 HP
function setEnemies1HP()
    print("👾 Mise des ennemis à 1 HP...")
    local enemies = 0
    
    -- Méthode 1: Explorer Workspace/Dungeon/Enemies
    local dungeon = workspace:FindFirstChild("Dungeon")
    if dungeon then
        local enemiesFolder = dungeon:FindFirstChild("Enemies")
        if enemiesFolder then
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                if enemy:IsA("Model") then
                    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.MaxHealth = 1
                        humanoid.Health = 1
                        enemies = enemies + 1
                        print("  👾 " .. enemy.Name .. " → 1 HP")
                    end
                end
            end
        end
    end
    
    -- Méthode 2: Explorer tous les modèles dans Workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 1 then
                humanoid.MaxHealth = 1
                humanoid.Health = 1
                enemies = enemies + 1
                print("  👾 " .. obj.Name .. " → 1 HP")
            end
        end
    end
    
    -- Méthode 3: Utiliser les RemoteEvents pour modifier les ennemis
    local replicatedStorage = game:GetService("ReplicatedStorage")
    if replicatedStorage then
        local dungeon = replicatedStorage:FindFirstChild("Dungeon")
        if dungeon then
            local attackAttempt = dungeon:FindFirstChild("AttackAttempt")
            if attackAttempt then
                print("🔍 RemoteEvent AttackAttempt trouvé - tentative d'utilisation...")
                -- Essayer d'utiliser le RemoteEvent
                pcall(function()
                    attackAttempt:FireServer("modify_enemies", "1hp")
                end)
            end
        end
    end
    
    print("✅ " .. enemies .. " ennemis mis à 1 HP")
end

-- Fonction pour mettre tous les ennemis à 0 dégâts
function setEnemies0DMG()
    print("⚔️ Mise des ennemis à 0 dégâts...")
    local enemies = 0
    
    -- Méthode 1: Explorer tous les modèles dans Workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Chercher des propriétés de dégâts
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        if string.find(string.lower(child.Name), "damage") or 
                           string.find(string.lower(child.Name), "dmg") or
                           string.find(string.lower(child.Name), "attack") then
                            child.Value = 0
                            enemies = enemies + 1
                            print("  ⚔️ " .. obj.Name .. "." .. child.Name .. " → 0")
                        end
                    end
                end
            end
        end
    end
    
    -- Méthode 2: Utiliser les RemoteEvents pour modifier les dégâts
    local replicatedStorage = game:GetService("ReplicatedStorage")
    if replicatedStorage then
        local dungeon = replicatedStorage:FindFirstChild("Dungeon")
        if dungeon then
            local attackAttempt = dungeon:FindFirstChild("AttackAttempt")
            if attackAttempt then
                print("🔍 RemoteEvent AttackAttempt trouvé - tentative de modification des dégâts...")
                -- Essayer d'utiliser le RemoteEvent pour modifier les dégâts
                pcall(function()
                    attackAttempt:FireServer("modify_damage", 0)
                end)
            end
        end
    end
    
    print("✅ " .. enemies .. " propriétés de dégâts mises à 0")
end

-- Fonction pour explorer les modules
function exploreModules()
    print("🔍 ========== EXPLORATION DÉTAILLÉE MODULES ==========")
    
    local replicatedStorage = game:GetService("ReplicatedStorage")
    if replicatedStorage then
        print("📦 ReplicatedStorage trouvé")
        
        -- Explorer Dungeon/Modules
        local dungeon = replicatedStorage:FindFirstChild("Dungeon")
        if dungeon then
            print("🏰 Dungeon trouvé")
            local modules = dungeon:FindFirstChild("Modules")
            if modules then
                print("📘 Modules trouvés dans Dungeon:")
                local moduleChildren = modules:GetChildren()
                for _, module in ipairs(moduleChildren) do
                    print("  📘 " .. module.Name .. " (" .. module.ClassName .. ")")
                    
                    if module:IsA("ModuleScript") then
                        print("    🔧 ModuleScript - contient du code Lua")
                        print("    💡 Peut être utilisé avec require()")
                    elseif module:IsA("Folder") then
                        local subModules = module:GetChildren()
                        print("    📁 " .. #subModules .. " sous-modules")
                        for i = 1, math.min(5, #subModules) do
                            local subModule = subModules[i]
                            print("      📘 " .. subModule.Name .. " (" .. subModule.ClassName .. ")")
                        end
                    end
                end
            else
                print("❌ Dossier Modules non trouvé dans Dungeon")
            end
        else
            print("❌ Aucun dossier Dungeon")
        end
        
        -- Explorer Shared/Modules
        local shared = replicatedStorage:FindFirstChild("Shared")
        if shared then
            print("🤝 Shared trouvé")
            local modules = shared:FindFirstChild("Modules")
            if modules then
                print("📘 Modules trouvés dans Shared:")
                local moduleChildren = modules:GetChildren()
                for _, module in ipairs(moduleChildren) do
                    print("  📘 " .. module.Name .. " (" .. module.ClassName .. ")")
                    
                    if module:IsA("ModuleScript") then
                        print("    🔧 ModuleScript - contient du code Lua")
                        print("    💡 Peut être utilisé avec require()")
                    elseif module:IsA("Folder") then
                        local subModules = module:GetChildren()
                        print("    📁 " .. #subModules .. " sous-modules")
                        for i = 1, math.min(5, #subModules) do
                            local subModule = subModules[i]
                            print("      📘 " .. subModule.Name .. " (" .. subModule.ClassName .. ")")
                        end
                    end
                end
            else
                print("❌ Dossier Modules non trouvé dans Shared")
            end
        else
            print("❌ Aucun dossier Shared")
        end
        
        -- Explorer tous les ModuleScripts dans ReplicatedStorage
        print("\n🔍 Recherche de tous les ModuleScripts dans ReplicatedStorage...")
        local allModules = {}
        for _, obj in ipairs(replicatedStorage:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                table.insert(allModules, obj)
            end
        end
        
        if #allModules > 0 then
            print("📘 Tous les ModuleScripts trouvés:")
            for _, module in ipairs(allModules) do
                local path = module:GetFullName()
                print("  📘 " .. path .. " (ModuleScript)")
            end
        else
            print("❌ Aucun ModuleScript trouvé")
        end
    else
        print("❌ ReplicatedStorage non trouvé")
    end
    
    print("🔍 ========== FIN EXPLORATION DÉTAILLÉE MODULES ==========")
end

-- Fonction pour explorer les remotes
function exploreRemotes()
    print("🔍 ========== EXPLORATION DÉTAILLÉE REMOTES ==========")
    
    local replicatedStorage = game:GetService("ReplicatedStorage")
    if replicatedStorage then
        print("📦 ReplicatedStorage trouvé")
        
        -- Explorer Dungeon/Remotes
        local dungeon = replicatedStorage:FindFirstChild("Dungeon")
        if dungeon then
            print("🏰 Dungeon trouvé")
            local remotes = dungeon:FindFirstChild("Remotes")
            if remotes then
                print("📡 Remotes trouvés dans Dungeon:")
                local remoteChildren = remotes:GetChildren()
                for _, remote in ipairs(remoteChildren) do
                    print("  📡 " .. remote.Name .. " (" .. remote.ClassName .. ")")
                    
                    if remote:IsA("RemoteEvent") then
                        print("    🔥 RemoteEvent - peut être utilisé avec FireServer()")
                        print("    💡 Exemple: " .. remote.Name .. ":FireServer(paramètres)")
                    elseif remote:IsA("RemoteFunction") then
                        print("    ⚡ RemoteFunction - peut être utilisé avec InvokeServer()")
                        print("    💡 Exemple: " .. remote.Name .. ":InvokeServer(paramètres)")
                    elseif remote:IsA("Folder") then
                        local subRemotes = remote:GetChildren()
                        print("    📁 " .. #subRemotes .. " sous-remotes")
                        for i = 1, math.min(5, #subRemotes) do
                            local subRemote = subRemotes[i]
                            print("      📡 " .. subRemote.Name .. " (" .. subRemote.ClassName .. ")")
                        end
                    end
                end
            else
                print("❌ Dossier Remotes non trouvé dans Dungeon")
            end
        else
            print("❌ Aucun dossier Dungeon")
        end
        
        -- Explorer Shared/Remotes
        local shared = replicatedStorage:FindFirstChild("Shared")
        if shared then
            print("🤝 Shared trouvé")
            local remotes = shared:FindFirstChild("Remotes")
            if remotes then
                print("📡 Remotes trouvés dans Shared:")
                local remoteChildren = remotes:GetChildren()
                for _, remote in ipairs(remoteChildren) do
                    print("  📡 " .. remote.Name .. " (" .. remote.ClassName .. ")")
                    
                    if remote:IsA("RemoteEvent") then
                        print("    🔥 RemoteEvent - peut être utilisé avec FireServer()")
                    elseif remote:IsA("RemoteFunction") then
                        print("    ⚡ RemoteFunction - peut être utilisé avec InvokeServer()")
                    end
                end
            else
                print("❌ Dossier Remotes non trouvé dans Shared")
            end
        else
            print("❌ Aucun dossier Shared")
        end
        
        -- Explorer tous les RemoteEvents dans ReplicatedStorage
        print("\n🔍 Recherche de tous les RemoteEvents dans ReplicatedStorage...")
        local allRemotes = {}
        for _, obj in ipairs(replicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(allRemotes, obj)
            end
        end
        
        if #allRemotes > 0 then
            print("📡 Tous les RemoteEvents/RemoteFunctions trouvés:")
            for _, remote in ipairs(allRemotes) do
                local path = remote:GetFullName()
                print("  📡 " .. path .. " (" .. remote.ClassName .. ")")
            end
        else
            print("❌ Aucun RemoteEvent/RemoteFunction trouvé")
        end
    else
        print("❌ ReplicatedStorage non trouvé")
    end
    
    print("🔍 ========== FIN EXPLORATION DÉTAILLÉE REMOTES ==========")
end

-- Fonction pour intercepter les RemoteEvents
function interceptRemotes()
    print("🔍 ========== INTERCEPTION REMOTES ==========")
    
    local replicatedStorage = game:GetService("ReplicatedStorage")
    if replicatedStorage then
        local dungeon = replicatedStorage:FindFirstChild("Dungeon")
        if dungeon then
            local remotes = dungeon:FindFirstChild("Remotes")
            if remotes then
                print("📡 Interception des RemoteEvents...")
                
                -- Intercepter AttackAttempt
                local attackAttempt = remotes:FindFirstChild("AttackAttempt")
                if attackAttempt then
                    attackAttempt.OnClientEvent:Connect(function(...)
                        print("🔥 AttackAttempt reçu:", ...)
                    end)
                    print("✅ AttackAttempt intercepté")
                end
                
                -- Intercepter EnemyAdded
                local enemyAdded = remotes:FindFirstChild("EnemyAdded")
                if enemyAdded then
                    enemyAdded.OnClientEvent:Connect(function(...)
                        print("👾 EnemyAdded reçu:", ...)
                    end)
                    print("✅ EnemyAdded intercepté")
                end
                
                -- Intercepter EnemyRemoved
                local enemyRemoved = remotes:FindFirstChild("EnemyRemoved")
                if enemyRemoved then
                    enemyRemoved.OnClientEvent:Connect(function(...)
                        print("💀 EnemyRemoved reçu:", ...)
                    end)
                    print("✅ EnemyRemoved intercepté")
                end
                
                -- Intercepter StartDungeon
                local startDungeon = remotes:FindFirstChild("StartDungeon")
                if startDungeon then
                    startDungeon.OnClientEvent:Connect(function(...)
                        print("🏰 StartDungeon reçu:", ...)
                    end)
                    print("✅ StartDungeon intercepté")
                end
            end
        end
    end
    
    print("🔍 ========== FIN INTERCEPTION ==========")
end

-- Fonction pour essayer de modifier les données via RemoteEvents
function tryModifyData()
    print("🔍 ========== TENTATIVE MODIFICATION DONNÉES ==========")
    
    local replicatedStorage = game:GetService("ReplicatedStorage")
    if replicatedStorage then
        local shared = replicatedStorage:FindFirstChild("Shared")
        if shared then
            local data = shared:FindFirstChild("Data")
            if data then
                print("📊 Tentative de modification via RemoteEvents Data...")
                for _, remote in ipairs(data:GetChildren()) do
                    if remote:IsA("RemoteEvent") then
                        print("  📡 " .. remote.Name .. " - tentative d'utilisation...")
                        pcall(function()
                            remote:FireServer("level_up", 1)
                        end)
                    elseif remote:IsA("RemoteFunction") then
                        print("  ⚡ " .. remote.Name .. " - tentative d'utilisation...")
                        pcall(function()
                            remote:InvokeServer("get_level")
                        end)
                    end
                end
            end
        end
    end
    
    print("🔍 ========== FIN TENTATIVE ==========")
end

-- Fonction pour analyser les paramètres des RemoteEvents
function analyzeRemoteParameters()
    print("🔍 ========== ANALYSE PARAMÈTRES REMOTES ==========")
    
    local replicatedStorage = game:GetService("ReplicatedStorage")
    if replicatedStorage then
        local dungeon = replicatedStorage:FindFirstChild("Dungeon")
        if dungeon then
            local remotes = dungeon:FindFirstChild("Remotes")
            if remotes then
                print("📡 Analyse des RemoteEvents dans Dungeon:")
                for _, remote in ipairs(remotes:GetChildren()) do
                    if remote:IsA("RemoteEvent") then
                        print("  🔥 " .. remote.Name .. " (RemoteEvent)")
                        print("    💡 Utilisation: " .. remote.Name .. ":FireServer(paramètres)")
                        print("    📝 Exemple: " .. remote.Name .. ":FireServer('test', 123, true)")
                    elseif remote:IsA("RemoteFunction") then
                        print("  ⚡ " .. remote.Name .. " (RemoteFunction)")
                        print("    💡 Utilisation: " .. remote.Name .. ":InvokeServer(paramètres)")
                        print("    📝 Exemple: local result = " .. remote.Name .. ":InvokeServer('get_data')")
                    end
                end
            end
        end
        
        local shared = replicatedStorage:FindFirstChild("Shared")
        if shared then
            local remotes = shared:FindFirstChild("Remotes")
            if remotes then
                print("📡 Analyse des RemoteEvents dans Shared:")
                for _, remote in ipairs(remotes:GetChildren()) do
                    if remote:IsA("RemoteEvent") then
                        print("  🔥 " .. remote.Name .. " (RemoteEvent)")
                        print("    💡 Utilisation: " .. remote.Name .. ":FireServer(paramètres)")
                    elseif remote:IsA("RemoteFunction") then
                        print("  ⚡ " .. remote.Name .. " (RemoteFunction)")
                        print("    💡 Utilisation: " .. remote.Name .. ":InvokeServer(paramètres)")
                    end
                end
            end
        end
    end
    
    print("🔍 ========== FIN ANALYSE PARAMÈTRES ==========")
end

-- Fonction pour tester les RemoteEvents
function testRemoteEvents()
    print("🔍 ========== TEST REMOTES ==========")
    
    local replicatedStorage = game:GetService("ReplicatedStorage")
    if replicatedStorage then
        local dungeon = replicatedStorage:FindFirstChild("Dungeon")
        if dungeon then
            local remotes = dungeon:FindFirstChild("Remotes")
            if remotes then
                print("🧪 Test des RemoteEvents...")
                
                -- Tester AttackAttempt
                local attackAttempt = remotes:FindFirstChild("AttackAttempt")
                if attackAttempt then
                    print("  🔥 Test AttackAttempt...")
                    pcall(function()
                        attackAttempt:FireServer("test_attack", 100, "player")
                    end)
                    print("  ✅ AttackAttempt testé")
                end
                
                -- Tester StartDungeon
                local startDungeon = remotes:FindFirstChild("StartDungeon")
                if startDungeon then
                    print("  🏰 Test StartDungeon...")
                    pcall(function()
                        startDungeon:FireServer("test_dungeon")
                    end)
                    print("  ✅ StartDungeon testé")
                end
                
                -- Tester RequestEnemies
                local requestEnemies = remotes:FindFirstChild("RequestEnemies")
                if requestEnemies then
                    print("  👾 Test RequestEnemies...")
                    pcall(function()
                        local result = requestEnemies:InvokeServer()
                        print("  📊 Résultat RequestEnemies:", result)
                    end)
                    print("  ✅ RequestEnemies testé")
                end
            end
        end
    end
    
    print("🔍 ========== FIN TEST REMOTES ==========")
end

print("Modern Mod Menu V10 chargé! Exploration détaillée des RemoteEvents et Modules")
