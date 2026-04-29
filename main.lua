--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║           STARLIGHT INTERFACE SUITE — v1.0.0                    ║
    ║       Premium Roblox UI Framework by Starlight Labs              ║
    ║                                                                  ║
    ║  Modular • Animated • Theming • Config • Notifications          ║
    ╚══════════════════════════════════════════════════════════════════╝
]]

local StarLight = {}
StarLight.__index = StarLight

-- ════════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════════
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")
local TextService      = game:GetService("TextService")

local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()
local Camera           = workspace.CurrentCamera

-- ════════════════════════════════════════════════════════════════════
--  UTILITY MODULE
-- ════════════════════════════════════════════════════════════════════
local Utility = {}

function Utility.Tween(instance, info, props)
    local tween = TweenService:Create(instance, info, props)
    tween:Play()
    return tween
end

function Utility.TweenInfo(t, style, dir, repeat_, reverse, delay)
    return TweenInfo.new(
        t or 0.2,
        Enum.EasingStyle[style or "Quad"],
        Enum.EasingDirection[dir or "Out"],
        repeat_ or 0,
        reverse or false,
        delay or 0
    )
end

function Utility.Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

function Utility.SafeCall(fn, ...)
    if type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then
            warn("[StarlightUI] Callback error: " .. tostring(err))
        end
    end
end

function Utility.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utility.RoundNumber(n, dec)
    local mult = 10 ^ (dec or 0)
    return math.floor(n * mult + 0.5) / mult
end

function Utility.FormatKey(key)
    local name = tostring(key):gsub("Enum.KeyCode.", "")
    return name
end

function Utility.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

function Utility.GetTextSize(text, size, font, frameSize)
    return TextService:GetTextSize(text, size, font, frameSize or Vector2.new(1000, 1000))
end

function Utility.Debounce(fn, wait)
    local last = 0
    return function(...)
        local now = tick()
        if now - last >= wait then
            last = now
            fn(...)
        end
    end
end

-- JSON helpers for config system
function Utility.JsonEncode(t)
    local ok, res = pcall(HttpService.JSONEncode, HttpService, t)
    return ok and res or "{}"
end

function Utility.JsonDecode(s)
    local ok, res = pcall(HttpService.JSONDecode, HttpService, s)
    return ok and res or {}
end

-- Executor detection
function Utility.GetExecutor()
    if identifyexecutor then
        local name, version = identifyexecutor()
        return name or "Unknown", version or ""
    elseif (getexecutorname or EXECUTOR_NAME) then
        return (getexecutorname and getexecutorname()) or EXECUTOR_NAME or "Unknown", ""
    end
    return "Unknown", ""
end

-- File system helpers (executor-safe)
function Utility.WriteFile(path, content)
    if writefile then
        pcall(writefile, path, content)
    end
end

function Utility.ReadFile(path)
    if readfile and isfile and isfile(path) then
        local ok, data = pcall(readfile, path)
        return ok and data or nil
    end
    return nil
end

function Utility.MakeFolder(path)
    if makefolder and not isfolder(path) then
        pcall(makefolder, path)
    end
end

