-- Mod Menu Auto Farm pour Roblox
-- Projet d'école

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

-- ===== NETTOYAGE DE L'ANCIENNE VERSION (OPTIMISÉ) =====
print("[MOD MENU] Nettoyage de l'ancienne version...")

-- Supprimer l'ancien GUI
local oldGui = player.PlayerGui:FindFirstChild("FarmModMenuGUI")
if oldGui then
    oldGui:Destroy()
    print("[MOD MENU] ✓ Ancien GUI supprimé")
end

-- Pas d'ESP à nettoyer (fonctionnalité supprimée)

-- Forcer l'arrêt de toutes les anciennes boucles en mettant un flag global
_G.FARM_MOD_MENU_ACTIVE = false
task.wait(0.5) -- Attendre que les anciennes boucles s'arrêtent

print("[MOD MENU] ✓ Nettoyage terminé!")

-- Activer cette instance du script
_G.FARM_MOD_MENU_ACTIVE = true

-- Variables globales
local menuVisible = false
local screenGui = nil
local mainFrame = nil
local savedPosition = nil -- Pour sauvegarder la position du menu
local autoFarmEnabled = false -- Auto farm activé ou non
local autoFarmConnection = nil -- Connection pour l'auto farm
local currentTarget = nil -- Monstre ciblé actuellement

-- Système d'enregistrement des actions
local isRecording = false
local recordedActions = {}
local actionLogLabel = nil

