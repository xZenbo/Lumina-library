-- [[ LUMINA UI LIBRARY ]]

local Lumina = {}
Lumina.__index = Lumina
Lumina.Windows = {}

local LucideIcons = {}
pcall(function()
    LucideIcons = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/Icons.lua"))().assets
end)

local function GetIcon(Name)
    if not Name then return "" end
    if Name:match("rbxassetid://") or Name:match("http://") or Name:match("https://") then return Name end
    
    local formatted = Name:lower():gsub(" ", "-")
    if LucideIcons["lucide-" .. formatted] then
        return LucideIcons["lucide-" .. formatted]
    elseif LucideIcons[formatted] then
        return LucideIcons[formatted]
    end
    return Name
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
    ["Default Dark"] = {Accent = Color3.fromRGB(114, 137, 218), MainSide = Color3.fromRGB(20, 20, 25), Background = Color3.fromRGB(15, 15, 18), Topbar = Color3.fromRGB(25, 25, 30), Text = Color3.fromRGB(255, 255, 255), Stroke = Color3.fromRGB(45, 45, 55)},
    ["Midnight"] = {Accent = Color3.fromRGB(255, 255, 255), MainSide = Color3.fromRGB(10, 10, 10), Background = Color3.fromRGB(5, 5, 5), Topbar = Color3.fromRGB(15, 15, 15), Text = Color3.fromRGB(255, 255, 255), Stroke = Color3.fromRGB(35, 35, 45)},
    ["Sakura"] = {Accent = Color3.fromRGB(255, 175, 204), MainSide = Color3.fromRGB(40, 30, 35), Background = Color3.fromRGB(30, 20, 25), Topbar = Color3.fromRGB(45, 35, 40), Text = Color3.fromRGB(255, 220, 230), Stroke = Color3.fromRGB(60, 45, 50)},
    ["Oceanic"] = {Accent = Color3.fromRGB(0, 170, 255), MainSide = Color3.fromRGB(15, 25, 35), Background = Color3.fromRGB(10, 15, 25), Topbar = Color3.fromRGB(20, 35, 50), Text = Color3.fromRGB(230, 240, 255), Stroke = Color3.fromRGB(35, 50, 70)},
    ["Cyberpunk"] = {Accent = Color3.fromRGB(255, 0, 85), MainSide = Color3.fromRGB(20, 20, 30), Background = Color3.fromRGB(15, 15, 20), Topbar = Color3.fromRGB(30, 25, 40), Text = Color3.fromRGB(0, 255, 200), Stroke = Color3.fromRGB(50, 40, 60)},
    ["Ruby"] = {Accent = Color3.fromRGB(220, 50, 50), MainSide = Color3.fromRGB(30, 15, 15), Background = Color3.fromRGB(20, 10, 10), Topbar = Color3.fromRGB(40, 20, 20), Text = Color3.fromRGB(255, 220, 220), Stroke = Color3.fromRGB(60, 30, 30)}
}

local ConfigData = {}
local ConfigName = "Lumina_Config.json"

local function SaveConfig()
    if writefile then
        pcall(function() writefile(ConfigName, HttpService:JSONEncode(ConfigData)) end)
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigName) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigName)) end)
        if success then ConfigData = data end
    end
end
LoadConfig()

local function Register(obj, category, prop)
    if not prop then
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then prop = "TextColor3"
        elseif obj:IsA("UIStroke") then prop = "Color"
        else prop = "BackgroundColor3" end
    end
    table.insert(ThemeRegistry[category], {Instance = obj, Property = prop})
    obj[prop] = Theme[category]
end

local function UpdateTheme(category, color)
    if typeof(category) == "table" then
        for cat, col in pairs(category) do UpdateTheme(cat, col) end
        return
    end
    Theme[category] = color
    if ThemeRegistry[category] then
        for _, data in pairs(ThemeRegistry[category]) do
            if data.Instance and data.Instance.Parent then
                TweenService:Create(data.Instance, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[data.Property] = color}):Play()
            end
        end
    end
end

