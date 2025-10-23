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

-- Configuration
local TOGGLE_KEY = Enum.KeyCode.Insert
local MENU_SIZE = UDim2.new(0, 450, 0, 300)
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
    mainFrame.Position = savedPosition or UDim2.new(0.5, -225, 0.5, -150)
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
    
    -- Info label
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -40, 0, 130)
    infoLabel.Position = UDim2.new(0, 20, 0, 145)
    infoLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    infoLabel.BorderSizePixel = 0
    infoLabel.Text = "Utilise le pathfinding pour aller vers le monstre le plus proche.\n\nOuvre F9 pour voir les détails du déplacement.\n\nINSERT pour toggle le menu."
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
    
    -- Rendre le menu déplaçable
    makeDraggable(mainFrame, titleBar)
    
    print("[MOD MENU] Interface créée avec succès!")
    
    return screenGui
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

-- Fonction pour tester le déplacement vers un monstre
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
    print("[MOVE] Calcul du chemin...")
    
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
            print("[MOVE] Chemin trouvé!")
            local waypoints = path:GetWaypoints()
            print(string.format("[MOVE] %d waypoints - déplacement en cours...", #waypoints))
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Pathfinding";
                Text = "Déplacement vers " .. monster.Name;
                Duration = 2;
            })
            
            local currentWaypoint = 2
            local pathBlocked = false
            
            local function moveToNextWaypoint()
                if currentWaypoint <= #waypoints and not pathBlocked then
                    local waypoint = waypoints[currentWaypoint]
                    local distToWaypoint = (waypoint.Position - humanoidRootPart.Position).Magnitude
                    print(string.format("[MOVE] ➤ Waypoint %d/%d - Distance: %.1fm", currentWaypoint, #waypoints, distToWaypoint))
                    
                    humanoid:MoveTo(waypoint.Position)
                    
                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        humanoid.Jump = true
                        print("[MOVE] Saut requis!")
                    end
                    
                    currentWaypoint = currentWaypoint + 1
                end
            end
            
            local reachedConnection
            
            reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
                print(string.format("[MOVE] MoveToFinished - Reached: %s - Waypoint: %d/%d", tostring(reached), currentWaypoint - 1, #waypoints))
                
                if reached then
                    print("[MOVE] Waypoint atteint!")
                    
                    if currentWaypoint <= #waypoints then
                        moveToNextWaypoint()
                    else
                        reachedConnection:Disconnect()
                        print("[MOVE] === ARRIVÉ AU MONSTRE! ===")
                        
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Pathfinding";
                            Text = "Arrivé devant " .. monster.Name;
                            Duration = 2;
                        })
                    end
                else
                    pathBlocked = true
                    reachedConnection:Disconnect()
                    
                    local distanceToTarget = (humanoidRootPart.Position - targetPos).Magnitude
                    print(string.format("[MOVE] BLOQUÉ au waypoint %d/%d - Distance restante: %.1fm", currentWaypoint - 1, #waypoints, distanceToTarget))
                    print("[MOVE] Raison: Obstacle, saut raté, ou chemin impossible")
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Pathfinding";
                        Text = "Bloqué! Check console F9";
                        Duration = 3;
                    })
                end
            end)
            
            print("[MOVE] 🚀 Démarrage du pathfinding...")
            moveToNextWaypoint()
            
            task.delay(30, function()
                if reachedConnection then reachedConnection:Disconnect() end
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
end

-- Fonction pour afficher/cacher le menu avec animation
function toggleMenu()
    menuVisible = not menuVisible
    
    if menuVisible then
        mainFrame.Visible = true
        mainFrame.Position = savedPosition or UDim2.new(0.5, -225, 0.5, -150)
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