-- ════════════════════════════════════════════════════════════════════
--  ANIMATION PRESETS
-- ════════════════════════════════════════════════════════════════════
local Animations = {
    Fast      = TweenInfo.new(0.12, Enum.EasingStyle.Quad,   Enum.EasingDirection.Out),
    Normal    = TweenInfo.new(0.22, Enum.EasingStyle.Quad,   Enum.EasingDirection.Out),
    Smooth    = TweenInfo.new(0.35, Enum.EasingStyle.Quart,  Enum.EasingDirection.Out),
    Spring    = TweenInfo.new(0.45, Enum.EasingStyle.Back,   Enum.EasingDirection.Out),
    Bounce    = TweenInfo.new(0.50, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    SlowFade  = TweenInfo.new(0.60, Enum.EasingStyle.Sine,   Enum.EasingDirection.InOut),
    Elastic   = TweenInfo.new(0.55, Enum.EasingStyle.Elastic,Enum.EasingDirection.Out),
}

-- ════════════════════════════════════════════════════════════════════
--  ICON SYSTEM
-- ════════════════════════════════════════════════════════════════════
local Icons = {
    -- Lucide-style icon IDs mapped to Roblox asset IDs or Unicode chars
    -- For Roblox we use rbxassetid:// or fallback text symbols
    Home        = "rbxassetid://7072706796",
    Settings    = "rbxassetid://7072722183",
    Star        = "rbxassetid://7072717081",
    Bell        = "rbxassetid://7072706161",
    Key         = "rbxassetid://7072706880",
    Eye         = "rbxassetid://7072706654",
    EyeOff      = "rbxassetid://7072706684",
    Lock        = "rbxassetid://7072718400",
    Unlock      = "rbxassetid://7072718438",
    Close       = "rbxassetid://7072725342",
    Check       = "rbxassetid://7072725218",
    Arrow       = "rbxassetid://7072725052",
    Palette     = "rbxassetid://7072719285",
    Folder      = "rbxassetid://7072706748",
    Save        = "rbxassetid://7072719557",
    Refresh     = "rbxassetid://7072719492",
    Info        = "rbxassetid://7072706824",
    Warning     = "rbxassetid://7072718664",
    Error       = "rbxassetid://7072706626",
    Success     = "rbxassetid://7072717081",
    Chevron     = "rbxassetid://6034818375",
    Discord     = "rbxassetid://7072706598",
    User        = "rbxassetid://7072717137",
    Gamepad     = "rbxassetid://7072706772",
    Slider      = "rbxassetid://7072706918",
    Dropdown    = "rbxassetid://6034818375",
}

function Icons.Get(name)
    return Icons[name] or ""
end

-- ════════════════════════════════════════════════════════════════════
--  THEME ENGINE
-- ════════════════════════════════════════════════════════════════════
local ThemeEngine = {}
ThemeEngine.__index = ThemeEngine

ThemeEngine.Themes = {
    ["Midnight"] = {
        -- Backgrounds
        Background      = Color3.fromHex("#0D0D12"),
        SecondaryBG     = Color3.fromHex("#13131A"),
        TertiaryBG      = Color3.fromHex("#1A1A24"),
        SidebarBG       = Color3.fromHex("#0A0A10"),
        TopbarBG        = Color3.fromHex("#0D0D12"),
        ElementBG       = Color3.fromHex("#1E1E2D"),
        HoverBG         = Color3.fromHex("#252535"),
        ActiveBG        = Color3.fromHex("#2A2A3F"),
        -- Foregrounds
        TextPrimary     = Color3.fromHex("#F0F0FF"),
        TextSecondary   = Color3.fromHex("#8888AA"),
        TextDisabled    = Color3.fromHex("#44445A"),
        -- Accents
        Accent          = Color3.fromHex("#7B6CFF"),
        AccentDark      = Color3.fromHex("#5A4DCC"),
        AccentLight     = Color3.fromHex("#9D91FF"),
        AccentGradient  = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#7B6CFF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#C26CFF")),
        }),
        -- Misc
        Divider         = Color3.fromHex("#252535"),
        Shadow          = Color3.fromHex("#000000"),
        Scrollbar       = Color3.fromHex("#333348"),
        Border          = Color3.fromHex("#2A2A3F"),
        -- Notifications
        NotifBG         = Color3.fromHex("#1A1A27"),
        NotifSuccess    = Color3.fromHex("#4ADE80"),
        NotifWarning    = Color3.fromHex("#FBBF24"),
        NotifError      = Color3.fromHex("#F87171"),
        NotifInfo       = Color3.fromHex("#60A5FA"),
        -- Toggle
        ToggleOff       = Color3.fromHex("#2A2A3F"),
        ToggleOn        = Color3.fromHex("#7B6CFF"),
    },
    ["Neon"] = {
        Background      = Color3.fromHex("#050508"),
        SecondaryBG     = Color3.fromHex("#0A0A10"),
        TertiaryBG      = Color3.fromHex("#0E0E18"),
        SidebarBG       = Color3.fromHex("#030305"),
        TopbarBG        = Color3.fromHex("#050508"),
        ElementBG       = Color3.fromHex("#111120"),
        HoverBG         = Color3.fromHex("#181830"),
        ActiveBG        = Color3.fromHex("#1D1D3A"),
        TextPrimary     = Color3.fromHex("#EEEEFF"),
        TextSecondary   = Color3.fromHex("#7777CC"),
        TextDisabled    = Color3.fromHex("#333360"),
        Accent          = Color3.fromHex("#00F5FF"),
        AccentDark      = Color3.fromHex("#00AACC"),
        AccentLight     = Color3.fromHex("#66FAFF"),
        AccentGradient  = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#00F5FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#00FF88")),
        }),
        Divider         = Color3.fromHex("#111120"),
        Shadow          = Color3.fromHex("#000000"),
        Scrollbar       = Color3.fromHex("#1A1A35"),
        Border          = Color3.fromHex("#00F5FF"),
        NotifBG         = Color3.fromHex("#0D0D20"),
        NotifSuccess    = Color3.fromHex("#00FF88"),
        NotifWarning    = Color3.fromHex("#FFCC00"),
        NotifError      = Color3.fromHex("#FF4466"),
        NotifInfo       = Color3.fromHex("#00F5FF"),
        ToggleOff       = Color3.fromHex("#1A1A35"),
        ToggleOn        = Color3.fromHex("#00F5FF"),
    },
    ["Sakura"] = {
        Background      = Color3.fromHex("#1A0E14"),
        SecondaryBG     = Color3.fromHex("#220F1A"),
        TertiaryBG      = Color3.fromHex("#2B1220"),
        SidebarBG       = Color3.fromHex("#150B10"),
        TopbarBG        = Color3.fromHex("#1A0E14"),
        ElementBG       = Color3.fromHex("#2E1522"),
        HoverBG         = Color3.fromHex("#3A1A2C"),
        ActiveBG        = Color3.fromHex("#421E33"),
        TextPrimary     = Color3.fromHex("#FFECF5"),
        TextSecondary   = Color3.fromHex("#CC88AA"),
        TextDisabled    = Color3.fromHex("#664455"),
        Accent          = Color3.fromHex("#FF6EA8"),
        AccentDark      = Color3.fromHex("#CC4480"),
        AccentLight     = Color3.fromHex("#FF99CC"),
        AccentGradient  = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#FF6EA8")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#FFB347")),
        }),
        Divider         = Color3.fromHex("#2E1522"),
        Shadow          = Color3.fromHex("#000000"),
        Scrollbar       = Color3.fromHex("#3A1A2C"),
        Border          = Color3.fromHex("#5C2240"),
        NotifBG         = Color3.fromHex("#2A1020"),
        NotifSuccess    = Color3.fromHex("#88FF88"),
        NotifWarning    = Color3.fromHex("#FFD700"),
        NotifError      = Color3.fromHex("#FF4466"),
        NotifInfo       = Color3.fromHex("#FF99CC"),
        ToggleOff       = Color3.fromHex("#3A1A2C"),
        ToggleOn        = Color3.fromHex("#FF6EA8"),
    },
    ["Frost"] = {
        Background      = Color3.fromHex("#EEF4FF"),
        SecondaryBG     = Color3.fromHex("#E4EEFF"),
        TertiaryBG      = Color3.fromHex("#DAE8FF"),
        SidebarBG       = Color3.fromHex("#D8E8FF"),
        TopbarBG        = Color3.fromHex("#EEF4FF"),
        ElementBG       = Color3.fromHex("#F8FBFF"),
        HoverBG         = Color3.fromHex("#E0EEFF"),
        ActiveBG        = Color3.fromHex("#CCDEFF"),
        TextPrimary     = Color3.fromHex("#1A2A4A"),
        TextSecondary   = Color3.fromHex("#5577AA"),
        TextDisabled    = Color3.fromHex("#99AACC"),
        Accent          = Color3.fromHex("#3B7FEE"),
        AccentDark      = Color3.fromHex("#2255CC"),
        AccentLight     = Color3.fromHex("#77AAFF"),
        AccentGradient  = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#3B7FEE")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#66CCFF")),
        }),
        Divider         = Color3.fromHex("#C8DCFF"),
        Shadow          = Color3.fromHex("#8899BB"),
        Scrollbar       = Color3.fromHex("#BBCCEE"),
        Border          = Color3.fromHex("#AACCEE"),
        NotifBG         = Color3.fromHex("#F0F6FF"),
        NotifSuccess    = Color3.fromHex("#22CC66"),
        NotifWarning    = Color3.fromHex("#EE9900"),
        NotifError      = Color3.fromHex("#EE3355"),
        NotifInfo       = Color3.fromHex("#3B7FEE"),
        ToggleOff       = Color3.fromHex("#C0D4EE"),
        ToggleOn        = Color3.fromHex("#3B7FEE"),
    },
    ["Ember"] = {
        Background      = Color3.fromHex("#12080A"),
        SecondaryBG     = Color3.fromHex("#1A0C0E"),
        TertiaryBG      = Color3.fromHex("#220E12"),
        SidebarBG       = Color3.fromHex("#0E0608"),
        TopbarBG        = Color3.fromHex("#12080A"),
        ElementBG       = Color3.fromHex("#261013"),
        HoverBG         = Color3.fromHex("#331318"),
        ActiveBG        = Color3.fromHex("#3D151A"),
        TextPrimary     = Color3.fromHex("#FFF0EC"),
        TextSecondary   = Color3.fromHex("#CC8877"),
        TextDisabled    = Color3.fromHex("#664444"),
        Accent          = Color3.fromHex("#FF5533"),
        AccentDark      = Color3.fromHex("#CC3311"),
        AccentLight     = Color3.fromHex("#FF8866"),
        AccentGradient  = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#FF5533")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#FFAA00")),
        }),
        Divider         = Color3.fromHex("#261013"),
        Shadow          = Color3.fromHex("#000000"),
        Scrollbar       = Color3.fromHex("#331318"),
        Border          = Color3.fromHex("#4D1A1A"),
        NotifBG         = Color3.fromHex("#1E0D0F"),
        NotifSuccess    = Color3.fromHex("#88FF66"),
        NotifWarning    = Color3.fromHex("#FFCC00"),
        NotifError      = Color3.fromHex("#FF3333"),
        NotifInfo       = Color3.fromHex("#FF8866"),
        ToggleOff       = Color3.fromHex("#331318"),
        ToggleOn        = Color3.fromHex("#FF5533"),
    },
    ["Ocean"] = {
        Background      = Color3.fromHex("#050E1A"),
        SecondaryBG     = Color3.fromHex("#071322"),
        TertiaryBG      = Color3.fromHex("#0A1A2C"),
        SidebarBG       = Color3.fromHex("#030C15"),
        TopbarBG        = Color3.fromHex("#050E1A"),
        ElementBG       = Color3.fromHex("#0C1F33"),
        HoverBG         = Color3.fromHex("#112844"),
        ActiveBG        = Color3.fromHex("#14304F"),
        TextPrimary     = Color3.fromHex("#E8F4FF"),
        TextSecondary   = Color3.fromHex("#6699BB"),
        TextDisabled    = Color3.fromHex("#334455"),
        Accent          = Color3.fromHex("#00AAFF"),
        AccentDark      = Color3.fromHex("#0077CC"),
        AccentLight     = Color3.fromHex("#44CCFF"),
        AccentGradient  = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#00AAFF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#00FFCC")),
        }),
        Divider         = Color3.fromHex("#0C1F33"),
        Shadow          = Color3.fromHex("#000000"),
        Scrollbar       = Color3.fromHex("#112844"),
        Border          = Color3.fromHex("#154466"),
        NotifBG         = Color3.fromHex("#091829"),
        NotifSuccess    = Color3.fromHex("#00FFAA"),
        NotifWarning    = Color3.fromHex("#FFBB00"),
        NotifError      = Color3.fromHex("#FF4455"),
        NotifInfo       = Color3.fromHex("#00AAFF"),
        ToggleOff       = Color3.fromHex("#112844"),
        ToggleOn        = Color3.fromHex("#00AAFF"),
    },
    ["Forest"] = {
        Background      = Color3.fromHex("#07100A"),
        SecondaryBG     = Color3.fromHex("#0B160E"),
        TertiaryBG      = Color3.fromHex("#101D12"),
        SidebarBG       = Color3.fromHex("#060D07"),
        TopbarBG        = Color3.fromHex("#07100A"),
        ElementBG       = Color3.fromHex("#132016"),
        HoverBG         = Color3.fromHex("#1A2B1C"),
        ActiveBG        = Color3.fromHex("#1F3322"),
        TextPrimary     = Color3.fromHex("#EAFFF0"),
        TextSecondary   = Color3.fromHex("#77AA88"),
        TextDisabled    = Color3.fromHex("#3A5540"),
        Accent          = Color3.fromHex("#44EE77"),
        AccentDark      = Color3.fromHex("#22BB55"),
        AccentLight     = Color3.fromHex("#88FFAA"),
        AccentGradient  = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#44EE77")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#AAFF44")),
        }),
        Divider         = Color3.fromHex("#132016"),
        Shadow          = Color3.fromHex("#000000"),
        Scrollbar       = Color3.fromHex("#1A2B1C"),
        Border          = Color3.fromHex("#224433"),
        NotifBG         = Color3.fromHex("#0D1A0F"),
        NotifSuccess    = Color3.fromHex("#44EE77"),
        NotifWarning    = Color3.fromHex("#EECC00"),
        NotifError      = Color3.fromHex("#FF4455"),
        NotifInfo       = Color3.fromHex("#88DDFF"),
        ToggleOff       = Color3.fromHex("#1A2B1C"),
        ToggleOn        = Color3.fromHex("#44EE77"),
    },
    ["Royal"] = {
        Background      = Color3.fromHex("#0C0A18"),
        SecondaryBG     = Color3.fromHex("#110E22"),
        TertiaryBG      = Color3.fromHex("#16122D"),
        SidebarBG       = Color3.fromHex("#090712"),
        TopbarBG        = Color3.fromHex("#0C0A18"),
        ElementBG       = Color3.fromHex("#1A1535"),
        HoverBG         = Color3.fromHex("#221C44"),
        ActiveBG        = Color3.fromHex("#28224F"),
        TextPrimary     = Color3.fromHex("#F5F0FF"),
        TextSecondary   = Color3.fromHex("#9988CC"),
        TextDisabled    = Color3.fromHex("#4A4466"),
        Accent          = Color3.fromHex("#AA77FF"),
        AccentDark      = Color3.fromHex("#7744CC"),
        AccentLight     = Color3.fromHex("#CCAAFF"),
        AccentGradient  = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#AA77FF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#FF77AA")),
        }),
        Divider         = Color3.fromHex("#1A1535"),
        Shadow          = Color3.fromHex("#000000"),
        Scrollbar       = Color3.fromHex("#221C44"),
        Border          = Color3.fromHex("#3A2A66"),
        NotifBG         = Color3.fromHex("#130F27"),
        NotifSuccess    = Color3.fromHex("#77FFAA"),
        NotifWarning    = Color3.fromHex("#FFD700"),
        NotifError      = Color3.fromHex("#FF4477"),
        NotifInfo       = Color3.fromHex("#AA77FF"),
        ToggleOff       = Color3.fromHex("#221C44"),
        ToggleOn        = Color3.fromHex("#AA77FF"),
    },
    ["Mono"] = {
        Background      = Color3.fromHex("#111111"),
        SecondaryBG     = Color3.fromHex("#181818"),
        TertiaryBG      = Color3.fromHex("#1F1F1F"),
        SidebarBG       = Color3.fromHex("#0D0D0D"),
        TopbarBG        = Color3.fromHex("#111111"),
        ElementBG       = Color3.fromHex("#222222"),
        HoverBG         = Color3.fromHex("#2A2A2A"),
        ActiveBG        = Color3.fromHex("#303030"),
        TextPrimary     = Color3.fromHex("#FFFFFF"),
        TextSecondary   = Color3.fromHex("#888888"),
        TextDisabled    = Color3.fromHex("#444444"),
        Accent          = Color3.fromHex("#CCCCCC"),
        AccentDark      = Color3.fromHex("#888888"),
        AccentLight     = Color3.fromHex("#EEEEEE"),
        AccentGradient  = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#888888")),
        }),
        Divider         = Color3.fromHex("#222222"),
        Shadow          = Color3.fromHex("#000000"),
        Scrollbar       = Color3.fromHex("#2A2A2A"),
        Border          = Color3.fromHex("#333333"),
        NotifBG         = Color3.fromHex("#1C1C1C"),
        NotifSuccess    = Color3.fromHex("#AAFFAA"),
        NotifWarning    = Color3.fromHex("#FFEE88"),
        NotifError      = Color3.fromHex("#FFAAAA"),
        NotifInfo       = Color3.fromHex("#AACCFF"),
        ToggleOff       = Color3.fromHex("#2A2A2A"),
        ToggleOn        = Color3.fromHex("#CCCCCC"),
    },
    ["Sunrise"] = {
        Background      = Color3.fromHex("#1A1005"),
        SecondaryBG     = Color3.fromHex("#221508"),
        TertiaryBG      = Color3.fromHex("#2B1C0B"),
        SidebarBG       = Color3.fromHex("#140C03"),
        TopbarBG        = Color3.fromHex("#1A1005"),
        ElementBG       = Color3.fromHex("#2E1E0D"),
        HoverBG         = Color3.fromHex("#3D2812"),
        ActiveBG        = Color3.fromHex("#4A3016"),
        TextPrimary     = Color3.fromHex("#FFF5E8"),
        TextSecondary   = Color3.fromHex("#CC9966"),
        TextDisabled    = Color3.fromHex("#664433"),
        Accent          = Color3.fromHex("#FF9933"),
        AccentDark      = Color3.fromHex("#CC6600"),
        AccentLight     = Color3.fromHex("#FFCC66"),
        AccentGradient  = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#FF9933")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#FF5599")),
        }),
        Divider         = Color3.fromHex("#2E1E0D"),
        Shadow          = Color3.fromHex("#000000"),
        Scrollbar       = Color3.fromHex("#3D2812"),
        Border          = Color3.fromHex("#5A3A1A"),
        NotifBG         = Color3.fromHex("#221508"),
        NotifSuccess    = Color3.fromHex("#88EE44"),
        NotifWarning    = Color3.fromHex("#FFDD00"),
        NotifError      = Color3.fromHex("#FF4444"),
        NotifInfo       = Color3.fromHex("#FF9933"),
        ToggleOff       = Color3.fromHex("#3D2812"),
        ToggleOn        = Color3.fromHex("#FF9933"),
    },
}