local function CreateTween(instance, properties, duration, style, direction)
    local tInfo = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tInfo, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(Frame, Handle)
    local Dragging, DragStart, StartPos
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true; DragStart = input.Position; StartPos = Frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = input.Position - DragStart
            Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end)
end

function Lumina.CreateWindow(Config)
    local self = setmetatable({}, Lumina)
    table.insert(Lumina.Windows, self)
    self.Visible = true
    self.ToggleKey = (ConfigData["Lumina_ToggleKey"] and Enum.KeyCode[ConfigData["Lumina_ToggleKey"]]) or Config.Keybind or Enum.KeyCode.RightShift
    self.Tabs = {} 
    self.Connections = {}
    local MaxSize = Config.MaxSize or Vector2.new(900, 700)
    
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "LuminaV5"
    self.Gui.ResetOnSpawn = false
    self.Gui.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or CoreGui
    
    self.Main = Instance.new("CanvasGroup")
    self.Main.Size = UDim2.new(0, 650, 0, 450)
    self.Main.Position = UDim2.new(0.5, -325, 0.5, -225)
    self.Main.GroupTransparency = 0.05
    Register(self.Main, "Background")
    self.Main.BorderSizePixel = 0
    self.Main.Parent = self.Gui

    local MainCorner = Instance.new("UICorner", self.Main)
    MainCorner.CornerRadius = UDim.new(0, 10)

    local MainStroke = Instance.new("UIStroke", self.Main)
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.5
    Register(MainStroke, "Stroke", "Color")

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Register(Topbar, "Topbar")
    Topbar.BorderSizePixel = 0
    Topbar.Parent = self.Main
    
    local Title = Instance.new("TextLabel")
    Title.Text = Config.Name or "Lumina"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Register(Title, "Text")
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar

    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Size = UDim2.new(0.28, 0, 1, -40)
    self.Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Register(self.Sidebar, "MainSide")
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Parent = self.Main

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
    self.Container.Parent = self.Main

    self.TabList = Instance.new("ScrollingFrame")
    self.TabList.Size = UDim2.new(1, 0, 1, 0)
    self.TabList.BackgroundTransparency = 1
    self.TabList.ScrollBarThickness = 0
    self.TabList.Parent = self.Sidebar

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Parent = self.TabList
    SideLayout.Padding = UDim.new(0, 6)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local SidePad = Instance.new("UIPadding", self.TabList)
    SidePad.PaddingTop = UDim.new(0, 8)
    
    MakeDraggable(self.Main, Topbar)

    local toggleConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.ToggleKey then
            self.Visible = not self.Visible
            CreateTween(self.Main, {GroupTransparency = self.Visible and 0.05 or 1}, 0.5, Enum.EasingStyle.Quart)
            self.Main.Visible = self.Visible
        end
    end)
    table.insert(self.Connections, toggleConn)

    self.ToastContainer = Instance.new("Frame")
    self.ToastContainer.Size = UDim2.new(0, 300, 1, -40)
    self.ToastContainer.Position = UDim2.new(1, -320, 0, 20)
    self.ToastContainer.BackgroundTransparency = 1
    self.ToastContainer.Parent = self.Gui
    local ToastLayout = Instance.new("UIListLayout", self.ToastContainer)
    ToastLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ToastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    ToastLayout.Padding = UDim.new(0, 10)

    return self
end

