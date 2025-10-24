local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local isMoving = false
local screenGui = nil
local mainFrame = nil
local toggleBtn = nil
local statusLabel = nil
local target = nil

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
local BOOSTED_WALKSPEED = 50 -- Vitesse boostée
local BOOSTED_JUMPPOWER = 100 -- Saut boosté

function createGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleMoveV28"
    screenGui.Parent = player.PlayerGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 80)
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
    title.Size = UDim2.new(1, -20, 0, 25)
    title.Position = UDim2.new(0, 15, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "AUTO MOVE V28 - SPEED BOOST"
    title.TextColor3 = Color3.fromRGB(220, 220, 220)
    title.TextSize = 14
    title.Font = Enum.Font.GothamMedium
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    
    toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 120, 0, 35)
    toggleBtn.Position = UDim2.new(0, 15, 0, 35)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "▶ START"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 13
    toggleBtn.Font = Enum.Font.GothamMedium
    toggleBtn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = toggleBtn
    
    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 80, 0, 20)
    statusLabel.Position = UDim2.new(0, 150, 0, 40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "IDLE"
    statusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 8)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    
    toggleBtn.MouseButton1Click:Connect(function()
        toggleMove()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
end

-- Fonction pour appliquer le boost de vitesse
local function applySpeedBoost()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        originalWalkSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = BOOSTED_WALKSPEED
        humanoid.JumpPower = BOOSTED_JUMPPOWER
        print(("🚀 Vitesse boostée: %.0f → %.0f"):format(originalWalkSpeed, BOOSTED_WALKSPEED))
    end
end

-- Fonction pour restaurer la vitesse normale
local function restoreSpeed()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        humanoid.WalkSpeed = originalWalkSpeed
        humanoid.JumpPower = 50
        print(("🐌 Vitesse restaurée: %.0f"):format(originalWalkSpeed))
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

    -- Afficher tous les modèles trouvés
    print("🔍 Modèles trouvés dans le rayon:")
    for _, model in ipairs(foundModels) do
        local type = model.isPlayer and "👤 JOUEUR" or "👾 MONSTRE"
        print(("  %s %s à %.1fm"):format(type, model.name, model.distance))
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
            -- Distance libre avant l'obstacle
            if result.Distance > maxDist then
                maxDist = result.Distance
                bestDir = d.vec
            end
            hitDetected = true
            print(("🔸 %s bloqué à %.1fm (%s)"):format(d.name, result.Distance, result.Instance.Name))
        else
            -- Pas de hit = direction libre
            maxDist = 6
            bestDir = d.vec
            print(("✅ %s libre"):format(d.name))
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

        -- Simulation de clic avec VirtualUser
        pcall(function()
            VirtualUser:Button1Down(Vector2.new(0,0))
            task.wait(0.05)
            VirtualUser:Button1Up(Vector2.new(0,0))
        end)
    end

    -- Vérifier si la cible est morte après le coup
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

    -- Paramètres pour le raycast
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {char}

    RunService.RenderStepped:Connect(function(dt)
        if isMoving and humanoid and root then
            -- Détection de blocage
            if lastPos then
                local movedDist = (root.Position - lastPos).Magnitude
                if movedDist < 0.1 then
                    stuckTimer = stuckTimer + dt
                else
                    stuckTimer = 0
                end
            end
            lastPos = root.Position

            -- Si bloqué trop longtemps, dégagement forcé
            if stuckTimer > 1.5 then
                print("⚠️ Personnage bloqué, tentative de dégagement...")
                local right = root.CFrame.RightVector
                local back = -root.CFrame.LookVector
                humanoid:Move(Vector3.new(right.X + back.X, 0, right.Z + back.Z), false)
                task.wait(0.8)
                stuckTimer = 0
            end

            -- Vérification de validité de la cible
            if not isValidTarget(target)
               or (root.Position - target.HumanoidRootPart.Position).Magnitude > DETECTION_RADIUS then
                target = getNearestMonster()
            end

            if target and target:FindFirstChild("HumanoidRootPart") then
                local toTarget = (target.HumanoidRootPart.Position - root.Position).Unit
                
                -- Détection d'obstacle pour saut amélioré (hauteur 1-8 studs)
                local rayOrigin = root.Position + Vector3.new(0, 2, 0)
                local rayDir = toTarget * 5
                local hit = workspace:Raycast(rayOrigin, rayDir, rayParams)
                
                if hit then
                    local obstacleHeight = hit.Position.Y - root.Position.Y
                    if obstacleHeight > 1 and obstacleHeight < 8 then
                        humanoid.Jump = true
                        print(("🟩 Petit obstacle détecté (%.1fm), saut !"):format(obstacleHeight))
                    elseif obstacleHeight >= 8 then
                        -- contournement
                        local strafeDir = (math.random() < 0.5) and root.CFrame.RightVector or -root.CFrame.RightVector
                        humanoid:Move(Vector3.new(strafeDir.X, 0, strafeDir.Z), false)
                        print(("🧱 Gros obstacle détecté (%.1fm), contournement."):format(obstacleHeight))
                    end
                end
                
                -- Vérification du sol sous les pieds pour descente
                local downRay = workspace:Raycast(root.Position + Vector3.new(0,2,0), Vector3.new(0, -8, 0), rayParams)
                if downRay then
                    if downRay.Distance > 6 then
                        -- sol bas → permet avancer
                        humanoid:Move(Vector3.new(toTarget.X, 0, toTarget.Z), false)
                        print("⬇️ Descente automatique détectée")
                    elseif downRay.Distance < 2 then
                        -- sol très proche ou rebord → reculer ou ajuster
                        humanoid:Move(-root.CFrame.LookVector, false)
                        task.wait(0.2)
                        print("🔄 Recul pour éviter rebord")
                    end
                end
                
                -- Anti-collage aux murs
                local wallAvoidForce = Vector3.zero
                
                -- Rayons gauche / droite pour éviter de se coller
                local leftRay = workspace:Raycast(root.Position + Vector3.new(0,2,0), -root.CFrame.RightVector * 3, rayParams)
                local rightRay = workspace:Raycast(root.Position + Vector3.new(0,2,0), root.CFrame.RightVector * 3, rayParams)
                
                if leftRay then
                    wallAvoidForce = wallAvoidForce + root.CFrame.RightVector * (3 - leftRay.Distance) * 0.5
                end
                if rightRay then
                    wallAvoidForce = wallAvoidForce + (-root.CFrame.RightVector) * (3 - rightRay.Distance) * 0.5
                end
                
                -- Détection de vide (falaises)
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
                        -- Direction finale : vers la cible + évitement des murs
                        local finalDir = (toTarget + wallAvoidForce).Unit
                        humanoid:Move(Vector3.new(finalDir.X, 0, finalDir.Z), false)
                    end
                end
                
                -- Attaque automatique si proche
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
        print("▶️ Auto-move activé avec boost de vitesse")
        toggleBtn.Text = "⏸ STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "RUNNING"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
        target = getNearestMonster()
        lastPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
        stuckTimer = 0
        applySpeedBoost()
    else
        print("⏹️ Auto-move désactivé, vitesse restaurée")
        toggleBtn.Text = "▶ START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        statusLabel.Text = "IDLE"
        statusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        target = nil
        lastPos = nil
        stuckTimer = 0
        restoreSpeed()
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

print("Auto Move V28 chargé! Vitesse boostée + VirtualUser pour clic gauche")