ThemeEngine.Current = "Midnight"
ThemeEngine.Listeners = {}

function ThemeEngine:Get()
    return self.Themes[self.Current]
end

function ThemeEngine:GetColor(key)
    local theme = self:Get()
    return theme and theme[key] or Color3.new(1,1,1)
end

function ThemeEngine:Set(name)
    if self.Themes[name] then
        self.Current = name
        for _, fn in ipairs(self.Listeners) do
            Utility.SafeCall(fn, self:Get())
        end
    end
end

function ThemeEngine:OnChange(fn)
    table.insert(self.Listeners, fn)
end

function ThemeEngine:GetThemeNames()
    local names = {}
    for k in pairs(self.Themes) do
        table.insert(names, k)
    end
    table.sort(names)
    return names
end

-- ════════════════════════════════════════════════════════════════════
--  CONFIG SYSTEM
-- ════════════════════════════════════════════════════════════════════
local ConfigSystem = {}
ConfigSystem.__index = ConfigSystem

function ConfigSystem.new(libraryName)
    local self = setmetatable({}, ConfigSystem)
    self.Name      = libraryName or "StarlightUI"
    self.Folder    = "StarlightConfigs/" .. self.Name
    self.Elements  = {} -- registered saveable elements
    self.AutoSave  = false
    Utility.MakeFolder("StarlightConfigs")
    Utility.MakeFolder(self.Folder)
    return self
end

function ConfigSystem:Register(key, element)
    self.Elements[key] = element
end

function ConfigSystem:Collect()
    local data = {}
    for key, elem in pairs(self.Elements) do
        if elem.Value ~= nil then
            data[key] = elem.Value
        end
    end
    return data
end

function ConfigSystem:Save(name)
    name = name or "default"
    local data = self:Collect()
    data["__theme"] = ThemeEngine.Current
    local path = self.Folder .. "/" .. name .. ".json"
    Utility.WriteFile(path, Utility.JsonEncode(data))
    return true
end

function ConfigSystem:Load(name)
    name = name or "default"
    local path = self.Folder .. "/" .. name .. ".json"
    local raw  = Utility.ReadFile(path)
    if not raw then return false end
    local data = Utility.JsonDecode(raw)
    if data["__theme"] then
        ThemeEngine:Set(data["__theme"])
    end
    for key, value in pairs(data) do
        if key ~= "__theme" and self.Elements[key] then
            local elem = self.Elements[key]
            if elem.SetValue then
                Utility.SafeCall(elem.SetValue, elem, value)
            end
        end
    end
    return true
end

function ConfigSystem:List()
    if listfiles then
        local ok, files = pcall(listfiles, self.Folder)
        if ok then
            local names = {}
            for _, f in ipairs(files) do
                local name = f:match("([^/\\]+)%.json$")
                if name then table.insert(names, name) end
            end
            return names
        end
    end
    return {}
end

-- ════════════════════════════════════════════════════════════════════
--  TOOLTIP SYSTEM
-- ════════════════════════════════════════════════════════════════════
local TooltipSystem = {}

local tooltipFrame = nil
local tooltipLabel = nil
local tooltipConn  = nil

local function EnsureTooltip(screenGui)
    if tooltipFrame then return end
    tooltipFrame = Utility.Create("Frame", {
        Name = "Tooltip",
        BackgroundColor3 = ThemeEngine:GetColor("TertiaryBG"),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 200, 0, 30),
        Visible = false,
        ZIndex = 9999,
        Parent = screenGui,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Utility.Create("UIStroke", {
            Color = ThemeEngine:GetColor("Border"),
            Thickness = 1,
        }),
    })
    tooltipLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = ThemeEngine:GetColor("TextSecondary"),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10000,
        Parent = tooltipFrame,
    })
end

function TooltipSystem.Attach(element, text, screenGui)
    if not text or text == "" then return end
    EnsureTooltip(screenGui)
    element.MouseEnter:Connect(function()
        tooltipLabel.Text = text
        local textW = Utility.GetTextSize(text, 12, Enum.Font.Gotham).X + 24
        tooltipFrame.Size = UDim2.new(0, math.max(textW, 80), 0, 28)
        tooltipFrame.Visible = true
    end)
    element.MouseLeave:Connect(function()
        tooltipFrame.Visible = false
    end)
    if tooltipConn then tooltipConn:Disconnect() end
    tooltipConn = RunService.RenderStepped:Connect(function()
        if tooltipFrame and tooltipFrame.Visible then
            local mx = Mouse.X + 14
            local my = Mouse.Y - 14
            local vp = Camera.ViewportSize
            if mx + tooltipFrame.AbsoluteSize.X > vp.X then
                mx = Mouse.X - tooltipFrame.AbsoluteSize.X - 8
            end
            if my < 0 then my = Mouse.Y + 20 end
            tooltipFrame.Position = UDim2.new(0, mx, 0, my)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ════════════════════════════════════════════════════════════════════
local NotificationSystem = {}
NotificationSystem.Queue  = {}
NotificationSystem.Active = {}
NotificationSystem.MaxVisible = 5
NotificationSystem.Container = nil

function NotificationSystem:Init(screenGui)
    self.Container = Utility.Create("Frame", {
        Name = "NotificationContainer",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.new(0, 320, 1, -32),
        BackgroundTransparency = 1,
        ZIndex = 9000,
        Parent = screenGui,
    }, {
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
        }),
    })
end

function NotificationSystem:Push(config)
    -- config: { Title, Body, Type, Duration, Icon }
    config = config or {}
    local title    = config.Title    or "Notification"
    local body     = config.Body     or ""
    local ntype    = config.Type     or "Info"     -- Info, Success, Warning, Error
    local duration = config.Duration or 4
    local theme    = ThemeEngine:Get()

    local accentColor = theme["Notif" .. ntype] or theme.NotifInfo

    local notif = Utility.Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.NotifBG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 9001,
        Parent = self.Container,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Utility.Create("UIStroke", {
            Color = accentColor,
            Thickness = 1,
            Transparency = 0.5,
        }),
    })

    -- Left accent bar
    local bar = Utility.Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        ZIndex = 9002,
        Parent = notif,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
    })

    local titleLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 20),
        Position = UDim2.new(0, 18, 0, 10),
        BackgroundTransparency = 1,
        TextColor3 = theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9003,
        Parent = notif,
    })

    local bodyLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -28, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 18, 0, 32),
        BackgroundTransparency = 1,
        TextColor3 = theme.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Text = body,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 9003,
        Parent = notif,
    })

    -- Progress bar
    local progress = Utility.Create("Frame", {
        Size = UDim2.new(1, -18, 0, 2),
        Position = UDim2.new(0, 18, 1, -6),
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 9003,
        Parent = notif,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
    })

    -- Close button
    local closeBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0, 6),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = theme.TextSecondary,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        ZIndex = 9004,
        Parent = notif,
    })

    -- Animate in
    notif.Position = UDim2.new(1, 320, 0, 0)
    Utility.Tween(notif, Animations.Spring, { Position = UDim2.new(0, 0, 0, 0) })

    -- Progress tween
    Utility.Tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2),
    })

    local function Dismiss()
        Utility.Tween(notif, Animations.Smooth, {
            Position = UDim2.new(1, 340, 0, 0),
            BackgroundTransparency = 1,
        })
        task.delay(0.4, function()
            notif:Destroy()
        end)
    end

    closeBtn.MouseButton1Click:Connect(Dismiss)
    task.delay(duration, Dismiss)

    table.insert(self.Active, notif)
end

-- ════════════════════════════════════════════════════════════════════
--  DRAG SYSTEM
-- ════════════════════════════════════════════════════════════════════
local DragSystem = {}

function DragSystem.Attach(dragTarget, dragHandle)
    dragHandle = dragHandle or dragTarget
    local dragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = dragTarget.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            -- Clamp to screen
            local vp = Camera.ViewportSize
            local absSize = dragTarget.AbsoluteSize
            local ox = math.clamp(newPos.X.Offset, 0, vp.X - absSize.X)
            local oy = math.clamp(newPos.Y.Offset, 0, vp.Y - absSize.Y)
            dragTarget.Position = UDim2.new(0, ox, 0, oy)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  MODAL SYSTEM
-- ════════════════════════════════════════════════════════════════════
local ModalSystem = {}
ModalSystem.Active = nil

function ModalSystem:Show(screenGui, config)
    -- config: { Title, Body, Buttons = { {Text, Callback, Style} } }
    local theme = ThemeEngine:Get()
    if self.Active then self.Active:Destroy() end

    local overlay = Utility.Create("Frame", {
        Name = "ModalOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        ZIndex = 8000,
        Parent = screenGui,
    })

    local modal = Utility.Create("Frame", {
        Name = "Modal",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 380, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.SecondaryBG,
        BorderSizePixel = 0,
        ZIndex = 8001,
        Parent = overlay,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIPadding", {
            PaddingTop    = UDim.new(0, 20),
            PaddingBottom = UDim.new(0, 20),
            PaddingLeft   = UDim.new(0, 24),
            PaddingRight  = UDim.new(0, 24),
        }),
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 12),
        }),
    })

    Utility.Create("TextLabel", {
        LayoutOrder = 1,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = config.Title or "Dialog",
        TextColor3 = theme.TextPrimary,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8002,
        Parent = modal,
    })

    if config.Body then
        Utility.Create("TextLabel", {
            LayoutOrder = 2,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = config.Body,
            TextColor3 = theme.TextSecondary,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 8002,
            Parent = modal,
        })
    end

    -- Divider
    Utility.Create("Frame", {
        LayoutOrder = 3,
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = theme.Divider,
        BorderSizePixel = 0,
        ZIndex = 8002,
        Parent = modal,
    })

    local btnRow = Utility.Create("Frame", {
        LayoutOrder = 4,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        ZIndex = 8002,
        Parent = modal,
    }, {
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
        }),
    })

    for _, btn in ipairs(config.Buttons or { { Text = "OK" } }) do
        local isPrimary = btn.Style == "Primary"
        local button = Utility.Create("TextButton", {
            Size = UDim2.new(0, 90, 0, 34),
            BackgroundColor3 = isPrimary and theme.Accent or theme.ElementBG,
            BorderSizePixel = 0,
            Text = btn.Text or "OK",
            TextColor3 = isPrimary and Color3.new(1,1,1) or theme.TextPrimary,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            ZIndex = 8003,
            Parent = btnRow,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        })
        button.MouseButton1Click:Connect(function()
            overlay:Destroy()
            self.Active = nil
            Utility.SafeCall(btn.Callback)
        end)
        button.MouseEnter:Connect(function()
            Utility.Tween(button, Animations.Fast, {
                BackgroundColor3 = isPrimary and theme.AccentLight or theme.HoverBG
            })
        end)
        button.MouseLeave:Connect(function()
            Utility.Tween(button, Animations.Fast, {
                BackgroundColor3 = isPrimary and theme.Accent or theme.ElementBG
            })
        end)
    end

    self.Active = overlay

    -- Animate in
    modal.Position = UDim2.new(0.5, 0, 0.6, 0)
    modal.BackgroundTransparency = 1
    Utility.Tween(modal, Animations.Spring, {
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0,
    })

    overlay.BackgroundTransparency = 1
    Utility.Tween(overlay, Animations.Fast, { BackgroundTransparency = 0.5 })

    -- Close on overlay click
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            overlay:Destroy()
            self.Active = nil
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  KEY SYSTEM
-- ════════════════════════════════════════════════════════════════════
local KeySystem = {}

