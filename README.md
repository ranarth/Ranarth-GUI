# Ranarth GUI Library

Ranarth GUI is a clean, modern, and highly flexible Custom UI Library for Roblox. It is perfectly suited for building game plugins or executing scripts, equipped with an automatic Config system, a live 7-theme Theming Engine, dynamic Layouting (Group & HStack), an Image Panel for previews, Smart Anti-Spam Notifications, Interactive Color Buttons, a Built-in Log Terminal, and highly optimized, memory-leak-free animations.

## 🚀 Installation & Loading

Load the library directly from your GitHub repository using `loadstring`.

```lua
local RanarthLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ranarth/Ranarth-GUI/main/main.lua"))()
```

---

## 🪟 1. Creating the Main Window

Initialize the main window interface. You can adjust the size, tab position, toggle keybind, configure the saving system, and toggle the anti-spam protection.

```lua
local Window = RanarthLib:CreateWindow({
    Title = "Ranarth GUI | Developer Build",
    DefaultWidth = 580,
    DefaultHeight = 380,
    MinWidth = 450,
    MinHeight = 300,
    TabPosition = "Left", -- Options: "Left" or "Top"
    ToggleKey = Enum.KeyCode.RightControl, -- Key to hide/show the GUI
    AntiSpam = true, -- Enable/Disable Notification Anti-Spam Protection
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Ranarth_Plugin_Data",
        FileName = "DefaultConfig"
    }
})
```
*💡 **Note:** Click the `-` button on the top right header to minimize the main panel into a freely draggable floating button.*

---

## 📑 2. Tabs, Namespace & Hybrid Icon System

Tabs organize your features. Our unique **Tab Namespace System** ensures that `Flag` names won't conflict even if you use the same name in different tabs.

Ranarth GUI features a **Hybrid Icon System**: it comes with 150+ built-in icons for instant loading, while seamlessly fetching future extensions directly from your external GitHub repository.

**How to Use Icons (Supports any element with an `Icon` or `Image` property):**
1. **Built-in Names:** Type names like `"home"`, `"settings"`, `"scan-face"`, `"gamepad"`, `"sword"`, etc.
2. **Roblox Asset IDs & Thumbnails:** Paste a Roblox image ID directly (e.g., `"rbxassetid://123456789"`). The GUI fully supports case-sensitive thumbnail APIs like `"rbxthumb://type=Asset&id=12345678&w=150&h=150"` and external web URLs.

```lua
local MainTab = Window:CreateTab({
    Name = "Dashboard", 
    Icon = "home" 
})
```

---

## 🛠️ 3. Standard Elements

Build your UI using the Tab variable (e.g., `MainTab`).

### Section & Divider
```lua
MainTab:CreateSection("Main Category")
MainTab:CreateDivider()
```

### Label & Tooltip
```lua
local InfoLabel = MainTab:CreateLabel({
    Name = "Environment Status",
    Desc = "All modules are running normally",
    Icon = "check"
})

-- Attaching a Tooltip to the label
RanarthLib:CreateTooltip(InfoLabel.Frame, "Connected to the server with low latency.")

-- Update label dynamically
-- InfoLabel:Set("New Status Here")
```

### Button (With Lock & Dynamic Color Feature)
Create a standard button, lock it if needed, or dynamically change its background color for togglable modes (like a Builder Mode) without making it a standard UI Toggle switch. Supports `Color3.fromRGB` and `Color3.fromHex`.

```lua
local btn = MainTab:CreateButton({
    Name = "Execute Script",
    Icon = "rocket",
    Callback = function() 
        print("Clicked!")
    end
})

-- Lock the button (optional)
btn:Lock("Requires admin access")
-- btn:Unlock()

-- Dynamically Change Colors (e.g., inside the Callback function)
-- arg 1: Idle Color, arg 2: Hover Color
btn:SetColor(Color3.fromRGB(40, 200, 40), Color3.fromRGB(60, 220, 60))
-- Or use Hex: btn:SetColor(Color3.fromHex("#28C828"), Color3.fromHex("#3CDC3C"))

-- Revert to the default Space theme
-- btn:ResetColor()
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
    Increment = 0.1, 
    CurrentValue = 1.0,
    Flag = "s_ui_scale",
    Callback = function(Value) end
})
```

### Dropdown & Multi-Dropdown
```lua
MainTab:CreateDropdown({
    Name = "Select Game",
    Options = {"Arknights: Endfield", "Ananta", "Toram", "Tower of Fantasy"},
    CurrentValue = "Toram",
    Flag = "d_game",
    Callback = function(Value) end
})
```

### Input (TextBox) & Keybind
```lua
MainTab:CreateInput({
    Name = "Item ID",
    Placeholder = "Type here...",
    Callback = function(Text, EnterPressed) end
})

MainTab:CreateKeybind({
    Name = "Dash Forward",
    CurrentKey = Enum.KeyCode.F,
    Callback = function(Key) end
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

## 🎨 4. Visual & Extra Elements

### Log Terminal (Console)
A scrollable terminal interface directly inside your UI for displaying script logs, debugging info, or visual feedback. Supports auto-scrolling, timestamps, and memory-leak protection via line limiting.

```lua
local Terminal = MainTab:CreateConsole({
    Name = "SYSTEM LOGS",
    Height = 200,
    ShowTimestamp = true, -- Automatically prefixes logs with [HH:MM:SS]
    MaxLines = 200        -- Limits the maximum log entries to prevent memory leaks
})

