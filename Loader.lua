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
    
    LPH_ENCFUNC = function(toEncrypt, encKey, decKey, ...)
        -- not checking decKey value since this shim is meant to be used without obfuscation/whitelisting
        assert(type(toEncrypt) == "function" and type(encKey) == "string" and #{...} == 0, "LPH_ENCFUNC accepts a constant function, constant string, and string variable as arguments.")
        return toEncrypt
    end
    LPH_FUNCENC = LPH_ENCFUNC
    
    LPH_JIT = function(f, ...)
        assert(type(f) == "function" and #{...} == 0, "LPH_JIT only accepts a single constant function as an argument.")
        return f
    end
    LPH_JIT_MAX = LPH_JIT
    
    LPH_NO_VIRTUALIZE = function(f, ...)
        assert(type(f) == "function" and #{...} == 0, "LPH_NO_VIRTUALIZE only accepts a single constant function as an argument.")
        return f
    end
    
    LPH_NO_UPVALUES = function(f, ...)
        assert(type(setfenv) == "function", "LPH_NO_UPVALUES can only be used on Lua versions with getfenv & setfenv")
        assert(type(f) == "function" and #{...} == 0, "LPH_NO_UPVALUES only accepts a single constant function as an argument.")
        return f
    end
    
    LPH_CRASH = function(...)
        assert(#{...} == 0, "LPH_CRASH does not accept any arguments.")
    end
end;

if not game:IsLoaded() then
    game.Loaded:Wait()
end

getgenv().KatsuraUIConfig = {
    LibraryName = "Katsura Loader",
    Theme = {
        PrimaryBG = Color3.fromRGB(31, 33, 41),       -- main window / background
        SecondaryBG = Color3.fromRGB(25, 25, 30),     -- panels, cards, subframes
        Accent = Color3.fromRGB(158, 150, 222),         -- highlights, buttons, important text
        Text = Color3.fromRGB(190, 190, 195),         -- standard text
        Stroke = Color3.fromRGB(40, 40, 45),          -- outlines, borders
        IconTint = Color3.fromRGB(200, 50, 60)        -- logos, image tints
    },
    Logos = (function()
        local rawUrl = "https://raw.githubusercontent.com/YhRyptix/Loader/main/d75af5bf-c12e-4753-9e85-76d367444a83.png"
        local imagePath = "katsuralogo.png"
        local fallback = "rbxassetid://0"

        local asset = fallback

        local ok_write = false
        if type(isfile) == "function" and type(writefile) == "function" and type(game.HttpGet) == "function" then
            if not isfile(imagePath) then
                local ok, data = pcall(function()
                    return game:HttpGet(rawUrl)
                end)
                if ok and data and #data > 0 then
                    pcall(function() writefile(imagePath, data) end)
                    ok_write = true
                end
            else
                ok_write = true
            end

            if ok_write and type(getcustomasset) == "function" then
                local ok2, res = pcall(function()
                    return getcustomasset(imagePath)
                end)
                if ok2 and res then
                    asset = res
                end
            end
        end

        return {
            KatsuraLogo = asset,
            KatsuraLoadingLogo = asset,
        }
    end)(),
}
local KatsuraFolder = Instance.new("Folder")
KatsuraFolder.Name = "KatsuraFolder"
KatsuraFolder.Parent = game.CoreGui

local katsuraMs = Instance.new("ModuleScript")
katsuraMs.Name = "Katsura"
katsuraMs.Parent = KatsuraFolder

local katsuraGui = Instance.new("ScreenGui")
katsuraGui.Name = "Katsura"
katsuraGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
katsuraGui.Parent = katsuraMs

local main = Instance.new("Frame")
main.Name = "Main"
main.BackgroundColor3 = KatsuraUIConfig.Theme.PrimaryBG
main.BorderColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(358, 297)

local topLabels = Instance.new("Frame")
topLabels.Name = "TopLabels"
topLabels.BackgroundColor3 = Color3.fromRGB(23, 26, 31)
topLabels.BorderColor3 = Color3.fromRGB(0, 0, 0)
topLabels.BorderSizePixel = 0
topLabels.Position = UDim2.fromScale(0, -0.00213)
topLabels.Size = UDim2.fromOffset(358, 34)

local purpleLine = Instance.new("Frame")
purpleLine.Name = "PurpleLine"
purpleLine.BackgroundColor3 = KatsuraUIConfig.Theme.Accent
purpleLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
purpleLine.BorderSizePixel = 0
purpleLine.Position = UDim2.fromScale(0, 0.924)
purpleLine.Size = UDim2.fromOffset(358, 2)
purpleLine.Parent = topLabels

local close = Instance.new("TextButton")
close.Name = "Close"
close.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
close.Text = "X"
close.TextColor3 = Color3.fromRGB(190, 190, 190)
close.TextSize = 14
close.TextTransparency = 0.6
close.AutoButtonColor = false
close.BackgroundColor3 = Color3.fromRGB(74, 74, 75)
close.BackgroundTransparency = 1
close.BorderColor3 = Color3.fromRGB(0, 0, 0)
close.BorderSizePixel = 0
close.Position = UDim2.fromScale(0.908, 0.192)
close.Size = UDim2.fromOffset(25, 18)

close.Parent = topLabels

local katsuraLabel = Instance.new("TextLabel")
katsuraLabel.Name = "KatsuraLabel"
katsuraLabel.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
katsuraLabel.Text = KatsuraUIConfig.LibraryName
katsuraLabel.TextColor3 = KatsuraUIConfig.Theme.Text
katsuraLabel.TextSize = 15
katsuraLabel.TextWrapped = true
katsuraLabel.BackgroundColor3 = KatsuraUIConfig.Theme.Accent
katsuraLabel.BackgroundTransparency = 1
katsuraLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
katsuraLabel.BorderSizePixel = 0
katsuraLabel.Position = UDim2.fromScale(0.0198, 0.192)
katsuraLabel.Size = UDim2.fromOffset(75, 18)
katsuraLabel.Parent = topLabels

topLabels.Parent = main

local loadFrame = Instance.new("Frame")
loadFrame.Name = "LoadFrame"
loadFrame.BackgroundColor3 = KatsuraUIConfig.Theme.PrimaryBG
loadFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
loadFrame.BorderSizePixel = 0
loadFrame.Position = UDim2.fromScale(0.0198, 0.88)
loadFrame.Size = UDim2.fromOffset(344, 26)

local uIStroke = Instance.new("UIStroke")
uIStroke.Name = "UIStroke"
uIStroke.Color = KatsuraUIConfig.Theme.Stroke
uIStroke.LineJoinMode = Enum.LineJoinMode.Miter
uIStroke.Parent = loadFrame

local LoadButton = Instance.new("TextButton")
LoadButton.Name = "Load"
LoadButton.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
LoadButton.Text = "Load"
LoadButton.TextColor3 = KatsuraUIConfig.Theme.Text
LoadButton.TextSize = 14
LoadButton.TextTransparency = 0.6
LoadButton.AutoButtonColor = false
LoadButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadButton.BackgroundTransparency = 1
LoadButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadButton.BorderSizePixel = 0
LoadButton.Position = UDim2.fromScale(0.021, 0)
LoadButton.Size = UDim2.fromOffset(335, 26)


LoadButton.Parent = loadFrame

loadFrame.Parent = main

local gamesHolder = Instance.new("ScrollingFrame")
gamesHolder.Name = "GamesHolder"
gamesHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
gamesHolder.BottomImage = ""
gamesHolder.ElasticBehavior = Enum.ElasticBehavior.Always
gamesHolder.MidImage = ""
gamesHolder.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
gamesHolder.ScrollBarThickness = 1
gamesHolder.ScrollingDirection = Enum.ScrollingDirection.Y
gamesHolder.Active = true
gamesHolder.BackgroundColor3 = Color3.fromRGB(23, 26, 31)
gamesHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
gamesHolder.BorderSizePixel = 0
gamesHolder.Position = UDim2.fromScale(0.0198, 0.139)
gamesHolder.Size = UDim2.fromOffset(344, 213)
gamesHolder.AutoLocalize = false

local uIStroke1 = Instance.new("UIStroke")
uIStroke1.Name = "UIStroke"
uIStroke1.Color = Color3.fromRGB(52, 52, 52)
uIStroke1.LineJoinMode = Enum.LineJoinMode.Miter
uIStroke1.Parent = gamesHolder

local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Name = "UIListLayout"
uIListLayout.Padding = UDim.new(0, 1)
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.Parent = gamesHolder

gamesHolder.Parent = main
main.Parent = katsuraGui

local katsuraLoading = Instance.new("ScreenGui")
katsuraLoading.Name = "KatsuraLoading"
katsuraLoading.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
-- keep as module template parent so LoadingEffect can clone it into PlayerGui
katsuraLoading.Parent = katsuraMs

local loadingWindow = Instance.new("Frame")
loadingWindow.Name = "LoadingWindow"
loadingWindow.Parent = katsuraLoading
loadingWindow.AnchorPoint = Vector2.new(0.5, 0.5)
loadingWindow.BackgroundColor3 = Color3.fromRGB(31, 33, 41)
loadingWindow.BorderColor3 = Color3.fromRGB(0, 0, 0)
loadingWindow.BorderSizePixel = 0
loadingWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
loadingWindow.Size = UDim2.new(0, 250, 0, 133)

local KatsuraLogo = Instance.new("ImageLabel")
KatsuraLogo.Name = "KatsuraLogo"
KatsuraLogo.Parent = loadingWindow
KatsuraLogo.AnchorPoint = Vector2.new(0.5, 0.5)
KatsuraLogo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
KatsuraLogo.BackgroundTransparency = 1.000
KatsuraLogo.BorderColor3 = Color3.fromRGB(0, 0, 0)
KatsuraLogo.BorderSizePixel = 0
KatsuraLogo.Position = UDim2.new(0.5, 0, 0.551929653, 0)
KatsuraLogo.Size = UDim2.new(0, 250, 0, 100)
KatsuraLogo.ScaleType = Enum.ScaleType.Fit
KatsuraLogo.Image = KatsuraUIConfig.Logos.KatsuraLoadingLogo

loadingWindow.Parent = katsuraLoading

local TopLabels = Instance.new("Frame")
TopLabels.Name = "TopLabels"
TopLabels.Parent = loadingWindow
TopLabels.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopLabels.BorderColor3 = Color3.fromRGB(0, 0, 0)
TopLabels.BorderSizePixel = 0
TopLabels.Position = UDim2.new(0, 0, 0.0149999997, 0)
TopLabels.Size = UDim2.new(0, 250, 0, 27)

local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = TopLabels
TextLabel.BackgroundColor3 = Color3.fromRGB(31, 33, 41)
TextLabel.BackgroundTransparency = 1.000
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.0280009769, 0, -0.0500000007, 0)
TextLabel.Size = UDim2.new(0, 96, 0, 27)
TextLabel.Font = Enum.Font.Ubuntu
TextLabel.Text = "Katsura Loader"
TextLabel.TextColor3 = Color3.fromRGB(190, 190, 195)
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

local Close = Instance.new("ImageLabel")
Close.Name = "Close"
Close.Parent = TopLabels
Close.BackgroundColor3 = Color3.fromRGB(74, 74, 75)
Close.BackgroundTransparency = 1.000
Close.Position = UDim2.new(0.879999995, 0, 0.222000003, 0)
Close.Size = UDim2.new(0, 15, 0, 24)
Close.Image = "rbxassetid://8445470984"
Close.ImageColor3 = Color3.fromRGB(141, 141, 141)
Close.ImageRectOffset = Vector2.new(304, 304)
Close.ImageRectSize = Vector2.new(96, 96)

local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
UIAspectRatioConstraint.Parent = Close
UIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height

local PurpleLine = Instance.new("Frame")
PurpleLine.Name = "PurpleLine"
PurpleLine.Parent = TopLabels
PurpleLine.BackgroundColor3 = Color3.fromRGB(158, 150, 222)
PurpleLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
PurpleLine.BorderSizePixel = 0
PurpleLine.Position = UDim2.new(0, 0, 0.924000025, 0)
PurpleLine.Size = UDim2.new(0, 250, 0, 2)

local BackgroundLoadBar = Instance.new("Frame")
BackgroundLoadBar.Name = "BackgroundLoadBar"
BackgroundLoadBar.Parent = TopLabels
BackgroundLoadBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
BackgroundLoadBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
BackgroundLoadBar.BorderSizePixel = 0
BackgroundLoadBar.Position = UDim2.new(0.122000001, 0, 4.3, 0)
BackgroundLoadBar.Size = UDim2.new(0, 189, 0, 3)

local LoadingLine = Instance.new("Frame")
LoadingLine.Name = "LoadingLine"
LoadingLine.Parent = BackgroundLoadBar
LoadingLine.BackgroundColor3 = Color3.fromRGB(158, 150, 222)
LoadingLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadingLine.BorderSizePixel = 0
LoadingLine.Position = UDim2.new(-0.00306000002, 0, 0, 0)
LoadingLine.Size = UDim2.new(0.958362997, 0, 1, 0)

local KatsuraLogo = Instance.new("ImageLabel")
KatsuraLogo.Name = "KatsuraLogo"
KatsuraLogo.Parent = loadingWindow
KatsuraLogo.AnchorPoint = Vector2.new(0.5, 0.5)
KatsuraLogo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
KatsuraLogo.BackgroundTransparency = 1.000
KatsuraLogo.BorderColor3 = Color3.fromRGB(0, 0, 0)
KatsuraLogo.BorderSizePixel = 0
KatsuraLogo.Position = UDim2.new(0.5, 0, 0.551929653, 0)
KatsuraLogo.Size = UDim2.new(0, 250, 0, 100)
KatsuraLogo.ScaleType = Enum.ScaleType.Fit
KatsuraLogo.Image = KatsuraUIConfig.Logos.KatsuraLoadingLogo


local gameFrame = Instance.new("Frame")
gameFrame.Name = "GameFrame"
gameFrame.BackgroundColor3 = Color3.fromRGB(19, 22, 27)
gameFrame.BackgroundTransparency = 0.25
gameFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
gameFrame.BorderSizePixel = 0
gameFrame.ClipsDescendants = true
gameFrame.Size = UDim2.fromOffset(344, 49)

local imageLabel = Instance.new("ImageLabel")

    imageLabel.Name = "ImageLabel"
    imageLabel.Image = "rbxassetid://108227353249963"
    imageLabel.ImageColor3 = Color3.fromRGB(255, 254, 253)
    imageLabel.ImageTransparency = 0.6
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    imageLabel.BackgroundTransparency = 1
    imageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    imageLabel.BorderSizePixel = 0
    imageLabel.Position = UDim2.fromScale(0.0208, 0.06)
    imageLabel.Size = UDim2.fromOffset(56, 64)

local uICorner = Instance.new("UICorner")
uICorner.Name = "UICorner"
uICorner.Parent = imageLabel

imageLabel.Parent = gameFrame

local gameName = Instance.new("TextLabel")
gameName.Name = "GameName"
gameName.FontFace = Font.new(
  "rbxasset://fonts/families/Ubuntu.json",
  Enum.FontWeight.Bold,
  Enum.FontStyle.Normal
)
gameName.RichText = true
gameName.Text = "CS:2 External"
gameName.TextColor3 = Color3.fromRGB(133, 127, 187)
gameName.TextSize = 14
gameName.TextTransparency = 0.6
gameName.TextWrapped = true
gameName.TextXAlignment = Enum.TextXAlignment.Left
gameName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
gameName.BackgroundTransparency = 1
gameName.BorderColor3 = Color3.fromRGB(0, 0, 0)
gameName.BorderSizePixel = 0
gameName.Position = UDim2.fromScale(0.147, 0.0612)
gameName.Size = UDim2.fromOffset(214, 25)
gameName.Parent = gameFrame

local updateStatus = Instance.new("TextLabel")
updateStatus.Name = "UpdateStatus"
updateStatus.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
updateStatus.RichText = true
updateStatus.Text = "Update June 11, 2025"
updateStatus.TextColor3 = Color3.fromRGB(205, 206, 212)
updateStatus.TextSize = 15
updateStatus.TextTransparency = 0.6
updateStatus.TextWrapped = true
updateStatus.TextXAlignment = Enum.TextXAlignment.Left
updateStatus.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
updateStatus.BackgroundTransparency = 1
updateStatus.BorderColor3 = Color3.fromRGB(0, 0, 0)
updateStatus.BorderSizePixel = 0
updateStatus.Position = UDim2.fromScale(0.147, 0.571)
updateStatus.Size = UDim2.fromOffset(214, 17)
updateStatus.Parent = gameFrame

local subTime = Instance.new("TextLabel")
subTime.Name = "SubTime"
subTime.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
subTime.Text = "183 Days"
subTime.TextColor3 = Color3.fromRGB(205, 206, 212)
subTime.TextSize = 14
subTime.TextTransparency = 0.6
subTime.BackgroundColor3 = Color3.fromRGB(42, 45, 56)
subTime.BorderColor3 = Color3.fromRGB(0, 0, 0)
subTime.BorderSizePixel = 0
subTime.Position = UDim2.fromScale(0.801, 0.224)
subTime.Size = UDim2.fromOffset(61, 25)
subTime.Parent = gameFrame

local LoaderHandler = {
    Katsura = katsuraGui,
    KatsuraLoading = katsuraLoading,
    GameFrame = gameFrame,
    LoadButton = LoadButton,
    CloseButton = close,
    FramesUrl = {}

}
local Katsura = {}
getgenv().ActiveFrame = nil
local activeTargets = nil
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer
local TWEEN_TIME = 0.2
LoaderHandler.KatsuraLoading.Enabled = false
LoaderHandler.Katsura.Enabled = false

local EnterColor = {
    GameFrame = {
        BackgroundColor3 = "19, 22, 27", 
        BackgroundTransparency = 0.25
    },
    SubTime = {
        TextColor3 = "205, 206, 212",
        BackgroundColor3 = "42, 45, 56",
        BackgroundTransparency = 0,
        TextTransparency = 0
    },
    UpdateStatus = {
        TextColor3 = "205, 206, 212",
        BackgroundColor3 = "255, 255, 255",
        TextTransparency = 0
    },
    GameName = {
        TextColor3 = "133, 127, 187",
        BackgroundTransparency = 1,
        TextTransparency = 0
    },
    Image = {
        ImageTransparency = 0,
    }
}

local LeaveColor = {
    GameFrame = {
        BackgroundColor3 = "23, 26, 31", 
        BackgroundTransparency = 0.25
    },
    SubTime = {
        TextColor3 = "190, 190, 190",
        BackgroundTransparency = 0.6,
        TextTransparency = 0.6
    },
    UpdateStatus = {
        TextColor3 = "190, 190, 190",
        BackgroundColor3 = "255, 255, 255",
        BackgroundTransparency = 1,
        TextTransparency = 0.6
    },
    GameName = {
        TextColor3 = "190, 190, 190",
        BackgroundTransparency = 1,
        TextTransparency = 0.6
    },
    Image = {
        ImageTransparency = 0.6,
    }
}



function Katsura.parseColor(value)
    if typeof(value) == "string" then
        local r, g, b = string.match(value, "(%d+),%s*(%d+),%s*(%d+)")
        if r and g and b then
            return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
        end
    end
    return value
end
function Katsura.applyStyle(styleTable, targets)
    for name, props in pairs(styleTable) do
        local instance = targets[name]
        if instance then
            local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local goal = {}

            for property, value in pairs(props) do
                goal[property] = Katsura.parseColor(value)
            end

            local tween = TweenService:Create(instance, tweenInfo, goal)
            tween:Play()
        end
    end
end
function Katsura.ApplyHoverEffect(gameFrame)
    local targets = {
        GameFrame = gameFrame,
        SubTime = gameFrame:FindFirstChild("SubTime"),
        UpdateStatus = gameFrame:FindFirstChild("UpdateStatus"),
        GameName = gameFrame:FindFirstChild("GameName"),
        Image = gameFrame:FindFirstChildWhichIsA("ImageLabel")
    }

    if not targets.GameFrame then return end

    gameFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if getgenv().ActiveFrame and getgenv().ActiveFrame ~= gameFrame then
                Katsura.applyStyle(LeaveColor, activeTargets)
            end
                Katsura.applyStyle(EnterColor, targets)
            getgenv().ActiveFrame = gameFrame
            activeTargets = targets
        end
    end)
end
function Katsura.ApplyHoverEffectToAny(guiObject, enterStyle, leaveStyle)
    if not guiObject or not guiObject:IsA("GuiObject") then return end
    local name = guiObject.Name
    local targets = {
        [name] = guiObject
    }

    guiObject.MouseEnter:Connect(function()
           Katsura.applyStyle(enterStyle or EnterColor, targets)
    end)

    guiObject.MouseLeave:Connect(function()
           Katsura.applyStyle(leaveStyle or LeaveColor, targets)
    end)
end
function Katsura.CloseGuiEffect(screenGui)
    if not screenGui or not screenGui:IsA("ScreenGui") then return end

    local TweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local lastTween = nil

    for _, guiObject in ipairs(screenGui:GetDescendants()) do
        if guiObject:IsA("GuiObject") then
            local goal = {}

            if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
                goal.TextTransparency = 1
            end

            if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
                goal.ImageTransparency = 1
            end

            goal.BackgroundTransparency = 1

            local tween = TweenService:Create(guiObject, tweenInfo, goal)
            tween:Play()
            lastTween = tween
        elseif guiObject:IsA("UIStroke") then
            local strokeTween = TweenService:Create(guiObject, tweenInfo, { Transparency = 1 })
            strokeTween:Play()
            lastTween = strokeTween
        end
    end

    if lastTween then
        lastTween.Completed:Once(function()
            if screenGui then
                screenGui:Destroy()
            end
        end)
    else
        screenGui:Destroy()
    end
end

function Katsura.LoadingEffect(duration, player, frameConfigs, mainTemplate, gameFrameTemplate, callback)
    if not player or not player:IsA("Player") then return end
    if not mainTemplate or not gameFrameTemplate then
        warn("Missing main UI or GameFrame template")
        return
    end

    local TweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local loadingTemplate = LoaderHandler.KatsuraLoading
    if not loadingTemplate then
        warn("Missing KatsuraLoading GUI")
        return
    end

    local clonedLoadingUI = loadingTemplate:Clone()
    clonedLoadingUI.Parent = player:WaitForChild("PlayerGui")
    clonedLoadingUI.Enabled = true

    local loadingWindow = clonedLoadingUI:FindFirstChild("LoadingWindow")
    if not loadingWindow then
        loadingWindow = loadingTemplate.Parent:FindFirstChild("LoadingWindow")
        if loadingWindow then
            local clonedLoadingWindow = loadingWindow:Clone()
            clonedLoadingWindow.Parent = clonedLoadingUI
            loadingWindow = clonedLoadingWindow
        else
            warn("LoadingWindow not found in template or parent")
            return
        end
    end

    local backgroundFrame = loadingWindow.TopLabels:FindFirstChild("BackgroundLoadBar")
        Katsura.MakeDraggable(loadingWindow)

    local loadingLine = backgroundFrame and backgroundFrame:FindFirstChild("LoadingLine")
    if not backgroundFrame or not loadingLine then return end

    loadingLine.Size = UDim2.new(0, 0, 1, 0)
    local tween = TweenService:Create(loadingLine, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})
    tween:Play()

    tween.Completed:Once(function()
            if Katsura.CloseGuiEffect then
            Katsura.CloseGuiEffect(clonedLoadingUI)
        else
            clonedLoadingUI:Destroy()
        end

        for _, gui in ipairs(player:WaitForChild("PlayerGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name == mainTemplate.Name then
                gui:Destroy()
            end
        end

        getgenv().newUI = mainTemplate:Clone()
        newUI.Parent = player:WaitForChild("PlayerGui")
        newUI.Enabled = true

        local gamesHolder = newUI.Main and newUI.Main.GamesHolder
        if not gamesHolder then
            warn("Missing GamesHolder")
            return
        end

        Katsura.MakeDraggable(newUI.Main)
        local Load = newUI.Main.LoadFrame.Load
        local Close = newUI.Main.TopLabels.Close

        Katsura.ApplyHoverEffectToAny(Load, {
            Load = { TextColor3 = "205, 206, 212", TextTransparency = 0 }
        }, {
            Load = { TextColor3 = "190, 190, 190", TextTransparency = 0.6 }
        })

        -- Load Button Logic
        Load.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            local active = getgenv().ActiveFrame
            if not active then return end
            local frameCallback = LoaderHandler.FrameCallbacks 
                and LoaderHandler.FrameCallbacks[active]

            if typeof(frameCallback) == "function" then
                frameCallback(active, newUI)
                return
            end
            local url = LoaderHandler.FramesUrl[active]
            if url then
                Katsura.CloseGuiEffect(newUI)
                loadstring(game:HttpGet(url))()
            end
        end)

        Katsura.ApplyHoverEffectToAny(Close, {
            Close = { TextColor3 = "205, 206, 212", TextTransparency = 0 }
        }, {
            Close = { TextColor3 = "190, 190, 190", TextTransparency = 0.6 }
        })

        Close.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Katsura.CloseGuiEffect(newUI)
            end
        end)

        -- Create Frames
        LoaderHandler.FramesUrl = LoaderHandler.FramesUrl or {}
        LoaderHandler.FrameCallbacks = LoaderHandler.FrameCallbacks or {}

        for i, config in ipairs(frameConfigs or {}) do
            local frame = gameFrameTemplate:Clone()
            frame.Name = "GameFrame_" .. i
            frame.Parent = gamesHolder

            Katsura.ApplyHoverEffect(frame)

            if frame.GameName then
                frame.GameName.Text = config.GameName or ("Game " .. i)
            end
            if frame.ImageLabel then
                frame.ImageLabel.Image = config.Image or ""
            end
            if frame.SubTime then
                frame.SubTime.Text = config.SubTime or "Updated Recently"
            end
            if frame.UpdateStatus then
                frame.UpdateStatus.Text = config.Status or "Unknown"
            end

            if config.Url then
                LoaderHandler.FramesUrl[frame] = config.Url
            end
            if typeof(config.Callback) == "function" then
                LoaderHandler.FrameCallbacks[frame] = config.Callback
            end
            if config.Properties then
                for childName, props in pairs(config.Properties) do
                    local child = frame:FindFirstChild(childName)
                    if child then
                        for prop, val in pairs(props) do
                            pcall(function()
                                child[prop] = val
                            end)
                        end
                    end
                end
            end
        end
    end)
end

function Katsura.MakeDraggable(guiObject)
    if not guiObject or not guiObject:IsA("GuiObject") then return end

    local dragging = false
    local startMousePos = nil
    local startGuiPos = nil

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMousePos = UserInputService:GetMouseLocation()
            startGuiPos = guiObject.AbsolutePosition

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not dragging then return end

        local mousePos = UserInputService:GetMouseLocation()
        local delta = mousePos - startMousePos
        local newTopLeft = startGuiPos + delta

        local camera = workspace.CurrentCamera
        local screenSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        local size = guiObject.AbsoluteSize
        local anchor = guiObject.AnchorPoint

        -- Clamp top-left so the GUI stays onscreen
        newTopLeft = Vector2.new(
            math.clamp(newTopLeft.X, 0, math.max(0, screenSize.X - size.X)),
            math.clamp(newTopLeft.Y, 0, math.max(0, screenSize.Y - size.Y))
        )

        -- Position property expects the anchored position, so add anchor*size
        local positionAbsolute = newTopLeft + Vector2.new(anchor.X * size.X, anchor.Y * size.Y)
        guiObject.Position = UDim2.fromOffset(math.floor(positionAbsolute.X + 0.5), math.floor(positionAbsolute.Y + 0.5))
    end)
end
return Katsura,LoaderHandler.Katsura, LoaderHandler.GameFrame
