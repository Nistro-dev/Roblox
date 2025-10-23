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

-- ===== NETTOYAGE DE L'ANCIENNE VERSION =====
-- Supprimer l'ancien GUI
local oldGui = player.PlayerGui:FindFirstChild("FarmModMenuGUI")
if oldGui then
    oldGui:Destroy()
    print("[MOD MENU] Ancien GUI supprimé")
end

-- Supprimer tous les anciens ESP
for _, obj in pairs(game.Workspace:GetDescendants()) do
    if obj.Name == "EnemyESP" then
        obj:Destroy()
    end
end

-- Supprimer le dossier ESP s'il existe
local oldESPFolder = game.CoreGui:FindFirstChild("EnemyESPFolder")
if oldESPFolder then
    oldESPFolder:Destroy()
    print("[MOD MENU] Anciens ESP supprimés")
end

print("[MOD MENU] Nettoyage terminé!")

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
local ESP_UPDATE_INTERVAL = 0.5 -- Mettre à jour l'ESP toutes les 0.5 secondes

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
    
    -- Section ESP Ennemis
    local espSection = createSection("👾 ESP Ennemis", contentContainer)
    espSection.LayoutOrder = 4
    espSection.Size = UDim2.new(1, -20, 0, 130)
    
    -- Description
    local espDesc = Instance.new("TextLabel")
    espDesc.Size = UDim2.new(1, -20, 0, 35)
    espDesc.Position = UDim2.new(0, 10, 0, 40)
    espDesc.BackgroundTransparency = 1
    espDesc.Text = "Active un encadré rouge autour de tous les ennemis du donjon"
    espDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
    espDesc.TextSize = 12
    espDesc.Font = Enum.Font.Gotham
    espDesc.TextWrapped = true
    espDesc.TextXAlignment = Enum.TextXAlignment.Left
    espDesc.Parent = espSection
    
    -- Bouton toggle ESP
    espToggleButton = Instance.new("TextButton")
    espToggleButton.Name = "ESPToggle"
    espToggleButton.Size = UDim2.new(1, -20, 0, 40)
    espToggleButton.Position = UDim2.new(0, 10, 0, 80)
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

-- Fonction pour mettre à jour les ESP
function updateESP()
    if not espEnabled then
        return
    end
    
    local playerChar = player.Character
    if not playerChar then
        return
    end
    
    local enemiesFound = 0
    
    -- Méthode 1: Chercher dans le workspace tous les modèles avec un Humanoid
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent then
            local enemyModel = obj.Parent
            
            -- Vérifier que ce n'est pas le joueur lui-même et pas un autre joueur
            if enemyModel ~= playerChar and not game.Players:GetPlayerFromCharacter(enemyModel) then
                -- Vérifier si c'est un personnage (a un HumanoidRootPart)
                if enemyModel:FindFirstChild("HumanoidRootPart") then
                    createESP(enemyModel)
                    enemiesFound = enemiesFound + 1
                end
            end
        end
    end
    
    -- Méthode 2: Chercher dans les dossiers communs d'ennemis
    local commonEnemyFolders = {"Enemies", "NPCs", "Monsters", "Mobs", "Characters", "Dungeon"}
    for _, folderName in pairs(commonEnemyFolders) do
        local folder = game.Workspace:FindFirstChild(folderName)
        if folder then
            for _, enemy in pairs(folder:GetDescendants()) do
                if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                    createESP(enemy)
                    enemiesFound = enemiesFound + 1
                end
            end
        end
    end
    
    if enemiesFound > 0 then
        print("[ESP] " .. enemiesFound .. " ennemis marqués")
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
        
        -- Boucle de mise à jour continue
        espConnection = RunService.Heartbeat:Connect(function()
            task.wait(ESP_UPDATE_INTERVAL)
            updateESP()
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
        
        -- Arrêter la boucle
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        
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
print("=================================")

-- Notification dans le jeu
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Farm Mod Menu";
    Text = "Chargé! Appuie sur INSERT";
    Duration = 5;
})