function KeySystem.new(config)
    -- config: { Title, Key, SavedKey, Callback, HWID }
    local self = {
        Title    = config.Title or "Key System",
        Key      = config.Key   or "",
        Callback = config.Callback,
        Verified = false,
    }

    -- Check if key is already saved
    local saved = Utility.ReadFile("StarlightConfigs/keyauth.dat")
    if saved and saved == self.Key then
        self.Verified = true
        Utility.SafeCall(self.Callback, true)
        return self
    end

    -- Show key UI (simple stub; would integrate with real key service)
    warn("[StarlightUI KeySystem] Key verification required for: " .. self.Title)
    -- In a real executor this would show a proper GUI
    -- Here we call callback with false to indicate unverified state

    function self:Submit(input)
        if input == self.Key or self.Key == "" then
            self.Verified = true
            Utility.WriteFile("StarlightConfigs/keyauth.dat", input)
            Utility.SafeCall(self.Callback, true)
            return true
        else
            Utility.SafeCall(self.Callback, false)
            return false
        end
    end

    return self
end

-- ════════════════════════════════════════════════════════════════════
--  COLOR PICKER ELEMENT (popup system)
-- ════════════════════════════════════════════════════════════════════
local function CreateColorPicker(parent, value, callback, screenGui)
    local theme = ThemeEngine:Get()
    value = value or Color3.fromHex("#7B6CFF")

    local h, s, v = Color3.toHSV(value)

    local popup = Utility.Create("Frame", {
        Name = "ColorPickerPopup",
        Size = UDim2.new(0, 220, 0, 240),
        BackgroundColor3 = theme.SecondaryBG,
        BorderSizePixel = 0,
        ZIndex = 5000,
        Visible = false,
        Parent = screenGui,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 10) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
        }),
    })

    -- Saturation/Value field (2D gradient)
    local svField = Utility.Create("ImageLabel", {
        Size = UDim2.new(1, 0, 0, 160),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        Image = "rbxassetid://4155801252",  -- white/black gradient overlay
        ZIndex = 5001,
        Parent = popup,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })

    -- SV cursor
    local svCursor = Utility.Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(s, 0, 1 - v, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 5002,
        Parent = svField,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIStroke", { Color = Color3.new(0,0,0), Thickness = 2 }),
    })

    -- Hue bar
    local hueBar = Utility.Create("ImageLabel", {
        Position = UDim2.new(0, 0, 0, 172),
        Size = UDim2.new(1, 0, 0, 16),
        Image = "rbxassetid://698052001",
        ZIndex = 5001,
        Parent = popup,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
    })

    local hueCursor = Utility.Create("Frame", {
        Size = UDim2.new(0, 10, 1, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(h, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
        ZIndex = 5002,
        Parent = hueBar,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
        Utility.Create("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1 }),
    })

    -- Hex input
    local hexInput = Utility.Create("TextBox", {
        Position = UDim2.new(0, 0, 0, 198),
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = theme.ElementBG,
        BorderSizePixel = 0,
        Text = string.format("#%02X%02X%02X",
            math.floor(value.R * 255),
            math.floor(value.G * 255),
            math.floor(value.B * 255)),
        TextColor3 = theme.TextPrimary,
        TextSize = 12,
        Font = Enum.Font.Code,
        ZIndex = 5001,
        PlaceholderText = "#RRGGBB",
        Parent = popup,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Utility.Create("UIPadding", { PaddingLeft = UDim.new(0, 8) }),
    })

    local currentColor = value
    local function UpdateColor()
        currentColor = Color3.fromHSV(h, s, v)
        svField.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
        hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
        hexInput.Text = string.format("#%02X%02X%02X",
            math.floor(currentColor.R * 255),
            math.floor(currentColor.G * 255),
            math.floor(currentColor.B * 255))
        Utility.SafeCall(callback, currentColor)
    end

    -- SV field interaction
    local svDragging = false
    svField.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            svDragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            svDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if svDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or
           inp.UserInputType == Enum.UserInputType.Touch) then
            local rel = svField.AbsolutePosition
            local sz  = svField.AbsoluteSize
            s = math.clamp((inp.Position.X - rel.X) / sz.X, 0, 1)
            v = math.clamp(1 - (inp.Position.Y - rel.Y) / sz.Y, 0, 1)
            UpdateColor()
        end
    end)

    -- Hue bar interaction
    local hueDragging = false
    hueBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            hueDragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            hueDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if hueDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or
           inp.UserInputType == Enum.UserInputType.Touch) then
            local rel = hueBar.AbsolutePosition
            local sz  = hueBar.AbsoluteSize
            h = math.clamp((inp.Position.X - rel.X) / sz.X, 0, 1)
            UpdateColor()
        end
    end)

    -- Hex input
    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:gsub("#", "")
        if #hex == 6 then
            local ok, col = pcall(Color3.fromHex, "#" .. hex)
            if ok then
                h, s, v = Color3.toHSV(col)
                UpdateColor()
            end
        end
    end)

    return popup, function() return currentColor end
end

-- ════════════════════════════════════════════════════════════════════
--  ELEMENT FACTORY
-- ════════════════════════════════════════════════════════════════════
local ElementFactory = {}

-- Shared element wrapper
local function WrapElement(inst, config, extraMethods)
    local elem = {
        Instance = inst,
        Locked   = false,
        Value    = config.Default,
        _callbacks = {},
    }

    function elem:Lock()
        self.Locked = true
        if inst then
            inst.BackgroundTransparency = 0.6
            for _, d in ipairs(inst:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    d.TextTransparency = 0.6
                end
            end
        end
    end

    function elem:Unlock()
        self.Locked = false
        if inst then
            inst.BackgroundTransparency = 0
            for _, d in ipairs(inst:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                    d.TextTransparency = 0
                end
            end
        end
    end

    function elem:OnChanged(fn)
        table.insert(self._callbacks, fn)
    end

    function elem:_fire(val)
        self.Value = val
        for _, fn in ipairs(self._callbacks) do
            Utility.SafeCall(fn, val)
        end
    end

    if extraMethods then
        for k, v in pairs(extraMethods) do
            elem[k] = v
        end
    end

    return elem
end

-- ─────────────────────────────────────────────
-- BUTTON
-- ─────────────────────────────────────────────
function ElementFactory.Button(parent, config, screenGui)
    local theme = ThemeEngine:Get()
    config = config or {}
    local text     = config.Text     or "Button"
    local callback = config.Callback
    local tooltip  = config.Tooltip  or ""
    local icon     = config.Icon

    local frame = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
        Parent = parent,
    })

    local btn = Utility.Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.ElementBG,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
        Parent = frame,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
    })

    -- Gradient accent on left edge
    local accent = Utility.Create("Frame", {
        Size = UDim2.new(0, 3, 0.6, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = btn,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
    })

    local iconImg
    if icon then
        iconImg = Utility.Create("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 14, 0.5, 0),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = theme.TextSecondary,
            ZIndex = 3,
            Parent = btn,
        })
    end

    local label = Utility.Create("TextLabel", {
        Size = UDim2.new(1, icon and -50 or -24, 1, 0),
        Position = UDim2.new(0, icon and 40 or 14, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = btn,
    })

    -- Ripple effect
    btn.MouseButton1Click:Connect(function()
        local elem = WrapElement(frame, config)
        if elem then end  -- just ensure table created
        -- ripple
        local ripple = Utility.Create("Frame", {
            Size = UDim2.new(0, 0, 0, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundColor3 = theme.Accent,
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            ZIndex = 4,
            ClipsDescendants = false,
            Parent = btn,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        })
        Utility.Tween(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
            Size = UDim2.new(1.5, 0, 1.5, 0),
            BackgroundTransparency = 1,
        })
        task.delay(0.4, function() ripple:Destroy() end)
        Utility.SafeCall(callback)
    end)

    btn.MouseEnter:Connect(function()
        Utility.Tween(btn, Animations.Fast, { BackgroundColor3 = theme.HoverBG })
        if iconImg then Utility.Tween(iconImg, Animations.Fast, { ImageColor3 = theme.Accent }) end
    end)
    btn.MouseLeave:Connect(function()
        Utility.Tween(btn, Animations.Fast, { BackgroundColor3 = theme.ElementBG })
        if iconImg then Utility.Tween(iconImg, Animations.Fast, { ImageColor3 = theme.TextSecondary }) end
    end)

    if tooltip ~= "" then TooltipSystem.Attach(btn, tooltip, screenGui) end

    local elem = WrapElement(frame, config)
    return elem
end

-- ─────────────────────────────────────────────
-- TOGGLE
-- ─────────────────────────────────────────────
function ElementFactory.Toggle(parent, config, screenGui)
    local theme = ThemeEngine:Get()
    config = config or {}
    local text     = config.Text    or "Toggle"
    local default  = config.Default ~= nil and config.Default or false
    local style    = config.Style   or "Switch"  -- "Switch" or "Checkbox"
    local tooltip  = config.Tooltip or ""

    local frame = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = theme.ElementBG,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
        Parent = parent,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
    })

    local label = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = frame,
    })

    local enabled = default
    local toggleWidget

    if style == "Switch" then
        -- Pill switch
        local switchBG = Utility.Create("Frame", {
            Size = UDim2.new(0, 42, 0, 22),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            BackgroundColor3 = enabled and theme.ToggleOn or theme.ToggleOff,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = frame,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        })
        local knob = Utility.Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, enabled and 22 or 4, 0.5, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = switchBG,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        })
        toggleWidget = { bg = switchBG, knob = knob }

        local function SetState(state, silent)
            enabled = state
            Utility.Tween(switchBG, Animations.Fast, {
                BackgroundColor3 = enabled and theme.ToggleOn or theme.ToggleOff
            })
            Utility.Tween(knob, Animations.Smooth, {
                Position = UDim2.new(0, enabled and 22 or 4, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
            })
        end

        frame.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
               inp.UserInputType == Enum.UserInputType.Touch then
                enabled = not enabled
                SetState(enabled)
                elem:_fire(enabled)
            end
        end)

        SetState(default, true)
    else
        -- Checkbox style
        local box = Utility.Create("Frame", {
            Size = UDim2.new(0, 20, 0, 20),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            BackgroundColor3 = enabled and theme.ToggleOn or theme.ToggleOff,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = frame,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
            Utility.Create("UIStroke", { Color = enabled and theme.Accent or theme.Border, Thickness = 1.5 }),
        })
        local checkMark = Utility.Create("ImageLabel", {
            Size = UDim2.new(0, 12, 0, 12),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Image = Icons.Get("Check"),
            ImageColor3 = Color3.new(1, 1, 1),
            ImageTransparency = enabled and 0 or 1,
            ZIndex = 3,
            Parent = box,
        })
        toggleWidget = { box = box, check = checkMark }

        local stroke = box:FindFirstChildOfClass("UIStroke")
        local function SetState(state, silent)
            enabled = state
            Utility.Tween(box, Animations.Fast, {
                BackgroundColor3 = enabled and theme.ToggleOn or theme.ToggleOff
            })
            Utility.Tween(checkMark, Animations.Fast, {
                ImageTransparency = enabled and 0 or 1
            })
            if stroke then
                Utility.Tween(stroke, Animations.Fast, {
                    Color = enabled and theme.Accent or theme.Border
                })
            end
        end

        frame.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
               inp.UserInputType == Enum.UserInputType.Touch then
                enabled = not enabled
                SetState(enabled)
                elem:_fire(enabled)
            end
        end)

        SetState(default, true)
    end

    frame.MouseEnter:Connect(function()
        Utility.Tween(frame, Animations.Fast, { BackgroundColor3 = theme.HoverBG })
    end)
    frame.MouseLeave:Connect(function()
        Utility.Tween(frame, Animations.Fast, { BackgroundColor3 = theme.ElementBG })
    end)

    if tooltip ~= "" then TooltipSystem.Attach(frame, tooltip, screenGui) end

    local elem = WrapElement(frame, config)
    elem.Value = default

    function elem:SetValue(val)
        if val ~= enabled then
            frame.InputBegan:Fire(Instance.new("InputObject"))  -- we'll just set directly
            enabled = val
            elem.Value = val
        end
    end

    return elem
