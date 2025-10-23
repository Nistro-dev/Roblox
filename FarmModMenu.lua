-- Mod Menu Auto Farm pour Roblox - VERSION SIMPLIFIÉE
-- Pathfinding uniquement

print("[MOD MENU] Initialisation du script...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
repeat task.wait() until player

local character = player.Character or player.CharacterAdded:Wait()
repeat task.wait() until character

print("[MOD MENU] Joueur détecté!")

-- ===== NETTOYAGE DE L'ANCIENNE VERSION =====
local oldGui = player.PlayerGui:FindFirstChild("FarmModMenuGUI")
if oldGui then
    oldGui:Destroy()
    print("[MOD MENU] ✓ Ancien GUI supprimé")
end

print("[MOD MENU] ✓ Nettoyage terminé!")

-- Activer cette instance du script
_G.FARM_MOD_MENU_ACTIVE = true

-- Variables globales
local menuVisible = false
local screenGui = nil
local mainFrame = nil
local savedPosition = nil
local pathfindingLogs = {} -- Stockage des logs

-- Configuration
local TOGGLE_KEY = Enum.KeyCode.Insert
local MENU_SIZE = UDim2.new(0, 450, 0, 470)
local ANIMATION_TIME = 0.3
local ENEMY_FOLDERS = {"Enemies", "NPCs", "Monsters", "Mobs", "Dungeon", "DungeonMobs", "Boss", "Bosses", "IzvDf"}
local detectedFolders = {}

-- Fonction pour créer le GUI principal
local function createMainGUI()
    print("[MOD MENU] Création de l'interface...")
    
    -- ScreenGui principal
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FarmModMenuGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Frame principale
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = MENU_SIZE
    mainFrame.Position = savedPosition or UDim2.new(0.5, -225, 0.5, -180)
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
    
    -- Barre de titre
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
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
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    -- Bouton Test Path finding
    local testMoveBtn = Instance.new("TextButton")
    testMoveBtn.Size = UDim2.new(1, -40, 0, 60)
    testMoveBtn.Position = UDim2.new(0, 20, 0, 70)
    testMoveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    testMoveBtn.Text = "🎯 Aller au monstre le plus proche"
    testMoveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    testMoveBtn.TextSize = 16
    testMoveBtn.Font = Enum.Font.GothamBold
    testMoveBtn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = testMoveBtn
    
    -- Bouton Désinjecter
    local uninjectBtn = Instance.new("TextButton")
    uninjectBtn.Size = UDim2.new(1, -40, 0, 50)
    uninjectBtn.Position = UDim2.new(0, 20, 0, 145)
    uninjectBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    uninjectBtn.Text = "🗑️ Désinjecter le script"
    uninjectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    uninjectBtn.TextSize = 14
    uninjectBtn.Font = Enum.Font.GothamBold
    uninjectBtn.Parent = mainFrame
    
    local uninjectCorner = Instance.new("UICorner")
    uninjectCorner.CornerRadius = UDim.new(0, 8)
    uninjectCorner.Parent = uninjectBtn
    
    -- Bouton Copier Logs
    local copyLogsBtn = Instance.new("TextButton")
    copyLogsBtn.Size = UDim2.new(0.48, -15, 0, 45)
    copyLogsBtn.Position = UDim2.new(0, 20, 0, 210)
    copyLogsBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    copyLogsBtn.Text = "📋 Copier logs"
    copyLogsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyLogsBtn.TextSize = 13
    copyLogsBtn.Font = Enum.Font.GothamBold
    copyLogsBtn.Parent = mainFrame
    
    local copyLogsCorner = Instance.new("UICorner")
    copyLogsCorner.CornerRadius = UDim.new(0, 8)
    copyLogsCorner.Parent = copyLogsBtn
    
    -- Bouton Effacer Logs
    local clearLogsBtn = Instance.new("TextButton")
    clearLogsBtn.Size = UDim2.new(0.48, -15, 0, 45)
    clearLogsBtn.Position = UDim2.new(0.52, 10, 0, 210)
    clearLogsBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    clearLogsBtn.Text = "🗑️ Effacer logs"
    clearLogsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearLogsBtn.TextSize = 13
    clearLogsBtn.Font = Enum.Font.GothamBold
    clearLogsBtn.Parent = mainFrame
    
    local clearLogsCorner = Instance.new("UICorner")
    clearLogsCorner.CornerRadius = UDim.new(0, 8)
    clearLogsCorner.Parent = clearLogsBtn
    
    -- Info label
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -40, 0, 150)
    infoLabel.Position = UDim2.new(0, 20, 0, 270)
    infoLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    infoLabel.BorderSizePixel = 0
    infoLabel.Text = "🎯 Pathfinding vers le monstre le plus proche\n📋 Copie les logs pour me les envoyer\n🗑️ Efface les logs avant un nouveau test\n\nF9 = Console | INSERT = Toggle menu"
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
    
    -- Événements
    closeButton.MouseButton1Click:Connect(function()
        toggleMenu()
    end)
    
    testMoveBtn.MouseButton1Click:Connect(function()
        testMoveToMonster()
    end)
    
    uninjectBtn.MouseButton1Click:Connect(function()
        uninjectScript()
    end)
    
    copyLogsBtn.MouseButton1Click:Connect(function()
        copyLogsToClipboard()
    end)
    
    clearLogsBtn.MouseButton1Click:Connect(function()
        clearLogs()
    end)
    
    -- Rendre le menu déplaçable
    makeDraggable(mainFrame, titleBar)
    
    print("[MOD MENU] Interface créée avec succès!")
    
    return screenGui
