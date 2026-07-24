# Ranarth GUI

Ranarth GUI is a custom interface library for Roblox designed to be clean, modern, and highly flexible. It is perfectly suited for building game plugins or executing scripts, equipped with an automatic Config system, dynamic Layouting (Group & HStack), Modals, and optimized animations.

## 🚀 Installation & Loading

You can load this library directly from GitHub using `loadstring`.

```lua
local RanarthLib = loadstring(game:HttpGet("https://github.com/ranarth/Ranarth-GUI/releases/latest/download/main.lua"))()
```

---

## 🪟 1. Creating the Main Window

The first step is to create the main window. You can adjust the size, tab position, toggle keybind, and enable the configuration saving system.

```lua
local Window = RanarthLib:CreateWindow({
    Title = "Ranarth GUI | Developer Build",
    DefaultWidth = 580,
    DefaultHeight = 380,
    MinWidth = 450,
    MinHeight = 300,
    TabPosition = "Left", -- Options: "Left" or "Top"
    ToggleKey = Enum.KeyCode.RightControl, -- Key to hide/show the GUI
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Ranarth_Plugin_Data",
        FileName = "DefaultConfig"
    }
})
```
*💡 **Note:** Click the `-` button on the top right header to minimize the main panel into a draggable floating button.*

---

## 📑 2. Creating Tabs & Icon System (Lucide Icons)

Tabs are used to separate features within the GUI. Ranarth GUI supports **thousands of icons from Lucide Icons**!

**How to Use Icons:**
1. **Basic Icon Names:** You can simply type common icon names like `"home"`, `"settings"`, `"user"`, `"folder"`, etc.
2. **Full Collection (1,500+ Icons):** Visit the website [icons.rest](https://icons.rest/), find the icon you want, click to copy its **Asset ID** (the numbers), and paste it directly into the script!

```lua
local MainTab = Window:CreateTab({
    Name = "Dashboard", 
    Icon = "home" -- Using basic pre-mapped name
})
```

---

## 🛠️ 3. Adding Standard Elements

Use the Tab variable (e.g., `MainTab`) to start building UI elements.

### Section & Divider
```lua
MainTab:CreateSection("Main Category")
MainTab:CreateDivider()
```

### Label & Tooltip
Labels for static text, which can be enhanced with a description (desc) and a tooltip when hovered.
```lua
local InfoLabel = MainTab:CreateLabel({
    Name = "Environment Status",
    Desc = "All modules are running normally",
    Icon = "check"
})

-- Attaching a Tooltip to the label
RanarthLib:CreateTooltip(InfoLabel.Frame, "Connected to the server with low latency.")
```

**🔥 Advanced Example: Live Label Monitor**
You can update the text on a Label dynamically in *real-time* (e.g., for tracking enemies or FPS) by using the `:Set()` function.

```lua
-- Example: Live Tracking Enemies / Monsters in the map
task.spawn(function()
    while task.wait(0.5) do
        local enemyCount = 0
        local enemiesFolder = workspace:FindFirstChild("Enemies") 
        if enemiesFolder then
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                local humanoid = enemy:FindFirstChildWhichIsA("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    enemyCount = enemyCount + 1
                end
            end
        end
        
        -- Update the label text dynamically
        if InfoLabel then
            pcall(function()
                InfoLabel:Set("Monsters Alive: " .. tostring(enemyCount))
            end)
        end
    end
end)
```

### Button (With Lock Feature)
```lua
local btn = MainTab:CreateButton({
    Name = "Upload Advanced Composition",
    Icon = "file",
    Callback = function() end
})

-- Locking the button (optional)
btn:Lock("Requires admin access")
-- btn:Unlock() -- To unlock it later
```

### Toggle (Switch)
```lua
MainTab:CreateToggle({
    Name = "Performance Mode",
    Desc = "Disables heavy background animations",
    Default = true,
    Flag = "t_perf_mode",
    Callback = function(state) end
})
```

### Slider (Supports Decimals & Increments)
```lua
MainTab:CreateSlider({
    Name = "UI Render Scale",
    Min = 0.5,
    Max = 2.0,
    Increment = 0.1, -- Decimals are supported!
    CurrentValue = 1.0,
    Flag = "s_ui_scale",
    Callback = function(Value) end
})
```

### Dropdown & Multi-Dropdown
```lua
MainTab:CreateDropdown({
    Name = "Target Beta Game",
    Options = {"Arknights: Endfield", "Ananta", "Toram", "Tower of Fantasy"},
    CurrentValue = "Toram",
    Flag = "d_beta",
    Callback = function(Value) end
})
```

### Input (TextBox) & Keybind
```lua
MainTab:CreateInput({
    Name = "Specifications",
    Placeholder = "Type here...",
    Callback = function(Text, EnterPressed) end
})
```

### Color Picker
```lua
MainTab:CreateColorPicker({
    Name = "Dominant Accent Color",
    Default = Color3.fromRGB(100, 150, 255),
    Flag = "c_accent",
    Callback = function(Color) end
})
```

---

## 🎨 4. Extra & Visual Elements

### Progress Bar
```lua
local progress = MainTab:CreateProgressBar({
    Name = "Chamber Folk Track (100 BPM)",
    Max = 100,
    CurrentValue = 45
})
-- progress:SetValue(80)
```

### Paragraph & Code Block
```lua
MainTab:CreateParagraph({
    Title = "Important Notes",
    Content = "Ensure all assets are loaded properly before running."
})
```

### Built-in Search Bar
```lua
MainTab:CreateSearchBar({Placeholder = "Search features in this tab..."})
```

---

## 📦 5. Layouting (HStack & Group)

```lua
local MainGroup = MainTab:CreateGroup("Project Control")
local ButtonRow = MainGroup:CreateHStack()

ButtonRow:CreateButton({Name = "Button 1", Callback = function() end})
ButtonRow:CreateButton({Name = "Button 2", Callback = function() end})
```

---

## 🔔 6. Global Utilities (Notifications, Dialogs & Floating Buttons)

### Notification
```lua
RanarthLib:CreateNotification("Warning", "Data synchronization complete.", 4)
```

### Dialog Box (Modal)
Pops up in the center of the screen and temporarily freezes the UI activity behind it.
```lua
Window:CreateDialog("Start Configuration", "Are you ready to load this script?", {
    { Title = "Start", Callback = function() end },
    { Title = "Cancel", Callback = function() end }
})
```

### SubPanel
Opens a small floating window attached next to the main GUI.
```lua
local sub = Window:CreateSubPanel("Additional Notes", 240, 200)
```

### Custom Floating Button (New!)
A neat feature to create an independent, freely draggable button that stays on the screen even when your main GUI is minimized. It comes fully equipped with Ranarth's signature glowing stroke theme!
```lua
local myFloat = Window:CreateFloatingButton({
    Name = "Refresh: 0",
    Icon = "refresh-cw", -- Lucide icons are supported
    Callback = function()
        print("Floating button pressed!")
    end
})

-- You can also update the text dynamically in real-time:
-- myFloat:Set("Refresh: 5")
-- myFloat:SetVisible(false) 
-- myFloat:Destroy()
```

---

## 💾 7. Configuration System (Save/Load)
Automatically generates a UI section to save and load the `Flag` you set for elements.
```lua
SettingsTab:CreateConfigSystem()
```

---

## 🛑 8. Cleanup (Unload)
```lua
RanarthLib:Unload()
```