end

-- ─────────────────────────────────────────────
-- SLIDER
-- ─────────────────────────────────────────────
function ElementFactory.Slider(parent, config, screenGui)
    local theme = ThemeEngine:Get()
    config = config or {}
    local text    = config.Text    or "Slider"
    local min     = config.Min     or 0
    local max     = config.Max     or 100
    local default = config.Default or min
    local suffix  = config.Suffix  or ""
    local step    = config.Step    or 1
    local tooltip = config.Tooltip or ""

    local value = math.clamp(default, min, max)

    local frame = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = theme.ElementBG,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
        Parent = parent,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
        }),
    })

    local headerRow = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = frame,
    })

    local nameLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = headerRow,
    })

    local valueBox = Utility.Create("TextBox", {
        Size = UDim2.new(0, 64, 1, 0),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = theme.TertiaryBG,
        BorderSizePixel = 0,
        Text = tostring(Utility.RoundNumber(value, 2)) .. suffix,
        TextColor3 = theme.Accent,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        ZIndex = 3,
        Parent = headerRow,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
        Utility.Create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }),
    })

    local track = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = theme.TertiaryBG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = frame,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })

    local fill = Utility.Create("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = track,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIGradient", {
            Color = theme.AccentGradient,
            Rotation = 90,
        }),
    })

    local knob = Utility.Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = track,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Utility.Create("UIStroke", { Color = theme.Accent, Thickness = 2 }),
    })

    local dragging = false
    local function UpdateSlider(inputX)
        local rel  = track.AbsolutePosition.X
        local size = track.AbsoluteSize.X
        local t    = math.clamp((inputX - rel) / size, 0, 1)
        value = Utility.RoundNumber(min + (max - min) * t, 2)
        -- Snap to step
        if step > 0 then
            value = min + math.round((value - min) / step) * step
        end
        value = math.clamp(value, min, max)
        local frac = (value - min) / (max - min)
        fill.Size  = UDim2.new(frac, 0, 1, 0)
        knob.Position = UDim2.new(frac, 0, 0.5, 0)
        valueBox.Text = tostring(Utility.RoundNumber(value, 2)) .. suffix
        return value
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local v = UpdateSlider(inp.Position.X)
            elem:_fire(v)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or
           inp.UserInputType == Enum.UserInputType.Touch) then
            local v = UpdateSlider(inp.Position.X)
            elem:_fire(v)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Textbox input
    valueBox.FocusLost:Connect(function()
        local n = tonumber(valueBox.Text:gsub(suffix, ""))
        if n then
            value = math.clamp(Utility.RoundNumber(n, 2), min, max)
            local frac = (value - min) / (max - min)
            fill.Size = UDim2.new(frac, 0, 1, 0)
            knob.Position = UDim2.new(frac, 0, 0.5, 0)
            valueBox.Text = tostring(value) .. suffix
            elem:_fire(value)
        else
            valueBox.Text = tostring(value) .. suffix
        end
    end)

    if tooltip ~= "" then TooltipSystem.Attach(frame, tooltip, screenGui) end

    local elem = WrapElement(frame, config)
    elem.Value = value

    function elem:SetValue(val)
        value = math.clamp(val, min, max)
        local frac = (value - min) / (max - min)
        fill.Size = UDim2.new(frac, 0, 1, 0)
        knob.Position = UDim2.new(frac, 0, 0.5, 0)
        valueBox.Text = tostring(value) .. suffix
        self.Value = value
    end

    return elem
end

-- ─────────────────────────────────────────────
-- INPUT / TEXTBOX
-- ─────────────────────────────────────────────
function ElementFactory.Input(parent, config, screenGui)
    local theme = ThemeEngine:Get()
    config = config or {}
    local text        = config.Text        or "Input"
    local placeholder = config.Placeholder or "Enter value..."
    local default     = config.Default     or ""
    local numeric     = config.Numeric     or false
    local password    = config.Password    or false
    local tooltip     = config.Tooltip     or ""

    local frame = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
        Parent = parent,
    })

    local nameLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = theme.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = frame,
    })

    local inputBG = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = theme.ElementBG,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = frame,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke", {
            Name = "BorderStroke",
            Color = theme.Border,
            Thickness = 1,
        }),
        Utility.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 36) }),
    })

    local tb = Utility.Create("TextBox", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = default,
        PlaceholderText = placeholder,
        PlaceholderColor3 = theme.TextDisabled,
        TextColor3 = theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 3,
        Parent = inputBG,
    })

    if password then
        tb.TextTransparency = 1  -- hide text
        -- show dots overlay
        local dots = Utility.Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = string.rep("•", #default),
            TextColor3 = theme.TextPrimary,
            TextSize = 16,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 4,
            Parent = inputBG,
        })
        tb:GetPropertyChangedSignal("Text"):Connect(function()
            dots.Text = string.rep("•", #tb.Text)
        end)
    end

    -- Eye toggle for password
    if password then
        local eyeBtn = Utility.Create("ImageButton", {
            Size = UDim2.new(0, 20, 0, 20),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            BackgroundTransparency = 1,
            Image = Icons.Get("Eye"),
            ImageColor3 = theme.TextDisabled,
            ZIndex = 4,
            Parent = inputBG,
        })
        local shown = false
        eyeBtn.MouseButton1Click:Connect(function()
            shown = not shown
            tb.TextTransparency = shown and 0 or 1
            eyeBtn.Image = shown and Icons.Get("EyeOff") or Icons.Get("Eye")
        end)
    end

    local borderStroke = inputBG:FindFirstChild("BorderStroke")
    tb.Focused:Connect(function()
        if borderStroke then
            Utility.Tween(borderStroke, Animations.Fast, { Color = theme.Accent })
        end
    end)
    tb.FocusLost:Connect(function(enter)
        if borderStroke then
            Utility.Tween(borderStroke, Animations.Fast, { Color = theme.Border })
        end
        if numeric then
            local n = tonumber(tb.Text)
            if not n then tb.Text = tostring(default or 0) end
        end
        elem:_fire(tb.Text)
    end)

    if tooltip ~= "" then TooltipSystem.Attach(inputBG, tooltip, screenGui) end

    local elem = WrapElement(frame, config)
    elem.Value = default

    function elem:SetValue(val)
        tb.Text = tostring(val)
        self.Value = val
    end

    function elem:GetValue()
        return tb.Text
    end

    return elem
end

-- ─────────────────────────────────────────────
-- LABEL
-- ─────────────────────────────────────────────
function ElementFactory.Label(parent, config, screenGui)
    local theme = ThemeEngine:Get()
    config = config or {}
    local text  = config.Text  or "Label"
    local color = config.Color or theme.TextSecondary
    local size  = config.Size  or 13
    local font  = config.Font  or "Gotham"

    local label = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color,
        TextSize = size,
        Font = Enum.Font[font] or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = config.LayoutOrder or 0,
        ZIndex = 2,
        Parent = parent,
    })

    local elem = WrapElement(label, config)

    function elem:SetText(t)
        label.Text = t
    end

    function elem:SetColor(c)
        label.TextColor3 = c
    end

    return elem
end

-- ─────────────────────────────────────────────
-- PARAGRAPH (rich text)
-- ─────────────────────────────────────────────
function ElementFactory.Paragraph(parent, config, screenGui)
    local theme = ThemeEngine:Get()
    config = config or {}
    local title = config.Title or ""
    local body  = config.Body  or ""

    local frame = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.ElementBG,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
        Parent = parent,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
        }),
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        }),
    })

    if title ~= "" then
        Utility.Create("TextLabel", {
            LayoutOrder = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = title,
            RichText = true,
            TextColor3 = theme.TextPrimary,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 2,
            Parent = frame,
        })
    end

    local bodyLabel = Utility.Create("TextLabel", {
        LayoutOrder = 2,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = body,
        RichText = true,
        TextColor3 = theme.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LineHeight = 1.4,
        ZIndex = 2,
        Parent = frame,
    })

    local elem = WrapElement(frame, config)

    function elem:SetBody(t)
        bodyLabel.Text = t
    end

    return elem
end

-- ─────────────────────────────────────────────
-- DIVIDER
-- ─────────────────────────────────────────────
function ElementFactory.Divider(parent, config, screenGui)
    local theme = ThemeEngine:Get()
    config = config or {}
    local text = config.Text or ""

    local frame = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
        Parent = parent,
    })

    if text == "" then
        Utility.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = theme.Divider,
            BorderSizePixel = 0,
            Parent = frame,
        })
    else
        local line1 = Utility.Create("Frame", {
            Size = UDim2.new(0.4, -8, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = theme.Divider,
            BorderSizePixel = 0,
            Parent = frame,
        })
        Utility.Create("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.2, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = theme.TextDisabled,
            TextSize = 10,
            Font = Enum.Font.GothamMedium,
            ZIndex = 2,
            Parent = frame,
        })
        local line2 = Utility.Create("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            Size = UDim2.new(0.4, -8, 0, 1),
            Position = UDim2.new(1, 0, 0.5, 0),
            BackgroundColor3 = theme.Divider,
            BorderSizePixel = 0,
            Parent = frame,
        })
    end

    return WrapElement(frame, config)
end

