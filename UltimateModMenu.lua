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
local isNoclipActive = false

local TOGGLE_KEY = Enum.KeyCode.Insert

-- Variables pour vitesse
local originalWalkSpeed = 16
local originalJumpPower = 50

function createGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltimateModMenu"
    screenGui.Parent = player.PlayerGui
    
    -- Main container
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 220)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Subtle border
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 1, 1, 1)
    border.Position = UDim2.new(0, -0.5, 0, -0.5)
    border.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    border.ZIndex = -1
    border.Parent = mainFrame
    
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, 12)
    borderCorner.Parent = border
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    -- Top right corner
    local topRightCorner = Instance.new("UICorner")
    topRightCorner.CornerRadius = UDim.new(0, 12)
    topRightCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "ULTIMATE MOD MENU"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    -- Content area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Speed section
    local speedSection = createSection("SPEED BOOST", 0, content)
    local speedInput = createInput("Vitesse", tostring(speedValue), speedSection, 0)
    local speedToggle = createToggle("SPEED", false, speedSection, 1)
    
    -- God mode section
    local godSection = createSection("GOD MODE", 1, content)
    local godToggle = createToggle("GOD", false, godSection, 0)
    local noclipToggle = createToggle("NOCLIP", false, godSection, 1)
    
    -- Control section
    local controlSection = createSection("CONTROLES", 2, content)
    local forceBtn = createButton("FORCER TOUT", Color3.fromRGB(50, 150, 50), controlSection, 0)
    local stopBtn = createButton("ARRÊTER TOUT", Color3.fromRGB(150, 50, 50), controlSection, 1)
    local infoBtn = createButton("INFO", Color3.fromRGB(50, 50, 150), controlSection, 2)
    
    -- Status bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 25)
    statusBar.Position = UDim2.new(0, 0, 1, -25)
    statusBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    statusBar.BorderSizePixel = 0
    statusBar.Parent = content
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusBar
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 1, 0)
    statusLabel.Position = UDim2.new(0, 5, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: TOUT INACTIF"
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
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
    
    noclipToggle.MouseButton1Click:Connect(function()
        toggleNoclip()
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
    addHoverEffect(closeBtn, Color3.fromRGB(40, 40, 40), Color3.fromRGB(60, 60, 60))
    addHoverEffect(speedToggle, Color3.fromRGB(40, 40, 40), Color3.fromRGB(60, 60, 60))
    addHoverEffect(godToggle, Color3.fromRGB(40, 40, 40), Color3.fromRGB(60, 60, 60))
    addHoverEffect(noclipToggle, Color3.fromRGB(40, 40, 40), Color3.fromRGB(60, 60, 60))
    addHoverEffect(forceBtn, Color3.fromRGB(50, 150, 50), Color3.fromRGB(40, 120, 40))
    addHoverEffect(stopBtn, Color3.fromRGB(150, 50, 50), Color3.fromRGB(120, 40, 40))
    addHoverEffect(infoBtn, Color3.fromRGB(50, 50, 150), Color3.fromRGB(40, 40, 120))
end

-- Fonction pour créer une section
function createSection(title, index, parent)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 50)
    section.Position = UDim2.new(0, 0, 0, index * 55)
    section.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 8)
    sectionCorner.Parent = section
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 100, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    return section
end

-- Fonction pour créer un input
function createInput(placeholder, text, parent, index)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0, 80, 0, 25)
    input.Position = UDim2.new(0, 10 + index * 90, 0, 20)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    input.BorderSizePixel = 0
    input.Text = text
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 14
    input.Font = Enum.Font.Gotham
    input.PlaceholderText = placeholder
    input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    input.Parent = parent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = input
    
    return input
end

-- Fonction pour créer un toggle
function createToggle(text, initialState, parent, index)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 80, 0, 25)
    toggle.Position = UDim2.new(0, 10 + index * 90, 0, 20)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.BorderSizePixel = 0
    toggle.Text = text .. " OFF"
    toggle.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggle.TextSize = 12
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = parent
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggle
    
    return toggle
end

