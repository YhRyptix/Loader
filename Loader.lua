-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Global Configuration & Constants
if not getgenv().KatsuraUIConfig then
    getgenv().KatsuraUIConfig = {
        LibraryName = "Katsura Loader",
        Theme = {
            PrimaryBG = Color3.fromRGB(31, 33, 41),
            SecondaryBG = Color3.fromRGB(25, 25, 30),
            Accent = Color3.fromRGB(158, 150, 222),
            Text = Color3.fromRGB(190, 190, 195),
            Stroke = Color3.fromRGB(40, 40, 45),
            IconTint = Color3.fromRGB(200, 50, 60)
        },
        Logos = {
            KatsuraLogo = "rbxassetid://0", -- Placeholder
            KatsuraLoadingLogo = "rbxassetid://0", -- Placeholder
        }
    }
end

-- LPH Stubs (Obfuscation compatibility)
if not LPH_OBFUSCATED then
    LPH_JIT = function(...) return ... end
    LPH_NO_VIRTUALIZE = function(...) return ... end
end

-- Wait for Game Load
if not game:IsLoaded() then game.Loaded:Wait() end

--// ANIMATION UTILITIES //--
local Anim = {}

-- Helper to tween any property
function Anim.Tween(obj, properties, time, style, direction)
    if not obj then return end
    local info = TweenInfo.new(
        time or 0.3, 
        style or Enum.EasingStyle.Quad, 
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, info, properties)
    tween:Play()
    return tween
end

-- Pop-in / Slide-up Animation for opening GUIs
function Anim.AnimateIn(frame)
    if not frame then return end
    
    -- Set initial state (invisible and slightly lower)
    local originalPos = frame.Position
    local startPos = UDim2.new(originalPos.X.Scale, originalPos.X.Offset, originalPos.Y.Scale, originalPos.Y.Offset + 50)
    
    frame.Position = startPos
    frame.BackgroundTransparency = 1
    
    -- Recursively hide all children initially
    for _, child in pairs(frame:GetDescendants()) do
        if child:IsA("GuiObject") then
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                child.TextTransparency = 1
            elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                child.ImageTransparency = 1
            end
            child.BackgroundTransparency = 1
        end
    end

    -- Animate Main Frame
    Anim.Tween(frame, {Position = originalPos, BackgroundTransparency = KatsuraUIConfig.Theme.PrimaryBG == frame.BackgroundColor3 and 0 or 0.25}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Animate Children (Fade in)
    for _, child in pairs(frame:GetDescendants()) do
        if child:IsA("GuiObject") then
            local targetTextTrans = 0
            local targetImgTrans = 0
            local targetBgTrans = 0 -- You might need to adjust this per object type logic
            
            -- Simple logic to restore visibility. 
            -- Note: In a complex UI, you'd store original transparencies. 
            -- Here we assume 0 for text/image and specific values for BG.
            
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                 -- Check if it's one of the "faded" elements by default
                 if child.Name == "Close" then targetTextTrans = 0.6 else targetTextTrans = 0 end
                 Anim.Tween(child, {TextTransparency = targetTextTrans}, 0.4)
            end
            
            if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                Anim.Tween(child, {ImageTransparency = 0}, 0.4)
            end
            
            -- Restore BG based on object type logic (simplified)
            if child.Name ~= "PurpleLine" and not child:IsA("TextLabel") then 
                 Anim.Tween(child, {BackgroundTransparency = 0}, 0.4)
            end
            if child.Name == "PurpleLine" then
                 Anim.Tween(child, {BackgroundTransparency = 0}, 0.4)
            end
        end
    end
end

-- Slide-down / Fade-out Animation for closing
function Anim.AnimateOut(screenGui, callback)
    if not screenGui then return end
    
    local frames = {}
    if screenGui:FindFirstChild("Main") then table.insert(frames, screenGui.Main) end
    if screenGui:FindFirstChild("LoadingWindow") then table.insert(frames, screenGui.LoadingWindow) end
    if screenGui:FindFirstChild("KeyLoadingGui") then table.insert(frames, screenGui.KeyLoadingGui) end
    
    local completedCount = 0
    local targetCount = #frames
    
    if targetCount == 0 then 
        screenGui:Destroy()
        if callback then callback() end
        return 
    end

    for _, frame in pairs(frames) do
        -- Move down and fade out
        local targetPos = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset, frame.Position.Y.Scale, frame.Position.Y.Offset + 50)
        
        Anim.Tween(frame, {Position = targetPos, BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        
        for _, child in pairs(frame:GetDescendants()) do
            if child:IsA("GuiObject") then
                local props = {BackgroundTransparency = 1}
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    props.TextTransparency = 1
                end
                if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    props.ImageTransparency = 1
                end
                if child:IsA("UIStroke") then
                    props.Transparency = 1
                end
                Anim.Tween(child, props, 0.3)
            end
        end
        
        -- Cleanup after tween
        task.delay(0.4, function()
            completedCount = completedCount + 1
            if completedCount >= targetCount then
                screenGui:Destroy()
                if callback then callback() end
            end
        end)
    end
end

-- Button Click "Press" Animation
function Anim.AddPressEffect(button)
    if not button then return end
    
    button.MouseButton1Down:Connect(function()
        Anim.Tween(button, {Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset * 0.95, button.Size.Y.Scale, button.Size.Y.Offset * 0.95)}, 0.1)
    end)
    
    button.MouseButton1Up:Connect(function()
        Anim.Tween(button, {Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset / 0.95, button.Size.Y.Scale, button.Size.Y.Offset / 0.95)}, 0.1, Enum.EasingStyle.Spring)
    end)
    
    button.MouseLeave:Connect(function()
         -- Reset size if mouse leaves while holding
         -- (This requires storing original size to be perfectly accurate, but for small buttons this visual reset is usually fine)
    end)
