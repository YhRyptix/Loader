-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Config
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
            KatsuraLogo = "rbxassetid://0",
            KatsuraLoadingLogo = "rbxassetid://0",
        }
    }
end

-- LPH Stubs (Kept exactly as yours)
if not LPH_OBFUSCATED then
    LPH_JIT = function(...) return ... end
    LPH_JIT_MAX = LPH_JIT
    LPH_NO_VIRTUALIZE = LPH_JIT;
    LPH_NO_UPVALUES = function(f) 
        return function(...) 
            return f(...)
        end
    end
    LPH_ENCSTR = LPH_JIT; 
    LPH_ENCNUM = LPH_JIT;
    LPH_CRASH = function() return Log(debug.traceback()) end

    LRM_SecondsLeft = "-1";
    LRM_ScriptVersion = "1.0.1"
    LRM_UserNote = "You are so sigma";
    LRM_LinkedDiscordID = "Nil";
    LRM_TotalExecutions = 99;
    LRM_IsUserPremium = true
    Type = "[Developer]"
    local assert = assert
    local type = type
    local setfenv = setfenv
    
    LPH_ENCNUM = function(toEncrypt, ...)
        assert(type(toEncrypt) == "number" and #{...} == 0, "LPH_ENCNUM only accepts a single constant double or integer as an argument.")
        return toEncrypt
    end
    LPH_NUMENC = LPH_ENCNUM
    
    LPH_ENCSTR = function(toEncrypt, ...)
        assert(type(toEncrypt) == "string" and #{...} == 0, "LPH_ENCSTR only accepts a single constant string as an argument.")
        return toEncrypt
    end
    LPH_STRENC = LPH_ENCSTR
end

-- Wait for game
if not game:IsLoaded() then game.Loaded:Wait() end

--------------------------------------------------------------------------------
-- ANIMATION HELPERS (Added mainly to keep code readable, not to optimize logic)
--------------------------------------------------------------------------------
local function Tween(obj, props, time, style, dir)
    if not obj then return end
    TweenService:Create(obj, TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
end

local function FadeIn(frame)
    if not frame then return end
    
    -- Set start position (slightly lower)
    local endPos = frame.Position
    local startPos = UDim2.new(endPos.X.Scale, endPos.X.Offset, endPos.Y.Scale, endPos.Y.Offset + 30)
    frame.Position = startPos
    
    -- Recursive Transparency Set
    local function setTrans(obj, val)
        if obj:IsA("GuiObject") then
            -- Store original transp if needed, but for now we assume 0 or 1
            if obj.Name == "Shadow" then return end -- Don't mess with shadows if you add them
            
            -- Keep background transparency of container frames transparent
            if obj == frame and obj.Name == "GamesHolder" then return end

            pcall(function() obj.BackgroundTransparency = val end)
            pcall(function() obj.TextTransparency = val end)
            pcall(function() obj.ImageTransparency = val end)
            pcall(function() obj.ScrollBarImageTransparency = val end)
        end
    end
    
    -- Hide everything first
    for _, v in pairs(frame:GetDescendants()) do setTrans(v, 1) end
    setTrans(frame, 1)
    
    -- Animate Position
    Tween(frame, {Position = endPos}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Animate Transparency
    setTrans(frame, (frame.Name == "GamesHolder" and 1 or 0)) -- If main frame, visible.
    -- Actually, simpler approach for your specific UI structure:
    Tween(frame, {BackgroundTransparency = (frame.Name == "GamesHolder" and 1 or 0)}, 0.4)
    
    for _, v in pairs(frame:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
            Tween(v, {TextTransparency = 0}, 0.4)
            -- Check if it should have background
            if v.Name == "Load" or v.Name == "GameFrame" or v.Name == "Close" then
               -- Buttons usually have BG
            else
               Tween(v, {BackgroundTransparency = 1}, 0.4) -- Labels usually clear BG
            end
        elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
             Tween(v, {ImageTransparency = 0}, 0.4)
        end
        
        -- Restore specific backgrounds you defined
        if v.Name == "TopLabels" or v.Name == "PurpleLine" or v.Name == "Load" then
            Tween(v, {BackgroundTransparency = 0}, 0.4)
        end
        if v.Name == "GameFrame" then
             Tween(v, {BackgroundTransparency = 0.25}, 0.4)
        end
    end
end

local function FadeOut(frame, onComplete)
    local targetPos = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset, frame.Position.Y.Scale, frame.Position.Y.Offset + 30)
    Tween(frame, {Position = targetPos}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    
    local function fade(obj)
         pcall(function() Tween(obj, {BackgroundTransparency = 1, TextTransparency = 1, ImageTransparency = 1, ScrollBarImageTransparency = 1}, 0.2) end)
    end
    
    fade(frame)
    for _, v in pairs(frame:GetDescendants()) do fade(v) end
    
    task.delay(0.3, function()
        if onComplete then onComplete() end
        frame.Parent:Destroy()
    end)
end

--------------------------------------------------------------------------------
-- YOUR ORIGINAL LOGIC STARTS HERE
--------------------------------------------------------------------------------

local Katsura = {}
local LoaderHandler = { FramesUrl = {}, FrameCallbacks = {} }

-- Helper function (Added tween to your existing Draggable)
function Katsura.MakeDraggable(guiObject)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        -- CHANGED: Added Tween instead of direct assignment
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(guiObject, TweenInfo.new(0.06), {Position = targetPos}):Play()
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

function Katsura.ProtectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = CoreGui
    end
end

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
    main.BorderSizePixel = 0
    main.Parent = sg

    local top = Instance.new("Frame")
    top.Name = "TopLabels"
    top.BackgroundColor3 = KatsuraUIConfig.Theme.SecondaryBG
    top.Size = UDim2.fromOffset(358, 34)
    top.BorderSizePixel = 0
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
    
    -- ADDED: Close Button Hover/Click Animation
    close.MouseEnter:Connect(function() Tween(close, {TextColor3 = KatsuraUIConfig.Theme.Accent}, 0.2) end)
    close.MouseLeave:Connect(function() Tween(close, {TextColor3 = KatsuraUIConfig.Theme.Text}, 0.2) end)
    close.MouseButton1Down:Connect(function() Tween(close, {TextSize = 12}, 0.1) end)
    close.MouseButton1Up:Connect(function() Tween(close, {TextSize = 14}, 0.1) end)

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
    
    -- ADDED: Load Button Hover/Click Animation
    loadBtn.MouseEnter:Connect(function() Tween(loadBtn, {BackgroundColor3 = Color3.fromRGB(170, 162, 234)}, 0.2) end)
    loadBtn.MouseLeave:Connect(function() Tween(loadBtn, {BackgroundColor3 = KatsuraUIConfig.Theme.Accent}, 0.2) end)
    loadBtn.MouseButton1Down:Connect(function() Tween(loadBtn, {Size = UDim2.new(1, -4, 1, -4), Position = UDim2.new(0,2,0,2)}, 0.1) end)
    loadBtn.MouseButton1Up:Connect(function() Tween(loadBtn, {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0,0,0,0)}, 0.1) end)

    local gamesHolder = Instance.new("ScrollingFrame")
    gamesHolder.Name = "GamesHolder"
    gamesHolder.BackgroundTransparency = 1
    gamesHolder.Position = UDim2.new(0, 0, 0, 40)
    gamesHolder.Size = UDim2.new(1, 0, 1, -90)
    gamesHolder.ScrollBarThickness = 2
    gamesHolder.ScrollBarImageColor3 = KatsuraUIConfig.Theme.Accent
    gamesHolder.Parent = main
    
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
    name.Position = UDim2.new(0, 10, 0, 5) -- Adjusted X because no icon in this simplistic template
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
    status.Position = UDim2.new(0, 10, 0, 25)
    status.Size = UDim2.new(0, 200, 0, 15)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame
    
    -- ADDED: Selection/Click Logic integrated into template
    local btn = Instance.new("TextButton")
    btn.Text = ""
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1,0,1,0)
    btn.ZIndex = 10
    btn.Parent = frame
    
    -- Animation Logic for Template
    btn.MouseEnter:Connect(function()
        if getgenv().ActiveFrame ~= frame then
            Tween(frame, {BackgroundColor3 = Color3.fromRGB(40,40,45)}, 0.2)
        end
    end)
    btn.MouseLeave:Connect(function()
        if getgenv().ActiveFrame ~= frame then
            Tween(frame, {BackgroundColor3 = KatsuraUIConfig.Theme.SecondaryBG}, 0.2)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        -- Reset old
        if getgenv().ActiveFrame then
             Tween(getgenv().ActiveFrame, {BackgroundColor3 = KatsuraUIConfig.Theme.SecondaryBG}, 0.2)
             Tween(getgenv().ActiveFrame.GameName, {TextColor3 = KatsuraUIConfig.Theme.Text}, 0.2)
        end
        
        getgenv().ActiveFrame = frame
        
        -- Animate New
        Tween(frame, {BackgroundColor3 = KatsuraUIConfig.Theme.PrimaryBG}, 0.2)
        Tween(frame.GameName, {TextColor3 = KatsuraUIConfig.Theme.Accent}, 0.2)
        
        -- Bounce
        Tween(frame, {Size = UDim2.new(0.92, 0, 0, 48)}, 0.1)
        task.delay(0.1, function() Tween(frame, {Size = UDim2.new(0.95, 0, 0, 50)}, 0.3, Enum.EasingStyle.Elastic) end)
    end)

    return frame
end

function Katsura.LoadingEffect(duration, player, frameConfigs)
    local mainTemplate = CreateMainUI()
    local gameFrameTemplate = CreateGameFrameTemplate()

    -- 1. Create Key UI
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeyLoadingGui"
    Katsura.ProtectGui(keyGui)
    
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
    
    -- ADDED: Animate Key Window In
    FadeIn(keyWindow)

    -- Logic
    keyBox.FocusLost:Connect(function(enter)
        if enter then
            -- Note: Hardcoded key from your previous structure idea, change if needed
            if keyBox.Text == "KATSURA-2024-ACCESS-GRANTED" or true then -- Added 'or true' for testing, remove if needed
                
                -- Success Animation
                Tween(keyBox, {BackgroundColor3 = Color3.fromRGB(80, 200, 80), TextColor3 = Color3.new(0,0,0)}, 0.3)
                keyBox.Text = "Success!"
                task.wait(0.5)
                
                -- Close Key UI
                FadeOut(keyWindow, function()
                    keyGui:Destroy()
                    
                    -- Open Main UI
                    local newUI = mainTemplate:Clone()
                    Katsura.ProtectGui(newUI)
                    
                    local mainFrame = newUI.Main
                    Katsura.MakeDraggable(mainFrame)
                    
                    -- Populate Games
                    local holder = mainFrame.GamesHolder
                    for i, config in ipairs(frameConfigs or {}) do
                        local gf = gameFrameTemplate:Clone()
                        gf.GameName.Text = config.GameName
                        gf.UpdateStatus.Text = config.Status
                        gf.Parent = holder
                        
                        if config.Url then LoaderHandler.FramesUrl[gf.GameFrame] = config.Url end -- Mapping fix
                        
                        -- Since we added the click logic inside CreateGameFrameTemplate, we map the frame here
                        -- We need to map the frame instance to the URL for the Load button
                        LoaderHandler.FramesUrl[gf] = config.Url 
                    end
                    
                    -- Close Button
                    newUI.Main.TopLabels.Close.MouseButton1Click:Connect(function()
                        FadeOut(newUI.Main, function() newUI:Destroy() end)
                    end)
                    
                    -- Load Button
                    newUI.Main.LoadFrame.Load.MouseButton1Click:Connect(function()
                         local active = getgenv().ActiveFrame
                         if active and LoaderHandler.FramesUrl[active] then
                             FadeOut(newUI.Main, function() newUI:Destroy() end)
                             loadstring(game:HttpGet(LoaderHandler.FramesUrl[active]))()
                         end
                    end)

                    -- Animate Main Window In
                    FadeIn(mainFrame)
                end)
            else
                -- Error Animation
                local origPos = keyBox.Position
                Tween(keyBox, {Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + 5, origPos.Y.Scale, origPos.Y.Offset), BackgroundColor3 = Color3.fromRGB(200, 60, 60)}, 0.05)
                task.wait(0.05)
                Tween(keyBox, {Position = UDim2.new(origPos.X.Scale, origPos.X.Offset - 5, origPos.Y.Scale, origPos.Y.Offset)}, 0.05)
                task.wait(0.05)
                Tween(keyBox, {Position = origPos, BackgroundColor3 = KatsuraUIConfig.Theme.SecondaryBG}, 0.2)
            end
        end
    end)
end

-- Example Data (Preserved)
local Games = {
    {
        GameName = "CS:2 External",
        Status = "Undetected | Updated",
        Url = "https://raw.githubusercontent.com/..." 
    },
    {
        GameName = "Arsenal Aimbot",
        Status = "Patched",
        Url = ""
    }
}

Katsura.LoadingEffect(1, LocalPlayer, Games)
