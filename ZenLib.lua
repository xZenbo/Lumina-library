-- [[ LUMINA UI LIBRARY ]]
-- Professional Roblox Luau UI Library

local Lumina = {}
Lumina.__index = Lumina

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Configuration
local SelectedTheme = {
    MainSide = Color3.fromRGB(30, 30, 35),
    Background = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(114, 137, 218),
    Text = Color3.fromRGB(255, 255, 255),
    SecondaryText = Color3.fromRGB(180, 180, 180)
}

-- Utility: Smooth Dragging
local function MakeDraggable(Frame)
    local Dragging, DragInput, DragStart, StartPos
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Frame.Position
        end
    end)
    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
end

-- Main Window Constructor
function Lumina.CreateWindow(Config)
    local self = setmetatable({}, Lumina)
    
    -- Root
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "LuminaLib"
    self.Gui.Parent = game.Players.LocalPlayer.PlayerGui or CoreGui
    
    -- Main Frame
    self.Main = Instance.new("Frame")
    self.Main.Size = UDim2.new(0, 500, 0, 350)
    self.Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    self.Main.BackgroundColor3 = SelectedTheme.Background
    self.Main.BorderSizePixel = 0
    self.Main.Parent = self.Gui
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 10)
    MakeDraggable(self.Main)

    -- Sidebar (Tabs Area)
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Size = UDim2.new(0, 150, 1, 0)
    self.Sidebar.BackgroundColor3 = SelectedTheme.MainSide
    self.Sidebar.Parent = self.Main
    Instance.new("UICorner", self.Sidebar).CornerRadius = UDim.new(0, 10)

    -- Container for Tabs
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(1, -160, 1, -10)
    self.Container.Position = UDim2.new(0, 155, 0, 5)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = self.Main

    -- Sidebar List Layout
    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Parent = self.Sidebar
    SideLayout.Padding = UDim.new(0, 5)

    self.Tabs = {}
    return self
end

-- Tab Constructor
function Lumina:CreateTab(Name)
    assert(self and self.Tabs, "Lumina: CreateTab must be called with a colon (:), not a dot (.)")
    local Tab = {}
    
    -- Tab Button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.BackgroundColor3 = SelectedTheme.Accent
    TabBtn.BackgroundTransparency = 0.8
    TabBtn.Text = Name
    TabBtn.TextColor3 = SelectedTheme.Text
    TabBtn.Parent = self.Sidebar
    Instance.new("UICorner", TabBtn)

    -- Tab Content Frame
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.ScrollBarThickness = 2
    TabFrame.Parent = self.Container
    
    local List = Instance.new("UIListLayout")
    List.Parent = TabFrame
    List.Padding = UDim.new(0, 8)

    -- Switching Logic
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Frame.Visible = false
        end
        TabFrame.Visible = true
    end)

    Tab.Frame = TabFrame
    table.insert(self.Tabs, Tab)
    
    -- Ensure first tab is visible
    if #self.Tabs == 1 then TabFrame.Visible = true end

    -- Element Methods (Button inside Tab)
    function Tab:CreateButton(Text, Callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -10, 0, 40)
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        Btn.Text = Text
        Btn.TextColor3 = SelectedTheme.Text
        Btn.AutoButtonColor = true
        Btn.Parent = TabFrame
        Instance.new("UICorner", Btn)

        Btn.MouseButton1Click:Connect(function()
            pcall(Callback)
        end)
    end

    return Tab
end

return Lumina
