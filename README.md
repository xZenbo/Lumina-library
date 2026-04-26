# Lumina Documentation

## Getting Started

Learn how to initialize Lumina and create a working user interface.

```lua
local Lumina = loadstring(game:HttpGet("https://raw.githubusercontent.com/xZenbo/Lumina-library/refs/heads/main/Lumina.lua"))()

local Window = Lumina.CreateWindow({
    Name = "Lumina Hub",
    MaxSize = Vector2.new(900, 700),
    CustomTheme = false, -- Set to true to enable custom color pickers in the Settings tab
    UseCanvasGroup = true, -- Toggles CanvasGroup for the main window (premium fade & opacity effects)
    Icon = "eclipse" -- Loading and open ui button icon | Lucide icons
    -- Keybind = Enum.KeyCode.LeftControl |  Ui keybind. Default is left ctrl if not set in createwindow
})

local MainTab = Window:CreateTab("Main", "lucide-home")
```

## Sections

Sections are perfect for grouping multiple UI elements within a tab. They can now also be collapsible!

```lua
-- Creates an uncollapsible section
local CombatSection = MainTab:CreateSection("Combat Settings", false, "lucide-icon")

-- Creates a collapsible section (by clicking the + / - header)
local CollapsibleSec = MainTab:CreateSection("Extra Settings", true, "lucide-icon")
```

## Labels

Labels are non-interactive text elements used to display information or titles within your UI.

```lua
MainTab:CreateLabel("Please make sure to inject before executing!", "lucide-icon")
```

## Buttons

Standard buttons for immediate single-click actions.

```lua
-- CreateButton(Text, Callback, InfoText)
MainTab:CreateButton("Click Me", function()
    print("Button clicked!")
end, "This is an optional info text!")
```

## Toggles

Toggles act as checkboxes which can output boolean values (true / false).

```lua
-- CreateToggle(Text, Default, Callback, NoSave, InfoText, Flag)
MainTab:CreateToggle("Auto Farmer", false, function(Value)
    print("Toggle is now:", Value)
end, false, "Automatically farms enemies for you", "AutoFarmToggle")
```

## Sliders

A smooth dragging slider that returns a number within a specified range.

```lua
-- CreateSlider(Text, Min, Max, Default, Callback, NoSave, InfoText, Flag)
MainTab:CreateSlider("WalkSpeed", 16, 120, 16, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end, false, "Adjusts your movement speed", "PlayerWalkSpeed")
```

## Inputs (Text Box)

An interactive field where users can type and submit text data. The callback receives the text string and a boolean indicating if tracking ended due to an 'Enter' key press.

```lua
-- CreateInput(Text, Placeholder, Callback, NoSave, InfoText, Flag)
MainTab:CreateInput("Message", "Type a message", function(Text, enterPressed)
    if enterPressed then
        print("User submitted:", Text)
    end
end, false, "Sets the automated chat message", "ChatMacroInput")
```

## Dropdowns

Dropdowns allow users to select from a list of predefined options. You can optionally enable Multi-Select mode.

```lua
-- CreateDropdown(Text, Options, Callback, MultiSelect, NoSave, InfoText, Flag)
MainTab:CreateDropdown("Select Player", {"Player1", "Player2", "Player3"}, function(Option)
    -- In MultiSelect, 'Option' is a table of selected strings
    -- In single select, 'Option' is a single string
    print("Selected:", Option)
end, false, false, "Pick a player to spectate", "SpectateDropdown")
```

## Color Pickers

A full Hue-Saturation-Value color window to select custom colors.

```lua
-- CreateColorPicker(Text, Category, Default, Callback, NoSave, InfoText, Flag)
-- Note: 'Category' corresponds to a custom theme category if you are editing the UI theme. Pass nil for normal pickers.
MainTab:CreateColorPicker("ESP Color", nil, Color3.fromRGB(255, 0, 0), function(Color)
    print("New Color:", Color)
end, false, "Changes the ESP line color", "ESPColorPicker")
```

## Keybinds

Allows the user to bind custom keyboard keys on the fly.

```lua
-- CreateKeybind(Text, Default, Callback, NoSave, InfoText, Flag)
MainTab:CreateKeybind("Toggle UI", Enum.KeyCode.RightShift, function(Key)
    print("UI Bind changed to:", Key.Name)
end, true, "Overrides the default UI visibility toggle.", "UIToggleBind")
```

## Flags & Advanced Configuration

Every customizable UI element can optionally take a 'Flag' identifier as its last parameter. This is incredibly useful if you have elements with identical names, as the Flag determines exactly how the setting is saved in the auto-generated config file, avoiding conflicts.

```lua
-- The Flag is always the very last argument!
MainTab:CreateToggle("Aim Assist", false, function(Value)
end, false, "Requires mouse to be locked", "AimAssistToggle")

-- If NoSave is set to true, the element will not be tracked by the config manager!
MainTab:CreateSlider("Range", 0, 100, 50, function(Value)
end, true, "Will not save dynamically!", "AimAssistRange")
```

## Updating Elements (:Set)

Every UI element created returns an object containing a ':Set()' method. You can use this method to dynamically update your interface through script. Doing so will trigger animations, re-evaluate config files, and fire all assigned callbacks exactly as if the user clicked it.

```lua
-- Store the returned object when creating it
local MyToggle = MainTab:CreateToggle("Aimbot", false, function(v) print("Aimbot is", v) end)
local MySlider = MainTab:CreateSlider("FOV", 60, 120, 90, function(v) end)
local MyInput = MainTab:CreateInput("Search", "...", function(t) end)
local MyDropdown = MainTab:CreateDropdown("Mode", {"Legit", "Blatant"}, function(o) end)

-- Later in your script, update them dynamically
MyToggle:Set(true)
MySlider:Set(100)
MyInput:Set("Head")
MyDropdown:Set("Blatant")
```

## Settings & Configuration System

Lumina automatically generates a 'Settings' tab. This tab includes Keybinds, Theme Presets, and an integrated advanced File-based Configuration system per-game (using game.PlaceId). You no longer need to manually create theme managers or config handlers.

```lua
-- The Settings tab is automatically injected in the top bar of your UI.
-- Users can Create, Load, and Save configs directly from the UI.
-- Configs are saved in 'workspace/Lumina/Configs/[PlaceId]' 
-- to natively support multiple games!

-- To enable the ADVANCED color picker menu inside the Settings Tab,
-- pass 'CustomTheme = true' during CreateWindow() initialization.
```

## Utility Methods

Helper functions attached directly to the root Lumina or Window object.

```lua
-- Send a sleek Toast notification
Lumina:Notify({
    Title = "Warning",
    Content = "You've enabled an experimental feature.",
    Duration = 4, -- Seconds until disappearance
    Icon = "lucide-triangle-alert" -- Uses built-in Lucide icons
})
```

