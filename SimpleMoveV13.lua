local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local isMoving = false
local screenGui = nil
local mainFrame = nil
local toggleBtn = nil
local statusLabel = nil
local target = nil

local TOGGLE_KEY = Enum.KeyCode.Insert
local DETECTION_RADIUS = 200

function createGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleMoveV13"
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
    title.Text = "AUTO MOVE V13"
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

-- Fonction pour calculer un chemin avec plusieurs tentatives
local function safeComputePath(startPos, endPos)
    for i = 1, 3 do -- tente 3 fois max
        local path = PathfindingService:CreatePath({
            AgentRadius = 1.2,      -- encore plus petit pour plus de tolérance
            AgentHeight = 7,        -- plus grand pour "voir" par-dessus les obstacles
            AgentCanJump = true,
            AgentCanClimb = true,
            WaypointSpacing = 0.5,  -- encore plus précis
            Costs = { 
                Water = 1,
                Lava = 1,
                Grass = 1,
                Sand = 1,
                Rock = 1,
                Snow = 1
            },
        })
        
        local success, result = pcall(function()
            return path:ComputeAsync(startPos, endPos)
        end)
        
        if success and path.Status == Enum.PathStatus.Success then
            return path
        end
        
        print(("⚠️ Tentative %d/3 échouée (Status: %s), retry..."):format(i, tostring(path.Status)))
        task.wait(0.1)
    end
    return nil
end

function moveTowardTarget()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    -- Fonction interne pour suivre un chemin complet
    local function followPath(targetPos)
        local path = safeComputePath(root.Position, targetPos)

        if path then
            local waypoints = path:GetWaypoints()
            print(("✅ Chemin trouvé avec %d points"):format(#waypoints))

            for _, wp in ipairs(waypoints) do
                if not isMoving then return end

                if wp.Action == Enum.PathWaypointAction.Jump then
                    humanoid.Jump = true
                end

                humanoid:MoveTo(wp.Position)
                local finished = humanoid.MoveToFinished:Wait()

                -- Si bloqué ou le chemin devient invalide, on relance un calcul
                if not finished then
                    print("⚠️ Blocage détecté, recalcul du chemin...")
                    break
                end
            end
        else
            print("❌ Aucun chemin possible, déplacement direct")
            local direction = (targetPos - root.Position).Unit
            humanoid:MoveTo(root.Position + (direction * 5))
        end
    end

    -- Boucle principale
    RunService.RenderStepped:Connect(function()
        if isMoving and humanoid and root then
            if not target or not target:FindFirstChild("HumanoidRootPart")
                or (root.Position - target.HumanoidRootPart.Position).Magnitude > DETECTION_RADIUS then
                target = getNearestMonster()
            end

            if target and target:FindFirstChild("HumanoidRootPart") then
                followPath(target.HumanoidRootPart.Position)
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
    else
        print("⏹️ Auto-move désactivé")
        toggleBtn.Text = "▶ START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        statusLabel.Text = "IDLE"
        statusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        target = nil
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

print("Auto Move V13 chargé! Pathfinding ultra-tolérant avec gestion d'erreur robuste")
