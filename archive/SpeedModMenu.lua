local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local isMoving = false
local screenGui = nil
local mainFrame = nil
local toggleBtn = nil
local statusLabel = nil
local target = nil
local speedInput = nil
local speedValue = 50

local TOGGLE_KEY = Enum.KeyCode.Insert
local DETECTION_RADIUS = 200

-- Variables pour détection de blocage
local lastPos = nil
local stuckTimer = 0

-- Variables pour attaque
local lastAttackTime = 0
local ATTACK_COOLDOWN = 1.2 -- secondes

-- Variables pour vitesse
local originalWalkSpeed = 16
local originalJumpPower = 50

function createGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedModMenu"
    screenGui.Parent = player.PlayerGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 200)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 4, 1, 4)
    shadow.Position = UDim2.new(0, -2, 0, -2)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 14)
    shadowCorner.Parent = shadow
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 15, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "SPEED MOD MENU"
    title.TextColor3 = Color3.fromRGB(220, 220, 220)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 8)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    
    -- Section Vitesse
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 100, 0, 25)
    speedLabel.Position = UDim2.new(0, 15, 0, 45)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Vitesse:"
    speedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.GothamMedium
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = mainFrame
    
    speedInput = Instance.new("TextBox")
    speedInput.Size = UDim2.new(0, 80, 0, 30)
    speedInput.Position = UDim2.new(0, 120, 0, 42)
    speedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    speedInput.BorderSizePixel = 0
    speedInput.Text = tostring(speedValue)
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.TextSize = 14
    speedInput.Font = Enum.Font.Gotham
    speedInput.PlaceholderText = "Vitesse"
    speedInput.Parent = mainFrame
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 6)
    speedCorner.Parent = speedInput
    
    local speedApplyBtn = Instance.new("TextButton")
    speedApplyBtn.Size = UDim2.new(0, 60, 0, 30)
    speedApplyBtn.Position = UDim2.new(0, 210, 0, 42)
    speedApplyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    speedApplyBtn.BorderSizePixel = 0
    speedApplyBtn.Text = "APPLIQUER"
    speedApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedApplyBtn.TextSize = 12
    speedApplyBtn.Font = Enum.Font.GothamMedium
    speedApplyBtn.Parent = mainFrame
    
    local speedApplyCorner = Instance.new("UICorner")
    speedApplyCorner.CornerRadius = UDim.new(0, 6)
    speedApplyCorner.Parent = speedApplyBtn
    
    -- Section Auto Move
    local autoLabel = Instance.new("TextLabel")
    autoLabel.Size = UDim2.new(0, 100, 0, 25)
    autoLabel.Position = UDim2.new(0, 15, 0, 85)
    autoLabel.BackgroundTransparency = 1
    autoLabel.Text = "Auto Move:"
    autoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    autoLabel.TextSize = 14
    autoLabel.Font = Enum.Font.GothamMedium
    autoLabel.TextXAlignment = Enum.TextXAlignment.Left
    autoLabel.Parent = mainFrame
    
    toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.Position = UDim2.new(0, 120, 0, 82)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "▶ DÉMARRER"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 13
    toggleBtn.Font = Enum.Font.GothamMedium
    toggleBtn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = toggleBtn
    
    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 80, 0, 20)
    statusLabel.Position = UDim2.new(0, 250, 0, 90)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "IDLE"
    statusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    -- Section Info
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -30, 0, 40)
    infoLabel.Position = UDim2.new(0, 15, 0, 130)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Touches: INSERT = Menu | Vitesse actuelle: " .. speedValue
    infoLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    infoLabel.TextSize = 11
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextWrapped = true
    infoLabel.Parent = mainFrame
    
    -- Section Actions
    local actionLabel = Instance.new("TextLabel")
    actionLabel.Size = UDim2.new(0, 100, 0, 25)
    actionLabel.Position = UDim2.new(0, 15, 0, 175)
    actionLabel.BackgroundTransparency = 1
    actionLabel.Text = "Actions:"
    actionLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    actionLabel.TextSize = 14
    actionLabel.Font = Enum.Font.GothamMedium
    actionLabel.TextXAlignment = Enum.TextXAlignment.Left
    actionLabel.Parent = mainFrame
    
    local speedOnlyBtn = Instance.new("TextButton")
    speedOnlyBtn.Size = UDim2.new(0, 100, 0, 30)
    speedOnlyBtn.Position = UDim2.new(0, 120, 0, 172)
    speedOnlyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    speedOnlyBtn.BorderSizePixel = 0
    speedOnlyBtn.Text = "VITESSE SEULE"
    speedOnlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedOnlyBtn.TextSize = 11
    speedOnlyBtn.Font = Enum.Font.GothamMedium
    speedOnlyBtn.Parent = mainFrame
    
    local speedOnlyCorner = Instance.new("UICorner")
    speedOnlyCorner.CornerRadius = UDim.new(0, 6)
    speedOnlyCorner.Parent = speedOnlyBtn
    
    local restoreBtn = Instance.new("TextButton")
    restoreBtn.Size = UDim2.new(0, 80, 0, 30)
    restoreBtn.Position = UDim2.new(0, 230, 0, 172)
    restoreBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    restoreBtn.BorderSizePixel = 0
    restoreBtn.Text = "RESTAURER"
    restoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    restoreBtn.TextSize = 11
    restoreBtn.Font = Enum.Font.GothamMedium
    restoreBtn.Parent = mainFrame
    
    local restoreCorner = Instance.new("UICorner")
    restoreCorner.CornerRadius = UDim.new(0, 6)
    restoreCorner.Parent = restoreBtn
    
    -- Connexions des boutons
    toggleBtn.MouseButton1Click:Connect(function()
        toggleMove()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    speedApplyBtn.MouseButton1Click:Connect(function()
        applySpeed()
    end)
    
    speedOnlyBtn.MouseButton1Click:Connect(function()
        applySpeedOnly()
    end)
    
    restoreBtn.MouseButton1Click:Connect(function()
        restoreSpeed()
    end)
    
    -- Validation de l'input vitesse
    speedInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            applySpeed()
        end
    end)