Terminal:Print("Initializing system...")
Terminal:Print("Connected to server.", Color3.fromRGB(150, 150, 255)) -- Custom Color
Terminal:Warn("High latency detected.")
Terminal:Error("Failed to fetch asset ID: 12345678")
Terminal:Success("Payload injected successfully!")

-- Terminal:Clear() -- Clears the console history programmatically
```

### Image Panel (Item Preview)
A dedicated panel designed to display a thumbnail image alongside a title and description. Perfect for item previews or player info. If no image is provided, the image box disappears and the text stretches automatically!

```lua
local PreviewPanel = MainTab:CreateImagePanel({
    Title = "📦 Item Preview",
    Desc = "Enter an item ID below to view details.",
    Image = "search"
})

-- Update dynamically:
-- PreviewPanel:SetTitle("Dominus")
-- PreviewPanel:SetDesc("Price: 10,000 Robux")
-- PreviewPanel:SetImage("rbxthumb://type=Asset&id=12345678&w=150&h=150") 
-- PreviewPanel:SetImage("") -- Will automatically hide the image box!
```

### Progress Bar & Paragraph
```lua
local progress = MainTab:CreateProgressBar({
    Name = "Processing",
    Max = 100,
    CurrentValue = 45
})
-- progress:SetValue(80)

MainTab:CreateParagraph({
    Title = "Important Notes",
    Content = "Ensure all assets are loaded properly before running."
})
```

### Built-in Search Bar
Instantly adds a functional search bar to find elements within the current tab.
```lua
MainTab:CreateSearchBar({Placeholder = "Search features..."})
```

---

## 📦 5. Layouting (HStack & Group)

Group your elements cleanly or align them horizontally.

```lua
local MainGroup = MainTab:CreateGroup("Project Control")
local ButtonRow = MainGroup:CreateHStack()

ButtonRow:CreateButton({Name = "Button 1", Callback = function() end})
ButtonRow:CreateButton({Name = "Button 2", Callback = function() end})
```

---

## 🔔 6. Global Utilities

### Smart Notification (With Anti-Spam & Image Support)
Pop up a notification. Protected by Ranarth's Anti-Spam system (max 5 on screen, 0.15s cooldown). You can optionally pass an image/icon as the 4th argument!

```lua
-- Standard Text Notification
RanarthLib:CreateNotification("Warning", "Data synchronization complete.", 4)

-- Notification with an Icon or Image!
RanarthLib:CreateNotification("Purchase Successful", "Dominus Acquired", 4, "rbxthumb://type=Asset&id=12345678&w=150&h=150")
```

### Dialog Box (Modal)
Freezes background UI and asks for user confirmation.
```lua
Window:CreateDialog("Confirmation", "Are you sure you want to run this?", {
    { Title = "Yes", Callback = function() end },
    { Title = "No", Callback = function() end }
})
```

### SubPanel
Opens a small floating window docked next to the main GUI.
```lua
local sub = Window:CreateSubPanel("Additional Notes", 240, 200)
```

### Custom Floating Button
Create an independent, freely draggable floating button (retains Ranarth's glowing stroke theme) with memory-leak-safe dragging logic.
```lua
local myFloat = Window:CreateFloatingButton({
    Name = "Refresh: 0",
    Icon = "refresh-cw", 
    Callback = function() end
})
-- myFloat:Set("Refresh: 5")
```

---

## 🎭 7. Theme System

Ranarth GUI ships with **7 built-in themes** and a live theme-switching engine — every themed element updates instantly with a smooth color tween, no reload required.

**Available Themes:** `"Space"` (default), `"Sakura"`, `"Bloody Mary"`, `"Cyberpunk"`, `"Mystic Grimoire"`, `"Retro Y2K"`, `"Cake"`

**Set a default theme on load:**
```lua
local Window = RanarthLib:CreateWindow({
    Title = "Ranarth GUI | Developer Build",
    Theme = "Retro Y2K", -- Optional, defaults to "Space"
    -- ...other options
})
```

**Switch themes dynamically at runtime** (e.g., from a Dropdown callback):
```lua
MainTab:CreateDropdown({
    Name = "UI Theme",
    Options = {"Space", "Sakura", "Bloody Mary", "Cyberpunk", "Mystic Grimoire", "Retro Y2K", "Cake"},
    CurrentValue = "Space",
    Callback = function(Value)
        RanarthLib:SetTheme(Value)
    end
})
```

*💡 **Note:** Every element created with `RanarthLib:ApplyTheme()` internally auto-registers itself to the live theme engine, so custom elements will also re-color correctly on `SetTheme()`.*

---

## 💾 8. Configuration System & Unload

Automatically generates a UI section to save and load the `Flag` you set for elements. Fixed syntax compilation errors for smoother JSON loading.
```lua
SettingsTab:CreateConfigSystem()
```

Completely remove the UI and clean up all connections safely.
```lua
RanarthLib:Unload()
```
