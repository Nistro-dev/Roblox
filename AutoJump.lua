-- Script Auto Jump pour Roblox
-- Projet d'école

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Variables
local autoJumpEnabled = false
local connection = nil

-- Fonction pour créer l'interface graphique (GUI)
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoJumpGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Frame principale
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 150)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.Parent = screenGui
    
    -- Coins arrondis
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Titre
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Auto Jump Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = title
    
    -- Bouton Toggle Auto Jump
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 250, 0, 40)
    toggleButton.Position = UDim2.new(0.5, -125, 0, 60)
    toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "Auto Jump: OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 16
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = toggleButton
    
    -- Bouton Fermer
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 250, 0, 30)
    closeButton.Position = UDim2.new(0.5, -125, 0, 110)
    closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Fermer Menu"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.Gotham
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    -- Rendre le frame déplaçable
    local dragging = false
    local dragInput, mousePos, framePos
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            mainFrame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    return screenGui, toggleButton, closeButton
end

-- Fonction pour activer/désactiver l'auto jump
local function toggleAutoJump(toggleButton)
    autoJumpEnabled = not autoJumpEnabled
    
    if autoJumpEnabled then
        toggleButton.Text = "Auto Jump: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        -- Boucle d'auto jump
        connection = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.Health > 0 then
                -- Vérifie si le personnage est au sol
                if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and 
                   humanoid:GetState() ~= Enum.HumanoidStateType.Flying then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        
        print("Auto Jump activé!")
    else
        toggleButton.Text = "Auto Jump: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        -- Arrête la boucle
        if connection then
            connection:Disconnect()
            connection = nil
        end
        
        print("Auto Jump désactivé!")
    end
end

-- Créer l'interface
local gui, toggleButton, closeButton = createGUI()

-- Événement du bouton toggle
toggleButton.MouseButton1Click:Connect(function()
    toggleAutoJump(toggleButton)
end)

-- Événement du bouton fermer
closeButton.MouseButton1Click:Connect(function()
    if connection then
        connection:Disconnect()
    end
    gui:Destroy()
    print("Menu fermé")
end)

-- Raccourci clavier (touche 'J' pour toggle)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.J then
        toggleAutoJump(toggleButton)
    end
end)

-- Gestion de la respawn du personnage
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    
    -- Réactive l'auto jump si il était activé
    if autoJumpEnabled and connection then
        connection:Disconnect()
        connection = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.Health > 0 then
                if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and 
                   humanoid:GetState() ~= Enum.HumanoidStateType.Flying then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end)

print("Script Auto Jump chargé! Appuie sur 'J' ou utilise le menu.")