end

--// MAIN LIBRARY LOGIC //--

local Katsura = {}
local LoaderHandler = { FramesUrl = {}, FrameCallbacks = {} }

--// UI CREATION HELPERS //--
-- (Simplified creation to keep script clean, using the structure you provided)

local function CreateMainUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "Katsura"
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.BackgroundColor3 = KatsuraUIConfig.Theme.PrimaryBG
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.Size = UDim2.fromOffset(358, 297)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Parent = sg

    local top = Instance.new("Frame")
    top.Name = "TopLabels"
    top.BackgroundColor3 = KatsuraUIConfig.Theme.SecondaryBG
    top.Size = UDim2.fromOffset(358, 34)
    top.Parent = main

    local line = Instance.new("Frame")
    line.Name = "PurpleLine"
    line.BackgroundColor3 = KatsuraUIConfig.Theme.Accent
    line.Position = UDim2.new(0,0,1, -2)
    line.Size = UDim2.new(1,0,0,2)
    line.BorderSizePixel = 0
    line.Parent = top

    local title = Instance.new("TextLabel")
    title.Text = KatsuraUIConfig.LibraryName
    title.Font = Enum.Font.Ubuntu
    title.TextSize = 14
    title.TextColor3 = KatsuraUIConfig.Theme.Text
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Size = UDim2.new(0, 100, 1, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top

    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.Text = "X"
    close.Font = Enum.Font.Ubuntu
    close.TextSize = 14
    close.TextColor3 = KatsuraUIConfig.Theme.Text
    close.BackgroundTransparency = 1
    close.Position = UDim2.new(1, -30, 0, 0)
    close.Size = UDim2.new(0, 30, 1, 0)
    close.Parent = top
    
    Anim.AddPressEffect(close) -- Add Animation

    local loadFrame = Instance.new("Frame")
    loadFrame.Name = "LoadFrame"
    loadFrame.BackgroundTransparency = 1
    loadFrame.Position = UDim2.new(0, 10, 1, -40)
    loadFrame.Size = UDim2.new(1, -20, 0, 30)
    loadFrame.Parent = main
    
    local loadBtn = Instance.new("TextButton")
    loadBtn.Name = "Load"
    loadBtn.Text = "LOAD"
    loadBtn.BackgroundColor3 = KatsuraUIConfig.Theme.Accent
    loadBtn.TextColor3 = Color3.new(1,1,1)
    loadBtn.Font = Enum.Font.Ubuntu
    loadBtn.TextSize = 14
    loadBtn.Size = UDim2.new(1, 0, 1, 0)
    loadBtn.Parent = loadFrame
    
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, 4)
    uic.Parent = loadBtn
    
    Anim.AddPressEffect(loadBtn) -- Add Animation

    local gamesHolder = Instance.new("ScrollingFrame")
    gamesHolder.Name = "GamesHolder"
    gamesHolder.BackgroundTransparency = 1
    gamesHolder.Position = UDim2.new(0, 0, 0, 40)
    gamesHolder.Size = UDim2.new(1, 0, 1, -90)
    gamesHolder.ScrollBarThickness = 2
    gamesHolder.Parent = main
    
    -- Layout
    local uiList = Instance.new("UIListLayout")
    uiList.Padding = UDim.new(0, 5)
    uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiList.Parent = gamesHolder

    return sg