-- ─────────────────────────────────────────────
-- DROPDOWN
-- ─────────────────────────────────────────────
function ElementFactory.Dropdown(parent, config, screenGui)
    local theme = ThemeEngine:Get()
    config = config or {}
    local text     = config.Text     or "Dropdown"
    local options  = config.Options  or {}
    local default  = config.Default
    local multi    = config.Multi    or false
    local tooltip  = config.Tooltip  or ""

    local selected = multi and {} or default
    local open     = false

    local frame = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        LayoutOrder = config.LayoutOrder or 0,
        ZIndex = 10,
        Parent = parent,
    })

    local nameLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = theme.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
        Parent = frame,
    })

    local dropBtn = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = theme.ElementBG,
        BorderSizePixel = 0,
        ZIndex = 11,
        Parent = frame,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 36) }),
    })

    local selectedLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = multi and "Select options..." or (default or "Select..."),
        TextColor3 = (default or multi) and theme.TextPrimary or theme.TextDisabled,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
        Parent = dropBtn,
    })

    local chevron = Utility.Create("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        BackgroundTransparency = 1,
        Image = Icons.Get("Chevron"),
        ImageColor3 = theme.TextSecondary,
        ZIndex = 12,
        Parent = dropBtn,
    })

    -- Options popup
    local popup = Utility.Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = theme.SecondaryBG,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Scrollbar,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        ZIndex = 100,
        Visible = false,
        Parent = frame,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
        }),
    })

    local function UpdateLabel()
        if multi then
            local keys = {}
            for k in pairs(selected) do table.insert(keys, k) end
            if #keys == 0 then
                selectedLabel.Text = "Select options..."
                selectedLabel.TextColor3 = theme.TextDisabled
            else
                selectedLabel.Text = table.concat(keys, ", ")
                selectedLabel.TextColor3 = theme.TextPrimary
            end
        else
            selectedLabel.Text = selected or "Select..."
            selectedLabel.TextColor3 = selected and theme.TextPrimary or theme.TextDisabled
        end
    end

    local optionBtns = {}
    for _, opt in ipairs(options) do
        local isSelected = multi and (selected[opt] ~= nil) or (selected == opt)
        local optBtn = Utility.Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = isSelected and theme.ActiveBG or Color3.fromRGB(0,0,0),
            BackgroundTransparency = isSelected and 0 or 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 101,
            Parent = popup,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        })
        local checkIcon = Utility.Create("ImageLabel", {
            Size = UDim2.new(0, 14, 0, 14),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            BackgroundTransparency = 1,
            Image = Icons.Get("Check"),
            ImageColor3 = theme.Accent,
            ImageTransparency = isSelected and 0 or 1,
            ZIndex = 102,
            Parent = optBtn,
        })
        Utility.Create("TextLabel", {
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = opt,
            TextColor3 = isSelected and theme.TextPrimary or theme.TextSecondary,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 102,
            Parent = optBtn,
        })
        optionBtns[opt] = { btn = optBtn, check = checkIcon }

        optBtn.MouseButton1Click:Connect(function()
            if multi then
                if selected[opt] then
                    selected[opt] = nil
                    Utility.Tween(optBtn, Animations.Fast, { BackgroundTransparency = 1 })
                    Utility.Tween(checkIcon, Animations.Fast, { ImageTransparency = 1 })
                else
                    selected[opt] = true
                    Utility.Tween(optBtn, Animations.Fast, { BackgroundTransparency = 0, BackgroundColor3 = theme.ActiveBG })
                    Utility.Tween(checkIcon, Animations.Fast, { ImageTransparency = 0 })
                end
                UpdateLabel()
                elem:_fire(selected)
            else
                -- deselect all
                for _, data in pairs(optionBtns) do
                    data.btn.BackgroundTransparency = 1
                    data.check.ImageTransparency = 1
                end
                selected = opt
                optBtn.BackgroundTransparency = 0
                optBtn.BackgroundColor3 = theme.ActiveBG
                checkIcon.ImageTransparency = 0
                UpdateLabel()
                open = false
                Utility.Tween(popup, Animations.Smooth, { Size = UDim2.new(1, 0, 0, 0) })
                Utility.Tween(chevron, Animations.Fast, { Rotation = 0 })
                task.delay(0.35, function() popup.Visible = false end)
                elem:_fire(selected)
            end
        end)
        optBtn.MouseEnter:Connect(function()
            if not (not multi and selected == opt) then
                Utility.Tween(optBtn, Animations.Fast, { BackgroundColor3 = theme.HoverBG, BackgroundTransparency = 0 })
            end
        end)
        optBtn.MouseLeave:Connect(function()
            local isSel = multi and (selected[opt] ~= nil) or (selected == opt)
            Utility.Tween(optBtn, Animations.Fast, {
                BackgroundColor3 = theme.ActiveBG,
                BackgroundTransparency = isSel and 0 or 1,
            })
        end)
    end

    local maxH = math.min(#options * 36 + 20, 200)

    dropBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            open = not open
            popup.Visible = true
            Utility.Tween(popup, Animations.Smooth, {
                Size = UDim2.new(1, 0, 0, open and maxH or 0)
            })
            Utility.Tween(chevron, Animations.Fast, { Rotation = open and 180 or 0 })
            if not open then
                task.delay(0.35, function() popup.Visible = false end)
            end
        end
    end)

    if tooltip ~= "" then TooltipSystem.Attach(dropBtn, tooltip, screenGui) end

    UpdateLabel()
    local elem = WrapElement(frame, config)
    elem.Value = selected

    function elem:SetOptions(opts)
        -- Rebuild options list
        for _, child in ipairs(popup:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        options = opts
        -- (re-populate -- simplified)
    end

    function elem:SetValue(val)
        selected = val
        UpdateLabel()
        self.Value = val
    end

    return elem
end

-- ─────────────────────────────────────────────
-- KEYBIND
-- ─────────────────────────────────────────────
function ElementFactory.Keybind(parent, config, screenGui)
    local theme = ThemeEngine:Get()
    config = config or {}
    local text     = config.Text    or "Keybind"
    local default  = config.Default or Enum.KeyCode.Unknown
    local tooltip  = config.Tooltip or ""

    local bound   = default
    local binding = false

    local frame = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = theme.ElementBG,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
        Parent = parent,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
    })

    local nameLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = frame,
    })

    local keyBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0, 72, 0, 26),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = theme.TertiaryBG,
        BorderSizePixel = 0,
        Text = Utility.FormatKey(bound),
        TextColor3 = theme.Accent,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        ZIndex = 2,
        Parent = frame,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
    })

    keyBtn.MouseButton1Click:Connect(function()
        binding = true
        keyBtn.Text = "..."
        keyBtn.TextColor3 = theme.TextSecondary
        Utility.Tween(keyBtn, Animations.Fast, { BackgroundColor3 = theme.HoverBG })
    end)

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if binding and inp.UserInputType == Enum.UserInputType.Keyboard then
            binding = false
            bound = inp.KeyCode
            keyBtn.Text = Utility.FormatKey(bound)
            keyBtn.TextColor3 = theme.Accent
            Utility.Tween(keyBtn, Animations.Fast, { BackgroundColor3 = theme.TertiaryBG })
            elem:_fire(bound)
        end
    end)

    -- Hold to execute callback on keypress
    if config.Callback then
        UserInputService.InputBegan:Connect(function(inp, gpe)
            if not gpe and not binding and inp.KeyCode == bound then
                Utility.SafeCall(config.Callback, bound)
            end
        end)
    end

    frame.MouseEnter:Connect(function()
        Utility.Tween(frame, Animations.Fast, { BackgroundColor3 = theme.HoverBG })
    end)
    frame.MouseLeave:Connect(function()
        Utility.Tween(frame, Animations.Fast, { BackgroundColor3 = theme.ElementBG })
    end)

    if tooltip ~= "" then TooltipSystem.Attach(frame, tooltip, screenGui) end

    local elem = WrapElement(frame, config)
    elem.Value = bound

    function elem:SetValue(val)
        bound = val
        keyBtn.Text = Utility.FormatKey(val)
        self.Value = val
    end

    function elem:GetKey()
        return bound
    end

    return elem
end

-- ─────────────────────────────────────────────
-- COLOR PICKER ELEMENT
-- ─────────────────────────────────────────────
function ElementFactory.ColorPicker(parent, config, screenGui)
    local theme = ThemeEngine:Get()
    config = config or {}
    local text     = config.Text    or "Color"
    local default  = config.Default or Color3.fromHex("#7B6CFF")
    local tooltip  = config.Tooltip or ""

    local currentColor = default
    local popupOpen    = false

    local frame = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = theme.ElementBG,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
        Parent = parent,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
    })

    local nameLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = frame,
    })

    local colorPreview = Utility.Create("TextButton", {
        Size = UDim2.new(0, 36, 0, 26),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = currentColor,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 2,
        Parent = frame,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
    })

    local popup, getColor = CreateColorPicker(frame, default, function(col)
        currentColor = col
        colorPreview.BackgroundColor3 = col
        elem:_fire(col)
    end, screenGui)

    popup.Position = UDim2.new(0, 0, 1, 6)
    popup.ZIndex = 500
    popup.Parent = frame

    colorPreview.MouseButton1Click:Connect(function()
        popupOpen = not popupOpen
        popup.Visible = popupOpen
        if popupOpen then
            Utility.Tween(popup, Animations.Spring, {
                Size = UDim2.new(0, 220, 0, 240),
                BackgroundTransparency = 0,
            })
        else
            Utility.Tween(popup, Animations.Fast, {
                Size = UDim2.new(0, 220, 0, 0),
            })
            task.delay(0.25, function() popup.Visible = false end)
        end
    end)

    frame.MouseEnter:Connect(function()
        Utility.Tween(frame, Animations.Fast, { BackgroundColor3 = theme.HoverBG })
    end)
    frame.MouseLeave:Connect(function()
        Utility.Tween(frame, Animations.Fast, { BackgroundColor3 = theme.ElementBG })
    end)

    if tooltip ~= "" then TooltipSystem.Attach(frame, tooltip, screenGui) end

    local elem = WrapElement(frame, config)
    elem.Value = default

    function elem:SetValue(col)
        currentColor = col
        colorPreview.BackgroundColor3 = col
        self.Value = col
    end

    function elem:GetColor()
        return currentColor
    end

    return elem
end

-- ════════════════════════════════════════════════════════════════════
--  GROUPBOX
-- ════════════════════════════════════════════════════════════════════
local GroupBox = {}
GroupBox.__index = GroupBox

