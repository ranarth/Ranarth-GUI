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
    AntiSpam = true,
    ScreenGuis = {}
}

    RanarthLib.Themes = {
        ["Space"] = {
            MainBG = Color3.fromRGB(10, 11, 16),
            ElementBG = Color3.fromRGB(16, 18, 28),
            Header = Color3.fromRGB(16, 18, 28),
            SecondaryBG = Color3.fromRGB(25, 28, 40),
            Hover = Color3.fromRGB(35, 40, 70),
            Accent = Color3.fromRGB(100, 150, 255),
            Text = Color3.fromRGB(220, 225, 255),
            TextDark = Color3.fromRGB(130, 140, 180),
            Stroke1 = Color3.fromRGB(38, 44, 75),
            Stroke2 = Color3.fromRGB(100, 150, 255),
            Stroke3 = Color3.fromRGB(220, 255, 255)
        },
        ["Sakura"] = {
            MainBG = Color3.fromRGB(255, 235, 240),
            ElementBG = Color3.fromRGB(255, 222, 232),
            Header = Color3.fromRGB(255, 222, 232),
            SecondaryBG = Color3.fromRGB(255, 205, 220),
            Hover = Color3.fromRGB(255, 190, 210),
            Accent = Color3.fromRGB(255, 105, 150),
            Text = Color3.fromRGB(90, 40, 55),
            TextDark = Color3.fromRGB(150, 100, 115),
            Stroke1 = Color3.fromRGB(219, 112, 147),
            Stroke2 = Color3.fromRGB(199, 21, 133),
            Stroke3 = Color3.fromRGB(255, 20, 147)
        },
        ["Bloody Mary"] = {
            MainBG = Color3.fromRGB(60, 5, 10),
            ElementBG = Color3.fromRGB(80, 10, 15),
            Header = Color3.fromRGB(80, 10, 15),
            SecondaryBG = Color3.fromRGB(100, 15, 20),
            Hover = Color3.fromRGB(130, 20, 20),
            Accent = Color3.fromRGB(230, 0, 0),
            Text = Color3.fromRGB(255, 225, 225),
            TextDark = Color3.fromRGB(200, 120, 120),
            Stroke1 = Color3.fromRGB(70, 8, 10),
            Stroke2 = Color3.fromRGB(150, 0, 0),
            Stroke3 = Color3.fromRGB(220, 20, 20)
        },
        ["Cyberpunk"] = {
            MainBG = Color3.fromRGB(18, 10, 30),
            ElementBG = Color3.fromRGB(28, 16, 46),
            Header = Color3.fromRGB(45, 40, 15),
            SecondaryBG = Color3.fromRGB(45, 40, 15),
            Hover = Color3.fromRGB(80, 70, 20),
            Accent = Color3.fromRGB(0, 255, 255),
            Text = Color3.fromRGB(229, 255, 255),
            TextDark = Color3.fromRGB(140, 130, 200),
            Stroke1 = Color3.fromRGB(255, 0, 170),
            Stroke2 = Color3.fromRGB(0, 255, 255),
            Stroke3 = Color3.fromRGB(255, 230, 0)
        },
        ["Mystic Grimoire"] = {
            MainBG = Color3.fromRGB(24, 16, 34),
            ElementBG = Color3.fromRGB(36, 24, 50),
            Header = Color3.fromRGB(28, 85, 48),
            SecondaryBG = Color3.fromRGB(48, 32, 66),
            Hover = Color3.fromRGB(64, 44, 88),
            Accent = Color3.fromRGB(80, 200, 120),
            Text = Color3.fromRGB(230, 220, 245),
            TextDark = Color3.fromRGB(160, 140, 190),
            Stroke1 = Color3.fromRGB(28, 85, 48),
            Stroke2 = Color3.fromRGB(60, 200, 100),
            Stroke3 = Color3.fromRGB(180, 255, 140)
        },
        ["Retro Y2K"] = {
            MainBG = Color3.fromRGB(235, 240, 255),
            ElementBG = Color3.fromRGB(255, 255, 255),
            Header = Color3.fromRGB(255, 255, 255),
            SecondaryBG = Color3.fromRGB(210, 220, 255),
            Hover = Color3.fromRGB(190, 205, 255),
            Accent = Color3.fromRGB(120, 140, 255),
            Text = Color3.fromRGB(40, 20, 70),
            TextDark = Color3.fromRGB(110, 100, 160),
            Stroke1 = Color3.fromRGB(150, 180, 255),
            Stroke2 = Color3.fromRGB(255, 0, 170),
            Stroke3 = Color3.fromRGB(180, 255, 240)
        },
        ["Cake"] = {
            MainBG = Color3.fromRGB(255, 250, 244),
            ElementBG = Color3.fromRGB(250, 240, 228),
            Header = Color3.fromRGB(196, 130, 74),
            SecondaryBG = Color3.fromRGB(240, 222, 200),
            Hover = Color3.fromRGB(228, 205, 175),
            Accent = Color3.fromRGB(196, 130, 74),
            Text = Color3.fromRGB(74, 44, 30),
            TextDark = Color3.fromRGB(150, 115, 90),
            Stroke1 = Color3.fromRGB(101, 67, 33),
            Stroke2 = Color3.fromRGB(54, 32, 18),
            Stroke3 = Color3.fromRGB(150, 105, 65)
        }
    }
    RanarthLib.CurrentTheme = RanarthLib.Themes["Space"]
    RanarthLib.OnThemeChanged = Instance.new("BindableEvent")
    RanarthLib.ThemeUpdaters = {}

    function RanarthLib:SetTheme(themeName)
        if self.Themes[themeName] then
            self.CurrentTheme = self.Themes[themeName]
            self.OnThemeChanged:Fire()
            for i = #self.ThemeUpdaters, 1, -1 do
                local data = self.ThemeUpdaters[i]
                if data.Obj and data.Obj.Parent then
                    tweens:Create(data.Obj, TweenInfo.new(0.3), {[data.Prop] = self.CurrentTheme[data.Key]}):Play()
                else
                    table.remove(self.ThemeUpdaters, i)
                end
            end
        end
    end

    function RanarthLib:ApplyTheme(obj, prop, themeKey)
        if not obj then return end
        obj[prop] = self.CurrentTheme[themeKey]
        table.insert(self.ThemeUpdaters, {Obj = obj, Prop = prop, Key = themeKey})

        if #self.ThemeUpdaters % 100 == 0 then
            for i = #self.ThemeUpdaters, 1, -1 do
                local d = self.ThemeUpdaters[i]
                if not (d.Obj and d.Obj.Parent) then
                    table.remove(self.ThemeUpdaters, i)
                end
            end
        end
    end

    function RanarthLib:GetThemeGradient()
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0, self.CurrentTheme.Stroke1),
            ColorSequenceKeypoint.new(0.3, self.CurrentTheme.Stroke2),
            ColorSequenceKeypoint.new(0.5, self.CurrentTheme.Stroke3),
            ColorSequenceKeypoint.new(0.7, self.CurrentTheme.Stroke2),
            ColorSequenceKeypoint.new(1, self.CurrentTheme.Stroke1),
        })
    end

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
    self.ThemeUpdaters = {}
end

local allGrads = {}
local function animStroke(parent, thick)
    local s = Instance.new("UIStroke")
    s.Thickness = thick or 1.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = Color3.new(1, 1, 1)
    s.Parent = parent
    local g = Instance.new("UIGradient")
    g.Color = RanarthLib:GetThemeGradient()
    g.Rotation = 45
    g.Parent = s
    table.insert(allGrads, g)
    RanarthLib:TrackConnection(RanarthLib.OnThemeChanged.Event:Connect(function()
        g.Color = RanarthLib:GetThemeGradient()
    end))
    return s, g
end

local function staticStroke(parent, thick)
    local s = Instance.new("UIStroke")
    s.Thickness = thick or 1.2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    RanarthLib:ApplyTheme(s, "Color", "Stroke1")
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

