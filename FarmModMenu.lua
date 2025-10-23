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

-- Supprimer tous les anciens ESP (OPTIMISÉ - seulement dans les dossiers d'ennemis)
local cleanupFolders = {"Enemies", "NPCs", "Monsters", "Mobs", "Dungeon", "DungeonMobs", "Boss", "Bosses"}
local espCleaned = 0

for _, folderName in pairs(cleanupFolders) do
    local folder = game.Workspace:FindFirstChild(folderName)
    if folder then
        for _, obj in pairs(folder:GetDescendants()) do
            if obj.Name == "EnemyESP" and obj:IsA("Highlight") then
                obj:Destroy()
                espCleaned = espCleaned + 1
            end
        end
    end
end

if espCleaned > 0 then
    print("[MOD MENU] ✓ " .. espCleaned .. " anciens ESP supprimés")
end

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
local espEnabled = false -- ESP activé ou non
local espConnection = nil -- Connection pour l'ESP continu
local espFolder = nil -- Dossier pour stocker les ESP
local espToggleButton = nil -- Référence au bouton toggle

-- Configuration
local TOGGLE_KEY = Enum.KeyCode.Insert -- Touche pour ouvrir/fermer le menu
local MENU_SIZE = UDim2.new(0, 450, 0, 500)
local ANIMATION_TIME = 0.3
local ESP_UPDATE_INTERVAL = 2 -- Mettre à jour l'ESP toutes les 2 secondes (optimisé)
local ENEMY_FOLDERS = {"Enemies", "NPCs", "Monsters", "Mobs", "Dungeon", "DungeonMobs", "Boss", "Bosses"} -- Dossiers où chercher les ennemis

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
    
    -- Section Debug Entités
    local debugSection = createSection("🔍 Debug Entités", contentContainer)
    debugSection.LayoutOrder = 1
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
    
    -- Section ESP Ennemis
    local espSection = createSection("👾 ESP Ennemis", contentContainer)
    espSection.LayoutOrder = 2
    espSection.Size = UDim2.new(1, -20, 0, 90)
    
    -- Bouton toggle ESP
    espToggleButton = Instance.new("TextButton")
    espToggleButton.Name = "ESPToggle"
    espToggleButton.Size = UDim2.new(1, -20, 0, 40)
    espToggleButton.Position = UDim2.new(0, 10, 0, 40)
    espToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    espToggleButton.BorderSizePixel = 0
    espToggleButton.Text = "🔴 ESP: OFF"
    espToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    espToggleButton.TextSize = 15
    espToggleButton.Font = Enum.Font.GothamBold
    espToggleButton.Parent = espSection
    
    local espBtnCorner = Instance.new("UICorner")
    espBtnCorner.CornerRadius = UDim.new(0, 8)
    espBtnCorner.Parent = espToggleButton
    
    -- Événement du bouton ESP
    espToggleButton.MouseButton1Click:Connect(function()
        toggleESP()
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
                    print("[MOD MENU] Position sauvegardée:", savedPosition)
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

-- Fonction pour créer un ESP autour d'un ennemi
function createESP(enemy)
    -- Vérifier que l'ennemi a bien les parties nécessaires
    if not enemy:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    -- Vérifier si un ESP existe déjà pour cet ennemi
    if enemy:FindFirstChild("EnemyESP") then
        return
    end
    
    -- Créer le Highlight (encadré rouge)
    local highlight = Instance.new("Highlight")
    highlight.Name = "EnemyESP"
    highlight.Adornee = enemy
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = enemy
    
    print("[ESP] ESP créé pour:", enemy.Name)
end

-- Fonction pour supprimer tous les ESP
function clearAllESP()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj.Name == "EnemyESP" and obj:IsA("Highlight") then
            obj:Destroy()
        end
    end
    print("[ESP] Tous les ESP supprimés")
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

-- Fonction pour mettre à jour les ESP (OPTIMISÉE)
function updateESP()
    if not espEnabled then
        return
    end
    
    local playerChar = player.Character
    if not playerChar then
        return
    end
    
    local enemiesFound = 0
    local processedModels = {} -- Pour éviter les doublons
    
    -- OPTIMISATION: Chercher UNIQUEMENT dans les dossiers d'ennemis spécifiques
    for _, folderName in pairs(ENEMY_FOLDERS) do
        local folder = game.Workspace:FindFirstChild(folderName)
        if folder then
            for _, child in pairs(folder:GetChildren()) do
                -- Si c'est un modèle avec un Humanoid
                if child:IsA("Model") and not processedModels[child] then
                    local humanoid = child:FindFirstChild("Humanoid")
                    local rootPart = child:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and rootPart then
                        -- Vérifier que ce n'est PAS un joueur
                        if not isPlayer(child) and child ~= playerChar then
                            createESP(child)
                            enemiesFound = enemiesFound + 1
                            processedModels[child] = true
                        end
                    end
                end
                
                -- Chercher aussi dans les sous-dossiers (1 niveau)
                if child:IsA("Folder") or child:IsA("Model") then
                    for _, subChild in pairs(child:GetChildren()) do
                        if subChild:IsA("Model") and not processedModels[subChild] then
                            local humanoid = subChild:FindFirstChild("Humanoid")
                            local rootPart = subChild:FindFirstChild("HumanoidRootPart")
                            
                            if humanoid and rootPart then
                                if not isPlayer(subChild) and subChild ~= playerChar then
                                    createESP(subChild)
                                    enemiesFound = enemiesFound + 1
                                    processedModels[subChild] = true
                                end
                            end
                        end
                    end
                end
            end
            print("[ESP] Dossier '" .. folderName .. "' scanné")
        end
    end
    
    if enemiesFound > 0 then
        print("[ESP] " .. enemiesFound .. " ennemis marqués (performance optimisée)")
    end
end

-- Fonction pour activer/désactiver l'ESP
function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        -- Activer l'ESP
        espToggleButton.Text = "🟢 ESP: ON"
        espToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        print("[ESP] ESP activé!")
        
        -- Première mise à jour immédiate
        updateESP()
        
        -- Boucle de mise à jour continue (optimisée avec spawn)
        espConnection = task.spawn(function()
            while espEnabled and _G.FARM_MOD_MENU_ACTIVE do
                task.wait(ESP_UPDATE_INTERVAL)
                if espEnabled and _G.FARM_MOD_MENU_ACTIVE then
                    updateESP()
                end
            end
        end)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ESP Ennemis";
            Text = "Activé! Les ennemis sont encadrés en rouge";
            Duration = 3;
        })
    else
        -- Désactiver l'ESP
        espToggleButton.Text = "🔴 ESP: OFF"
        espToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        -- La boucle s'arrêtera automatiquement car espEnabled = false
        espConnection = nil
        
        -- Supprimer tous les ESP
        clearAllESP()
        
        print("[ESP] ESP désactivé!")
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ESP Ennemis";
            Text = "Désactivé";
            Duration = 2;
        })
    end
end

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

