local Umbra = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer

local Unpack = table.unpack or unpack
local function Clamp(Value, Minimum, Maximum)
        if Value < Minimum then
                return Minimum
        end
        if Value > Maximum then
                return Maximum
        end
        return Value
end

local protectgui = (syn and syn.protect_gui) or function() end
local GetHui = gethui or nil

local FileSystem = {
        Write = (typeof(writefile) == "function" and writefile) or nil,
        Read = (typeof(readfile) == "function" and readfile) or nil,
        List = (typeof(listfiles) == "function" and listfiles) or nil,
        Exists = (typeof(isfile) == "function" and isfile) or nil,
        MakeFolder = (typeof(makefolder) == "function" and makefolder) or nil,
}

Umbra.Version = "1.0.0"
Umbra.Unloaded = false
Umbra.Options = {}
Umbra.Toggles = {}
Umbra.Signals = {}
Umbra.Registry = {}
Umbra.Refreshers = {}
Umbra.UnloadCallbacks = {}
Umbra.OpenPopup = nil
Umbra.KeybindListening = false
Umbra.ShowTooltips = true
Umbra.NotifySide = "Right"
Umbra.DPIScale = 1
Umbra.MinWindowSize = Vector2.new(460, 340)
Umbra.ConfigFolder = "Umbra"
Umbra.ConfigExtension = "umbra"
Umbra.MemoryConfigs = {}
Umbra.ToggleKeybind = nil

local Library = Umbra


Umbra.Scheme = {
        BackgroundColor = Color3.fromRGB(13, 13, 16),
        MainColor = Color3.fromRGB(21, 21, 26),
        AccentColor = Color3.fromRGB(235, 64, 92),
        AccentDim = Color3.fromRGB(120, 34, 48),
        OutlineColor = Color3.fromRGB(38, 38, 46),
        FontColor = Color3.fromRGB(235, 235, 240),
        MutedColor = Color3.fromRGB(148, 148, 160),
        DangerColor = Color3.fromRGB(255, 82, 82),
        SuccessColor = Color3.fromRGB(88, 214, 141),
        Font = Enum.Font.Gotham,
        FontMedium = Enum.Font.GothamMedium,
}

local Resolvable = {
        BackgroundColor3 = true,
        TextColor3 = true,
        ImageColor3 = true,
        ScrollBarImageColor3 = true,
        Color = true,
        Font = true,
}

Umbra.Themes = {
        Default = {
                BackgroundColor = Color3.fromRGB(13, 13, 16),
                MainColor = Color3.fromRGB(21, 21, 26),
                AccentColor = Color3.fromRGB(235, 64, 92),
                AccentDim = Color3.fromRGB(120, 34, 48),
                OutlineColor = Color3.fromRGB(38, 38, 46),
                FontColor = Color3.fromRGB(235, 235, 240),
                MutedColor = Color3.fromRGB(148, 148, 160),
                DangerColor = Color3.fromRGB(255, 82, 82),
                SuccessColor = Color3.fromRGB(88, 214, 141),
        },
        Void = {
                BackgroundColor = Color3.fromRGB(0, 0, 0),
                MainColor = Color3.fromRGB(10, 10, 10),
                AccentColor = Color3.fromRGB(240, 240, 240),
                AccentDim = Color3.fromRGB(90, 90, 90),
                OutlineColor = Color3.fromRGB(30, 30, 30),
                FontColor = Color3.fromRGB(230, 230, 230),
                MutedColor = Color3.fromRGB(120, 120, 120),
                DangerColor = Color3.fromRGB(255, 82, 82),
                SuccessColor = Color3.fromRGB(88, 214, 141),
        },
        Blood = {
                BackgroundColor = Color3.fromRGB(16, 6, 8),
                MainColor = Color3.fromRGB(28, 10, 13),
                AccentColor = Color3.fromRGB(255, 48, 48),
                AccentDim = Color3.fromRGB(130, 26, 26),
                OutlineColor = Color3.fromRGB(48, 18, 22),
                FontColor = Color3.fromRGB(240, 225, 226),
                MutedColor = Color3.fromRGB(160, 120, 124),
                DangerColor = Color3.fromRGB(255, 120, 90),
                SuccessColor = Color3.fromRGB(120, 220, 130),
        },
        Emerald = {
                BackgroundColor = Color3.fromRGB(7, 14, 11),
                MainColor = Color3.fromRGB(13, 24, 19),
                AccentColor = Color3.fromRGB(64, 224, 148),
                AccentDim = Color3.fromRGB(32, 100, 68),
                OutlineColor = Color3.fromRGB(22, 42, 33),
                FontColor = Color3.fromRGB(226, 244, 235),
                MutedColor = Color3.fromRGB(130, 165, 148),
                DangerColor = Color3.fromRGB(255, 96, 96),
                SuccessColor = Color3.fromRGB(88, 214, 141),
        },
        Frost = {
                BackgroundColor = Color3.fromRGB(10, 13, 18),
                MainColor = Color3.fromRGB(18, 23, 31),
                AccentColor = Color3.fromRGB(120, 200, 255),
                AccentDim = Color3.fromRGB(54, 92, 120),
                OutlineColor = Color3.fromRGB(32, 40, 52),
                FontColor = Color3.fromRGB(228, 238, 248),
                MutedColor = Color3.fromRGB(140, 158, 175),
                DangerColor = Color3.fromRGB(255, 96, 96),
                SuccessColor = Color3.fromRGB(88, 214, 141),
        },
}

local function S(Value)
        return math.floor(Value * Umbra.DPIScale + 0.5)
end

local function SafeCallback(Callback, ...)
        if type(Callback) ~= "function" then
                return
        end
        local Args = { ... }
        task.spawn(function()
                local Ok, Err = pcall(function()
                        Callback(Unpack(Args))
                end)
                if not Ok then
                        warn("[Umbra] callback error: " .. tostring(Err))
                end
        end)
end

local function GiveSignal(Signal)
        table.insert(Umbra.Signals, Signal)
        return Signal
end

local function RegisterColor(Instance, Property, Key)
        for Index = #Umbra.Registry, 1, -1 do
                local Entry = Umbra.Registry[Index]
                if Entry.Instance == Instance and Entry.Property == Property then
                        table.remove(Umbra.Registry, Index)
                end
        end
        table.insert(Umbra.Registry, { Instance = Instance, Property = Property, Key = Key })
end

local function New(ClassName, Props)
        local Inst = Instance.new(ClassName)
        for Property, Value in pairs(Props or {}) do
                if type(Value) == "string" and Resolvable[Property] and Umbra.Scheme[Value] ~= nil then
                        RegisterColor(Inst, Property, Value)
                        Inst[Property] = Umbra.Scheme[Value]
                else
                        Inst[Property] = Value
                end
        end
        return Inst
end

local function Corner(Radius)
        return New("UICorner", { CornerRadius = UDim.new(0, S(Radius)) })
end

local function Stroke(ColorKey, Thickness)
        return New("UIStroke", {
                Color = ColorKey or "OutlineColor",
                Thickness = S(Thickness or 1),
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        })
end

local function Tween(Object, Time, Props, Style, Direction)
        local Created = TweenService:Create(
                Object,
                TweenInfo.new(Time or 0.18, Style or Enum.EasingStyle.Quad, Direction or Enum.EasingDirection.Out),
                Props
        )
        Created:Play()
        return Created
end

local function GetMousePos()
        return UserInputService:GetMouseLocation()
end

local function IsInside(GuiObject, ScreenPos)
        local Pos = GuiObject.AbsolutePosition
        local Size = GuiObject.AbsoluteSize
        return ScreenPos.X >= Pos.X and ScreenPos.X <= Pos.X + Size.X and ScreenPos.Y >= Pos.Y and ScreenPos.Y <= Pos.Y + Size.Y
end

local function IsTouchInput(Input)
        return Input.UserInputType == Enum.UserInputType.Touch
end

local function IsPrimaryInput(Input)
        return Input.UserInputType == Enum.UserInputType.MouseButton1 or IsTouchInput(Input)
end

local function IsMouseMove(Input)
        return Input.UserInputType == Enum.UserInputType.MouseMovement or IsTouchInput(Input)
end

local function FindInList(List, Value)
        for Index = 1, #List do
                if List[Index] == Value then
                        return Index
                end
        end
        return nil
end

local function Viewport()
        local Camera = workspace.CurrentCamera
        return Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
end

local function SafeParent(Gui)
        local Ok = pcall(function()
                if GetHui then
                        Gui.Parent = GetHui()
                else
                        protectgui(Gui)
                        Gui.Parent = CoreGui
                end
        end)
        if not Ok or not Gui.Parent then
                Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
end

local function AddChangedSupport(Object)
        Object.ChangedCallbacks = {}

        function Object:OnChanged(Callback)
                table.insert(self.ChangedCallbacks, Callback)
                return self
        end

        function Object:FireChanged(...)
                for _, Callback in ipairs(self.ChangedCallbacks) do
                        SafeCallback(Callback, ...)
                end
        end
end

local function ApplyDisabledVisual(Element, Label)
        Label.TextTransparency = Element.Disabled and 0.45 or 0
end

local TooltipFrame = nil
local TooltipLabel = nil
local TooltipToken = 0

local function HideTooltip()
        TooltipToken = TooltipToken + 1
        if TooltipFrame then
                TooltipFrame.Visible = false
        end
end

local function ShowTooltip(Text)
        if not Umbra.ShowTooltips or not TooltipFrame or not Text or Text == "" then
                return
        end
        TooltipToken = TooltipToken + 1
        local Bounds = TextService:GetTextSize(Text, S(12), Umbra.Scheme.Font, Vector2.new(320, 10000))
        TooltipLabel.Text = Text
        TooltipFrame.Size = UDim2.fromOffset(Bounds.X + S(14), Bounds.Y + S(8))
        local Mouse = GetMousePos()
        local View = Viewport()
        TooltipFrame.Position = UDim2.fromOffset(
                Clamp(Mouse.X + S(14), S(4), View.X - TooltipFrame.AbsoluteSize.X - S(4)),
                Clamp(Mouse.Y + S(16), S(4), View.Y - TooltipFrame.AbsoluteSize.Y - S(4))
        )
        TooltipFrame.Visible = true
end

local function BindTooltip(HoverObject, Text)
        if not HoverObject or not Text or Text == "" then
                return
        end
        HoverObject.MouseEnter:Connect(function()
                if not Umbra.Unloaded then
                        ShowTooltip(Text)
                end
        end)
        HoverObject.MouseLeave:Connect(function()
                HideTooltip()
        end)
end

local function CloseOpenPopup()
        if Umbra.OpenPopup then
                local Popup = Umbra.OpenPopup
                Umbra.OpenPopup = nil
                if Popup.Close then
                        Popup:Close()
                end
        end
end

local function MakeDraggable(HandleObject, TargetFrame)
        local Dragging = false
        local StartInputPos = nil
        local StartFramePos = nil

        HandleObject.InputBegan:Connect(function(Input)
                if not IsPrimaryInput(Input) or Umbra.Unloaded then
                        return
                end
                Dragging = true
                StartInputPos = Input.Position
                StartFramePos = TargetFrame.Position
        end)

        GiveSignal(UserInputService.InputChanged:Connect(function(Input)
                if not Dragging or not IsMouseMove(Input) then
                        return
                end
                local Delta = Input.Position - StartInputPos
                local View = Viewport()
                local NewX = StartFramePos.X.Offset + Delta.X
                local NewY = StartFramePos.Y.Offset + Delta.Y
                NewX = Clamp(NewX, -TargetFrame.AbsoluteSize.X + S(90), View.X - S(90))
                NewY = Clamp(NewY, 0, View.Y - S(40))
                TargetFrame.Position = UDim2.fromOffset(NewX, NewY)
        end))

        GiveSignal(UserInputService.InputEnded:Connect(function(Input)
                if IsPrimaryInput(Input) then
                        Dragging = false
                end
        end))
end

local function TrackDragAlong(InputObject, Axis, BaseFrame, OnUpdate)
        local StartX = InputObject.Position.X
        local StartY = InputObject.Position.Y
        local Base = nil
        task.defer(function()
                if BaseFrame and BaseFrame.Parent then
                        Base = BaseFrame.AbsolutePosition
                end
        end)
        local MoveConnection
        local EndConnection
        MoveConnection = GiveSignal(UserInputService.InputChanged:Connect(function(Moved)
                if not IsMouseMove(Moved) or not Base then
                        return
                end
                local CurrentX = StartX + (Moved.Position.X - StartX)
                local CurrentY = StartY + (Moved.Position.Y - StartY)
                if Axis == "XY" then
                        OnUpdate(CurrentX - Base.X, CurrentY - Base.Y)
                elseif Axis == "X" then
                        OnUpdate(CurrentX - Base.X)
                elseif Axis == "Y" then
                        OnUpdate(CurrentY - Base.Y)
                end
        end))
        EndConnection = GiveSignal(UserInputService.InputEnded:Connect(function(Ended)
                if IsPrimaryInput(Ended) then
                        MoveConnection:Disconnect()
                        EndConnection:Disconnect()
                end
        end))