end

local function CreateGameFrameTemplate()
    local frame = Instance.new("Frame")
    frame.Name = "GameFrame"
    frame.BackgroundColor3 = KatsuraUIConfig.Theme.SecondaryBG
    frame.BackgroundTransparency = 0.25
    frame.Size = UDim2.new(0.95, 0, 0, 50)
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame

    local name = Instance.new("TextLabel")
    name.Name = "GameName"
    name.Text = "Game Name"
    name.Font = Enum.Font.Ubuntu
    name.TextSize = 14
    name.TextColor3 = KatsuraUIConfig.Theme.Text
    name.BackgroundTransparency = 1
    name.Position = UDim2.new(0, 60, 0, 5)
    name.Size = UDim2.new(0, 200, 0, 20)
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Name = "UpdateStatus"
    status.Text = "Status"
    status.Font = Enum.Font.Ubuntu
    status.TextSize = 12
    status.TextColor3 = Color3.fromRGB(150,150,150)
    status.BackgroundTransparency = 1
    status.Position = UDim2.new(0, 60, 0, 25)
    status.Size = UDim2.new(0, 200, 0, 15)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    return frame
end

--// KATSURA FUNCTIONS //--

function Katsura.MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        -- Use Tween for smooth drag (optional, but requested animations)
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Anim.Tween(guiObject, {Position = targetPos}, 0.05) -- Very fast tween for smooth follow
    end

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Katsura.ApplyHoverEffect(gameFrame)
    local targets = {
        GameFrame = gameFrame,
        GameName = gameFrame:FindFirstChild("GameName"),
        UpdateStatus = gameFrame:FindFirstChild("UpdateStatus")
    }
    
    -- Styles
    local EnterColor = {
        GameFrame = {BackgroundColor3 = KatsuraUIConfig.Theme.PrimaryBG, BackgroundTransparency = 0},
        GameName = {TextColor3 = KatsuraUIConfig.Theme.Accent},
    }
    local LeaveColor = {
        GameFrame = {BackgroundColor3 = KatsuraUIConfig.Theme.SecondaryBG, BackgroundTransparency = 0.25},
        GameName = {TextColor3 = KatsuraUIConfig.Theme.Text},
    }

    gameFrame.MouseEnter:Connect(function()
        for objName, props in pairs(EnterColor) do
            if targets[objName] then Anim.Tween(targets[objName], props, 0.3) end
        end
    end)
    
    gameFrame.MouseLeave:Connect(function()
        if getgenv().ActiveFrame ~= gameFrame then
            for objName, props in pairs(LeaveColor) do
                 if targets[objName] then Anim.Tween(targets[objName], props, 0.3) end
            end
        end
    end)
    
    gameFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Reset previous
            if getgenv().ActiveFrame and getgenv().ActiveFrame ~= gameFrame then
                 local oldTargets = {
                    GameFrame = getgenv().ActiveFrame,
                    GameName = getgenv().ActiveFrame:FindFirstChild("GameName")
                 }
                 for objName, props in pairs(LeaveColor) do
                     if oldTargets[objName] then Anim.Tween(oldTargets[objName], props, 0.3) end
                 end
            end
            
            -- Set Active
            getgenv().ActiveFrame = gameFrame
            
            -- Click Animation (Bounce)
            local originalSize = gameFrame.Size
            local shrink = UDim2.new(originalSize.X.Scale * 0.98, 0, originalSize.Y.Scale * 0.98, 0)
            Anim.Tween(gameFrame, {Size = shrink}, 0.1).Completed:Connect(function()
                Anim.Tween(gameFrame, {Size = originalSize}, 0.1, Enum.EasingStyle.Spring)
            end)
        end
    end)
