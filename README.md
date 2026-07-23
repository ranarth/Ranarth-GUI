# Ranarth GUI Library

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

---

## 📑 2. Creating Tabs

Tabs are used to separate features within the GUI. You can use the built-in icons from *Lucide Icons* (such as `home`, `settings`, `user`, `folder`, `zap`, etc.) or use Roblox asset IDs (`rbxassetid://...`).

```lua
local MainTab = Window:CreateTab({
    Name = "Dashboard", 
    Icon = "home"
})

local SettingsTab = Window:CreateTab({
    Name = "Settings", 
    Icon = "settings"
})
```

---

## 🛠️ 3. Adding Standard Elements

Use the Tab variable (e.g., `MainTab`) to start building UI elements.

### Section & Divider
Used to provide separators and titles between categories.
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

### Button (With Lock Feature)
```lua
local btn = MainTab:CreateButton({
    Name = "Upload Advanced Composition",
    Icon = "file",
    Callback = function()
        print("Executing code...")
    end
})

-- Locking the button (optional)
btn:Lock("Waiting for Tegar's review")
-- btn:Unlock() -- To unlock it later
```

### Toggle (Switch)
```lua
MainTab:CreateToggle({
    Name = "Performance Mode",
    Desc = "Disables heavy background animations",
    Default = true,
    Flag = "t_perf_mode", -- Used for the Save/Load Config system
    Callback = function(state)
        print("Toggle status:", state)
    end
})
```

### Slider (Supports Decimals & Increments)
This slider now supports high precision through the `Increment` parameter.
```lua
MainTab:CreateSlider({
    Name = "UI Render Scale",
    Min = 0.5,
    Max = 2.0,
    Increment = 0.1, -- Decimals are supported!
    CurrentValue = 1.0,
    Flag = "s_ui_scale",
    Callback = function(Value)
        print("Scale:", Value)
    end
})
```

### Dropdown & Multi-Dropdown
```lua
MainTab:CreateDropdown({
    Name = "Target Beta Game",
    Options = {"Arknights: Endfield", "Ananta", "Toram", "Tower of Fantasy"},
    CurrentValue = "Toram",
    Flag = "d_beta",
    Callback = function(Value)
        print("Selected:", Value)
    end
})

MainTab:CreateMultiDropdown({
    Name = "Optimization Plugins",
    Options = {"Mesh Reducer", "Texture Streamer", "Lighting Bake"},
    CurrentValue = {"Mesh Reducer"},
    Flag = "md_plugins",
    Callback = function(SelectedList)
        print("Total selected:", #SelectedList)
    end
})
```

### Input (TextBox) & Keybind
```lua
MainTab:CreateInput({
    Name = "Specifications",
    Placeholder = "Type here...",
    Callback = function(Text, EnterPressed)
        if EnterPressed then
            print("Input finished:", Text)
        end
    end
})

MainTab:CreateKeybind({
    Name = "Quick Action Key",
    Default = Enum.KeyCode.F,
    Flag = "k_action",
    Callback = function(Key)
        print("Keybind changed to:", Key.Name)
    end
})
```

### Color Picker
```lua
MainTab:CreateColorPicker({
    Name = "Dominant Accent Color",
    Default = Color3.fromRGB(100, 150, 255),
    Flag = "c_accent",
    Callback = function(Color)
        print("RGB:", Color.R, Color.G, Color.B)
    end
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

-- Updating the progress bar value
-- progress:SetValue(80)
```

### Paragraph & Code Block
```lua
MainTab:CreateParagraph({
    Title = "Particle Notes",
    Content = "은/는 is used as a topic marker in a sentence."
})

MainTab:CreateCodeBlock({
    Title = "Event Example (Lua)",
    Code = "print('Hello World!')
-- Second line"
})
```

### Built-in Search Bar
Instantly adds a feature to search for elements within the current tab.
```lua
MainTab:CreateSearchBar({Placeholder = "Search features in this tab..."})
```

---

## 📦 5. Layouting (HStack & Group)

You can nest elements horizontally or within a bordered group so the UI layout doesn't just linearly stack downwards.

```lua
-- Creating a Group (Box)
local MainGroup = MainTab:CreateGroup("Project Control")

-- Creating a Horizontal Layout (HStack) inside the Group
local ButtonRow = MainGroup:CreateHStack()

ButtonRow:CreateButton({Name = "Button 1", Callback = function() end})
ButtonRow:CreateButton({Name = "Button 2", Callback = function() end})
```
*Note: Elements inside an HStack will automatically distribute their widths evenly (flex).*

---

## 🔔 6. Global Utilities (Notifications & Dialogs)

### Notification
Appears floating at the corner of the screen. Can be called anywhere as long as `RanarthLib` is loaded.
```lua
RanarthLib:CreateNotification("Warning", "Data synchronization complete.", 4) -- Appears for 4 seconds
```

### Dialog Box (Modal)
Pops up in the center of the screen and temporarily freezes the UI activity behind it.
```lua
Window:CreateDialog("Start Practice", "Are you ready to test N4 Kanji?", {
    {
        Title = "Start", 
        Callback = function() print("Practice started") end
    },
    {
        Title = "Cancel", 
        Callback = function() end
    }
})
```

### SubPanel
Opens a small floating window attached next to the main GUI. This is highly useful for containing standard Roblox elements (*Raw Instances*) of your own creation.
```lua
local sub = Window:CreateSubPanel("Additional Notes", 240, 200)
-- 'sub' is a ScrollingFrame. You can Parent regular Roblox UI elements here.
```

---

## 💾 7. Configuration System (Save/Load)

Instead of creating save and load buttons manually, simply call this function. The library will automatically generate a section with a UI Input, a Dropdown containing the file list, and execution buttons to save/load settings based on the `Flag` of your elements.

```lua
SettingsTab:CreateConfigSystem()
```

---

## 🛑 8. Cleanup (Unload)
If you need to completely close and clear the GUI from memory:
```lua
RanarthLib:Unload()
```