end

local function CreateColorSwatch(AnchorInstance)
        AnchorInstance.SwatchCount = (AnchorInstance.SwatchCount or 0) + 1
        local Order = AnchorInstance.SwatchCount
        local Swatch = New("Frame", {
                BackgroundColor3 = "AccentColor",
                Position = UDim2.new(1, -S(6) - (Order - 1) * S(22), 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                Size = UDim2.fromOffset(S(16), S(16)),
                Active = true,
                ZIndex = 6,
                Parent = AnchorInstance,
        })
        Corner(4).Parent = Swatch
        Stroke("OutlineColor", 1).Parent = Swatch
        return Swatch
end

local function CreateColorPicker(Container, Idx, Info, AnchorInstance)
        assert(Idx ~= nil, "Umbra: ColorPicker requires an index")
        assert(Library.Main, "Umbra: create a window before adding elements")
        Info = Info or {}

        local Picker = {
                Type = "ColorPicker",
                Idx = Idx,
                Title = Info.Title or "Color",
                Value = typeof(Info.Default) == "Color3" and Info.Default or Color3.fromRGB(255, 255, 255),
                Disabled = Info.Disabled or false,
                Visible = true,
                AlphaEnabled = Info.Transparency ~= nil,
        }

        AddChangedSupport(Picker)
        if Info.Callback then
                table.insert(Picker.ChangedCallbacks, Info.Callback)
        end

        if Picker.AlphaEnabled then
                Picker.T = Clamp(tonumber(Info.Transparency) or 0, 0, 1)
                Picker.Transparency = Picker.T
        else
                Picker.T = 0
                Picker.Transparency = nil
        end

        local H, Sat, Val = Picker.Value:ToHSV()
        Picker.H = H
        Picker.S = Sat
        Picker.V = Val

        local Swatch = CreateColorSwatch(AnchorInstance)

        local PopupWidth = S(200)
        local Popup = New("Frame", {
                BackgroundColor3 = "MainColor",
                Size = UDim2.fromOffset(PopupWidth, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Visible = false,
                ZIndex = 60,
                Parent = Library.Main,
        })
        Corner(6).Parent = Popup
        Stroke("OutlineColor", 1).Parent = Popup
        New("UIListLayout", { Padding = S(8), Parent = Popup })
        New("UIPadding", {
                PaddingTop = UDim.new(0, S(10)),
                PaddingBottom = UDim.new(0, S(10)),
                PaddingLeft = UDim.new(0, S(10)),
                PaddingRight = UDim.new(0, S(10)),
                Parent = Popup,
        })

        New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, S(16)),
                Font = "FontMedium",
                Text = Picker.Title,
                TextColor3 = "FontColor",
                TextSize = S(13),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 61,
                Parent = Popup,
        })

        local PickerArea = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, S(120)),
                ZIndex = 61,
                Parent = Popup,
        })

        local SVBase = New("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new(1, -S(18), 1, 0),
                ZIndex = 61,
                Parent = PickerArea,
        })
        Corner(4).Parent = SVBase
        local SVGradient = New("UIGradient", { Parent = SVBase })

        local SVOverlay = New("Frame", {
                BackgroundColor3 = Color3.new(0, 0, 0),
                Size = UDim2.new(1, -S(18), 1, 0),
                ZIndex = 62,
                Parent = PickerArea,
        })
        Corner(4).Parent = SVOverlay
        New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0),
                }),
                Parent = SVOverlay,
        })

        local SVMarker = New("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.fromOffset(S(10), S(10)),
                ZIndex = 64,
                Parent = PickerArea,
        })
        Corner(5).Parent = SVMarker
        Stroke("BackgroundColor", 1).Parent = SVMarker

        local HueBase = New("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1),
                Position = UDim2.new(1, -S(14), 0, 0),
                Size = UDim2.fromOffset(S(14), S(120)),
                ZIndex = 61,
                Parent = PickerArea,
        })
        Corner(4).Parent = HueBase
        New("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                }),
                Parent = HueBase,
        })

        local HueMarker = New("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, 0, 0, S(3)),
                ZIndex = 63,
                Parent = HueBase,
        })
        Corner(2).Parent = HueMarker
        Stroke("BackgroundColor", 1).Parent = HueMarker

        local AlphaBase = nil
        local AlphaMarker = nil
        if Picker.AlphaEnabled then
                AlphaBase = New("Frame", {
                        BackgroundColor3 = Color3.fromRGB(140, 140, 140),
                        Size = UDim2.new(1, -S(18), 0, S(12)),
                        ZIndex = 61,
                        Parent = Popup,
                })
                Corner(4).Parent = AlphaBase
                New("UIGradient", {
                        Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(1, 1),
                        }),
                        Parent = AlphaBase,
                })
                AlphaMarker = New("Frame", {
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Size = UDim2.new(0, S(6), 1, 0),
                        ZIndex = 63,
                        Parent = AlphaBase,
                })
                Corner(3).Parent = AlphaMarker
                Stroke("BackgroundColor", 1).Parent = AlphaMarker
        end

        local PreviewRow = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, S(18)),
                ZIndex = 61,
                Parent = Popup,
        })
        local Preview = New("Frame", {
                BackgroundColor3 = Picker.Value,
                Size = UDim2.fromOffset(S(18), S(18)),
                ZIndex = 61,
                Parent = PreviewRow,
        })
        Corner(4).Parent = Preview
        Stroke("OutlineColor", 1).Parent = Preview
        local RGBLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, S(24), 0, 0),
                Size = UDim2.new(1, -S(24), 1, 0),
                Font = "Font",
                Text = "",
                TextColor3 = "MutedColor",
                TextSize = S(12),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 61,
                Parent = PreviewRow,
        })

        local function UpdateVisuals()
                SVBase.BackgroundColor3 = Color3.fromHSV(Picker.H, 1, 1)
                SVGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(Picker.H, 1, 1))
                local AreaWidth = SVBase.AbsoluteSize.X
                local AreaHeight = SVBase.AbsoluteSize.Y
                if AreaWidth > 0 then
                        SVMarker.Position = UDim2.new(0, Picker.S * AreaWidth, 0, (1 - Picker.V) * AreaHeight)
                end
                HueMarker.Position = UDim2.new(0, 0, 1 - Picker.H, 0)
                if AlphaMarker then
                        AlphaMarker.Position = UDim2.new(Picker.T, 0, 0.5, 0)
                end
                Preview.BackgroundColor3 = Picker.Value
                Preview.BackgroundTransparency = Picker.AlphaEnabled and Picker.T or 0
                RGBLabel.Text = math.floor(Picker.Value.R * 255 + 0.5)
                        .. ", "
                        .. math.floor(Picker.Value.G * 255 + 0.5)
                        .. ", "
                        .. math.floor(Picker.Value.B * 255 + 0.5)
                Swatch.BackgroundColor3 = Picker.Value
                Swatch.BackgroundTransparency = Picker.AlphaEnabled and Picker.T or 0
        end

        local function Changed(SkipCallback)
                UpdateVisuals()
                if not SkipCallback then
                        Picker:FireChanged(Picker.Value)
                end
        end

        function Picker:SetValueRGB(Color, SkipCallback)
                if typeof(Color) ~= "Color3" then
                        return
                end
                self.Value = Color
                local H2, S2, V2 = Color:ToHSV()
                self.H = H2
                self.S = S2
                self.V = V2
                Changed(SkipCallback)
        end

        Picker.SetValue = Picker.SetValueRGB

        function Picker:SetTransparency(Value, SkipCallback)
                if not self.AlphaEnabled then
                        return
                end
                self.T = Clamp(tonumber(Value) or 0, 0, 1)
                self.Transparency = self.T
                Changed(SkipCallback)
        end

        function Picker:SetText(Text)
                Picker.Title = tostring(Text)
        end

        function Picker:SetVisible(State)
                Picker.Visible = State ~= false
                Swatch.Visible = Picker.Visible
        end

        local PopupObject = { PopupFrame = Popup }

        function Picker:Close()
                Popup.Visible = false
                if Library.OpenPopup == PopupObject then
                        Library.OpenPopup = nil
                end
        end

        PopupObject.Close = function()
                Picker:Close()
        end

        local function SetPopupOpen(Open)
                if Open then
                        CloseOpenPopup()
                        local View = Viewport()
                        local AnchorPos = Swatch.AbsolutePosition
                        local MainPos = Library.Main.AbsolutePosition
                        local X = Clamp(
                                AnchorPos.X - MainPos.X - PopupWidth + Swatch.AbsoluteSize.X + S(10),
                                S(4),
                                View.X - PopupWidth - S(4)
                        )
                        local Y = Clamp(AnchorPos.Y - MainPos.Y + Swatch.AbsoluteSize.Y + S(6), S(4), View.Y - S(320))
                        Popup.Position = UDim2.fromOffset(X, Y)
                        Popup.Visible = true
                        Library.OpenPopup = PopupObject
                        UpdateVisuals()
                else
                        Picker:Close()
                end
        end

        SVBase.InputBegan:Connect(function(Input)
                if Picker.Disabled or not IsPrimaryInput(Input) then
                        return
                end
                TrackDragAlong(Input, "XY", SVBase, function(Dx, Dy)
                        Picker.S = Clamp(Dx / math.max(SVBase.AbsoluteSize.X, 1), 0, 1)
                        Picker.V = 1 - Clamp(Dy / math.max(SVBase.AbsoluteSize.Y, 1), 0, 1)
                        Picker.Value = Color3.fromHSV(Picker.H, Picker.S, Picker.V)
                        Changed()
                end)
        end)
        HueBase.InputBegan:Connect(function(Input)
                if Picker.Disabled or not IsPrimaryInput(Input) then
                        return
                end
                TrackDragAlong(Input, "Y", HueBase, function(Dy)
                        Picker.H = 1 - Clamp(Dy / math.max(HueBase.AbsoluteSize.Y, 1), 0, 1)
                        Picker.Value = Color3.fromHSV(Picker.H, Picker.S, Picker.V)
                        Changed()
                end)
        end)
        if AlphaBase then
                AlphaBase.InputBegan:Connect(function(Input)
                        if Picker.Disabled or not IsPrimaryInput(Input) then
                                return
                        end
                        TrackDragAlong(Input, "X", AlphaBase, function(Dx)
                                Picker.T = Clamp(Dx / math.max(AlphaBase.AbsoluteSize.X, 1), 0, 1)
                                Picker.Transparency = Picker.T
                                Changed()
                        end)
                end)
        end

        Swatch.InputBegan:Connect(function(Input)
                if Picker.Disabled or not IsPrimaryInput(Input) then
                        return
                end
                SetPopupOpen(not Popup.Visible)
        end)

        UpdateVisuals()
        Library.Options[Idx] = Picker
        return Picker
end