local LucideIcons = {
    ["settings"] = "rbxassetid://106205298246017",
    ["settings-2"] = "rbxassetid://109485777305919",
    ["gamepad"] = "rbxassetid://99293705721130",
    ["home"] = "rbxassetid://109841253338329",
    ["skull"] = "rbxassetid://101060850237115",
    ["monitor"] = "rbxassetid://70520152532392",
    ["user"] = "rbxassetid://114567720540659",
    ["user-2"] = "rbxassetid://92481398073007",
    ["user-circle"] = "rbxassetid://96888447186214",
    ["user-cog"] = "rbxassetid://115462370853742",
    ["user-plus"] = "rbxassetid://101184880550364",
    ["user-minus"] = "rbxassetid://94865546608687",
    ["user-round-x"] = "rbxassetid://89227016198055",
    ["users"] = "rbxassetid://85332511060401",
    ["user-search"] = "rbxassetid://110388873642450",
    ["shield"] = "rbxassetid://106509993556171",
    ["shield-x"] = "rbxassetid://75826463279777",
    ["shield-off"] = "rbxassetid://98525250043109",
    ["shield-check"] = "rbxassetid://71867984579031",
    ["shield-alert"] = "rbxassetid://91754324662625",
    ["accessibility"] = "rbxassetid://109960743825561",
    ["alert-circle"] = "rbxassetid://74115333842618",
    ["alert-octagon"] = "rbxassetid://138910404523272",
    ["alert-triangle"] = "rbxassetid://112102474509324",
    ["align-text"] = "rbxassetid://120408521883501",
    ["swords"] = "rbxassetid://99199363807265",
    ["sword"] = "rbxassetid://121406454377051",
    ["zap"] = "rbxassetid://109718589733073",
    ["zap-off"] = "rbxassetid://115642996489807",
    ["star"] = "rbxassetid://72669221096319",
    ["star-off"] = "rbxassetid://120003686620511",
    ["folder"] = "rbxassetid://77937190465422",
    ["folder-check"] = "rbxassetid://95477621394824",
    ["folder-clock"] = "rbxassetid://137926892639070",
    ["folder-closed"] = "rbxassetid://86427718056887",
    ["folder-down"] = "rbxassetid://82793534945672",
    ["folder-edit"] = "rbxassetid://102495189191583",
    ["folder-input"] = "rbxassetid://132837435930621",
    ["folder-lock"] = "rbxassetid://111493727654155",
    ["folder-open"] = "rbxassetid://112237915867403",
    ["file-text"] = "rbxassetid://92774566080911",
    ["file-type"] = "rbxassetid://139551268989315",
    ["file-up"] = "rbxassetid://99191463679083",
    ["file-x"] = "rbxassetid://117124390222574",
    ["file-warning"] = "rbxassetid://89824347717079",
    ["file-xml"] = "rbxassetid://106124864132557",
    ["search"] = "rbxassetid://72296609649861",
    ["search-check"] = "rbxassetid://135876289053244",
    ["search-code"] = "rbxassetid://96217854889522",
    ["search-x"] = "rbxassetid://107116182495739",
    ["lock"] = "rbxassetid://119765975153029",
    ["lock-keyhole"] = "rbxassetid://135504457058301",
    ["lock-keyhole-open"] = "rbxassetid://132192657766903",
    ["check"] = "rbxassetid://86817768619372",
    ["double-check"] = "rbxassetid://101885204738917",
    ["check-circle"] = "rbxassetid://105979545056636",
    ["check-circle-2"] = "rbxassetid://76928915955542",
    ["check-square"] = "rbxassetid://135686334400788",
    ["check-square-2"] = "rbxassetid://84113739446686",
    ["bookmark-check"] = "rbxassetid://103743627936816",
    ["badge-check"] = "rbxassetid://76305757263548",
    ["copy-check"] = "rbxassetid://92397569046734",
    ["clipboard-check"] = "rbxassetid://90432969741774",
    ["camera"] = "rbxassetid://114084146151777",
    ["camera-off"] = "rbxassetid://101456706369049",
    ["bell"] = "rbxassetid://84691420588185",
    ["bell-ring"] = "rbxassetid://71006419366158",
    ["bell-off"] = "rbxassetid://115540031372596",
    ["bookmark"] = "rbxassetid://137439152875860",
    ["bookmark-plus"] = "rbxassetid://108572239011289",
    ["bookmark-x"] = "rbxassetid://115354177404954",
    ["bookmark-minus"] = "rbxassetid://106761186502279",
    ["calendar"] = "rbxassetid://126460151885084",
    ["calendar-day"] = "rbxassetid://83005303274935",
    ["calendar-check"] = "rbxassetid://116665691227418",
    ["calendar-clock"] = "rbxassetid://91678408267921",
    ["calendar-x"] = "rbxassetid://117555084312063",
    ["clipboard"] = "rbxassetid://105021692319787",
    ["clipboard-copy"] = "rbxassetid://85387882337161",
    ["clipboard-edit"] = "rbxassetid://131193135046966",
    ["clipboard-paste"] = "rbxassetid://79192963603923",
    ["clipboard-x"] = "rbxassetid://132658738057667",
    ["clock"] = "rbxassetid://136533241128438",
    ["cloud"] = "rbxassetid://136524873450824",
    ["cloud-cog"] = "rbxassetid://108438517119798",
    ["cloud-off"] = "rbxassetid://111796785870393",
    ["upload-cloud"] = "rbxassetid://121807815408739",
    ["download-cloud"] = "rbxassetid://122841052352556",
    ["compass"] = "rbxassetid://73836660434977",
    ["cpu"] = "rbxassetid://105237370909681",
    ["credit-card"] = "rbxassetid://124946887228472",
    ["database"] = "rbxassetid://99154172590159",
    ["download"] = "rbxassetid://109698732019071",
    ["file-edit"] = "rbxassetid://82156880342025",
    ["eye"] = "rbxassetid://127234874352422",
    ["eye-off"] = "rbxassetid://85207295981701",
    ["scan-eye"] = "rbxassetid://109514269737059",
    ["globe"] = "rbxassetid://125685532120024",
    ["globe-lock"] = "rbxassetid://96469366281710",
    ["hash"] = "rbxassetid://128945191245705",
    ["heart"] = "rbxassetid://88525382655929",
    ["heart-off"] = "rbxassetid://121500734414824",
    ["heart-pulse"] = "rbxassetid://101116623654468",
    ["heart-crack"] = "rbxassetid://78532998725036",
    ["image"] = "rbxassetid://114022611279795",
    ["image-down"] = "rbxassetid://91697762317652",
    ["image-off"] = "rbxassetid://113890586559666",
    ["image-up"] = "rbxassetid://95362531246536",
    ["image-plus"] = "rbxassetid://131640557457656",
    ["image-minus"] = "rbxassetid://111691180013117",
    ["images"] = "rbxassetid://87539822715105",
    ["file-image"] = "rbxassetid://83675710276234",
    ["info"] = "rbxassetid://120620848266512",
    ["badge-info"] = "rbxassetid://109792483526167",
    ["key"] = "rbxassetid://83474888140571",
    ["key-round"] = "rbxassetid://116918931002434",
    ["link"] = "rbxassetid://86131768436965",
    ["link-2"] = "rbxassetid://107339085791087",
    ["link-2-off"] = "rbxassetid://74994782779018",
    ["unlink"] = "rbxassetid://108239607794680",
    ["mail"] = "rbxassetid://77537514051485",
    ["mail-check"] = "rbxassetid://90824179551389",
    ["mail-plus"] = "rbxassetid://130540869833539",
    ["mail-question"] = "rbxassetid://128924135790205",
    ["mail-search"] = "rbxassetid://108269769085404",
    ["mail-warning"] = "rbxassetid://126275145590627",
    ["mail-minus"] = "rbxassetid://104189493909738",
    ["mail-x"] = "rbxassetid://97229750262408",
    ["map"] = "rbxassetid://131325044235094",
    ["map-pin"] = "rbxassetid://137091405832737",
    ["map-pin-off"] = "rbxassetid://130126969919710",
    ["map-pinned"] = "rbxassetid://78894827751778",
    ["menu"] = "rbxassetid://83047518441184",
    ["menu-square"] = "rbxassetid://84168857053009",
    ["square-menu"] = "rbxassetid://135438142591878",
    ["message-square"] = "rbxassetid://86432989388834",
    ["message-square-off"] = "rbxassetid://97376166485199",
    ["monitor-check"] = "rbxassetid://112341875921743",
    ["monitor-off"] = "rbxassetid://95048101284680",
    ["monitor-x"] = "rbxassetid://102604336229610",
    ["moon"] = "rbxassetid://98353636264918",
    ["music"] = "rbxassetid://132132095360900",
    ["music-2"] = "rbxassetid://121112248614371",
    ["music-3"] = "rbxassetid://122935411241955",
    ["pen"] = "rbxassetid://101486948449510",
    ["pen-square"] = "rbxassetid://124290018373176",
    ["pen-tool"] = "rbxassetid://126917951709518",
    ["clipboard-pen"] = "rbxassetid://99195778697194",
    ["phone"] = "rbxassetid://110402416146068",
    ["phone-call"] = "rbxassetid://83844308787978",
    ["phone-off"] = "rbxassetid://124218610436691",
    ["phone-missed"] = "rbxassetid://79555645036339",
    ["phone-incoming"] = "rbxassetid://80024725665109",
    ["phone-forwarded"] = "rbxassetid://121647613341736",
    ["phone-outgoing"] = "rbxassetid://107942094735434",
    ["smartphone"] = "rbxassetid://74962751233767",
    ["tablet-smartphone"] = "rbxassetid://78186066591210",
    ["headphones"] = "rbxassetid://89990513082092",
    ["megaphone"] = "rbxassetid://139746713205639",
    ["play"] = "rbxassetid://76386816441302",
    ["play-circle"] = "rbxassetid://94679908148591",
    ["play-square"] = "rbxassetid://88949301532557",
    ["power"] = "rbxassetid://89331085993646",
    ["power-off"] = "rbxassetid://71082730746769",
    ["refresh-cw"] = "rbxassetid://106497040962250",
    ["refresh-ccw"] = "rbxassetid://112330254035751",
    ["refresh-cw-off"] = "rbxassetid://70915551154203",
    ["save"] = "rbxassetid://122894934359450",
    ["save-all"] = "rbxassetid://130108174247404",
    ["send"] = "rbxassetid://94849431195865",
    ["send-horizontal"] = "rbxassetid://71350661970492",
    ["share"] = "rbxassetid://78225483239202",
    ["share-2"] = "rbxassetid://139712792470775",
    ["shopping-cart"] = "rbxassetid://79435149356304",
    ["speaker"] = "rbxassetid://117894179084666",
    ["sun"] = "rbxassetid://139232691165198",
    ["target"] = "rbxassetid://121091323240554",
    ["trash"] = "rbxassetid://126010725826757",
    ["video"] = "rbxassetid://99411215690870",
    ["video-off"] = "rbxassetid://81634790888002",
    ["volume"] = "rbxassetid://127607149758269",
    ["volume-x"] = "rbxassetid://106700331106145",
    ["volume-1"] = "rbxassetid://115207748957226",
    ["volume-2"] = "rbxassetid://129861259578431",
    ["wifi"] = "rbxassetid://104941258142372",
    ["wifi-off"] = "rbxassetid://120795495190257",
    ["x"] = "rbxassetid://116396312853810",
    ["x-circle"] = "rbxassetid://111132030834422",
    ["x-octagon"] = "rbxassetid://105062643930018",
    ["chevron-left"] = "rbxassetid://102314312897830",
    ["chevrons-left"] = "rbxassetid://87881912126351",
    ["chevron-right"] = "rbxassetid://101007429951147",
    ["chevrons-right"] = "rbxassetid://134353805354361",
    ["crosshair"] = "rbxassetid://83752373575368",
    ["cross"] = "rbxassetid://93673591064028",
    ["bot"] = "rbxassetid://70979486241131",
    ["teleport"] = "rbxassetid://6723742959",
    ["speed"] = "rbxassetid://13492318257",
    ["fly"] = "rbxassetid://7062265702",
    ["layout-grid"] = "rbxassetid://89644754139307",
    ["layout-dashboard"] = "rbxassetid://70433574792490",
    ["plane"] = "rbxassetid://123931033451986",
    ["plane-landing"] = "rbxassetid://127564654216931",
    ["rocket"] = "rbxassetid://109537053598807",
    ["repeat"] = "rbxassetid://88751041821881",
    ["repeat-1"] = "rbxassetid://83172378763568",
    ["scan"] = "rbxassetid://125367266780285",
    ["scan-barcode"] = "rbxassetid://97414347978098",
    ["scan-face"] = "rbxassetid://98379048258175",
    ["scan-line"] = "rbxassetid://74491678843147",
    ["scan-search"] = "rbxassetid://133304136560518",
    ["scan-text"] = "rbxassetid://135056446730766",
    ["file-scan"] = "rbxassetid://132590981389921",
    ["timer"] = "rbxassetid://120164083411828",
    ["timer-off"] = "rbxassetid://116991705734594",
    ["timer-reset"] = "rbxassetid://79948324123231",
    ["hourglass"] = "rbxassetid://135654740495171",
    ["glass-water"] = "rbxassetid://125170765146614",
    ["glasses"] = "rbxassetid://77027406085123",
    ["dices"] = "rbxassetid://116678154854810",
    ["dice-1"] = "rbxassetid://133629376866649",
    ["dice-2"] = "rbxassetid://137517882571271",
    ["dice-3"] = "rbxassetid://128612626459042",
    ["dice-4"] = "rbxassetid://73117400593570",
    ["dice-5"] = "rbxassetid://107643287892749",
    ["dice-6"] = "rbxassetid://112067139297943",
    ["loader"] = "rbxassetid://132295854994374",
    ["loader-2"] = "rbxassetid://128780061297692",
    ["loader-circle"] = "rbxassetid://71250150569964",
    ["sparkle"] = "rbxassetid://83114431765537",
    ["sparkles"] = "rbxassetid://105634041692696",
    ["wand-sparkles"] = "rbxassetid://115623066336607",
    ["car"] = "rbxassetid://91451724283877",
    ["car-front"] = "rbxassetid://79993076477613",
    ["leaf"] = "rbxassetid://70846801126940",
    ["leafy-green"] = "rbxassetid://94770162749325",
    ["maximize"] = "rbxassetid://116546384863431",
    ["minimize"] = "rbxassetid://95555494586098",
    ["maximize-2"] = "rbxassetid://130049637400171",
    ["minimize-2"] = "rbxassetid://96294437144715",
    ["proportions"] = "rbxassetid://78144579158638",
    ["store"] = "rbxassetid://121962391563311",
    ["dollar-sign"] = "rbxassetid://74567340201672",
    ["circle-dollar-sign"] = "rbxassetid://102720278203768",
    ["badge-dollar-sign"] = "rbxassetid://123225256208806",
    ["package"] = "rbxassetid://106101842173393",
    ["thumbs-up"] = "rbxassetid://96046658888813",
    ["thumbs-down"] = "rbxassetid://73778874448741",
    ["wrench"] = "rbxassetid://85345725497834",
    ["trophy"] = "rbxassetid://113055182645565",
    ["crown"] = "rbxassetid://92253403464658",
    ["pointer"] = "rbxassetid://98931495397575",
    ["pointer-off"] = "rbxassetid://121208450103912",
    ["mouse-pointer"] = "rbxassetid://113428527051320",
    ["mouse-pointer-click"] = "rbxassetid://81854854241463",
    ["waypoints"] = "rbxassetid://101997233404191",
    ["cat"] = "rbxassetid://118339348494810",
    ["angry"] = "rbxassetid://79345553086407",
    ["laugh"] = "rbxassetid://115974660887808",
    ["ban"] = "rbxassetid://109685306480139",
    ["gift"] = "rbxassetid://87706885156127",
}

