local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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

function createGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleMoveV18"
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
    title.Text = "AUTO MOVE V18"
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

-- Fonction de détection multi-rayons
local function detectSurface(root)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {player.Character}

    local forward = root.CFrame.LookVector
    local origin = root.Position + Vector3.new(0, 2, 0)

    local hits = {
        front = workspace:Raycast(origin, forward * 5, params),
        down = workspace:Raycast(origin + forward * 2, Vector3.new(0, -5, 0), params),
        left = workspace:Raycast(origin, -root.CFrame.RightVector * 3, params),
        right = workspace:Raycast(origin, root.CFrame.RightVector * 3, params),
    }

    return hits
end

-- Fonction d'interprétation des raycasts
local function interpretSurface(hits)
    if hits.front then
        local normal = hits.front.Normal
        local y = math.abs(normal.Y)

        if y < 0.2 then
            -- Mur vertical
            print(("🧱 Mur détecté: %s"):format(hits.front.Instance.Name))
            return "wall", hits.front, hits
        elseif y < 0.6 then
            -- Obstacle incliné
            print(("🪨 Obstacle incliné: %s"):format(hits.front.Instance.Name))
            return "obstacle", hits.front, hits
        else
            -- Sol / marche
            print("⬆️ Sol détecté")
            return "floor", hits.front, hits
        end
    elseif hits.down then
        print("✅ Sol stable dessous")
        return "ground", hits.down, hits
    else
        print("⚠️ Vide devant")
        return "void", nil, hits
    end
end

function moveTowardTarget()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

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

            if not target or not target:FindFirstChild("HumanoidRootPart")
               or (root.Position - target.HumanoidRootPart.Position).Magnitude > DETECTION_RADIUS then
                target = getNearestMonster()
            end

            if target and target:FindFirstChild("HumanoidRootPart") then
                local direction = (target.HumanoidRootPart.Position - root.Position).Unit
                
                -- Détection intelligente multi-rayons
                local hits = detectSurface(root)
                local surfaceType, hit, allHits = interpretSurface(hits)

                if surfaceType == "wall" then
                    -- Choisir contournement selon le côté dégagé
                    local leftClear = not allHits.left
                    local rightClear = not allHits.right
                    local strafeDir = rightClear and root.CFrame.RightVector or -root.CFrame.RightVector

                    humanoid:Move(Vector3.new(strafeDir.X * 2, 0, strafeDir.Z * 2), false)
                    task.wait(0.5)
                elseif surfaceType == "obstacle" then
                    humanoid.Jump = true
                    task.wait(0.2)
                    humanoid:Move(Vector3.new(direction.X, 0, direction.Z), false)
                elseif surfaceType == "void" then
                    humanoid:Move(-root.CFrame.LookVector, false)
                    task.wait(0.3)
                else
                    -- Pas d'obstacle, avancer normalement
                    humanoid:Move(Vector3.new(direction.X, 0, direction.Z), false)
                end
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
        toggleBtn.Text = "⏸ STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        statusLabel.Text = "RUNNING"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
        target = getNearestMonster()
        lastPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
        stuckTimer = 0
    else
        print("⏹️ Auto-move désactivé")
        toggleBtn.Text = "▶ START"
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

print("Auto Move V18 chargé! Détection multi-rayons intelligente")