-- Configuration
local TOGGLE_KEY = Enum.KeyCode.Insert -- Touche pour ouvrir/fermer le menu
local MENU_SIZE = UDim2.new(0, 450, 0, 500)
local ANIMATION_TIME = 0.3
local ENEMY_FOLDERS = {"Enemies", "NPCs", "Monsters", "Mobs", "Dungeon", "DungeonMobs", "Boss", "Bosses", "IzvDf"} -- Dossiers où chercher les ennemis
local detectedFolders = {} -- Dossiers détectés automatiquement pendant le debug

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
    -- Utiliser la position sauvegardée ou la position par défaut
    mainFrame.Position = savedPosition or UDim2.new(0.5, -225, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false -- Caché par défaut
    mainFrame.Parent = screenGui
    
    -- Coins arrondis pour la frame principale
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    -- Bordure lumineuse
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
    
    -- Titre
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎮 Auto Farm Mod Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Bouton de fermeture
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
    
    -- Container pour le contenu
    local contentContainer = Instance.new("ScrollingFrame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -20, 1, -70)
    contentContainer.Position = UDim2.new(0, 10, 0, 60)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.ScrollBarThickness = 6
    contentContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
    contentContainer.Parent = mainFrame
    
    -- Layout pour organiser les sections
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = contentContainer
    
    -- Section Enregistrement Actions
    local recordSection = createSection("🎬 Enregistrement Sélection Donjon", contentContainer)
    recordSection.LayoutOrder = 1
    recordSection.Size = UDim2.new(1, -20, 0, 300)
    
    -- Bouton Start/Stop Recording
    local recordBtn = Instance.new("TextButton")
    recordBtn.Size = UDim2.new(1, -20, 0, 45)
    recordBtn.Position = UDim2.new(0, 10, 0, 45)
    recordBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    recordBtn.Text = "🔴 Démarrer l'enregistrement"
    recordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    recordBtn.TextSize = 14
    recordBtn.Font = Enum.Font.GothamBold
    recordBtn.Parent = recordSection
    local rc1 = Instance.new("UICorner")
    rc1.CornerRadius = UDim.new(0, 8)
    rc1.Parent = recordBtn
    
    -- Zone d'affichage des actions
    actionLogLabel = Instance.new("TextLabel")
    actionLogLabel.Name = "ActionLog"
    actionLogLabel.Size = UDim2.new(1, -20, 0, 210)
    actionLogLabel.Position = UDim2.new(0, 10, 0, 100)
    actionLogLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    actionLogLabel.BorderSizePixel = 0
    actionLogLabel.Text = "Clique sur 'Démarrer' puis sélectionne:\n1. Le donjon\n2. La difficulté\n3. Le gamemode\n4. Valide\n\nToutes tes actions seront enregistrées!"
    actionLogLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    actionLogLabel.TextSize = 11
    actionLogLabel.Font = Enum.Font.Code
    actionLogLabel.TextWrapped = true
    actionLogLabel.TextXAlignment = Enum.TextXAlignment.Left
    actionLogLabel.TextYAlignment = Enum.TextYAlignment.Top
    actionLogLabel.Parent = recordSection
    local rc2 = Instance.new("UICorner")
    rc2.CornerRadius = UDim.new(0, 6)
    rc2.Parent = actionLogLabel
    
    -- Événement du bouton
    recordBtn.MouseButton1Click:Connect(function()
        toggleRecording(recordBtn)
    end)
    
    -- Section Debug Entités
    local debugSection = createSection("🔍 Debug Entités", contentContainer)
    debugSection.LayoutOrder = 2
    debugSection.Size = UDim2.new(1, -20, 0, 280)
    
    -- Bouton de scan
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(1, -20, 0, 40)
    scanButton.Position = UDim2.new(0, 10, 0, 40)
    scanButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    scanButton.BorderSizePixel = 0
    scanButton.Text = "🔎 Scanner toutes les entités"
    scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanButton.TextSize = 15
    scanButton.Font = Enum.Font.GothamBold
    scanButton.Parent = debugSection
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 8)
    scanCorner.Parent = scanButton
    
    -- Zone d'affichage du debug
    local debugOutput = Instance.new("TextLabel")
    debugOutput.Name = "DebugOutput"
    debugOutput.Size = UDim2.new(1, -20, 0, 200)
    debugOutput.Position = UDim2.new(0, 10, 0, 90)
    debugOutput.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    debugOutput.BorderSizePixel = 0
    debugOutput.Text = "Clique sur 'Scanner' pour voir toutes les entités\n(joueurs et monstres)"
    debugOutput.TextColor3 = Color3.fromRGB(200, 200, 200)
    debugOutput.TextSize = 11
    debugOutput.Font = Enum.Font.Code
    debugOutput.TextWrapped = true
    debugOutput.TextXAlignment = Enum.TextXAlignment.Left
    debugOutput.TextYAlignment = Enum.TextYAlignment.Top
    debugOutput.Parent = debugSection
    
    local debugCorner = Instance.new("UICorner")
    debugCorner.CornerRadius = UDim.new(0, 6)
    debugCorner.Parent = debugOutput
    
    -- Événement du bouton scan
    scanButton.MouseButton1Click:Connect(function()
        debugScanEntities(debugOutput)
    end)
    
    -- Section Déplacement Auto
    local moveSection = createSection("🎯 Pathfinding vers Monstre", contentContainer)
    moveSection.LayoutOrder = 3
    moveSection.Size = UDim2.new(1, -20, 0, 100)
    
    -- Bouton Test déplacement
    local testMoveBtn = Instance.new("TextButton")
    testMoveBtn.Size = UDim2.new(1, -20, 0, 45)
    testMoveBtn.Position = UDim2.new(0, 10, 0, 45)
    testMoveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    testMoveBtn.Text = "🧪 TESTER: Aller au monstre le plus proche"
    testMoveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    testMoveBtn.TextSize = 14
    testMoveBtn.Font = Enum.Font.GothamBold
    testMoveBtn.Parent = moveSection
    local pf4 = Instance.new("UICorner")
    pf4.CornerRadius = UDim.new(0, 8)
    pf4.Parent = testMoveBtn
    
    -- Événement test déplacement
    testMoveBtn.MouseButton1Click:Connect(function()
        testMoveToMonster()
    end)
    
    -- Mise à jour de la taille du canvas
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Rendre le menu déplaçable
    makeDraggable(mainFrame, titleBar)
    
    -- Événement du bouton de fermeture
    closeButton.MouseButton1Click:Connect(function()
        toggleMenu()
    end)
    
    print("[MOD MENU] Interface créée avec succès!")
    
    return screenGui
end

-- Fonction pour créer une section
function createSection(titleText, parent)
    local section = Instance.new("Frame")
    section.Name = titleText
    section.Size = UDim2.new(1, -20, 0, 100) -- Hauteur initiale, sera ajustée
    section.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 8)
    sectionCorner.Parent = section
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Size = UDim2.new(1, -20, 0, 30)
    sectionTitle.Position = UDim2.new(0, 10, 0, 5)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = titleText
    sectionTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    sectionTitle.TextSize = 16
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = section
    
    return section
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
                    -- Sauvegarder la position quand on arrête de déplacer
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

