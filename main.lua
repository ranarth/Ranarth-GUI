local plrs = game:GetService("Players")
local runs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local tweens = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local lp = plrs.LocalPlayer
local core_gui = runs:IsStudio() and lp:WaitForChild("PlayerGui") or (gethui and gethui() or game:GetService("CoreGui"))

local RanarthLib = {
    Connections = {},
    Flags = {},
    ConfigFolder = "Ranarth GUI",
    ConfigFileName = "default",
    AutoSaveEnabled = false,
    ScreenGuis = {}
}

-- ==========================================
-- 1. TRACKING & CLEANUP SYSTEM
-- ==========================================
function RanarthLib:TrackConnection(conn)
    table.insert(self.Connections, conn)
    return conn
end

function RanarthLib:SafeUIS(event, guiElement, callback)
    local conn
    conn = event:Connect(function(...)
        if not guiElement or not guiElement.Parent then
            if conn then conn:Disconnect() end
            return
        end
        callback(...)
    end)
    return self:TrackConnection(conn)
end

function RanarthLib:Unload()
    for _, conn in ipairs(self.Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    self.Connections = {}
    
    for _, guiObj in ipairs(self.ScreenGuis) do
        if guiObj and guiObj.Parent then
            guiObj:Destroy()
        end
    end
    self.ScreenGuis = {}
    self.Flags = {}
end

-- ==========================================
-- 2. GLOBAL ANIMATIONS & STROKES
-- ==========================================
local allGrads = {}
local RANARTH_STROKE_CS = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 44, 75)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 150, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 255, 255)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(100, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(38, 44, 75)),
})

local function animStroke(parent, thick)
    local s = Instance.new("UIStroke")
    s.Thickness = thick or 1.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = Color3.new(1, 1, 1)
    s.Parent = parent
    local g = Instance.new("UIGradient")
    g.Color = RANARTH_STROKE_CS
    g.Rotation = 45
    g.Parent = s
    table.insert(allGrads, g)
    return s, g
end

local function staticStroke(parent, thick)
    local s = Instance.new("UIStroke")
    s.Thickness = thick or 1.2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = Color3.fromRGB(38, 44, 75)
    s.Parent = parent
    return s
end

RanarthLib:TrackConnection(runs.RenderStepped:Connect(function()
    local off = Vector2.new(math.sin(tick() * 2.8), 0)
    for i = #allGrads, 1, -1 do
        local g = allGrads[i]
        if g and g.Parent then 
            g.Offset = off 
        else
            table.remove(allGrads, i) 
        end
    end
end))

-- ==========================================
-- 3. ICON & ASSET HELPER (External Module)
-- ==========================================
local LucideIcons = {}

-- Load the icon database from GitHub dynamically and safely
local success, result = pcall(function()
    -- Ensure this URL points to the "Raw" link of your LucideIcons.lua file in your repository
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ranarth/Ranarth-GUI/refs/heads/Icons/LucideIcons.lua"))()
end)

if success and type(result) == "table" then
    LucideIcons = result
else
    warn("Ranarth GUI: Failed to load external icon database. Fallback to manual ID mode (icons.rest) activated.")
end

local function applyIcon(parent, iconData)
    if not iconData or iconData == "" then return nil end
    
    local strData = tostring(iconData):lower()
    
    -- Smart Logic: Check the external table FIRST. 
    -- If not found, assume the user inputted an ID number directly from icons.rest
    local assetUrl = LucideIcons[strData] or (strData:find("rbxassetid://") and iconData or ("rbxassetid://" .. strData))
    
    local img = Instance.new("ImageLabel")
    img.Name = "Icon"
    img.Size = UDim2.new(0, 16, 0, 16)
    img.BackgroundTransparency = 1
    img.Image = assetUrl
    img.ImageColor3 = Color3.fromRGB(200, 210, 255)
    img.Parent = parent
    
    return img
end

-- ==========================================
-- 4. SETUP NOTIFICATION & TOOLTIP (Global)
-- ==========================================
local notif_gui = Instance.new("ScreenGui")
notif_gui.Name = "RanarthNotifications"
notif_gui.ResetOnSpawn = false
notif_gui.DisplayOrder = 100
notif_gui.Parent = core_gui
table.insert(RanarthLib.ScreenGuis, notif_gui)

local notif_container = Instance.new("Frame")
notif_container.Size = UDim2.new(0, 260, 1, -20)
notif_container.Position = UDim2.new(1, -280, 0, 10)
notif_container.BackgroundTransparency = 1
notif_container.Parent = notif_gui

local notif_layout = Instance.new("UIListLayout", notif_container)
notif_layout.SortOrder = Enum.SortOrder.LayoutOrder
notif_layout.Padding = UDim.new(0, 8)
notif_layout.VerticalAlignment = Enum.VerticalAlignment.Top
notif_layout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local tooltip_gui = Instance.new("ScreenGui")
tooltip_gui.Name = "RanarthTooltip"
tooltip_gui.ResetOnSpawn = false
tooltip_gui.DisplayOrder = 1000
tooltip_gui.Parent = core_gui
table.insert(RanarthLib.ScreenGuis, tooltip_gui)

local tooltipLabel = Instance.new("TextLabel")
tooltipLabel.Size = UDim2.new(0, 160, 0, 26)
tooltipLabel.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
tooltipLabel.TextColor3 = Color3.fromRGB(220, 225, 255)
tooltipLabel.Font = Enum.Font.Gotham
tooltipLabel.TextSize = 11
tooltipLabel.RichText = true
tooltipLabel.TextWrapped = true
tooltipLabel.Visible = false
tooltipLabel.ZIndex = 100
tooltipLabel.Parent = tooltip_gui
Instance.new("UICorner", tooltipLabel).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", tooltipLabel).Color = Color3.fromRGB(38, 44, 75)