end

-- Fonction pour logger avec stockage
local function logPath(message)
    local success, err = pcall(function()
        print(message)
        table.insert(pathfindingLogs, message)
    end)
    if not success then
        print("[ERROR] logPath failed: " .. tostring(err))
    end
end

-- Fonction pour copier les logs dans le presse-papier
function copyLogsToClipboard()
    if #pathfindingLogs == 0 then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Logs";
            Text = "Aucun log à copier!";
            Duration = 2;
        })
        return
    end
    
    local logsText = table.concat(pathfindingLogs, "\n")
    
    -- Vérifier si setclipboard existe (supporté par la plupart des executors)
    if setclipboard then
        setclipboard(logsText)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Logs";
            Text = string.format("%d lignes copiées!", #pathfindingLogs);
            Duration = 3;
        })
        print("[LOGS] ✓ " .. #pathfindingLogs .. " lignes copiées dans le presse-papier!")
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Erreur";
            Text = "setclipboard non supporté par ton executor";
            Duration = 3;
        })
        print("[LOGS] ❌ setclipboard() n'est pas disponible")
    end
end

-- Fonction pour réinitialiser les logs
function clearLogs()
    pathfindingLogs = {}
    print("[LOGS] ✓ Logs effacés")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Logs";
        Text = "Logs effacés!";
        Duration = 2;
    })
end

-- Fonction pour désinjecter proprement le script
function uninjectScript()
    print("[MOD MENU] ========== DÉSINJECTION ==========")
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Mod Menu";
        Text = "Désinjection en cours...";
        Duration = 2;
    })
    
    -- Désactiver le flag global
    _G.FARM_MOD_MENU_ACTIVE = false
    print("[MOD MENU] ✓ Flag global désactivé")
    
    -- Supprimer le GUI
    if screenGui then
        screenGui:Destroy()
        print("[MOD MENU] ✓ Interface supprimée")
    end
    
    print("[MOD MENU] ✓ Script désinjecté avec succès!")
    print("[MOD MENU] ========== FIN DÉSINJECTION ==========")
    
    task.wait(0.5)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Mod Menu";
        Text = "✓ Script désinjecté!";
        Duration = 3;
    })
end

