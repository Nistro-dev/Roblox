local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local isMoving = false
local screenGui = nil
local mainFrame = nil

local TOGGLE_KEY = Enum.KeyCode.Insert

function createGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleMove"
    screenGui.Parent = player.PlayerGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 100)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SIMPLE MOVE"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -20, 0, 40)
    toggleBtn.Position = UDim2.new(0, 10, 0, 40)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    toggleBtn.Text = "AVANCER"
    toggleBtn.TextSize = 14
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = mainFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 85)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "ARRÊTÉ"
    statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame
    
    toggleBtn.MouseButton1Click:Connect(function()
        if isMoving then
            isMoving = false
            toggleBtn.Text = "AVANCER"
            statusLabel.Text = "ARRÊTÉ"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        else
            isMoving = true
            toggleBtn.Text = "ARRÊTER"
            statusLabel.Text = "EN COURS"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            startMoving()
        end
    end)
end

function startMoving()
    local playerChar = player.Character
    if not playerChar or not playerChar:FindFirstChild("HumanoidRootPart") then
        print("Personnage non trouvé")
        return
    end
    
    local humanoid = playerChar:FindFirstChild("Humanoid")
    if not humanoid then
        print("Humanoid non trouvé")
        return
    end
    
    local humanoidRootPart = playerChar.HumanoidRootPart
    local startPos = humanoidRootPart.Position
    local direction = humanoidRootPart.CFrame.LookVector
    
    print("Démarrage mouvement en ligne droite")
    
    local function moveForward()
        if not isMoving then return end
        
        local currentPos = humanoidRootPart.Position
        local distance = (currentPos - startPos).Magnitude
        
        if distance > 100 then
            isMoving = false
            print("Arrêt - Distance max atteinte")
            return
        end
        
        local targetPos = currentPos + (direction * 5)
        humanoid:MoveTo(targetPos)
        humanoid.WalkSpeed = 16
        
        print(string.format("Avancement: %.1fm", distance))
        
        task.wait(0.5)
        moveForward()
    end
    
    moveForward()
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

print("Simple Move chargé! Appuie sur INSERT pour toggle")
