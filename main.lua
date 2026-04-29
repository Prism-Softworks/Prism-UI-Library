--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║       STARLIGHT INTERFACE SUITE — Example Usage Script          ║
    ║  Demonstrates every major feature: tabs, groups, all elements   ║
    ╚══════════════════════════════════════════════════════════════════╝
    
    USAGE INSIDE ROBLOX EXECUTOR:
    
    local StarLight = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/yourusername/StarlightUI/main/StarlightInterfaceSuite.lua"
    ))()
    
    OR if loaded locally:
    local StarLight = require(path.to.StarlightInterfaceSuite)
]]
 
-- ════════════════════════════════════════════════════════════════════
--  LOAD THE LIBRARY
--  (Replace the require below with your loadstring/require path)
-- ════════════════════════════════════════════════════════════════════
local StarLight = loadstring(readfile("StarlightInterfaceSuite.lua"))()
-- local StarLight = require(game.ReplicatedStorage.StarlightInterfaceSuite)
 
-- ════════════════════════════════════════════════════════════════════
--  OPTIONAL: KEY SYSTEM
-- ════════════════════════════════════════════════════════════════════
-- Uncomment to use a key gate before showing the UI:
--[[
local keyGate = StarLight:CreateKeySystem({
    Title    = "My Script",
    Key      = "STARLIGHT2024",
    Callback = function(verified)
        if not verified then
            warn("Invalid key!")
            return
        end
        -- Build your UI here (wrapped in the gate)
    end,
})
-- Later: keyGate:Submit("STARLIGHT2024")
-- If key matches, Callback fires with true
]]
 
-- ════════════════════════════════════════════════════════════════════
--  CREATE THE WINDOW
-- ════════════════════════════════════════════════════════════════════
local Window = StarLight:CreateWindow({
    Title      = "Starlight",
    Subtitle   = "Interface Suite v1.0",
    Icon       = StarLight.Icons.Get("Star"),
    Size       = UDim2.new(0, 780, 0, 530),
    ToggleKey  = Enum.KeyCode.RightShift,   -- press RightShift to show/hide
    Discord    = {
        ServerName = "Starlight Community",
        InviteCode = "starlight",
        Callback   = function(code)
            print("Copied discord.gg/" .. code)
        end,
    },
})
 
-- ════════════════════════════════════════════════════════════════════
--  TAB 1 — COMBAT
-- ════════════════════════════════════════════════════════════════════
local CombatTab = Window:AddTab({
    Name = "Combat",
    Icon = StarLight.Icons.Get("Gamepad"),
})
 
-- ── Group: Aimbot Settings
local AimbotGroup = CombatTab:AddGroupBox({ Title = "Aimbot Settings" })
 
local aimbotToggle = AimbotGroup:AddToggle({
    Key      = "aimbot_enabled",
    Text     = "Enable Aimbot",
    Default  = false,
    Style    = "Switch",
    Tooltip  = "Automatically aim at the nearest enemy",
    Callback = function(val)
        print("Aimbot:", val)
    end,
})
 
local smoothness = AimbotGroup:AddSlider({
    Key      = "aimbot_smooth",
    Text     = "Smoothness",
    Min      = 1,
    Max      = 100,
    Default  = 30,
    Suffix   = "%",
    Step     = 1,
    Tooltip  = "Higher = smoother, slower aim",
    Callback = function(val)
        print("Smoothness:", val)
    end,
})
 
local fovSlider = AimbotGroup:AddSlider({
    Key      = "aimbot_fov",
    Text     = "FOV Radius",
    Min      = 10,
    Max      = 500,
    Default  = 120,
    Suffix   = "px",
    Step     = 5,
})
 
local targetPart = AimbotGroup:AddDropdown({
    Key      = "aimbot_part",
    Text     = "Target Part",
    Options  = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "RightArm", "LeftArm" },
    Default  = "Head",
    Tooltip  = "Which body part to aim at",
    Callback = function(val)
        print("Target Part:", val)
    end,
})
 
local ignoreParts = AimbotGroup:AddDropdown({
    Key      = "aimbot_ignore",
    Text     = "Ignore Tags",
    Options  = { "Friends", "Team", "NPC", "Invisible" },
    Multi    = true,  -- multi-select enabled
    Tooltip  = "These targets will be skipped",
    Callback = function(selected)
        for k in pairs(selected) do print("Ignoring:", k) end
    end,
})
 
AimbotGroup:AddDivider({ Text = "Keybinds" })
 
local aimbotKey = AimbotGroup:AddKeybind({
    Key      = "aimbot_key",
    Text     = "Aim Hold Key",
    Default  = Enum.KeyCode.Q,
    Tooltip  = "Hold this key to activate aimbot",
    Callback = function(key)
        print("Aiming with:", key)
    end,
})
 