-- HYBRID MODE: Load future icon extensions from GitHub
pcall(function()
    local ext = loadstring(game:HttpGet("https://raw.githubusercontent.com/ranarth/Ranarth-GUI/refs/heads/Icons/LucideIcons.lua"))()
    if type(ext) == "table" then
        for k, v in pairs(ext) do LucideIcons[k] = v end
    end
end)

-- UPDATE: Support rbxthumb:// while maintaining case-sensitivity
local function applyIcon(parent, iconData, preserveColor)
    if not iconData or iconData == "" then return nil end
    
    local strData = tostring(iconData)
    local lowerData = strData:lower()
    
    local isLucide = LucideIcons[lowerData] ~= nil
    local assetUrl
    
    if isLucide then
        assetUrl = LucideIcons[lowerData]
    elseif lowerData:find("rbxassetid://") or lowerData:find("rbxthumb://") or lowerData:find("http://") or lowerData:find("https://") then
        -- Return the original strData to preserve case (Crucial for rbxthumb://type=Asset)
        assetUrl = strData
    else
        assetUrl = "rbxassetid://" .. lowerData
    end
    
    local img = Instance.new("ImageLabel")
    img.Name = "Icon"
    img.Size = UDim2.new(0, 16, 0, 16)
    img.BackgroundTransparency = 1
    img.Image = assetUrl
    
    if preserveColor or not isLucide then
        img.ImageColor3 = Color3.fromRGB(255, 255, 255)
    else
        RanarthLib:ApplyTheme(img, "ImageColor3", "Text")
    end
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
RanarthLib:ApplyTheme(tooltipLabel, "BackgroundColor3", "MainBG")
RanarthLib:ApplyTheme(tooltipLabel, "TextColor3", "Text")
tooltipLabel.Font = Enum.Font.Gotham
tooltipLabel.TextSize = 11
tooltipLabel.RichText = true
tooltipLabel.TextWrapped = true
tooltipLabel.Visible = false
tooltipLabel.ZIndex = 100
tooltipLabel.Parent = tooltip_gui
Instance.new("UICorner", tooltipLabel).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", tooltipLabel).Color = RanarthLib.CurrentTheme.Stroke1

local lastNotifTick = 0
function RanarthLib:CreateNotification(title, text, duration, iconData)
    -- RANARTH ANTI-SPAM SECURITY SYSTEM (Toggleable by Developer)
    if RanarthLib.AntiSpam then
        local currentTick = tick()
        if currentTick - lastNotifTick < 0.15 then return end -- Ignore if fired faster than 0.15 seconds
        lastNotifTick = currentTick

        local maxNotifs = 5
        local activeNotifs = {}
        for _, child in ipairs(notif_container:GetChildren()) do
            if child:IsA("Frame") then table.insert(activeNotifs, child) end
        end
        if #activeNotifs >= maxNotifs then
            activeNotifs[1]:Destroy() -- Destroy the oldest notification
        end
    end

    duration = duration or 4
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 250, 0, 60)
    RanarthLib:ApplyTheme(card, "BackgroundColor3", "MainBG")
    card.BackgroundTransparency = 1
    card.ClipsDescendants = true
    card.Parent = notif_container
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    staticStroke(card, 1.2)

    local xOffset = 10
    local imgNode = nil
    if iconData then
        imgNode = applyIcon(card, iconData, true)
        if imgNode then
            imgNode.Size = UDim2.new(0, 32, 0, 32)
            imgNode.Position = UDim2.new(0, 10, 0.5, -16)
            imgNode.ImageTransparency = 1
            xOffset = 52
        end
    end

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -(xOffset + 10), 0, 20)
    titleLbl.Position = UDim2.new(0, xOffset, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title or "Notification"
    RanarthLib:ApplyTheme(titleLbl, "TextColor3", "Text")
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.RichText = true
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTransparency = 1
    titleLbl.Parent = card

    local bodyLbl = Instance.new("TextLabel")
    bodyLbl.Size = UDim2.new(1, -(xOffset + 10), 0, 30)
    bodyLbl.Position = UDim2.new(0, xOffset, 0, 26)
    bodyLbl.BackgroundTransparency = 1
    bodyLbl.Text = text or ""
    RanarthLib:ApplyTheme(bodyLbl, "TextColor3", "Text")
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
    if imgNode then
        tweens:Create(imgNode, TweenInfo.new(0.25), {ImageTransparency = 0}):Play()
    end

    task.spawn(function()
        task.wait(duration)
        tweens:Create(card, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        tweens:Create(titleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        if imgNode then tweens:Create(imgNode, TweenInfo.new(0.3), {ImageTransparency = 1}):Play() end
        local fadeOut = tweens:Create(bodyLbl, TweenInfo.new(0.3), {TextTransparency = 1})
        fadeOut:Play()
        fadeOut.Completed:Wait()
        card:Destroy()
    end)
end

function RanarthLib:CreateTooltip(target, text)
    RanarthLib:TrackConnection(target.MouseEnter:Connect(function()
        tooltipLabel.Text = "  " .. text
        tooltipLabel.Visible = true
    end))
    RanarthLib:TrackConnection(target.MouseMoved:Connect(function(x, y)
        tooltipLabel.Position = UDim2.new(0, x + 15, 0, y + 15)
    end))
    RanarthLib:TrackConnection(target.MouseLeave:Connect(function()
        tooltipLabel.Visible = false
    end))
end

-- ==========================================
-- 5. WINDOW CONSTRUCTOR
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
    
    if HubConfig.AntiSpam ~= nil then
        RanarthLib.AntiSpam = HubConfig.AntiSpam
    end
    
    if HubConfig.Theme and RanarthLib.Themes[HubConfig.Theme] then
        RanarthLib.CurrentTheme = RanarthLib.Themes[HubConfig.Theme]
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
    RanarthLib:ApplyTheme(frame, "BackgroundColor3", "MainBG")
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ClipsDescendants = true 
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    animStroke(frame, 1.5)

    if ToggleKey then
        RanarthLib:TrackConnection(uis.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == ToggleKey then
                frame.Visible = not frame.Visible
            end
        end))
    end

    local top_bar = Instance.new("Frame")
    top_bar.Size = UDim2.new(1, 0, 0, 35)
    RanarthLib:ApplyTheme(top_bar, "BackgroundColor3", "Header")
    top_bar.BorderSizePixel = 0
    top_bar.Parent = frame
    Instance.new("UICorner", top_bar).CornerRadius = UDim.new(0, 10)

    local title_txt = Instance.new("TextLabel")
    title_txt.Size = UDim2.new(1, -65, 1, 0)
    title_txt.Position = UDim2.new(0, 15, 0, 0)
    title_txt.BackgroundTransparency = 1
    title_txt.Text = Title
    RanarthLib:ApplyTheme(title_txt, "TextColor3", "Text")
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
        RanarthLib:ApplyTheme(btn, "BackgroundColor3", "SecondaryBG")
        btn.Text = text
        btn.TextColor3 = color
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = control_buttons
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        RanarthLib:TrackConnection(btn.MouseEnter:Connect(function() tweens:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 40, 55)}):Play() end))
        RanarthLib:TrackConnection(btn.MouseLeave:Connect(function() tweens:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = RanarthLib.CurrentTheme.SecondaryBG}):Play() end))
        RanarthLib:TrackConnection(btn.MouseButton1Click:Connect(callback))
    end

    create_header_btn("-", Color3.fromRGB(200, 200, 200), function()
        frame.Visible = false
        t_btn.Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset + frame.Size.X.Offset - 45, frame.Position.Y.Scale, frame.Position.Y.Offset)
        t_gui.Enabled = true 
    end)
    
    create_header_btn("X", Color3.fromRGB(255, 80, 80), function()
        RanarthLib:Unload()
    end)

    local drag, drag_in, start_drag, start_pos
    RanarthLib:TrackConnection(top_bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true; start_drag = input.Position; start_pos = frame.Position
            local releaseConn
            releaseConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    drag = false
                    if releaseConn then releaseConn:Disconnect() end
                end
            end)
        end
    end))
    RanarthLib:TrackConnection(top_bar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then drag_in = input end
    end))
    RanarthLib:SafeUIS(uis.InputChanged, frame, function(input)
        if input == drag_in and drag then
            local offset = input.Position - start_drag
            frame.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + offset.X, start_pos.Y.Scale, start_pos.Y.Offset + offset.Y)
        end
    end)

    local dragToggle, dragInputToggle, dragStartPos, startBtnPos, hasDragged = false, nil, nil, nil, false
    RanarthLib:TrackConnection(t_btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true; hasDragged = false; dragStartPos = input.Position; startBtnPos = t_btn.Position
            local releaseConn
            releaseConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                    if releaseConn then releaseConn:Disconnect() end
                end
            end)
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
    RanarthLib:ApplyTheme(watermark, "TextColor3", "TextDark")
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
    RanarthLib:ApplyTheme(resizer, "TextColor3", "TextDark")
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
    tab_container.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab_container.ClipsDescendants = true
    tab_container.Parent = frame
    
    local tab_pad = Instance.new("UIPadding", tab_container)
    tab_pad.PaddingTop = UDim.new(0, 2)
    tab_pad.PaddingBottom = UDim.new(0, 2)
    tab_pad.PaddingLeft = UDim.new(0, 2)
    tab_pad.PaddingRight = UDim.new(0, 2)
    
    local tab_layout = Instance.new("UIListLayout", tab_container)
    tab_layout.SortOrder = Enum.SortOrder.LayoutOrder
    tab_layout.Padding = UDim.new(0, 10)

    local content_container = Instance.new("Frame")
    content_container.BackgroundTransparency = 1
    content_container.ClipsDescendants = true
    content_container.Parent = frame

    if TabPosition == "Left" then
        tab_container.Size = UDim2.new(0, 148, 1, -55)
        tab_container.Position = UDim2.new(0, 10, 0, 45)
        tab_container.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tab_layout.FillDirection = Enum.FillDirection.Vertical
        
        local tab_divider = Instance.new("Frame", frame)
        tab_divider.Size = UDim2.new(0, 1, 1, -55)
        tab_divider.Position = UDim2.new(0, 163, 0, 45)
        RanarthLib:ApplyTheme(tab_divider, "BackgroundColor3", "Stroke1")
        tab_divider.BorderSizePixel = 0

        content_container.Size = UDim2.new(1, -183, 1, -55)
        content_container.Position = UDim2.new(0, 173, 0, 45)
    else
        tab_container.Size = UDim2.new(1, -20, 0, 35)
        tab_container.Position = UDim2.new(0, 10, 0, 45)
        tab_container.AutomaticCanvasSize = Enum.AutomaticSize.X
        tab_layout.FillDirection = Enum.FillDirection.Horizontal

        local tab_divider = Instance.new("Frame", frame)
        tab_divider.Size = UDim2.new(1, -20, 0, 1)
        tab_divider.Position = UDim2.new(0, 10, 0, 82)
        RanarthLib:ApplyTheme(tab_divider, "BackgroundColor3", "Stroke1")
        tab_divider.BorderSizePixel = 0

        content_container.Size = UDim2.new(1, -20, 1, -95)
        content_container.Position = UDim2.new(0, 10, 0, 85)
    end

    -- ==========================================
    -- DIALOG / MODAL SYSTEM
    -- ==========================================
    function Window:CreateDialog(title, text, options)
        options = options or {}
        if #options == 0 then
            options = {{Title = "OK", Callback = function() end}}
        end
        local overlay = Instance.new("Frame", gui)
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundTransparency = 1
        overlay.Active = true 
        overlay.ZIndex = 9999

        local dialogBox = Instance.new("Frame", overlay)
        dialogBox.Size = UDim2.new(0, 320, 0, 0)
        dialogBox.Position = UDim2.new(0.5, 0, 0.5, 20)
        dialogBox.AnchorPoint = Vector2.new(0.5, 0.5)
        RanarthLib:ApplyTheme(dialogBox, "BackgroundColor3", "ElementBG")
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
        RanarthLib:ApplyTheme(lblText, "TextColor3", "Text")
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
            RanarthLib:ApplyTheme(btn, "BackgroundColor3", "Hover")
            btn.Text = opt.Title
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 12
            btn.RichText = true
            btn.BackgroundTransparency = 1
            btn.TextTransparency = 1
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            RanarthLib:TrackConnection(btn.MouseEnter:Connect(function() tweens:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 60, 90)}):Play() end))
            RanarthLib:TrackConnection(btn.MouseLeave:Connect(function() tweens:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = RanarthLib.CurrentTheme.Hover}):Play() end))

            RanarthLib:TrackConnection(btn.MouseButton1Click:Connect(function()
                closeDialog()
                if opt.Callback then opt.Callback() end
            end))
        end

        RanarthLib:TrackConnection(dLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            dialogBox.Size = UDim2.new(0, 320, 0, dLayout.AbsoluteContentSize.Y + 30)
        end))

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
        RanarthLib:ApplyTheme(subFrame, "BackgroundColor3", "MainBG")
        subFrame.BorderSizePixel = 0
        subFrame.Active = true
        subFrame.ClipsDescendants = true
        Instance.new("UICorner", subFrame).CornerRadius = UDim.new(0, 10)
        animStroke(subFrame, 1.5)

        local sub_top_bar = Instance.new("Frame", subFrame)
        sub_top_bar.Size = UDim2.new(1, 0, 0, 30)
        RanarthLib:ApplyTheme(sub_top_bar, "BackgroundColor3", "Header")
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
        RanarthLib:ApplyTheme(minBtn, "BackgroundColor3", "SecondaryBG")
        minBtn.Text = "-"
        minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        minBtn.Font = Enum.Font.GothamBold
        minBtn.TextSize = 12
        Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)
        RanarthLib:TrackConnection(minBtn.MouseEnter:Connect(function() tweens:Create(minBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 40, 55)}):Play() end))
        RanarthLib:TrackConnection(minBtn.MouseLeave:Connect(function() tweens:Create(minBtn, TweenInfo.new(0.1), {BackgroundColor3 = RanarthLib.CurrentTheme.SecondaryBG}):Play() end))
        RanarthLib:TrackConnection(minBtn.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            tweens:Create(subFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, width, 0, isMinimized and 30 or height)}):Play()
        end))

        local clsBtn = Instance.new("TextButton", sub_control_buttons)
        clsBtn.Size = UDim2.new(0, 24, 0, 24)
        RanarthLib:ApplyTheme(clsBtn, "BackgroundColor3", "SecondaryBG")
        clsBtn.Text = "X"
        clsBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
        clsBtn.Font = Enum.Font.GothamBold
        clsBtn.TextSize = 12
        Instance.new("UICorner", clsBtn).CornerRadius = UDim.new(0, 4)
        RanarthLib:TrackConnection(clsBtn.MouseEnter:Connect(function() tweens:Create(clsBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 30, 40)}):Play() end))
        RanarthLib:TrackConnection(clsBtn.MouseLeave:Connect(function() tweens:Create(clsBtn, TweenInfo.new(0.1), {BackgroundColor3 = RanarthLib.CurrentTheme.SecondaryBG}):Play() end))
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

    -- ==========================================
    -- FLOATING BUTTON FEATURE
    -- ==========================================
    function Window:CreateFloatingButton(args)
        args = args or {}
        local text = args.Name or args.Title or args.Text or "Floating Button"
        local iconData = args.Icon or nil
        local callback = args.Callback or function() end

        local fBtn = Instance.new("TextButton")
        fBtn.Size = UDim2.new(0, 140, 0, 35)
        fBtn.Position = UDim2.new(0.5, -70, 0.1, 0)
        RanarthLib:ApplyTheme(fBtn, "BackgroundColor3", "ElementBG")
        fBtn.Text = ""
        fBtn.AutoButtonColor = false
        fBtn.AutomaticSize = Enum.AutomaticSize.X
        fBtn.Parent = gui

        Instance.new("UICorner", fBtn).CornerRadius = UDim.new(0, 6)
        local pad = Instance.new("UIPadding", fBtn)
        pad.PaddingLeft = UDim.new(0, 15)
        pad.PaddingRight = UDim.new(0, 15)

        -- Connect to the same gradient animation system
        animStroke(fBtn, 1.5)

        local contentFrame = Instance.new("Frame", fBtn)
        contentFrame.Size = UDim2.new(1, 0, 1, 0)
        contentFrame.BackgroundTransparency = 1

        local layout = Instance.new("UIListLayout", contentFrame)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 8)

        local img = nil
        if iconData then
            img = applyIcon(contentFrame, iconData)
            if img then img.Size = UDim2.new(0, 16, 0, 16) end
        end

        local txtLbl = Instance.new("TextLabel", contentFrame)
        txtLbl.AutomaticSize = Enum.AutomaticSize.X
        txtLbl.Size = UDim2.new(0, 0, 1, 0)
        txtLbl.BackgroundTransparency = 1
        txtLbl.Text = text
        RanarthLib:ApplyTheme(txtLbl, "TextColor3", "Text")
        txtLbl.Font = Enum.Font.GothamBold
        txtLbl.TextSize = 12

        RanarthLib:TrackConnection(fBtn.MouseEnter:Connect(function() tweens:Create(fBtn, TweenInfo.new(0.15), {BackgroundColor3 = RanarthLib.CurrentTheme.Hover}):Play() end))
        RanarthLib:TrackConnection(fBtn.MouseLeave:Connect(function() tweens:Create(fBtn, TweenInfo.new(0.15), {BackgroundColor3 = RanarthLib.CurrentTheme.ElementBG}):Play() end))

        local dragToggle, dragInputToggle, dragStartPos, startBtnPos, hasDragged = false, nil, nil, nil, false
        RanarthLib:TrackConnection(fBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragToggle = true; hasDragged = false; dragStartPos = input.Position; startBtnPos = fBtn.Position
                local releaseConn
                releaseConn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragToggle = false
                        if releaseConn then releaseConn:Disconnect() end
                    end
                end)
            end
        end))
        RanarthLib:TrackConnection(fBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputToggle = input end
        end))
        RanarthLib:SafeUIS(uis.InputChanged, fBtn, function(input)
            if input == dragInputToggle and dragToggle then
                local delta = input.Position - dragStartPos
                if delta.Magnitude > 5 then hasDragged = true end
                fBtn.Position = UDim2.new(startBtnPos.X.Scale, startBtnPos.X.Offset + delta.X, startBtnPos.Y.Scale, startBtnPos.Y.Offset + delta.Y)
            end
        end)
        
        RanarthLib:TrackConnection(fBtn.MouseButton1Click:Connect(function()
            if not hasDragged then callback() end
        end))

        return {
            Set = function(self, newText) txtLbl.Text = tostring(newText) end,
            SetVisible = function(self, isVisible) fBtn.Visible = isVisible end,
            Destroy = function(self) fBtn:Destroy() end
        }
    end

    function Window:CreateTab(args)
        local tabName = type(args) == "table" and (args.Name or args.Title) or args
        local tabIcon = type(args) == "table" and args.Icon or nil
        
        local Tab = { Container = nil }

        -- Namespace unik per-tab (dipakai sebagai upvalue oleh semua Elements:CreateX
        -- di bawah) supaya Flag dengan nama sama di tab berbeda tidak saling menimpa.
        Window.TabCount = (Window.TabCount or 0) + 1
        local tabNamespace = tostring(tabName) .. "#" .. tostring(Window.TabCount)
        
        local tabBtn = Instance.new("TextButton")
        if TabPosition == "Left" then
            tabBtn.Size = UDim2.new(1, 0, 0, 32)
            tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        else
            tabBtn.Size = UDim2.new(0, 0, 1, 0)
            tabBtn.AutomaticSize = Enum.AutomaticSize.X
        end
        RanarthLib:ApplyTheme(tabBtn, "BackgroundColor3", "SecondaryBG")
        tabBtn.Text = tabName
        RanarthLib:ApplyTheme(tabBtn, "TextColor3", "TextDark")
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 12
        tabBtn.RichText = true
        tabBtn.AutoButtonColor = false
        tabBtn.Parent = tab_container
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
        staticStroke(tabBtn, 1.2)

        local pad = Instance.new("UIPadding", tabBtn)
        if TabPosition == "Left" then
            pad.PaddingLeft = UDim.new(0, tabIcon and 32 or 12)
            pad.PaddingRight = UDim.new(0, 12)
        else
            pad.PaddingLeft = UDim.new(0, tabIcon and 34 or 16)
            pad.PaddingRight = UDim.new(0, 16)
        end

        if tabIcon then
            local iconImg = applyIcon(tabBtn, tabIcon)
            if iconImg then
                iconImg.Position = UDim2.new(0, -24, 0.5, -8)
            end
        end

        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 4
        RanarthLib:ApplyTheme(scrollFrame, "ScrollBarImageColor3", "Stroke1")
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
        
        RanarthLib:TrackConnection(scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 10)
        end))

        RanarthLib:TrackConnection(tabBtn.MouseButton1Click:Connect(function()
            if Window.ActiveTabBtn == tabBtn then return end
            for btn, frm in pairs(Window.Tabs) do
                frm.Visible = false
                tweens:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = RanarthLib.CurrentTheme.SecondaryBG, TextColor3 = RanarthLib.CurrentTheme.TextDark}):Play()
            end
            scrollFrame.Visible = true
            tweens:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = RanarthLib.CurrentTheme.Hover, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            Window.ActiveTabBtn = tabBtn
        end))

        Window.Tabs[tabBtn] = scrollFrame
        
        if not Window.ActiveTabBtn then
            scrollFrame.Visible = true
            RanarthLib:ApplyTheme(tabBtn, "BackgroundColor3", "Hover")
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
                RanarthLib:ApplyTheme(frame, "BackgroundColor3", "ElementBG")
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
                RanarthLib:ApplyTheme(titleLbl, "TextColor3", "Text")
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
                RanarthLib:ApplyTheme(lockOverlay, "BackgroundColor3", "MainBG")
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
                RanarthLib:ApplyTheme(lbl, "TextColor3", "Text")
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

                local currentColor = RanarthLib.CurrentTheme.ElementBG
                local currentHoverColor = RanarthLib.CurrentTheme.Hover

                RanarthLib:TrackConnection(btn.MouseEnter:Connect(function() 
                    tweens:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = currentHoverColor}):Play() 
                end))
                RanarthLib:TrackConnection(btn.MouseLeave:Connect(function() 
                    tweens:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = currentColor}):Play() 
                end))
                RanarthLib:TrackConnection(btn.MouseButton1Click:Connect(callback))

                local extendedCtrl = setmetatable({
                    SetColor = function(self, newColor, newHoverColor)
                        currentColor = newColor or RanarthLib.CurrentTheme.ElementBG
                        currentHoverColor = newHoverColor or RanarthLib.CurrentTheme.Hover
                        tweens:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = currentColor}):Play()
                    end,
                    ResetColor = function(self)
                        currentColor = RanarthLib.CurrentTheme.ElementBG
                        currentHoverColor = RanarthLib.CurrentTheme.Hover
                        tweens:Create(frame, TweenInfo.new(0.15), {BackgroundColor3 = currentColor}):Play()
                    end
                }, {__index = ctrl})

                return extendedCtrl
            end

            function Elements:CreateToggle(args)
                args = args or {}
                local callback = args.Callback or function() end
                local flag = args.Flag and (tabNamespace .. "::" .. args.Flag) or nil
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
                btn.BackgroundColor3 = state and RanarthLib.CurrentTheme.Accent or RanarthLib.CurrentTheme.SecondaryBG
                btn.Text = ""
                Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
                staticStroke(btn, 1.2)

                local circle = Instance.new("Frame", btn)
                circle.Size = UDim2.new(0, 14, 0, 14)
                circle.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                circle.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or RanarthLib.CurrentTheme.TextDark
                Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

                local function updateState(newState)
                    state = newState
                    if flag then
                        RanarthLib.Flags[flag] = state
                        if RanarthLib.AutoSaveEnabled then RanarthLib:SaveConfiguration() end
                    end
                    tweens:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and RanarthLib.CurrentTheme.Accent or RanarthLib.CurrentTheme.SecondaryBG}):Play()
                    tweens:Create(circle, TweenInfo.new(0.2), {
                        Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                        BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or RanarthLib.CurrentTheme.TextDark
                    }):Play()
                    callback(state)
                end

                RanarthLib:TrackConnection(btn.MouseButton1Click:Connect(function() updateState(not state) end))

                RanarthLib:TrackConnection(RanarthLib.OnThemeChanged.Event:Connect(function()
                    btn.BackgroundColor3 = state and RanarthLib.CurrentTheme.Accent or RanarthLib.CurrentTheme.SecondaryBG
                    circle.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or RanarthLib.CurrentTheme.TextDark
                end))

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
                local flag = args.Flag and (tabNamespace .. "::" .. args.Flag) or nil

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
                RanarthLib:ApplyTheme(bgBar, "BackgroundColor3", "SecondaryBG")
                Instance.new("UICorner", bgBar).CornerRadius = UDim.new(1, 0)

                local fill = Instance.new("Frame", bgBar)
                fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
                RanarthLib:ApplyTheme(fill, "BackgroundColor3", "Accent")
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

                RanarthLib:TrackConnection(hitBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true; update(input)
                    end
                end))
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
                        
                        if flag then
                            RanarthLib.Flags[flag] = numValue
                            if RanarthLib.AutoSaveEnabled then RanarthLib:SaveConfiguration() end
                        end
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
                local flag = args.Flag and (tabNamespace .. "::" .. args.Flag) or nil

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
                RanarthLib:ApplyTheme(icon, "TextColor3", "Text")
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
                RanarthLib:TrackConnection(topBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    local targetHeight = isOpen and math.min(140, (#options * 28) + 40) or 35
                    tweens:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
                    icon.Text = isOpen and "^" or "v"
                end))

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
                        RanarthLib:ApplyTheme(optBtn, "BackgroundColor3", "SecondaryBG")
                        optBtn.Text = opt
                        RanarthLib:ApplyTheme(optBtn, "TextColor3", "Text")
                        optBtn.Font = Enum.Font.Gotham
                        optBtn.TextSize = 11
                        Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
                        RanarthLib:TrackConnection(optBtn.MouseButton1Click:Connect(function() selectOpt(opt) end))
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
                local flag = args.Flag and (tabNamespace .. "::" .. args.Flag) or nil

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
                RanarthLib:ApplyTheme(icon, "TextColor3", "Text")

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
                RanarthLib:TrackConnection(topBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    tweens:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, isOpen and math.min(140, (#options * 28) + 40) or 35)}):Play()
                    icon.Text = isOpen and "^" or "v"
                end))

                for _, opt in ipairs(options) do
                    if selected[opt] == nil then selected[opt] = false end
                    local optBtn = Instance.new("TextButton", sFrame)
                    optBtn.Size = UDim2.new(1, -8, 0, 25)
                    RanarthLib:ApplyTheme(optBtn, "BackgroundColor3", "SecondaryBG")
                    optBtn.Text = (selected[opt] and "[x] " or "[ ] ") .. opt
                    RanarthLib:ApplyTheme(optBtn, "TextColor3", "Text")
                    optBtn.Font = Enum.Font.Gotham
                    optBtn.TextSize = 11
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

                    RanarthLib:TrackConnection(optBtn.MouseButton1Click:Connect(function()
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
                    end))
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
                RanarthLib:ApplyTheme(boxFrame, "BackgroundColor3", "SecondaryBG")
                Instance.new("UICorner", boxFrame).CornerRadius = UDim.new(0, 4)
                staticStroke(boxFrame, 1.2)

                local tBox = Instance.new("TextBox", boxFrame)
                tBox.Size = UDim2.new(1, -10, 1, 0)
                tBox.Position = UDim2.new(0, 5, 0, 0)
                tBox.BackgroundTransparency = 1
                tBox.Text = ""
                tBox.PlaceholderText = placeholder
                tBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                RanarthLib:ApplyTheme(tBox, "PlaceholderColor3", "TextDark")
                tBox.Font = Enum.Font.Gotham
                tBox.TextSize = 11
                tBox.ClearTextOnFocus = false

                RanarthLib:TrackConnection(tBox.FocusLost:Connect(function(enterPressed) callback(tBox.Text, enterPressed) end))

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
                RanarthLib:ApplyTheme(keyBtn, "BackgroundColor3", "SecondaryBG")
                keyBtn.Text = currentKey.Name
                keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                keyBtn.Font = Enum.Font.GothamBold
                keyBtn.TextSize = 11
                Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 4)
                local keyStroke = staticStroke(keyBtn, 1.2)

                local listening = false
                RanarthLib:TrackConnection(keyBtn.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    keyBtn.Text = "..."
                    RanarthLib:ApplyTheme(keyStroke, "Color", "Accent")
                    
                    local conn
                    conn = RanarthLib:SafeUIS(uis.InputBegan, frame, function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            keyBtn.Text = currentKey.Name
                            RanarthLib:ApplyTheme(keyStroke, "Color", "Stroke1")
                            listening = false
                            conn:Disconnect()
                            callback(currentKey)
                        end
                    end)
                end))

                return setmetatable({
                    SetKey = function(self, k) currentKey = k; keyBtn.Text = currentKey.Name end,
                    GetKey = function() return currentKey end
                }, {__index = ctrl})
            end

            function Elements:CreateColorPicker(args)
                args = args or {}
                local defaultColor = args.Color or args.Default or RanarthLib.CurrentTheme.Accent
                local callback = args.Callback or function() end
                local flag = args.Flag and (tabNamespace .. "::" .. args.Flag) or nil
                
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
                    RanarthLib:ApplyTheme(cLbl, "TextColor3", "Text")

                    local bgBar = Instance.new("Frame", sFrame)
                    bgBar.Size = UDim2.new(1, -25, 0, 6)
                    bgBar.Position = UDim2.new(0, 25, 0.5, -3)
                    RanarthLib:ApplyTheme(bgBar, "BackgroundColor3", "SecondaryBG")
                    Instance.new("UICorner", bgBar).CornerRadius = UDim.new(1, 0)

                    local fill = Instance.new("Frame", bgBar)
                    fill.Size = UDim2.new(initial / 255, 0, 1, 0)
                    RanarthLib:ApplyTheme(fill, "BackgroundColor3", "Accent")
                    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

                    local hitBtn = Instance.new("TextButton", bgBar)
                    hitBtn.Size = UDim2.new(1, 0, 1, 0)
                    hitBtn.BackgroundTransparency = 1
                    hitBtn.Text = ""

                    local dragging = false
                    RanarthLib:TrackConnection(hitBtn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            local pos = math.clamp((input.Position.X - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)
                            fill.Size = UDim2.new(pos, 0, 1, 0)
                            onChange(math.floor(pos * 255))
                        end
                    end))
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

                RanarthLib:TrackConnection(swatch.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    tweens:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, isOpen and 120 or 35)}):Play()
                end))

                return setmetatable({ GetColor = function() return currentColor end }, {__index = ctrl})
            end

            function Elements:CreateSearchBar(args)
                args = args or {}
                local placeholder = args.PlaceholderText or args.Placeholder or "Search features..."
                local sFrame = Instance.new("Frame", targetParent)
                sFrame.Size = UDim2.new(1, 0, 0, 32)
                RanarthLib:ApplyTheme(sFrame, "BackgroundColor3", "ElementBG")
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
                RanarthLib:ApplyTheme(searchBox, "PlaceholderColor3", "TextDark")
                searchBox.Font = Enum.Font.Gotham
                searchBox.TextSize = 12
                searchBox.TextXAlignment = Enum.TextXAlignment.Left
                searchBox.ClearTextOnFocus = false

                RanarthLib:TrackConnection(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
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
                end))
                return sFrame
            end

            function Elements:CreateDivider()
                local div = Instance.new("Frame", targetParent)
                div.Size = UDim2.new(1, 0, 0, 1)
                RanarthLib:ApplyTheme(div, "BackgroundColor3", "Stroke1")
                div.BorderSizePixel = 0
                ApplyFlex(div)
            end

            function Elements:CreateImagePanel(args)
            args = args or {}
            local titleText = args.Title or args.Name or "Preview"
            local descText = args.Content or args.Desc or "Description"
            local imageUrl = args.Image or ""
            
            local pFrame = Instance.new("Frame", targetParent)
            pFrame.Size = UDim2.new(1, 0, 0, 80)
            RanarthLib:ApplyTheme(pFrame, "BackgroundColor3", "ElementBG")
            Instance.new("UICorner", pFrame).CornerRadius = UDim.new(0, 6)
            staticStroke(pFrame, 1.2)
            ApplyFlex(pFrame)

            local imgPlaceholder = Instance.new("Frame", pFrame)
            imgPlaceholder.Size = UDim2.new(0, 60, 0, 60)
            imgPlaceholder.Position = UDim2.new(0, 10, 0, 10)
            RanarthLib:ApplyTheme(imgPlaceholder, "BackgroundColor3", "SecondaryBG")
            Instance.new("UICorner", imgPlaceholder).CornerRadius = UDim.new(0, 6)

            local imgNode = nil
            local hasImage = (imageUrl ~= nil and imageUrl ~= "")
            
            imgPlaceholder.Visible = hasImage
            
            if hasImage then
                imgNode = applyIcon(imgPlaceholder, imageUrl, true)
                if imgNode then
                    imgNode.Size = UDim2.new(1, 0, 1, 0)
                    Instance.new("UICorner", imgNode).CornerRadius = UDim.new(0, 6)
                end
            end

            local txtContainer = Instance.new("Frame", pFrame)
            txtContainer.Size = hasImage and UDim2.new(1, -90, 1, -20) or UDim2.new(1, -20, 1, -20)
            txtContainer.Position = hasImage and UDim2.new(0, 80, 0, 10) or UDim2.new(0, 10, 0, 10)
            txtContainer.BackgroundTransparency = 1
            
            local tLayout = Instance.new("UIListLayout", txtContainer)
            tLayout.SortOrder = Enum.SortOrder.LayoutOrder
            tLayout.Padding = UDim.new(0, 4)

            local lblTitle = Instance.new("TextLabel", txtContainer)
            lblTitle.Size = UDim2.new(1, 0, 0, 16)
            lblTitle.BackgroundTransparency = 1
            lblTitle.Text = titleText
            RanarthLib:ApplyTheme(lblTitle, "TextColor3", "Text")
            lblTitle.Font = Enum.Font.GothamBold
            lblTitle.TextSize = 13
            lblTitle.RichText = true
            lblTitle.TextXAlignment = Enum.TextXAlignment.Left

            local lblDesc = Instance.new("TextLabel", txtContainer)
            lblDesc.Size = UDim2.new(1, 0, 1, -20)
            lblDesc.BackgroundTransparency = 1
            lblDesc.Text = descText
            RanarthLib:ApplyTheme(lblDesc, "TextColor3", "TextDark")
            lblDesc.Font = Enum.Font.Gotham
            lblDesc.TextSize = 11
            lblDesc.RichText = true
            lblDesc.TextWrapped = true
            lblDesc.TextYAlignment = Enum.TextYAlignment.Top
            lblDesc.TextXAlignment = Enum.TextXAlignment.Left

            return {
                SetTitle = function(self, text) lblTitle.Text = text end,
                SetDesc = function(self, text) lblDesc.Text = text end,
                SetImage = function(self, id)
                    if imgNode then imgNode:Destroy() end
                    local _hasImg = (id ~= nil and id ~= "")
                    imgPlaceholder.Visible = _hasImg
                    txtContainer.Size = _hasImg and UDim2.new(1, -90, 1, -20) or UDim2.new(1, -20, 1, -20)
                    txtContainer.Position = _hasImg and UDim2.new(0, 80, 0, 10) or UDim2.new(0, 10, 0, 10)
                    
                    if _hasImg then
                        imgNode = applyIcon(imgPlaceholder, id, true)
                        if imgNode then
                            imgNode.Size = UDim2.new(1, 0, 1, 0)
                            Instance.new("UICorner", imgNode).CornerRadius = UDim.new(0, 6)
                        end
                    end
                end
            }
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
                RanarthLib:ApplyTheme(title, "TextColor3", "Text")
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
                    RanarthLib:ApplyTheme(desc, "TextColor3", "TextDark")
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
                RanarthLib:ApplyTheme(pbFrame, "BackgroundColor3", "ElementBG")
                Instance.new("UICorner", pbFrame).CornerRadius = UDim.new(0, 6)
                staticStroke(pbFrame, 1.2)
                ApplyFlex(pbFrame)

                local lbl = Instance.new("TextLabel", pbFrame)
                lbl.Size = UDim2.new(1, -20, 0, 20)
                lbl.Position = UDim2.new(0, 10, 0, 5)
                lbl.BackgroundTransparency = 1
                lbl.Text = title .. " : " .. tostring(defaultVal) .. " / " .. tostring(maxVal)
                RanarthLib:ApplyTheme(lbl, "TextColor3", "Text")
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 12
                lbl.RichText = true
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local bgBar = Instance.new("Frame", pbFrame)
                bgBar.Size = UDim2.new(1, -20, 0, 6)
                bgBar.Position = UDim2.new(0, 10, 0, 30)
                RanarthLib:ApplyTheme(bgBar, "BackgroundColor3", "SecondaryBG")
                Instance.new("UICorner", bgBar).CornerRadius = UDim.new(1, 0)

                local fill = Instance.new("Frame", bgBar)
                fill.Size = UDim2.new(math.clamp(defaultVal/maxVal, 0, 1), 0, 1, 0)
                RanarthLib:ApplyTheme(fill, "BackgroundColor3", "Accent")
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
                RanarthLib:ApplyTheme(cbFrame, "BackgroundColor3", "MainBG")
                Instance.new("UICorner", cbFrame).CornerRadius = UDim.new(0, 6)
                staticStroke(cbFrame, 1.2)
                ApplyFlex(cbFrame)

                local topBar = Instance.new("Frame", cbFrame)
                topBar.Size = UDim2.new(1, 0, 0, 25)
                RanarthLib:ApplyTheme(topBar, "BackgroundColor3", "Header")
                Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 6)
                
                local lbl = Instance.new("TextLabel", topBar)
                lbl.Size = UDim2.new(1, -10, 1, 0)
                lbl.Position = UDim2.new(0, 10, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = title
                RanarthLib:ApplyTheme(lbl, "TextColor3", "TextDark")
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 10
                lbl.RichText = true
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local copyBtn = Instance.new("TextButton", topBar)
                copyBtn.Size = UDim2.new(0, 40, 0, 15)
                copyBtn.Position = UDim2.new(1, -45, 0.5, -7.5)
                RanarthLib:ApplyTheme(copyBtn, "BackgroundColor3", "Hover")
                copyBtn.Text = "COPY"
                copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                copyBtn.Font = Enum.Font.GothamBold
                copyBtn.TextSize = 9
                Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)
                
                local isCopying = false
                RanarthLib:TrackConnection(copyBtn.MouseButton1Click:Connect(function()
                    if isCopying then return end
                    isCopying = true
                    if setclipboard then setclipboard(codeText) end
                    copyBtn.Text = "COPIED"
                    task.spawn(function()
                        task.wait(1.5)
                        copyBtn.Text = "COPY"
                        isCopying = false
                    end)
                end))

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
                RanarthLib:ApplyTheme(txt, "TextColor3", "Text")
                txt.Font = Enum.Font.Code
                txt.TextSize = 12
                txt.TextXAlignment = Enum.TextXAlignment.Left
                txt.TextYAlignment = Enum.TextYAlignment.Top

                local layout = Instance.new("UIListLayout", cbFrame)
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                local pad = Instance.new("UIPadding", cbFrame)
                pad.PaddingBottom = UDim.new(0, 5)
            end

            function Elements:CreateConsole(args)
                args = args or {}
                local height = args.Height or 150
                local showTimestamp = args.ShowTimestamp ~= false
                local maxLines = args.MaxLines or 200
                
                local consoleFrame = Instance.new("Frame", targetParent)
                consoleFrame.Size = UDim2.new(1, 0, 0, height)
                RanarthLib:ApplyTheme(consoleFrame, "BackgroundColor3", "ElementBG")
                Instance.new("UICorner", consoleFrame).CornerRadius = UDim.new(0, 6)
                staticStroke(consoleFrame, 1.2)
                ApplyFlex(consoleFrame)

                local topBar = Instance.new("Frame", consoleFrame)
                topBar.Size = UDim2.new(1, 0, 0, 20)
                RanarthLib:ApplyTheme(topBar, "BackgroundColor3", "Header")
                Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 6)

                local titleLbl = Instance.new("TextLabel", topBar)
                titleLbl.Size = UDim2.new(1, -60, 1, 0)
                titleLbl.Position = UDim2.new(0, 10, 0, 0)
                titleLbl.BackgroundTransparency = 1
                titleLbl.Text = args.Title or args.Name or "TERMINAL LOG"
                RanarthLib:ApplyTheme(titleLbl, "TextColor3", "TextDark")
                titleLbl.Font = Enum.Font.GothamBold
                titleLbl.TextSize = 10
                titleLbl.TextXAlignment = Enum.TextXAlignment.Left

                local clearBtn = Instance.new("TextButton", topBar)
                clearBtn.Size = UDim2.new(0, 45, 0, 14)
                clearBtn.Position = UDim2.new(1, -50, 0.5, -7)
                RanarthLib:ApplyTheme(clearBtn, "BackgroundColor3", "Hover")
                clearBtn.Text = "CLEAR"
                RanarthLib:ApplyTheme(clearBtn, "TextColor3", "Text")
                clearBtn.Font = Enum.Font.GothamBold
                clearBtn.TextSize = 9
                Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 4)

                local logScroll = Instance.new("ScrollingFrame", consoleFrame)
                logScroll.Size = UDim2.new(1, -10, 1, -25)
                logScroll.Position = UDim2.new(0, 5, 0, 25)
                logScroll.BackgroundTransparency = 1
                logScroll.ScrollBarThickness = 3
                logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                
                local logLayout = Instance.new("UIListLayout", logScroll)
                logLayout.SortOrder = Enum.SortOrder.LayoutOrder
                logLayout.Padding = UDim.new(0, 2)

                local pad = Instance.new("UIPadding", consoleFrame)
                pad.PaddingBottom = UDim.new(0, 5)
                
                RanarthLib:TrackConnection(logLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    logScroll.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 5)
                    logScroll.CanvasPosition = Vector2.new(0, logLayout.AbsoluteContentSize.Y)
                end))

                local function ClearLogs()
                    for _, child in ipairs(logScroll:GetChildren()) do
                        if child:IsA("TextLabel") then child:Destroy() end
                    end
                    logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                end

                RanarthLib:TrackConnection(clearBtn.MouseButton1Click:Connect(ClearLogs))
                
                local currentLogIndex = 0

                local function LogMessage(text, color)
                    currentLogIndex = currentLogIndex + 1
                    
                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, -5, 0, 14)
                    txt.BackgroundTransparency = 1
                    
                    local prefix = showTimestamp and string.format("[%s] ", os.date("%X")) or "> "
                    txt.Text = prefix .. tostring(text)
                    txt.TextColor3 = color or RanarthLib.CurrentTheme.Text
                    txt.Font = Enum.Font.Code
                    txt.TextSize = 11
                    txt.TextXAlignment = Enum.TextXAlignment.Left
                    txt.TextWrapped = true
                    txt.AutomaticSize = Enum.AutomaticSize.Y
                    txt.LayoutOrder = currentLogIndex
                    txt.Parent = logScroll
                    
                    local activeLogs = {}
                    for _, child in ipairs(logScroll:GetChildren()) do
                        if child:IsA("TextLabel") then table.insert(activeLogs, child) end
                    end
                    
                    if #activeLogs > maxLines then
                        table.sort(activeLogs, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
                        activeLogs[1]:Destroy()
                    end
                end

                return {
                    Print = function(self, text, color) LogMessage(text, color) end,
                    Warn = function(self, text) LogMessage("[WARN] " .. text, Color3.fromRGB(255, 200, 0)) end,
                    Error = function(self, text) LogMessage("[ERROR] " .. text, Color3.fromRGB(255, 80, 80)) end,
                    Success = function(self, text) LogMessage(text, Color3.fromRGB(100, 255, 100)) end,
                    Clear = function(self) ClearLogs() end
                }
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
                RanarthLib:ApplyTheme(gFrame, "BackgroundColor3", "ElementBG")
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
                    RanarthLib:ApplyTheme(lbl, "TextColor3", "TextDark")
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 11
                    lbl.RichText = true
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    local div = Instance.new("Frame", gFrame)
                    div.Size = UDim2.new(1, 0, 0, 1); RanarthLib:ApplyTheme(div, "BackgroundColor3", "Stroke1"); div.BorderSizePixel = 0
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
-- 7. BACKWARD-COMPATIBLE CONFIG ALIASES
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