function RanarthLib:CreateNotification(title, text, duration)
    duration = duration or 4
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 250, 0, 60)
    card.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
    card.BackgroundTransparency = 1
    card.ClipsDescendants = true
    card.Parent = notif_container
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    staticStroke(card, 1.2)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 20)
    titleLbl.Position = UDim2.new(0, 10, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title or "Notification"
    titleLbl.TextColor3 = Color3.fromRGB(220, 225, 255)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.RichText = true
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTransparency = 1
    titleLbl.Parent = card

    local bodyLbl = Instance.new("TextLabel")
    bodyLbl.Size = UDim2.new(1, -20, 0, 30)
    bodyLbl.Position = UDim2.new(0, 10, 0, 26)
    bodyLbl.BackgroundTransparency = 1
    bodyLbl.Text = text or ""
    bodyLbl.TextColor3 = Color3.fromRGB(200, 210, 255)
    bodyLbl.Font = Enum.Font.Gotham
    bodyLbl.TextSize = 12
    bodyLbl.RichText = true
    bodyLbl.TextWrapped = true
    bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
    bodyLbl.TextYAlignment = Enum.TextYAlignment.Top
    bodyLbl.TextTransparency = 1
    bodyLbl.Parent = card

    tweens:Create(card, TweenInfo.new(0.25), {BackgroundTransparency = 0.1}):Play()
    tweens:Create(titleLbl, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
    tweens:Create(bodyLbl, TweenInfo.new(0.25), {TextTransparency = 0}):Play()

    task.spawn(function()
        task.wait(duration)
        tweens:Create(card, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        tweens:Create(titleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        local fadeOut = tweens:Create(bodyLbl, TweenInfo.new(0.3), {TextTransparency = 1})
        fadeOut:Play()
        fadeOut.Completed:Wait()
        card:Destroy()
    end)
end

function RanarthLib:CreateTooltip(target, text)
    target.MouseEnter:Connect(function()
        tooltipLabel.Text = "  " .. text
        tooltipLabel.Visible = true
    end)
    target.MouseMoved:Connect(function(x, y)
        tooltipLabel.Position = UDim2.new(0, x + 15, 0, y + 15)
    end)
    target.MouseLeave:Connect(function()
        tooltipLabel.Visible = false
    end)
end

-- ==========================================
-- 5. WINDOW CONSTRUCTOR & KEYBIND TOGGLE
-- ==========================================
function RanarthLib:CreateWindow(HubConfig)
    HubConfig = HubConfig or {}
    local Title = HubConfig.Title or "Ranarth GUI"
    local DefWidth = HubConfig.DefaultWidth or 500
    local DefHeight = HubConfig.DefaultHeight or 320
    local MinWidth = HubConfig.MinWidth or 400
    local MinHeight = HubConfig.MinHeight or 250
    local TabPosition = HubConfig.TabPosition or "Top" 
    local ToggleKey = HubConfig.ToggleKey or HubConfig.Keybind or nil

    if HubConfig.ConfigurationSaving then
        RanarthLib.AutoSaveEnabled = HubConfig.ConfigurationSaving.Enabled or false
        RanarthLib.ConfigFolder = HubConfig.ConfigurationSaving.FolderName or RanarthLib.ConfigFolder
        RanarthLib.ConfigFileName = HubConfig.ConfigurationSaving.FileName or RanarthLib.ConfigFileName
    end

    local Window = { Tabs = {}, ActiveTabBtn = nil }

    local gui = Instance.new("ScreenGui")
    gui.Name = "RanarthHub_" .. tostring(math.random(1000, 9999))
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
    gui.Parent = core_gui
    gui.ResetOnSpawn = false
    table.insert(RanarthLib.ScreenGuis, gui)
    Window.Gui = gui

    local frame = Instance.new("Frame")
    frame.Name = "Main"
    frame.Size = UDim2.new(0, DefWidth, 0, DefHeight)
    frame.Position = UDim2.new(0.5, -(DefWidth/2), 0.5, -(DefHeight/2))
    frame.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ClipsDescendants = true 
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    animStroke(frame, 1.5)

    -- Handle Global Toggle Keybind
    if ToggleKey then
        RanarthLib:TrackConnection(uis.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == ToggleKey then
                frame.Visible = not frame.Visible
            end
        end))
    end

    local top_bar = Instance.new("Frame")
    top_bar.Size = UDim2.new(1, 0, 0, 35)
    top_bar.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
    top_bar.BorderSizePixel = 0
    top_bar.Parent = frame
    Instance.new("UICorner", top_bar).CornerRadius = UDim.new(0, 10)

    local title_txt = Instance.new("TextLabel")
    title_txt.Size = UDim2.new(1, -65, 1, 0)
    title_txt.Position = UDim2.new(0, 15, 0, 0)
    title_txt.BackgroundTransparency = 1
    title_txt.Text = Title
    title_txt.TextColor3 = Color3.fromRGB(220, 225, 255)
    title_txt.Font = Enum.Font.GothamBold
    title_txt.TextSize = 12
    title_txt.RichText = true
    title_txt.TextXAlignment = Enum.TextXAlignment.Left
    title_txt.Parent = top_bar

    local control_buttons = Instance.new("Frame")
    control_buttons.Size = UDim2.new(0, 60, 1, 0)
    control_buttons.Position = UDim2.new(1, -65, 0, 0)
    control_buttons.BackgroundTransparency = 1
    control_buttons.Parent = top_bar
    local control_layout = Instance.new("UIListLayout", control_buttons)
    control_layout.FillDirection = Enum.FillDirection.Horizontal
    control_layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    control_layout.VerticalAlignment = Enum.VerticalAlignment.Center
    control_layout.Padding = UDim.new(0, 5)

    local t_gui = Instance.new("ScreenGui")
    t_gui.Name = "RanarthMinimizeBtn_" .. tostring(math.random(1000, 9999))
    t_gui.Parent = core_gui
    t_gui.Enabled = false 
    table.insert(RanarthLib.ScreenGuis, t_gui)
    
    local t_btn = Instance.new("TextButton")
    t_btn.Size = UDim2.new(0, 45, 0, 45)
    t_btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    t_btn.BackgroundTransparency = 0.65 
    t_btn.Text = "TAP"
    t_btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    t_btn.Font = Enum.Font.GothamBlack
    t_btn.TextSize = 16
    t_btn.Parent = t_gui
    Instance.new("UICorner", t_btn).CornerRadius = UDim.new(1, 0) 
    animStroke(t_btn, 1.5)

    local function create_header_btn(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 24, 0, 24)
        btn.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
        btn.Text = text
        btn.TextColor3 = color
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = control_buttons
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseEnter:Connect(function() tweens:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 40, 55)}):Play() end)
        btn.MouseLeave:Connect(function() tweens:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 28, 40)}):Play() end)
        btn.MouseButton1Click:Connect(callback)
    end

    create_header_btn("-", Color3.fromRGB(200, 200, 200), function()
        frame.Visible = false
        t_btn.Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset + frame.Size.X.Offset - 45, frame.Position.Y.Scale, frame.Position.Y.Offset)
        t_gui.Enabled = true 
    end)
    
    create_header_btn("X", Color3.fromRGB(255, 80, 80), function()
        RanarthLib:Unload()
    end)

    -- Safe UI Dragging Logic
    local drag, drag_in, start_drag, start_pos
    top_bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true; start_drag = input.Position; start_pos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    top_bar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then drag_in = input end
    end)
    RanarthLib:SafeUIS(uis.InputChanged, frame, function(input)
        if input == drag_in and drag then
            local offset = input.Position - start_drag
            frame.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + offset.X, start_pos.Y.Scale, start_pos.Y.Offset + offset.Y)
        end
    end)

    -- Floating "TAP" button: drag it around + tap to reopen the main panel
    local dragToggle, dragInputToggle, dragStartPos, startBtnPos, hasDragged = false, nil, nil, nil, false
    RanarthLib:TrackConnection(t_btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true; hasDragged = false; dragStartPos = input.Position; startBtnPos = t_btn.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
        end
    end))
    RanarthLib:TrackConnection(t_btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputToggle = input end
    end))
    RanarthLib:SafeUIS(uis.InputChanged, t_btn, function(input)
        if input == dragInputToggle and dragToggle then
            local delta = input.Position - dragStartPos
            if delta.Magnitude > 5 then hasDragged = true end
            t_btn.Position = UDim2.new(startBtnPos.X.Scale, startBtnPos.X.Offset + delta.X, startBtnPos.Y.Scale, startBtnPos.Y.Offset + delta.Y)
        end
    end)
    RanarthLib:TrackConnection(t_btn.MouseButton1Click:Connect(function()
        if hasDragged then return end
        frame.Position = UDim2.new(t_btn.Position.X.Scale, t_btn.Position.X.Offset - frame.Size.X.Offset + 45, t_btn.Position.Y.Scale, t_btn.Position.Y.Offset)
        frame.Visible = true; t_gui.Enabled = false
        t_btn.Size = UDim2.new(0, 45, 0, 45)
    end))

    local watermark = Instance.new("TextLabel")
    watermark.Size = UDim2.new(0, 150, 0, 15)
    watermark.Position = UDim2.new(0, 10, 1, -20)
    watermark.BackgroundTransparency = 1
    watermark.Text = "Ranarth GUI @2026"
    watermark.TextColor3 = Color3.fromRGB(130, 140, 180)
    watermark.TextTransparency = 0.4
    watermark.Font = Enum.Font.Gotham
    watermark.TextSize = 10
    watermark.TextXAlignment = Enum.TextXAlignment.Left
    watermark.ZIndex = 5
    watermark.Parent = frame

    local resizer = Instance.new("TextButton")
    resizer.Size = UDim2.new(0, 20, 0, 20)
    resizer.Position = UDim2.new(1, -20, 1, -20)
    resizer.BackgroundTransparency = 1
    resizer.Text = "◢"
    resizer.TextColor3 = Color3.fromRGB(130, 140, 180)
    resizer.TextSize = 14
    resizer.Font = Enum.Font.Gotham
    resizer.ZIndex = 10
    resizer.Parent = frame

    local resizing, rs_start_pos, rs_start_size = false
    RanarthLib:TrackConnection(resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true; rs_start_pos = input.Position; rs_start_size = frame.AbsoluteSize
        end
    end))
    RanarthLib:SafeUIS(uis.InputChanged, frame, function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - rs_start_pos
            local newWidth = math.clamp(rs_start_size.X + delta.X, MinWidth, 1200)
            local newHeight = math.clamp(rs_start_size.Y + delta.Y, MinHeight, 800)
            frame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
    RanarthLib:SafeUIS(uis.InputEnded, frame, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
    end)

    local tab_container = Instance.new("ScrollingFrame")
    tab_container.BackgroundTransparency = 1
    tab_container.ScrollBarThickness = 0
    tab_container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tab_container.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab_container.ClipsDescendants = true
    tab_container.Parent = frame
    
    local tab_layout = Instance.new("UIListLayout", tab_container)
    tab_layout.SortOrder = Enum.SortOrder.LayoutOrder
    tab_layout.Padding = UDim.new(0, 10)

    local content_container = Instance.new("Frame")
    content_container.BackgroundTransparency = 1
    content_container.ClipsDescendants = true
    content_container.Parent = frame

    if TabPosition == "Left" then
        tab_container.Size = UDim2.new(0, 120, 1, -55)
        tab_container.Position = UDim2.new(0, 10, 0, 45)
        tab_layout.FillDirection = Enum.FillDirection.Vertical
        
        local tab_divider = Instance.new("Frame", frame)
        tab_divider.Size = UDim2.new(0, 1, 1, -55)
        tab_divider.Position = UDim2.new(0, 135, 0, 45)
        tab_divider.BackgroundColor3 = Color3.fromRGB(38, 44, 75)
        tab_divider.BorderSizePixel = 0

        content_container.Size = UDim2.new(1, -155, 1, -55)
        content_container.Position = UDim2.new(0, 145, 0, 45)
    else
        tab_container.Size = UDim2.new(1, -20, 0, 35)
        tab_container.Position = UDim2.new(0, 10, 0, 45)
        tab_layout.FillDirection = Enum.FillDirection.Horizontal

        local tab_divider = Instance.new("Frame", frame)
        tab_divider.Size = UDim2.new(1, -20, 0, 1)
        tab_divider.Position = UDim2.new(0, 10, 0, 82)
        tab_divider.BackgroundColor3 = Color3.fromRGB(38, 44, 75)
        tab_divider.BorderSizePixel = 0

        content_container.Size = UDim2.new(1, -20, 1, -95)
        content_container.Position = UDim2.new(0, 10, 0, 85)
    end

    -- ==========================================
    -- DIALOG / MODAL SYSTEM
    -- ==========================================
    function Window:CreateDialog(title, text, options)
        options = options or {}
        local overlay = Instance.new("Frame", gui)
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundTransparency = 1
        overlay.Active = true 
        overlay.ZIndex = 9999

        local dialogBox = Instance.new("Frame", overlay)
        dialogBox.Size = UDim2.new(0, 320, 0, 0)
        dialogBox.Position = UDim2.new(0.5, 0, 0.5, 20)
        dialogBox.AnchorPoint = Vector2.new(0.5, 0.5)
        dialogBox.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
        dialogBox.BackgroundTransparency = 1
        dialogBox.ClipsDescendants = true
        dialogBox.Active = true 
        Instance.new("UICorner", dialogBox).CornerRadius = UDim.new(0, 8)
        staticStroke(dialogBox, 1.5)

        local dLayout = Instance.new("UIListLayout", dialogBox)
        dLayout.SortOrder = Enum.SortOrder.LayoutOrder
        dLayout.Padding = UDim.new(0, 10)
        dLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        local padding = Instance.new("UIPadding", dialogBox)
        padding.PaddingTop = UDim.new(0, 15)
        padding.PaddingBottom = UDim.new(0, 15)
        padding.PaddingLeft = UDim.new(0, 15)
        padding.PaddingRight = UDim.new(0, 15)

        local lblTitle = Instance.new("TextLabel", dialogBox)
        lblTitle.Size = UDim2.new(1, 0, 0, 20)
        lblTitle.BackgroundTransparency = 1
        lblTitle.Text = title
        lblTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        lblTitle.Font = Enum.Font.GothamBold
        lblTitle.TextSize = 16
        lblTitle.RichText = true
        lblTitle.TextTransparency = 1

        local lblText = Instance.new("TextLabel", dialogBox)
        lblText.Size = UDim2.new(1, 0, 0, 0)
        lblText.AutomaticSize = Enum.AutomaticSize.Y
        lblText.BackgroundTransparency = 1
        lblText.Text = text
        lblText.TextColor3 = Color3.fromRGB(200, 210, 255)
        lblText.Font = Enum.Font.Gotham
        lblText.TextSize = 13
        lblText.RichText = true
        lblText.TextWrapped = true
        lblText.TextTransparency = 1

        local btnContainer = Instance.new("Frame", dialogBox)
        btnContainer.Size = UDim2.new(1, 0, 0, 35)
        btnContainer.BackgroundTransparency = 1
        
        local btnLayout = Instance.new("UIListLayout", btnContainer)
        btnLayout.FillDirection = Enum.FillDirection.Horizontal
        btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        btnLayout.Padding = UDim.new(0, 10)

        local function closeDialog()
            local shrink = tweens:Create(dialogBox, TweenInfo.new(0.2), {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 20)})
            lblTitle.TextTransparency = 1; lblText.TextTransparency = 1
            for _, child in ipairs(btnContainer:GetChildren()) do
                if child:IsA("TextButton") then child.BackgroundTransparency = 1; child.TextTransparency = 1 end
            end
            shrink:Play()
            shrink.Completed:Wait()
            overlay:Destroy()
        end

        for _, opt in ipairs(options) do
            local btn = Instance.new("TextButton", btnContainer)
            btn.Size = UDim2.new(1 / #options, -10, 1, 0)
            btn.BackgroundColor3 = Color3.fromRGB(35, 40, 70)
            btn.Text = opt.Title
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 12
            btn.RichText = true
            btn.BackgroundTransparency = 1
            btn.TextTransparency = 1
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            btn.MouseEnter:Connect(function() tweens:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 60, 90)}):Play() end)
            btn.MouseLeave:Connect(function() tweens:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 40, 70)}):Play() end)

            btn.MouseButton1Click:Connect(function()
                closeDialog()
                if opt.Callback then opt.Callback() end
            end)
        end

        dLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            dialogBox.Size = UDim2.new(0, 320, 0, dLayout.AbsoluteContentSize.Y + 30)
        end)

        tweens:Create(dialogBox, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        lblTitle.TextTransparency = 0; lblText.TextTransparency = 0
        for _, child in ipairs(btnContainer:GetChildren()) do
            if child:IsA("TextButton") then child.BackgroundTransparency = 0; child.TextTransparency = 0 end
        end
    end

    function Window:CreateSubPanel(name, width, height)
        width = width or 260
        height = height or 320

        local subFrame = Instance.new("Frame", gui)
        subFrame.Size = UDim2.new(0, width, 0, height)
        subFrame.Position = UDim2.new(0.5, (DefWidth/2) + 20, 0.5, -(height/2))
        subFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
        subFrame.BorderSizePixel = 0
        subFrame.Active = true
        subFrame.ClipsDescendants = true
        Instance.new("UICorner", subFrame).CornerRadius = UDim.new(0, 10)
        animStroke(subFrame, 1.5)

        local sub_top_bar = Instance.new("Frame", subFrame)
        sub_top_bar.Size = UDim2.new(1, 0, 0, 30)
        sub_top_bar.BackgroundColor3 = Color3.fromRGB(14, 20, 40)
        sub_top_bar.BorderSizePixel = 0
        Instance.new("UICorner", sub_top_bar).CornerRadius = UDim.new(0, 10)

        local subTitle = Instance.new("TextLabel", sub_top_bar)
        subTitle.Text = name
        subTitle.Size = UDim2.new(1, -65, 1, 0)
        subTitle.Position = UDim2.new(0, 10, 0, 0)
        subTitle.BackgroundTransparency = 1
        subTitle.TextColor3 = Color3.new(1, 1, 1)
        subTitle.Font = Enum.Font.GothamBold
        subTitle.TextSize = 10
        subTitle.TextXAlignment = Enum.TextXAlignment.Left

        local sub_control_buttons = Instance.new("Frame", sub_top_bar)
        sub_control_buttons.Size = UDim2.new(0, 60, 1, 0)
        sub_control_buttons.Position = UDim2.new(1, -65, 0, 0)
        sub_control_buttons.BackgroundTransparency = 1
        local sub_control_layout = Instance.new("UIListLayout", sub_control_buttons)
        sub_control_layout.FillDirection = Enum.FillDirection.Horizontal
        sub_control_layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        sub_control_layout.VerticalAlignment = Enum.VerticalAlignment.Center
        sub_control_layout.Padding = UDim.new(0, 5)

        local isMinimized = false
        local minBtn = Instance.new("TextButton", sub_control_buttons)
        minBtn.Size = UDim2.new(0, 24, 0, 24)
        minBtn.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
        minBtn.Text = "-"
        minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        minBtn.Font = Enum.Font.GothamBold
        minBtn.TextSize = 12
        Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)
        RanarthLib:TrackConnection(minBtn.MouseEnter:Connect(function() tweens:Create(minBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 40, 55)}):Play() end))
        RanarthLib:TrackConnection(minBtn.MouseLeave:Connect(function() tweens:Create(minBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 28, 40)}):Play() end))
        RanarthLib:TrackConnection(minBtn.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            tweens:Create(subFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, width, 0, isMinimized and 30 or height)}):Play()
        end))

        local clsBtn = Instance.new("TextButton", sub_control_buttons)
        clsBtn.Size = UDim2.new(0, 24, 0, 24)
        clsBtn.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
        clsBtn.Text = "X"
        clsBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
        clsBtn.Font = Enum.Font.GothamBold
        clsBtn.TextSize = 12
        Instance.new("UICorner", clsBtn).CornerRadius = UDim.new(0, 4)
        RanarthLib:TrackConnection(clsBtn.MouseEnter:Connect(function() tweens:Create(clsBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 30, 40)}):Play() end))
        RanarthLib:TrackConnection(clsBtn.MouseLeave:Connect(function() tweens:Create(clsBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 28, 40)}):Play() end))
        RanarthLib:TrackConnection(clsBtn.MouseButton1Click:Connect(function() subFrame:Destroy() end))

        local tDrag, tDragStart, tStartPos, dragInputToggle
        RanarthLib:TrackConnection(sub_top_bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                tDrag = true; tDragStart = input.Position; tStartPos = subFrame.Position
            end
        end))
        RanarthLib:TrackConnection(sub_top_bar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInputToggle = input
            end
        end))
        RanarthLib:SafeUIS(uis.InputChanged, subFrame, function(input)
            if input == dragInputToggle and tDrag then
                local delta = input.Position - tDragStart
                subFrame.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
            end
        end)
        RanarthLib:SafeUIS(uis.InputEnded, subFrame, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                tDrag = false
            end
        end)

        local subScroll = Instance.new("ScrollingFrame", subFrame)
        subScroll.Size = UDim2.new(1, -10, 1, -40)
        subScroll.Position = UDim2.new(0, 5, 0, 35)
        subScroll.BackgroundTransparency = 1
        subScroll.ScrollBarThickness = 2
        local subLayout = Instance.new("UIListLayout", subScroll)
        subLayout.SortOrder = Enum.SortOrder.LayoutOrder
        subLayout.Padding = UDim.new(0, 5)
        RanarthLib:TrackConnection(subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            subScroll.CanvasSize = UDim2.new(0, 0, 0, subLayout.AbsoluteContentSize.Y + 10)
        end))

        return subScroll
    end

    function Window:CreateTab(args)
        local tabName = type(args) == "table" and (args.Name or args.Title) or args
        local tabIcon = type(args) == "table" and args.Icon or nil
        
        local Tab = { Container = nil }
        
        local tabBtn = Instance.new("TextButton")
        if TabPosition == "Left" then
            tabBtn.Size = UDim2.new(1, 0, 0, 32)
        else
            tabBtn.Size = UDim2.new(0, 100, 1, 0)
        end
        tabBtn.BackgroundColor3 = Color3.fromRGB(22, 26, 44)
        tabBtn.Text = (tabIcon and "   " or "") .. tabName
        tabBtn.TextColor3 = Color3.fromRGB(130, 140, 180)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 12
        tabBtn.RichText = true
        tabBtn.AutoButtonColor = false
        tabBtn.Parent = tab_container
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
        staticStroke(tabBtn, 1.2)

        if tabIcon then
            local iconImg = applyIcon(tabBtn, tabIcon)
            if iconImg then
                iconImg.Position = UDim2.new(0, 8, 0.5, -8)
            end
        end

        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 4
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(38, 44, 75)
        scrollFrame.Visible = false
        scrollFrame.Parent = content_container
        
        Tab.Container = scrollFrame
        
        local scrollPad = Instance.new("UIPadding", scrollFrame)
        scrollPad.PaddingTop = UDim.new(0, 2)
        scrollPad.PaddingBottom = UDim.new(0, 2)
        scrollPad.PaddingLeft = UDim.new(0, 2)
        scrollPad.PaddingRight = UDim.new(0, 12)
        
        local scrollLayout = Instance.new("UIListLayout", scrollFrame)
        scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
        scrollLayout.Padding = UDim.new(0, 8)
        
        scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 10)
        end)

        tabBtn.MouseButton1Click:Connect(function()
            if Window.ActiveTabBtn == tabBtn then return end
            for btn, frm in pairs(Window.Tabs) do
                frm.Visible = false
                tweens:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 26, 44), TextColor3 = Color3.fromRGB(130, 140, 180)}):Play()
            end
            scrollFrame.Visible = true
            tweens:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 40, 70), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            Window.ActiveTabBtn = tabBtn
        end)

        Window.Tabs[tabBtn] = scrollFrame
        
        if not Window.ActiveTabBtn then
            scrollFrame.Visible = true
            tabBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 70)
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Window.ActiveTabBtn = tabBtn
        end

        -- ==========================================
        -- UI BUILDER WRAPPER
        -- ==========================================
        local function BuildElements(targetParent)
            local Elements = {}

            local function ApplyFlex(element)
                if targetParent:IsA("GuiObject") and targetParent:FindFirstChild("UIListLayout") and targetParent.UIListLayout.FillDirection == Enum.FillDirection.Horizontal then
                    local flex = Instance.new("UIFlexItem", element)
                    flex.FlexMode = Enum.UIFlexMode.Fill
                end
            end

            local function CreateElementBase(args, height)
                args = args or {}
                local titleText = args.Name or args.Title or "Element"
                local descText = args.Description or args.Desc or nil
                local iconData = args.Icon or nil

                height = descText and (height + 12) or height

                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, height)
                frame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
                frame.Parent = targetParent
                Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
                staticStroke(frame, 1.2)
                ApplyFlex(frame)

                local xOffset = 10
                if iconData then
                    local img = applyIcon(frame, iconData)
                    if img then
                        img.Position = UDim2.new(0, 10, 0, 10)
                        xOffset = 32
                    end
                end

                local titleLbl = Instance.new("TextLabel")
                titleLbl.Size = UDim2.new(1, -(xOffset + 10), 0, 20)
                titleLbl.Position = UDim2.new(0, xOffset, 0, descText and 4 or (height/2 - 10))
                titleLbl.BackgroundTransparency = 1
                titleLbl.Text = titleText
                titleLbl.TextColor3 = Color3.fromRGB(200, 210, 255)
                titleLbl.Font = Enum.Font.GothamBold
                titleLbl.TextSize = 12
                titleLbl.RichText = true
                titleLbl.TextXAlignment = Enum.TextXAlignment.Left
                titleLbl.Parent = frame

                local descLbl = nil
                if descText then
                    descLbl = Instance.new("TextLabel")
                    descLbl.Size = UDim2.new(1, -(xOffset + 10), 0, 15)
                    descLbl.Position = UDim2.new(0, xOffset, 0, 22)
                    descLbl.BackgroundTransparency = 1
                    descLbl.Text = descText
                    descLbl.TextColor3 = Color3.fromRGB(140, 150, 190)
                    descLbl.Font = Enum.Font.Gotham
                    descLbl.TextSize = 10
                    descLbl.RichText = true
                    descLbl.TextXAlignment = Enum.TextXAlignment.Left
                    descLbl.Parent = frame
                end

                -- Lock Overlay Frame
                local lockOverlay = Instance.new("Frame", frame)
                lockOverlay.Size = UDim2.new(1, 0, 1, 0)
                lockOverlay.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
                lockOverlay.BackgroundTransparency = 0.3
                lockOverlay.Visible = false
                lockOverlay.ZIndex = 10
                Instance.new("UICorner", lockOverlay).CornerRadius = UDim.new(0, 6)

                local lockLbl = Instance.new("TextLabel", lockOverlay)
                lockLbl.Size = UDim2.new(1, -20, 1, 0)
                lockLbl.Position = UDim2.new(0, 10, 0, 0)
                lockLbl.BackgroundTransparency = 1
                lockLbl.Text = "🔒 Locked"
                lockLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
                lockLbl.Font = Enum.Font.GothamBold
                lockLbl.TextSize = 11
                lockLbl.RichText = true

                local ControlObj = {
                    Frame = frame,
                    SetVisible = function(self, vis) frame.Visible = vis end,
                    Lock = function(self, reason)
                        lockLbl.Text = "🔒 " .. (reason or "Locked")
                        lockOverlay.Visible = true
                    end,
                    Unlock = function(self) lockOverlay.Visible = false end,
                    SetTitle = function(self, newTitle) titleLbl.Text = newTitle end,
                    SetDesc = function(self, newDesc)
                        if descLbl then descLbl.Text = newDesc end
                    end
                }

                return frame, titleLbl, descLbl, ControlObj
            end

            function Elements:CreateSection(args)
                local secName = type(args) == "table" and (args.Name or args.Title) or args
                local secIcon = type(args) == "table" and args.Icon or nil

                local sFrame = Instance.new("Frame", targetParent)
                sFrame.Size = UDim2.new(1, 0, 0, 20)
                sFrame.BackgroundTransparency = 1
                ApplyFlex(sFrame)

                local xOff = 0
                if secIcon then
                    local img = applyIcon(sFrame, secIcon)
                    if img then
                        img.Position = UDim2.new(0, 0, 0.5, -8)
                        xOff = 22
                    end
                end

                local lbl = Instance.new("TextLabel", sFrame)
                lbl.Size = UDim2.new(1, -xOff, 1, 0)
                lbl.Position = UDim2.new(0, xOff, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = secName
                lbl.TextColor3 = Color3.fromRGB(220, 225, 255)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 13
                lbl.RichText = true
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                return {
                    SetVisible = function(self, vis) sFrame.Visible = vis end,
                    SetTitle = function(self, text) lbl.Text = text end
                }
            end

            function Elements:CreateLabel(args)
                local frame, titleLbl, descLbl, ctrl = CreateElementBase(args, 30)
                return setmetatable({
                    Set = function(self, newText) titleLbl.Text = tostring(newText) end,
                    Get = function() return titleLbl.Text end
                }, {__index = ctrl})
            end

            function Elements:CreateButton(args)
                args = args or {}
                local callback = args.Callback or function() end
                local frame, titleLbl, descLbl, ctrl = CreateElementBase(args, 35)

                local btn = Instance.new("TextButton", frame)
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.AutoButtonColor = false

                btn.MouseEnter:Connect(function() tweens:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 40, 70)}):Play() end)
                btn.MouseLeave:Connect(function() tweens:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(15, 18, 28)}):Play() end)
                btn.MouseButton1Click:Connect(callback)

                return ctrl
            end

            function Elements:CreateToggle(args)
                args = args or {}
                local callback = args.Callback or function() end
                local flag = args.Flag or nil
                local state = args.CurrentValue or args.Default or false

                if flag then
                    if RanarthLib.Flags[flag] ~= nil then
                        state = RanarthLib.Flags[flag]
                    else
                        RanarthLib.Flags[flag] = state
                    end
                end

                local frame, titleLbl, descLbl, ctrl = CreateElementBase(args, 35)

                local btn = Instance.new("TextButton", frame)
                btn.Size = UDim2.new(0, 40, 0, 20)
                btn.Position = UDim2.new(1, -50, 0.5, -10)
                btn.BackgroundColor3 = state and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(25, 28, 40)
                btn.Text = ""
                Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
                staticStroke(btn, 1.2)

                local circle = Instance.new("Frame", btn)
                circle.Size = UDim2.new(0, 14, 0, 14)
                circle.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                circle.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 140, 180)
                Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

                local function updateState(newState)
                    state = newState
                    if flag then
                        RanarthLib.Flags[flag] = state
                        if RanarthLib.AutoSaveEnabled then RanarthLib:SaveConfiguration() end
                    end
                    tweens:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(25, 28, 40)}):Play()
                    tweens:Create(circle, TweenInfo.new(0.2), {
                        Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                        BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 140, 180)
                    }):Play()
                    callback(state)
                end

                btn.MouseButton1Click:Connect(function() updateState(not state) end)

                return setmetatable({
                    Set = function(self, newState) updateState(newState) end,
                    Get = function() return state end
                }, {__index = ctrl})
            end

            function Elements:CreateSlider(args)
                args = args or {}
                local min = args.Min or 0
                local max = args.Max or 100
                local step = args.Increment or args.Step or 1
                local default = args.CurrentValue or args.Default or min
                local callback = args.Callback or function() end
                local flag = args.Flag or nil

                if flag then
                    if RanarthLib.Flags[flag] ~= nil then
                        default = RanarthLib.Flags[flag]
                    else
                        RanarthLib.Flags[flag] = default
                    end
                end

                local sldName = args.Name or "Slider"
                local frame, titleLbl, descLbl, ctrl = CreateElementBase(args, 50)
                
                local decimals = 0
                local stepStr = tostring(step)
                if stepStr:find("%.") then
                    decimals = #stepStr:match("%.(%d+)")
                end
                local formatStr = "%." .. decimals .. "f"
                
                titleLbl.Text = sldName .. " : " .. string.format(formatStr, default)

                local bgBar = Instance.new("Frame", frame)
                bgBar.Size = UDim2.new(1, -20, 0, 6)
                bgBar.Position = UDim2.new(0, 10, 1, -12)
                bgBar.BackgroundColor3 = Color3.fromRGB(22, 26, 44)
                Instance.new("UICorner", bgBar).CornerRadius = UDim.new(1, 0)

                local fill = Instance.new("Frame", bgBar)
                fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
                fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

                local hitBtn = Instance.new("TextButton", bgBar)
                hitBtn.Size = UDim2.new(1, 0, 1, 0)
                hitBtn.BackgroundTransparency = 1
                hitBtn.Text = ""

                local dragging = false
                local function update(input)
                    local pos = math.clamp((input.Position.X - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)
                    local rawValue = min + ((max - min) * pos)
                    local value = math.round(rawValue / step) * step
                    value = math.clamp(value, min, max)
                    
                    local numValue = tonumber(string.format(formatStr, value))
                    local actualPos = (numValue - min) / (max - min)
                    
                    fill.Size = UDim2.new(actualPos, 0, 1, 0)
                    titleLbl.Text = sldName .. " : " .. string.format(formatStr, numValue)
                    
                    if flag then
                        RanarthLib.Flags[flag] = numValue
                        if RanarthLib.AutoSaveEnabled then RanarthLib:SaveConfiguration() end
                    end
                    callback(numValue)
                end

                hitBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true; update(input)
                    end
                end)
                RanarthLib:SafeUIS(uis.InputChanged, frame, function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        update(input)
                    end
                end)
                RanarthLib:SafeUIS(uis.InputEnded, frame, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                return setmetatable({
                    Set = function(self, val)
                        val = math.clamp(math.round(val / step) * step, min, max)
                        local numValue = tonumber(string.format(formatStr, val))
                        local pos = (numValue - min) / (max - min)
                        
                        fill.Size = UDim2.new(pos, 0, 1, 0)
                        titleLbl.Text = sldName .. " : " .. string.format(formatStr, numValue)
                        
                        if flag then RanarthLib.Flags[flag] = numValue end
                        callback(numValue)
                    end
                }, {__index = ctrl})
            end

            function Elements:CreateDropdown(args)
                args = args or {}
                local dropName = args.Name or "Dropdown"
                local options = args.Options or {}
                local currentVal = args.CurrentValue or options[1] or "None"
                local callback = args.Callback or function() end
                local flag = args.Flag or nil

                if flag then
                    if RanarthLib.Flags[flag] ~= nil then
                        currentVal = RanarthLib.Flags[flag]
                    else
                        RanarthLib.Flags[flag] = currentVal
                    end
                end

                local frame, titleLbl, descLbl, ctrl = CreateElementBase(args, 35)
                titleLbl.Text = "  " .. dropName .. " : " .. currentVal

                local icon = Instance.new("TextLabel", frame)
                icon.Size = UDim2.new(0, 20, 0, 20)
                icon.Position = UDim2.new(1, -25, 0, 7)
                icon.BackgroundTransparency = 1
                icon.Text = "v"
                icon.TextColor3 = Color3.fromRGB(200, 210, 255)
                icon.Font = Enum.Font.GothamBold

                local topBtn = Instance.new("TextButton", frame)
                topBtn.Size = UDim2.new(1, 0, 0, 35)
                topBtn.BackgroundTransparency = 1
                topBtn.Text = ""

                local sFrame = Instance.new("ScrollingFrame", frame)
                sFrame.Size = UDim2.new(1, -10, 1, -40)
                sFrame.Position = UDim2.new(0, 5, 0, 35)
                sFrame.BackgroundTransparency = 1
                sFrame.ScrollBarThickness = 4
                sFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                sFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

                local layout = Instance.new("UIListLayout", sFrame)
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0, 3)

                local isOpen = false
                topBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    local targetHeight = isOpen and math.min(140, (#options * 28) + 40) or 35
                    tweens:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
                    icon.Text = isOpen and "^" or "v"
                end)

                local function selectOpt(opt)
                    currentVal = opt
                    titleLbl.Text = "  " .. dropName .. " : " .. opt
                    isOpen = false
                    tweens:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                    icon.Text = "v"
                    if flag then
                        RanarthLib.Flags[flag] = currentVal
                        if RanarthLib.AutoSaveEnabled then RanarthLib:SaveConfiguration() end
                    end
                    callback(opt)
                end

                local function buildOptions(opts)
                    options = opts
                    for _, child in ipairs(sFrame:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local optBtn = Instance.new("TextButton", sFrame)
                        optBtn.Size = UDim2.new(1, -8, 0, 25)
                        optBtn.BackgroundColor3 = Color3.fromRGB(22, 26, 44)
                        optBtn.Text = opt
                        optBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
                        optBtn.Font = Enum.Font.Gotham
                        optBtn.TextSize = 11
                        Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
                        optBtn.MouseButton1Click:Connect(function() selectOpt(opt) end)
                    end
                end

                buildOptions(options)

                return setmetatable({
                    Refresh = function(self, newOpts) buildOptions(newOpts) end,
                    Set = function(self, val) selectOpt(val) end
                }, {__index = ctrl})
            end

            function Elements:CreateMultiDropdown(args)
                args = args or {}
                local dropName = args.Name or "Multi Dropdown"
                local options = args.Options or {}
                local currentSelected = args.CurrentValue or {}
                local callback = args.Callback or function() end
                local flag = args.Flag or nil

                local selected = {}
                for _, v in ipairs(currentSelected) do selected[v] = true end

                if flag and RanarthLib.Flags[flag] then
                    selected = RanarthLib.Flags[flag]
                end

                local frame, titleLbl, descLbl, ctrl = CreateElementBase(args, 35)

                local icon = Instance.new("TextLabel", frame)
                icon.Size = UDim2.new(0, 20, 0, 20)
                icon.Position = UDim2.new(1, -25, 0, 7)
                icon.BackgroundTransparency = 1
                icon.Text = "v"
                icon.TextColor3 = Color3.fromRGB(200, 210, 255)

                local topBtn = Instance.new("TextButton", frame)
                topBtn.Size = UDim2.new(1, 0, 0, 35)
                topBtn.BackgroundTransparency = 1
                topBtn.Text = ""

                local sFrame = Instance.new("ScrollingFrame", frame)
                sFrame.Size = UDim2.new(1, -10, 1, -40)
                sFrame.Position = UDim2.new(0, 5, 0, 35)
                sFrame.BackgroundTransparency = 1
                sFrame.ScrollBarThickness = 4
                sFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                sFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                Instance.new("UIListLayout", sFrame).Padding = UDim.new(0, 3)

                local function refreshLabel()
                    local names = {}
                    for opt, isSel in pairs(selected) do if isSel then table.insert(names, opt) end end
                    titleLbl.Text = "  " .. dropName .. " : " .. (#names > 0 and table.concat(names, ", ") or "None")
                end
                refreshLabel()

                local isOpen = false
                topBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    tweens:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, isOpen and math.min(140, (#options * 28) + 40) or 35)}):Play()
                    icon.Text = isOpen and "^" or "v"
                end)

                for _, opt in ipairs(options) do
                    if selected[opt] == nil then selected[opt] = false end
                    local optBtn = Instance.new("TextButton", sFrame)
                    optBtn.Size = UDim2.new(1, -8, 0, 25)
                    optBtn.BackgroundColor3 = Color3.fromRGB(22, 26, 44)
                    optBtn.Text = (selected[opt] and "[x] " or "[ ] ") .. opt
                    optBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
                    optBtn.Font = Enum.Font.Gotham
                    optBtn.TextSize = 11
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

                    optBtn.MouseButton1Click:Connect(function()
                        selected[opt] = not selected[opt]
                        optBtn.Text = (selected[opt] and "[x] " or "[ ] ") .. opt
                        refreshLabel()
                        local res = {}
                        for o, isSel in pairs(selected) do if isSel then table.insert(res, o) end end
                        if flag then 
                            RanarthLib.Flags[flag] = res
                            if RanarthLib.AutoSaveEnabled then RanarthLib:SaveConfiguration() end
                        end
                        callback(res)
                    end)
                end

                return setmetatable({
                    GetSelected = function()
                        local res = {}
                        for o, isSel in pairs(selected) do if isSel then table.insert(res, o) end end
                        return res
                    end
                }, {__index = ctrl})
            end

            function Elements:CreateInput(args)
                args = args or {}
                local placeholder = args.PlaceholderText or args.Placeholder or "Type here..."
                local callback = args.Callback or function() end
                local frame, titleLbl, descLbl, ctrl = CreateElementBase(args, 35)

                local boxFrame = Instance.new("Frame", frame)
                boxFrame.Size = UDim2.new(0, 110, 0, 24)
                boxFrame.Position = UDim2.new(1, -120, 0.5, -12)
                boxFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
                Instance.new("UICorner", boxFrame).CornerRadius = UDim.new(0, 4)
                staticStroke(boxFrame, 1.2)

                local tBox = Instance.new("TextBox", boxFrame)
                tBox.Size = UDim2.new(1, -10, 1, 0)
                tBox.Position = UDim2.new(0, 5, 0, 0)
                tBox.BackgroundTransparency = 1
                tBox.Text = ""
                tBox.PlaceholderText = placeholder
                tBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                tBox.PlaceholderColor3 = Color3.fromRGB(130, 140, 180)
                tBox.Font = Enum.Font.Gotham
                tBox.TextSize = 11
                tBox.ClearTextOnFocus = false

                tBox.FocusLost:Connect(function(enterPressed) callback(tBox.Text, enterPressed) end)

                return setmetatable({
                    Set = function(self, txt) tBox.Text = txt end,
                    Get = function() return tBox.Text end
                }, {__index = ctrl})
            end

            function Elements:CreateKeybind(args)
                args = args or {}
                local currentKey = args.CurrentKey or args.Default or Enum.KeyCode.F
                local callback = args.Callback or function() end
                local frame, titleLbl, descLbl, ctrl = CreateElementBase(args, 35)

                local keyBtn = Instance.new("TextButton", frame)
                keyBtn.Size = UDim2.new(0, 90, 0, 23)
                keyBtn.Position = UDim2.new(1, -100, 0.5, -11.5)
                keyBtn.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
                keyBtn.Text = currentKey.Name
                keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                keyBtn.Font = Enum.Font.GothamBold
                keyBtn.TextSize = 11
                Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 4)
                local keyStroke = staticStroke(keyBtn, 1.2)

                local listening = false
                keyBtn.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    keyBtn.Text = "..."
                    keyStroke.Color = Color3.fromRGB(100, 150, 255)
                    
                    local conn
                    conn = RanarthLib:SafeUIS(uis.InputBegan, frame, function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            keyBtn.Text = currentKey.Name
                            keyStroke.Color = Color3.fromRGB(38, 44, 75)
                            listening = false
                            conn:Disconnect()
                            callback(currentKey)
                        end
                    end)
                end)

                return setmetatable({
                    SetKey = function(self, k) currentKey = k; keyBtn.Text = currentKey.Name end,
                    GetKey = function() return currentKey end
                }, {__index = ctrl})
            end

            function Elements:CreateColorPicker(args)
                args = args or {}
                local defaultColor = args.Color or args.Default or Color3.fromRGB(100, 150, 255)
                local callback = args.Callback or function() end
                local flag = args.Flag or nil
                
                if flag and RanarthLib.Flags[flag] then
                    local stored = RanarthLib.Flags[flag]
                    if type(stored) == "table" and stored.R and stored.G and stored.B then
                        defaultColor = Color3.fromRGB(stored.R, stored.G, stored.B)
                    end
                end

                local frame, titleLbl, descLbl, ctrl = CreateElementBase(args, 35)

                local swatch = Instance.new("TextButton", frame)
                swatch.Size = UDim2.new(0, 35, 0, 20)
                swatch.Position = UDim2.new(1, -45, 0, 7.5)
                swatch.BackgroundColor3 = defaultColor
                swatch.Text = ""
                Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 4)
                staticStroke(swatch, 1.2)

                local isOpen = false
                local currentColor = defaultColor
                local r, g, b = math.floor(defaultColor.R * 255), math.floor(defaultColor.G * 255), math.floor(defaultColor.B * 255)

                local function pushColor()
                    currentColor = Color3.fromRGB(r, g, b)
                    swatch.BackgroundColor3 = currentColor
                    if flag then
                        RanarthLib.Flags[flag] = {R = r, G = g, B = b}
                        if RanarthLib.AutoSaveEnabled then RanarthLib:SaveConfiguration() end
                    end
                    callback(currentColor)
                end

                local function makeChannelSlider(yPos, channelName, initial, onChange)
                    local sFrame = Instance.new("Frame", frame)
                    sFrame.Size = UDim2.new(1, -20, 0, 22)
                    sFrame.Position = UDim2.new(0, 10, 0, yPos)
                    sFrame.BackgroundTransparency = 1

                    local cLbl = Instance.new("TextLabel", sFrame)
                    cLbl.Size = UDim2.new(0, 20, 1, 0)
                    cLbl.BackgroundTransparency = 1
                    cLbl.Text = channelName
                    cLbl.TextColor3 = Color3.fromRGB(200, 210, 255)

                    local bgBar = Instance.new("Frame", sFrame)
                    bgBar.Size = UDim2.new(1, -25, 0, 6)
                    bgBar.Position = UDim2.new(0, 25, 0.5, -3)
                    bgBar.BackgroundColor3 = Color3.fromRGB(22, 26, 44)
                    Instance.new("UICorner", bgBar).CornerRadius = UDim.new(1, 0)

                    local fill = Instance.new("Frame", bgBar)
                    fill.Size = UDim2.new(initial / 255, 0, 1, 0)
                    fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

                    local hitBtn = Instance.new("TextButton", bgBar)
                    hitBtn.Size = UDim2.new(1, 0, 1, 0)
                    hitBtn.BackgroundTransparency = 1
                    hitBtn.Text = ""

                    local dragging = false
                    hitBtn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            local pos = math.clamp((input.Position.X - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)
                            fill.Size = UDim2.new(pos, 0, 1, 0)
                            onChange(math.floor(pos * 255))
                        end
                    end)
                    RanarthLib:SafeUIS(uis.InputChanged, frame, function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local pos = math.clamp((input.Position.X - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)
                            fill.Size = UDim2.new(pos, 0, 1, 0)
                            onChange(math.floor(pos * 255))
                        end
                    end)
                    RanarthLib:SafeUIS(uis.InputEnded, frame, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
                    end)
                end

                makeChannelSlider(40, "R", r, function(v) r = v; pushColor() end)
                makeChannelSlider(65, "G", g, function(v) g = v; pushColor() end)
                makeChannelSlider(90, "B", b, function(v) b = v; pushColor() end)

                swatch.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    tweens:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, isOpen and 120 or 35)}):Play()
                end)

                return setmetatable({ GetColor = function() return currentColor end }, {__index = ctrl})
            end

            function Elements:CreateSearchBar(args)
                args = args or {}
                local placeholder = args.PlaceholderText or args.Placeholder or "Search features..."
                local sFrame = Instance.new("Frame", targetParent)
                sFrame.Size = UDim2.new(1, 0, 0, 32)
                sFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
                sFrame.LayoutOrder = -1000
                Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 6)
                staticStroke(sFrame, 1.2)
                ApplyFlex(sFrame)

                local searchBox = Instance.new("TextBox", sFrame)
                searchBox.Size = UDim2.new(1, -20, 1, 0)
                searchBox.Position = UDim2.new(0, 10, 0, 0)
                searchBox.BackgroundTransparency = 1
                searchBox.Text = ""
                searchBox.PlaceholderText = placeholder
                searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                searchBox.PlaceholderColor3 = Color3.fromRGB(130, 140, 180)
                searchBox.Font = Enum.Font.Gotham
                searchBox.TextSize = 12
                searchBox.TextXAlignment = Enum.TextXAlignment.Left
                searchBox.ClearTextOnFocus = false

                searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local query = searchBox.Text:lower()
                    for _, child in ipairs(targetParent:GetChildren()) do
                        if child:IsA("GuiObject") and child ~= sFrame then
                            if query == "" then
                                child.Visible = true
                            else
                                local matched = false
                                for _, desc in ipairs(child:GetDescendants()) do
                                    if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                                        if desc.Text:lower():find(query, 1, true) then matched = true break end
                                    end
                                end
                                child.Visible = matched
                            end
                        end
                    end
                end)
                return sFrame
            end

            function Elements:CreateDivider()
                local div = Instance.new("Frame", targetParent)
                div.Size = UDim2.new(1, 0, 0, 1)
                div.BackgroundColor3 = Color3.fromRGB(38, 44, 75)
                div.BorderSizePixel = 0
                ApplyFlex(div)
            end

            function Elements:CreateParagraph(args)
                args = args or {}
                local titleText = args.Title or args.Name or "Information"
                local descText = args.Content or args.Text or ""
                
                local pFrame = Instance.new("Frame", targetParent)
                pFrame.Size = UDim2.new(1, 0, 0, 0)
                pFrame.AutomaticSize = Enum.AutomaticSize.Y
                pFrame.BackgroundTransparency = 1
                ApplyFlex(pFrame)
                
                local pLayout = Instance.new("UIListLayout", pFrame)
                pLayout.SortOrder = Enum.SortOrder.LayoutOrder
                pLayout.Padding = UDim.new(0, 4)

                local title = Instance.new("TextLabel", pFrame)
                title.Size = UDim2.new(1, 0, 0, 16)
                title.BackgroundTransparency = 1
                title.Text = titleText
                title.TextColor3 = Color3.fromRGB(220, 225, 255)
                title.Font = Enum.Font.GothamBold
                title.TextSize = 13
                title.RichText = true
                title.TextXAlignment = Enum.TextXAlignment.Left

                if descText ~= "" then
                    local desc = Instance.new("TextLabel", pFrame)
                    desc.Size = UDim2.new(1, 0, 0, 0)
                    desc.AutomaticSize = Enum.AutomaticSize.Y
                    desc.BackgroundTransparency = 1
                    desc.Text = descText
                    desc.TextColor3 = Color3.fromRGB(150, 160, 200)
                    desc.Font = Enum.Font.Gotham
                    desc.TextSize = 11
                    desc.RichText = true
                    desc.TextWrapped = true
                    desc.TextXAlignment = Enum.TextXAlignment.Left
                end
            end

            function Elements:CreateProgressBar(args)
                args = args or {}
                local title = args.Name or "Progress"
                local maxVal = math.max(args.Max or 100, 0.001)
                local defaultVal = args.CurrentValue or args.Default or args.Value or 0
                
                local pbFrame = Instance.new("Frame", targetParent)
                pbFrame.Size = UDim2.new(1, 0, 0, 45)
                pbFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
                Instance.new("UICorner", pbFrame).CornerRadius = UDim.new(0, 6)
                staticStroke(pbFrame, 1.2)
                ApplyFlex(pbFrame)

                local lbl = Instance.new("TextLabel", pbFrame)
                lbl.Size = UDim2.new(1, -20, 0, 20)
                lbl.Position = UDim2.new(0, 10, 0, 5)
                lbl.BackgroundTransparency = 1
                lbl.Text = title .. " : " .. tostring(defaultVal) .. " / " .. tostring(maxVal)
                lbl.TextColor3 = Color3.fromRGB(200, 210, 255)
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 12
                lbl.RichText = true
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local bgBar = Instance.new("Frame", pbFrame)
                bgBar.Size = UDim2.new(1, -20, 0, 6)
                bgBar.Position = UDim2.new(0, 10, 0, 30)
                bgBar.BackgroundColor3 = Color3.fromRGB(22, 26, 44)
                Instance.new("UICorner", bgBar).CornerRadius = UDim.new(1, 0)

                local fill = Instance.new("Frame", bgBar)
                fill.Size = UDim2.new(math.clamp(defaultVal/maxVal, 0, 1), 0, 1, 0)
                fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

                return {
                    SetValue = function(self, newVal)
                        newVal = math.clamp(newVal, 0, maxVal)
                        tweens:Create(fill, TweenInfo.new(0.3), {Size = UDim2.new(newVal/maxVal, 0, 1, 0)}):Play()
                        lbl.Text = title .. " : " .. tostring(newVal) .. " / " .. tostring(maxVal)
                    end,
                    Update = function(newVal)
                        newVal = math.clamp(newVal, 0, maxVal)
                        tweens:Create(fill, TweenInfo.new(0.3), {Size = UDim2.new(newVal/maxVal, 0, 1, 0)}):Play()
                        lbl.Text = title .. " : " .. tostring(newVal) .. " / " .. tostring(maxVal)
                    end
                }
            end

            function Elements:CreateCodeBlock(args)
                args = args or {}
                local title = args.Title or args.Name or args.Language or "Code"
                local codeText = args.Code or ""
                
                local cbFrame = Instance.new("Frame", targetParent)
                cbFrame.Size = UDim2.new(1, 0, 0, 0)
                cbFrame.AutomaticSize = Enum.AutomaticSize.Y
                cbFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
                Instance.new("UICorner", cbFrame).CornerRadius = UDim.new(0, 6)
                staticStroke(cbFrame, 1.2)
                ApplyFlex(cbFrame)

                local topBar = Instance.new("Frame", cbFrame)
                topBar.Size = UDim2.new(1, 0, 0, 25)
                topBar.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
                Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 6)
                
                local lbl = Instance.new("TextLabel", topBar)
                lbl.Size = UDim2.new(1, -10, 1, 0)
                lbl.Position = UDim2.new(0, 10, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = title
                lbl.TextColor3 = Color3.fromRGB(150, 160, 200)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 10
                lbl.RichText = true
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local copyBtn = Instance.new("TextButton", topBar)
                copyBtn.Size = UDim2.new(0, 40, 0, 15)
                copyBtn.Position = UDim2.new(1, -45, 0.5, -7.5)
                copyBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 70)
                copyBtn.Text = "COPY"
                copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                copyBtn.Font = Enum.Font.GothamBold
                copyBtn.TextSize = 9
                Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)
                copyBtn.MouseButton1Click:Connect(function()
                    if setclipboard then setclipboard(codeText) end
                    copyBtn.Text = "COPIED"
                    task.wait(1.5); copyBtn.Text = "COPY"
                end)

                local codeScroll = Instance.new("ScrollingFrame", cbFrame)
                codeScroll.Size = UDim2.new(1, -10, 0, 100)
                codeScroll.Position = UDim2.new(0, 5, 0, 30)
                codeScroll.BackgroundTransparency = 1
                codeScroll.ScrollBarThickness = 2
                codeScroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
                codeScroll.CanvasSize = UDim2.new(0, 0, 0, 0) 
                
                local txt = Instance.new("TextLabel", codeScroll)
                txt.Size = UDim2.new(1, 0, 0, 0)
                txt.AutomaticSize = Enum.AutomaticSize.XY
                txt.BackgroundTransparency = 1
                txt.Text = codeText
                txt.TextColor3 = Color3.fromRGB(220, 225, 255)
                txt.Font = Enum.Font.Code
                txt.TextSize = 12
                txt.TextXAlignment = Enum.TextXAlignment.Left
                txt.TextYAlignment = Enum.TextYAlignment.Top

                local layout = Instance.new("UIListLayout", cbFrame)
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                local pad = Instance.new("UIPadding", cbFrame)
                pad.PaddingBottom = UDim.new(0, 5)
            end

            -- INFINITE NESTING CONTAINERS
            function Elements:CreateHStack()
                local hFrame = Instance.new("Frame", targetParent)
                hFrame.Size = UDim2.new(1, 0, 0, 0)
                hFrame.AutomaticSize = Enum.AutomaticSize.Y
                hFrame.BackgroundTransparency = 1
                ApplyFlex(hFrame)
                
                local hLayout = Instance.new("UIListLayout", hFrame)
                hLayout.FillDirection = Enum.FillDirection.Horizontal
                hLayout.SortOrder = Enum.SortOrder.LayoutOrder
                hLayout.Padding = UDim.new(0, 8)
                hLayout.VerticalAlignment = Enum.VerticalAlignment.Center

                return BuildElements(hFrame)
            end

            function Elements:CreateGroup(titleArgs)
                local title = type(titleArgs) == "table" and titleArgs.Name or titleArgs
                local gFrame = Instance.new("Frame", targetParent)
                gFrame.Size = UDim2.new(1, 0, 0, 0)
                gFrame.AutomaticSize = Enum.AutomaticSize.Y
                gFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 24)
                Instance.new("UICorner", gFrame).CornerRadius = UDim.new(0, 8)
                staticStroke(gFrame, 1.2)
                ApplyFlex(gFrame)

                local pad = Instance.new("UIPadding", gFrame)
                pad.PaddingTop = UDim.new(0, 10)
                pad.PaddingBottom = UDim.new(0, 10)
                pad.PaddingLeft = UDim.new(0, 10)
                pad.PaddingRight = UDim.new(0, 10)

                local gLayout = Instance.new("UIListLayout", gFrame)
                gLayout.SortOrder = Enum.SortOrder.LayoutOrder
                gLayout.Padding = UDim.new(0, 8)

                if title then
                    local lbl = Instance.new("TextLabel", gFrame)
                    lbl.Size = UDim2.new(1, 0, 0, 15)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = title
                    lbl.TextColor3 = Color3.fromRGB(150, 160, 200)
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 11
                    lbl.RichText = true
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    local div = Instance.new("Frame", gFrame)
                    div.Size = UDim2.new(1, 0, 0, 1); div.BackgroundColor3 = Color3.fromRGB(38, 44, 75); div.BorderSizePixel = 0
                end

                local contentFrame = Instance.new("Frame", gFrame)
                contentFrame.Size = UDim2.new(1, 0, 0, 0)
                contentFrame.AutomaticSize = Enum.AutomaticSize.Y
                contentFrame.BackgroundTransparency = 1
                local cLayout = Instance.new("UIListLayout", contentFrame)
                cLayout.SortOrder = Enum.SortOrder.LayoutOrder
                cLayout.Padding = UDim.new(0, 8)

                return BuildElements(contentFrame)
            end

            -- CONFIG SYSTEM (TERINTEGRASI DI DALAM UI BUILDER)
            function Elements:CreateConfigSystem(args)
                args = args or {}
                local currentSaveName = "default"
                local currentLoadName = "default"

                self:CreateSection("Save Configuration")
                self:CreateInput({
                    Name = "Config Name",
                    Placeholder = "Enter name...",
                    Callback = function(val)
                        currentSaveName = val ~= "" and val or "default"
                    end
                })
                self:CreateButton({
                    Name = "Save Config",
                    Callback = function()
                        local success = RanarthLib:SaveConfiguration(currentSaveName)
                        if success then
                            RanarthLib:CreateNotification("Config", "Saved: " .. currentSaveName, 3)
                        else
                            RanarthLib:CreateNotification("Config", "Failed to save config.", 3)
                        end
                    end
                })

                self:CreateSection("Load Configuration")
                local configDropdown 
                configDropdown = self:CreateDropdown({
                    Name = "Select Config",
                    Options = RanarthLib.ListConfigs(),
                    Callback = function(val)
                        currentLoadName = val
                    end
                })
                
                local btnStack = self:CreateHStack()
                btnStack:CreateButton({
                    Name = "Refresh List",
                    Callback = function()
                        configDropdown:Refresh(RanarthLib.ListConfigs())
                    end
                })
                btnStack:CreateButton({
                    Name = "Load Config",
                    Callback = function()
                        local success = RanarthLib:LoadConfiguration(currentLoadName)
                        if success then
                            RanarthLib:CreateNotification("Config", "Loaded: " .. currentLoadName, 3)
                        else
                            RanarthLib:CreateNotification("Config", "Config not found.", 3)
                        end
                    end
                })
            end

            return Elements
        end

        local TabElements = BuildElements(scrollFrame)
        setmetatable(Tab, {__index = TabElements})

        return Tab
    end
    
    return Window
