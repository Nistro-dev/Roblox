local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
repeat task.wait() until player
local character = player.Character or player.CharacterAdded:Wait()
repeat task.wait() until character

local oldGui = player.PlayerGui:FindFirstChild("FarmModMenuGUI")
if oldGui then oldGui:Destroy() end

local menuVisible = false
local screenGui = nil
local mainFrame = nil
local savedPosition = nil
local pathfindingLogs = {}
local isPathfinding = false
local waypoints = {}
local currentWaypoint = 1
local targetPos = nil

local TOGGLE_KEY = Enum.KeyCode.Insert
local MENU_SIZE = UDim2.new(0, 450, 0, 350)
local ANIMATION_TIME = 0.3

local function logPath(message)
    pcall(function()
        print(message)
        table.insert(pathfindingLogs, message)
    end)
end

function copyLogsToClipboard()
    if #pathfindingLogs == 0 then
        StarterGui:SetCore("SendNotification", {Title = "Logs"; Text = "Aucun log!"; Duration = 2})
        return
    end
    
    if setclipboard then
        setclipboard(table.concat(pathfindingLogs, "\n"))
        StarterGui:SetCore("SendNotification", {Title = "Logs"; Text = #pathfindingLogs .. " lignes copiées!"; Duration = 3})
    else
        StarterGui:SetCore("SendNotification", {Title = "Erreur"; Text = "setclipboard non supporté"; Duration = 3})
    end
end

function clearLogs()
    pathfindingLogs = {}
    StarterGui:SetCore("SendNotification", {Title = "Logs"; Text = "Logs effacés!"; Duration = 2})
end

local function createMainGUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FarmModMenuGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = MENU_SIZE
    mainFrame.Position = savedPosition or UDim2.new(0.5, -225, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(100, 200, 255)
    border.Thickness = 2
    border.Transparency = 0.5
    border.Parent = mainFrame
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎮 Pathfinding Mod Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    local testMoveBtn = Instance.new("TextButton")
    testMoveBtn.Size = UDim2.new(1, -40, 0, 60)
    testMoveBtn.Position = UDim2.new(0, 20, 0, 70)
    testMoveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    testMoveBtn.Text = "🚀 Déplacement automatique 100m"
    testMoveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    testMoveBtn.TextSize = 16
    testMoveBtn.Font = Enum.Font.GothamBold
    testMoveBtn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = testMoveBtn
    
    local copyLogsBtn = Instance.new("TextButton")
    copyLogsBtn.Size = UDim2.new(0.48, -15, 0, 45)
    copyLogsBtn.Position = UDim2.new(0, 20, 0, 145)
    copyLogsBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    copyLogsBtn.Text = "📋 Copier logs"
    copyLogsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyLogsBtn.TextSize = 13
    copyLogsBtn.Font = Enum.Font.GothamBold
    copyLogsBtn.Parent = mainFrame
    
    local copyLogsCorner = Instance.new("UICorner")
    copyLogsCorner.CornerRadius = UDim.new(0, 8)
    copyLogsCorner.Parent = copyLogsBtn
    
    local clearLogsBtn = Instance.new("TextButton")
    clearLogsBtn.Size = UDim2.new(0.48, -15, 0, 45)
    clearLogsBtn.Position = UDim2.new(0.52, 10, 0, 145)
    clearLogsBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    clearLogsBtn.Text = "🗑️ Effacer logs"
    clearLogsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearLogsBtn.TextSize = 13
    clearLogsBtn.Font = Enum.Font.GothamBold
    clearLogsBtn.Parent = mainFrame
    
    local clearLogsCorner = Instance.new("UICorner")
    clearLogsCorner.CornerRadius = UDim.new(0, 8)
    clearLogsCorner.Parent = clearLogsBtn
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -40, 0, 120)
    infoLabel.Position = UDim2.new(0, 20, 0, 205)
    infoLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    infoLabel.BorderSizePixel = 0
    infoLabel.Text = "🚀 Déplacement automatique 100m (mouvement naturel)\n📋 Copie les logs pour debug\n🗑️ Efface les logs\n\nINSERT = Toggle menu"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextSize = 13
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextWrapped = true
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.Parent = mainFrame
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 6)
    infoCorner.Parent = infoLabel
    
    closeButton.MouseButton1Click:Connect(function() toggleMenu() end)
    testMoveBtn.MouseButton1Click:Connect(function() testMoveToMonster() end)
    copyLogsBtn.MouseButton1Click:Connect(function() copyLogsToClipboard() end)
    clearLogsBtn.MouseButton1Click:Connect(function() clearLogs() end)
    
    local function makeDraggable(frame, dragHandle)
        local dragging = false
        local dragInput, mousePos, framePos
        
        dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                mousePos = input.Position
                framePos = frame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        savedPosition = frame.Position
                    end
                end)
            end
        end)
        
        dragHandle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            end
        end)
    end
    
    makeDraggable(mainFrame, titleBar)
    return screenGui