local function CreateKeyPicker(Container, Idx, Info, AnchorInstance)
        assert(Idx ~= nil, "Umbra: KeyPicker requires an index")
        Info = Info or {}

        local Modes = { "Always", "Toggle", "Hold", "Press" }

        local Picker = {
                Type = "KeyPicker",
                Idx = Idx,
                Text = Info.Text or Idx,
                Value = "None",
                Mode = Info.Mode or "Toggle",
                NoUI = Info.NoUI or false,
                SyncToggleState = Info.SyncToggleState or false,
                Disabled = Info.Disabled or false,
                Visible = true,
                State = false,
                ClickCallbacks = {},
                KeyChangedCallbacks = {},
        }

        local DefaultKey = Info.Default
        local DefaultMode = nil
        if type(DefaultKey) == "table" then
                DefaultMode = DefaultKey[2]
                DefaultKey = DefaultKey[1]
        end
        if type(DefaultKey) == "string" and DefaultKey ~= "" then
                if string.sub(DefaultKey, 1, 2) == "MB" then
                        Picker.Value = DefaultKey
                else
                        local Ok, KeyCode = pcall(function()
                                return Enum.KeyCode[DefaultKey]
                        end)
                        if Ok and KeyCode then
                                Picker.Value = DefaultKey
                        end
                end
        end
        if type(DefaultMode) == "string" and FindInList(Modes, DefaultMode) then
                Picker.Mode = DefaultMode
        end

        function Picker:OnClick(Callback)
                table.insert(self.ClickCallbacks, Callback)
                return self
        end

        function Picker:OnChanged(Callback)
                table.insert(self.KeyChangedCallbacks, Callback)
                return self
        end

        local SwatchOffset = (AnchorInstance.SwatchCount or 0) * S(22)
        local KeyButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -S(6) - SwatchOffset, 0.5, 0),
                Size = UDim2.fromOffset(S(44), S(20)),
                Font = "FontMedium",
                Text = Picker.Value,
                TextColor3 = "FontColor",
                TextSize = S(12),
                ZIndex = 6,
                Parent = AnchorInstance,
        })
        Corner(4).Parent = KeyButton
        Stroke("OutlineColor", 1).Parent = KeyButton

        local ModeButton = nil
        if Picker.Mode ~= "Press" then
                ModeButton = New("TextButton", {
                        BackgroundColor3 = "MainColor",
                        AutoButtonColor = false,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -S(56) - SwatchOffset, 0.5, 0),
                        Size = UDim2.fromOffset(S(48), S(20)),
                        Font = "Font",
                        Text = Picker.Mode,
                        TextColor3 = "MutedColor",
                        TextSize = S(11),
                        ZIndex = 6,
                        Parent = AnchorInstance,
                })
                Corner(4).Parent = ModeButton
                Stroke("OutlineColor", 1).Parent = ModeButton
        end

        local function KeyFromInput(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        return "MB1"
                elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                        return "MB2"
                elseif Input.UserInputType == Enum.UserInputType.MouseButton3 then
                        return "MB3"
                elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                        return Input.KeyCode.Name
                end
                return nil
        end

        local function UpdateBindRow()
                if Picker.BindRow then
                        Picker.BindRow.KeyLabel.Text = Picker.Value .. " [" .. Picker.Mode .. "]"
                end
        end

        local function FireKeyChanged()
                for _, Callback in ipairs(Picker.KeyChangedCallbacks) do
                        SafeCallback(Callback, Picker.Value, Picker.Mode)
                end
        end

        local function FireClick(...)
                for _, Callback in ipairs(Picker.ClickCallbacks) do
                        SafeCallback(Callback, ...)
                end
        end

        local function ApplyPress()
                if Picker.SyncToggleState and Picker.ParentToggle then
                        Picker.ParentToggle:SetValue(not Picker.ParentToggle.Value)
                        return
                end
                if Picker.Mode == "Toggle" then
                        Picker.State = not Picker.State
                        FireClick(Picker.State)
                elseif Picker.Mode == "Press" then
                        FireClick(true)
                elseif Picker.Mode == "Hold" then
                        Picker.State = true
                        FireClick(true)
                end
        end

        GiveSignal(UserInputService.InputBegan:Connect(function(Input, GameProcessed)
                if Umbra.Unloaded then
                        return
                end
                if Picker.Listening then
                        local Key = KeyFromInput(Input)
                        if Input.KeyCode == Enum.KeyCode.Escape then
                                Picker.Listening = false
                                Library.KeybindListening = false
                                KeyButton.Text = Picker.Value
                                return
                        end
                        if Key then
                                Picker.Listening = false
                                Library.KeybindListening = false
                                Picker.Value = Key
                                KeyButton.Text = Key
                                UpdateBindRow()
                                FireKeyChanged()
                        end
                        return
                end
                if GameProcessed or Picker.Disabled then
                        return
                end
                local Key = KeyFromInput(Input)
                if Key and Key == Picker.Value and Picker.Mode ~= "Always" then
                        ApplyPress()
                end
        end))

        GiveSignal(UserInputService.InputEnded:Connect(function(Input)
                if Umbra.Unloaded then
                        return
                end
                local Key = KeyFromInput(Input)
                if Key and Key == Picker.Value and Picker.Mode == "Hold" and not Picker.SyncToggleState then
                        Picker.State = false
                        FireClick(false)
                end
        end))

        KeyButton.MouseButton1Click:Connect(function()
                if Picker.Disabled then
                        return
                end
                Picker.Listening = true
                Library.KeybindListening = true
                KeyButton.Text = "..."
        end)

        if ModeButton then
                ModeButton.MouseButton1Click:Connect(function()
                        if Picker.Disabled then
                                return
                        end
                        local Index = FindInList(Modes, Picker.Mode) or 1
                        Index = Index % #Modes + 1
                        Picker.Mode = Modes[Index]
                        ModeButton.Text = Picker.Mode
                        UpdateBindRow()
                        FireKeyChanged()
                end)
        end

        function Picker:GetState()
                if Picker.Mode == "Always" then
                        return true
                elseif Picker.Mode == "Toggle" or Picker.Mode == "Hold" then
                        return Picker.State
                end
                return false
        end

        function Picker:SetValue(NewValue)
                if type(NewValue) == "table" then
                        local Key = tostring(NewValue[1] or NewValue.Key or "None")
                        local Mode = tostring(NewValue[2] or NewValue.Mode or Picker.Mode)
                        if FindInList(Modes, Mode) then
                                Picker.Mode = Mode
                        end
                        if ModeButton then
                                ModeButton.Text = Picker.Mode
                        end
                        NewValue = Key
                end
                Picker.Value = tostring(NewValue)
                KeyButton.Text = Picker.Value
                UpdateBindRow()
                FireKeyChanged()
        end

        function Picker:SetText(Text)
                Picker.Text = tostring(Text)
                if Picker.BindRow then
                        Picker.BindRow.TextLabel.Text = Picker.Text
                end
        end

        function Picker:SetVisible(State)
                Picker.Visible = State ~= false
                KeyButton.Visible = Picker.Visible
                if ModeButton then
                        ModeButton.Visible = Picker.Visible
                end
        end

        if not Picker.NoUI and Library.KeybindFrame then
                local BindRow = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, S(20)),
                        Parent = Library.KeybindFrame.Holder,
                })
                local BindText = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, S(8), 0, 0),
                        Size = UDim2.new(1, -S(104), 1, 0),
                        Font = "Font",
                        Text = Picker.Text,
                        TextColor3 = "MutedColor",
                        TextSize = S(12),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = BindRow,
                })
                local BindKey = New("TextLabel", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -S(8), 0, 0),
                        Size = UDim2.new(0, S(96), 1, 0),
                        Font = "FontMedium",
                        Text = Picker.Value .. " [" .. Picker.Mode .. "]",
                        TextColor3 = "FontColor",
                        TextSize = S(12),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = BindRow,
                })
                Picker.BindRow = { Frame = BindRow, TextLabel = BindText, KeyLabel = BindKey }
        end

        Library.Options[Idx] = Picker
        return Picker
end

