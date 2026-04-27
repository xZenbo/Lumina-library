-- [[ LUMINA UI LIBRARY - THE DEFINITIVE EXPERIENCE ]]
-- [Features: Glassmorphism Blur, Advanced Easing, Dynamic Shadows, Auto-Config, Sections]

local Lumina = {}
Lumina.__index = Lumina
Lumina.Windows = {}
Lumina._Configurables = {}
Lumina._ColorPickers = {}
Lumina._ThemeDropdown = nil

local Lucide = {}
pcall(function()
    Lucide = loadstring(game:HttpGet("https://github.com/latte-soft/lucide-roblox/releases/latest/download/lucide-roblox.luau"))()
end)

local function ApplyIcon(UIElement, Name)
    if not Name or Name == "" then 
        UIElement.Image = ""
        UIElement.ImageRectSize = Vector2.new(0, 0)
        UIElement.ImageRectOffset = Vector2.new(0, 0)
        return 
    end
    
    if Name:match("rbxassetid://") or Name:match("http://") or Name:match("https://") then 
        UIElement.Image = Name
        UIElement.ImageRectSize = Vector2.new(0, 0)
        UIElement.ImageRectOffset = Vector2.new(0, 0)
        return 
    end
    
    local cleanName = Name:lower():gsub("^lucide%-", "")
    
    if Lucide and Lucide.GetAsset then
        local success, asset = pcall(function() return Lucide.GetAsset(cleanName) end)
        if success and asset then
            UIElement.Image = asset.Url
            UIElement.ImageRectSize = asset.ImageRectSize
            UIElement.ImageRectOffset = asset.ImageRectOffset
            return
        end
    end
    
    UIElement.Image = Name
    UIElement.ImageRectSize = Vector2.new(0, 0)
    UIElement.ImageRectOffset = Vector2.new(0, 0)
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Theme = {
    MainSide = Color3.fromRGB(20, 20, 25),
    Background = Color3.fromRGB(15, 15, 18),
    Accent = Color3.fromRGB(114, 137, 218),
    Text = Color3.fromRGB(255, 255, 255),
    SecondaryText = Color3.fromRGB(160, 160, 160),
    Topbar = Color3.fromRGB(25, 25, 30),
    Stroke = Color3.fromRGB(45, 45, 55)
}

local ThemeRegistry = { Background = {}, MainSide = {}, Accent = {}, Topbar = {}, Text = {}, SecondaryText = {}, Stroke = {} }

local Presets = {
    ["Default Dark"] = {GradientEdge = Color3.fromRGB(114, 137, 218), Accent = Color3.fromRGB(114, 137, 218), MainSide = Color3.fromRGB(20, 20, 25), Background = Color3.fromRGB(15, 15, 18), Topbar = Color3.fromRGB(25, 25, 30), Text = Color3.fromRGB(255, 255, 255), SecondaryText = Color3.fromRGB(190, 190, 190), Stroke = Color3.fromRGB(45, 45, 55)},
    ["Midnight"] = {GradientEdge = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(255, 255, 255), MainSide = Color3.fromRGB(10, 10, 10), Background = Color3.fromRGB(5, 5, 5), Topbar = Color3.fromRGB(15, 15, 15), Text = Color3.fromRGB(255, 255, 255), SecondaryText = Color3.fromRGB(180, 180, 180), Stroke = Color3.fromRGB(35, 35, 45)},
    ["Sakura"] = {GradientEdge = Color3.fromRGB(255, 175, 204), Accent = Color3.fromRGB(255, 175, 204), MainSide = Color3.fromRGB(40, 30, 35), Background = Color3.fromRGB(30, 20, 25), Topbar = Color3.fromRGB(45, 35, 40), Text = Color3.fromRGB(255, 220, 230), SecondaryText = Color3.fromRGB(200, 190, 190), Stroke = Color3.fromRGB(60, 45, 50)},
    ["Oceanic"] = {GradientEdge = Color3.fromRGB(0, 170, 255), Accent = Color3.fromRGB(0, 170, 255), MainSide = Color3.fromRGB(15, 25, 35), Background = Color3.fromRGB(10, 15, 25), Topbar = Color3.fromRGB(20, 35, 50), Text = Color3.fromRGB(230, 240, 255), SecondaryText = Color3.fromRGB(180, 200, 220), Stroke = Color3.fromRGB(35, 50, 70)},
    ["Cyberpunk"] = {GradientEdge = Color3.fromRGB(255, 0, 85), Accent = Color3.fromRGB(255, 0, 85), MainSide = Color3.fromRGB(20, 20, 30), Background = Color3.fromRGB(15, 15, 20), Topbar = Color3.fromRGB(30, 25, 40), Text = Color3.fromRGB(0, 255, 200), SecondaryText = Color3.fromRGB(190, 190, 190), Stroke = Color3.fromRGB(50, 40, 60)},
    ["Ruby"] = {GradientEdge = Color3.fromRGB(220, 50, 50), Accent = Color3.fromRGB(220, 50, 50), MainSide = Color3.fromRGB(30, 15, 15), Background = Color3.fromRGB(20, 10, 10), Topbar = Color3.fromRGB(40, 20, 20), Text = Color3.fromRGB(255, 220, 220), SecondaryText = Color3.fromRGB(180, 160, 160), Stroke = Color3.fromRGB(60, 30, 30)},
    ["Custom"] = {}
}

-- [[ AUTO-CONFIG SYSTEM ]]
local ConfigData = {}
local FolderPath = "Lumina"
local GameFolderStr = "Configs/" .. tostring(game.PlaceId)

if makefolder then
    pcall(function() makefolder(FolderPath) end)
    pcall(function() makefolder(FolderPath .. "/Configs") end)
    pcall(function() makefolder(FolderPath .. "/" .. GameFolderStr) end)
end

local function SaveConfig(name, force)
    if not Lumina.AutoSave and not force then return end
    name = type(name) == "string" and name or Lumina.CurrentConfig or "Default"
    local normalized = name:gsub("\\", "/")
    local safeName = normalized:match("([^/]+)$") or normalized
    if writefile then
        pcall(function() writefile(FolderPath .. "/" .. GameFolderStr .. "/" .. safeName .. ".json", HttpService:JSONEncode(ConfigData)) end)
    end
end

local function LoadConfig(name)
    name = type(name) == "string" and name or "Default"
    local normalized = name:gsub("\\", "/")
    local safeName = normalized:match("([^/]+)$") or normalized
    if isfile and isfile(FolderPath .. "/" .. GameFolderStr .. "/" .. safeName .. ".json") then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(FolderPath .. "/" .. GameFolderStr .. "/" .. safeName .. ".json")) end)
        if success then 
            ConfigData = data 
            
            if ConfigData["Lumina_ThemePreset"] and not ConfigData["Theme Presets"] then 
                ConfigData["Theme Presets"] = ConfigData["Lumina_ThemePreset"] 
            end

            Lumina.CurrentConfig = safeName
            if Lumina._Configurables then
                for _, refresh in ipairs(Lumina._Configurables) do
                    pcall(refresh)
                end
            end
        end
    end
end

local function GetConfigs()
    local configs = {}
    if listfiles then
        local success, files = pcall(function() return listfiles(FolderPath .. "/" .. GameFolderStr) end)
        if success then
            for _, file in ipairs(files) do
                local normalized = file:gsub("\\", "/")
                local name = normalized:match("([^/]+)%.json$")
                if name then table.insert(configs, name) end
            end
        end
    end
    if #configs == 0 then table.insert(configs, "Default") end
    return configs
end

Lumina.CurrentConfig = "Default"

local InitialLoadName = "Default"
local AutoLoadEnabled = false
if isfile and isfile(FolderPath .. "/" .. GameFolderStr .. "/Autoload.txt") then
    local success, autoName = pcall(function() return readfile(FolderPath .. "/" .. GameFolderStr .. "/Autoload.txt") end)
    if success and autoName ~= "" then 
        InitialLoadName = autoName 
        AutoLoadEnabled = true
    end
end
LoadConfig(InitialLoadName)

if ConfigData["Lumina_AutoSave"] ~= nil then
    Lumina.AutoSave = ConfigData["Lumina_AutoSave"]
else
    Lumina.AutoSave = false
end

Lumina.GradientEnabled = ConfigData["Lumina_GradientEffect"] or true
Lumina._Gradients = {}

local function Register(obj, category, prop)
    if not prop then
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then prop = "TextColor3"
        elseif obj:IsA("UIStroke") then prop = "Color"
        else prop = "BackgroundColor3" end
    end
    for cat, list in pairs(ThemeRegistry) do
        for i = #list, 1, -1 do
            if list[i].Instance == obj and list[i].Property == prop then
                table.remove(list, i)
            end
        end
    end
    table.insert(ThemeRegistry[category], {Instance = obj, Property = prop})
    obj[prop] = Theme[category]
end

local function UpdateGradients()
    local gradCol = Theme.GradientEdge or Theme.Accent
    local strokeCol = Theme.Stroke
    local seq = ColorSequence.new({
        ColorSequenceKeypoint.new(0, strokeCol),
        ColorSequenceKeypoint.new(0.5, gradCol),
        ColorSequenceKeypoint.new(1, strokeCol)
    })
    for _, grad in pairs(Lumina._Gradients) do
        pcall(function() 
            grad.Color = seq
            if grad.Parent and grad.Parent:IsA("UIStroke") then
                if Lumina.GradientEnabled then
                    grad.Parent.Color = Color3.new(1, 1, 1)
                else
                    grad.Parent.Color = strokeCol
                end
            end
        end)
    end
end

local function UpdateTheme(category, color)
    if typeof(category) == "table" then
        for cat, col in pairs(category) do UpdateTheme(cat, col) end
        if Lumina._ColorPickers then
            for _, updateFn in ipairs(Lumina._ColorPickers) do
                pcall(updateFn)
            end
        end
        return
    end
    Theme[category] = color
    if ThemeRegistry[category] then
        local i = 1
        local batchCounter = 0
        while i <= #ThemeRegistry[category] do
            local data = ThemeRegistry[category][i]
            if data.Instance and data.Instance.Parent then
                local skipTween = false
                if Lumina.GradientEnabled and category == "Stroke" and data.Instance:IsA("UIStroke") and data.Instance:FindFirstChildOfClass("UIGradient") then
                    skipTween = true
                end
                
                if not skipTween then
                    TweenService:Create(data.Instance, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[data.Property] = color}):Play()
                end
                
                i = i + 1
                batchCounter = batchCounter + 1
                if batchCounter % 50 == 0 then
                    task.wait() -- Yield to prevent freezing on huge updates
                end
            else
                table.remove(ThemeRegistry[category], i)
            end
        end
    end
    
    -- Update Gradients!
    if category == "GradientEdge" or category == "Accent" or category == "Stroke" then
        UpdateGradients()
    end