-- Fonction pour trouver le monstre le plus proche
function findNearestMonster()
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        print("[MOVE] ❌ Personnage non trouvé")
        return nil
    end
    
    local playerPos = playerChar.HumanoidRootPart.Position
    local nearestMonster = nil
    local nearestDistance = math.huge
    local monstresTrouves = 0
    
    print("[MOVE] Recherche du monstre le plus proche...")
    
    -- Scanner TOUT le Workspace (même méthode que le debug scan)
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent then
            local model = obj.Parent
            local rootPart = model:FindFirstChild("HumanoidRootPart")
            
            if rootPart and obj.Health > 0 then
                -- Vérifier que ce n'est PAS un joueur et PAS nous
                if model ~= playerChar and not isPlayer(model) then
                    local distance = (rootPart.Position - playerPos).Magnitude
                    monstresTrouves = monstresTrouves + 1
                    
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestMonster = model
                        
                        -- Sauvegarder automatiquement le dossier parent
                        if model.Parent and model.Parent ~= game.Workspace then
                            local folderName = model.Parent.Name
                            local alreadyInList = false
                            
                            for _, existing in pairs(ENEMY_FOLDERS) do
                                if existing == folderName then
                                    alreadyInList = true
                                    break
                                end
                            end
                            
                            if not alreadyInList and not detectedFolders[folderName] then
                                table.insert(ENEMY_FOLDERS, folderName)
                                detectedFolders[folderName] = true
                            end
                        end
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

-- Fonction pour scanner et débugger toutes les entités
function debugScanEntities(outputLabel)
    print("========== DEBUG SCAN ==========")
    outputLabel.Text = "🔍 Scan en cours..."
    outputLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    task.wait(0.1)
    
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        outputLabel.Text = "❌ Erreur: Personnage non trouvé"
        outputLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    local playerPos = playerChar.HumanoidRootPart.Position
    local allEntities = {}
    local scanRange = 150 -- Distance de scan
    
    -- Scanner TOUT le Workspace
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent then
            local model = obj.Parent
            local rootPart = model:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                local distance = (rootPart.Position - playerPos).Magnitude
                
                if distance <= scanRange and model ~= playerChar then
                    -- Déterminer le type
                    local entityType = "INCONNU"
                    local isPlayerChar = Players:GetPlayerFromCharacter(model)
                    
                    if isPlayerChar then
                        entityType = "👤 JOUEUR"
                    else
                        -- Vérifier si le nom correspond à un joueur
                        local nameMatchPlayer = false
                        for _, plr in pairs(Players:GetPlayers()) do
                            if model.Name == plr.Name or model.Name == plr.DisplayName then
                                nameMatchPlayer = true
                                break
                            end
                        end
                        
                        if nameMatchPlayer then
                            entityType = "👤 JOUEUR (nom)"
                        else
                            entityType = "👾 MONSTRE"
                        end
                    end
                    
                    -- Trouver le parent/dossier
                    local parentInfo = "Workspace"
                    if model.Parent and model.Parent ~= game.Workspace then
                        parentInfo = model.Parent.Name
                        
                        -- Si c'est un monstre, ajouter automatiquement le dossier à la liste
                        if entityType == "👾 MONSTRE" then
                            local folderName = model.Parent.Name
                            local alreadyInList = false
                            
                            for _, existing in pairs(ENEMY_FOLDERS) do
                                if existing == folderName then
                                    alreadyInList = true
                                    break
                                end
                            end
                            
                            if not alreadyInList and not detectedFolders[folderName] then
                                table.insert(ENEMY_FOLDERS, folderName)
                                detectedFolders[folderName] = true
                                print("[DEBUG] ✓ Nouveau dossier d'ennemis détecté et ajouté: " .. folderName)
                            end
                        end
                    end
                    
                    table.insert(allEntities, {
                        name = model.Name,
                        type = entityType,
                        distance = math.floor(distance),
                        health = math.floor(obj.Health),
                        maxHealth = math.floor(obj.MaxHealth),
                        parent = parentInfo,
                        model = model
                    })
                end
            end
        end
    end
    
    -- Trier par distance
    table.sort(allEntities, function(a, b) return a.distance < b.distance end)
    
    -- Afficher les résultats
    if #allEntities == 0 then
        outputLabel.Text = "❌ Aucune entité trouvée dans " .. scanRange .. " studs"
        outputLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
        print("[DEBUG] Aucune entité trouvée")
    else
        local displayText = "✓ " .. #allEntities .. " entité(s) trouvée(s):\n\n"
        
        for i, entity in ipairs(allEntities) do
            if i <= 10 then -- Afficher max 10
                displayText = displayText .. string.format(
                    "%s %s\n  📏 %dm | 💚 %d/%d\n  📁 %s\n\n",
                    entity.type,
                    entity.name,
                    entity.distance,
                    entity.health,
                    entity.maxHealth,
                    entity.parent
                )
                
                -- Aussi dans la console pour plus de détails
                print(string.format(
                    "[DEBUG] %s | Nom: %s | Distance: %dm | HP: %d/%d | Dossier: %s",
                    entity.type,
                    entity.name,
                    entity.distance,
                    entity.health,
                    entity.maxHealth,
                    entity.parent
                ))
            end
        end
        
        if #allEntities > 10 then
            displayText = displayText .. "... et " .. (#allEntities - 10) .. " autre(s)"
        end
        
        outputLabel.Text = displayText
        outputLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        print("[DEBUG] Total: " .. #allEntities .. " entités scannées")
        
        -- Afficher les dossiers de monstres
        local folderList = "Dossiers monstres: "
        for i, folder in ipairs(ENEMY_FOLDERS) do
            if i <= 5 then
                folderList = folderList .. folder .. ", "
            end
        end
        print("[DEBUG] " .. folderList)
        print("========== FIN DU SCAN ==========")
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Debug Scan";
        Text = #allEntities .. " entité(s) trouvée(s)";
        Duration = 3;
    })