function Lumina:Notify(Options)
    local targetWindow = self.ToastContainer and self or Lumina.Windows[1]
    if not targetWindow or not targetWindow.ToastContainer then return end

    local Title = Options.Title or "Notification"
    local Content = Options.Content or "Content"
    local Duration = Options.Duration or 3

    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(1, 50, 0, 65)
    Register(Toast, "Topbar")
    Toast.BackgroundTransparency = 1
    Toast.Parent = targetWindow.ToastContainer
    Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 10)

    local TStroke = Instance.new("UIStroke", Toast)
    TStroke.Thickness = 1.2
    TStroke.Transparency = 1
    Register(TStroke, "Accent", "Color")

    local TTitle = Instance.new("TextLabel", Toast)
    TTitle.Size = UDim2.new(1, -20, 0, 25)
    TTitle.Position = UDim2.new(0, 10, 0, 5)
    TTitle.BackgroundTransparency = 1
    Register(TTitle, "Text")
    TTitle.Font = Enum.Font.GothamBold
    TTitle.TextSize = 14
    TTitle.TextXAlignment = Enum.TextXAlignment.Left
    TTitle.TextTransparency = 1
    TTitle.Text = Title

    local TContent = Instance.new("TextLabel", Toast)
    TContent.Size = UDim2.new(1, -20, 0, 25)
    TContent.Position = UDim2.new(0, 10, 0, 30)
    TContent.BackgroundTransparency = 1
    Register(TContent, "SecondaryText")
    TContent.Font = Enum.Font.Gotham
    TContent.TextSize = 13
    TContent.TextXAlignment = Enum.TextXAlignment.Left
    TContent.TextTransparency = 1
    TContent.Text = Content

    CreateTween(Toast, {Size = UDim2.new(1, 0, 0, 65), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    CreateTween(TStroke, {Transparency = 0.5}, 0.5)
    CreateTween(TTitle, {TextTransparency = 0}, 0.5)
    CreateTween(TContent, {TextTransparency = 0}, 0.5)

    task.delay(Duration, function()
        CreateTween(Toast, {Size = UDim2.new(1, 50, 0, 65), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        CreateTween(TStroke, {Transparency = 1}, 0.5)
        CreateTween(TTitle, {TextTransparency = 1}, 0.5)
        CreateTween(TContent, {TextTransparency = 1}, 0.5)
        task.wait(0.5)
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

    if self.Connections then
        for _, conn in ipairs(self.Connections) do 
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end 
        end
    end
    if self.Gui then self.Gui:Destroy() end
end

local function RenderComponentBase(TargetParent, Height)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -6, 0, Height)
    Register(Frame, "Topbar")
    Frame.Parent = TargetParent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.8
    Register(Stroke, "Stroke", "Color")

    return Frame, Stroke
end

function Lumina:CreateTab(Name, IconName)
    local Window = self
    local Tab = { LayoutOrder = 0 }
    
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -16, 0, 35)
    Register(TabBtn, "Accent", "BackgroundColor3")
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = IconName and "    " .. Name or " " .. Name
    Register(TabBtn, "SecondaryText", "TextColor3")
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 14
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Window.TabList
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    
        local TabIcon = Instance.new("ImageLabel", TabBtn)
        TabIcon.Name = "Icon"
        TabIcon.Size = UDim2.new(0, 16, 0, 16)
        TabIcon.Position = UDim2.new(0, -15, 0.5, -8)
        TabIcon.BackgroundTransparency = 1
        local fetchedIcon = GetIcon(IconName)
        TabIcon.Image = fetchedIcon
        if not fetchedIcon:match("rbxassetid://") and not IconName then TabIcon.Visible = false end
        Register(TabIcon, "SecondaryText", "ImageColor3")
        

    local TabPad = Instance.new("UIPadding", TabBtn)
    TabPad.PaddingLeft = UDim.new(0, 20)

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.ScrollBarThickness = 2
    Register(TabFrame, "Accent", "ScrollBarImageColor3")
    TabFrame.Parent = Window.Container
    
    local List = Instance.new("UIListLayout", TabFrame)
    List.Padding = UDim.new(0, 8)
    List.SortOrder = Enum.SortOrder.LayoutOrder

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Window.Tabs) do
            t.Frame.Visible = false
            CreateTween(t.Btn, {BackgroundTransparency = 1}, 0.3)
            if t.Icon then Register(t.Icon, "SecondaryText", "ImageColor3") end
            Register(t.Btn, "SecondaryText", "TextColor3")
        end
        TabFrame.Visible = true
        CreateTween(TabBtn, {BackgroundTransparency = 0.9}, 0.3)
        if TabIcon then Register(TabIcon, "Accent", "ImageColor3") end
        Register(TabBtn, "Text", "TextColor3")
    end)

    if #Window.Tabs == 0 then 
        TabFrame.Visible = true 
        TabBtn.BackgroundTransparency = 0.9
        if TabIcon then Register(TabIcon, "Accent", "ImageColor3") end
        Register(TabBtn, "Text", "TextColor3")
    end

    Tab.Frame = TabFrame
    Tab.Btn = TabBtn
    Tab.Icon = TabIcon
    table.insert(Window.Tabs, Tab)

    function Tab:CreateLabel(Text)
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        
        local LabelFrame = Instance.new("Frame")
        LabelFrame.Size = UDim2.new(1, -6, 0, 30)
        LabelFrame.BackgroundTransparency = 1
        LabelFrame.Parent = ParentFrame

        local Label = Instance.new("TextLabel", LabelFrame)
        Label.Size = UDim2.new(1, -20, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Text
        Register(Label, "Text", "TextColor3") 
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextWrapped = true

        return Label
    end

    function Tab:CreateSection(SectionName)
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local Section = {LayoutOrder = 0}
        
        local SecFrame = Instance.new("Frame")
        SecFrame.Size = UDim2.new(1, -6, 0, 40)
        SecFrame.BackgroundTransparency = 1
        SecFrame.Parent = TabFrame

        local SecHeader = Instance.new("TextLabel", SecFrame)
        SecHeader.Size = UDim2.new(1, -10, 0, 20)
        SecHeader.Position = UDim2.new(0, 10, 0, 5)
        SecHeader.BackgroundTransparency = 1
        SecHeader.Text = SectionName
        Register(SecHeader, "Accent", "TextColor3")
        SecHeader.Font = Enum.Font.GothamBold
        SecHeader.TextSize = 13
        SecHeader.TextXAlignment = Enum.TextXAlignment.Left

        local SecContainer = Instance.new("Frame", SecFrame)
        SecContainer.Size = UDim2.new(1, 0, 1, -30)
        SecContainer.Position = UDim2.new(0, 0, 0, 30)
        SecContainer.BackgroundTransparency = 0.9
        
        local SecStroke = Instance.new("UIStroke", SecContainer)
        SecStroke.Thickness = 2
        SecStroke.Transparency = 0
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
            SecFrame.Size = UDim2.new(1, -6, 0, SecLayout.AbsoluteContentSize.Y + 46)
            if CanvasUpdate then CanvasUpdate() end
        end
        SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionSize)
        
        task.defer(UpdateSectionSize)

        local ProxyTab = setmetatable({}, {__index = Tab})
        ProxyTab.TargetParent = SecContainer
        return ProxyTab
    end

    function Tab:CreateButton(Text, Callback)
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        local ButtonFrame, Stroke = RenderComponentBase(ParentFrame, 40)
        
        local Button = Instance.new("TextButton", ButtonFrame)
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
        Button.MouseButton1Down:Connect(function()
            CreateTween(ButtonFrame, {Size = UDim2.new(1, -12, 0, 36)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)
        Button.MouseButton1Up:Connect(function()
            CreateTween(ButtonFrame, {Size = UDim2.new(1, -6, 0, 40)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            pcall(Callback)
        end)
    end

    function Tab:CreateToggle(Text, Default, Callback)
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        
        if ConfigData[Text] ~= nil then Default = ConfigData[Text] end
        local Toggled = Default or false

        local ToggleFrame, Stroke = RenderComponentBase(ParentFrame, 44)

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
        Clicker.Size = UDim2.new(1, 0, 1, 0)
        Clicker.BackgroundTransparency = 1
        Clicker.Text = ""

        Clicker.MouseEnter:Connect(function() CreateTween(Stroke, {Transparency = 0.4}, 0.3) end)
        Clicker.MouseLeave:Connect(function() CreateTween(Stroke, {Transparency = 0.8}, 0.3) end)

        local function FireToggle(state)
            Toggled = state
            CreateTween(SwitchBg, {BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(50, 50, 55)}, 0.4)
            CreateTween(Dot, {Position = Toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            ConfigData[Text] = Toggled; SaveConfig()
            pcall(Callback, Toggled)
        end

        Clicker.MouseButton1Click:Connect(function() FireToggle(not Toggled) end)
        if Toggled then pcall(Callback, Toggled) end
    end

    function Tab:CreateSlider(Text, Min, Max, Default, Callback)
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        if ConfigData[Text] ~= nil then Default = ConfigData[Text] end
        local Value = Default or Min

        local SliderFrame, Stroke = RenderComponentBase(ParentFrame, 54)

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

        local function Update(pos)
            local pct = math.clamp((pos.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
            Value = math.floor(Min + (Max - Min) * pct)
            CreateTween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1)
            ValBtn.Text = tostring(Value)
            ConfigData[Text] = Value; SaveConfig()
            pcall(Callback, Value)
        end

        local Dragging = false
        SliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true; Update(UserInputService:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset())
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                Update(UserInputService:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset())
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
        end)
    end

    function Tab:CreateInput(Text, Placeholder, Callback)
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        local InputFrame, Stroke = RenderComponentBase(ParentFrame, 44)

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
        Register(TBox, "Text", "TextColor3")
        TBox.Font = Enum.Font.Gotham
        TBox.TextSize = 13
        TBox.TextXAlignment = Enum.TextXAlignment.Left
        TBox.ClearTextOnFocus = false

        TBox.Focused:Connect(function()
            CreateTween(TbxStroke, {Transparency = 0.2, Color = Theme.Accent}, 0.3)
        end)

        TBox.FocusLost:Connect(function(enterPressed)
            CreateTween(TbxStroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.3)
            pcall(Callback, TBox.Text, enterPressed)
        end)
    end

    function Tab:CreateKeybind(Text, Default, Callback)
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        if ConfigData[Text] ~= nil then Default = Enum.KeyCode[ConfigData[Text]] end
        local Key = Default

        local BindFrame, Stroke = RenderComponentBase(ParentFrame, 44)

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

        BindBtn.MouseButton1Click:Connect(function()
            BindBtn.Text = "Listening..."
            CreateTween(BStroke, {Transparency = 0.2, Color = Theme.Accent}, 0.2)

            local conn
            conn = UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                    Key = input.KeyCode
                    BindBtn.Text = Key.Name
                    ConfigData[Text] = Key.Name; SaveConfig()
                    CreateTween(BStroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.2)
                    pcall(Callback, Key)
                    conn:Disconnect()
                end
            end)
        end)

        local gConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and Key and input.KeyCode == Key then pcall(Callback, Key) end
        end)
        table.insert(Window.Connections, gConn)
    end

    function Tab:CreateDropdown(Text, Options, Callback)
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        local Dropped = false
        if ConfigData[Text] ~= nil and table.find(Options, ConfigData[Text]) then
        end

        local DropdownFrame, Stroke = RenderComponentBase(ParentFrame, 44)
        DropdownFrame.ClipsDescendants = true

        local Label = Instance.new("TextLabel", DropdownFrame)
        Label.Text = "  " .. Text
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

        for _, opt in ipairs(Options) do
            local OptBtn = Instance.new("TextButton", OptionContainer)
            OptBtn.Size = UDim2.new(1, 0, 0, 28)
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = "  " .. opt
            Register(OptBtn, "SecondaryText", "TextColor3") 
            OptBtn.Font = Enum.Font.GothamMedium
            OptBtn.TextSize = 13
            OptBtn.TextXAlignment = Enum.TextXAlignment.Left

            OptBtn.MouseEnter:Connect(function() CreateTween(OptBtn, {TextColor3 = Theme.Accent}, 0.2) end)
            OptBtn.MouseLeave:Connect(function() CreateTween(OptBtn, {TextColor3 = Theme.SecondaryText}, 0.2) end)

            OptBtn.MouseButton1Click:Connect(function()
                Label.Text = "  " .. Text .. " (" .. opt .. ")"
                Dropped = false
                Icon.Text = "+"
                CreateTween(DropdownFrame, {Size = UDim2.new(1, -6, 0, 44)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                ConfigData[Text] = opt; SaveConfig()
                pcall(Callback, opt)
            end)
        end

        local Clicker = Instance.new("TextButton", DropdownFrame)
        Clicker.Size = UDim2.new(1, 0, 0, 44)
        Clicker.BackgroundTransparency = 1
        Clicker.Text = ""

        Clicker.MouseButton1Click:Connect(function()
            Dropped = not Dropped
            Icon.Text = Dropped and "-" or "+"
            local targetHeight = Dropped and (44 + (#Options * 32) + 6) or 44
            CreateTween(DropdownFrame, {Size = UDim2.new(1, -6, 0, targetHeight)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end)
        
        Clicker.MouseEnter:Connect(function() CreateTween(Stroke, {Transparency = 0.2, Color = Theme.Accent}, 0.3) end)
        Clicker.MouseLeave:Connect(function() CreateTween(Stroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.3) end)
    end

    function Tab:CreateColorPicker(Text, Category, Default, Callback)
        Tab.LayoutOrder = Tab.LayoutOrder + 1
        local ParentFrame = self.TargetParent or TabFrame
        local PickerActive = false
        local InitialColor = (typeof(Default) == "Color3" and Default) or Theme[Category] or Color3.new(1, 1, 1)
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
            if Category then UpdateTheme(Category, NewCol) end
            if Callback then pcall(Callback, NewCol) end
        end

        Display.MouseEnter:Connect(function() CreateTween(Stroke, {Transparency = 0.2, Color = Theme.Accent}, 0.3) end)
        Display.MouseLeave:Connect(function() CreateTween(Stroke, {Transparency = 0.8, Color = Theme.Stroke}, 0.3) end)

        Display.MouseButton1Click:Connect(function()
            PickerActive = not PickerActive
            SatValSquare.Visible = PickerActive
            HueSlider.Visible = PickerActive
            CreateTween(ColorFrame, {Size = PickerActive and UDim2.new(1, -6, 0, 180) or UDim2.new(1, -6, 0, 44)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end)

        local function GetInput(obj)
            local mouse = UserInputService:GetMouseLocation()
            local relativePos = mouse - obj.AbsolutePosition - game:GetService("GuiService"):GetGuiInset()
            return math.clamp(relativePos.X / obj.AbsoluteSize.X, 0, 1), math.clamp(relativePos.Y / obj.AbsoluteSize.Y, 0, 1)
        end

        SatValSquare.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn
                conn = RunService.RenderStepped:Connect(function()
                    if not PickerActive then conn:Disconnect() return end
                    local x, y = GetInput(SatValSquare)
                    s, v = x, 1 - y
                    UpdateColor()
                end)
                UserInputService.InputEnded:Connect(function(ended)
                    if ended.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end
                end)
            end
        end)

        HueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn
                conn = RunService.RenderStepped:Connect(function()
                    if not PickerActive then conn:Disconnect() return end
                    local _, y = GetInput(HueSlider)
                    h = y
                    UpdateColor()
                end)
                UserInputService.InputEnded:Connect(function(ended)
                    if ended.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end
                end)
            end
        end)
    end

    function Tab:CreateThemeManager()
        local ThemeSection = self:CreateSection("Theme System")

        local presetNames = {}
        for name, _ in pairs(Presets) do
            table.insert(presetNames, name)
        end
        
        ThemeSection:CreateDropdown("Theme Presets", presetNames, function(selected)
            local preset = Presets[selected]
            if preset then
                UpdateTheme(preset)
            end
        end)

        ThemeSection:CreateKeybind("Toggle UI", Window.ToggleKey, function(Key)
            Window.ToggleKey = Key
            ConfigData["Lumina_ToggleKey"] = Key.Name
            SaveConfig()
        end)

        ThemeSection:CreateColorPicker("Accent Color", "Accent", Theme.Accent, function() end)
        ThemeSection:CreateColorPicker("Background", "Background", Theme.Background, function() end)
        ThemeSection:CreateColorPicker("Sidebar", "MainSide", Theme.MainSide, function() end)
        ThemeSection:CreateColorPicker("Topbar/Buttons", "Topbar", Theme.Topbar, function() end)
        ThemeSection:CreateColorPicker("Text Color", "Text", Theme.Text, function() end)
        ThemeSection:CreateColorPicker("Stroke/Borders", "Stroke", Theme.Stroke, function() end)
    end

    return Tab
end

return Lumina