end

-- Fonction pour appliquer la vitesse configurée
function applySpeed()
    local newSpeed = tonumber(speedInput.Text)
    if newSpeed and newSpeed > 0 and newSpeed <= 200 then
        speedValue = newSpeed
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = speedValue
            char.Humanoid.JumpPower = speedValue * 2
            print(("🚀 Vitesse appliquée: %.0f"):format(speedValue))
            updateInfoLabel()
        end
    else
        print("❌ Vitesse invalide (1-200)")
        speedInput.Text = tostring(speedValue)
    end
end

-- Fonction pour appliquer seulement la vitesse (sans auto move)
function applySpeedOnly()
    applySpeed()
    print("✅ Vitesse appliquée sans auto move")
end

-- Fonction pour restaurer la vitesse normale
function restoreSpeed()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = originalWalkSpeed
        char.Humanoid.JumpPower = originalJumpPower
        print(("🐌 Vitesse restaurée: %.0f"):format(originalWalkSpeed))
        updateInfoLabel()
    end
end

-- Fonction pour mettre à jour le label d'info
function updateInfoLabel()
    local infoLabel = mainFrame:FindFirstChild("infoLabel")
    if infoLabel then
        infoLabel.Text = "Touches: INSERT = Menu | Vitesse actuelle: " .. speedValue
    end
end

-- Fonction de validation de cible
local function isValidTarget(monster)
    if not monster then return false end
    local humanoid = monster:FindFirstChildOfClass("Humanoid")
    local hrp = monster:FindFirstChild("HumanoidRootPart")
    return humanoid and humanoid.Health > 0 and hrp
end