-- Fonction pour créer un bouton
function createButton(text, color, parent, index)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 70, 0, 25)
    button.Position = UDim2.new(0, 10 + index * 80, 0, 20)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    return button
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
    local speedToggle = mainFrame:FindFirstChild("speedToggle")
    
    if isSpeedActive then
        print("🚀 Speed activé")
        if speedToggle then 
            speedToggle.Text = "SPEED ON"
            speedToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        end
    else
        print("⏹️ Speed désactivé")
        if speedToggle then 
            speedToggle.Text = "SPEED OFF"
            speedToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
    end
    updateStatus()
end

-- Fonction pour activer/désactiver le god mode
function toggleGodMode()
    isGodModeActive = not isGodModeActive
    local godToggle = mainFrame:FindFirstChild("godToggle")
    
    if isGodModeActive then
        print("🛡️ God Mode activé")
        if godToggle then 
            godToggle.Text = "GOD ON"
            godToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        end
    else
        print("⏹️ God Mode désactivé")
        if godToggle then 
            godToggle.Text = "GOD OFF"
            godToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
    end
    updateStatus()
end

-- Fonction pour activer/désactiver le noclip
function toggleNoclip()
    isNoclipActive = not isNoclipActive
    local noclipToggle = mainFrame:FindFirstChild("noclipToggle")
    
    if isNoclipActive then
        print("👻 Noclip activé")
        if noclipToggle then 
            noclipToggle.Text = "NOCLIP ON"
            noclipToggle.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
        end
    else
        print("⏹️ Noclip désactivé")
        if noclipToggle then 
            noclipToggle.Text = "NOCLIP OFF"
            noclipToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
    end
    updateStatus()
end

-- Fonction pour forcer tout
function forceAll()
    updateSpeedValue()
    applySpeedOnce()
    applyGodMode()
    applyNoclip()
    print("🔥 Tout forcé!")
end

-- Fonction pour arrêter tout
function stopAll()
    isSpeedActive = false
    isGodModeActive = false
    isNoclipActive = false
    
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = originalWalkSpeed
        char.Humanoid.JumpPower = originalJumpPower
        char.Humanoid.MaxHealth = 100
        char.Humanoid.Health = 100
        print("🐌 Tout restauré")
    end
    
    -- Reset des boutons
    local speedToggle = mainFrame:FindFirstChild("speedToggle")
    local godToggle = mainFrame:FindFirstChild("godToggle")
    local noclipToggle = mainFrame:FindFirstChild("noclipToggle")
    
    if speedToggle then 
        speedToggle.Text = "SPEED OFF"
        speedToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
    if godToggle then 
        godToggle.Text = "GOD OFF"
        godToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
    if noclipToggle then 
        noclipToggle.Text = "NOCLIP OFF"
        noclipToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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

-- Fonction pour appliquer le noclip
function applyNoclip()
    local char = player.Character
    if char then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
        print("👻 Noclip appliqué")
    end
end

-- Fonction pour mettre à jour le status
function updateStatus()
    local statusLabel = mainFrame:FindFirstChild("statusLabel")
    if statusLabel then
        local status = "Status: "
        if isSpeedActive and isGodModeActive and isNoclipActive then
            status = status .. "TOUT ACTIF"
        elseif isSpeedActive and isGodModeActive then
            status = status .. "SPEED + GOD ACTIFS"
        elseif isSpeedActive then
            status = status .. "SPEED ACTIF"
        elseif isGodModeActive then
            status = status .. "GOD ACTIF"
        elseif isNoclipActive then
            status = status .. "NOCLIP ACTIF"
        else
            status = status .. "TOUT INACTIF"
        end
        statusLabel.Text = status
    end
end

-- Fonction pour afficher les infos
function showInfo()
    print("📊 ULTIMATE MOD MENU")
    print("🎛️ Vitesse configurée: " .. speedValue)
    print("🚀 Speed: " .. (isSpeedActive and "ACTIF" or "INACTIF"))
    print("🛡️ God Mode: " .. (isGodModeActive and "ACTIF" or "INACTIF"))
    print("👻 Noclip: " .. (isNoclipActive and "ACTIF" or "INACTIF"))
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
            
            if isNoclipActive then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = false
                    end
                end
            end
        end
        task.wait(0.1) -- Force toutes les 0.1 secondes
    end
end)

print("Ultimate Mod Menu chargé! Interface minimaliste et professionnelle")