end

-- [[ ADVANCED EASING UTILITY ]]
local function CreateTween(instance, properties, duration, style, direction)
    local tInfo = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tInfo, properties)
    tween:Play()
    return tween
end

local function ApplyBounce(Clickable, TargetFrame)
    TargetFrame = TargetFrame or Clickable
    local scaleObj = TargetFrame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", TargetFrame)
    
    local hovering = false
    Clickable.MouseEnter:Connect(function()
        hovering = true
        CreateTween(scaleObj, {Scale = 1.01}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end)
    Clickable.MouseLeave:Connect(function()
        hovering = false
        CreateTween(scaleObj, {Scale = 1}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end)
    Clickable.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            CreateTween(scaleObj, {Scale = 0.98}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end
    end)
    Clickable.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            CreateTween(scaleObj, {Scale = hovering and 1.01 or 1}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)
end

local function MakeDraggable(Frame, Handle, Window)
    local Dragging, DragStart, StartPos
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPos = Frame.Position
        end
    end)
    local c1 = UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = input.Position - DragStart
            Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
    local c2 = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
    end)
    if Window and type(Window) == "table" and Window.Connections then
        table.insert(Window.Connections, c1)
        table.insert(Window.Connections, c2)
    end
end

local function MakeResizable(Frame, Handle, MinSize, MaxSize, Window)
    local Dragging, DragStart, StartSize
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartSize = Frame.AbsoluteSize
        end
    end)
    local c1 = UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = input.Position - DragStart
            local newWidth = math.clamp(StartSize.X + Delta.X, MinSize.X, MaxSize.X)
            local newHeight = math.clamp(StartSize.Y + Delta.Y, MinSize.Y, MaxSize.Y)
            Frame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
    local c2 = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
    end)
    if Window and type(Window) == "table" and Window.Connections then
        table.insert(Window.Connections, c1)
        table.insert(Window.Connections, c2)
    end
end

