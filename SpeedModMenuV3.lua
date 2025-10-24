local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local screenGui = nil
local mainFrame = nil
local speedInput = nil
local speedValue = 50

local TOGGLE_KEY = Enum.KeyCode.Insert

-- Variables pour vitesse
local originalWalkSpeed = 16
local originalJumpPower = 50

function createGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedModMenuV3"
    screenGui.Parent = player.PlayerGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 120)
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
    title.Text = "SPEED MOD V3"
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
    
    -- Action buttons
    local speedOnlyBtn = Instance.new("TextButton")
    speedOnlyBtn.Size = UDim2.new(0, 80, 0, 35)
    speedOnlyBtn.Position = UDim2.new(0, 20, 0, 90)
    speedOnlyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    speedOnlyBtn.BorderSizePixel = 0
    speedOnlyBtn.Text = "APPLIQUER"
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
    restoreBtn.Text = "RESTAURER"
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
    
    -- Connexions des boutons
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    speedOnlyBtn.MouseButton1Click:Connect(function()
        applySpeed()
    end)
    
    restoreBtn.MouseButton1Click:Connect(function()
        restoreSpeed()
    end)
    
    infoBtn.MouseButton1Click:Connect(function()
        showInfo()
    end)
    
    -- Validation automatique de l'input vitesse
    speedInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            applySpeed()
        end
    end)
    
    -- Hover effects
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

-- Fonction pour appliquer la vitesse avec debug
function applySpeed()
    print("🔧 Tentative d'application de la vitesse...")
    
    local newSpeed = tonumber(speedInput.Text)
    print("📊 Vitesse demandée:", newSpeed)
    
    if newSpeed and newSpeed > 0 and newSpeed <= 200 then
        speedValue = newSpeed
        print("✅ Vitesse valide:", speedValue)
        
        local char = player.Character
        print("👤 Personnage trouvé:", char and "OUI" or "NON")
        
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            print("🤖 Humanoid trouvé:", humanoid and "OUI" or "NON")
            
            if humanoid then
                print("🚀 Ancienne vitesse:", humanoid.WalkSpeed)
                humanoid.WalkSpeed = speedValue
                humanoid.JumpPower = speedValue * 2
                print("✅ Nouvelle vitesse appliquée:", humanoid.WalkSpeed)
                print("✅ Nouveau saut appliqué:", humanoid.JumpPower)
                
                -- Animation de confirmation
                local tween = TweenService:Create(speedInput, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 150, 50)})
                tween:Play()
                tween.Completed:Connect(function()
                    local tween2 = TweenService:Create(speedInput, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
                    tween2:Play()
                end)
            else
                print("❌ Humanoid non trouvé dans le personnage")
            end
        else
            print("❌ Personnage non trouvé")
        end
    else
        print("❌ Vitesse invalide (1-200)")
        speedInput.Text = tostring(speedValue)
        
        -- Animation d'erreur
        local tween = TweenService:Create(speedInput, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(150, 50, 50)})
        tween:Play()
        tween.Completed:Connect(function()
            local tween2 = TweenService:Create(speedInput, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
            tween2:Play()
        end)
    end
end

-- Fonction pour restaurer la vitesse normale
function restoreSpeed()
    print("🔄 Restauration de la vitesse normale...")
    
    local char = player.Character
    print("👤 Personnage trouvé:", char and "OUI" or "NON")
    
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        print("🤖 Humanoid trouvé:", humanoid and "OUI" or "NON")
        
        if humanoid then
            print("🚀 Ancienne vitesse:", humanoid.WalkSpeed)
            humanoid.WalkSpeed = originalWalkSpeed
            humanoid.JumpPower = originalJumpPower
            print("✅ Vitesse restaurée:", humanoid.WalkSpeed)
            print("✅ Saut restauré:", humanoid.JumpPower)
            
            -- Animation de confirmation
            local tween = TweenService:Create(restoreBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 200, 100)})
            tween:Play()
            tween.Completed:Connect(function()
                local tween2 = TweenService:Create(restoreBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(150, 50, 50)})
                tween2:Play()
            end)
        else
            print("❌ Humanoid non trouvé dans le personnage")
        end
    else
        print("❌ Personnage non trouvé")
    end
end

-- Fonction pour afficher les infos
function showInfo()
    print("📊 SPEED MOD MENU V3")
    print("🎛️ Vitesse actuelle: " .. speedValue)
    print("⌨️ Touches: INSERT = Menu")
    print("🚀 Vitesse normale: " .. originalWalkSpeed)
    print("💡 Astuce: Tape une vitesse et appuie sur ENTER")
    
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        print("👤 Vitesse actuelle du personnage: " .. char.Humanoid.WalkSpeed)
        print("🦘 Saut actuel du personnage: " .. char.Humanoid.JumpPower)
    else
        print("❌ Personnage ou Humanoid non trouvé")
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

print("Speed Mod Menu V3 chargé! Debug amélioré pour diagnostiquer les problèmes")
