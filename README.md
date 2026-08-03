# Ranarth GUI Library

Ranarth GUI is a clean, modern, and highly flexible Custom UI Library for Roblox. It is perfectly suited for building game plugins or executing scripts, equipped with an automatic Config system, dynamic Layouting (Group & HStack), an Image Panel for previews, Smart Anti-Spam Notifications, and optimized animations.

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

## 📑 2. Tabs & Hybrid Icon System

Tabs organize your features. Ranarth GUI features a **Hybrid Icon System**: it comes with 110+ built-in icons for instant loading, while seamlessly fetching future icons directly from your external GitHub repository.

**How to Use Icons (Supports any element with an `Icon` or `Image` property):**
1. **Built-in Names:** Type names like `"home"`, `"settings"`, `"rocket"`, `"gamepad"`, `"sword"`, etc.
2. **Roblox Asset IDs & Thumbnails:** Paste a Roblox image ID directly (e.g., `"rbxassetid://123456789"`). The GUI also fully supports case-sensitive thumbnail APIs like `"rbxthumb://type=Asset&id=12345678&w=150&h=150"` and external web URLs (`http://`/`https://`). The system is smart enough to preserve the original colors of these standard images while properly tinting Lucide icons.

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

### Button (With Lock Feature)
```lua
local btn = MainTab:CreateButton({
    Name = "Execute Script",
    Icon = "rocket",
    Callback = function() end
})

-- Lock the button (optional)
btn:Lock("Requires admin access")
-- btn:Unlock()
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

### Image Panel (Item Preview) - **NEW**
A dedicated panel designed to display a thumbnail image alongside a title and description. Perfect for item previews or player info. If no image is provided, the image box disappears and the text stretches automatically!

```lua
local PreviewPanel = MainTab:CreateImagePanel({
    Title = "📦 Item Preview",
    Desc = "Enter an item ID below to view details.",
    Image = "search" -- You can use built-in icons, rbxassetid://, or rbxthumb://
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
Create an independent, freely draggable floating button (retains Ranarth's glowing stroke theme).
```lua
local myFloat = Window:CreateFloatingButton({
    Name = "Refresh: 0",
    Icon = "refresh-cw", 
    Callback = function() end
})
-- myFloat:Set("Refresh: 5")
```

---

## 💾 7. Configuration System & Unload

Automatically generates a UI section to save and load the `Flag` you set for elements.
```lua
SettingsTab:CreateConfigSystem()
```

Completely remove the UI and all connections.
```lua
RanarthLib:Unload()
```
