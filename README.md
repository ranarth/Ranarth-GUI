# 🌌 Ranarth GUI

A modern, lightweight, and minimalist Roblox UI library. Designed for developers who want a clean aesthetic, blazing fast execution, and a simple Rayfield-style dictionary syntax.

---

## 📥 Loading the Library

To load the UI library into your script, use the `raw.githubusercontent` link to ensure you are always fetching the latest version.

```lua
local Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/ranarth/Ranarth-GUI/main/main.lua](https://raw.githubusercontent.com/ranarth/Ranarth-GUI/main/main.lua)"))()
```

---

## 🚀 Creating a Window

Initialize the main UI window. You can choose between top navigation or left side navigation.

```lua
local Window = Library:CreateWindow({
    Title = "Ranarth GUI Demo", 
    DefaultWidth = 500,
    DefaultHeight = 320,
    MinWidth = 400,
    MinHeight = 250,
    TabPosition = "Top" -- Choose "Top" or "Left"
})
```

---

## 📑 Creating Tabs & Sections

```lua
local MainTab = Window:CreateTab("Main Features")
local SettingsTab = Window:CreateTab("Settings")

MainTab:CreateSection({ Name = "Combat Settings" })
MainTab:CreateDivider()
```

---

## 🔘 Basic Elements

Ranarth GUI uses a clean dictionary table `{}` syntax for all elements.

### Label
Labels return an object with a `.Set()` function so you can update them dynamically (e.g., for player counts).
```lua
local StatusLabel = MainTab:CreateLabel({
    Name = "Status: Idle"
})

-- Update the label later:
-- StatusLabel.Set("Status: Farming")
```

### Button
```lua
MainTab:CreateButton({
    Name = "Execute Script",
    Callback = function()
        print("Button Clicked!")
    end
})
```

### Toggle
```lua
local MyToggle = MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false, -- Default state
    Callback = function(state)
        print("Auto Farm is now:", state)
    end
})

-- Update toggle state via script:
-- MyToggle.Set(true)
```

### Slider
```lua
MainTab:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    CurrentValue = 16,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})
```

---

## 📋 Advanced Elements

### Dropdown
```lua
local Dropdown = MainTab:CreateDropdown({
    Name = "Select Weapon",
    Options = {"Sword", "Bow", "Magic"},
    CurrentValue = "Sword",
    Callback = function(value)
        print("Equipped:", value)
    end
})

-- Refresh options dynamically:
-- Dropdown:Refresh({"Axe", "Spear", "Dagger"})
```

### Multi-Dropdown
Allows multiple selections at once.
```lua
local MultiDrop = MainTab:CreateMultiDropdown({
    Name = "Select Fruits",
    Options = {"Apple", "Banana", "Orange"},
    CurrentValue = {"Apple"},
    Callback = function(selected)
        -- 'selected' is a table of checked items
        print("Selected fruits:", table.concat(selected, ", "))
    end
})

-- Fetch selected items manually:
-- local currentFruits = MultiDrop.GetSelected()
```

### Keybind
```lua
MainTab:CreateKeybind({
    Name = "Dash Ability",
    CurrentKey = Enum.KeyCode.Q,
    Callback = function(key)
        print("Key pressed:", key)
    end
})
```

### Input Box
```lua
MainTab:CreateInput({
    Name = "Target Player",
    Placeholder = "Enter username...",
    Callback = function(text, enterPressed)
        print("Target set to:", text)
    end
})
```

### Color Picker
```lua
MainTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("New Color:", color)
    end
})
```

---

## 🔍 Display & Layout Utilities

### Search Bar
Automatically searches and filters elements within the tab!
```lua
MainTab:CreateSearchBar({ Placeholder = "Search features..." })
```

### Progress Bar
```lua
local ProgressBar = MainTab:CreateProgressBar({
    Name = "Loading",
    Max = 100,
    CurrentValue = 0
})

-- Update visually:
-- ProgressBar:SetValue(50)
```

### Paragraph & Code Block
```lua
MainTab:CreateParagraph({
    Title = "Warning",
    Content = "Use this feature at your own risk."
})

MainTab:CreateCodeBlock({
    Title = "Example Lua",
    Code = "print('Hello Ranarth!')"
})
```

### Grouping (Nesting)
You can visually group elements inside boxes.
```lua
local FarmGroup = MainTab:CreateGroup({ Name = "Farming Automation" })
FarmGroup:CreateToggle({ Name = "Auto Mob", Callback = function() end })
FarmGroup:CreateToggle({ Name = "Auto Boss", Callback = function() end })
```

---

## 💬 Global Functions

These functions are called directly from the `Library` or `Window` and float above the UI.

### Notification
```lua
-- Format: Library:CreateNotification(Title, Description, Duration)
Library:CreateNotification("Success", "Script injected successfully!", 3)
```

### Dialog Modal (Popup Confirmation)
```lua
Window:CreateDialog("Confirmation", "Are you sure you want to execute?", {
    { Title = "Yes", Callback = function() print("Executing...") end },
    { Title = "No", Callback = function() print("Cancelled") end }
})
```

---

## ⚙️ Configuration System

Ranarth GUI has a built-in UI for saving and loading user configs seamlessly!

```lua
local ConfigTab = Window:CreateTab("Config")

ConfigTab:CreateConfigSystem({
    -- What data should be saved?
    GetDataCallback = function()
        return {
            WalkSpeed = 50,
            AutoKill = true
        }
    end,
    -- What to do when a config is loaded?
    ApplyDataCallback = function(data)
        print("Loaded Walkspeed:", data.WalkSpeed)
        print("Loaded AutoKill:", data.AutoKill)
    end
})
```

---

# ❤️ Credits

Designed and maintained with ❤️ by **Ranarth**