end

-- Fonction pour vérifier si un modèle est un joueur
function isPlayer(model)
    -- Vérifier si c'est un personnage de joueur
    if Players:GetPlayerFromCharacter(model) then
        return true
    end
    
    -- Vérifier si le nom correspond à un joueur
    for _, plr in pairs(Players:GetPlayers()) do
        if model.Name == plr.Name or model.Name == plr.DisplayName then
            return true
        end
    end
    
    return false
end

-- Fonction pour tester le déplacement vers un monstre (PATHFINDING uniquement)
function testMoveToMonster()
    print("========== TEST PATHFINDING ==========")
    
    local monster, distance = findNearestMonster()
    if not monster then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Pathfinding";
            Text = "Aucun monstre trouvé!";
            Duration = 3;
        })
        return
    end
    
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        print("[MOVE] Personnage non trouvé")
        return
    end
    
    local humanoidRootPart = playerChar.HumanoidRootPart
    local targetPos = monster.HumanoidRootPart.Position
    
    print(string.format("[MOVE] Cible: %s (%dm)", monster.Name, math.floor(distance)))
    
    -- PathfindingService (contourne les murs)
    print("[MOVE] Calcul du chemin...")
    local PathfindingService = game:GetService("PathfindingService")
    local humanoid = playerChar:FindFirstChild("Humanoid")
    
    if humanoid then
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentMaxSlope = 45,
            Costs = {
                Water = 20
            }
        })
        
        local success, errorMessage = pcall(function()
            path:ComputeAsync(humanoidRootPart.Position, targetPos)
        end)
        
        if success and path.Status == Enum.PathStatus.Success then
            print("[MOVE] Chemin trouvé!")
            local waypoints = path:GetWaypoints()
            print(string.format("[MOVE] %d waypoints - déplacement en cours...", #waypoints))
            
            -- Suivre le chemin COMPLET
            local currentWaypoint = 2 -- Skip le premier (position actuelle)
            local pathBlocked = false
            
            local function moveToNextWaypoint()
                if currentWaypoint <= #waypoints and not pathBlocked then
                    local waypoint = waypoints[currentWaypoint]
                    print(string.format("[MOVE] Waypoint %d/%d - Distance: %.1fm", currentWaypoint, #waypoints, (waypoint.Position - humanoidRootPart.Position).Magnitude))
                    
                    humanoid:MoveTo(waypoint.Position)
                    
                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        humanoid.Jump = true
                        print("[MOVE] Saut requis!")
                    end
                    
                    currentWaypoint = currentWaypoint + 1
                end
            end
            
            -- Connection pour gérer la progression
            local reachedConnection
            local blockedConnection
            
            reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
                print(string.format("[MOVE] MoveToFinished appelé - Reached: %s - Waypoint: %d/%d", tostring(reached), currentWaypoint - 1, #waypoints))
                
                if reached then
                    print("[MOVE] Waypoint atteint avec succès!")
                    
                    if currentWaypoint <= #waypoints then
                        -- Continuer vers le prochain waypoint
                        print("[MOVE] Continuation vers le prochain waypoint...")
                        moveToNextWaypoint()
                    else
                        -- On a fini !
                        reachedConnection:Disconnect()
                        if blockedConnection then blockedConnection:Disconnect() end
                        
                        print("[MOVE] === ARRIVÉ AU MONSTRE! ===")
                        
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Pathfinding";
                            Text = "Arrivé devant " .. monster.Name;
                            Duration = 2;
                        })
                    end
                else
                    -- Chemin bloqué
                    pathBlocked = true
                    reachedConnection:Disconnect()
                    if blockedConnection then blockedConnection:Disconnect() end
                    
                    local distanceToTarget = (humanoidRootPart.Position - targetPos).Magnitude
                    print(string.format("[MOVE] BLOQUÉ au waypoint %d/%d - Distance restante: %.1fm", currentWaypoint - 1, #waypoints, distanceToTarget))
                    print("[MOVE] Raison possible: Obstacle, saut raté, ou chemin impossible")
                    print("[MOVE] Position actuelle:", humanoidRootPart.Position)
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Pathfinding";
                        Text = "Bloqué! Check console F9";
                        Duration = 3;
                    })
                end
            end)
            
            -- Démarrer le mouvement
            moveToNextWaypoint()
            
            -- Timeout de sécurité (30 secondes)
            task.delay(30, function()
                if reachedConnection then reachedConnection:Disconnect() end
                if blockedConnection then blockedConnection:Disconnect() end
                print("[MOVE] Timeout - déplacement trop long")
            end)
        else
            print("[MOVE] Chemin impossible:", errorMessage or path.Status)
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Pathfinding";
                Text = "Impossible de calculer un chemin!";
                Duration = 3;
            })
        end
    end
    
    print("========== FIN TEST ==========")
end

-- Fonction pour logger une action
function logAction(actionType, details)
    local timestamp = os.date("%H:%M:%S")
    local action = {
        time = timestamp,
        type = actionType,
        details = details
    }
    
    table.insert(recordedActions, action)
    
    -- Log dans la console
    print(string.format("[ACTION] [%s] %s: %s", timestamp, actionType, details))
    
    -- Mettre à jour l'affichage
    if actionLogLabel then
        local displayText = string.format("✅ Enregistrement actif (%d actions)\n\n", #recordedActions)
        
        local start = math.max(1, #recordedActions - 8)
        for i = start, #recordedActions do
            local act = recordedActions[i]
            displayText = displayText .. string.format("[%s] %s\n", act.time, act.details)
        end
        
        actionLogLabel.Text = displayText
        actionLogLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end

-- Fonction pour démarrer/arrêter l'enregistrement
function toggleRecording(button)
    isRecording = not isRecording
    
    if isRecording then
        button.Text = "⏹️ Arrêter l'enregistrement"
        button.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        recordedActions = {}
        
        print("========== ENREGISTREMENT DÉMARRÉ ==========")
        print("[RECORD] Toutes les interactions vont être enregistrées")
        print("[RECORD] Clique sur les boutons du jeu pour sélectionner le donjon")
        
        actionLogLabel.Text = "🔴 ENREGISTREMENT EN COURS...\n\nEn attente d'actions..."
        actionLogLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        -- Démarrer le tracking des clics
        startClickTracking()
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Enregistrement";
            Text = "Démarré! Sélectionne ton donjon";
            Duration = 3;
        })
    else
        button.Text = "🔴 Démarrer l'enregistrement"
        button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        print("========== ENREGISTREMENT ARRÊTÉ ==========")
        print(string.format("[RECORD] Total d'actions enregistrées: %d", #recordedActions))
        
        -- Afficher le récapitulatif
        print("[RECORD] === RÉCAPITULATIF ===")
        for i, action in ipairs(recordedActions) do
            print(string.format("[RECORD] %d. [%s] %s", i, action.time, action.details))
        end
        print("[RECORD] ======================")
        
        if actionLogLabel then
            local displayText = string.format("⏹️ Enregistrement terminé\n%d actions enregistrées\n\n", #recordedActions)
            for i, act in ipairs(recordedActions) do
                if i <= 10 then
                    displayText = displayText .. string.format("%d. %s\n", i, act.details)
                end
            end
            actionLogLabel.Text = displayText
            actionLogLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        
        -- Arrêter le tracking
        stopClickTracking()
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Enregistrement";
            Text = #recordedActions .. " actions sauvegardées";
            Duration = 3;
        })
    end
end

-- Variables pour le tracking
local clickConnection = nil
local guiChangedConnection = nil

-- Fonction pour tracker tous les clics
function startClickTracking()
    print("[TRACKER] Démarrage du tracking des clics...")
    
    -- Tracker les clics de souris
    clickConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not isRecording then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Essayer de trouver sur quoi l'utilisateur a cliqué
            local mouse = player:GetMouse()
            local target = mouse.Target
            
            if target then
                local gui = target:FindFirstAncestorOfClass("ScreenGui") or target:FindFirstAncestorOfClass("SurfaceGui")
                
                if gui and gui.Parent ~= player.PlayerGui then
                    -- C'est probablement un GUI du jeu
                    local guiName = gui.Name
                    local targetName = target.Name
                    
                    -- Chercher un TextButton ou TextLabel parent
                    local button = target:FindFirstAncestorWhichIsA("TextButton") or target:FindFirstAncestorWhichIsA("ImageButton")
                    
                    if button then
                        local buttonText = button:FindFirstChild("TextLabel") and button.TextLabel.Text or button.Text or "Bouton sans texte"
                        logAction("CLIC BOUTON", string.format("GUI: %s | Bouton: %s | Texte: %s", guiName, button.Name, buttonText))
                    else
                        logAction("CLIC GUI", string.format("GUI: %s | Objet: %s", guiName, targetName))
                    end
                end
            end
        end
    end)
    
    -- Tracker les changements de GUI (nouveau menu qui apparaît)
    task.spawn(function()
        while isRecording and _G.FARM_MOD_MENU_ACTIVE do
            for _, gui in pairs(player.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name ~= "FarmModMenuGUI" then
                    -- Nouveau GUI détecté
                    local guiName = gui.Name
                    
                    -- Chercher des boutons importants
                    for _, descendant in pairs(gui:GetDescendants()) do
                        if descendant:IsA("TextButton") or descendant:IsA("TextLabel") then
                            local text = descendant.Text
                            if text and text ~= "" then
                                print(string.format("[TRACKER] 📋 GUI actif: %s | Élément: %s (Texte: %s)", guiName, descendant.Name, text))
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
    
    print("[TRACKER] ✓ Tracking actif")
end

-- Fonction pour arrêter le tracking
function stopClickTracking()
    if clickConnection then
        clickConnection:Disconnect()
        clickConnection = nil
    end
    
    print("[TRACKER] Tracking arrêté")
end

-- Gérer la téléportation (le script survit)
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    print("[SYSTEM] 🔄 Nouveau personnage détecté (téléportation?)")
    print("[SYSTEM] ℹ️ Le mod menu reste actif!")
    
    if isRecording then
        logAction("TÉLÉPORTATION", "Nouveau personnage chargé - probablement téléporté dans le donjon")
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Téléportation détectée";
            Text = "Script toujours actif!";
            Duration = 3;
        })
    end
end)

-- Fonction pour afficher/cacher le menu avec animation
function toggleMenu()
    menuVisible = not menuVisible
    
    if menuVisible then
        mainFrame.Visible = true
        -- Utiliser la position sauvegardée ou la position par défaut
        mainFrame.Position = savedPosition or UDim2.new(0.5, -225, 0.5, -250)
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        
        -- Animation d'ouverture
        local openTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = MENU_SIZE}
        )
        openTween:Play()
        
        print("[MOD MENU] Menu ouvert!")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Mod Menu";
            Text = "Menu ouvert";
            Duration = 2;
        })
    else
        -- Animation de fermeture
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
print("[MOD MENU] ✓ Script chargé avec succès!")
print("[MOD MENU] ✓ Appuyez sur INSERT pour ouvrir le menu")
print("[MOD MENU] ℹ️  Tu peux réinjecter sans restart Roblox!")
print("=================================")

-- Notification dans le jeu
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✓ Auto Farm Mod Menu";
    Text = "Prêt! Appuie sur INSERT";
    Duration = 5;
})