local function BuildElementAPI(Container)
        local Elements = {}

        function Elements:AddToggle(Idx, Info)
                assert(Idx ~= nil, "Umbra: Toggle requires an index")
                Info = Info or {}

                local Toggle = {
                        Type = "Toggle",
                        Idx = Idx,
                        Text = Info.Text or Idx,
                        Value = Info.Default == true,
                        Disabled = Info.Disabled or false,
                        Risky = Info.Risky or false,
                        Visible = Info.Visible ~= false,
                }

                AddChangedSupport(Toggle)
                if Info.Callback then
                        table.insert(Toggle.ChangedCallbacks, Info.Callback)
                end

                local Row = New("TextButton", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, S(24)),
                        Text = "",
                        AutoButtonColor = false,
                        Visible = Toggle.Visible,
                        Parent = Container.Holder,
                })

                local Box = New("Frame", {
                        BackgroundColor3 = "MainColor",
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.fromOffset(S(16), S(16)),
                        ZIndex = 3,
                        Parent = Row,
                })
                Corner(4).Parent = Box
                local BoxStroke = Stroke("OutlineColor", 1)
                BoxStroke.Parent = Box

                local Check = New("Frame", {
                        BackgroundColor3 = "AccentColor",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.fromOffset(S(8), S(8)),
                        Visible = false,
                        ZIndex = 4,
                        Parent = Box,
                })
                Corner(2).Parent = Check

                local Label = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, S(24), 0, 0),
                        Size = UDim2.new(1, -S(28), 1, 0),
                        Font = "Font",
                        Text = Toggle.Text,
                        TextColor3 = Toggle.Risky and "DangerColor" or "FontColor",
                        TextSize = S(13),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        ZIndex = 3,
                        Parent = Row,
                })

                BindTooltip(Row, Info.Tooltip)

                local function RefreshStateColors()
                        if Toggle.Value then
                                BoxStroke.Color = Umbra.Scheme.AccentColor
                        else
                                BoxStroke.Color = Umbra.Scheme.OutlineColor
                        end
                end
                table.insert(Umbra.Refreshers, RefreshStateColors)

                function Toggle:SetText(Text)
                        Toggle.Text = tostring(Text)
                        Label.Text = Toggle.Text
                end

                function Toggle:SetValue(State, SkipCallback)
                        Toggle.Value = State == true
                        Check.Visible = Toggle.Value
                        RefreshStateColors()
                        if not SkipCallback then
                                Toggle:FireChanged(Toggle.Value)
                        end
                end

                function Toggle:SetDisabled(State)
                        Toggle.Disabled = State == true
                        ApplyDisabledVisual(Toggle, Label)
                end

                function Toggle:SetVisible(State)
                        Toggle.Visible = State ~= false
                        Row.Visible = Toggle.Visible
                end

                function Toggle:AddColorPicker(ChildIdx, ChildInfo)
                        return CreateColorPicker(Container, ChildIdx, ChildInfo, Row)
                end

                function Toggle:AddKeyPicker(ChildIdx, ChildInfo)
                        ChildInfo = ChildInfo or {}
                        Label.Size = UDim2.new(1, -S(130), 1, 0)
                        local Picker = CreateKeyPicker(Container, ChildIdx, ChildInfo, Row)
                        if ChildInfo.SyncToggleState then
                                Picker.ParentToggle = Toggle
                        end
                        return Picker
                end

                Row.MouseButton1Click:Connect(function()
                        if Toggle.Disabled then
                                return
                        end
                        Toggle:SetValue(not Toggle.Value)
                end)

                if Toggle.Disabled then
                        ApplyDisabledVisual(Toggle, Label)
                end
                Toggle:SetValue(Toggle.Value, true)

                Library.Options[Idx] = Toggle
                Library.Toggles[Idx] = Toggle
                return Toggle
        end

        function Elements:AddButton(Info, Callback)
                if type(Info) ~= "table" then
                        Info = { Text = tostring(Info), Func = Callback }
                end

                local Button = {
                        Type = "Button",
                        Text = Info.Text or "Button",
                        Disabled = Info.Disabled or false,
                        Risky = Info.Risky or false,
                        DoubleClick = Info.DoubleClick or false,
                        Visible = Info.Visible ~= false,
                        SubButtons = {},
                }

                local Row = New("TextButton", {
                        BackgroundColor3 = "MainColor",
                        AutoButtonColor = false,
                        Size = UDim2.new(1, 0, 0, S(26)),
                        Text = "",
                        Visible = Button.Visible,
                        Parent = Container.Holder,
                })
                Corner(4).Parent = Row
                Stroke("OutlineColor", 1).Parent = Row

                local Label = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, S(8), 0, 0),
                        Size = UDim2.new(1, -S(16), 1, 0),
                        Font = "FontMedium",
                        Text = Button.Text,
                        TextColor3 = Button.Risky and "DangerColor" or "FontColor",
                        TextSize = S(13),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = Row,
                })

                BindTooltip(Row, Info.Tooltip)

                local LastClick = 0

                Row.MouseButton1Click:Connect(function()
                        if Button.Disabled then
                                return
                        end
                        local Now = os.clock()
                        if Button.DoubleClick then
                                if Now - LastClick < 0.35 then
                                        LastClick = 0
                                        SafeCallback(Info.Func)
                                else
                                        LastClick = Now
                                end
                        else
                                SafeCallback(Info.Func)
                        end
                end)

                Row.MouseEnter:Connect(function()
                        if not Button.Disabled then
                                Tween(Row, 0.12, { BackgroundColor3 = Umbra.Scheme.AccentDim })
                        end
                end)
                Row.MouseLeave:Connect(function()
                        Tween(Row, 0.12, { BackgroundColor3 = Umbra.Scheme.MainColor })
                end)

                function Button:SetText(Text)
                        Button.Text = tostring(Text)
                        Label.Text = Button.Text
                end

                function Button:SetDisabled(State)
                        Button.Disabled = State == true
                        ApplyDisabledVisual(Button, Label)
                end

                function Button:SetVisible(State)
                        Button.Visible = State ~= false
                        Row.Visible = Button.Visible
                end

                function Button:AddButton(SubInfo, SubCallback)
                        if type(SubInfo) ~= "table" then
                                SubInfo = { Text = tostring(SubInfo), Func = SubCallback }
                        end

                        local SubButton = {
                                Type = "SubButton",
                                Text = SubInfo.Text or "Sub button",
                                Disabled = SubInfo.Disabled or false,
                        }

                        if not Button.SubMenu then
                                New("TextLabel", {
                                        BackgroundTransparency = 1,
                                        AnchorPoint = Vector2.new(1, 0.5),
                                        Position = UDim2.new(1, -S(8), 0.5, 0),
                                        Size = UDim2.fromOffset(S(14), S(14)),
                                        Font = "Font",
                                        Text = "+",
                                        TextColor3 = "MutedColor",
                                        TextSize = S(14),
                                        Parent = Row,
                                })
                                Label.Size = UDim2.new(1, -S(30), 1, 0)

                                local SubMenu = New("Frame", {
                                        BackgroundColor3 = "BackgroundColor",
                                        Visible = false,
                                        ZIndex = 70,
                                        AutomaticSize = Enum.AutomaticSize.Y,
                                        Parent = Library.Main,
                                })
                                Corner(6).Parent = SubMenu
                                Stroke("OutlineColor", 1).Parent = SubMenu
                                New("UIListLayout", { Padding = S(2), Parent = SubMenu })
                                New("UIPadding", {
                                        PaddingTop = UDim.new(0, S(4)),
                                        PaddingBottom = UDim.new(0, S(4)),
                                        PaddingLeft = UDim.new(0, S(4)),
                                        PaddingRight = UDim.new(0, S(4)),
                                        Parent = SubMenu,
                                })
                                Button.SubMenu = SubMenu

                                Row.MouseButton1Click:Connect(function()
                                        if Button.Disabled or not Button.SubMenu then
                                                return
                                        end
                                        if Button.SubMenu.Visible then
                                                Button.SubMenu.Visible = false
                                                Library.OpenPopup = nil
                                                return
                                        end
                                        CloseOpenPopup()
                                        local View = Viewport()
                                        local AnchorPos = Row.AbsolutePosition
                                        local MainPos = Library.Main.AbsolutePosition
                                        SubMenu.Size = UDim2.fromOffset(math.max(Row.AbsoluteSize.X, S(150)), 0)
                                        local X = Clamp(AnchorPos.X - MainPos.X, S(4), View.X - SubMenu.Size.X.Offset - S(4))
                                        local Y = AnchorPos.Y - MainPos.Y + Row.AbsoluteSize.Y + S(4)
                                        SubMenu.Position = UDim2.fromOffset(X, Y)
                                        SubMenu.Visible = true
                                        Library.OpenPopup = {
                                                PopupFrame = SubMenu,
                                                Close = function()
                                                        SubMenu.Visible = false
                                                end,
                                        }
                                end)
                        end

                        local SubRow = New("TextButton", {
                                BackgroundColor3 = "MainColor",
                                AutoButtonColor = false,
                                Size = UDim2.new(1, 0, 0, S(24)),
                                Text = "",
                                Parent = Button.SubMenu,
                        })
                        Corner(4).Parent = SubRow
                        local SubLabel = New("TextLabel", {
                                BackgroundTransparency = 1,
                                Position = UDim2.new(0, S(8), 0, 0),
                                Size = UDim2.new(1, -S(16), 1, 0),
                                Font = "Font",
                                Text = SubButton.Text,
                                TextColor3 = "FontColor",
                                TextSize = S(12),
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Parent = SubRow,
                        })

                        SubRow.MouseButton1Click:Connect(function()
                                if SubButton.Disabled then
                                        return
                                end
                                Button.SubMenu.Visible = false
                                Library.OpenPopup = nil
                                SafeCallback(SubInfo.Func)
                        end)

                        function SubButton:SetText(Text)
                                SubButton.Text = tostring(Text)
                                SubLabel.Text = SubButton.Text
                        end

                        function SubButton:SetDisabled(State)
                                SubButton.Disabled = State == true
                                ApplyDisabledVisual(SubButton, SubLabel)
                        end

                        table.insert(Button.SubButtons, SubButton)
                        return SubButton
                end

                if Info.Idx then
                        Library.Options[Info.Idx] = Button
                end
                return Button
        end

        function Elements:AddLabel(Info, DoesWrap, Idx)
                if type(Info) ~= "table" then
                        Info = { Text = tostring(Info), DoesWrap = DoesWrap, Idx = Idx }
                end
                if type(DoesWrap) == "boolean" then
                        Info.DoesWrap = DoesWrap
                end

                local Label = {
                        Type = "Label",
                        Text = Info.Text or "",
                        Visible = true,
                }

                local Row = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, S(20)),
                        Parent = Container.Holder,
                })

                local TextLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -S(4), 1, 0),
                        Font = "Font",
                        Text = Label.Text,
                        TextColor3 = "FontColor",
                        TextSize = S(Info.Size or 13),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = Info.DoesWrap == true,
                        TextTruncate = Info.DoesWrap and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd,
                        Parent = Row,
                })

                if Info.DoesWrap then
                        TextLabel.AutomaticSize = Enum.AutomaticSize.Y
                        Row.AutomaticSize = Enum.AutomaticSize.Y
                        Row.Size = UDim2.new(1, 0, 0, 0)
                end

                function Label:SetText(Text)
                        Label.Text = tostring(Text)
                        TextLabel.Text = Label.Text
                end

                function Label:SetVisible(State)
                        Label.Visible = State ~= false
                        Row.Visible = Label.Visible
                end

                function Label:AddColorPicker(ChildIdx, ChildInfo)
                        return CreateColorPicker(Container, ChildIdx, ChildInfo, Row)
                end

                function Label:AddKeyPicker(ChildIdx, ChildInfo)
                        TextLabel.Size = UDim2.new(1, -S(120), 1, 0)
                        return CreateKeyPicker(Container, ChildIdx, ChildInfo or {}, Row)
                end

                if Info.Idx then
                        Library.Options[Info.Idx] = Label
                end
                return Label
        end

        function Elements:AddDivider()
                local Row = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, S(10)),
                        Parent = Container.Holder,
                })
                local Line = New("Frame", {
                        BackgroundColor3 = "OutlineColor",
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.new(1, 0, 0, S(1)),
                        Parent = Row,
                })
                return { Type = "Divider", Row = Row, Line = Line }
        end

        function Elements:AddSlider(Idx, Info)
                assert(Idx ~= nil, "Umbra: Slider requires an index")
                Info = Info or {}

                local Slider = {
                        Type = "Slider",
                        Idx = Idx,
                        Text = Info.Text or Idx,
                        Min = tonumber(Info.Min) or 0,
                        Max = tonumber(Info.Max) or 100,
                        Rounding = math.max(tonumber(Info.Rounding) or 0, 0),
                        Suffix = Info.Suffix or "",
                        Compact = Info.Compact or false,
                        HideMax = Info.HideMax or false,
                        Disabled = Info.Disabled or false,
                        Visible = Info.Visible ~= false,
                        Value = tonumber(Info.Default) or 0,
                        FormatDisplayValue = Info.FormatDisplayValue,
                }

                AddChangedSupport(Slider)
                if Info.Callback then
                        table.insert(Slider.ChangedCallbacks, Info.Callback)
                end
                Slider.Value = Clamp(Slider.Value, Slider.Min, Slider.Max)

                local Row = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Visible = Slider.Visible,
                        Parent = Container.Holder,
                })
                New("UIListLayout", { Padding = S(4), Parent = Row })

                local HeaderRow = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, S(18)),
                        Visible = not Slider.Compact,
                        Parent = Row,
                })
                local HeaderLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.6, 0, 1, 0),
                        Font = "Font",
                        Text = Slider.Text,
                        TextColor3 = "FontColor",
                        TextSize = S(13),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = HeaderRow,
                })
                local ValueLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.new(0.4, 0, 1, 0),
                        Font = "FontMedium",
                        Text = "",
                        TextColor3 = "AccentColor",
                        TextSize = S(13),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = HeaderRow,
                })

                local BarRow = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, S(16)),
                        Parent = Row,
                })
                local Bar = New("TextButton", {
                        BackgroundColor3 = "MainColor",
                        AutoButtonColor = false,
                        Text = "",
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.new(1, 0, 0, S(10)),
                        Parent = BarRow,
                })
                Corner(3).Parent = Bar
                Stroke("OutlineColor", 1).Parent = Bar

                local Fill = New("Frame", {
                        BackgroundColor3 = "AccentColor",
                        Size = UDim2.new(0, 0, 1, 0),
                        Parent = Bar,
                })
                Corner(3).Parent = Fill

                local BarValueLabel = nil
                if Slider.Compact then
                        BarValueLabel = New("TextLabel", {
                                BackgroundTransparency = 1,
                                AnchorPoint = Vector2.new(1, 0.5),
                                Position = UDim2.new(1, -S(6), 0.5, 0),
                                Size = UDim2.new(0.5, 0, 1, 0),
                                Font = "FontMedium",
                                Text = "",
                                TextColor3 = "FontColor",
                                TextSize = S(11),
                                TextXAlignment = Enum.TextXAlignment.Right,
                                ZIndex = 5,
                                Parent = Bar,
                        })
                end

                BindTooltip(Bar, Info.Tooltip)

                local function FormatValue(Value)
                        if Slider.FormatDisplayValue then
                                local Custom = Slider.FormatDisplayValue(Slider, Value)
                                if Custom ~= nil then
                                        return tostring(Custom)
                                end
                        end
                        local Number
                        if Slider.Rounding <= 0 then
                                Number = string.format("%d", Value)
                        else
                                Number = string.format("%." .. Slider.Rounding .. "f", Value)
                        end
                        return Number .. Slider.Suffix
                end

                local function UpdateVisual()
                        local Alpha = (Slider.Value - Slider.Min) / math.max(Slider.Max - Slider.Min, 0.0001)
                        Fill.Size = UDim2.new(Alpha, 0, 1, 0)
                        local Shown = FormatValue(Slider.Value)
                        if not Slider.HideMax then
                                Shown = Shown .. " / " .. FormatValue(Slider.Max)
                        end
                        ValueLabel.Text = Shown
                        if BarValueLabel then
                                BarValueLabel.Text = FormatValue(Slider.Value)
                        end
                end

                local function SetValueInternal(Value, SkipCallback)
                        Value = tonumber(Value) or Slider.Min
                        Value = Clamp(Value, Slider.Min, Slider.Max)
                        local Power = 10 ^ Slider.Rounding
                        Value = math.floor(Value * Power + 0.5) / Power
                        Slider.Value = Value
                        UpdateVisual()
                        if not SkipCallback then
                                Slider:FireChanged(Slider.Value)
                        end
                end

                Bar.InputBegan:Connect(function(Input)
                        if Slider.Disabled or not IsPrimaryInput(Input) then
                                return
                        end
                        local StartX = Input.Position.X
                        local BaseX = nil
                        local BaseWidth = nil
                        task.defer(function()
                                if Bar.Parent then
                                        BaseX = Bar.AbsolutePosition.X
                                        BaseWidth = Bar.AbsoluteSize.X
                                        local Alpha = Clamp((StartX - BaseX) / math.max(BaseWidth, 1), 0, 1)
                                        SetValueInternal(Slider.Min + Alpha * (Slider.Max - Slider.Min))
                                end
                        end)
                        TrackDragAlong(Input, "X", Bar, function(Dx)
                                if BaseX == nil then
                                        return
                                end
                                local CurrentX = StartX + Dx
                                local Alpha = Clamp((CurrentX - BaseX) / math.max(BaseWidth, 1), 0, 1)
                                SetValueInternal(Slider.Min + Alpha * (Slider.Max - Slider.Min))
                        end)
                end)

                local function RefreshColors()
                        Fill.BackgroundColor3 = Slider.Disabled and Umbra.Scheme.MutedColor or Umbra.Scheme.AccentColor
                end
                table.insert(Umbra.Refreshers, RefreshColors)

                function Slider:SetText(Text)
                        Slider.Text = tostring(Text)
                        HeaderLabel.Text = Slider.Text
                end

                function Slider:SetSuffix(Suffix)
                        Slider.Suffix = tostring(Suffix or "")
                        UpdateVisual()
                end

                function Slider:SetMin(Minimum)
                        Slider.Min = tonumber(Minimum) or Slider.Min
                        SetValueInternal(Slider.Value, true)
                end

                function Slider:SetMax(Maximum)
                        Slider.Max = tonumber(Maximum) or Slider.Max
                        SetValueInternal(Slider.Value, true)
                end

                function Slider:SetValue(Value)
                        SetValueInternal(Value)
                end

                function Slider:SetDisabled(State)
                        Slider.Disabled = State == true
                        ApplyDisabledVisual(Slider, HeaderLabel)
                        RefreshColors()
                end

                function Slider:SetVisible(State)
                        Slider.Visible = State ~= false
                        Row.Visible = Slider.Visible
                end

                SetValueInternal(Slider.Value, true)

                Library.Options[Idx] = Slider
                return Slider
        end

        function Elements:AddInput(Idx, Info)
                assert(Idx ~= nil, "Umbra: Input requires an index")
                Info = Info or {}

                local Input = {
                        Type = "Input",
                        Idx = Idx,
                        Text = Info.Text or "",
                        Value = tostring(Info.Default or ""),
                        Numeric = Info.Numeric or false,
                        Finished = Info.Finished or false,
                        ClearTextOnFocus = Info.ClearTextOnFocus ~= false,
                        Placeholder = Info.Placeholder or "",
                        MaxLength = tonumber(Info.MaxLength),
                        Disabled = Info.Disabled or false,
                        Visible = true,
                }

                AddChangedSupport(Input)
                if Info.Callback then
                        table.insert(Input.ChangedCallbacks, Info.Callback)
                end

                local Row = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Visible = Input.Visible,
                        Parent = Container.Holder,
                })
                New("UIListLayout", { Padding = S(4), Parent = Row })

                local HeaderRow = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, S(18)),
                        Visible = Input.Text ~= "",
                        Parent = Row,
                })
                local HeaderLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = "Font",
                        Text = Input.Text,
                        TextColor3 = "FontColor",
                        TextSize = S(13),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = HeaderRow,
                })

                local Box = New("Frame", {
                        BackgroundColor3 = "BackgroundColor",
                        Size = UDim2.new(1, 0, 0, S(26)),
                        Parent = Row,
                })
                Corner(4).Parent = Box
                Stroke("OutlineColor", 1).Parent = Box

                local TextBox = New("TextBox", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, S(8), 0, 0),
                        Size = UDim2.new(1, -S(16), 1, 0),
                        Font = "Font",
                        Text = Input.Value,
                        PlaceholderText = Input.Placeholder,
                        PlaceholderColor3 = Umbra.Scheme.MutedColor,
                        TextColor3 = "FontColor",
                        TextSize = S(13),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ClearTextOnFocus = Input.ClearTextOnFocus,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = Box,
                })

                BindTooltip(Box, Info.Tooltip)

                if Input.MaxLength then
                        GiveSignal(TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                                if #TextBox.Text > Input.MaxLength then
                                        TextBox.Text = string.sub(TextBox.Text, 1, Input.MaxLength)
                                end
                        end))
                end

                local function Commit()
                        if Input.Disabled then
                                return
                        end
                        local Text = TextBox.Text
                        if Input.Numeric then
                                Text = string.gsub(Text, "[^%d%-%.]", "")
                                local Number = tonumber(Text)
                                Text = Number and tostring(Number) or ""
                                TextBox.Text = Text
                        end
                        Input.Value = Text
                        Input:FireChanged(Input.Value)
                end

                TextBox.FocusLost:Connect(function(EnterPressed)
                        if Input.Finished then
                                if EnterPressed then
                                        Commit()
                                else
                                        TextBox.Text = Input.Value
                                end
                        else
                                Commit()
                        end
                end)

                function Input:SetText(Text)
                        Input.Text = tostring(Text)
                        HeaderLabel.Text = Input.Text
                        HeaderRow.Visible = Input.Text ~= ""
                end

                function Input:SetValue(Value)
                        Input.Value = tostring(Value)
                        TextBox.Text = Input.Value
                        Input:FireChanged(Input.Value)
                end

                function Input:SetDisabled(State)
                        Input.Disabled = State == true
                        ApplyDisabledVisual(Input, HeaderLabel)
                        TextBox.TextTransparency = Input.Disabled and 0.45 or 0
                end

                function Input:SetVisible(State)
                        Input.Visible = State ~= false
                        Row.Visible = Input.Visible
                end

                Library.Options[Idx] = Input
                return Input
        end

        function Elements:AddDropdown(Idx, Info)
                assert(Idx ~= nil, "Umbra: Dropdown requires an index")
                assert(Library.Main, "Umbra: create a window before adding elements")
                Info = Info or {}

                local Dropdown = {
                        Type = "Dropdown",
                        Idx = Idx,
                        Text = Info.Text or "",
                        Values = {},
                        Multi = Info.Multi or false,
                        Searchable = Info.Searchable or false,
                        MaxVisibleItems = tonumber(Info.MaxVisibleDropdownItems) or 8,
                        Disabled = Info.Disabled or false,
                        Visible = true,
                        Value = nil,
                        SpecialType = Info.SpecialType,
                        ExcludeLocalPlayer = Info.ExcludeLocalPlayer or false,
                        DisabledValues = {},
                        FormatDisplayValue = Info.FormatDisplayValue,
                }

                AddChangedSupport(Dropdown)
                if Info.Callback then
                        table.insert(Dropdown.ChangedCallbacks, Info.Callback)
                end
                if type(Info.DisabledValues) == "table" then
                        for _, Value in ipairs(Info.DisabledValues) do
                                Dropdown.DisabledValues[tostring(Value)] = true
                        end
                end
                if Dropdown.Multi then
                        Dropdown.Value = {}
                end

                local Row = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Visible = Dropdown.Visible,
                        Parent = Container.Holder,
                })
                New("UIListLayout", { Padding = S(4), Parent = Row })

                local HeaderRow = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, S(18)),
                        Visible = Dropdown.Text ~= "",
                        Parent = Row,
                })
                local HeaderLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = "Font",
                        Text = Dropdown.Text,
                        TextColor3 = "FontColor",
                        TextSize = S(13),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = HeaderRow,
                })

                local Button = New("TextButton", {
                        BackgroundColor3 = "BackgroundColor",
                        AutoButtonColor = false,
                        Text = "",
                        Size = UDim2.new(1, 0, 0, S(26)),
                        Parent = Row,
                })
                Corner(4).Parent = Button
                Stroke("OutlineColor", 1).Parent = Button

                local CurrentLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, S(8), 0, 0),
                        Size = UDim2.new(1, -S(28), 1, 0),
                        Font = "Font",
                        Text = "Select...",
                        TextColor3 = "MutedColor",
                        TextSize = S(13),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = Button,
                })

                local Chevron = New("TextLabel", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -S(8), 0.5, 0),
                        Size = UDim2.fromOffset(S(14), S(14)),
                        Font = "Font",
                        Text = "+",
                        TextColor3 = "MutedColor",
                        TextSize = S(14),
                        Parent = Button,
                })

                BindTooltip(Button, Info.Tooltip)

                local ListFrame = New("Frame", {
                        BackgroundColor3 = "BackgroundColor",
                        Visible = false,
                        ZIndex = 80,
                        Parent = Library.Main,
                })
                Corner(6).Parent = ListFrame
                Stroke("OutlineColor", 1).Parent = ListFrame
                New("UIListLayout", { Padding = S(4), Parent = ListFrame })
                New("UIPadding", {
                        PaddingTop = UDim.new(0, S(4)),
                        PaddingBottom = UDim.new(0, S(4)),
                        PaddingLeft = UDim.new(0, S(4)),
                        PaddingRight = UDim.new(0, S(4)),
                        Parent = ListFrame,
                })

                local SearchBox = nil
                if Dropdown.Searchable then
                        SearchBox = New("TextBox", {
                                BackgroundColor3 = "MainColor",
                                Size = UDim2.new(1, 0, 0, S(26)),
                                Font = "Font",
                                Text = "",
                                PlaceholderText = "Search...",
                                PlaceholderColor3 = Umbra.Scheme.MutedColor,
                                TextColor3 = "FontColor",
                                TextSize = S(13),
                                ClearTextOnFocus = false,
                                ZIndex = 81,
                                Parent = ListFrame,
                        })
                        Corner(4).Parent = SearchBox
                end

                local ListHolder = New("ScrollingFrame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, S(28)),
                        ScrollBarThickness = S(3),
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        ZIndex = 81,
                        Parent = ListFrame,
                })
                New("UIListLayout", { Padding = S(2), Parent = ListHolder })

                local function DisplayFor(Value)
                        if Dropdown.FormatDisplayValue then
                                local Custom = Dropdown.FormatDisplayValue(Value)
                                if Custom ~= nil then
                                        return tostring(Custom)
                                end
                        end
                        return tostring(Value)
                end

                local function UpdateCurrentLabel()
                        if Dropdown.Multi then
                                local Count = 0
                                local First = nil
                                for Value, Selected in pairs(Dropdown.Value or {}) do
                                        if Selected then
                                                Count = Count + 1
                                                if not First then
                                                        First = Value
                                                end
                                        end
                                end
                                if Count == 0 then
                                        CurrentLabel.Text = "Select..."
                                        CurrentLabel.TextColor3 = Umbra.Scheme.MutedColor
                                elseif Count == 1 then
                                        CurrentLabel.Text = DisplayFor(First)
                                        CurrentLabel.TextColor3 = Umbra.Scheme.FontColor
                                else
                                        CurrentLabel.Text = Count .. " selected"
                                        CurrentLabel.TextColor3 = Umbra.Scheme.FontColor
                                end
                        else
                                if Dropdown.Value == nil then
                                        CurrentLabel.Text = "Select..."
                                        CurrentLabel.TextColor3 = Umbra.Scheme.MutedColor
                                else
                                        CurrentLabel.Text = DisplayFor(Dropdown.Value)
                                        CurrentLabel.TextColor3 = Umbra.Scheme.FontColor
                                end
                        end
                end

                local function BuildList(Filter)
                        for _, Child in ipairs(ListHolder:GetChildren()) do
                                if Child:IsA("TextButton") then
                                        Child:Destroy()
                                end
                        end
                        for _, Value in ipairs(Dropdown.Values) do
                                if not Filter or string.find(string.lower(DisplayFor(Value)), string.lower(Filter), 1, true) then
                                        local IsDisabled = Dropdown.DisabledValues[Value] == true
                                        local OptionButton = New("TextButton", {
                                                BackgroundColor3 = "MainColor",
                                                AutoButtonColor = false,
                                                Text = "",
                                                Size = UDim2.new(1, 0, 0, S(22)),
                                                Parent = ListHolder,
                                        })
                                        Corner(4).Parent = OptionButton
                                        local OptionLabel = New("TextLabel", {
                                                BackgroundTransparency = 1,
                                                Position = UDim2.new(0, S(8), 0, 0),
                                                Size = UDim2.new(1, -S(16), 1, 0),
                                                Font = "Font",
                                                Text = DisplayFor(Value),
                                                TextColor3 = IsDisabled and "MutedColor" or "FontColor",
                                                TextSize = S(12),
                                                TextXAlignment = Enum.TextXAlignment.Left,
                                                TextTruncate = Enum.TextTruncate.AtEnd,
                                                Parent = OptionButton,
                                        })
                                        local Mark = nil
                                        if Dropdown.Multi then
                                                Mark = New("Frame", {
                                                        BackgroundColor3 = "AccentColor",
                                                        AnchorPoint = Vector2.new(1, 0.5),
                                                        Position = UDim2.new(1, -S(6), 0.5, 0),
                                                        Size = UDim2.fromOffset(S(12), S(12)),
                                                        Visible = Dropdown.Value[Value] == true,
                                                        Parent = OptionButton,
                                                })
                                                Corner(3).Parent = Mark
                                        end
                                        if not IsDisabled then
                                                OptionButton.MouseEnter:Connect(function()
                                                        OptionLabel.TextColor3 = Umbra.Scheme.AccentColor
                                                end)
                                                OptionButton.MouseLeave:Connect(function()
                                                        OptionLabel.TextColor3 = Umbra.Scheme.FontColor
                                                end)
                                                OptionButton.MouseButton1Click:Connect(function()
                                                        if Dropdown.Multi then
                                                                local State = not (Dropdown.Value[Value] == true)
                                                                Dropdown.Value[Value] = State
                                                                Mark.Visible = State
                                                                UpdateCurrentLabel()
                                                                Dropdown:FireChanged(Dropdown.Value)
                                                        else
                                                                Dropdown.Value = Value
                                                                UpdateCurrentLabel()
                                                                Dropdown:Close()
                                                                Dropdown:FireChanged(Dropdown.Value)
                                                        end
                                                end)
                                        end
                                end
                        end
                end

                local function SetPopupOpen(Open)
                        if Open then
                                CloseOpenPopup()
                                local View = Viewport()
                                local Width = math.max(Button.AbsoluteSize.X, S(160))
                                local OptionHeight = S(24)
                                local VisibleItems = math.max(1, math.min(#Dropdown.Values, Dropdown.MaxVisibleItems))
                                local ListHeight = VisibleItems * OptionHeight + S(8)
                                if Dropdown.Searchable then
                                        ListHeight = ListHeight + S(30)
                                end
                                local AnchorPos = Button.AbsolutePosition
                                local MainPos = Library.Main.AbsolutePosition
                                local X = Clamp(AnchorPos.X - MainPos.X, S(4), View.X - Width - S(4))
                                local Y = AnchorPos.Y - MainPos.Y + Button.AbsoluteSize.Y + S(4)
                                if Y + ListHeight > View.Y - S(8) then
                                        Y = math.max(S(4), AnchorPos.Y - MainPos.Y - ListHeight - S(4))
                                end
                                ListFrame.Position = UDim2.fromOffset(X, Y)
                                ListFrame.Size = UDim2.fromOffset(Width, ListHeight)
                                ListFrame.Visible = true
                                Chevron.Text = "-"
                                Library.OpenPopup = Dropdown
                                if SearchBox then
                                        SearchBox.Text = ""
                                        task.defer(function()
                                                if SearchBox.Parent then
                                                        SearchBox:CaptureFocus()
                                                end
                                        end)
                                end
                        else
                                ListFrame.Visible = false
                                Chevron.Text = "+"
                                if Library.OpenPopup == Dropdown then
                                        Library.OpenPopup = nil
                                end
                        end
                end

                function Dropdown:Close()
                        SetPopupOpen(false)
                end

                Dropdown.PopupFrame = ListFrame

                Button.MouseButton1Click:Connect(function()
                        if Dropdown.Disabled then
                                return
                        end
                        SetPopupOpen(not ListFrame.Visible)
                end)

                if SearchBox then
                        GiveSignal(SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                                BuildList(SearchBox.Text)
                        end))
                end

                function Dropdown:SetValues(NewValues)
                        Dropdown.Values = {}
                        if typeof(NewValues) == "table" then
                                for _, Value in ipairs(NewValues) do
                                        table.insert(Dropdown.Values, tostring(Value))
                                end
                        end
                        if Dropdown.Multi then
                                local NewSelected = {}
                                for Value, Selected in pairs(Dropdown.Value or {}) do
                                        if Selected and FindInList(Dropdown.Values, Value) then
                                                NewSelected[Value] = true
                                        end
                                end
                                Dropdown.Value = NewSelected
                        elseif Dropdown.Value ~= nil and not FindInList(Dropdown.Values, Dropdown.Value) then
                                Dropdown.Value = nil
                        end
                        BuildList(nil)
                        UpdateCurrentLabel()
                end

                function Dropdown:SetValue(NewValue)
                        if Dropdown.Multi then
                                local Selected = {}
                                if typeof(NewValue) == "table" then
                                        for Value, State in pairs(NewValue) do
                                                if FindInList(Dropdown.Values, tostring(Value)) and State == true then
                                                        Selected[tostring(Value)] = true
                                                end
                                        end
                                elseif type(NewValue) == "number" then
                                        local Target = Dropdown.Values[NewValue]
                                        if Target then
                                                Selected[Target] = true
                                        end
                                elseif type(NewValue) == "string" then
                                        if FindInList(Dropdown.Values, NewValue) then
                                                Selected[NewValue] = true
                                        end
                                end
                                Dropdown.Value = Selected
                        else
                                if type(NewValue) == "number" then
                                        NewValue = Dropdown.Values[NewValue]
                                end
                                if NewValue ~= nil then
                                        NewValue = tostring(NewValue)
                                        if not FindInList(Dropdown.Values, NewValue) then
                                                return
                                        end
                                end
                                Dropdown.Value = NewValue
                        end
                        UpdateCurrentLabel()
                        BuildList(nil)
                        Dropdown:FireChanged(Dropdown.Value)
                end

                function Dropdown:SetText(Text)
                        Dropdown.Text = tostring(Text)
                        HeaderLabel.Text = Dropdown.Text
                        HeaderRow.Visible = Dropdown.Text ~= ""
                end

                function Dropdown:SetDisabled(State)
                        Dropdown.Disabled = State == true
                        ApplyDisabledVisual(Dropdown, HeaderLabel)
                end

                function Dropdown:SetVisible(State)
                        Dropdown.Visible = State ~= false
                        Row.Visible = Dropdown.Visible
                end

                function Dropdown:GetActiveValues()
                        if Dropdown.Multi then
                                local Selected = {}
                                for Value, State in pairs(Dropdown.Value or {}) do
                                        if State then
                                                table.insert(Selected, Value)
                                        end
                                end
                                return Selected
                        end
                        return Dropdown.Value
                end

                if Dropdown.SpecialType == "Player" then
                        local function RefreshPlayers()
                                local List = {}
                                for _, Player in ipairs(Players:GetPlayers()) do
                                        if not (Dropdown.ExcludeLocalPlayer and Player == LocalPlayer) then
                                                table.insert(List, Player.Name)
                                        end
                                end
                                Dropdown:SetValues(List)
                        end
                        RefreshPlayers()
                        GiveSignal(Players.PlayerAdded:Connect(RefreshPlayers))
                        GiveSignal(Players.PlayerRemoving:Connect(RefreshPlayers))
                elseif Dropdown.SpecialType == "Team" then
                        local function RefreshTeams()
                                local List = {}
                                for _, Team in ipairs(Teams:GetTeams()) do
                                        table.insert(List, Team.Name)
                                end
                                Dropdown:SetValues(List)
                        end
                        RefreshTeams()
                        GiveSignal(Teams.TeamAdded:Connect(RefreshTeams))
                        GiveSignal(Teams.TeamRemoved:Connect(RefreshTeams))
                else
                        Dropdown:SetValues(Info.Values or {})
                        if Info.Default ~= nil then
                                Dropdown:SetValue(Info.Default)
                        end
                end

                Library.Options[Idx] = Dropdown
                return Dropdown
        end

        return Elements
end

local function CreateGroupbox(Column, Title)
        local Groupbox = {}

        local Outer = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Column,
        })
        Corner(6).Parent = Outer
        Stroke("OutlineColor", 1).Parent = Outer
        New("UIListLayout", { Padding = S(6), Parent = Outer })
        New("UIPadding", {
                PaddingTop = UDim.new(0, S(10)),
                PaddingBottom = UDim.new(0, S(12)),
                PaddingLeft = UDim.new(0, S(10)),
                PaddingRight = UDim.new(0, S(10)),
                Parent = Outer,
        })

        local TitleRow = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, S(20)),
                Parent = Outer,
        })
        New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = "FontMedium",
                Text = Title,
                TextColor3 = "FontColor",
                TextSize = S(14),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TitleRow,
        })

        local LineRow = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, S(6)),
                Parent = Outer,
        })
        New("Frame", {
                BackgroundColor3 = "OutlineColor",
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 0, S(1)),
                Parent = LineRow,
        })

        local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Outer,
        })
        New("UIListLayout", { Padding = S(4), Parent = Holder })

        Groupbox.Outer = Outer
        Groupbox.Holder = Holder
        Groupbox.Title = Title

        for Name, Method in pairs(BuildElementAPI(Groupbox)) do
                Groupbox[Name] = Method
        end

        return Groupbox