function GroupBox.new(parent, config, screenGui, configSystem)
    local self = setmetatable({}, GroupBox)
    local theme = ThemeEngine:Get()
    config = config or {}
    self.ScreenGui    = screenGui
    self.ConfigSystem = configSystem
    self.Collapsible  = config.Collapsible or false
    self.Collapsed    = false
    self.Elements     = {}

    -- Header
    self.Frame = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.SecondaryBG,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
        Parent = parent,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    self.Header = Utility.Create("Frame", {
        LayoutOrder = 1,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = self.Frame,
    }, {
        Utility.Create("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }),
    })

    -- Accent line
    Utility.Create("Frame", {
        Size = UDim2.new(0, 3, 0, 18),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = self.Header,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
    })

    local titleLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "Group",
        TextColor3 = theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = self.Header,
    })

    local chevron
    if self.Collapsible then
        chevron = Utility.Create("ImageLabel", {
            Size = UDim2.new(0, 14, 0, 14),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Image = Icons.Get("Chevron"),
            ImageColor3 = theme.TextSecondary,
            ZIndex = 3,
            Parent = self.Header,
        })
    end

    -- Divider
    Utility.Create("Frame", {
        LayoutOrder = 2,
        Size = UDim2.new(1, -28, 0, 1),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundColor3 = theme.Divider,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = self.Frame,
    })

    -- Content area
    self.Content = Utility.Create("Frame", {
        LayoutOrder = 3,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 2,
        Parent = self.Frame,
    }, {
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
        }),
    })

    if self.Collapsible then
        self.Header.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or
               inp.UserInputType == Enum.UserInputType.Touch then
                self.Collapsed = not self.Collapsed
                self.Content.Visible = not self.Collapsed
                if chevron then
                    Utility.Tween(chevron, Animations.Fast, {
                        Rotation = self.Collapsed and -90 or 0
                    })
                end
            end
        end)
    end

    return self
end

function GroupBox:AddButton(config)
    local elem = ElementFactory.Button(self.Content, config, self.ScreenGui)
    if self.ConfigSystem and config.Key then
        self.ConfigSystem:Register(config.Key, elem)
    end
    table.insert(self.Elements, elem)
    return elem
end

function GroupBox:AddToggle(config)
    local elem = ElementFactory.Toggle(self.Content, config, self.ScreenGui)
    if self.ConfigSystem and config.Key then
        self.ConfigSystem:Register(config.Key, elem)
    end
    table.insert(self.Elements, elem)
    return elem
end

function GroupBox:AddSlider(config)
    local elem = ElementFactory.Slider(self.Content, config, self.ScreenGui)
    if self.ConfigSystem and config.Key then
        self.ConfigSystem:Register(config.Key, elem)
    end
    table.insert(self.Elements, elem)
    return elem
end

function GroupBox:AddInput(config)
    local elem = ElementFactory.Input(self.Content, config, self.ScreenGui)
    if self.ConfigSystem and config.Key then
        self.ConfigSystem:Register(config.Key, elem)
    end
    table.insert(self.Elements, elem)
    return elem
end

function GroupBox:AddLabel(config)
    local elem = ElementFactory.Label(self.Content, config, self.ScreenGui)
    table.insert(self.Elements, elem)
    return elem
end

function GroupBox:AddParagraph(config)
    local elem = ElementFactory.Paragraph(self.Content, config, self.ScreenGui)
    table.insert(self.Elements, elem)
    return elem
end

function GroupBox:AddDivider(config)
    local elem = ElementFactory.Divider(self.Content, config, self.ScreenGui)
    table.insert(self.Elements, elem)
    return elem
end

function GroupBox:AddDropdown(config)
    local elem = ElementFactory.Dropdown(self.Content, config, self.ScreenGui)
    if self.ConfigSystem and config.Key then
        self.ConfigSystem:Register(config.Key, elem)
    end
    table.insert(self.Elements, elem)
    return elem
end

function GroupBox:AddKeybind(config)
    local elem = ElementFactory.Keybind(self.Content, config, self.ScreenGui)
    if self.ConfigSystem and config.Key then
        self.ConfigSystem:Register(config.Key, elem)
    end
    table.insert(self.Elements, elem)
    return elem
end

function GroupBox:AddColorPicker(config)
    local elem = ElementFactory.ColorPicker(self.Content, config, self.ScreenGui)
    if self.ConfigSystem and config.Key then
        self.ConfigSystem:Register(config.Key, elem)
    end
    table.insert(self.Elements, elem)
    return elem
end

function GroupBox:AddGroupBox(config)
    local gb = GroupBox.new(self.Content, config, self.ScreenGui, self.ConfigSystem)
    table.insert(self.Elements, gb)
    return gb
end

-- ════════════════════════════════════════════════════════════════════
--  TAB SYSTEM
-- ════════════════════════════════════════════════════════════════════
local TabSystem = {}
TabSystem.__index = TabSystem

function TabSystem.new(sideBar, contentArea, screenGui, configSystem)
    local self = setmetatable({}, TabSystem)
    self.SideBar     = sideBar
    self.Content     = contentArea
    self.ScreenGui   = screenGui
    self.ConfigSys   = configSystem
    self.Tabs        = {}
    self.ActiveTab   = nil
    return self
end

function TabSystem:AddTab(config)
    local theme = ThemeEngine:Get()
    config = config or {}
    local name = config.Name or ("Tab " .. (#self.Tabs + 1))
    local icon = config.Icon

    -- Sidebar button
    local tabBtn = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        LayoutOrder = #self.Tabs + 1,
        Parent = self.SideBar,
    })

    local indicator = Utility.Create("Frame", {
        Size = UDim2.new(0, 3, 0.6, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = tabBtn,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
    })

    local btnBG = Utility.Create("Frame", {
        Size = UDim2.new(1, -6, 0, 36),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 6, 0.5, 0),
        BackgroundColor3 = theme.TertiaryBG,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = tabBtn,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
    })

    local iconImg
    if icon then
        iconImg = Utility.Create("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 10, 0.5, 0),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = theme.TextSecondary,
            ZIndex = 3,
            Parent = btnBG,
        })
    end

    local nameLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, icon and -36 or -12, 1, 0),
        Position = UDim2.new(0, icon and 34 or 10, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = theme.TextSecondary,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = btnBG,
    })

    -- Content page (scrollable)
    local page = Utility.Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Scrollbar,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 2,
        Parent = self.Content,
    }, {
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        }),
        Utility.Create("UIPadding", {
            PaddingTop    = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 16),
            PaddingLeft   = UDim.new(0, 12),
            PaddingRight  = UDim.new(0, 12),
        }),
    })

    local tabData = {
        Name       = name,
        Button     = tabBtn,
        BG         = btnBG,
        Indicator  = indicator,
        Icon       = iconImg,
        Label      = nameLabel,
        Page       = page,
        GroupBoxes = {},
    }

    -- Click handler
    local clickArea = Utility.Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 4,
        Parent = tabBtn,
    })

    clickArea.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)

    clickArea.MouseEnter:Connect(function()
        if self.ActiveTab ~= tabData then
            Utility.Tween(btnBG, Animations.Fast, {
                BackgroundColor3 = theme.HoverBG,
                BackgroundTransparency = 0,
            })
        end
    end)
    clickArea.MouseLeave:Connect(function()
        if self.ActiveTab ~= tabData then
            Utility.Tween(btnBG, Animations.Fast, { BackgroundTransparency = 1 })
        end
    end)

    table.insert(self.Tabs, tabData)

    -- Select first tab automatically
    if #self.Tabs == 1 then
        self:SelectTab(tabData)
    end

    -- AddGroupBox on the tab
    function tabData:AddGroupBox(gbConfig, columns)
        columns = columns or 1
        local container

        if columns > 1 then
            -- Multi-column layout
            container = Utility.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder = #self.GroupBoxes + 1,
                Parent = page,
            }, {
                Utility.Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDim.new(0, 8),
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                }),
            })
            local colWidth = (1 / columns)
            local groups = {}
            for i = 1, columns do
                local colFrame = Utility.Create("Frame", {
                    Size = UDim2.new(colWidth, i < columns and -4 or 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    LayoutOrder = i,
                    Parent = container,
                }, {
                    Utility.Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 8),
                    }),
                })
                local gb = GroupBox.new(colFrame, gbConfig[i] or gbConfig, screenGui, configSystem)
                table.insert(groups, gb)
            end
            table.insert(self.GroupBoxes, container)
            return table.unpack(groups)
        else
            gbConfig = gbConfig or {}
            gbConfig.LayoutOrder = #self.GroupBoxes + 1
            local gb = GroupBox.new(page, gbConfig, screenGui, configSystem)
            table.insert(self.GroupBoxes, gb)
            return gb
        end
    end

    function tabData:AddSection(sectionConfig)
        sectionConfig = sectionConfig or {}
        local theme2 = ThemeEngine:Get()
        local sFrame = Utility.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = #self.GroupBoxes + 1,
            Parent = page,
        }, {
            Utility.Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
            }),
        })
        if sectionConfig.Title then
            Utility.Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                Text = sectionConfig.Title:upper(),
                TextColor3 = theme2.Accent,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1,
                Parent = sFrame,
            })
        end
        local gb = GroupBox.new(sFrame, sectionConfig, screenGui, configSystem)
        table.insert(self.GroupBoxes, sFrame)
        return gb
    end

    return tabData
end

function TabSystem:SelectTab(tabData)
    local theme = ThemeEngine:Get()

    -- Deactivate previous
    if self.ActiveTab then
        local prev = self.ActiveTab
        Utility.Tween(prev.BG, Animations.Fast, {
            BackgroundColor3 = theme.TertiaryBG,
            BackgroundTransparency = 1,
        })
        Utility.Tween(prev.Indicator, Animations.Fast, { BackgroundTransparency = 1 })
        prev.Label.TextColor3 = theme.TextSecondary
        if prev.Icon then prev.Icon.ImageColor3 = theme.TextSecondary end
        prev.Page.Visible = false
    end

    self.ActiveTab = tabData

    Utility.Tween(tabData.BG, Animations.Smooth, {
        BackgroundColor3 = theme.ActiveBG,
        BackgroundTransparency = 0,
    })
    Utility.Tween(tabData.Indicator, Animations.Smooth, { BackgroundTransparency = 0 })
    tabData.Label.TextColor3 = theme.TextPrimary
    tabData.Label.Font = Enum.Font.GothamBold
    if tabData.Icon then tabData.Icon.ImageColor3 = theme.Accent end
    tabData.Page.Visible = true
end

-- ════════════════════════════════════════════════════════════════════
--  DISCORD WIDGET
-- ════════════════════════════════════════════════════════════════════
local function CreateDiscordWidget(parent, config)
    local theme = ThemeEngine:Get()
    config = config or {}
    local inviteCode = config.InviteCode or "XXXXXXXX"
    local serverName = config.ServerName or "Discord Server"

    local widget = Utility.Create("Frame", {
        Size = UDim2.new(1, -24, 0, 50),
        BackgroundColor3 = Color3.fromHex("#5865F2"),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = parent,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Utility.Create("UIPadding", {
            PaddingLeft  = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
    })

    Utility.Create("ImageLabel", {
        Size = UDim2.new(0, 22, 0, 22),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Image = Icons.Get("Discord"),
        ImageColor3 = Color3.new(1, 1, 1),
        ZIndex = 4,
        Parent = widget,
    })

    Utility.Create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 18),
        Position = UDim2.new(0, 30, 0, 8),
        BackgroundTransparency = 1,
        Text = serverName,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = widget,
    })
    Utility.Create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 16),
        Position = UDim2.new(0, 30, 0, 26),
        BackgroundTransparency = 1,
        Text = "discord.gg/" .. inviteCode,
        TextColor3 = Color3.fromRGB(200, 200, 255),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = widget,
    })

    local joinBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0, 56, 0, 28),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Text = "Join",
        TextColor3 = Color3.fromHex("#5865F2"),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 4,
        Parent = widget,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })

    joinBtn.MouseButton1Click:Connect(function()
        -- In executor context, setclipboard
        if setclipboard then
            setclipboard("https://discord.gg/" .. inviteCode)
        end
        if config.Callback then
            Utility.SafeCall(config.Callback, inviteCode)
        end
    end)

    return widget
