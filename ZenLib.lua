-- [[ LUMINA UI LIBRARY V2 ]]
-- Professional, Resizable, and Keybound

local Lumina = {}
Lumina.__index = Lumina

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local SelectedTheme = {
    MainSide = Color3.fromRGB(25, 25, 30),
    Background = Color3.fromRGB(20, 20, 23),
    Accent = Color3.fromRGB(114, 137, 218),
    Text = Color3.fromRGB(255, 255, 255),
    SecondaryText = Color3.fromRGB(160, 160, 160),
    Topbar = Color3.fromRGB(30, 30, 35)
}

-- Utility: Smooth Dragging & Resizing
local function MakeDraggable(Frame, Handle)
    local Dragging, DragInput, DragStart, StartPos
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Frame.Position
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

local function MakeResizable(Frame, Handle)
    local Resizing, DragStart, StartSize
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Resizing = true
            DragStart = input.Position
            StartSize = Frame.Size
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = input.Position - DragStart
            Frame.Size = UDim2.new(0, math.max(300, StartSize.X.Offset + Delta.X), 0, math.max(200, StartSize.Y.Offset + Delta.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Resizing = false end
    end)
end

function Lumina.CreateWindow(Config)
    local self = setmetatable({}, Lumina)
    self.Visible = true
    self.ToggleKey = Config.Keybind or Enum.KeyCode.RightShift
    
    -- Root
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "LuminaV2"
    self.Gui.Parent = (RunService:IsStudio() and game.Players.LocalPlayer.PlayerGui) or CoreGui
    
    -- Main Frame
    self.Main = Instance.new("Frame")
    self.Main.Size = UDim2.new(0, 550, 0, 380)
    self.Main.Position = UDim2.new(0.5, -275, 0.5, -190)
    self.Main.BackgroundColor3 = SelectedTheme.Background
    self.Main.BorderSizePixel = 0
    self.Main.ClipsDescendants = true
    self.Main.Parent = self.Gui
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 8)

    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 35)
    Topbar.BackgroundColor3 = SelectedTheme.Topbar
    Topbar.BorderSizePixel = 0
    Topbar.Parent = self.Main
    
    local Title = Instance.new("TextLabel")
    Title.Text = Config.Name or "Lumina Lib"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = SelectedTheme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar

    -- Resize Handle (Bottom Right)
    local ResizeHandle = Instance.new("TextButton")
    ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
    ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = "◢"
    ResizeHandle.TextColor3 = SelectedTheme.SecondaryText
    ResizeHandle.Parent = self.Main
    
    MakeDraggable(self.Main, Topbar)
    MakeResizable(self.Main, ResizeHandle)

    -- Content Area
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Size = UDim2.new(0, 140, 1, -35)
    self.Sidebar.Position = UDim2.new(0, 0, 0, 35)
    self.Sidebar.BackgroundColor3 = SelectedTheme.MainSide
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Parent = self.Main

    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(1, -150, 1, -45)
    self.Container.Position = UDim2.new(0, 145, 0, 40)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = self.Main

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Parent = self.Sidebar
    SideLayout.Padding = UDim.new(0, 2)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Keybind Toggle Logic
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.ToggleKey then
            self.Visible = not self.Visible
            self.Main.Visible = self.Visible
        end
    end)

    self.Tabs = {}
    return self
end

function Lumina:CreateTab(Name)
    local Tab = {}
    
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0.9, 0, 0, 32)
    TabBtn.BackgroundColor3 = SelectedTheme.Accent
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = Name
    TabBtn.TextColor3 = SelectedTheme.SecondaryText
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.Parent = self.Sidebar
    Instance.new("UICorner", TabBtn)

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.ScrollBarThickness = 0
    TabFrame.Parent = self.Container
    
    local List = Instance.new("UIListLayout")
    List.Parent = TabFrame
    List.Padding = UDim.new(0, 5)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Frame.Visible = false
            TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = SelectedTheme.SecondaryText}):Play()
        end
        TabFrame.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, TextColor3 = SelectedTheme.Text}):Play()
    end)

    Tab.Frame = TabFrame
    Tab.Btn = TabBtn
    table.insert(self.Tabs, Tab)
    
    if #self.Tabs == 1 then 
        TabFrame.Visible = true 
        TabBtn.BackgroundTransparency = 0.8
        TabBtn.TextColor3 = SelectedTheme.Text
    end

    function Tab:CreateButton(Text, Callback)
        local BtnFrame = Instance.new("TextButton")
        BtnFrame.Size = UDim2.new(1, 0, 0, 38)
        BtnFrame.BackgroundColor3 = SelectedTheme.Topbar
        BtnFrame.Text = "  " .. Text
        BtnFrame.TextColor3 = SelectedTheme.Text
        BtnFrame.Font = Enum.Font.Gotham
        BtnFrame.TextXAlignment = Enum.TextXAlignment.Left
        BtnFrame.Parent = TabFrame
        Instance.new("UICorner", BtnFrame)

        BtnFrame.MouseButton1Click:Connect(function()
            TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = SelectedTheme.Accent}):Play()
            task.wait(0.1)
            TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = SelectedTheme.Topbar}):Play()
            pcall(Callback)
        end)
    end

    return Tab
end

return Lumina