end

function Umbra:UpdateColors()
        for Index = #Umbra.Registry, 1, -1 do
                local Entry = Umbra.Registry[Index]
                local Inst = Entry.Instance
                if Inst and Inst.Parent ~= nil then
                        pcall(function()
                                Inst[Entry.Property] = Umbra.Scheme[Entry.Key]
                        end)
                else
                        table.remove(Umbra.Registry, Index)
                end
        end
        for _, Refresh in ipairs(Umbra.Refreshers) do
                pcall(Refresh)
        end
end

function Umbra:SetThemeColor(Key, Color)
        if Umbra.Scheme[Key] ~= nil and typeof(Color) == "Color3" then
                Umbra.Scheme[Key] = Color
                Umbra:UpdateColors()
        end
end

function Umbra:SetTheme(Name)
        local Theme = Umbra.Themes[Name]
        if not Theme then
                return false
        end
        for Key, Color in pairs(Theme) do
                if typeof(Color) == "Color3" then
                        Umbra.Scheme[Key] = Color
                end
        end
        Umbra:UpdateColors()
        return true
end

function Umbra:SetDPIScale(Scale)
        Umbra.DPIScale = Clamp(tonumber(Scale) or 1, 0.5, 3)
        if Library.Main and Library.BaseSize then
                Library.Main.Size = UDim2.fromOffset(S(Library.BaseSize.X), S(Library.BaseSize.Y))
        end
