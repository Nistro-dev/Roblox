local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local menuVisible = false
local screenGui = nil
local mainFrame = nil
local isMoving = false

local TOGGLE_KEY = Enum.KeyCode.Insert
local MENU_SIZE = UDim2.new(0, 400, 0, 300)
local ANIMATION_TIME = 0.3

function logPath(message)
    print(message)
    if pathfindingLogs then
        table.insert(pathfindingLogs, message)
    end
end

function copyLogsToClipboard()
    if pathfindingLogs and #pathfindingLogs > 0 then
        local logsText = table.concat(pathfindingLogs, "\n")
        pcall(function()
            setclipboard(logsText)
        end)
        StarterGui:SetCore("SendNotification", {Title = "Logs"; Text = "Logs copiés dans le clipboard!"; Duration = 3})
        print("=== LOGS COPIÉS ===")
        print(logsText)
        print("==================")
    else
        StarterGui:SetCore("SendNotification", {Title = "Logs"; Text = "Aucun log!"; Duration = 2})
    end
end

function clearLogs()
    pathfindingLogs = {}
    StarterGui:SetCore("SendNotification", {Title = "Logs"; Text = "Logs effacés!"; Duration = 2})
end

local pathfindingLogs = {}
local goToMonsterBtn = nil

function findNearestMonster()
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        return nil, math.huge
    end
    
    local humanoidRootPart = playerChar.HumanoidRootPart
    local nearestMonster = nil
    local nearestDistance = math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent:FindFirstChild("HumanoidRootPart") then
            local monsterModel = obj.Parent
            local monsterHumanoid = obj
            
            if monsterHumanoid.Health > 0 and not Players:GetPlayerFromCharacter(monsterModel) then
                local monsterPos = monsterModel.HumanoidRootPart.Position
                local distance = (humanoidRootPart.Position - monsterPos).Magnitude
                
                if distance < nearestDistance then
                    nearestMonster = monsterModel
                    nearestDistance = distance
                end
            end
        end
    end
    
    return nearestMonster, nearestDistance
end

function customPathfinding(startPos, targetPos)
    local distance = (targetPos - startPos).Magnitude
    local direction = (targetPos - startPos).Unit
    
    logPath(string.format("[PATH] Distance totale: %.1fm", distance))
    logPath(string.format("[PATH] Direction: %.2f, %.2f, %.2f", direction.X, direction.Y, direction.Z))
    
    local steps = math.ceil(distance / 2)
    local stepDistance = distance / steps
    
    logPath(string.format("[PATH] %d étapes de %.1fm", steps, stepDistance))
    
    local waypoints = {}
    for i = 1, steps do
        local stepPos = startPos + (direction * (stepDistance * i))
        table.insert(waypoints, stepPos)
    end
    
    return waypoints
end

