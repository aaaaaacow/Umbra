local Env = (getgenv and getgenv()) or _G
local Umbra = Env.Umbra
if not Umbra then
        assert(loadfile, "Umbra library not loaded, run Loader.lua first")
        Umbra = loadfile("UmbraUI.lua")()
end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Options = Umbra.Options
local Toggles = Umbra.Toggles

Umbra:SetDPIScale(1)

local Window = Umbra:CreateWindow({
        Title = "HvH Project",
        Footer = "Umbra " .. Umbra.Version .. " | HvH",
        Center = true,
        AutoShow = true,
        Resizable = true,
})

local Tabs = {
        Combat = Window:AddTab("Combat"),
        Visuals = Window:AddTab("Visuals"),
        Movement = Window:AddTab("Movement"),
        UISettings = Window:AddTab("UI Settings"),
}

local CombatState = {
        Enabled = false,
        Target = nil,
        FieldOfView = 90,
        Smoothing = 0.25,
        HitboxPart = "Head",
        WallCheck = true,
        GlowColor = Color3.fromRGB(235, 64, 92),
        TriggerKey = nil,
}

local CombatGroup = Tabs.Combat:AddLeftGroupbox("Aim")
local TriggerGroup = Tabs.Combat:AddRightGroupbox("Trigger")

CombatGroup:AddToggle("AimEnabled", {
        Text = "Enabled",
        Default = false,
        Tooltip = "Master switch for the aim module",
        Callback = function(Value)
                CombatState.Enabled = Value
        end,
})

CombatGroup:AddDropdown("AimTarget", {
        Values = { "Closest to cursor", "Lowest health", "Highest threat" },
        Default = 1,
        Text = "Target priority",
        Callback = function(Value)
                CombatState.Target = Value
        end,
})

CombatGroup:AddSlider("AimFOV", {
        Text = "Field of view",
        Default = 90,
        Min = 10,
        Max = 360,
        Rounding = 0,
        Suffix = "deg",
        Callback = function(Value)
                CombatState.FieldOfView = Value
        end,
})

CombatGroup:AddSlider("AimSmoothing", {
        Text = "Smoothing",
        Default = 0.25,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
                CombatState.Smoothing = Value
        end,
})

CombatGroup:AddDropdown("AimHitbox", {
        Values = { "Head", "Torso", "Closest part" },
        Default = "Head",
        Multi = false,
        Text = "Hitbox",
        Callback = function(Value)
                CombatState.HitboxPart = Value
        end,
})

CombatGroup:AddToggle("AimWallCheck", {
        Text = "Wall check",
        Default = true,
        Callback = function(Value)
                CombatState.WallCheck = Value
        end,
})

CombatGroup:AddLabel("Glow color"):AddColorPicker("AimGlowColor", {
        Title = "Target glow",
        Default = CombatState.GlowColor,
        Callback = function(Value)
                CombatState.GlowColor = Value
        end,
})

CombatGroup:AddLabel("Trigger key"):AddKeyPicker("AimTriggerKey", {
        Default = "E",
        Mode = "Hold",
        Text = "Aim hold key",
        Callback = function(State)
                print("[hvvh] aim hold:", State)
        end,
})

CombatState.TriggerKey = Options.AimTriggerKey

TriggerGroup:AddToggle("TriggerBot", {
        Text = "Trigger bot",
        Default = false,
        Risky = true,
        Callback = function(Value)
                print("[hvvh] trigger bot:", Value)
        end,
})

TriggerGroup:AddSlider("TriggerDelay", {
        Text = "Reaction delay",
        Default = 120,
        Min = 0,
        Max = 500,
        Rounding = 0,
        Suffix = "ms",
        Callback = function(Value)
                print("[hvvh] trigger delay:", Value)
        end,
})

TriggerGroup:AddButton({
        Text = "Panic reset",
        DoubleClick = true,
        Tooltip = "Double click to reset all combat state",
        Func = function()
                Toggles.AimEnabled:SetValue(false)
                Toggles.TriggerBot:SetValue(false)
                Umbra:Notify({ Title = "Combat", Description = "All combat modules disabled.", Time = 3 })
        end,
})

TriggerGroup:AddButton("Sub-action demo")
        :AddButton({ Text = "Nested action", Func = function()
                Umbra:Notify("Nested button pressed!", 3)
        end })

local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("Skybox")
local MiscVisuals = Tabs.Visuals:AddRightGroupbox("Extras")