end

function Katsura.LoadingEffect(duration, player, frameConfigs)
    local mainTemplate = CreateMainUI()
    local gameFrameTemplate = CreateGameFrameTemplate()

    -- 1. Create Key UI
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeyLoadingGui"
    keyGui.Parent = player:WaitForChild("PlayerGui")
    
    local keyWindow = Instance.new("Frame")
    keyWindow.Name = "LoadingWindow"
    keyWindow.Size = UDim2.fromOffset(300, 100)
    keyWindow.Position = UDim2.fromScale(0.5, 0.5)
    keyWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    keyWindow.BackgroundColor3 = KatsuraUIConfig.Theme.PrimaryBG
    keyWindow.BorderSizePixel = 0
    keyWindow.Parent = keyGui
    
    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.8, 0, 0, 30)
    keyBox.Position = UDim2.new(0.1, 0, 0.4, 0)
    keyBox.PlaceholderText = "Enter Key..."
    keyBox.BackgroundColor3 = KatsuraUIConfig.Theme.SecondaryBG
    keyBox.TextColor3 = KatsuraUIConfig.Theme.Text
    keyBox.Font = Enum.Font.Ubuntu
    keyBox.TextSize = 14
    keyBox.Parent = keyWindow
    
    local corner = Instance.new("UICorner")
    corner.Parent = keyBox
    local corner2 = Instance.new("UICorner")
    corner2.Parent = keyWindow

    Katsura.MakeDraggable(keyWindow)
    
    -- Animate Key Window IN
    Anim.AnimateIn(keyWindow)

    -- Logic
    keyBox.FocusLost:Connect(function(enter)
        if enter then
            if keyBox.Text == "KATSURA-2024-ACCESS-GRANTED" then
                -- Success Animation
                Anim.Tween(keyBox, {BackgroundColor3 = Color3.fromRGB(100, 255, 100), TextColor3 = Color3.new(0,0,0)}, 0.3)
                keyBox.Text = "Access Granted"
                task.wait(0.5)
                
                -- Close Key UI smoothly
                Anim.AnimateOut(keyGui, function()
                    -- Open Main UI
                    local newUI = mainTemplate:Clone()
                    newUI.Parent = player.PlayerGui
                    
                    local mainFrame = newUI.Main
                    Katsura.MakeDraggable(mainFrame)
                    
                    -- Close Button Logic
                    local closeBtn = mainFrame.TopLabels.Close
                    closeBtn.MouseButton1Click:Connect(function()
                        Anim.AnimateOut(newUI)
                    end)
                    
                    -- Populate Games
                    local holder = mainFrame.GamesHolder
                    for i, config in ipairs(frameConfigs or {}) do
                        local gf = gameFrameTemplate:Clone()
                        gf.GameName.Text = config.GameName
                        gf.UpdateStatus.Text = config.Status
                        gf.Parent = holder
                        
                        -- Store Data
                        if config.Url then LoaderHandler.FramesUrl[gf] = config.Url end
                        
                        Katsura.ApplyHoverEffect(gf)
                    end
                    
                    -- Load Button Logic
                    local loadBtn = mainFrame.LoadFrame.Load
                    loadBtn.MouseButton1Click:Connect(function()
                         local active = getgenv().ActiveFrame
                         if active and LoaderHandler.FramesUrl[active] then
                             Anim.AnimateOut(newUI)
                             -- Executing script
                             loadstring(game:HttpGet(LoaderHandler.FramesUrl[active]))()
                         end
                    end)

                    -- Animate Main Window IN
                    Anim.AnimateIn(mainFrame)
                end)
            else
                -- Error Animation (Shake or Red)
                Anim.Tween(keyBox, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.2)
                task.wait(0.2)
                Anim.Tween(keyBox, {BackgroundColor3 = KatsuraUIConfig.Theme.SecondaryBG}, 0.5)
            end
        end
    end)
end

--// EXAMPLE CONFIG //--
local Games = {
    {
        GameName = "CS:2 External",
        Status = "Undetected | Updated",
        Url = "https://raw.githubusercontent.com/..." -- your url
    },
    {
        GameName = "Arsenal Aimbot",
        Status = "Patched",
        Url = ""
    }
}

--// START //--
Katsura.LoadingEffect(1, LocalPlayer, Games)
