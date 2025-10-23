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

-- Variables globales
local menuVisible = false
local screenGui = nil
local mainFrame = nil
local savedPosition = nil -- Pour sauvegarder la position du menu
local enemiesList = {} -- Liste des ennemis détectés
local enemiesListUI = nil -- UI pour afficher les ennemis
local enemyConnection = nil -- Connection pour la détection continue

-- Configuration
local TOGGLE_KEY = Enum.KeyCode.Insert -- Touche pour ouvrir/fermer le menu
local MENU_SIZE = UDim2.new(0, 450, 0, 500)
local ANIMATION_TIME = 0.3
local ENEMY_DETECTION_RANGE = 100 -- Distance de détection des ennemis

-- Fonction pour créer le GUI principal
local function createMainGUI()
    print("[MOD MENU] Création de l'interface...")
    
    -- Supprimer l'ancien GUI s'il existe
    local oldGui = player.PlayerGui:FindFirstChild("FarmModMenuGUI")
    if oldGui then
        oldGui:Destroy()
        print("[MOD MENU] Ancien GUI supprimé")
    end
    
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
    
    -- Section Info
    local infoSection = createSection("📊 Informations", contentContainer)
    infoSection.LayoutOrder = 1
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 0, 60)
    infoText.Position = UDim2.new(0, 10, 0, 40)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Appuyez sur INSERT pour ouvrir/fermer ce menu\n\nUtilisez les boutons ci-dessous pour activer les fonctionnalités"
    infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoText.TextSize = 14
    infoText.Font = Enum.Font.Gotham
    infoText.TextWrapped = true
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.Parent = infoSection
    
    -- Section Auto Farm (pour plus tard)
    local farmSection = createSection("🌾 Auto Farm", contentContainer)
    farmSection.LayoutOrder = 2
    
    local farmInfo = Instance.new("TextLabel")
    farmInfo.Size = UDim2.new(1, -20, 0, 40)
    farmInfo.Position = UDim2.new(0, 10, 0, 40)
    farmInfo.BackgroundTransparency = 1
    farmInfo.Text = "Les fonctionnalités d'auto farm seront ajoutées ici"
    farmInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
    farmInfo.TextSize = 13
    farmInfo.Font = Enum.Font.Gotham
    farmInfo.TextWrapped = true
    farmInfo.TextXAlignment = Enum.TextXAlignment.Left
    farmInfo.Parent = farmSection
    
    -- Section Téléportation (pour plus tard)
    local tpSection = createSection("📍 Téléportation", contentContainer)
    tpSection.LayoutOrder = 3
    
    local tpInfo = Instance.new("TextLabel")
    tpInfo.Size = UDim2.new(1, -20, 0, 40)
    tpInfo.Position = UDim2.new(0, 10, 0, 40)
    tpInfo.BackgroundTransparency = 1
    tpInfo.Text = "Les options de téléportation seront ajoutées ici"
    tpInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
    tpInfo.TextSize = 13
    tpInfo.Font = Enum.Font.Gotham
    tpInfo.TextWrapped = true
    tpInfo.TextXAlignment = Enum.TextXAlignment.Left
    tpInfo.Parent = tpSection
    
    -- Section Détection Ennemis
    local enemySection = createSection("👾 Détection Ennemis", contentContainer)
    enemySection.LayoutOrder = 4
    enemySection.Size = UDim2.new(1, -20, 0, 200)
    
    -- Bouton pour activer/désactiver la détection
    local detectButton = Instance.new("TextButton")
    detectButton.Name = "DetectButton"
    detectButton.Size = UDim2.new(1, -20, 0, 35)
    detectButton.Position = UDim2.new(0, 10, 0, 40)
    detectButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    detectButton.BorderSizePixel = 0
    detectButton.Text = "🔍 Détecter les Ennemis"
    detectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    detectButton.TextSize = 14
    detectButton.Font = Enum.Font.GothamBold
    detectButton.Parent = enemySection
    
    local detectCorner = Instance.new("UICorner")
    detectCorner.CornerRadius = UDim.new(0, 8)
    detectCorner.Parent = detectButton
    
    -- Zone de texte pour afficher les ennemis
    enemiesListUI = Instance.new("TextLabel")
    enemiesListUI.Name = "EnemiesList"
    enemiesListUI.Size = UDim2.new(1, -20, 0, 110)
    enemiesListUI.Position = UDim2.new(0, 10, 0, 85)
    enemiesListUI.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    enemiesListUI.BorderSizePixel = 0
    enemiesListUI.Text = "Cliquez sur 'Détecter' pour scanner les ennemis"
    enemiesListUI.TextColor3 = Color3.fromRGB(150, 150, 150)
    enemiesListUI.TextSize = 12
    enemiesListUI.Font = Enum.Font.Code
    enemiesListUI.TextWrapped = true
    enemiesListUI.TextXAlignment = Enum.TextXAlignment.Left
    enemiesListUI.TextYAlignment = Enum.TextYAlignment.Top
    enemiesListUI.Parent = enemySection
    
    local enemiesCorner = Instance.new("UICorner")
    enemiesCorner.CornerRadius = UDim.new(0, 6)
    enemiesCorner.Parent = enemiesListUI
    
    -- Événement du bouton de détection
    detectButton.MouseButton1Click:Connect(function()
        detectEnemies()
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

-- Fonction pour détecter les ennemis
function detectEnemies()
    enemiesList = {} -- Réinitialiser la liste
    
    -- Récupérer le personnage du joueur
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        enemiesListUI.Text = "❌ Impossible de détecter (personnage non trouvé)"
        enemiesListUI.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    local playerPos = playerChar.HumanoidRootPart.Position
    
    print("[MOD MENU] Recherche d'ennemis...")
    
    -- Méthode 1: Chercher dans le workspace tous les modèles avec un Humanoid
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent then
            local enemyModel = obj.Parent
            
            -- Vérifier que ce n'est pas le joueur lui-même
            if enemyModel ~= playerChar then
                -- Vérifier si c'est un personnage (a un HumanoidRootPart)
                local rootPart = enemyModel:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local distance = (rootPart.Position - playerPos).Magnitude
                    
                    -- Vérifier si dans la portée
                    if distance <= ENEMY_DETECTION_RANGE then
                        table.insert(enemiesList, {
                            name = enemyModel.Name,
                            distance = math.floor(distance),
                            health = obj.Health,
                            maxHealth = obj.MaxHealth,
                            model = enemyModel,
                            humanoid = obj
                        })
                    end
                end
            end
        end
    end
    
    -- Méthode 2: Chercher dans les dossiers communs d'ennemis
    local commonEnemyFolders = {"Enemies", "NPCs", "Monsters", "Mobs", "Characters"}
    for _, folderName in pairs(commonEnemyFolders) do
        local folder = game.Workspace:FindFirstChild(folderName)
        if folder then
            for _, enemy in pairs(folder:GetChildren()) do
                if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                    local distance = (enemy.HumanoidRootPart.Position - playerPos).Magnitude
                    
                    if distance <= ENEMY_DETECTION_RANGE then
                        -- Vérifier si pas déjà dans la liste
                        local alreadyAdded = false
                        for _, existing in pairs(enemiesList) do
                            if existing.model == enemy then
                                alreadyAdded = true
                                break
                            end
                        end
                        
                        if not alreadyAdded then
                            table.insert(enemiesList, {
                                name = enemy.Name,
                                distance = math.floor(distance),
                                health = enemy.Humanoid.Health,
                                maxHealth = enemy.Humanoid.MaxHealth,
                                model = enemy,
                                humanoid = enemy.Humanoid
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Afficher les résultats
    if #enemiesList == 0 then
        enemiesListUI.Text = "❌ Aucun ennemi trouvé dans un rayon de " .. ENEMY_DETECTION_RANGE .. " studs"
        enemiesListUI.TextColor3 = Color3.fromRGB(255, 150, 50)
        print("[MOD MENU] Aucun ennemi détecté")
    else
        -- Trier par distance
        table.sort(enemiesList, function(a, b) return a.distance < b.distance end)
        
        local displayText = "✓ " .. #enemiesList .. " ennemi(s) détecté(s):\n\n"
        for i, enemy in ipairs(enemiesList) do
            if i <= 5 then -- Afficher maximum 5 ennemis
                displayText = displayText .. string.format(
                    "%d. %s\n   💚 HP: %d/%d | 📏 %dm\n",
                    i,
                    enemy.name,
                    math.floor(enemy.health),
                    math.floor(enemy.maxHealth),
                    enemy.distance
                )
            end
        end
        
        if #enemiesList > 5 then
            displayText = displayText .. "\n... et " .. (#enemiesList - 5) .. " autre(s)"
        end
        
        enemiesListUI.Text = displayText
        enemiesListUI.TextColor3 = Color3.fromRGB(100, 255, 100)
        print("[MOD MENU] " .. #enemiesList .. " ennemi(s) détecté(s)")
    end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Détection Ennemis";
        Text = #enemiesList .. " ennemi(s) trouvé(s)";
        Duration = 3;
    })
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
print("=================================")

-- Notification dans le jeu
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Mod Menu";
    Text = "Chargé! Appuie sur INSERT";
    Duration = 5;
})

