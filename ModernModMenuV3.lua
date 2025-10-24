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

function createGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModernModMenuV3"
    screenGui.Parent = player.PlayerGui
    
    -- Main container avec design moderne
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
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
    title.Text = "MODERN MOD V3"
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
    
    -- Section Debug
    local debugSection = createModernSection("DEBUG", 2, content)
    local debugBtn = createModernButton("INFO", Color3.fromRGB(100, 150, 255), debugSection, 0)
    
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
    
    debugBtn.MouseButton1Click:Connect(function()
        showDebugInfo()
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

-- Fonction pour activer/désactiver le god mode
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
        restoreHealth()
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

-- Fonction pour appliquer le god mode
function applyGodMode()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        -- Sauvegarder les valeurs originales si pas déjà fait
        if originalMaxHealth == 100 then
            originalMaxHealth = char.Humanoid.MaxHealth
            originalHealth = char.Humanoid.Health
        end
        char.Humanoid.MaxHealth = math.huge
        char.Humanoid.Health = math.huge
        print("🛡️ God Mode appliqué")
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
        statusLabel.Text = status
        print("🔧 DEBUG: Status mis à jour:", status)
    else
        print("❌ DEBUG: statusLabel non trouvé")
    end
end

-- Fonction de debug complète avec exploration des dossiers
function showDebugInfo()
    print("🔍 ========== DEBUG INFO V3 ==========")
    
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
    
    print("\n🔍 EXPLORATION WORKSPACE:")
    local workspaceFolders = workspace:GetChildren()
    print("  📁 Dossiers dans Workspace: " .. #workspaceFolders)
    for _, folder in ipairs(workspaceFolders) do
        if folder:IsA("Folder") then
            print("    📁 " .. folder.Name)
            local folderContents = folder:GetChildren()
            if #folderContents > 0 and #folderContents < 10 then
                for _, item in ipairs(folderContents) do
                    print("      📄 " .. item.Name .. " (" .. item.ClassName .. ")")
                end
            else
                print("      📄 " .. #folderContents .. " éléments")
            end
        end
    end
    
    print("\n🎮 MOD MENU:")
    print("  🚀 Speed: " .. (isSpeedActive and "ACTIF" or "INACTIF"))
    print("  🛡️ God Mode: " .. (isGodModeActive and "ACTIF" or "INACTIF"))
    print("  ⚙️ Vitesse configurée: " .. speedValue)
    
    print("\n🔍 MONSTRES PROCHES:")
    local monsters = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp and humanoid.Health > 0 then
                local dist = (char.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < 50 then
                    table.insert(monsters, {name = obj.Name, distance = dist, health = humanoid.Health})
                end
            end
        end
    end
    
    if #monsters > 0 then
        for _, monster in ipairs(monsters) do
            print("  👾 " .. monster.name .. " - " .. math.floor(monster.distance) .. "m - " .. math.floor(monster.health) .. " HP")
        end
    else
        print("  ❌ Aucun monstre proche")
    end
    
    print("🔍 ========== FIN DEBUG V3 ==========")
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

print("Modern Mod Menu V3 chargé! Indicateurs corrigés avec debug détaillé")