function getNearestMonster()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        print("❌ Pas de HumanoidRootPart")
        return nil
    end

    local root = char.HumanoidRootPart
    local nearest, minDist = nil, DETECTION_RADIUS
    local foundModels = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp and humanoid.Health > 0 then
                local dist = (root.Position - hrp.Position).Magnitude
                local isPlayer = Players:GetPlayerFromCharacter(obj)
                
                if dist < DETECTION_RADIUS then
                    table.insert(foundModels, {
                        name = obj.Name,
                        distance = dist,
                        isPlayer = isPlayer ~= nil
                    })
                    
                    if not isPlayer and dist < minDist then
                        nearest = obj
                        minDist = dist
                    end
                end
            end
        end
    end

    if nearest then
        print(("✅ Cible choisie: %s (%.1fm)"):format(nearest.Name, minDist))
    else
        print("❌ Aucun monstre dans le rayon")
    end

    return nearest
end

-- Fonction de contournement multi-directionnel
local function findBestDirection(root, rayParams)
    local dirs = {
        {name="front", vec=root.CFrame.LookVector},
        {name="frontLeft", vec=(root.CFrame.LookVector - root.CFrame.RightVector).Unit},
        {name="frontRight", vec=(root.CFrame.LookVector + root.CFrame.RightVector).Unit},
        {name="left", vec=-root.CFrame.RightVector},
        {name="right", vec=root.CFrame.RightVector},
    }

    local bestDir = root.CFrame.LookVector
    local maxDist = 0
    local hitDetected = false

    for _, d in ipairs(dirs) do
        local result = workspace:Raycast(root.Position + Vector3.new(0,2,0), d.vec * 6, rayParams)
        if result then
            if result.Distance > maxDist then
                maxDist = result.Distance
                bestDir = d.vec
            end
            hitDetected = true
        else
            maxDist = 6
            bestDir = d.vec
            break
        end
    end

    return bestDir, hitDetected
end

-- Fonction d'attaque automatique avec VirtualUser
local function autoAttack(target)
    if not target or not isValidTarget(target) then return end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local distance = (root.Position - target.HumanoidRootPart.Position).Magnitude
    if distance < 5 and tick() - lastAttackTime > ATTACK_COOLDOWN then
        lastAttackTime = tick()
        print(("⚔️ Attaque déclenchée sur %s (%.1fm)"):format(target.Name, distance))

        pcall(function()
            VirtualUser:Button1Down(Vector2.new(0,0))
            task.wait(0.05)
            VirtualUser:Button1Up(Vector2.new(0,0))
        end)
    end

    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then
        print("💀 Cible éliminée :", target.Name)
        target = getNearestMonster()
        if target then
            print("🎯 Nouvelle cible :", target.Name)
        else
            print("🔄 Aucune cible restante, recherche en cours...")
        end
    end
end

