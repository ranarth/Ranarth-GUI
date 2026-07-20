# 🌌 Ranarth GUI

A modern Roblox UI library focused on simplicity, customization, and performance.

---

## 📥 Installation

```lua
local Ranarth = loadstring(game:HttpGet("https://github.com/ranarth/Ranarth-GUI/releases/latest/download/main.lua"))()
```

---

## 🚀 Creating a Window

```lua
local Window = Ranarth.CreateWindow({
    Title = "Ranarth GUI Demo",
    Size = UDim2.fromOffset(580, 420)
})
```

---

## 📑 Creating Tabs

```lua
local MainTab = Window:CreateTab("Main")
local MiscTab = Window:CreateTab("Misc")
```

---

## 📌 Creating Sections

```lua
local CombatSection = MainTab:CreateSection("Combat")
```

---

## 🔘 Button

```lua
CombatSection:CreateButton({
    Name = "Print Hello",
    Callback = function()
        print("Hello!")
    end
})
```

---

## ✅ Toggle

```lua
CombatSection:CreateToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(Value)
        print(Value)
    end
})
```

---

## 🎚 Slider

```lua
CombatSection:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})
```

---

## 📋 Dropdown

```lua
CombatSection:CreateDropdown({
    Name = "Select Team",
    Options = {
        "Red",
        "Blue",
        "Green"
    },
    Callback = function(Value)
        print(Value)
    end
})
```

---

## ☑ Multi Dropdown

```lua
CombatSection:CreateMultiDropdown({
    Name = "Select Fruits",
    Options = {
        "Apple",
        "Banana",
        "Orange"
    },
    Callback = function(Selected)
        print(Selected)
    end
})
```

---

## 🔍 Search Bar

```lua
CombatSection:CreateSearchBar({
    Placeholder = "Search..."
})
```

---

## 📊 Progress Bar

```lua
local Progress = CombatSection:CreateProgressBar({
    Name = "Loading",
    Value = 50
})

Progress:SetValue(75)
```

---

## 📖 Paragraph

```lua
CombatSection:CreateParagraph({
    Title = "Information",
    Content = "This is a paragraph."
})
```

---

## 📄 Code Block

```lua
CombatSection:CreateCodeBlock({
    Language = "lua",
    Code = [[
print("Hello Ranarth GUI")
]]
})
```

---

## 📂 Group

```lua
local Group = CombatSection:CreateGroup("Settings")
```

---

## 📁 Sub Panel

```lua
local Panel = CombatSection:CreateSubPanel("Advanced")

Panel:CreateToggle(...)
Panel:CreateButton(...)
```

---

## 💬 Notification

```lua
Ranarth:Notify({
    Title = "Success",
    Content = "Loaded successfully!",
    Duration = 5
})
```

---

## 💡 Tooltip

```lua
Button:SetTooltip("Click to execute.")
```

---

## ⚠ Dialog

```lua
Ranarth:Dialog({
    Title = "Confirmation",
    Content = "Continue?",
    Buttons = {
        {
            Name = "Yes",
            Callback = function()

            end
        },
        {
            Name = "No"
        }
    }
})
```

---

# 📚 API Reference

| Feature | Supported |
|----------|-----------|
| Window | ✅ |
| Tabs | ✅ |
| Section | ✅ |
| Button | ✅ |
| Toggle | ✅ |
| Slider | ✅ |
| Dropdown | ✅ |
| Multi Dropdown | ✅ |
| Search Bar | ✅ |
| Divider | ✅ |
| Paragraph | ✅ |
| Progress Bar | ✅ |
| Code Block | ✅ |
| Group | ✅ |
| HStack | ✅ |
| Sub Panel | ✅ |
| Notification | ✅ |
| Tooltip | ✅ |
| Dialog | ✅ |

---

# ❤️ Credits

Made with ❤️ by **Ranarth**