-- Fonction pour rendre un frame déplaçable
function makeDraggable(frame, dragHandle)
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
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Fonction pour vérifier si un modèle est un joueur
function isPlayer(model)
    if Players:GetPlayerFromCharacter(model) then
        return true
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if model.Name == plr.Name or model.Name == plr.DisplayName then
            return true
        end
    end
    
    return false
end

-- Fonction pour trouver le monstre le plus proche
function findNearestMonster()
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        print("[MOVE] Personnage non trouvé")
        return nil
    end
    
    local playerPos = playerChar.HumanoidRootPart.Position
    local nearestMonster = nil
    local nearestDistance = math.huge
    local monstresTrouves = 0
    
    print("[MOVE] Recherche du monstre le plus proche...")
    
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent then
            local model = obj.Parent
            local rootPart = model:FindFirstChild("HumanoidRootPart")
            
            if rootPart and obj.Health > 0 then
                if model ~= playerChar and not isPlayer(model) then
                    local distance = (rootPart.Position - playerPos).Magnitude
                    monstresTrouves = monstresTrouves + 1
                    
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestMonster = model
                    end
                end
            end
        end
    end
    
    if nearestMonster then
        print(string.format("[MOVE] Monstre trouvé: %s à %dm (%d total)", nearestMonster.Name, math.floor(nearestDistance), monstresTrouves))
    else
        print("[MOVE] Aucun monstre trouvé")
    end
    
    return nearestMonster, nearestDistance
end

-- Variables pour empêcher les clics multiples
local isPathfinding = false