end

function Umbra:OnUnload(Callback)
        table.insert(Umbra.UnloadCallbacks, Callback)
end

function Umbra:Unload()
        if Umbra.Unloaded then
                return
        end
        Umbra.Unloaded = true
        CloseOpenPopup()
        HideTooltip()
        for _, Callback in ipairs(Umbra.UnloadCallbacks) do
                SafeCallback(Callback)
        end
        for Index = #Umbra.Signals, 1, -1 do
                pcall(function()
                        Umbra.Signals[Index]:Disconnect()
                end)
        end
        Umbra.Signals = {}
        if Library.ScreenGui then
                Library.ScreenGui:Destroy()
                Library.ScreenGui = nil
        end
        Library.Main = nil
        Library.KeybindFrame = nil
        Library.Watermark = nil
        Library.NotifyArea = nil
        Library.Options = {}
        Library.Toggles = {}
        Library.Registry = {}
        Library.Refreshers = {}
end

function Umbra:SetWatermarkVisibility(Visible)
        if Library.Watermark then
                Library.Watermark.Visible = Visible == true
        end
end

function Umbra:SetWatermark(Text)
        if not Library.Watermark then
                return
        end
        Text = tostring(Text or "")
        if Text == "" then
                Library.Watermark.Visible = false
                return
        end
        Library.Watermark.Label.Text = Text
        Library.Watermark.Visible = true
end

function Umbra:SetNotifySide(Side)
        if Side ~= "Left" and Side ~= "Right" then
                return
        end
        Umbra.NotifySide = Side
        if Library.NotifyArea then
                if Side == "Left" then
                        Library.NotifyArea.AnchorPoint = Vector2.new(0, 1)
                        Library.NotifyArea.Position = UDim2.new(0, S(12), 1, -S(12))
                else
                        Library.NotifyArea.AnchorPoint = Vector2.new(1, 1)
                        Library.NotifyArea.Position = UDim2.new(1, -S(12), 1, -S(12))
                end
        end
end

function Umbra:Notify(...)
        local Data = {}
        local First = select(1, ...)
        if typeof(First) == "table" then
                Data.Title = tostring(First.Title or "Notification")
                Data.Description = tostring(First.Description or First.Text or "")
                Data.Time = tonumber(First.Time) or 5
                Data.SoundId = First.SoundId
        else
                Data.Title = "Notification"
                Data.Description = tostring(First)
                Data.Time = tonumber(select(2, ...)) or 5
                Data.SoundId = select(3, ...)
        end

        if not Library.NotifyArea then
                return nil
        end

        if Data.SoundId then
                pcall(function()
                        local Sound = New("Sound", {
                                SoundId = Data.SoundId,
                                Volume = 1,
                                Parent = SoundService,
                        })
                        Sound:Play()
                        task.delay(6, function()
                                pcall(function()
                                        Sound:Destroy()
                                end)
                        end)
                end)
        end

        local Notification = { Destroyed = false }

        local Holder = New("Frame", {
                BackgroundColor3 = "MainColor",
                Size = UDim2.fromOffset(S(260), 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Library.NotifyArea,
        })
        Corner(6).Parent = Holder
        Stroke("OutlineColor", 1).Parent = Holder
        New("UIListLayout", { Padding = S(4), Parent = Holder })
        New("UIPadding", {
                PaddingTop = UDim.new(0, S(10)),
                PaddingBottom = UDim.new(0, S(10)),
                PaddingLeft = UDim.new(0, S(10)),
                PaddingRight = UDim.new(0, S(10)),
                Parent = Holder,
        })

        local TitleRow = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, S(16)),
                Parent = Holder,
        })
        New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -S(20), 1, 0),
                Font = "FontMedium",
                Text = Data.Title,
                TextColor3 = "FontColor",
                TextSize = S(13),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = TitleRow,
        })
        local CloseButton = New("TextButton", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.fromOffset(S(18), S(16)),
                Font = "Font",
                Text = "x",
                TextColor3 = "MutedColor",
                TextSize = S(14),
                Parent = TitleRow,
        })

        New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Font = "Font",
                Text = Data.Description,
                TextWrapped = true,
                TextColor3 = "MutedColor",
                TextSize = S(12),
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = Data.Description ~= "",
                Parent = Holder,
        })

        local ProgressBar = New("Frame", {
                BackgroundColor3 = "AccentColor",
                Size = UDim2.new(1, 0, 0, S(2)),
                Parent = Holder,
        })
        Corner(2).Parent = ProgressBar

        Holder.Position = UDim2.new(0, Umbra.NotifySide == "Left" and S(-40) or S(40), 0, 0)
        Tween(Holder, 0.25, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)

        function Notification:Destroy()
                if Notification.Destroyed then
                        return
                end
                Notification.Destroyed = true
                Tween(Holder, 0.2, { Position = UDim2.new(0, Umbra.NotifySide == "Left" and S(-40) or S(40), 0, 0) })
                task.delay(0.22, function()
                        pcall(function()
                                Holder:Destroy()
                        end)
                end)
        end

        CloseButton.MouseButton1Click:Connect(function()
                Notification:Destroy()
        end)

        if Data.Time > 0 then
                task.spawn(function()
                        local Steps = 30
                        for Step = 1, Steps do
                                if Notification.Destroyed or Umbra.Unloaded then
                                        return
                                end
                                task.wait(Data.Time / Steps)
                                ProgressBar.Size = UDim2.new(1 - Step / Steps, 0, 0, S(2))
                        end
                        Notification:Destroy()
                end)
        end

        return Notification
end