function goToMonster()
    if isMoving then
        isMoving = false
        goToMonsterBtn.Text = "👾 Démarrer"
        logPath("[MOVE] ⏹️ Arrêté par l'utilisateur")
        StarterGui:SetCore("SendNotification", {Title = "Monstre"; Text = "Arrêté!"; Duration = 2})
        return
    end
    
    isMoving = true
    goToMonsterBtn.Text = "⏹️ Arrêter"
    logPath("========== PATHFINDING CUSTOM ==========")
    
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        logPath("[MOVE] Personnage non trouvé")
        isMoving = false
        goToMonsterBtn.Text = "👾 Démarrer"
        return
    end
    
    local humanoid = playerChar:FindFirstChild("Humanoid")
    if not humanoid then
        logPath("[MOVE] Humanoid non trouvé")
        isMoving = false
        goToMonsterBtn.Text = "👾 Démarrer"
        return
    end
    
    local humanoidRootPart = playerChar.HumanoidRootPart
    
    logPath("[MOVE] 🔍 Recherche du monstre le plus proche...")
    StarterGui:SetCore("SendNotification", {Title = "Monstre"; Text = "Recherche monstre..."; Duration = 2})
    
    local function moveToMonster()
        if not isMoving then 
            goToMonsterBtn.Text = "👾 Démarrer"
            return 
        end
        
        local nearestMonster, nearestDistance = findNearestMonster()
        
        if not nearestMonster then
            logPath("[MOVE] ❌ Aucun monstre trouvé")
            StarterGui:SetCore("SendNotification", {Title = "Monstre"; Text = "Aucun monstre!"; Duration = 2})
            isMoving = false
            goToMonsterBtn.Text = "👾 Démarrer"
            return
        end
        
        logPath(string.format("[MOVE] 🎯 Monstre: %s à %.1fm", nearestMonster.Name, nearestDistance))
        
        if nearestDistance < 8 then
            isMoving = false
            goToMonsterBtn.Text = "👾 Démarrer"
            logPath("[MOVE] ✅ Arrivé au monstre!")
            StarterGui:SetCore("SendNotification", {Title = "Monstre"; Text = "Arrivé au monstre!"; Duration = 2})
            return
        end
        
        local monsterPos = nearestMonster.HumanoidRootPart.Position
        local currentPos = humanoidRootPart.Position
        
        local waypoints = customPathfinding(currentPos, monsterPos)
        
        logPath(string.format("[MOVE] 🗺️ %d waypoints calculés", #waypoints))
        
        local currentWaypoint = 1
        
        local function moveToNextWaypoint()
            if not isMoving or currentWaypoint > #waypoints then
                if isMoving then
                    task.wait(0.5)
                    moveToMonster()
                end
                return
            end
            
            local waypoint = waypoints[currentWaypoint]
            local distanceToWaypoint = (currentPos - waypoint).Magnitude
            
            logPath(string.format("[MOVE] Waypoint %d/%d - Distance: %.1fm", currentWaypoint, #waypoints, distanceToWaypoint))
            
            humanoid:MoveTo(waypoint)
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            
            local direction = (waypoint - currentPos).Unit
            if direction.Y > 0.3 then
                humanoid.Jump = true
                logPath("[MOVE] 🦘 Saut!")
            end
            
            currentWaypoint = currentWaypoint + 1
            
            task.wait(1)
            moveToNextWaypoint()
        end
        
        moveToNextWaypoint()
    end
    
    moveToMonster()
    
    task.delay(60, function()
        if isMoving then
            isMoving = false
            goToMonsterBtn.Text = "👾 Démarrer"
        end
    end)
end

function createMainGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FarmModMenuV5"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = player.PlayerGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = MENU_SIZE
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(100, 200, 255)
    border.Thickness = 2
    border.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "👾 Farm Mod Menu V5"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    goToMonsterBtn = Instance.new("TextButton")
    goToMonsterBtn.Size = UDim2.new(1, -40, 0, 60)
    goToMonsterBtn.Position = UDim2.new(0, 20, 0, 70)
    goToMonsterBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    goToMonsterBtn.Text = "👾 Démarrer"
    goToMonsterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    goToMonsterBtn.TextSize = 16
    goToMonsterBtn.Font = Enum.Font.GothamBold
    goToMonsterBtn.Parent = mainFrame
    
    local goToMonsterCorner = Instance.new("UICorner")
    goToMonsterCorner.CornerRadius = UDim.new(0, 8)
    goToMonsterCorner.Parent = goToMonsterBtn
    
    local copyLogsBtn = Instance.new("TextButton")
    copyLogsBtn.Size = UDim2.new(0.45, 0, 0, 35)
    copyLogsBtn.Position = UDim2.new(0, 20, 0, 150)
    copyLogsBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    copyLogsBtn.Text = "📋 Copier logs"
    copyLogsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyLogsBtn.TextSize = 14
    copyLogsBtn.Font = Enum.Font.Gotham
    copyLogsBtn.Parent = mainFrame
    
    local copyLogsCorner = Instance.new("UICorner")
    copyLogsCorner.CornerRadius = UDim.new(0, 6)
    copyLogsCorner.Parent = copyLogsBtn
    
    local clearLogsBtn = Instance.new("TextButton")
    clearLogsBtn.Size = UDim2.new(0.45, 0, 0, 35)
    clearLogsBtn.Position = UDim2.new(0.55, 0, 0, 150)
    clearLogsBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
    clearLogsBtn.Text = "🗑️ Effacer logs"
    clearLogsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearLogsBtn.TextSize = 14
    clearLogsBtn.Font = Enum.Font.Gotham
    clearLogsBtn.Parent = mainFrame
    
    local clearLogsCorner = Instance.new("UICorner")
    clearLogsCorner.CornerRadius = UDim.new(0, 6)
    clearLogsCorner.Parent = clearLogsBtn
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -40, 0, 100)
    infoLabel.Position = UDim2.new(0, 20, 0, 200)
    infoLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    infoLabel.BorderSizePixel = 0
    infoLabel.Text = "👾 Pathfinding custom (étapes de 2m)\n📋 Copie les logs pour debug\n🗑️ Efface les logs\n\nINSERT = Toggle menu"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextSize = 13
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextWrapped = true
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = mainFrame
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoLabel
    
    closeButton.MouseButton1Click:Connect(function()
        toggleMenu()
    end)
    
    goToMonsterBtn.MouseButton1Click:Connect(function()
        goToMonster()
    end)
    
    copyLogsBtn.MouseButton1Click:Connect(function()
        copyLogsToClipboard()
    end)
    
    clearLogsBtn.MouseButton1Click:Connect(function()
        clearLogs()
    end)
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
    
    frame.InputBegan:Connect(function(input)
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

function toggleMenu()
    menuVisible = not menuVisible
    
    if menuVisible then
        mainFrame.Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = MENU_SIZE}):Play()
    else
        TweenService:Create(mainFrame, TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(ANIMATION_TIME)
        mainFrame.Visible = false
    end
end

createMainGUI()
makeDraggable(mainFrame)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == TOGGLE_KEY then
        toggleMenu()
    end
end)

StarterGui:SetCore("SendNotification", {Title = "Farm Mod Menu V5"; Text = "Chargé! Appuie sur INSERT"; Duration = 5})