VisualsGroup:AddDropdown("SkyboxPreset", {
        Values = { "Solar Fade", "Deep Field", "Neon Grid", "Code Rain", "Blood Moon", "Event Horizon", "Whiteout" },
        Default = "Blood Moon",
        Text = "Skybox",
        Searchable = true,
        Callback = function(Value)
                Umbra:Notify({ Title = "Skybox", Description = "Applied: " .. Value, Time = 3 })
        end,
})

VisualsGroup:AddSlider("SkyboxBlend", {
        Text = "Blend strength",
        Default = 1,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
                print("[hvvh] skybox blend:", Value)
        end,
})

MiscVisuals:AddToggle("ESPEnabled", {
        Text = "Player ESP",
        Default = false,
        Callback = function(Value)
                print("[hvvh] esp:", Value)
        end,
})
        :AddColorPicker("ESPColor", {
                Title = "ESP color",
                Default = Color3.fromRGB(120, 200, 255),
        })

MiscVisuals:AddToggle("ESPTeammates", {
        Text = "Show teammates",
        Default = false,
        Callback = function(Value)
                print("[hvvh] esp teammates:", Value)
        end,
})

MiscVisuals:AddDropdown("ESPMembers", {
        SpecialType = "Player",
        ExcludeLocalPlayer = true,
        Multi = true,
        Text = "Highlighted players",
        Callback = function(Value)
                for Name, Selected in pairs(Value) do
                        if Selected then
                                print("[hvvh] highlighted:", Name)
                        end
                end
        end,
})

local MovementGroup = Tabs.Movement:AddLeftGroupbox("Movement")

MovementGroup:AddToggle("FlyEnabled", {
        Text = "Fly",
        Default = false,
        Callback = function(Value)
                print("[hvvh] fly:", Value)
        end,
})
        :AddKeyPicker("FlyKeybind", {
                Default = "F",
                SyncToggleState = true,
                Mode = "Toggle",
                Text = "Fly",
                NoUI = false,
        })

MovementGroup:AddSlider("FlySpeed", {
        Text = "Fly speed",
        Default = 50,
        Min = 10,
        Max = 500,
        Rounding = 0,
        Callback = function(Value)
                print("[hvvh] fly speed:", Value)
        end,
})

MovementGroup:AddToggle("SpeedEnabled", {
        Text = "Speed hack",
        Default = false,
        Risky = true,
        Callback = function(Value)
                print("[hvvh] speed:", Value)
        end,
})

MovementGroup:AddInput("SpeedValue", {
        Default = "16",
        Numeric = true,
        Finished = true,
        Text = "Walk speed",
        Placeholder = "16",
        Callback = function(Value)
                print("[hvvh] walk speed:", Value)
        end,
})

local MenuGroup = Tabs.UISettings:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
        Text = "Show keybind menu",
        Default = false,
        Callback = function(Value)
                if Umbra.KeybindFrame then
                        Umbra.KeybindFrame.Visible = Value
                end
        end,
})

MenuGroup:AddDropdown("NotifySide", {
        Values = { "Left", "Right" },
        Default = "Right",
        Text = "Notification side",
        Callback = function(Value)
                Umbra:SetNotifySide(Value)
        end,
})

MenuGroup:AddDropdown("DPIScale", {
        Values = { "75%", "100%", "125%", "150%" },
        Default = "100%",
        Text = "UI scale",
        Callback = function(Value)
                Umbra:SetDPIScale(tonumber(string.gsub(Value, "%%", "")) / 100)
        end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = true,
        Text = "Menu keybind",
})

MenuGroup:AddButton({
        Text = "Unload",
        Func = function()
                Umbra:Unload()
        end,
})

Umbra.ToggleKeybind = Options.MenuKeybind

Umbra:BuildThemeSection(Tabs.UISettings)
Umbra:BuildConfigSection(Tabs.UISettings)

Umbra:OnUnload(function()
        print("[hvvh] umbra unloaded, cleanup here")
end)

Umbra:SetWatermarkVisibility(true)

local FrameCounter = 0
local FrameTimer = os.clock()
local FPS = 0

task.spawn(function()
        while not Umbra.Unloaded do
                task.wait(0.25)
                FrameCounter = FrameCounter + 1
                if os.clock() - FrameTimer >= 1 then
                        FPS = FrameCounter / (os.clock() - FrameTimer)
                        FrameCounter = 0
                        FrameTimer = os.clock()
                        local Ping = math.floor((LocalPlayer and LocalPlayer:GetNetworkPing() or 0) * 1000)
                        Umbra:SetWatermark("hvvh | " .. string.format("%.0f fps", FPS) .. " | " .. Ping .. " ms")
                end
        end
end)

Umbra:Notify({
        Title = "Umbra loaded",
        Description = "Press RightShift to toggle the menu.",
        Time = 5,
})

Umbra:LoadAutoloadConfig()