end

-- ════════════════════════════════════════════════════════════════════
--  MAIN WINDOW
-- ════════════════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    local theme = ThemeEngine:Get()

    config = config or {}
    self.Title       = config.Title       or "Starlight"
    self.Subtitle    = config.Subtitle    or "Interface Suite"
    self.Icon        = config.Icon        or Icons.Get("Star")
    self.Size        = config.Size        or UDim2.new(0, 760, 0, 520)
    self.ToggleKey   = config.ToggleKey   or Enum.KeyCode.K
    self.Visible     = true
    self.ConfigSys   = ConfigSystem.new(self.Title)
    self.Tabs        = {}

    -- ScreenGui
    self.ScreenGui = Utility.Create("ScreenGui", {
        Name = "StarlightUI_" .. self.Title:gsub(" ", ""),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })
    -- Safe parenting
    local ok = pcall(function() self.ScreenGui.Parent = CoreGui end)
    if not ok then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Init sub-systems
    NotificationSystem:Init(self.ScreenGui)

    -- ── Main window frame
    local vp = Camera.ViewportSize
    local winW = self.Size.X.Offset
    local winH = self.Size.Y.Offset

    self.MainFrame = Utility.Create("Frame", {
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = self.Size,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 1,
        Parent = self.ScreenGui,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
    })

    -- Drop shadow
    local shadow = Utility.Create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 8),
        Size = UDim2.new(1, 60, 1, 60),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 0,
        Parent = self.MainFrame,
    })

    -- ── Topbar
    self.Topbar = Utility.Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = theme.TopbarBG,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = self.MainFrame,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
    })
    -- Fix bottom corners
    Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme.TopbarBG,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = self.Topbar,
    })

    -- Icon
    if self.Icon and self.Icon ~= "" then
        Utility.Create("ImageLabel", {
            Size = UDim2.new(0, 22, 0, 22),
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 14, 0.5, 0),
            BackgroundTransparency = 1,
            Image = self.Icon,
            ImageColor3 = theme.Accent,
            ZIndex = 3,
            Parent = self.Topbar,
        })
    end

    -- Title
    local titleLabel = Utility.Create("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, self.Icon ~= "" and 44 or 14, 0.5, -5),
        Size = UDim2.new(0, 200, 0, 20),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = theme.TextPrimary,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = self.Topbar,
    })

    local subtitleLabel = Utility.Create("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, self.Icon ~= "" and 44 or 14, 0.5, 8),
        Size = UDim2.new(0, 200, 0, 16),
        BackgroundTransparency = 1,
        Text = self.Subtitle,
        TextColor3 = theme.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = self.Topbar,
    })

    -- Executor tag
    local execName = Utility.GetExecutor()
    Utility.Create("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 120, 0, 20),
        BackgroundTransparency = 1,
        Text = execName,
        TextColor3 = theme.TextDisabled,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        ZIndex = 3,
        Parent = self.Topbar,
    })

    -- Window controls
    local controls = Utility.Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 80, 0, 28),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = self.Topbar,
    }, {
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
        }),
    })

    -- Minimize
    local minBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = theme.ElementBG,
        BorderSizePixel = 0,
        Text = "─",
        TextColor3 = theme.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 4,
        Parent = controls,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })

    -- Close
    local closeBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = Color3.fromHex("#F87171"),
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        ZIndex = 4,
        Parent = controls,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })

    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle(false)
    end)
    minBtn.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    closeBtn.MouseEnter:Connect(function()
        Utility.Tween(closeBtn, Animations.Fast, { BackgroundColor3 = Color3.fromHex("#FCA5A5") })
    end)
    closeBtn.MouseLeave:Connect(function()
        Utility.Tween(closeBtn, Animations.Fast, { BackgroundColor3 = Color3.fromHex("#F87171") })
    end)

    -- Topbar gradient accent
    local topGrad = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = self.Topbar,
    }, {
        Utility.Create("UIGradient", {
            Color = theme.AccentGradient,
            Rotation = 90,
        }),
    })

    -- ── Body (sidebar + content)
    self.Body = Utility.Create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = self.MainFrame,
    })

    -- Sidebar
    self.SideBar = Utility.Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundColor3 = theme.SidebarBG,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = self.Body,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
    })
    -- Fix right corners
    Utility.Create("Frame", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = theme.SidebarBG,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = self.SideBar,
    })
    -- Fix top left
    Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundColor3 = theme.SidebarBG,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = self.SideBar,
    })

    local sideList = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 1, -20),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = self.SideBar,
    }, {
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        }),
        Utility.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }),
    })

    -- Bottom sidebar: theme selector + discord
    local sideBottom = Utility.Create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 110),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = self.SideBar,
    }, {
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 6),
        }),
        Utility.Create("UIPadding", {
            PaddingLeft  = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }),
    })

    -- Theme dropdown in sidebar
    local themeDD = Utility.Create("Frame", {
        LayoutOrder = 2,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.ElementBG,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = sideBottom,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke", { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
    })

    local themeLabel = Utility.Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "⬡  " .. ThemeEngine.Current,
        TextColor3 = theme.TextPrimary,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
        Parent = themeDD,
    })

    -- Content area
    self.ContentArea = Utility.Create("Frame", {
        Name = "Content",
        Position = UDim2.new(0, 160, 0, 0),
        Size = UDim2.new(1, -160, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = self.Body,
    })

    -- Tab system
    self.TabSys = TabSystem.new(sideList, self.ContentArea, self.ScreenGui, self.ConfigSys)

    -- Mobile toggle
    self.MobileToggle = Utility.Create("TextButton", {
        Size = UDim2.new(0, 50, 0, 50),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Text = "✦",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        ZIndex = 9999,
        Visible = Utility.IsMobile(),
        Parent = self.ScreenGui,
    }, {
        Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })

    self.MobileToggle.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- Drag
    DragSystem.Attach(self.MainFrame, self.Topbar)

    -- Keybind toggle
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end)

    -- Theme switcher logic
    local themeOpen = false
    local themePopup = Utility.Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 0, -4),
        BackgroundColor3 = theme.SecondaryBG,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Scrollbar,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 100,
        Parent = themeDD,
    }, {
        Utility.Create("UICorner",  { CornerRadius = UDim.new(0, 8) }),
        Utility.Create("UIStroke",  { Color = theme.Border, Thickness = 1 }),
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        }),
        Utility.Create("UIPadding", {
            PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
        }),
    })

    for _, tname in ipairs(ThemeEngine:GetThemeNames()) do
        local tBtn = Utility.Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = tname == ThemeEngine.Current and theme.ActiveBG or theme.ElementBG,
            BackgroundTransparency = tname == ThemeEngine.Current and 0 or 1,
            BorderSizePixel = 0,
            Text = tname,
            TextColor3 = tname == ThemeEngine.Current and theme.TextPrimary or theme.TextSecondary,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            ZIndex = 101,
            Parent = themePopup,
        }, {
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        })
        tBtn.MouseButton1Click:Connect(function()
            ThemeEngine:Set(tname)
            themeLabel.Text = "⬡  " .. tname
            themeOpen = false
            Utility.Tween(themePopup, Animations.Fast, { Size = UDim2.new(1, 0, 0, 0) })
            task.delay(0.25, function() themePopup.Visible = false end)
        end)
        tBtn.MouseEnter:Connect(function()
            if ThemeEngine.Current ~= tname then
                Utility.Tween(tBtn, Animations.Fast, { BackgroundTransparency = 0, BackgroundColor3 = ThemeEngine:GetColor("HoverBG") })
            end
        end)
        tBtn.MouseLeave:Connect(function()
            if ThemeEngine.Current ~= tname then
                Utility.Tween(tBtn, Animations.Fast, { BackgroundTransparency = 1 })
            end
        end)
    end

    themeDD.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            themeOpen = not themeOpen
            themePopup.Visible = true
            local maxH = math.min(ThemeEngine:GetThemeNames() and #ThemeEngine:GetThemeNames() * 32 or 200, 160)
            Utility.Tween(themePopup, Animations.Smooth, {
                Size = UDim2.new(1, 0, 0, themeOpen and maxH or 0)
            })
            if not themeOpen then
                task.delay(0.35, function() themePopup.Visible = false end)
            end
        end
    end)

    -- Discord widget
    if config.Discord then
        CreateDiscordWidget(sideBottom, config.Discord)
    end

    -- Animate in
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    self.MainFrame.BackgroundTransparency = 1
    task.wait()
    Utility.Tween(self.MainFrame, Animations.Spring, {
        Size = self.Size,
        BackgroundTransparency = 0,
    })

    self.Minimized = false

    return self
end

function Window:AddTab(config)
    local tab = self.TabSys:AddTab(config)
    table.insert(self.Tabs, tab)
    return tab
end

function Window:Toggle(state)
    if state == nil then state = not self.Visible end
    self.Visible = state
    if state then
        self.MainFrame.Visible = true
        Utility.Tween(self.MainFrame, Animations.Spring, {
            Size = self.Size,
            BackgroundTransparency = 0,
        })
    else
        Utility.Tween(self.MainFrame, Animations.Smooth, {
            Size = UDim2.new(0, self.Size.X.Offset, 0, 0),
            BackgroundTransparency = 1,
        })
        task.delay(0.4, function()
            if not self.Visible then
                self.MainFrame.Visible = false
            end
        end)
    end
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    if self.Minimized then
        Utility.Tween(self.MainFrame, Animations.Smooth, {
            Size = UDim2.new(0, self.Size.X.Offset, 0, 44),
        })
        self.Body.Visible = false
    else
        self.Body.Visible = true
        Utility.Tween(self.MainFrame, Animations.Spring, { Size = self.Size })
    end
end

function Window:Notify(config)
    NotificationSystem:Push(config)
end

function Window:ShowModal(config)
    ModalSystem:Show(self.ScreenGui, config)
end

function Window:SetTheme(name)
    ThemeEngine:Set(name)
end

function Window:SaveConfig(name)
    return self.ConfigSys:Save(name)
end

function Window:LoadConfig(name)
    return self.ConfigSys:Load(name)
end

function Window:ListConfigs()
    return self.ConfigSys:List()
end

function Window:Destroy()
    self.ScreenGui:Destroy()
end

-- ════════════════════════════════════════════════════════════════════
--  PUBLIC API
-- ════════════════════════════════════════════════════════════════════
StarLight.ThemeEngine    = ThemeEngine
StarLight.Icons          = Icons
StarLight.Animations     = Animations
StarLight.Utility        = Utility
StarLight.NotifSystem    = NotificationSystem
StarLight.KeySystem      = KeySystem

function StarLight:CreateWindow(config)
    return Window.new(config)
end

function StarLight:CreateKeySystem(config)
    return KeySystem.new(config)
end

return StarLight