-- ── Group: Visuals
local VisualsGroup = CombatTab:AddGroupBox({ Title = "Visuals", Collapsible = true })
 
local espToggle = VisualsGroup:AddToggle({
    Key     = "esp_enabled",
    Text    = "Enable ESP",
    Default = true,
    Style   = "Checkbox",
})
 
local espColor = VisualsGroup:AddColorPicker({
    Key      = "esp_color",
    Text     = "ESP Color",
    Default  = Color3.fromHex("#7B6CFF"),
    Callback = function(col)
        print("ESP Color:", col)
    end,
})
 
local chamsColor = VisualsGroup:AddColorPicker({
    Key      = "chams_color",
    Text     = "Chams Color",
    Default  = Color3.fromHex("#FF5533"),
    Callback = function(col)
        print("Chams Color:", col)
    end,
})
 
VisualsGroup:AddToggle({
    Key     = "esp_names",
    Text    = "Show Names",
    Default = true,
    Style   = "Switch",
})
 
VisualsGroup:AddToggle({
    Key     = "esp_health",
    Text    = "Show Health Bars",
    Default = false,
    Style   = "Switch",
})
 
local espDist = VisualsGroup:AddSlider({
    Key     = "esp_distance",
    Text    = "Max Distance",
    Min     = 50,
    Max     = 2000,
    Default = 500,
    Suffix  = "m",
    Step    = 10,
})
 
-- ════════════════════════════════════════════════════════════════════
--  TAB 2 — MOVEMENT
-- ════════════════════════════════════════════════════════════════════
local MovTab = Window:AddTab({
    Name = "Movement",
    Icon = StarLight.Icons.Get("Arrow"),
})
 
-- Two-column layout example
local SpeedGroup, JumpGroup = MovTab:AddGroupBox(
    {
        { Title = "Speed Settings" },
        { Title = "Jump Settings" },
    },
    2   -- 2 columns
)
 
local speedToggle = SpeedGroup:AddToggle({
    Key     = "speed_enabled",
    Text    = "Speed Hack",
    Default = false,
    Style   = "Switch",
})
 
local speedVal = SpeedGroup:AddSlider({
    Key     = "speed_value",
    Text    = "Walk Speed",
    Min     = 16,
    Max     = 300,
    Default = 16,
    Step    = 1,
    Suffix  = " ws",
})
 
SpeedGroup:AddKeybind({
    Key     = "speed_key",
    Text    = "Toggle Key",
    Default = Enum.KeyCode.LeftShift,
})
 
local jumpToggle = JumpGroup:AddToggle({
    Key     = "jump_enabled",
    Text    = "Jump Hack",
    Default = false,
    Style   = "Switch",
})
 
local jumpPower = JumpGroup:AddSlider({
    Key     = "jump_power",
    Text    = "Jump Power",
    Min     = 50,
    Max     = 500,
    Default = 50,
    Step    = 5,
    Suffix  = " jp",
})
 
JumpGroup:AddToggle({
    Key     = "inf_jump",
    Text    = "Infinite Jump",
    Default = false,
    Style   = "Checkbox",
})
 
-- Fly section
local FlyGroup = MovTab:AddGroupBox({ Title = "Fly / Noclip", Collapsible = true })
 
FlyGroup:AddToggle({
    Key     = "fly_enabled",
    Text    = "Fly Mode",
    Default = false,
    Style   = "Switch",
})
 
FlyGroup:AddToggle({
    Key     = "noclip_enabled",
    Text    = "Noclip",
    Default = false,
    Style   = "Switch",
})
 
FlyGroup:AddSlider({
    Key     = "fly_speed",
    Text    = "Fly Speed",
    Min     = 10,
    Max     = 300,
    Default = 50,
    Suffix  = " u/s",
})
 
-- ════════════════════════════════════════════════════════════════════
--  TAB 3 — PLAYER
-- ════════════════════════════════════════════════════════════════════
local PlayerTab = Window:AddTab({
    Name = "Player",
    Icon = StarLight.Icons.Get("User"),
})
 
local ModsGroup = PlayerTab:AddGroupBox({ Title = "Player Mods" })
 
ModsGroup:AddToggle({
    Key     = "anti_ragdoll",
    Text    = "Anti-Ragdoll",
    Default = false,
    Style   = "Switch",
})
 
ModsGroup:AddToggle({
    Key     = "anti_void",
    Text    = "Anti-Void",
    Default = true,
    Style   = "Switch",
    Tooltip = "Teleports you to last safe position if you fall",
})
 
ModsGroup:AddToggle({
    Key     = "always_sprint",
    Text    = "Always Sprint",
    Default = false,
    Style   = "Switch",
})
 
ModsGroup:AddDivider()
 