function Umbra:Toggle(Value)
        if not Library.Main then
                return
        end
        if Value == nil then
                Value = not Library.Main.Visible
        end
        if not Value then
                CloseOpenPopup()
                HideTooltip()
        end
        Library.Main.Visible = Value
end

function Umbra:CreateWindow(Info)
        assert(not Library.ScreenGui, "Umbra: only one window can exist per execution")
        Info = Info or {}

        local ScreenGui = New("ScreenGui", {
                Name = "UmbraUI",
                ResetOnSpawn = false,
                IgnoreGuiInset = true,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                DisplayOrder = 999,
        })
        SafeParent(ScreenGui)
        Library.ScreenGui = ScreenGui

        local BaseSize = Info.Size
        if typeof(BaseSize) == "UDim2" then
                BaseSize = Vector2.new(BaseSize.X.Offset, BaseSize.Y.Offset)
        elseif typeof(BaseSize) ~= "Vector2" then
                BaseSize = Vector2.new(680, 480)
        end
        if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
                BaseSize = Vector2.new(math.min(BaseSize.X, 420), math.min(BaseSize.Y, 360))
        end
        Library.BaseSize = BaseSize

        local View = Viewport()

        local Main = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                BorderSizePixel = 0,
                Position = Info.Position or UDim2.fromOffset(
                        math.floor((View.X - S(BaseSize.X)) / 2),
                        math.floor((View.Y - S(BaseSize.Y)) / 2.6)
                ),
                Size = UDim2.fromOffset(S(BaseSize.X), S(BaseSize.Y)),
                Parent = ScreenGui,
        })
        if Info.Center then
                Main.Position = UDim2.fromOffset(
                        math.floor((View.X - S(BaseSize.X)) / 2),
                        math.floor((View.Y - S(BaseSize.Y)) / 2)
                )
        end
        Corner(8).Parent = Main
        Stroke("OutlineColor", 1).Parent = Main
        Library.Main = Main
        Main.Visible = Info.AutoShow ~= false

        TooltipFrame = New("Frame", {
                BackgroundColor3 = "MainColor",
                Visible = false,
                ZIndex = 200,
                Parent = Main,
        })
        Corner(4).Parent = TooltipFrame
        Stroke("OutlineColor", 1).Parent = TooltipFrame
        TooltipLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -S(14), 1, 0),
                Position = UDim2.new(0, S(7), 0, 0),
                Font = "Font",
                Text = "",
                TextColor3 = "FontColor",
                TextSize = S(12),
                TextWrapped = true,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 201,
                Parent = TooltipFrame,
        })

        local Sidebar = New("Frame", {
                BackgroundColor3 = "MainColor",
                BorderSizePixel = 0,
                Size = UDim2.new(0, S(178), 1, 0),
                Parent = Main,
        })
        Corner(8).Parent = Sidebar
        New("Frame", {
                BackgroundColor3 = "MainColor",
                BorderSizePixel = 0,
                Position = UDim2.new(1, -S(8), 0, 0),
                Size = UDim2.new(0, S(8), 1, 0),
                Parent = Sidebar,
        })

        local LogoRow = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, S(46)),
                Parent = Sidebar,
        })
        if Info.Icon then
                New("ImageLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, S(12), 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.fromOffset(S(20), S(20)),
                        Image = Info.Icon,
                        ImageColor3 = "AccentColor",
                        Parent = LogoRow,
                })
        end
        New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, Info.Icon and S(40) or S(12), 0, 0),
                Size = UDim2.new(1, Info.Icon and -S(48) or -S(20), 1, 0),
                Font = "FontMedium",
                Text = Info.Title or "Umbra",
                TextColor3 = "FontColor",
                TextSize = S(15),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = LogoRow,
        })

        MakeDraggable(LogoRow, Main)

        local Divider = New("Frame", {
                BackgroundColor3 = "OutlineColor",
                BorderSizePixel = 0,
                Position = UDim2.new(0, S(178), 0, 0),
                Size = UDim2.new(0, S(1), 1, 0),
                Parent = Main,
        })

        local TabButtons = New("ScrollingFrame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, S(50)),
                Size = UDim2.new(1, 0, 1, -S(76)),
                ScrollBarThickness = S(2),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Parent = Sidebar,
        })
        New("UIListLayout", { Padding = S(2), Parent = TabButtons })

        New("TextLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, S(12), 1, -S(10)),
                Size = UDim2.new(1, -S(24), 0, S(14)),
                Font = "Font",
                Text = Info.Footer or "Umbra " .. Umbra.Version,
                TextColor3 = "MutedColor",
                TextSize = S(11),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = Sidebar,
        })

        local Content = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, S(179), 0, 0),
                Size = UDim2.new(1, -S(179), 1, 0),
                Parent = Main,
        })

        local Watermark = New("Frame", {
                BackgroundColor3 = "MainColor",
                Visible = false,
                ZIndex = 90,
                Parent = ScreenGui,
        })
        Corner(6).Parent = Watermark
        Stroke("OutlineColor", 1).Parent = Watermark
        New("UIPadding", {
                PaddingTop = UDim.new(0, S(6)),
                PaddingBottom = UDim.new(0, S(6)),
                PaddingLeft = UDim.new(0, S(10)),
                PaddingRight = UDim.new(0, S(10)),
                Parent = Watermark,
        })
        local WatermarkLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                Font = "FontMedium",
                Text = "",
                TextColor3 = "FontColor",
                TextSize = S(13),
                Parent = Watermark,
        })
        Watermark.AnchorPoint = Vector2.new(1, 0)
        Watermark.Position = UDim2.new(1, -S(12), 0, S(12))
        Library.Watermark = Watermark
        Library.Watermark.Label = WatermarkLabel

        local NotifyArea = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(S(280), math.floor(View.Y * 0.6)),
                Parent = ScreenGui,
        })
        New("UIListLayout", {
                Padding = S(8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Parent = NotifyArea,
        })
        Library.NotifyArea = NotifyArea
        Umbra:SetNotifySide(Umbra.NotifySide)

        if not Info.DisableKeybindFrame then
                local KeybindFrame = New("Frame", {
                        BackgroundColor3 = "BackgroundColor",
                        Position = UDim2.new(0, S(12), 0.5, S(60)),
                        Size = UDim2.fromOffset(S(200), 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Visible = false,
                        ZIndex = 90,
                        Parent = ScreenGui,
                })
                Corner(6).Parent = KeybindFrame
                Stroke("OutlineColor", 1).Parent = KeybindFrame
                New("UIListLayout", { Padding = S(2), Parent = KeybindFrame })
                New("UIPadding", {
                        PaddingTop = UDim.new(0, S(6)),
                        PaddingBottom = UDim.new(0, S(6)),
                        PaddingLeft = UDim.new(0, S(2)),
                        PaddingRight = UDim.new(0, S(2)),
                        Parent = KeybindFrame,
                })
                local KeybindHeader = New("TextButton", {
                        BackgroundColor3 = "MainColor",
                        AutoButtonColor = false,
                        Size = UDim2.new(1, 0, 0, S(24)),
                        Text = "",
                        Parent = KeybindFrame,
                })
                Corner(4).Parent = KeybindHeader
                New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, S(8), 0, 0),
                        Size = UDim2.new(1, -S(16), 1, 0),
                        Font = "FontMedium",
                        Text = "Keybinds",
                        TextColor3 = "FontColor",
                        TextSize = S(13),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = KeybindHeader,
                })
                local KeybindHolder = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = KeybindFrame,
                })
                New("UIListLayout", { Padding = S(2), Parent = KeybindHolder })
                MakeDraggable(KeybindHeader, KeybindFrame)
                Library.KeybindFrame = KeybindFrame
                Library.KeybindFrame.Holder = KeybindHolder
        end

        local ResizeGrip = New("TextButton", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, -S(4), 1, -S(4)),
                Size = UDim2.fromOffset(S(18), S(18)),
                Text = "",
                ZIndex = 120,
                Parent = Main,
        })
        New("TextLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, 0, 1, 0),
                Size = UDim2.fromOffset(S(10), S(10)),
                Font = "Font",
                Text = "◢",
                TextColor3 = "MutedColor",
                TextSize = S(12),
                ZIndex = 121,
                Parent = ResizeGrip,
        })

        if Info.Resizable ~= false then
                local Resizing = false
                local StartInput = nil
                local StartSize = nil
                ResizeGrip.InputBegan:Connect(function(Input)
                        if not IsPrimaryInput(Input) or Umbra.Unloaded then
                                return
                        end
                        Resizing = true
                        StartInput = Input.Position
                        StartSize = Vector2.new(Main.AbsoluteSize.X, Main.AbsoluteSize.Y)
                end)
                GiveSignal(UserInputService.InputChanged:Connect(function(Input)
                        if not Resizing or not IsMouseMove(Input) then
                                return
                        end
                        local Delta = Input.Position - StartInput
                        local CurrentView = Viewport()
                        local NewWidth = Clamp(StartSize.X + Delta.X, S(Umbra.MinWindowSize.X), CurrentView.X - S(20))
                        local NewHeight = Clamp(StartSize.Y + Delta.Y, S(Umbra.MinWindowSize.Y), CurrentView.Y - S(20))
                        Main.Size = UDim2.fromOffset(NewWidth, NewHeight)
                end))
                GiveSignal(UserInputService.InputEnded:Connect(function(Input)
                        if IsPrimaryInput(Input) then
                                Resizing = false
                        end
                end))
        end

        GiveSignal(UserInputService.InputBegan:Connect(function(Input, GameProcessed)
                if Umbra.Unloaded then
                        return
                end
                if Library.OpenPopup and not GameProcessed then
                        local PopupHolder = Library.OpenPopup.PopupFrame
                        if PopupHolder and not IsInside(PopupHolder, GetMousePos()) then
                                CloseOpenPopup()
                        end
                end
                if GameProcessed then
                        return
                end
                if Library.KeybindListening then
                        return
                end
                local ToggleBind = Library.ToggleKeybind
                if type(ToggleBind) == "table" and ToggleBind.Type == "KeyPicker" then
                        if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == ToggleBind.Value then
                                Umbra:Toggle()
                        end
                elseif Input.KeyCode == Enum.KeyCode.RightShift then
                        Umbra:Toggle()
                end
        end))

        if UserInputService.TouchEnabled then
                local MenuButton = New("TextButton", {
                        BackgroundColor3 = "BackgroundColor",
                        AnchorPoint = Vector2.new(1, 1),
                        Position = UDim2.new(1, -S(16), 1, -S(16)),
                        Size = UDim2.fromOffset(S(44), S(44)),
                        Font = "FontMedium",
                        Text = "=",
                        TextColor3 = "AccentColor",
                        TextSize = S(22),
                        ZIndex = 150,
                        Parent = ScreenGui,
                })
                Corner(22).Parent = MenuButton
                Stroke("AccentColor", 2).Parent = MenuButton
                MenuButton.MouseButton1Click:Connect(function()
                        Umbra:Toggle()
                end)
        end

        local Window = { Tabs = {}, TabCount = 0 }

        function Window:SelectTab(Selected)
                for _, Tab in ipairs(Window.Tabs) do
                        local Active = Tab == Selected
                        Tab.Page.Visible = Active
                        Tab.ActiveBar.Visible = Active
                        Tab.Button.BackgroundTransparency = Active and 0 or 1
                        Tab.ButtonLabel.TextColor3 = Active and Umbra.Scheme.FontColor or Umbra.Scheme.MutedColor
                        if Tab.TabIcon then
                                Tab.TabIcon.ImageColor3 = Active and Umbra.Scheme.AccentColor or Umbra.Scheme.MutedColor
                        end
                end
        end

        function Window:AddTab(Name, Icon)
                local Tab = { Name = Name, Groupboxes = {} }

                local TabButton = New("TextButton", {
                        BackgroundColor3 = "MainColor",
                        BackgroundTransparency = 1,
                        AutoButtonColor = false,
                        Size = UDim2.new(1, -S(8), 0, S(32)),
                        Text = "",
                        Parent = TabButtons,
                })
                Corner(6).Parent = TabButton
                local ActiveBar = New("Frame", {
                        BackgroundColor3 = "AccentColor",
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.fromOffset(S(3), S(16)),
                        Visible = false,
                        Parent = TabButton,
                })
                Corner(2).Parent = ActiveBar

                local ButtonLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, S(14), 0, 0),
                        Size = UDim2.new(1, -S(22), 1, 0),
                        Font = "FontMedium",
                        Text = Name,
                        TextColor3 = "MutedColor",
                        TextSize = S(13),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = TabButton,
                })

                local TabIcon = nil
                if Icon then
                        TabIcon = New("ImageLabel", {
                                BackgroundTransparency = 1,
                                AnchorPoint = Vector2.new(1, 0.5),
                                Position = UDim2.new(1, -S(14), 0.5, 0),
                                Size = UDim2.fromOffset(S(16), S(16)),
                                Image = Icon,
                                ImageColor3 = "MutedColor",
                                Parent = TabButton,
                        })
                        ButtonLabel.Size = UDim2.new(1, -S(44), 1, 0)
                end

                local Page = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Visible = false,
                        Parent = Content,
                })

                local LeftColumn = New("ScrollingFrame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, S(10), 0, S(10)),
                        Size = UDim2.new(0.5, -S(16), 1, -S(20)),
                        ScrollBarThickness = S(3),
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        Parent = Page,
                })
                New("UIListLayout", { Padding = S(10), Parent = LeftColumn })

                local RightColumn = New("ScrollingFrame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.5, S(6), 0, S(10)),
                        Size = UDim2.new(0.5, -S(16), 1, -S(20)),
                        ScrollBarThickness = S(3),
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        Parent = Page,
                })
                New("UIListLayout", { Padding = S(10), Parent = RightColumn })

                function Tab:AddGroupbox(Title, Side)
                        local Column = (Side == "Right") and RightColumn or LeftColumn
                        local Groupbox = CreateGroupbox(Column, Title)
                        table.insert(Tab.Groupboxes, Groupbox)
                        return Groupbox
                end

                function Tab:AddLeftGroupbox(Title)
                        return Tab:AddGroupbox(Title, "Left")
                end

                function Tab:AddRightGroupbox(Title)
                        return Tab:AddGroupbox(Title, "Right")
                end

                function Tab:Select()
                        Window:SelectTab(Tab)
                end

                Tab.Button = TabButton
                Tab.ActiveBar = ActiveBar
                Tab.Page = Page
                Tab.ButtonLabel = ButtonLabel
                Tab.TabIcon = TabIcon

                TabButton.MouseButton1Click:Connect(function()
                        Window:SelectTab(Tab)
                end)

                Window.TabCount = Window.TabCount + 1
                Window.Tabs[Name] = Tab
                table.insert(Window.Tabs, Tab)
                if Window.TabCount == 1 then
                        Window:SelectTab(Tab)
                end
                return Tab
        end

        return Window