end

-- ==========================================
-- 6. CONFIG SYSTEM & FILE IO
-- ==========================================
function RanarthLib.ListConfigs()
    if not listfiles or not isfolder then return {"default"} end
    if not isfolder(RanarthLib.ConfigFolder) then return {"default"} end
    local result = {}
    for _, path in ipairs(listfiles(RanarthLib.ConfigFolder)) do
        local fname = path:match("([^/\\]+)%.json$")
        if fname then table.insert(result, fname) end
    end
    if #result == 0 then table.insert(result, "default") end
    return result
end

function RanarthLib:SaveConfiguration(configName)
    configName = configName or self.ConfigFileName
    if not writefile then warn("Ranarth GUI: Unsupported executor.") return false end
    if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(self.Flags) end)
    if not ok then return false end
    writefile(self.ConfigFolder .. "/" .. configName .. ".json", encoded)
    return true
end

function RanarthLib:LoadConfiguration(configName)
    configName = configName or self.ConfigFileName
    if not readfile or not isfile then return false end
    local path = self.ConfigFolder .. "/" .. configName .. ".json"
    if not isfile(path) then return false end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if ok and type(decoded) == "table" then
        self.Flags = decoded
        return true
    end
    return false
end

-- ==========================================
-- 7. BACKWARD-COMPATIBLE CONFIG ALIASES (dari main.lua lama)
-- ==========================================
function RanarthLib.SaveConfig(configName, dataTable)
    if not writefile then warn("Ranarth GUI: unsupported executor.") return false end
    if not isfolder(RanarthLib.ConfigFolder) then makefolder(RanarthLib.ConfigFolder) end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(dataTable) end)
    if not ok then return false end
    writefile(RanarthLib.ConfigFolder .. "/" .. configName .. ".json", encoded)
    return true
end

function RanarthLib.LoadConfig(configName)
    if not readfile or not isfile then return nil end
    local path = RanarthLib.ConfigFolder .. "/" .. configName .. ".json"
    if not isfile(path) then return nil end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if ok then return decoded end
    return nil
end

return RanarthLib