end

function isPlayer(model)
    if Players:GetPlayerFromCharacter(model) then return true end
    for _, plr in pairs(Players:GetPlayers()) do
        if model.Name == plr.Name or model.Name == plr.DisplayName then return true end
    end
    return false
end

function findNearestMonster()
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then return nil end
    
    local playerPos = playerChar.HumanoidRootPart.Position
    local nearestMonster = nil
    local nearestDistance = math.huge
    
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent then
            local model = obj.Parent
            local rootPart = model:FindFirstChild("HumanoidRootPart")
            
            if rootPart and obj.Health > 0 and model ~= playerChar and not isPlayer(model) then
                local distance = (rootPart.Position - playerPos).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestMonster = model
                end
            end
        end
    end
    
    return nearestMonster, nearestDistance
end

function testMoveToMonster()
    if isPathfinding then
        StarterGui:SetCore("SendNotification", {Title = "Déplacement"; Text = "Déjà en cours!"; Duration = 2})
        return
    end
    
    isPathfinding = true
    logPath("========== DÉPLACEMENT AUTOMATIQUE ==========")
    
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        logPath("[MOVE] Personnage non trouvé")
        isPathfinding = false
        StarterGui:SetCore("SendNotification", {Title = "Déplacement"; Text = "Personnage pas prêt!"; Duration = 2})
        return
    end
    
    local humanoid = playerChar:FindFirstChild("Humanoid")
    if not humanoid then
        logPath("[MOVE] Humanoid non trouvé")
        isPathfinding = false
        StarterGui:SetCore("SendNotification", {Title = "Déplacement"; Text = "Humanoid pas prêt!"; Duration = 2})
        return
    end
    
    local humanoidRootPart = playerChar.HumanoidRootPart
    local startPos = humanoidRootPart.Position
    targetPos = humanoidRootPart.Position + (humanoidRootPart.CFrame.LookVector * 100)
    local distance = (targetPos - startPos).Magnitude
    
    logPath(string.format("[MOVE] Déplacement automatique vers %.0fm", distance))
    StarterGui:SetCore("SendNotification", {Title = "Déplacement"; Text = "Déplacement automatique..."; Duration = 2})
    
    local path = PathfindingService:CreatePath({
        AgentRadius = 3,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentMaxSlope = 60,
        Costs = {Water = 20}
    })
    
    local success, errorMessage = pcall(function()
        path:ComputeAsync(startPos, targetPos)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        waypoints = path:GetWaypoints()
        currentWaypoint = 2
        
        logPath(string.format("[MOVE] ✅ Chemin calculé: %d waypoints", #waypoints))
        logPath("[MOVE] 🚀 Déplacement automatique en cours...")
        
        local function moveToNextWaypoint()
            if currentWaypoint <= #waypoints and isPathfinding then
                local waypoint = waypoints[currentWaypoint]
                local humanoidRootPart = playerChar.HumanoidRootPart
                
                logPath(string.format("[MOVE] Waypoint %d/%d - Distance: %.1fm", currentWaypoint, #waypoints, (waypoint.Position - humanoidRootPart.Position).Magnitude))
                
                humanoid:MoveTo(waypoint.Position)
                
                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    humanoid.Jump = true
                    logPath("[MOVE] 🦘 Saut automatique!")
                end
                
                currentWaypoint = currentWaypoint + 1
            else
                isPathfinding = false
                logPath("[MOVE] ✅ Arrivé à destination!")
                StarterGui:SetCore("SendNotification", {Title = "Déplacement"; Text = "Arrivé à destination!"; Duration = 2})
            end
        end
        
        local reachedConnection
        local consecutiveFailures = 0
        
        reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
            if reached then
                consecutiveFailures = 0
                logPath(string.format("[MOVE] Waypoint %d/%d atteint!", currentWaypoint - 1, #waypoints))
                moveToNextWaypoint()
            else
                local currentPos = humanoidRootPart.Position
                local lastWaypointPos = waypoints[currentWaypoint - 1].Position
                local distToWaypoint = (currentPos - lastWaypointPos).Magnitude
                
                if distToWaypoint < 15 then
                    consecutiveFailures = 0
                    logPath(string.format("[MOVE] Waypoint %d/%d OK (tolérance %.1fm)", currentWaypoint - 1, #waypoints, distToWaypoint))
                    moveToNextWaypoint()
                else
                    consecutiveFailures = consecutiveFailures + 1
                    logPath(string.format("[MOVE] Échec %d/10 - Distance: %.1fm", consecutiveFailures, distToWaypoint))
                    
                    if consecutiveFailures >= 10 then
                        reachedConnection:Disconnect()
                        isPathfinding = false
                        
                        local distanceToTarget = (currentPos - targetPos).Magnitude
                        logPath(string.format("[MOVE] Bloqué - Distance restante: %.0fm", distanceToTarget))
                        StarterGui:SetCore("SendNotification", {Title = "Déplacement"; Text = "Bloqué après 10 échecs!"; Duration = 3})
                    else
                        logPath("[MOVE] On force le passage au waypoint suivant...")
                        moveToNextWaypoint()
                    end
                end
            end
        end)
        
        moveToNextWaypoint()
        
        task.delay(30, function()
            if reachedConnection then reachedConnection:Disconnect() end
            isPathfinding = false
        end)
    else
        logPath("[MOVE] ❌ Pathfinding échoué - Essai mouvement direct...")
        
        local humanoidRootPart = playerChar.HumanoidRootPart
        local startPos = humanoidRootPart.Position
        local directTarget = startPos + (humanoidRootPart.CFrame.LookVector * 100)
        
        logPath("[MOVE] 🎯 Mouvement direct vers la cible")
        StarterGui:SetCore("SendNotification", {Title = "Déplacement"; Text = "Mouvement direct..."; Duration = 2})
        
        humanoid:MoveTo(directTarget)
        
        local directConnection
        local startTime = tick()
        
        directConnection = humanoid.MoveToFinished:Connect(function(reached)
            local elapsed = tick() - startTime
            local currentPos = humanoidRootPart.Position
            local distanceToTarget = (currentPos - directTarget).Magnitude
            
            if reached then
                isPathfinding = false
                logPath("[MOVE] ✅ Arrivé à destination (mouvement direct)!")
                StarterGui:SetCore("SendNotification", {Title = "Déplacement"; Text = "Arrivé à destination!"; Duration = 2})
            else
                if elapsed > 15 or distanceToTarget < 5 then
                    isPathfinding = false
                    logPath(string.format("[MOVE] ✅ Arrivé proche (%.1fm restant)", distanceToTarget))
                    StarterGui:SetCore("SendNotification", {Title = "Déplacement"; Text = "Arrivé proche!"; Duration = 2})
                else
                    logPath(string.format("[MOVE] En cours... Distance: %.1fm", distanceToTarget))
                    humanoid:MoveTo(directTarget)
                end
            end
        end)
        
        task.delay(20, function()
            if directConnection then directConnection:Disconnect() end
            isPathfinding = false
        end)
    end
end

function toggleMenu()
    menuVisible = not menuVisible
    
    if menuVisible then
        mainFrame.Visible = true
        mainFrame.Position = savedPosition or UDim2.new(0.5, -225, 0.5, -175)
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        
        TweenService:Create(mainFrame, TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = MENU_SIZE}):Play()
    else
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        closeTween:Play()
        closeTween.Completed:Connect(function() mainFrame.Visible = false end)
    end
end

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    if isPathfinding then
        isPathfinding = false
        logPath("[SYSTEM] Respawn détecté - Pathfinding annulé")
    end
end)

createMainGUI()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == TOGGLE_KEY then
        toggleMenu()
    end
end)

StarterGui:SetCore("SendNotification", {Title = "Pathfinding Mod Menu"; Text = "Chargé! Appuie sur INSERT"; Duration = 5})