function moveTowardTarget()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {char}

    RunService.RenderStepped:Connect(function(dt)
        if isMoving and humanoid and root then
            if lastPos then
                local movedDist = (root.Position - lastPos).Magnitude
                if movedDist < 0.1 then
                    stuckTimer = stuckTimer + dt
                else
                    stuckTimer = 0
                end
            end
            lastPos = root.Position

            if stuckTimer > 1.5 then
                print("⚠️ Personnage bloqué, tentative de dégagement...")
                local right = root.CFrame.RightVector
                local back = -root.CFrame.LookVector
                humanoid:Move(Vector3.new(right.X + back.X, 0, right.Z + back.Z), false)
                task.wait(0.8)
                stuckTimer = 0
            end

            if not isValidTarget(target)
               or (root.Position - target.HumanoidRootPart.Position).Magnitude > DETECTION_RADIUS then
                target = getNearestMonster()
            end

            if target and target:FindFirstChild("HumanoidRootPart") then
                local toTarget = (target.HumanoidRootPart.Position - root.Position).Unit
                
                local rayOrigin = root.Position + Vector3.new(0, 2, 0)
                local rayDir = toTarget * 5
                local hit = workspace:Raycast(rayOrigin, rayDir, rayParams)
                
                if hit then
                    local obstacleHeight = hit.Position.Y - root.Position.Y
                    if obstacleHeight > 1 and obstacleHeight < 8 then
                        humanoid.Jump = true
                        print(("🟩 Petit obstacle détecté (%.1fm), saut !"):format(obstacleHeight))
                    elseif obstacleHeight >= 8 then
                        local strafeDir = (math.random() < 0.5) and root.CFrame.RightVector or -root.CFrame.RightVector
                        humanoid:Move(Vector3.new(strafeDir.X, 0, strafeDir.Z), false)
                        print(("🧱 Gros obstacle détecté (%.1fm), contournement."):format(obstacleHeight))
                    end
                end
                
                local downRay = workspace:Raycast(root.Position + Vector3.new(0,2,0), Vector3.new(0, -8, 0), rayParams)
                if downRay then
                    if downRay.Distance > 6 then
                        humanoid:Move(Vector3.new(toTarget.X, 0, toTarget.Z), false)
                        print("⬇️ Descente automatique détectée")
                    elseif downRay.Distance < 2 then
                        humanoid:Move(-root.CFrame.LookVector, false)
                        task.wait(0.2)
                        print("🔄 Recul pour éviter rebord")
                    end
                end
                
                local wallAvoidForce = Vector3.zero
                local leftRay = workspace:Raycast(root.Position + Vector3.new(0,2,0), -root.CFrame.RightVector * 3, rayParams)
                local rightRay = workspace:Raycast(root.Position + Vector3.new(0,2,0), root.CFrame.RightVector * 3, rayParams)
                
                if leftRay then
                    wallAvoidForce = wallAvoidForce + root.CFrame.RightVector * (3 - leftRay.Distance) * 0.5
                end
                if rightRay then
                    wallAvoidForce = wallAvoidForce + (-root.CFrame.RightVector) * (3 - rightRay.Distance) * 0.5
                end
                
                local downRay = workspace:Raycast(root.Position, Vector3.new(0, -5, 0), rayParams)
                if not downRay then
                    print("⚠️ Vide détecté sous le joueur, recul d'urgence")
                    humanoid:Move(-root.CFrame.LookVector, false)
                    task.wait(0.3)
                else
                    local bestDir, hitDetected = findBestDirection(root, rayParams)
                    
                    if hitDetected then
                        print("⚠️ Obstacle détecté, contournement par direction libre.")
                        humanoid:Move(Vector3.new(bestDir.X, 0, bestDir.Z), false)
                    else
                        local finalDir = (toTarget + wallAvoidForce).Unit
                        humanoid:Move(Vector3.new(finalDir.X, 0, finalDir.Z), false)
                    end
                end
                
                autoAttack(target)
            else
                humanoid:Move(Vector3.zero)
            end
        end
    end)
end

function toggleMove()
    isMoving = not isMoving
    if isMoving then
        print("▶️ Auto-move activé")
        toggleBtn.Text = "⏸ ARRÊTER"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "RUNNING"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
        target = getNearestMonster()
        lastPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
        stuckTimer = 0
        applySpeed()
    else
        print("⏹️ Auto-move désactivé")
        toggleBtn.Text = "▶ DÉMARRER"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        statusLabel.Text = "IDLE"
        statusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        target = nil
        lastPos = nil
        stuckTimer = 0
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

moveTowardTarget()

-- Boucle de spam automatique (toutes les 0.5s) - VirtualUser pour clic gauche
task.spawn(function()
    while true do
        if isMoving then
            pcall(function()
                VirtualUser:Button1Down(Vector2.new(0,0))
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(0,0))
            end)
        end
        task.wait(0.5)
    end
end)

print("Speed Mod Menu chargé! Interface complète avec configuration de vitesse")