-- Fonction pour tester le déplacement vers un monstre
function testMoveToMonster()
    if isPathfinding then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Pathfinding";
            Text = "Déjà en cours!";
            Duration = 2;
        })
        logPath("[MOVE] ⚠️ Pathfinding déjà en cours, attends la fin!")
        return
    end
    
    isPathfinding = true
    logPath("========== TEST PATHFINDING ==========")
    
    local monster, distance = findNearestMonster()
    if not monster then
        isPathfinding = false
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Pathfinding";
            Text = "Aucun monstre trouvé!";
            Duration = 3;
        })
        return
    end
    
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        logPath("[MOVE] Personnage non trouvé")
        return
    end
    
    local humanoidRootPart = playerChar.HumanoidRootPart
    local targetPos = monster.HumanoidRootPart.Position
    
    logPath(string.format("[MOVE] Cible: %s (%dm)", monster.Name, math.floor(distance)))
    logPath("[MOVE] Calcul du chemin...")
    
    local PathfindingService = game:GetService("PathfindingService")
    local humanoid = playerChar:FindFirstChild("Humanoid")
    
    if humanoid then
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentMaxSlope = 45,
            Costs = { Water = 20 }
        })
        
        local success, errorMessage = pcall(function()
            path:ComputeAsync(humanoidRootPart.Position, targetPos)
        end)
        
        if success and path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            
            print("") -- Test sans logPath
            print("╔═══════════════════════════════════════╗")
            print("║      ✅ CHEMIN TROUVÉ - DÉPART ✅      ║")
            print("╚═══════════════════════════════════════╝")
            print(string.format("[MOVE] 🎯 Cible: %s", monster.Name))
            print(string.format("[MOVE] 📏 Distance totale: %.1fm", distance))
            print(string.format("[MOVE] 🗺️ Nombre de waypoints: %d", #waypoints))
            print(string.format("[MOVE] 📍 Position départ: (%.1f, %.1f, %.1f)", humanoidRootPart.Position.X, humanoidRootPart.Position.Y, humanoidRootPart.Position.Z))
            print(string.format("[MOVE] 🎯 Position arrivée: (%.1f, %.1f, %.1f)", targetPos.X, targetPos.Y, targetPos.Z))
            print("═══════════════════════════════════════")
            print("")
            
            print("[DEBUG] 1/5 - DÉBUT DU CODE PATHFINDING")
            
            local notifSuccess = pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Pathfinding";
                    Text = "Déplacement vers " .. monster.Name;
                    Duration = 2;
                })
            end)
            
            print("[DEBUG] 2/5 - Notif success: " .. tostring(notifSuccess))
            print("[MOVE] 🚀 Initialisation du mouvement...")
            print("[DEBUG] 3/5 - Avant définition de moveToNextWaypoint")
            
            local currentWaypoint = 2
            local pathBlocked = false
            
            local function moveToNextWaypoint()
                print("[DEBUG] moveToNextWaypoint() APPELÉE - currentWaypoint: " .. currentWaypoint .. " / " .. #waypoints .. " - pathBlocked: " .. tostring(pathBlocked))
                
                if currentWaypoint <= #waypoints and not pathBlocked then
                    print("[DEBUG] Condition OK, on entre dans le if")
                    local waypoint = waypoints[currentWaypoint]
                    local playerPos = humanoidRootPart.Position
                    local waypointPos = waypoint.Position
                    
                    print("[DEBUG] Waypoint récupéré, calcul des distances...")
                    
                    -- Calcul des distances
                    local distToWaypoint = (waypointPos - playerPos).Magnitude
                    local horizontalDist = math.sqrt((waypointPos.X - playerPos.X)^2 + (waypointPos.Z - playerPos.Z)^2)
                    local heightDiff = waypointPos.Y - playerPos.Y
                    
                    -- Détection d'obstacles
                    local rayOrigin = playerPos + Vector3.new(0, 2, 0) -- 2 studs au-dessus
                    local rayDirection = (waypointPos - playerPos).Unit * distToWaypoint
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    raycastParams.FilterDescendantsInstances = {playerChar}
                    
                    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                    local obstacleDetected = rayResult ~= nil
                    local obstacleInfo = "Aucun"
                    
                    if rayResult then
                        local obstacleDistance = (rayResult.Position - playerPos).Magnitude
                        obstacleInfo = string.format("%s à %.1fm", rayResult.Instance.Name, obstacleDistance)
                    end
                    
                    -- Type de waypoint
                    local actionType = "Normal"
                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        actionType = "SAUT"
                    elseif waypoint.Action == Enum.PathWaypointAction.Walk then
                        actionType = "Marche"
                    end
                    
                    -- Affichage détaillé
                    print("═══════════════════════════════════════")
                    print(string.format("[MOVE] ➤ WAYPOINT %d/%d", currentWaypoint, #waypoints))
                    print(string.format("[MOVE] 📍 Position Joueur: (%.1f, %.1f, %.1f)", playerPos.X, playerPos.Y, playerPos.Z))
                    print(string.format("[MOVE] 🎯 Position Waypoint: (%.1f, %.1f, %.1f)", waypointPos.X, waypointPos.Y, waypointPos.Z))
                    print(string.format("[MOVE] 📏 Distance totale: %.1fm", distToWaypoint))
                    print(string.format("[MOVE] ↔️ Distance horizontale: %.1fm", horizontalDist))
                    print(string.format("[MOVE] ⬆️ Différence hauteur: %.1fm %s", math.abs(heightDiff), heightDiff >= 0 and "(monte)" or "(descend)"))
                    print(string.format("[MOVE] 🎬 Type: %s", actionType))
                    print(string.format("[MOVE] 🚧 Obstacle: %s", obstacleInfo))
                    print("═══════════════════════════════════════")
                    
                    humanoid:MoveTo(waypointPos)
                    
                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        humanoid.Jump = true
                        print("[MOVE] 🦘 SAUT ACTIVÉ!")
                    end
                    
                    currentWaypoint = currentWaypoint + 1
                    print("[DEBUG] currentWaypoint incrémenté à: " .. currentWaypoint)
                else
                    print("[DEBUG] ❌ Condition FAUSSE - ne rentre PAS dans le if")
                    print("[DEBUG] currentWaypoint: " .. currentWaypoint .. " <= " .. #waypoints .. " ?")
                    print("[DEBUG] pathBlocked: " .. tostring(pathBlocked))
                end
                print("[DEBUG] Fin de moveToNextWaypoint()")
            end
            
            local reachedConnection
            local consecutiveFailures = 0
            
            reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
                print("")
                print("─────────────── MOVE FINISHED ───────────────")
                print(string.format("[MOVE] ✓ MoveToFinished appelé"))
                print(string.format("[MOVE] Reached: %s", reached and "✅ OUI" or "❌ NON"))
                print(string.format("[MOVE] Waypoint complété: %d/%d", currentWaypoint - 1, #waypoints))
                
                if reached then
                    print("[MOVE] ✅ Waypoint atteint parfaitement!")
                    consecutiveFailures = 0
                    
                    if currentWaypoint <= #waypoints then
                        moveToNextWaypoint()
                    else
                        reachedConnection:Disconnect()
                        isPathfinding = false
                        logPath("[MOVE] === ✅ ARRIVÉ AU MONSTRE! ===")
                        
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Pathfinding";
                            Text = "Arrivé devant " .. monster.Name;
                            Duration = 2;
                        })
                    end
                else
                    -- Vérifier si on est PROCHE du waypoint même si pas parfaitement atteint
                    local currentPos = humanoidRootPart.Position
                    local lastWaypointPos = waypoints[currentWaypoint - 1].Position
                    local distToWaypoint = (currentPos - lastWaypointPos).Magnitude
                    
                    print(string.format("[MOVE] 🔍 Vérification: Distance au waypoint = %.1fm", distToWaypoint))
                    
                    -- Si on est à moins de 5m du waypoint, on considère que c'est OK (terrain irrégulier)
                    if distToWaypoint < 5 then
                        print(string.format("[MOVE] ⚠️ Pas parfait mais assez proche (%.1fm) - ON CONTINUE!", distToWaypoint))
                        consecutiveFailures = 0
                        
                        if currentWaypoint <= #waypoints then
                            moveToNextWaypoint()
                        else
                            reachedConnection:Disconnect()
                            isPathfinding = false
                            logPath("[MOVE] === ✅ ARRIVÉ AU MONSTRE (avec tolérance)! ===")
                            
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "Pathfinding";
                                Text = "Arrivé devant " .. monster.Name;
                                Duration = 2;
                            })
                        end
                    else
                        -- Vraiment loin du waypoint, analyse détaillée du blocage
                        consecutiveFailures = consecutiveFailures + 1
                        print(string.format("[MOVE] ❌ Trop loin du waypoint! Échec %d/3", consecutiveFailures))
                        
                        if consecutiveFailures >= 3 then
                            -- Vraiment bloqué après 3 échecs
                            local distanceToTarget = (currentPos - targetPos).Magnitude
                            
                            print("")
                            print("╔═══════════════════════════════════════╗")
                            print("║        ⚠️ PATHFINDING BLOQUÉ ⚠️       ║")
                            print("╚═══════════════════════════════════════╝")
                            print(string.format("[MOVE] 🛑 Bloqué au waypoint: %d/%d", currentWaypoint - 1, #waypoints))
                            print(string.format("[MOVE] 📍 Position actuelle: (%.1f, %.1f, %.1f)", currentPos.X, currentPos.Y, currentPos.Z))
                            print(string.format("[MOVE] 🎯 Position waypoint: (%.1f, %.1f, %.1f)", lastWaypointPos.X, lastWaypointPos.Y, lastWaypointPos.Z))
                            print(string.format("[MOVE] 📏 Distance au waypoint: %.1fm", distToWaypoint))
                            print(string.format("[MOVE] 🎯 Distance restante au monstre: %.1fm", distanceToTarget))
                            print(string.format("[MOVE] 📊 Progression: %.1f%%", (1 - distanceToTarget / distance) * 100))
                            
                            -- Vérifier le sol sous les pieds
                            local rayDown = Ray.new(currentPos, Vector3.new(0, -10, 0))
                            local hitPart, hitPos = workspace:FindPartOnRay(rayDown, playerChar)
                            if hitPart then
                                local heightAboveGround = currentPos.Y - hitPos.Y
                                print(string.format("[MOVE] 🌍 Sol détecté: %s (hauteur: %.1fm)", hitPart.Name, heightAboveGround))
                            else
                                print("[MOVE] ⚠️ AUCUN SOL DÉTECTÉ (dans le vide?)")
                            end
                            
                            -- État du personnage
                            print(string.format("[MOVE] 🏃 Vitesse actuelle: %.1f", humanoid.WalkSpeed))
                            print(string.format("[MOVE] 💚 Santé: %d/%d", humanoid.Health, humanoid.MaxHealth))
                            print(string.format("[MOVE] 🎯 État: %s", humanoid:GetState().Name))
                            print("═══════════════════════════════════════")
                            
                            pathBlocked = true
                            reachedConnection:Disconnect()
                            isPathfinding = false
                            
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "Pathfinding";
                                Text = string.format("Bloqué! %.1f%% parcouru", (1 - distanceToTarget / distance) * 100);
                                Duration = 3;
                            })
                        else
                            -- Réessayer le waypoint suivant
                            print("[MOVE] 🔄 On essaie quand même le prochain waypoint...")
                            if currentWaypoint <= #waypoints then
                                moveToNextWaypoint()
                            end
                        end
                    end
                end
            end)
            
            logPath("[DEBUG] 4/5 - Après définition callback MoveToFinished")
            logPath("[MOVE] 🚀 Démarrage du pathfinding...")
            
            -- Sécurité: Capturer les erreurs
            local success, err = pcall(function()
                logPath("[DEBUG] 5/5 - Dans pcall, avant moveToNextWaypoint()")
                moveToNextWaypoint()
                logPath("[DEBUG] 6/5 - Après moveToNextWaypoint()")
            end)
            
            if not success then
                isPathfinding = false
                logPath("[MOVE] ❌ ERREUR CRITIQUE: " .. tostring(err))
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Erreur Pathfinding";
                    Text = "Erreur! Check F9";
                    Duration = 3;
                })
            else
                logPath("[DEBUG] ✅ moveToNextWaypoint() appelé sans erreur")
            end
            
            task.delay(30, function()
                if reachedConnection then reachedConnection:Disconnect() end
                isPathfinding = false
                logPath("[MOVE] ⏱️ Timeout - déplacement trop long (30s)")
            end)
        else
            isPathfinding = false
            logPath("[MOVE] ❌ Chemin impossible: " .. tostring(errorMessage or path.Status))
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Pathfinding";
                Text = "Impossible de calculer un chemin!";
                Duration = 3;
            })
        end
    end
    
    logPath("[DEBUG] Fin de testMoveToMonster()")
end

-- Fonction pour afficher/cacher le menu avec animation
function toggleMenu()
    menuVisible = not menuVisible
    
    if menuVisible then
        mainFrame.Visible = true
        mainFrame.Position = savedPosition or UDim2.new(0.5, -225, 0.5, -180)
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        
        local openTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = MENU_SIZE}
        )
        openTween:Play()
        
        print("[MOD MENU] Menu ouvert!")
    else
        local closeTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0)}
        )
        closeTween:Play()
        closeTween.Completed:Connect(function()
            mainFrame.Visible = false
        end)
        
        print("[MOD MENU] Menu fermé!")
    end
end

-- Initialisation
createMainGUI()

-- Raccourci clavier pour toggle le menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == TOGGLE_KEY then
        toggleMenu()
    end
end)

-- Messages de confirmation
print("=================================")
print("[MOD MENU] ✓ Script chargé!")
print("[MOD MENU] ✓ Appuie sur INSERT pour ouvrir")
print("=================================")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Pathfinding Mod Menu";
    Text = "Chargé! Appuie sur INSERT";
    Duration = 5;
})