ModsGroup:AddSlider({
    Key     = "gravity",
    Text    = "Gravity Scale",
    Min     = 0,
    Max     = 200,
    Default = 100,
    Suffix  = "%",
    Step    = 5,
})
 
ModsGroup:AddSlider({
    Key     = "fov_changer",
    Text    = "FOV",
    Min     = 30,
    Max     = 120,
    Default = 70,
    Suffix  = "°",
    Step    = 1,
})
 
-- Teleport section
local TPGroup = PlayerTab:AddGroupBox({ Title = "Teleport" })
 
TPGroup:AddInput({
    Key         = "tp_player",
    Text        = "Teleport to Player",
    Placeholder = "Enter username...",
    Tooltip     = "Teleport to another player by name",
})
 
TPGroup:AddButton({
    Text     = "Teleport to Waypoint",
    Icon     = StarLight.Icons.Get("Arrow"),
    Tooltip  = "Teleport to your saved waypoint",
    Callback = function()
        print("Teleporting to waypoint!")
        Window:Notify({
            Title    = "Teleporting",
            Body     = "Moving to your saved waypoint...",
            Type     = "Info",
            Duration = 3,
        })
    end,
})
 
TPGroup:AddButton({
    Text     = "Save Current Position",
    Icon     = StarLight.Icons.Get("Save"),
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            print(string.format("Saved: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
            Window:Notify({
                Title    = "Waypoint Saved",
                Body     = string.format("Position: %.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z),
                Type     = "Success",
                Duration = 3,
            })
        end
    end,
})
 
-- ════════════════════════════════════════════════════════════════════
--  TAB 4 — WORLD
-- ════════════════════════════════════════════════════════════════════
local WorldTab = Window:AddTab({
    Name = "World",
    Icon = StarLight.Icons.Get("Eye"),
})
 
local LightGroup = WorldTab:AddGroupBox({ Title = "Lighting & Environment" })
 
LightGroup:AddToggle({
    Key     = "fullbright",
    Text    = "Fullbright",
    Default = false,
    Style   = "Switch",
    Callback = function(val)
        local lighting = game:GetService("Lighting")
        if val then
            lighting.Brightness = 10
            lighting.GlobalShadows = false
        else
            lighting.Brightness = 1
            lighting.GlobalShadows = true
        end
    end,
})
 
LightGroup:AddToggle({
    Key     = "no_fog",
    Text    = "Remove Fog",
    Default = false,
    Style   = "Switch",
})
 
LightGroup:AddColorPicker({
    Key      = "ambient_color",
    Text     = "Ambient Color",
    Default  = Color3.fromHex("#FFFFFF"),
    Callback = function(col)
        game:GetService("Lighting").Ambient = col
    end,
})
 
LightGroup:AddSlider({
    Key     = "time_of_day",
    Text    = "Time of Day",
    Min     = 0,
    Max     = 24,
    Default = 14,
    Suffix  = ":00",
    Step    = 0.5,
    Callback = function(val)
        game:GetService("Lighting").ClockTime = val
    end,
})
 
local RenderGroup = WorldTab:AddGroupBox({ Title = "Rendering" })
 
RenderGroup:AddDropdown({
    Key     = "render_quality",
    Text    = "Render Quality",
    Options = { "Automatic", "Level01", "Level05", "Level10", "Level21" },
    Default = "Automatic",
    Callback = function(val)
        local rqLevel = { Automatic=0, Level01=1, Level05=5, Level10=10, Level21=21 }
        settings().Rendering.QualityLevel = rqLevel[val] or 0
    end,
})
 
RenderGroup:AddToggle({
    Key     = "no_particles",
    Text    = "Disable Particles",
    Default = false,
    Style   = "Switch",
})
 
-- ════════════════════════════════════════════════════════════════════
--  TAB 5 — SETTINGS
-- ════════════════════════════════════════════════════════════════════
local SettingsTab = Window:AddTab({
    Name = "Settings",
    Icon = StarLight.Icons.Get("Settings"),
})
 
local UIGroup = SettingsTab:AddGroupBox({ Title = "UI Settings" })
 
UIGroup:AddDropdown({
    Key      = "ui_theme",
    Text     = "Theme",
    Options  = StarLight.ThemeEngine:GetThemeNames(),
    Default  = "Midnight",
    Callback = function(val)
        Window:SetTheme(val)
    end,
})
 
UIGroup:AddKeybind({
    Key     = "toggle_key",
    Text    = "Toggle UI Key",
    Default = Enum.KeyCode.RightShift,
})
 
UIGroup:AddToggle({
    Key     = "ui_sounds",
    Text    = "UI Sounds",
    Default = true,
    Style   = "Switch",
})
 
UIGroup:AddToggle({
    Key     = "ui_animations",
    Text    = "UI Animations",
    Default = true,
    Style   = "Switch",
})
 
UIGroup:AddDivider({ Text = "CONFIG" })
 
local configNameInput = UIGroup:AddInput({
    Key         = "_config_name_input",
    Text        = "Config Name",
    Placeholder = "my-config",
    Default     = "default",
})
 
UIGroup:AddButton({
    Text     = "💾  Save Config",
    Tooltip  = "Save current settings to file",
    Callback = function()
        local name = configNameInput:GetValue()
        if name and name ~= "" then
            local ok = Window:SaveConfig(name)
            Window:Notify({
                Title    = ok and "Config Saved" or "Save Failed",
                Body     = ok and ("Saved as '" .. name .. "'") or "Could not write file.",
                Type     = ok and "Success" or "Error",
                Duration = 3,
            })
        end
    end,
})
 
UIGroup:AddButton({
    Text     = "📂  Load Config",
    Tooltip  = "Load saved settings from file",
    Callback = function()
        local name = configNameInput:GetValue()
        if name and name ~= "" then
            local ok = Window:LoadConfig(name)
            Window:Notify({
                Title    = ok and "Config Loaded" or "Load Failed",
                Body     = ok and ("Loaded '" .. name .. "'") or "Config not found.",
                Type     = ok and "Success" or "Warning",
                Duration = 3,
            })
        end
    end,
})
 
-- About paragraph
local AboutGroup = SettingsTab:AddGroupBox({ Title = "About" })
 
AboutGroup:AddParagraph({
    Title = "Starlight Interface Suite",
    Body  = "<b>Version:</b> 1.0.0\n<b>Author:</b> Starlight Labs\n\nA premium, modular Roblox UI framework with full theming, config system, animations, and a comprehensive element library.\n\nPress <b>RightShift</b> to toggle visibility.",
})
 
AboutGroup:AddLabel({
    Text  = "✦ Built with Starlight Interface Suite",
    Color = StarLight.ThemeEngine:GetColor("Accent"),
    Size  = 11,
})
 
-- ════════════════════════════════════════════════════════════════════
--  DEMONSTRATE NOTIFICATION SYSTEM
-- ════════════════════════════════════════════════════════════════════
local NotifGroup = SettingsTab:AddGroupBox({ Title = "Notification Demo" })
 
NotifGroup:AddButton({
    Text     = "🔔  Info Notification",
    Callback = function()
        Window:Notify({
            Title    = "Information",
            Body     = "This is an informational notification with a longer body text to demonstrate wrapping.",
            Type     = "Info",
            Duration = 4,
        })
    end,
})
 
NotifGroup:AddButton({
    Text     = "✅  Success Notification",
    Callback = function()
        Window:Notify({
            Title    = "Success!",
            Body     = "Operation completed successfully.",
            Type     = "Success",
            Duration = 3,
        })
    end,
})
 
NotifGroup:AddButton({
    Text     = "⚠️  Warning Notification",
    Callback = function()
        Window:Notify({
            Title    = "Warning",
            Body     = "Something might need your attention.",
            Type     = "Warning",
            Duration = 4,
        })
    end,
})
 
NotifGroup:AddButton({
    Text     = "❌  Error Notification",
    Callback = function()
        Window:Notify({
            Title    = "Error",
            Body     = "An error occurred. Please check your settings.",
            Type     = "Error",
            Duration = 5,
        })
    end,
})
 
-- ════════════════════════════════════════════════════════════════════
--  DEMONSTRATE MODAL SYSTEM
-- ════════════════════════════════════════════════════════════════════
NotifGroup:AddDivider({ Text = "MODALS" })
 
NotifGroup:AddButton({
    Text     = "📋  Show Confirmation Dialog",
    Callback = function()
        Window:ShowModal({
            Title = "Confirm Action",
            Body  = "Are you sure you want to reset all settings to their defaults? This cannot be undone.",
            Buttons = {
                {
                    Text     = "Cancel",
                    Callback = function()
                        print("Cancelled")
                    end,
                },
                {
                    Text     = "Reset All",
                    Style    = "Primary",
                    Callback = function()
                        Window:Notify({
                            Title    = "Settings Reset",
                            Body     = "All values have been restored to defaults.",
                            Type     = "Info",
                            Duration = 3,
                        })
                    end,
                },
            },
        })
    end,
})
 
-- ════════════════════════════════════════════════════════════════════
--  STARTUP NOTIFICATION
-- ════════════════════════════════════════════════════════════════════
task.delay(0.8, function()
    Window:Notify({
        Title    = "Starlight Loaded ✦",
        Body     = "Press RightShift to toggle. Select a theme in the sidebar.",
        Type     = "Success",
        Duration = 5,
    })
end)
 
print("[StarlightUI] Example script loaded successfully!")
print("[StarlightUI] Press RightShift to toggle the UI.")