end

function Umbra:BuildConfigSection(Tab)
        local Groupbox = Tab:AddRightGroupbox("Configuration")

        local ConfigDropdown = Groupbox:AddDropdown("UmbraConfigDropdown", {
                Text = "Config",
                Values = {},
                Searchable = true,
                Tooltip = "Saved configurations",
        })

        local NameInput = Groupbox:AddInput("UmbraConfigName", {
                Text = "Name",
                Placeholder = "config name",
                ClearTextOnFocus = false,
        })

        local function GetConfigPath(Name)
                return Umbra.ConfigFolder .. "/" .. Name .. "." .. Umbra.ConfigExtension
        end

        local function GetFolderPath()
                return Umbra.ConfigFolder
        end

        local function RefreshList()
                local Names = {}
                if FileSystem.List then
                        local Ok, Files = pcall(FileSystem.List, GetFolderPath())
                        if Ok and Files then
                                for _, Path in ipairs(Files) do
                                        local Base = string.match(Path, "[^/\\]+$") or Path
                                        local Name = string.match(Base, "^(.+)%." .. Umbra.ConfigExtension .. "$")
                                        if Name then
                                                table.insert(Names, Name)
                                        end
                                end
                        end
                end
                for Name in pairs(Umbra.MemoryConfigs) do
                        if not FindInList(Names, Name) then
                                table.insert(Names, Name)
                        end
                end
                table.sort(Names)
                ConfigDropdown:SetValues(Names)
        end

        function Umbra:SaveConfig(Name)
                Name = tostring(Name or "")
                if Name == "" then
                        Umbra:Notify({ Title = "Config", Description = "Enter a config name first.", Time = 4 })
                        return false
                end
                local Data = {}
                for Idx, Option in pairs(Library.Options) do
                        if type(Idx) ~= "string" or string.sub(Idx, 1, 5) ~= "Umbra" then
                        local Value = nil
                        if Option.Type == "Toggle" or Option.Type == "Slider" or Option.Type == "Input" then
                                Value = Option.Value
                        elseif Option.Type == "Dropdown" then
                                if Option.Multi then
                                        local Selected = {}
                                        for Key, State in pairs(Option.Value or {}) do
                                                if State then
                                                        Selected[Key] = true
                                                end
                                        end
                                        Value = Selected
                                else
                                        Value = Option.Value
                                end
                        elseif Option.Type == "ColorPicker" then
                                Value = { R = Option.Value.R, G = Option.Value.G, B = Option.Value.B, Transparency = Option.Transparency }
                        elseif Option.Type == "KeyPicker" then
                                Value = { Key = Option.Value, Mode = Option.Mode }
                        end
                        if Value ~= nil then
                                Data[Idx] = Value
                        end
                        end
                end
                local WroteToDisk = false
                if FileSystem.Write and FileSystem.MakeFolder then
                        pcall(FileSystem.MakeFolder, GetFolderPath())
                        local OkEncode, Encoded = pcall(function()
                                return HttpService:JSONEncode({
                                        Data = Data,
                                        AutoLoad = (Umbra.MemoryConfigs[Name] and Umbra.MemoryConfigs[Name].AutoLoad) or false,
                                })
                        end)
                        if OkEncode then
                                WroteToDisk = pcall(FileSystem.Write, GetConfigPath(Name), Encoded)
                        end
                end
                local WasAutoLoad = (Umbra.MemoryConfigs[Name] and Umbra.MemoryConfigs[Name].AutoLoad) or false
                Umbra.MemoryConfigs[Name] = { Data = Data, AutoLoad = WasAutoLoad }
                RefreshList()
                Umbra:Notify({
                        Title = "Config",
                        Description = (WroteToDisk and "Saved " or "Stored in memory: ") .. Name,
                        Time = 3,
                })
                return true
        end

        function Umbra:LoadConfig(Name)
                Name = tostring(Name or "")
                if Name == "" then
                        return false
                end
                local Raw = nil
                if FileSystem.Exists and FileSystem.Read then
                        local OkExists = pcall(FileSystem.Exists, GetConfigPath(Name))
                        if OkExists then
                                local OkRead, Content = pcall(FileSystem.Read, GetConfigPath(Name))
                                if OkRead then
                                        Raw = Content
                                end
                        end
                end
                if not Raw and Umbra.MemoryConfigs[Name] then
                        local OkEncode, Encoded = pcall(function()
                                return HttpService:JSONEncode(Umbra.MemoryConfigs[Name])
                        end)
                        if OkEncode then
                                Raw = Encoded
                        end
                end
                if not Raw then
                        Umbra:Notify({ Title = "Config", Description = "Config not found: " .. Name, Time = 4 })
                        return false
                end
                local OkDecode, Decoded = pcall(function()
                        return HttpService:JSONDecode(Raw)
                end)
                if not OkDecode or type(Decoded.Data) ~= "table" then
                        Umbra:Notify({ Title = "Config", Description = "Config is corrupted: " .. Name, Time = 4 })
                        return false
                end
                local Applied = 0
                for Idx, Value in pairs(Decoded.Data) do
                        local Option = Library.Options[Idx]
                        if Option then
                                if Option.Type == "ColorPicker" and type(Value) == "table" then
                                        Option:SetValueRGB(Color3.new(Value.R or 1, Value.G or 1, Value.B or 1))
                                        if Value.Transparency ~= nil then
                                                Option:SetTransparency(Value.Transparency)
                                        end
                                        Applied = Applied + 1
                                elseif Option.Type == "KeyPicker" and type(Value) == "table" then
                                        Option:SetValue({ Value.Key, Value.Mode })
                                        Applied = Applied + 1
                                elseif Option.Type ~= "Label" and Option.Type ~= "Divider" and Option.Type ~= "Button" then
                                        Option:SetValue(Value)
                                        Applied = Applied + 1
                                end
                        end
                end
                Umbra:Notify({ Title = "Config", Description = "Loaded " .. Name .. " (" .. Applied .. " options)", Time = 3 })
                return true
        end

        function Umbra:DeleteConfig(Name)
                Name = tostring(Name or "")
                if Name == "" then
                        return false
                end
                if FileSystem.Exists and FileSystem.Write then
                        local OkExists = pcall(FileSystem.Exists, GetConfigPath(Name))
                        if OkExists then
                                pcall(FileSystem.Write, GetConfigPath(Name), "")
                        end
                end
                Umbra.MemoryConfigs[Name] = nil
                RefreshList()
                Umbra:Notify({ Title = "Config", Description = "Deleted " .. Name, Time = 3 })
                return true
        end

        function Umbra:SetAutoLoad(Name, State)
                Name = tostring(Name or "")
                if Name == "" then
                        return false
                end
                local Previous = Umbra.MemoryConfigs[Name]
                Umbra.MemoryConfigs[Name] = {
                        Data = (Previous and Previous.Data) or {},
                        AutoLoad = State == true,
                }
                if FileSystem.Exists and FileSystem.Write then
                        local OkExists = pcall(FileSystem.Exists, GetConfigPath(Name))
                        if OkExists then
                                local OkRead, Content = pcall(FileSystem.Read, GetConfigPath(Name))
                                if OkRead then
                                        local OkDecode, Decoded = pcall(function()
                                                return HttpService:JSONDecode(Content)
                                        end)
                                        if OkDecode then
                                                Decoded.AutoLoad = State == true
                                                pcall(FileSystem.MakeFolder, GetFolderPath())
                                                pcall(FileSystem.Write, GetConfigPath(Name), HttpService:JSONEncode(Decoded))
                                        end
                                end
                        end
                end
                Umbra:Notify({ Title = "Config", Description = Name .. " autoload: " .. tostring(State == true), Time = 3 })
                return true
        end

        function Umbra:LoadAutoloadConfig()
                if FileSystem.List then
                        local Ok, Files = pcall(FileSystem.List, GetFolderPath())
                        if Ok and Files then
                                for _, Path in ipairs(Files) do
                                        local Base = string.match(Path, "[^/\\]+$") or Path
                                        local Name = string.match(Base, "^(.+)%." .. Umbra.ConfigExtension .. "$")
                                        if Name then
                                                local OkRead, Content = pcall(FileSystem.Read, GetConfigPath(Name))
                                                if OkRead then
                                                        local OkDecode, Decoded = pcall(function()
                                                                return HttpService:JSONDecode(Content)
                                                        end)
                                                        if OkDecode and Decoded.AutoLoad then
                                                                return Umbra:LoadConfig(Name)
                                                        end
                                                end
                                        end
                                end
                        end
                end
                for Name, Config in pairs(Umbra.MemoryConfigs) do
                        if Config.AutoLoad then
                                return Umbra:LoadConfig(Name)
                        end
                end
                return false
        end

        Groupbox:AddButton({
                Text = "Save",
                Func = function()
                        Umbra:SaveConfig(NameInput.Value)
                end,
        })
        Groupbox:AddButton({
                Text = "Load",
                Func = function()
                        Umbra:LoadConfig(ConfigDropdown.Value)
                end,
        })
        Groupbox:AddButton({
                Text = "Delete",
                Func = function()
                        Umbra:DeleteConfig(ConfigDropdown.Value)
                end,
        })
        Groupbox:AddButton({
                Text = "Refresh list",
                Func = function()
                        RefreshList()
                end,
        })
        Groupbox:AddButton({
                Text = "Set autoload",
                Func = function()
                        Umbra:SetAutoLoad(ConfigDropdown.Value, true)
                end,
        })
        Groupbox:AddButton({
                Text = "Load autoload config",
                Func = function()
                        Umbra:LoadAutoloadConfig()
                end,
        })

        RefreshList()
        return Groupbox
end

function Umbra:BuildThemeSection(Tab)
        local Groupbox = Tab:AddLeftGroupbox("Theme")

        local ThemeNames = {}
        for Name in pairs(Umbra.Themes) do
                table.insert(ThemeNames, Name)
        end
        table.sort(ThemeNames)

        Groupbox:AddDropdown("UmbraThemeDropdown", {
                Text = "Theme",
                Values = ThemeNames,
                Default = "Default",
                Tooltip = "Menu color theme",
                Callback = function(Value)
                        Umbra:SetTheme(Value)
                end,
        })

        Groupbox:AddLabel("Accent"):AddColorPicker("UmbraAccentColor", {
                Title = "Accent color",
                Default = Umbra.Scheme.AccentColor,
                Callback = function(Value)
                        Umbra:SetThemeColor("AccentColor", Value)
                        Umbra:SetThemeColor("AccentDim", Color3.new(Value.R * 0.5, Value.G * 0.5, Value.B * 0.5))
                end,
        })

        return Groupbox
end

function Umbra:IsLightTheme()
        local Background = Umbra.Scheme.BackgroundColor
        return (Background.R + Background.G + Background.B) / 3 > 0.5
end

function Umbra:GetState(Idx)
        local Option = Library.Options[Idx]
        if Option then
                return Option.Value
        end
        return nil
end

return Umbra