function Lumina.CreateWindow(Config)
    local self = setmetatable({}, Lumina)
    table.insert(Lumina.Windows, self)
    
    self.Tabs = {}
    self.Connections = {}
    local MaxSize = Config.MaxSize or Vector2.new(900, 700)
    
    local rsConn = RunService.RenderStepped:Connect(function(dt)
        if Lumina.GradientEnabled then
            for _, grad in pairs(Lumina._Gradients) do
                if grad.Parent then
                    grad.Rotation = (grad.Rotation + 90 * dt) % 360
                end
            end
        end
    end)
    table.insert(self.Connections, rsConn)
    self.Visible = true
    self.ToggleKey = (ConfigData["Lumina_ToggleKey"] and Enum.KeyCode[ConfigData["Lumina_ToggleKey"]]) or Config.Keybind or Enum.KeyCode.LeftControl
    
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "Lumina"
    self.Gui.ResetOnSpawn = false
    self.Gui.Parent = gethui()
    
    self.UseCanvasGroup = Config.UseCanvasGroup
    if self.UseCanvasGroup == nil then self.UseCanvasGroup = true end -- Default to true for premium fade

    self.Main = Instance.new(self.UseCanvasGroup and "CanvasGroup" or "Frame")
    self.Main.Size = UDim2.new(0, 650, 0, 450)
    self.Main.Position = UDim2.new(0.5, -325, 0.5, -225)
    
    local targetBgTrans = 0.05 -- slight transparency to make CanvasGroup shine
    
    if self.UseCanvasGroup then
        self.Main.GroupTransparency = 1
        self.Main.BackgroundTransparency = targetBgTrans
    else
        self.Main.BackgroundTransparency = 0
    end
    
    Register(self.Main, "Background")
    self.Main.BorderSizePixel = 0
    self.Main.Parent = self.Gui

    local MainScale = Instance.new("UIScale")
    MainScale.Name = "WindowScale"
    MainScale.Parent = self.Main
    MainScale.Scale = 0.9

    local MainCorner = Instance.new("UICorner", self.Main)
    MainCorner.CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", self.Main)
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Thickness = 2.5
    MainStroke.Transparency = 0.2
    Register(MainStroke, "Stroke", "Color")
    
    local MainGradient = Instance.new("UIGradient", MainStroke)
    MainGradient.Enabled = Lumina.GradientEnabled
    table.insert(Lumina._Gradients, MainGradient)

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Register(Topbar, "Topbar")
    Topbar.BorderSizePixel = 0
    Topbar.Parent = self.Main
    
    local TopbarCorner = Instance.new("UICorner", Topbar)
    TopbarCorner.CornerRadius = UDim.new(0, 12)
    
    local TopbarPatch = Instance.new("Frame", Topbar)
    TopbarPatch.Size = UDim2.new(1, 0, 0, 12)
    TopbarPatch.Position = UDim2.new(0, 0, 1, -12)
    TopbarPatch.BorderSizePixel = 0
    Register(TopbarPatch, "Topbar")
    
    local Title = Instance.new("TextLabel")
    Title.Text = Config.Name or "Lumina"
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Register(Title, "Text")
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar

    local MinimizeBtn = Instance.new("ImageButton", Topbar)
    MinimizeBtn.Size = UDim2.new(0, 16, 0, 16)
    MinimizeBtn.Position = UDim2.new(1, -28, 0.5, -8)
    MinimizeBtn.BackgroundTransparency = 1
    ApplyIcon(MinimizeBtn, "lucide-minus")
    Register(MinimizeBtn, "SecondaryText", "ImageColor3")
    
    MinimizeBtn.MouseEnter:Connect(function() CreateTween(MinimizeBtn, {ImageTransparency = 0.5}, 0.2) end)
    MinimizeBtn.MouseLeave:Connect(function() CreateTween(MinimizeBtn, {ImageTransparency = 0}, 0.2) end)

    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Size = UDim2.new(0.28, 0, 1, -40)
    self.Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Register(self.Sidebar, "MainSide")
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Parent = self.Main
    
    local SidebarCorner = Instance.new("UICorner", self.Sidebar)
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    
    local SidebarPatchTop = Instance.new("Frame", self.Sidebar)
    SidebarPatchTop.Size = UDim2.new(1, 0, 0, 12)
    SidebarPatchTop.Position = UDim2.new(0, 0, 0, 0)
    SidebarPatchTop.BorderSizePixel = 0
    Register(SidebarPatchTop, "MainSide")

    local SidebarPatchRight = Instance.new("Frame", self.Sidebar)
    SidebarPatchRight.Size = UDim2.new(0, 12, 1, 0)
    SidebarPatchRight.Position = UDim2.new(1, -12, 0, 0)
    SidebarPatchRight.BorderSizePixel = 0
    Register(SidebarPatchRight, "MainSide")

    local SideStroke = Instance.new("Frame")
    SideStroke.Size = UDim2.new(0, 1, 1, 0)
    SideStroke.Position = UDim2.new(1, 0, 0, 0)
    Register(SideStroke, "Stroke", "BackgroundColor3")
    SideStroke.BorderSizePixel = 0
    SideStroke.Parent = self.Sidebar

    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(0.72, -16, 1, -56)
    self.Container.Position = UDim2.new(0.28, 8, 0, 48)
    self.Container.BackgroundTransparency = 1
    self.Container.ClipsDescendants = true
    self.Container.Parent = self.Main

    self.TabList = Instance.new("ScrollingFrame")
    self.TabList.Size = UDim2.new(1, 0, 1, 0)
    self.TabList.BackgroundTransparency = 1
    self.TabList.ScrollBarThickness = 0
    self.TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabList.Parent = self.Sidebar

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Parent = self.TabList
    SideLayout.Padding = UDim.new(0, 6)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local SidePad = Instance.new("UIPadding", self.TabList)
    SidePad.PaddingTop = UDim.new(0, 8)
    
    local ResizeHandle = Instance.new("ImageLabel", self.Main)
    ResizeHandle.Size = UDim2.new(0, 16, 0, 16)
    ResizeHandle.Position = UDim2.new(1, -16, 1, -16)
    ResizeHandle.BackgroundTransparency = 1
    ApplyIcon(ResizeHandle, "lucide-scaling")
    ResizeHandle.ImageTransparency = 0.5
    Register(ResizeHandle, "SecondaryText", "ImageColor3")
    
    MakeDraggable(self.Main, Topbar, self)
    MakeResizable(self.Main, ResizeHandle, Vector2.new(450, 300), MaxSize, self)

    -- Floating Minimized Toggle
    self.MobileToggle = Instance.new("TextButton")
    self.MobileToggle.Size = UDim2.new(0, 46, 0, 46)
    self.MobileToggle.Position = UDim2.new(0.5, -23, 0, 15)
    self.MobileToggle.BackgroundTransparency = 0.1
    self.MobileToggle.Text = ""
    self.MobileToggle.Parent = self.Gui
    self.MobileToggle.Visible = false
    
    local MobileToggleCorner = Instance.new("UICorner", self.MobileToggle)
    MobileToggleCorner.CornerRadius = UDim.new(0, 14)
    local MobileToggleStroke = Instance.new("UIStroke", self.MobileToggle)
    MobileToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MobileToggleStroke.Thickness = 2
    MobileToggleStroke.Transparency = 0.2
    
    local MobileToggleGradient = Instance.new("UIGradient", MobileToggleStroke)
    MobileToggleGradient.Enabled = Lumina.GradientEnabled
    table.insert(Lumina._Gradients, MobileToggleGradient)
    
    local MobileToggleScale = Instance.new("UIScale", self.MobileToggle)
    
    local MobileToggleIcon = Instance.new("ImageLabel", self.MobileToggle)
    MobileToggleIcon.Size = UDim2.new(0, 24, 0, 24)
    MobileToggleIcon.Position = UDim2.new(0.5, -12, 0.5, -12)
    MobileToggleIcon.BackgroundTransparency = 1
    ApplyIcon(MobileToggleIcon, Config.Icon or "lucide-terminal")

    Register(self.MobileToggle, "MainSide", "BackgroundColor3")
    Register(MobileToggleIcon, "Accent", "ImageColor3")
    Register(MobileToggleStroke, "Stroke", "Color")

    self.MobileToggle.MouseEnter:Connect(function()
        CreateTween(MobileToggleScale, {Scale = 1.05}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        CreateTween(MobileToggleStroke, {Transparency = 0}, 0.2)
    end)
    self.MobileToggle.MouseLeave:Connect(function()
        CreateTween(MobileToggleScale, {Scale = 1}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        CreateTween(MobileToggleStroke, {Transparency = 0.4}, 0.2)
    end)
    self.MobileToggle.MouseButton1Down:Connect(function()
        CreateTween(MobileToggleScale, {Scale = 0.95}, 0.15)
    end)
    self.MobileToggle.MouseButton1Up:Connect(function()
        CreateTween(MobileToggleScale, {Scale = 1.05}, 0.15)
    end)

    MakeDraggable(self.MobileToggle, self.MobileToggle, self)

    self.MobileToggle.MouseButton1Click:Connect(function()
        self:SetVisible(true)
    end)
    
    local function GetTargetScale()
        local vp = workspace.CurrentCamera.ViewportSize
        return math.clamp(math.min(vp.X / 1024, vp.Y / 768), 0.5, 1)
    end

    local activePos = self.Main.Position

    function self:SetVisible(state)
        if self._Toggling then return end
        self._Toggling = true
        self.Visible = state
        
        local Main = self.Main
        local Scale = Main:FindFirstChild("WindowScale") or Instance.new("UIScale", Main)
        Scale.Name = "WindowScale"

        local duration = 0.4
        local style = Enum.EasingStyle.Quint
        local dir = Enum.EasingDirection.Out
        
        local targetScale = GetTargetScale()

        if state then
            self.MobileToggle.Visible = false
            Main.Visible = true
            if self.UseCanvasGroup then Main.GroupTransparency = 1 end
            Scale.Scale = targetScale * 0.8
            
            local targetPos = activePos
            Main.Position = UDim2.new(targetPos.X.Scale, targetPos.X.Offset, targetPos.Y.Scale, targetPos.Y.Offset + 20)

            local tweenProps = {Position = targetPos}
            if self.UseCanvasGroup then tweenProps.GroupTransparency = 0 end

            CreateTween(Main, tweenProps, duration, style, dir)
            
            local scaleTween = CreateTween(Scale, {Scale = targetScale}, duration, style, dir)
            scaleTween.Completed:Wait()
        else
            activePos = Main.Position
            
            local tweenProps = {Position = UDim2.new(activePos.X.Scale, activePos.X.Offset, activePos.Y.Scale, activePos.Y.Offset + 20)}
            if self.UseCanvasGroup then tweenProps.GroupTransparency = 1 end

            CreateTween(Main, tweenProps, duration * 0.7, style, Enum.EasingDirection.In)
            
            local scaleTween = CreateTween(Scale, {Scale = targetScale * 0.8}, duration * 0.7, style, Enum.EasingDirection.In)
            scaleTween.Completed:Wait()
            
            if not self.Visible then
                Main.Visible = false
                Main.Position = activePos
                self.MobileToggle.Visible = true
            end
        end
        
        self._Toggling = false
    end

    local viewportConn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if self.Visible and not self._Toggling then
            local newScale = GetTargetScale()
            local currentScale = self.Main:FindFirstChild("WindowScale")
            if currentScale then
                CreateTween(currentScale, {Scale = newScale}, 0.2)
            end
        end
    end)
    table.insert(self.Connections, viewportConn)

    MinimizeBtn.MouseButton1Click:Connect(function()
        self:SetVisible(false)
    end)

    local toggleConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.ToggleKey then
            self:SetVisible(not self.Visible)
        end
    end)
    table.insert(self.Connections, toggleConn)

    -- Static container for Notifications
    self.ToastContainer = Instance.new("Frame")
    self.ToastContainer.Size = UDim2.new(0, 300, 1, -40)
    self.ToastContainer.Position = UDim2.new(1, -320, 0, 20)
    self.ToastContainer.BackgroundTransparency = 1
    self.ToastContainer.Parent = self.Gui
    local ToastLayout = Instance.new("UIListLayout", self.ToastContainer)
    ToastLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ToastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    ToastLayout.Padding = UDim.new(0, 10)

    -- [[ LOADING SCREEN INJECTION ]]
    local Splash = Instance.new("Frame", self.Gui)
    Splash.Size = UDim2.new(0, 260, 0, 120)
    Splash.Position = UDim2.new(0.5, -130, 0.5, -60)
    Register(Splash, "MainSide", "BackgroundColor3")
    Instance.new("UICorner", Splash).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", Splash).Color = Color3.fromRGB(45, 45, 55)
    Register(Splash.UIStroke, "Stroke", "Color")

    local SplashLogo = Instance.new("ImageLabel", Splash)
    SplashLogo.Size = UDim2.new(0, 36, 0, 36)
    SplashLogo.Position = UDim2.new(0.5, -18, 0, 24)
    SplashLogo.BackgroundTransparency = 1
    ApplyIcon(SplashLogo, Config.Icon or "lucide-terminal")
    Register(SplashLogo, "Accent", "ImageColor3")

    local SplashTitle = Instance.new("TextLabel", Splash)
    SplashTitle.Size = UDim2.new(1, 0, 0, 20)
    SplashTitle.Position = UDim2.new(0, 0, 0, 68)
    SplashTitle.BackgroundTransparency = 1
    SplashTitle.Text = "Lumina"
    SplashTitle.Font = Enum.Font.GothamMedium
    SplashTitle.TextSize = 13
    Register(SplashTitle, "Text", "TextColor3")

    local SplashBarBg = Instance.new("Frame", Splash)
    SplashBarBg.Size = UDim2.new(0, 180, 0, 2)
    SplashBarBg.Position = UDim2.new(0.5, -90, 1, -20)
    Register(SplashBarBg, "Stroke", "BackgroundColor3")

    local SplashBarFill = Instance.new("Frame", SplashBarBg)
    SplashBarFill.Size = UDim2.new(0, 0, 1, 0)
    Register(SplashBarFill, "Accent", "BackgroundColor3")

    -- Initially hide main globally by moving it offscreen
    local startPos = self.Main.Position
    self.Main.Position = UDim2.new(2, 0, 2, 0)
    self.Main.Visible = true
    if self.UseCanvasGroup then self.Main.GroupTransparency = 1 end

    task.spawn(function()
        task.wait(0.2)
        -- Animate bar
        CreateTween(SplashBarFill, {Size = UDim2.new(0.4, 0, 1, 0)}, 0.4, Enum.EasingStyle.Quart)
        task.wait(0.3)
        CreateTween(SplashBarFill, {Size = UDim2.new(0.8, 0, 1, 0)}, 0.6, Enum.EasingStyle.Quart)
        task.wait(0.2)
        CreateTween(SplashBarFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.2, Enum.EasingStyle.Quart)
        task.wait(0.25)
        
        -- Explode Splash away
        CreateTween(Splash, {Size = UDim2.new(0, 300, 0, 140), Position = UDim2.new(0.5, -150, 0.5, -70), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        for _, obj in pairs(Splash:GetDescendants()) do
            if obj:IsA("TextLabel") then CreateTween(obj, {TextTransparency = 1}, 0.3)
            elseif obj:IsA("ImageLabel") then CreateTween(obj, {ImageTransparency = 1}, 0.3)
            elseif obj:IsA("Frame") then CreateTween(obj, {BackgroundTransparency = 1}, 0.3)
            elseif obj:IsA("UIStroke") then CreateTween(obj, {Transparency = 1}, 0.3) end
        end
        
        task.wait(0.35)
        
        -- Hide inactive tabs that were visible just to compute layout sizes
        for _, t in pairs(self.Tabs) do
            if self.ActiveTab ~= t then t.Frame.Visible = false end
        end

        -- Open Main UI beautifully
        local finalPos = startPos
        local Scale = self.Main:FindFirstChild("WindowScale")
        if Scale then Scale.Scale = GetTargetScale() * 0.8 end
        
        self.Main.Position = UDim2.new(finalPos.X.Scale, finalPos.X.Offset, finalPos.Y.Scale, finalPos.Y.Offset + 20)
        self.Main.Visible = true
        
        local tweenProps = {Position = finalPos}
        if self.UseCanvasGroup then tweenProps.GroupTransparency = 0 end
        CreateTween(self.Main, tweenProps, 0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        
        if Scale then
            CreateTween(Scale, {Scale = GetTargetScale()}, 0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end
        task.wait(0.1)
        Splash:Destroy()
    end)

    task.defer(function()
        local SettingsTab = self:CreateTab("Settings", "lucide-settings", true)
        SettingsTab.Btn.LayoutOrder = 99999
        
        local SettingsOpenBtn = Instance.new("ImageButton", Topbar)
        SettingsOpenBtn.Size = UDim2.new(0, 16, 0, 16)
        SettingsOpenBtn.Position = UDim2.new(1, -56, 0.5, -8)
        SettingsOpenBtn.BackgroundTransparency = 1
        ApplyIcon(SettingsOpenBtn, "lucide-settings")
        Register(SettingsOpenBtn, "SecondaryText", "ImageColor3")
        
        -- Hover effects
        SettingsOpenBtn.MouseEnter:Connect(function() CreateTween(SettingsOpenBtn, {ImageTransparency = 0.5}, 0.2) end)
        SettingsOpenBtn.MouseLeave:Connect(function() CreateTween(SettingsOpenBtn, {ImageTransparency = 0}, 0.2) end)
        
        SettingsOpenBtn.MouseButton1Click:Connect(function()
            self:SelectTab(SettingsTab)
        end)

        local ThemeSec = SettingsTab:CreateSection("Theme System", true)
        local presetKeys = {}
        for k, v in pairs(Presets) do table.insert(presetKeys, k) end

        if ConfigData["Lumina_ThemePreset"] and not ConfigData["Theme Presets"] then ConfigData["Theme Presets"] = ConfigData["Lumina_ThemePreset"] end

        Lumina._ThemeDropdown = ThemeSec:CreateDropdown("Theme Presets", presetKeys, function(presetName)
            if Presets[presetName] then
                UpdateTheme(Presets[presetName])
            end
        end)

        ThemeSec:CreateKeybind("Toggle UI", self.ToggleKey, function(key)
            self.ToggleKey = key
        end, false, nil, "Lumina_ToggleKey")
        
        ThemeSec:CreateToggle("Gradient Line Effect", Lumina.GradientEnabled, function(toggled)
            Lumina.GradientEnabled = toggled
            ConfigData["Lumina_GradientEffect"] = toggled
            
            for _, grad in pairs(Lumina._Gradients) do
                if grad then grad.Enabled = toggled end
            end
            UpdateGradients()
            
            if Lumina.AutoSave then SaveConfig() end
        end, true, "Enables an RGB rotation outline around the main UI and mobile toggle", "Lumina_GradientEffect")

        if Config.CustomTheme then
            local CustomThemeSec = SettingsTab:CreateSection("Custom Colors", true)
            for categoryName, colorVal in pairs(Theme) do
                CustomThemeSec:CreateColorPicker(categoryName, categoryName, colorVal, function() end)
            end
        end

        local ConfigSec = SettingsTab:CreateSection("Configuration", true)
        local SelectedConfig = InitialLoadName

        local RefreshDropdown
        local ConfigDropdown = ConfigSec:CreateDropdown("Selected Config", GetConfigs(), function(val)
            SelectedConfig = val
            Lumina.CurrentConfig = val
        end, false, true)
        
        ConfigSec:CreateInput("New Config Name", "", function(val)
            if val and val ~= "" then
                SelectedConfig = val
                Lumina.CurrentConfig = val
                SaveConfig(SelectedConfig, true)
                ConfigDropdown:RefreshOptions(GetConfigs())
                ConfigDropdown:Set(SelectedConfig)
            end
        end, true)

        ConfigSec:CreateButton("Load Selected Config", function()
            LoadConfig(SelectedConfig)
            Lumina:Notify({Title = "Configuration", Content = "Loaded " .. SelectedConfig .. " (Some changes require reload)"})
        end)

        ConfigSec:CreateButton("Save Selected Config", function()
            SaveConfig(SelectedConfig, true)
            ConfigDropdown:RefreshOptions(GetConfigs())
            Lumina:Notify({Title = "Configuration", Content = "Saved " .. SelectedConfig })
        end)

        ConfigSec:CreateToggle("Auto-Save Configuration", Lumina.AutoSave or false, function(toggled)
            Lumina.AutoSave = toggled
            ConfigData["Lumina_AutoSave"] = toggled
            SaveConfig(SelectedConfig, true)
        end, true, "Automatically saves configuration changes")

        ConfigSec:CreateToggle("Auto-Load Selection", AutoLoadEnabled, function(toggled)
            if toggled then
                if writefile then pcall(function() writefile(FolderPath .. "/" .. GameFolderStr .. "/Autoload.txt", SelectedConfig) end) end
            else
                if writefile then pcall(function() writefile(FolderPath .. "/" .. GameFolderStr .. "/Autoload.txt", "") end) end
            end
        end, true, "Automatically loads this configuration on launch")

        local UtilitySec = SettingsTab:CreateSection("Utility", true)
        
        local afkConnection
        UtilitySec:CreateToggle("Anti-AFK", true, function(toggled)
            if toggled then
                local currentCamera = game.Workspace.CurrentCamera
                local virtualUser = game:GetService("VirtualUser")
                local lp = game:GetService("Players").LocalPlayer
                afkConnection = lp.Idled:Connect(function()
                    virtualUser:Button2Down(Vector2.zero, currentCamera.CFrame)
                    task.wait(1)
                    virtualUser:Button2Up(Vector2.zero, currentCamera.CFrame)
                end)
            else
                if afkConnection then
                    afkConnection:Disconnect()
                    afkConnection = nil
                end
            end
        end, true, "Prevents Roblox from disconnecting you for being idle.")

        UtilitySec:CreateButton("Destroy UI", function()
            Lumina:Destroy()
        end)
    end)

    UpdateGradients()
    return self
end

function Lumina:Notify(Options)
    local targetWindow = self.ToastContainer and self or Lumina.Windows[1]
    if not targetWindow or not targetWindow.ToastContainer then return end

    local TitleStr = Options.Title or "Notification"
    local ContentStr = Options.Content or ""
    local Duration = Options.Duration or 4
    local IconStr = Options.Icon or "lucide-bell"
    
    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(1, 0, 0, 80)
    Toast.BackgroundTransparency = 1
    Register(Toast, "Topbar", "BackgroundColor3")
    Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 8)
    Toast.Parent = targetWindow.ToastContainer
    
    local Stroke = Instance.new("UIStroke", Toast)
    Stroke.Transparency = 1
    Register(Stroke, "Stroke", "Color")
    
    local ToastScale = Instance.new("UIScale", Toast)
    ToastScale.Scale = 0.8
    
    local TopBar = Instance.new("Frame", Toast)
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundTransparency = 1
    
    local Icon = Instance.new("ImageLabel", TopBar)
    Icon.Size = UDim2.new(0, 16, 0, 16)
    Icon.Position = UDim2.new(0, 12, 0, 10)
    Icon.BackgroundTransparency = 1
    ApplyIcon(Icon, IconStr)
    Register(Icon, "Accent", "ImageColor3")
    
    local TitleLabel = Instance.new("TextLabel", TopBar)
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 32, 0, 3) 
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = TitleStr
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextTransparency = 1
    Register(TitleLabel, "Text", "TextColor3")

    local ProgressBg = Instance.new("Frame", Toast)
    ProgressBg.Size = UDim2.new(1, 0, 0, 2)
    ProgressBg.Position = UDim2.new(0, 0, 1, -2)
    ProgressBg.BackgroundTransparency = 1
    
    local ProgressFill = Instance.new("Frame", ProgressBg)
    ProgressFill.Size = UDim2.new(1, 0, 1, 0)
    ProgressFill.BorderSizePixel = 0
    Register(ProgressFill, "Accent", "BackgroundColor3")

    local ContentLabel = Instance.new("TextLabel", Toast)
    ContentLabel.Size = UDim2.new(1, -24, 1, -38)
    ContentLabel.Position = UDim2.new(0, 12, 0, 32)
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Text = ContentStr
    ContentLabel.Font = Enum.Font.GothamMedium
    ContentLabel.TextSize = 12
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
    ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
    ContentLabel.TextWrapped = true
    ContentLabel.TextTransparency = 1
    Register(ContentLabel, "SecondaryText", "TextColor3")
    
    -- Animation IN
    CreateTween(Toast, {BackgroundTransparency = 0.05}, 0.3)
    CreateTween(Stroke, {Transparency = 0.5}, 0.3)
    CreateTween(Icon, {ImageTransparency = 0}, 0.3)
    CreateTween(TitleLabel, {TextTransparency = 0}, 0.3)
    CreateTween(ContentLabel, {TextTransparency = 0}, 0.3)
    CreateTween(ToastScale, {Scale = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Timer Anim
    CreateTween(ProgressFill, {Size = UDim2.new(0, 0, 1, 0)}, Duration, Enum.EasingStyle.Linear)
    
    task.delay(Duration, function()
        CreateTween(Toast, {BackgroundTransparency = 1}, 0.4)
        CreateTween(Stroke, {Transparency = 1}, 0.4)
        CreateTween(Icon, {ImageTransparency = 1}, 0.4)
        CreateTween(TitleLabel, {TextTransparency = 1}, 0.4)
        CreateTween(ContentLabel, {TextTransparency = 1}, 0.4)
        CreateTween(ProgressFill, {BackgroundTransparency = 1}, 0.4)
        CreateTween(ToastScale, {Scale = 0.8}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.4)
        Toast:Destroy()
    end)
end

function Lumina:Destroy()
    if self == Lumina then
        for _, win in ipairs(Lumina.Windows) do
            win:Destroy()
        end
        Lumina.Windows = {}
        return
    end

    if self.Toggles then
        for _, toggle in ipairs(self.Toggles) do
            if toggle.Get ~= nil and toggle:Get() == true then
                pcall(function() toggle:Set(false) end)
            end
        end
    end

    if self.Connections then
        for _, conn in ipairs(self.Connections) do 
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end 
        end
    end
    if self.Gui then self.Gui:Destroy() end
end

    -- [[ COMPONENT BUILDER ]]
local function RenderComponentBase(TargetParent, Height, InfoText, TitleText)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -14, 0, Height)
    Register(Frame, "Topbar")
    Frame.Parent = TargetParent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    local BindInfo = nil
    if type(InfoText) == "string" and InfoText ~= "" then
        BindInfo = function(Element)
            Element.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    Lumina:Notify({
                        Title = TitleText and (TitleText .. " Info") or "Information",
                        Content = InfoText,
                        Icon = "lucide-info",
                        Duration = 6
                    })
                end
            end)
        end
        BindInfo(Frame)
    end
    
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Thickness = 1.2
    Stroke.Transparency = 0.6
    Register(Stroke, "Stroke", "Color")

    return Frame, Stroke, BindInfo
end

function Lumina:CreateTab(Name, IconName, IsHidden)
    local Window = self
    local Tab = { LayoutOrder = 0 }
    
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -16, 0, 35)
    TabBtn.LayoutOrder = #Window.Tabs
    Register(TabBtn, "Accent", "BackgroundColor3")
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = Name
    Register(TabBtn, "SecondaryText", "TextColor3")
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 14
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Window.TabList
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    
        local TabIcon = Instance.new("ImageLabel", TabBtn)
        TabIcon.Name = "Icon"
        TabIcon.Size = UDim2.new(0, 16, 0, 16)
        TabIcon.Position = UDim2.new(0, -24, 0.5, -8) -- Anchored absolutely away from padding
        TabIcon.BackgroundTransparency = 1
        ApplyIcon(TabIcon, IconName)
        if not IconName then TabIcon.Visible = false end
        Register(TabIcon, "SecondaryText", "ImageColor3")

    local TabPad = Instance.new("UIPadding", TabBtn)
    TabPad.PaddingLeft = UDim.new(0, IconName and 40 or 16)

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = true -- Compute layouts automatically!
    TabFrame.ScrollBarThickness = 2
    TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    Register(TabFrame, "Accent", "ScrollBarImageColor3")
    TabFrame.Parent = Window.Container
    
    local List = Instance.new("UIListLayout", TabFrame)
    List.Padding = UDim.new(0, 8)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local FramePad = Instance.new("UIPadding", TabFrame)
    FramePad.PaddingTop = UDim.new(0, 4)
    FramePad.PaddingBottom = UDim.new(0, 4)
    FramePad.PaddingLeft = UDim.new(0, 4)
    FramePad.PaddingRight = UDim.new(0, 4)

    if not Window.SelectTab then
        Window.ActiveTab = nil
        function Window:SelectTab(CurrentTab)
            if Window.ActiveTab == CurrentTab then return end
            
            local isMovingDown = true
            if Window.ActiveTab then
                isMovingDown = CurrentTab.Btn.LayoutOrder > Window.ActiveTab.Btn.LayoutOrder
            end
            
            local outOffset = isMovingDown and -40 or 40
            local inOffset = isMovingDown and 40 or -40
            
            local activeTab = Window.ActiveTab
            Window.ActiveTab = CurrentTab
            
            for _, t in pairs(Window.Tabs) do
                if t == CurrentTab then continue end
                if t.Frame.Visible then
                    CreateTween(t.Btn, {BackgroundTransparency = 1}, 0.3)
                    if t.Icon then Register(t.Icon, "SecondaryText", "ImageColor3") end
                    Register(t.Btn, "SecondaryText", "TextColor3")
                    
                    local frame = t.Frame
                    CreateTween(frame, {Position = UDim2.new(0, 0, 0, outOffset)}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                    task.delay(0.15, function()
                        if Window.ActiveTab ~= t then frame.Visible = false end
                    end)
                end
            end
            
            if activeTab then
                task.wait(0.15)
            end
            
            if Window.ActiveTab == CurrentTab then
                CurrentTab.Frame.Visible = true
                CurrentTab.Frame.Position = UDim2.new(0, 0, 0, inOffset)
                CreateTween(CurrentTab.Frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                
                CreateTween(CurrentTab.Btn, {BackgroundTransparency = 0.9}, 0.3)
                if CurrentTab.Icon then Register(CurrentTab.Icon, "Accent", "ImageColor3") end
                Register(CurrentTab.Btn, "Text", "TextColor3")
            end
        end
    end

    TabBtn.MouseButton1Click:Connect(function()
        Window:SelectTab(Tab)
    end)

    if #Window.Tabs == 0 and not IsHidden then 
        TabBtn.BackgroundTransparency = 0.9
        if TabIcon then Register(TabIcon, "Accent", "ImageColor3") end
        Register(TabBtn, "Text", "TextColor3")
        Window.ActiveTab = Tab
    end

    Tab.Frame = TabFrame
    Tab.Btn = TabBtn
    Tab.Icon = TabIcon
    Tab.IsHidden = IsHidden
    if IsHidden then TabBtn.Visible = false end
    table.insert(Window.Tabs, Tab)

    ApplyBounce(TabBtn)

    -- [[ TAB METHODS (Including Sections and Labels) ]]
    function Tab:CreateLabel(Text, IconName)
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        
        local LabelFrame = Instance.new("Frame")
        LabelFrame.Size = UDim2.new(1, -14, 0, 30)
        LabelFrame.BackgroundTransparency = 1
        LabelFrame.Parent = ParentFrame

        local textOffset = 10
        if IconName then
            local Icon = Instance.new("ImageLabel", LabelFrame)
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Position = UDim2.new(0, textOffset, 0.5, -8)
            Icon.BackgroundTransparency = 1
            ApplyIcon(Icon, IconName)
            Register(Icon, "Text", "ImageColor3")
            textOffset = textOffset + 24
        end

        local Label = Instance.new("TextLabel", LabelFrame)
        Label.Size = UDim2.new(1, -(textOffset + 10), 1, 0)
        Label.Position = UDim2.new(0, textOffset, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Text
        Register(Label, "Text", "TextColor3") 
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextWrapped = true

        local LabelComponent = {}
        function LabelComponent:Set(NewText)
            Label.Text = NewText
        end
        return LabelComponent
    end

    function Tab:CreateSection(SectionName, Collapsible, IconName)
        if type(Collapsible) == "string" then IconName = Collapsible; Collapsible = false; end
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local Section = {LayoutOrder = 0}
        local IsCollapsed = false
        
        local SecFrame = Instance.new("Frame")
        SecFrame.Size = UDim2.new(1, -14, 0, 40)
        SecFrame.BackgroundTransparency = 1
        SecFrame.ClipsDescendants = false
        SecFrame.Parent = TabFrame

        local textOffset = 2
        if IconName then
            local Icon = Instance.new("ImageLabel", SecFrame)
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Position = UDim2.new(0, textOffset, 0, 7)
            Icon.BackgroundTransparency = 1
            ApplyIcon(Icon, IconName)
            Register(Icon, "Text", "ImageColor3")
            textOffset = textOffset + 22
        end

        local SecHeader = Instance.new("TextLabel", SecFrame)
        SecHeader.Size = UDim2.new(1, -(textOffset + 8), 0, 20)
        SecHeader.Position = UDim2.new(0, textOffset, 0, 5)
        SecHeader.BackgroundTransparency = 1
        SecHeader.Text = SectionName
        Register(SecHeader, "Accent", "TextColor3")
        SecHeader.Font = Enum.Font.GothamBold
        SecHeader.TextSize = 13
        SecHeader.TextXAlignment = Enum.TextXAlignment.Left

        local SecContainer = Instance.new("Frame", SecFrame)
        SecContainer.Size = UDim2.new(1, 0, 1, -30)
        SecContainer.Position = UDim2.new(0, 0, 0, 30)
        SecContainer.BackgroundTransparency = 0.4
        Register(SecContainer, "MainSide", "BackgroundColor3")
        SecContainer.ClipsDescendants = true
        
        local SecStroke = Instance.new("UIStroke", SecContainer)
        SecStroke.Thickness = 1.5
        SecStroke.Transparency = 0.1
        Register(SecStroke, "Stroke", "Color")
        Instance.new("UICorner", SecContainer).CornerRadius = UDim.new(0, 8)

        local SecLayout = Instance.new("UIListLayout", SecContainer)
        SecLayout.Padding = UDim.new(0, 6)
        SecLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        SecLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local SecPad = Instance.new("UIPadding", SecContainer)
        SecPad.PaddingTop = UDim.new(0, 8)
        SecPad.PaddingBottom = UDim.new(0, 8)

        local function UpdateSectionSize()
            if IsCollapsed then return end
            CreateTween(SecFrame, {Size = UDim2.new(1, -14, 0, SecLayout.AbsoluteContentSize.Y + 46)}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end
        SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionSize)

        if Collapsible then
            local CollapseBtn = Instance.new("TextButton", SecFrame)
            CollapseBtn.Size = UDim2.new(1, 0, 0, 30)
            CollapseBtn.Position = UDim2.new(0, 0, 0, 0)
            CollapseBtn.BackgroundTransparency = 1
            CollapseBtn.Text = ""

            local CollapseIcon = Instance.new("TextLabel", CollapseBtn)
            CollapseIcon.Size = UDim2.new(0, 20, 0, 20)
            CollapseIcon.Position = UDim2.new(1, -25, 0, 5)
            CollapseIcon.BackgroundTransparency = 1
            CollapseIcon.Text = "-"
            Register(CollapseIcon, "Accent", "TextColor3")
            CollapseIcon.Font = Enum.Font.GothamBold
            CollapseIcon.TextSize = 18

            CollapseBtn.MouseButton1Click:Connect(function()
                IsCollapsed = not IsCollapsed
                if IsCollapsed then
                    CreateTween(SecStroke, {Transparency = 1}, 0.2)
                    CreateTween(SecContainer, {BackgroundTransparency = 1}, 0.2)
                    CreateTween(SecFrame, {Size = UDim2.new(1, -14, 0, 30)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    CollapseIcon.Text = "+"
                    task.delay(0.4, function()
                        if IsCollapsed then SecContainer.Visible = false end
                    end)
                else
                    SecContainer.Visible = true
                    CreateTween(SecStroke, {Transparency = 0.1}, 0.4)
                    CreateTween(SecContainer, {BackgroundTransparency = 0.4}, 0.4)
                    CollapseIcon.Text = "-"
                    UpdateSectionSize()
                end
            end)
        end
        
        -- Initial evaluation 
        task.defer(function()
            SecFrame.Size = UDim2.new(1, -14, 0, SecLayout.AbsoluteContentSize.Y + 46)
        end)

        -- Mirror tab methods to append to the Section's container instead
        local ProxyTab = setmetatable({}, {__index = Tab})
        ProxyTab.TargetParent = SecContainer
        return ProxyTab
    end

    function Tab:CreateButton(Text, Callback, InfoText)
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        local ButtonFrame, Stroke, BindInfo = RenderComponentBase(ParentFrame, 40, InfoText, Text)
        
        local Button = Instance.new("TextButton", ButtonFrame)
        if BindInfo then BindInfo(Button) end
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = "  " .. Text
        Register(Button, "Text", "TextColor3") 
        Button.Font = Enum.Font.GothamMedium
        Button.TextSize = 14
        Button.TextXAlignment = Enum.TextXAlignment.Left

        Button.MouseEnter:Connect(function()
            CreateTween(Stroke, {Transparency = 0.2, Color = Theme.Accent}, 0.3)
        end)
        Button.MouseLeave:Connect(function()
            CreateTween(Stroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.3)
        end)
        
        ApplyBounce(Button, ButtonFrame)
        Button.MouseButton1Click:Connect(Callback)
        
        local ButtonComponent = {}
        function ButtonComponent:Set(NewText)
            Button.Text = "  " .. NewText
        end
        return ButtonComponent
    end

    function Tab:CreateToggle(Text, Default, Callback, NoSave, InfoText, Flag)
        local FlagStr = Flag or Text
        if type(NoSave) == "string" then InfoText = NoSave; NoSave = false; end
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        
        -- Load Config
        if ConfigData[FlagStr] ~= nil and not NoSave then Default = ConfigData[FlagStr] end
        local Toggled = Default or false
        if not NoSave and ConfigData[FlagStr] == nil then ConfigData[FlagStr] = Toggled end


        local ToggleFrame, Stroke, BindInfo = RenderComponentBase(ParentFrame, 44, InfoText, Text)

        local Label = Instance.new("TextLabel", ToggleFrame)
        Label.Text = "  " .. Text
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.BackgroundTransparency = 1
        Register(Label, "Text")
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local SwitchBg = Instance.new("Frame", ToggleFrame)
        SwitchBg.Size = UDim2.new(0, 44, 0, 22)
        SwitchBg.Position = UDim2.new(1, -54, 0.5, -11)
        SwitchBg.BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(50, 50, 55)
        Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

        local Dot = Instance.new("Frame", SwitchBg)
        Dot.Size = UDim2.new(0, 18, 0, 18)
        Dot.Position = Toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        Dot.BackgroundColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
        local DotShadow = Instance.new("UIStroke", Dot)
        DotShadow.Transparency = 0.5

        local Clicker = Instance.new("TextButton", ToggleFrame)
        if BindInfo then BindInfo(Clicker) end
        Clicker.Size = UDim2.new(1, 0, 1, 0)
        Clicker.BackgroundTransparency = 1
        Clicker.Text = ""

        if not NoHover then
            Clicker.MouseEnter:Connect(function() CreateTween(Stroke, {Transparency = 0.2, Color = Theme.Accent}, 0.3) end)
            Clicker.MouseLeave:Connect(function() CreateTween(Stroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.3) end)
        end
        ApplyBounce(Clicker, ToggleFrame)

        local function FireToggle(state)
            Toggled = state
            CreateTween(SwitchBg, {BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(50, 50, 55)}, 0.4)
            CreateTween(Dot, {Position = Toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            if not NoSave then ConfigData[FlagStr] = Toggled; SaveConfig() end
            pcall(Callback, Toggled)
        end

        Clicker.MouseButton1Click:Connect(function() FireToggle(not Toggled) end)

        local function Refresh()
            local cfg = ConfigData[FlagStr]
            if not NoSave then
                local val = (cfg ~= nil) and cfg or (Default or false)
                if val ~= Toggled then
                    Toggled = val
                    CreateTween(SwitchBg, {BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(50, 50, 55)}, 0.4)
                    CreateTween(Dot, {Position = Toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                end
                pcall(Callback, Toggled)
            end
        end
        table.insert(Lumina._Configurables, Refresh)

        if Toggled then pcall(Callback, Toggled) end -- Init callback
        
        local ToggleComponent = {}
        function ToggleComponent:Set(state)
            if state ~= Toggled then
                FireToggle(state)
            end
        end
        function ToggleComponent:Get()
            return Toggled
        end
        if not Window.Toggles then Window.Toggles = {} end
        table.insert(Window.Toggles, ToggleComponent)
        return ToggleComponent
    end

    function Tab:CreateSlider(Text, Min, Max, Default, Callback, NoSave, InfoText, Flag)
        local FlagStr = Flag or Text
        if type(NoSave) == "string" then InfoText = NoSave; NoSave = false; end
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        if ConfigData[FlagStr] ~= nil and not NoSave then Default = ConfigData[FlagStr] end
        local Value = Default or Min
        if not NoSave and ConfigData[FlagStr] == nil then ConfigData[FlagStr] = Value end

        local SliderFrame, Stroke = RenderComponentBase(ParentFrame, 54, InfoText, Text)

        local Label = Instance.new("TextLabel", SliderFrame)
        Label.Text = "  " .. Text
        Label.Size = UDim2.new(1, -40, 0, 28)
        Label.BackgroundTransparency = 1
        Register(Label, "Text")
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local ValBtn = Instance.new("TextBox", SliderFrame)
        ValBtn.Text = tostring(Value)
        ValBtn.Size = UDim2.new(0, 40, 0, 20)
        ValBtn.Position = UDim2.new(1, -50, 0, 4)
        Register(ValBtn, "Background", "BackgroundColor3")
        Register(ValBtn, "Text", "TextColor3")
        ValBtn.Font = Enum.Font.GothamMedium
        ValBtn.TextSize = 12
        Instance.new("UICorner", ValBtn).CornerRadius = UDim.new(0, 6)

        local BarBg = Instance.new("Frame", SliderFrame)
        BarBg.Size = UDim2.new(1, -20, 0, 8)
        BarBg.Position = UDim2.new(0, 10, 1, -16)
        BarBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame", BarBg)
        Fill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
        Register(Fill, "Accent")
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
        
        local Knob = Instance.new("Frame", Fill)
        Knob.Size = UDim2.new(0, 14, 0, 14)
        Knob.Position = UDim2.new(1, -7, 0.5, -7)
        Knob.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)
        
        SliderFrame.MouseEnter:Connect(function() CreateTween(Stroke, {Transparency = 0.2, Color = Theme.Accent}, 0.3) end)
        SliderFrame.MouseLeave:Connect(function() CreateTween(Stroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.3) end)
        ApplyBounce(SliderFrame)

        local function Update(pos)
            local pct = math.clamp((pos.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
            Value = math.floor(Min + (Max - Min) * pct)
            CreateTween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1)
            ValBtn.Text = tostring(Value)
            if not NoSave then ConfigData[FlagStr] = Value; SaveConfig() end
            pcall(Callback, Value)
        end

        local Dragging = false
        SliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true; Update(UserInputService:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset())
            end
        end)
        local c1 = UserInputService.InputChanged:Connect(function(input)
            if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                Update(UserInputService:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset())
            end
        end)
        local c2 = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
        end)
        table.insert(Window.Connections, c1)
        table.insert(Window.Connections, c2)

        local function Refresh()
            local cfg = ConfigData[FlagStr]
            if not NoSave then
                local val = (cfg ~= nil) and cfg or (Default or Min)
                if val ~= Value then
                    Value = val
                    local pct = math.clamp((Value - Min) / (Max - Min), 0, 1)
                    CreateTween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1)
                    ValBtn.Text = tostring(Value)
                end
                pcall(Callback, Value)
            end
        end
        table.insert(Lumina._Configurables, Refresh)
        
        pcall(Callback, Value)
        
        local SliderComponent = {}
        function SliderComponent:Set(pos)
            pos = math.clamp(pos, Min, Max)
            Value = pos
            local pct = math.clamp((Value - Min) / (Max - Min), 0, 1)
            CreateTween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1)
            ValBtn.Text = tostring(Value)
            if not NoSave then ConfigData[FlagStr] = Value; SaveConfig() end
            pcall(Callback, Value)
        end
        return SliderComponent
    end

    function Tab:CreateInput(Text, Placeholder, Callback, NoSave, InfoText, Flag)
        local FlagStr = Flag or Text
        if type(NoSave) == "string" then InfoText = NoSave; NoSave = false; end
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        local InputFrame, Stroke = RenderComponentBase(ParentFrame, 44, InfoText, Text)

        local Label = Instance.new("TextLabel", InputFrame)
        Label.Text = "  " .. Text
        Label.Size = UDim2.new(0.4, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Register(Label, "Text")
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local TBoxCover = Instance.new("Frame", InputFrame)
        TBoxCover.Size = UDim2.new(0.55, -10, 0, 30)
        TBoxCover.Position = UDim2.new(0.45, 0, 0.5, -15)
        Register(TBoxCover, "Background")
        Instance.new("UICorner", TBoxCover).CornerRadius = UDim.new(0, 6)
        
        local TbxStroke = Instance.new("UIStroke", TBoxCover)
        TbxStroke.Transparency = 0.8
        Register(TbxStroke, "Stroke", "Color")

        local TBox = Instance.new("TextBox", TBoxCover)
        TBox.Size = UDim2.new(1, -10, 1, 0)
        TBox.Position = UDim2.new(0, 5, 0, 0)
        TBox.BackgroundTransparency = 1
        TBox.PlaceholderText = Placeholder or "Type here..."
        TBox.Text = ""
        Register(TBox, "Stroke", "PlaceholderColor3")
        Register(TBox, "Text", "TextColor3")
        TBox.Font = Enum.Font.Gotham
        TBox.TextSize = 13
        TBox.TextXAlignment = Enum.TextXAlignment.Left
        TBox.ClearTextOnFocus = false

        InputFrame.MouseEnter:Connect(function() CreateTween(Stroke, {Transparency = 0.2, Color = Theme.Accent}, 0.3) end)
        InputFrame.MouseLeave:Connect(function() CreateTween(Stroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.3) end)

        TBox.Focused:Connect(function()
            CreateTween(TbxStroke, {Transparency = 0.2, Color = Theme.Accent}, 0.3)
        end)

        TBox.FocusLost:Connect(function(enterPressed)
            CreateTween(TbxStroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.3)
            if not NoSave then ConfigData[FlagStr] = TBox.Text; SaveConfig() end
            pcall(Callback, TBox.Text, enterPressed)
        end)

        local function Refresh()
            local cfg = ConfigData[FlagStr]
            if not NoSave then
                local val = cfg ~= nil and tostring(cfg) or ""
                if val ~= TBox.Text then
                    TBox.Text = val
                end
                pcall(Callback, TBox.Text, true)
            end
        end
        table.insert(Lumina._Configurables, Refresh)
        
        if not NoSave and ConfigData[FlagStr] == nil then ConfigData[FlagStr] = TBox.Text end
        if not NoSave and ConfigData[FlagStr] ~= nil then 
            TBox.Text = tostring(ConfigData[FlagStr])
            pcall(Callback, TBox.Text, true) 
        end
        
        local InputComponent = {}
        function InputComponent:Set(text)
            TBox.Text = tostring(text)
            if not NoSave then ConfigData[FlagStr] = TBox.Text; SaveConfig() end
            pcall(Callback, TBox.Text, true)
        end
        return InputComponent
    end

    function Tab:CreateKeybind(Text, Default, Callback, NoSave, InfoText, Flag)
        local FlagStr = Flag or Text
        if type(NoSave) == "string" then InfoText = NoSave; NoSave = false; end
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        if ConfigData[FlagStr] ~= nil and not NoSave then Default = Enum.KeyCode[ConfigData[FlagStr]] end
        local Key = Default
        if not NoSave and ConfigData[FlagStr] == nil then ConfigData[FlagStr] = Key and Key.Name or "None" end

        local BindFrame, Stroke = RenderComponentBase(ParentFrame, 44, InfoText, Text)

        local Label = Instance.new("TextLabel", BindFrame)
        Label.Text = "  " .. Text
        Label.Size = UDim2.new(1, -120, 1, 0)
        Label.BackgroundTransparency = 1
        Register(Label, "Text")
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local BindBtn = Instance.new("TextButton", BindFrame)
        BindBtn.Size = UDim2.new(0, 100, 0, 30)
        BindBtn.Position = UDim2.new(1, -110, 0.5, -15)
        Register(BindBtn, "Background", "BackgroundColor3")
        BindBtn.AutoButtonColor = false
        BindBtn.Text = Key and Key.Name or "None"
        Register(BindBtn, "Accent", "TextColor3")
        BindBtn.Font = Enum.Font.GothamBold
        BindBtn.TextSize = 13
        Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)
        
        local BStroke = Instance.new("UIStroke", BindBtn)
        BStroke.Transparency = 0.8
        Register(BStroke, "Stroke", "Color")

        BindFrame.MouseEnter:Connect(function() CreateTween(Stroke, {Transparency = 0.2, Color = Theme.Accent}, 0.3) end)
        BindFrame.MouseLeave:Connect(function() CreateTween(Stroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.3) end)
        ApplyBounce(BindBtn)

        BindBtn.MouseButton1Click:Connect(function()
            BindBtn.Text = "Listening..."
            CreateTween(BStroke, {Transparency = 0.2, Color = Theme.Accent}, 0.2)

            local conn
            conn = UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                    Key = input.KeyCode
                    BindBtn.Text = Key.Name
                    if not NoSave then ConfigData[FlagStr] = Key.Name; SaveConfig() end
                    CreateTween(BStroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.2)
                    pcall(Callback, Key)
                    conn:Disconnect()
                end
            end)
        end)
        
        -- Global Listener for Keybind
        local gConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and Key and input.KeyCode == Key then pcall(Callback, Key) end
        end)
        table.insert(Window.Connections, gConn)

        local function Refresh()
            local cfg = ConfigData[FlagStr]
            if not NoSave then
                local val = (cfg and Enum.KeyCode[cfg]) and Enum.KeyCode[cfg] or (Default or Enum.KeyCode.Unknown)
                if val ~= Key then
                    Key = val
                    BindBtn.Text = Key.Name
                end
                pcall(Callback, Key)
            end
        end
        table.insert(Lumina._Configurables, Refresh)
        if ConfigData[FlagStr] ~= nil then pcall(Callback, Enum.KeyCode[ConfigData[FlagStr]] or Key) end
        
        local KeybindComponent = {}
        function KeybindComponent:Set(newKey)
            local k
            if typeof(newKey) == "string" and Enum.KeyCode[newKey] then k = Enum.KeyCode[newKey]
            elseif typeof(newKey) == "EnumItem" then k = newKey end
            if k then
                Key = k
                BindBtn.Text = Key.Name
                if not NoSave then ConfigData[FlagStr] = Key.Name; SaveConfig() end
                pcall(Callback, Key)
            end
        end
        return KeybindComponent
    end

    function Tab:CreateDropdown(Text, Options, Callback, MultiSelect, NoSave, InfoText, Flag)
        local FlagStr = Flag or Text
        if type(MultiSelect) == "string" then InfoText = MultiSelect; MultiSelect = false; NoSave = false; elseif type(NoSave) == "string" then InfoText = NoSave; NoSave = false; end
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        local Dropped = false
        local SelectedValues = {}
        
        if ConfigData[FlagStr] ~= nil and not NoSave then
            if MultiSelect and type(ConfigData[FlagStr]) == "table" then
                SelectedValues = ConfigData[FlagStr]
            elseif not MultiSelect then
                -- Single select initialization implicitly handled in RefreshOptions
            end
        end
        
        if not NoSave and ConfigData[FlagStr] == nil then 
            ConfigData[FlagStr] = MultiSelect and SelectedValues or (Options and Options[1] or "") 
        end

        local DropdownFrame, Stroke, BindInfo = RenderComponentBase(ParentFrame, 44, InfoText, Text)
        DropdownFrame.ClipsDescendants = true

        local Label = Instance.new("TextLabel", DropdownFrame)
        Label.Text = "  " .. Text .. (ConfigData[FlagStr] and not MultiSelect and " (" .. ConfigData[FlagStr] .. ")" or "")
        if MultiSelect and SelectedValues and #SelectedValues > 0 then
            Label.Text = "  " .. Text .. " (" .. #SelectedValues .. " selected)"
        end
        Label.Size = UDim2.new(1, -40, 0, 44)
        Label.BackgroundTransparency = 1
        Register(Label, "Text")
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Icon = Instance.new("TextLabel", DropdownFrame)
        Icon.Size = UDim2.new(0, 40, 0, 44)
        Icon.Position = UDim2.new(1, -40, 0, 0)
        Icon.BackgroundTransparency = 1
        Icon.Text = "+"
        Register(Icon, "Accent")
        Icon.Font = Enum.Font.GothamBold
        Icon.TextSize = 16

        local OptionContainer = Instance.new("Frame", DropdownFrame)
        OptionContainer.Size = UDim2.new(1, -12, 0, #Options * 32)
        OptionContainer.Position = UDim2.new(0, 6, 0, 44)
        OptionContainer.BackgroundTransparency = 1

        local OptList = Instance.new("UIListLayout", OptionContainer)
        OptList.Padding = UDim.new(0, 4)

        local DropdownComponent = {}

        function DropdownComponent:RefreshOptions(newOptions)
            Options = newOptions or Options
            for _, child in ipairs(OptionContainer:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            OptionContainer.Size = UDim2.new(1, -12, 0, #Options * 32)
            if Dropped then
                DropdownFrame.Size = UDim2.new(1, -14, 0, 44 + (#Options * 32) + 6)
            end

            for _, opt in ipairs(Options) do
                local OptBtn = Instance.new("TextButton", OptionContainer)
                OptBtn.Size = UDim2.new(1, 0, 0, 28)
                OptBtn.BackgroundTransparency = 1
                
                local isSelected = MultiSelect and table.find(SelectedValues, opt) ~= nil
                OptBtn.Text = "  " .. opt .. (isSelected and " (Selected)" or "")
                Register(OptBtn, isSelected and "Accent" or "SecondaryText", "TextColor3") 
                OptBtn.Font = Enum.Font.GothamMedium
                OptBtn.TextSize = 13
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left

                OptBtn.MouseEnter:Connect(function() CreateTween(OptBtn, {TextColor3 = Theme.Accent}, 0.2) end)
                OptBtn.MouseLeave:Connect(function() 
                    local isSel = MultiSelect and table.find(SelectedValues, opt) ~= nil
                    CreateTween(OptBtn, {TextColor3 = isSel and Theme.Accent or Theme.SecondaryText}, 0.2) 
                end)

                OptBtn.MouseButton1Click:Connect(function()
                    if MultiSelect then
                        local idx = table.find(SelectedValues, opt)
                        if idx then
                            table.remove(SelectedValues, idx)
                            OptBtn.Text = "  " .. opt
                        else
                            table.insert(SelectedValues, opt)
                            OptBtn.Text = "  " .. opt .. " (Selected)"
                        end
                        Label.Text = "  " .. Text .. (#SelectedValues > 0 and " (" .. #SelectedValues .. " selected)" or "")
                        CreateTween(OptBtn, {TextColor3 = table.find(SelectedValues, opt) and Theme.Accent or Theme.SecondaryText}, 0.2)
                        if not NoSave then ConfigData[FlagStr] = SelectedValues; SaveConfig() end
                        pcall(Callback, SelectedValues)
                    else
                        Label.Text = "  " .. Text .. " (" .. opt .. ")"
                        Dropped = false
                        Icon.Text = "+"
                        CreateTween(DropdownFrame, {Size = UDim2.new(1, -14, 0, 44)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                        if not NoSave then ConfigData[FlagStr] = opt; SaveConfig() end
                        pcall(Callback, opt)
                    end
                end)
            end
        end

        function DropdownComponent:Set(value)
            if MultiSelect then
                SelectedValues = value
                Label.Text = "  " .. Text .. (#SelectedValues > 0 and " (" .. #SelectedValues .. " selected)" or "")
                for _, child in pairs(OptionContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        local optName = child.Text:match("^%s*(.-)%s*$"):gsub(" %(Selected%)$", "")
                        if table.find(SelectedValues, optName) then
                            child.Text = "  " .. optName .. " (Selected)"
                            Register(child, "Accent", "TextColor3") 
                        else
                            child.Text = "  " .. optName
                            Register(child, "SecondaryText", "TextColor3") 
                        end
                    end
                end
                if not NoSave then ConfigData[FlagStr] = SelectedValues; SaveConfig() end
                pcall(Callback, SelectedValues)
            else
                Label.Text = "  " .. Text .. " (" .. value .. ")"
                if not NoSave then ConfigData[FlagStr] = value; SaveConfig() end
                pcall(Callback, value)
            end
        end

        DropdownComponent:RefreshOptions(Options)

        local Clicker = Instance.new("TextButton", DropdownFrame)
        if BindInfo then BindInfo(Clicker) end
        Clicker.Size = UDim2.new(1, 0, 0, 44)
        Clicker.BackgroundTransparency = 1
        Clicker.Text = ""

        Clicker.MouseButton1Click:Connect(function()
            Dropped = not Dropped
            Icon.Text = Dropped and "-" or "+"
            local targetHeight = Dropped and (44 + (#Options * 32) + 6) or 44
            CreateTween(DropdownFrame, {Size = UDim2.new(1, -14, 0, targetHeight)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end)
        
        ApplyBounce(Clicker, DropdownFrame)
        Clicker.MouseEnter:Connect(function() CreateTween(Stroke, {Transparency = 0.2, Color = Theme.Accent}, 0.3) end)
        Clicker.MouseLeave:Connect(function() CreateTween(Stroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.3) end)

        local function Refresh()
            if NoSave then return end
            local cfg = ConfigData[FlagStr]
            if MultiSelect then
                local val = (cfg ~= nil and type(cfg) == "table") and cfg or {}
                SelectedValues = val
                Label.Text = "  " .. Text .. (#SelectedValues > 0 and " (" .. #SelectedValues .. " selected)" or "")
                for _, child in pairs(OptionContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        local optName = child.Text:match("^%s*(.-)%s*$"):gsub(" %(Selected%)$", "")
                        if table.find(SelectedValues, optName) then
                            child.Text = "  " .. optName .. " (Selected)"
                            Register(child, "Accent", "TextColor3") 
                        else
                            child.Text = "  " .. optName
                            Register(child, "SecondaryText", "TextColor3") 
                        end
                    end
                end
                pcall(Callback, SelectedValues)
            else
                local val = (cfg ~= nil and table.find(Options, cfg)) and cfg or Options[1]
                if val then
                    Label.Text = "  " .. Text .. " (" .. val .. ")"
                    pcall(Callback, val)
                end
            end
        end
        table.insert(Lumina._Configurables, Refresh)

        if ConfigData[FlagStr] ~= nil then 
            if MultiSelect then pcall(Callback, SelectedValues) else pcall(Callback, ConfigData[FlagStr]) end
        end

        return DropdownComponent
    end

    function Tab:CreateColorPicker(Text, Category, Default, Callback, NoSave, InfoText, Flag)
        local FlagStr = Flag or Text
        if type(NoSave) == "string" then InfoText = NoSave; NoSave = false; end
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        local PickerActive = false
        
        local isCustomTheme = (ConfigData["Theme Presets"] == "Custom" or ConfigData["Theme Presets"] == nil)

        -- Load custom config and update the global Custom preset cache
        if ConfigData[FlagStr] ~= nil and type(ConfigData[FlagStr]) == "table" and not NoSave then
            local ccfg = ConfigData[FlagStr]
            if ccfg.r and ccfg.g and ccfg.b then
                local savedCol = Color3.new(ccfg.r, ccfg.g, ccfg.b)
                Presets["Custom"][Category] = savedCol
                if isCustomTheme then
                    Default = savedCol
                end
            end
        end

        local InitialColor = Default
        if not isCustomTheme then
            InitialColor = Theme[Category] or InitialColor
        end
        InitialColor = (typeof(InitialColor) == "Color3" and InitialColor) or Theme[Category] or Color3.new(1, 1, 1)

        local h, s, v = Color3.toHSV(InitialColor)
        
        local ColorFrame, Stroke = RenderComponentBase(ParentFrame, 44)
        ColorFrame.ClipsDescendants = true

        local Label = Instance.new("TextLabel", ColorFrame)
        Label.Text = "  " .. Text
        Label.Size = UDim2.new(1, -70, 0, 44)
        Label.BackgroundTransparency = 1
        Register(Label, "Text")
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextSize = 14

        local Display = Instance.new("TextButton", ColorFrame)
        Display.Size = UDim2.new(0, 36, 0, 20)
        Display.Position = UDim2.new(1, -46, 0, 12)
        Display.BackgroundColor3 = InitialColor
        Display.Text = ""
        Instance.new("UICorner", Display).CornerRadius = UDim.new(0, 6)
        
        local DisplayStroke = Instance.new("UIStroke", Display)
        DisplayStroke.Thickness = 1
        Register(DisplayStroke, "Stroke", "Color")

        local SatValSquare = Instance.new("ImageButton", ColorFrame)
        SatValSquare.Size = UDim2.new(1, -50, 0, 120)
        SatValSquare.Position = UDim2.new(0, 10, 0, 50)
        SatValSquare.Image = "rbxassetid://4155801252"
        SatValSquare.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        SatValSquare.Visible = false
        Instance.new("UICorner", SatValSquare).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", SatValSquare).Color = Color3.fromRGB(30, 30, 30)

        local Cursor = Instance.new("Frame", SatValSquare)
        Cursor.Size = UDim2.new(0, 8, 0, 8)
        Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
        Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
        Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
        Instance.new("UICorner", Cursor).CornerRadius = UDim.new(1, 0)
        Instance.new("UIStroke", Cursor).Color = Color3.new(0, 0, 0)

        local HueSlider = Instance.new("ImageButton", ColorFrame)
        HueSlider.Size = UDim2.new(0, 20, 0, 120)
        HueSlider.Position = UDim2.new(1, -30, 0, 50)
        HueSlider.Image = "rbxassetid://3595743326"
        HueSlider.Visible = false
        Instance.new("UICorner", HueSlider).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", HueSlider).Color = Color3.fromRGB(30,30,30)

        local HueGrad = Instance.new("UIGradient", HueSlider)
        HueGrad.Rotation = 90
        HueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.16, Color3.fromHSV(0.16, 1, 1)),
            ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.66, Color3.fromHSV(0.66, 1, 1)),
            ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
        })
        
        local HueCursor = Instance.new("Frame", HueSlider)
        HueCursor.Size = UDim2.new(1, 4, 0, 2)
        HueCursor.Position = UDim2.new(0.5, 0, h, 0)
        HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        HueCursor.BorderSizePixel = 0
        Instance.new("UIStroke", HueCursor).Color = Color3.new(0,0,0)

        local function UpdateColor()
            local NewCol = Color3.fromHSV(h, s, v)
            SatValSquare.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            Display.BackgroundColor3 = NewCol
            Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
            HueCursor.Position = UDim2.new(0.5, 0, h, 0)
            
            Presets["Custom"][Category] = NewCol

            if Lumina._ThemeDropdown then Lumina._ThemeDropdown:Set("Custom") end
            if not NoSave then ConfigData[FlagStr] = {r = NewCol.R, g = NewCol.G, b = NewCol.B}; SaveConfig() end
            if Category then UpdateTheme(Category, NewCol) end
            if Callback then pcall(Callback, NewCol) end
        end

        local function Refresh()
            if NoSave then return end
            local isCustom = (ConfigData["Theme Presets"] == "Custom" or ConfigData["Theme Presets"] == nil)
            local cfg = ConfigData[FlagStr]
            
            local NewCol = Default or Color3.new(1, 1, 1)
            if cfg and type(cfg) == "table" and cfg.r and cfg.g and cfg.b then
                NewCol = Color3.new(cfg.r, cfg.g, cfg.b)
            end
                
            if Category then Presets["Custom"][Category] = NewCol end
            
            if not isCustom then return end

            h, s, v = Color3.toHSV(NewCol)
            SatValSquare.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            Display.BackgroundColor3 = NewCol
            Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
            HueCursor.Position = UDim2.new(0.5, 0, h, 0)
            if Category then UpdateTheme(Category, NewCol) end
            if Callback then pcall(Callback, NewCol) end
        end
        table.insert(Lumina._Configurables, Refresh)
        
        table.insert(Lumina._ColorPickers, function()
            local newClr = Theme[Category]
            if newClr then
                h, s, v = Color3.toHSV(newClr)
                SatValSquare.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                Display.BackgroundColor3 = newClr
                Cursor.Position = UDim2.new(s, 0, 1 - v, 0)
                HueCursor.Position = UDim2.new(0.5, 0, h, 0)
            end
        end)

        if ConfigData[FlagStr] ~= nil then pcall(Refresh) end

        ApplyBounce(Display, ColorFrame)
        Display.MouseEnter:Connect(function() CreateTween(Stroke, {Transparency = 0.2, Color = Theme.Accent}, 0.3) end)
        Display.MouseLeave:Connect(function() CreateTween(Stroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.3) end)

        Display.MouseButton1Click:Connect(function()
            PickerActive = not PickerActive
            SatValSquare.Visible = PickerActive
            HueSlider.Visible = PickerActive
            CreateTween(ColorFrame, {Size = PickerActive and UDim2.new(1, -14, 0, 180) or UDim2.new(1, -14, 0, 44)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end)

        local function GetInput(obj)
            local mouse = UserInputService:GetMouseLocation()
            local relativePos = mouse - obj.AbsolutePosition - game:GetService("GuiService"):GetGuiInset()
            return math.clamp(relativePos.X / obj.AbsoluteSize.X, 0, 1), math.clamp(relativePos.Y / obj.AbsoluteSize.Y, 0, 1)
        end

        SatValSquare.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn, endConn
                conn = RunService.RenderStepped:Connect(function()
                    if not PickerActive then conn:Disconnect(); if endConn then endConn:Disconnect() end return end
                    local x, y = GetInput(SatValSquare)
                    s, v = x, 1 - y
                    UpdateColor()
                end)
                endConn = UserInputService.InputEnded:Connect(function(ended)
                    if ended.UserInputType == Enum.UserInputType.MouseButton1 then 
                        if conn then conn:Disconnect() end
                        if endConn then endConn:Disconnect() end
                    end
                end)
            end
        end)

        HueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn, endConn
                conn = RunService.RenderStepped:Connect(function()
                    if not PickerActive then conn:Disconnect(); if endConn then endConn:Disconnect() end return end
                    local _, y = GetInput(HueSlider)
                    h = y
                    UpdateColor()
                end)
                endConn = UserInputService.InputEnded:Connect(function(ended)
                    if ended.UserInputType == Enum.UserInputType.MouseButton1 then 
                        if conn then conn:Disconnect() end
                        if endConn then endConn:Disconnect() end
                    end
                end)
            end
        end)
        
        local ColorPickerComponent = {}
        function ColorPickerComponent:Set(col)
            if typeof(col) == "Color3" then
                h, s, v = Color3.toHSV(col)
                UpdateColor()
            end
        end
        return ColorPickerComponent
    end

    function Tab:CreateThemeManager()
        -- Deprecated: Theme Manager is now automatically built into the integrated Settings Tab when Window is created.
        -- We will leave this stub.
    end

    return Tab
end

return Lumina
