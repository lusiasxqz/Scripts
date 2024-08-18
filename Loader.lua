repeat wait() until game.Players
repeat wait() until game.Players.LocalPlayer
repeat wait() until game.ReplicatedStorage
repeat wait() until game.ReplicatedStorage:FindFirstChild("Remotes");
repeat wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui");
repeat wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("Main");
repeat wait() until game:GetService("Players")
repeat wait() until game:GetService("Players").LocalPlayer.Character:FindFirstChild("Energy")

if not game:IsLoaded() then repeat game.Loaded:Wait() until game:IsLoaded() end
if game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("ChooseTeam") then
    repeat wait()
        if game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Main").ChooseTeam.Visible == true then
            if _G.Team == "Pirate" then
                for i, v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container.Pirates.Frame.TextButton.Activated)) do                                                                                                
                    v.Function()
                end
            elseif _G.Team == "Marine" then
                for i, v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container.Marines.Frame.TextButton.Activated)) do                                                                                                
                    v.Function()
                end
            else
                for i, v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container.Pirates.Frame.TextButton.Activated)) do                                                                                                
                    v.Function()
                end
            end
        end
    until game.Players.LocalPlayer.Team ~= nil and game:IsLoaded()
end

wait(1)

local InputService = game:GetService('UserInputService');
local TextService = game:GetService('TextService');
local TweenService = game:GetService('TweenService');
local CoreGui = game:GetService('CoreGui');
local RenderStepped = game:GetService('RunService').RenderStepped;
local LocalPlayer = game:GetService('Players').LocalPlayer;
local Mouse = LocalPlayer:GetMouse();

local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end);

ScreenGui = Instance.new('ScreenGui');
ScreenGui.Name = "SixMaHub"
ProtectGui(ScreenGui);

ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
ScreenGui.Parent = CoreGui;

local Toggles = {};
local Options = {};

getgenv().Toggles = Toggles;
getgenv().Options = Options;

local Library = {
    Registry = {};
    RegistryMap = {};

    HudRegistry = {};

    FontColor = Color3.fromRGB(255, 255, 255);
    MainColor = Color3.fromRGB(28, 28, 28);
    BackgroundColor = Color3.fromRGB(20, 20, 20);
    AccentColor = Color3.fromRGB(253, 0, 44);
    OutlineColor = Color3.fromRGB(50, 50, 50);

    Black = Color3.new(0, 0, 0);

    OpenedFrames = {};
};

task.spawn(function()
    local Tick = tick();
    local Hue = 0;

    while RenderStepped:Wait() do
        if tick() - Tick >= (1 / 60) then
            Hue = Hue + (1 / 400);

            if Hue > 1 then
                Hue = 0;
            end;

            Library.CurrentRainbowHue = Hue;
            Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1);

            Tick = tick();
        end;
    end;
end);

function Library:AttemptSave()
    if Library.SaveManager then
        Library.SaveManager:Save();
    end;
end;

function Library:Create(Class, Properties)
    local _Instance = Class;

    if type(Class) == 'string' then
        _Instance = Instance.new(Class);
    end;

    for Property, Value in next, Properties do
        _Instance[Property] = Value;
    end;

    return _Instance;
end;

function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        Font = Enum.Font.Code;
        TextColor3 = Library.FontColor;
        TextSize = 16;
        TextStrokeTransparency = 0;
    });

    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor';
    }, IsHud);

    return Library:Create(_Instance, Properties);
end;


function Library:MakeDraggable(Instance, Cutoff)
    Instance.Active = true;

    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local ObjPos = Vector2.new(
                Mouse.X - Instance.AbsolutePosition.X,
                Mouse.Y - Instance.AbsolutePosition.Y
            );

            if ObjPos.Y > (Cutoff or 40) then
                return;
            end;

            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                Instance.Position = UDim2.new(
                    0,
                    Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                    0,
                    Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
                );

                RenderStepped:Wait();
            end;
        end;
    end);
end;

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
    HighlightInstance.MouseEnter:Connect(function()
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, Properties do
            Instance[Property] = Library[ColorIdx] or ColorIdx;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end);

    HighlightInstance.MouseLeave:Connect(function()
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, PropertiesDefault do
            Instance[Property] = Library[ColorIdx] or ColorIdx;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end);
end;

function Library:MouseIsOverOpenedFrame()
    for Frame, _ in next, Library.OpenedFrames do
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

        if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
            and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

            return true;
        end;
    end;
end;

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
end;

function Library:GetTextBounds(Text, Font, Size)
    return TextService:GetTextSize(Text, Size, Font, Vector2.new(1920, 1080)).X;
end;

function Library:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color);
    return Color3.fromHSV(H, S, V / 1.5);
end; Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);

function Library:AddToRegistry(Instance, Properties, IsHud)
    local Idx = #Library.Registry + 1;
    local Data = {
        Instance = Instance;
        Properties = Properties;
        Idx = Idx;
    };

    table.insert(Library.Registry, Data);
    Library.RegistryMap[Instance] = Data;

    if IsHud then
        table.insert(Library.HudRegistry, Data);
    end;
end;

function Library:RemoveFromRegistry(Instance)
    local Data = Library.RegistryMap[Instance];

    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then
                table.remove(Library.Registry, Idx);
            end;
        end;

        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then
                table.remove(Library.HudRegistry, Idx);
            end;
        end;

        Library.RegistryMap[Instance] = nil;
    end;
end;

ScreenGui.DescendantRemoving:Connect(function(Instance)
    if Library.RegistryMap[Instance] then
        Library:RemoveFromRegistry(Instance);
    end;
end);

function Library:UpdateColorsUsingRegistry()
    -- TODO: Could have an 'active' list of objects
    -- where the active list only contains Visible objects.

    -- IMPL: Could setup .Changed events on the AddToRegistry function
    -- that listens for the 'Visible' propert being changed.
    -- Visible: true => Add to active list, and call UpdateColors function
    -- Visible: false => Remove from active list.

    -- The above would be especially efficient for a rainbow menu color or live color-changing.

    for Idx, Object in next, Library.Registry do
        for Property, ColorIdx in next, Object.Properties do
            Object.Instance[Property] = Library[ColorIdx];
        end;
    end;
end;

local BaseAddons = {};

do
    local Funcs = {};

    function Funcs:AddColorPicker(Idx, Info)
        local ToggleLabel = self.TextLabel;
        local Container = self.Container;

        local ColorPicker = {
            Value = Info.Default;
            Type = 'ColorPicker';
        };

        function ColorPicker:SetHSVFromRGB(Color)
            local H, S, V = Color3.toHSV(Color);

            ColorPicker.Hue = H;
            ColorPicker.Sat = S;
            ColorPicker.Vib = V;
        end;

        ColorPicker:SetHSVFromRGB(ColorPicker.Value);

        local DisplayFrame = Library:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value;
            BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(0, 28, 0, 14);
            ZIndex = 6;
            Parent = ToggleLabel;
        });

        local RelativeOffset = 0;

        for _, Element in next, Container:GetChildren() do
            if not Element:IsA('UIListLayout') then
                RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
            end;
        end;

        local PickerFrameOuter = Library:Create('Frame', {
            Name = 'Color';
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 20 + RelativeOffset + 1);
            Size = UDim2.new(1, -4, 0, 234);
            Visible = false;
            ZIndex = 15;
            Parent = Container.Parent;
        });

        local PickerFrameInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });

        Library:AddToRegistry(PickerFrameInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local Highlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        Library:AddToRegistry(Highlight, {
            BackgroundColor3 = 'AccentColor';
        });

        local SatVibMapOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 6);
            Size = UDim2.new(0, 200, 0, 200);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local SatVibMapInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = SatVibMapOuter;
        });

        Library:AddToRegistry(SatVibMapInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local SatVibMap = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Image = 'rbxassetid://4155801252';
            Parent = SatVibMapInner;
        });

        local HueSelectorOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 211, 0, 7);
            Size = UDim2.new(0, 15, 0, 198);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local HueSelectorInner = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = HueSelectorOuter;
        });

        local HueTextSize = Library:GetTextBounds('Hex color', Enum.Font.Code, 16) + 3
        local RgbTextSize = Library:GetTextBounds('255, 255, 255', Enum.Font.Code, 16) + 3

        local HueBoxOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(4, 209),
            Size = UDim2.new(0.5, -6, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameInner;
        });

        local HueBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18,
            Parent = HueBoxOuter;
        });

        Library:AddToRegistry(HueBoxInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = HueBoxInner;
        });

        local HueBox = Library:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = Enum.Font.Code;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = 'Hex color',
            Text = '#FFFFFF',
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = HueBoxInner;
        });

        local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
            Position = UDim2.new(0.5, 2, 0, 209),
            Size = UDim2.new(0.5, -6, 0, 20),
            Parent = PickerFrameInner
        })  

        Library:AddToRegistry(RgbBoxBase.Frame, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local RgbBox = Library:Create(RgbBoxBase.Frame:FindFirstChild('TextBox'), {
            Text = '255, 255, 255',
            PlaceholderText = 'RGB color',
        })

        local SequenceTable = {};

        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
        end;

        local HueSelectorGradient = Library:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable);
            Rotation = 90;
            Parent = HueSelectorInner;
        });

        HueBox.FocusLost:Connect(function(enter)
            if enter then
                local success, result = pcall(Color3.fromHex, HueBox.Text)
                if success and typeof(result) == 'Color3' then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
            end

            ColorPicker:Display()
        end)

        RgbBox.FocusLost:Connect(function(enter)
            if enter then
                local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
                if r and g and b then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
            end

            ColorPicker:Display()
        end)

        function ColorPicker:Display()
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

            Library:Create(DisplayFrame, {
                BackgroundColor3 = ColorPicker.Value;
                BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            });

            HueBox.Text = '#' .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

            if ColorPicker.Changed then
                ColorPicker.Changed();
            end;
        end;

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func;
            Func();
        end;

        function ColorPicker:Show()
            for Frame, Val in next, Library.OpenedFrames do
                if Frame.Name == 'Color' then
                    Frame.Visible = false;
                    Library.OpenedFrames[Frame] = nil;
                end;
            end;

            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;
        end;

        function ColorPicker:Hide()
            PickerFrameOuter.Visible = false;
            Library.OpenedFrames[PickerFrameOuter] = nil;
        end;

        function ColorPicker:SetValue(HSV)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        function ColorPicker:SetValueRGB(Color)
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        SatVibMap.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local MinX = SatVibMap.AbsolutePosition.X;
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X;
                    local MouseX = math.clamp(Mouse.X, MinX, MaxX);

                    local MinY = SatVibMap.AbsolutePosition.Y;
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                    ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
                    ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        HueSelectorInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local MinY = HueSelectorInner.AbsolutePosition.Y;
                    local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y;
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                    ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        DisplayFrame.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                if PickerFrameOuter.Visible then
                    ColorPicker:Hide();
                else
                    ColorPicker:Show();
                end;
            end;
        end);

        InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize;

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    ColorPicker:Hide();
                end;
            end;
        end);

        ColorPicker:Display();

        Options[Idx] = ColorPicker;

        return self;
    end;

    function Funcs:AddKeyPicker(Idx, Info)
        local ToggleLabel = self.TextLabel;
        local Container = self.Container;

        local KeyPicker = {
            Value = Info.Default;
            Toggled = false;
            Mode = Info.Mode or 'Toggle'; -- Always, Toggle, Hold
            Type = 'KeyPicker';
        };

        local RelativeOffset = 0;

        for _, Element in next, Container:GetChildren() do
            if not Element:IsA('UIListLayout') then
                RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
            end;
        end;

        local PickOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 28, 0, 15);
            ZIndex = 6;
            Parent = ToggleLabel;
        });

        local PickInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 7;
            Parent = PickOuter;
        });

        Library:AddToRegistry(PickInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 13;
            Text = Info.Default;
            TextWrapped = true;
            ZIndex = 8;
            Parent = PickInner;
        });

        local ModeSelectOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(1, 0, 0, RelativeOffset + 1);
            Size = UDim2.new(0, 60, 0, 45 + 2);
            Visible = false;
            ZIndex = 14;
            Parent = Container.Parent;
        });

        local ModeSelectInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 15;
            Parent = ModeSelectOuter;
        });

        Library:AddToRegistry(ModeSelectInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ModeSelectInner;
        });

        local ContainerLabel = Library:CreateLabel({
            TextXAlignment = Enum.TextXAlignment.Left;
            Size = UDim2.new(1, 0, 0, 18);
            TextSize = 13;
            Visible = false;
            ZIndex = 110;
            Parent = Library.KeybindContainer;
        },  true);

        local Modes = Info.Modes or { 'Always', 'Toggle', 'Hold' };
        local ModeButtons = {};

        for Idx, Mode in next, Modes do
            local ModeButton = {};

            local Label = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 13;
                Text = Mode;
                ZIndex = 16;
                Parent = ModeSelectInner;
            });

            function ModeButton:Select()
                for _, Button in next, ModeButtons do
                    Button:Deselect();
                end;

                KeyPicker.Mode = Mode;

                Label.TextColor3 = Library.AccentColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor';

                ModeSelectOuter.Visible = false;
            end;

            function ModeButton:Deselect()
                KeyPicker.Mode = nil;

                Label.TextColor3 = Library.FontColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor';
            end;

            Label.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    ModeButton:Select();
                    Library:AttemptSave();
                end;
            end);

            if Mode == KeyPicker.Mode then
                ModeButton:Select();
            end;

            ModeButtons[Mode] = ModeButton;
        end;

        function KeyPicker:Update()
            if Info.NoUI then
                return;
            end;

            local State = KeyPicker:GetState();

            ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, Info.Text, KeyPicker.Mode);
            ContainerLabel.Visible = true;
            ContainerLabel.TextColor3 = State and Library.AccentColor or Library.FontColor;

            Library.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor';

            local YSize = 0;

            for _, Label in next, Library.KeybindContainer:GetChildren() do
                if not Label:IsA('UIListLayout') then
                    if Label.Visible then
                        YSize = YSize + 18;
                    end;
                end;
            end;

            Library.KeybindFrame.Size = UDim2.new(0, 210, 0, 20 + YSize);
        end;

        function KeyPicker:GetState()
            if KeyPicker.Mode == 'Always' then
                return true;
            elseif KeyPicker.Mode == 'Hold' then
                local Key = KeyPicker.Value;

                if Key == 'MB1' or Key == 'MB2' then
                    return Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                        or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
                else
                    return InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]);
                end;
            else
                return KeyPicker.Toggled;
            end;
        end;

        function KeyPicker:SetValue(Data)
            local Key, Mode = Data[1], Data[2];
            DisplayLabel.Text = Key;
            KeyPicker.Value = Key;
            ModeButtons[Mode]:Select();
            KeyPicker:Update();
        end;

        function KeyPicker:OnClick(Callback)
            KeyPicker.Clicked = Callback
        end

        function KeyPicker:DoClick()
            if KeyPicker.Clicked then
                KeyPicker.Clicked()
            end
        end

        local Picking = false;

        PickOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                Picking = true;

                DisplayLabel.Text = '';

                local Break;
                local Text = '';

                task.spawn(function()
                    while (not Break) do
                        if Text == '...' then
                            Text = '';
                        end;

                        Text = Text .. '.';
                        DisplayLabel.Text = Text;

                        wait(0.4);
                    end;
                end);

                wait(0.2);

                local Event;
                Event = InputService.InputBegan:Connect(function(Input)
                    local Key;

                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        Key = Input.KeyCode.Name;
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Key = 'MB1';
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                        Key = 'MB2';
                    end;

                    Break = true;
                    Picking = false;

                    DisplayLabel.Text = Key;
                    KeyPicker.Value = Key;

                    Library:AttemptSave();

                    Event:Disconnect();
                end);
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                ModeSelectOuter.Visible = true;
            end;
        end);

        InputService.InputBegan:Connect(function(Input)
            if (not Picking) then
                if KeyPicker.Mode == 'Toggle' then
                    local Key = KeyPicker.Value;

                    if Key == 'MB1' or Key == 'MB2' then
                        if Key == 'MB1' and Input.UserInputType == Enum.UserInputType.MouseButton1
                        or Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
                            KeyPicker.Toggled = not KeyPicker.Toggled
                            KeyPicker:DoClick()
                        end;
                    elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                        if Input.KeyCode.Name == Key then
                            KeyPicker.Toggled = not KeyPicker.Toggled;
                            KeyPicker:DoClick()
                        end;
                    end;
                end;

                KeyPicker:Update();
            end;

            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    ModeSelectOuter.Visible = false;
                end;
            end;
        end);

        InputService.InputEnded:Connect(function(Input)
            if (not Picking) then
                KeyPicker:Update();
            end;
        end);

        KeyPicker:Update();

        Options[Idx] = KeyPicker;

        return self;
    end;

    BaseAddons.__index = Funcs;
    BaseAddons.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;

local BaseGroupbox = {};

do
    local Funcs = {};

    function Funcs:AddBlank(Size)
        local Groupbox = self;
        local Container = Groupbox.Container;

        Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, Size);
            ZIndex = 1;
            Parent = Container;
        });
    end;

    function Funcs:AddLabel(Text)
        local Labell = {};

        local Groupbox = self;
        local Container = Groupbox.Container;

        local TextLabel = Library:CreateLabel({
            Size = UDim2.new(1, -4, 0, 15);
            TextSize = 14;
            Text = Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = TextLabel;
        });

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        function Labell:Set(newtext)
            TextLabel.Text = newtext
        end
        return Labell
    end;

    function Funcs:AddButton(Text, Func)
        local Button = {};

        local Groupbox = self;
        local Container = Groupbox.Container;

        local ButtonOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(ButtonOuter, {
            BorderColor3 = 'Black';
        });

        local ButtonInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = ButtonOuter;
        });

        Library:AddToRegistry(ButtonInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = ButtonInner;
        });

        local ButtonLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 14;
            Text = Text;
            ZIndex = 6;
            Parent = ButtonInner;
        });

        Library:OnHighlight(ButtonOuter, ButtonOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        ButtonOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                Func();
            end;
        end);

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        return Button;
    end;

    function Funcs:AddInput(Idx, Info)
        local Textbox = {
            Value = Info.Default;
            Type = 'Input';
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local InputLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 15);
            TextSize = 14;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });

        Groupbox:AddBlank(1);

        local TextBoxOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
        });

        local TextBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = TextBoxOuter;
        });

        Library:AddToRegistry(TextBoxInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = TextBoxInner;
        });

        local Box = Library:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = Enum.Font.Code;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = Info.Placeholder;
            Text = Info.Default;
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 7;
            Parent = TextBoxInner;
            TextTruncate = Enum.TextTruncate.AtEnd
        });

        function Textbox:SetValue(Text)
            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength);
            end;

            if Textbox.Changed then
                Textbox.Changed();
            end;

            Textbox.Value = Text;
            Box.Text = Text;
        end;

        Box:GetPropertyChangedSignal('Text'):Connect(function()
            if Text ~= Box.Text then
                Text = Box.Text
            end
            Textbox:SetValue(Text);
            Textbox:SetValue(Text);
            Library:AttemptSave();
        end);

        Library:AddToRegistry(Box, {
            TextColor3 = 'FontColor';
        });

        function Textbox:OnChanged(Func)
            Textbox.Changed = Func;
            Func();
        end;

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        Options[Idx] = Textbox;

        return Textbox;
    end;

    function Funcs:AddToggle(Idx, Info)
        local Toggle = {
            Value = Info.Default or false;
            Type = 'Toggle';
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local ToggleOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 13, 0, 13);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(ToggleOuter, {
            BorderColor3 = 'Black';
        });

        local ToggleInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = ToggleOuter;
        });

        Library:AddToRegistry(ToggleInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local ToggleLabel = Library:CreateLabel({
            Size = UDim2.new(0, 216, 1, 0);
            Position = UDim2.new(1, 6, 0, 0);
            TextSize = 14;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 6;
            Parent = ToggleInner;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ToggleLabel;
        });

        local ToggleRegion = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(0, 170, 1, 0);
            ZIndex = 8;
            Parent = ToggleOuter;
        });

        Library:OnHighlight(ToggleRegion, ToggleOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        function Toggle:UpdateColors()
            Toggle:Display();
        end;

        function Toggle:Display()
            ToggleInner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.MainColor;
            ToggleInner.BorderColor3 = Toggle.Value and Library.AccentColorDark or Library.OutlineColor;

            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor';
            Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor';
        end;

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func;
            Func();
        end;

        function Toggle:SetValue(Bool)
            Toggle.Value = Bool;
            Toggle:Display();

            if Toggle.Changed then
                Toggle.Changed();
            end;
        end;

        ToggleRegion.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                Toggle.Value = not Toggle.Value;
                Toggle:Display();

                if Toggle.Changed then
                    Toggle.Changed();
                end;

                Library:AttemptSave();
            end;
        end);

        Toggle:Display();
        Groupbox:AddBlank(Info.BlankSize or 5 + 2);
        Groupbox:Resize();

        Toggle.TextLabel = ToggleLabel;
        Toggle.Container = Container;
        setmetatable(Toggle, BaseAddons);

        Toggles[Idx] = Toggle;

        return Toggle;
    end;

    function Funcs:AddSlider(Idx, Info)
        assert(Info.Default and Info.Text and Info.Min and Info.Max and Info.Rounding, 'Bad Slider Data');

        local Slider = {
            Value = Info.Default;
            Min = Info.Min;
            Max = Info.Max;
            Rounding = Info.Rounding;
            MaxSize = 232;
            Type = 'Slider';
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        if not Info.Compact then
            Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = 5;
                Parent = Container;
            });

            Groupbox:AddBlank(3);
        end

        local SliderOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 13);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(SliderOuter, {
            BorderColor3 = 'Black';
        });

        local SliderInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = SliderOuter;
        });

        Library:AddToRegistry(SliderInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local Fill = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderColor3 = Library.AccentColorDark;
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 7;
            Parent = SliderInner;
        });

        Library:AddToRegistry(Fill, {
            BackgroundColor3 = 'AccentColor';
            BorderColor3 = 'AccentColorDark';
        });

        local HideBorderRight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(1, 0, 0, 0);
            Size = UDim2.new(0, 1, 1, 0);
            ZIndex = 8;
            Parent = Fill;
        });

        Library:AddToRegistry(HideBorderRight, {
            BackgroundColor3 = 'AccentColor';
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 14;
            Text = 'Infinite';
            ZIndex = 9;
            Parent = SliderInner;
        });

        Library:OnHighlight(SliderOuter, SliderOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        function Slider:UpdateColors()
            Fill.BackgroundColor3 = Library.AccentColor;
            Fill.BorderColor3 = Library.AccentColorDark;
        end;

        function Slider:Display()
            local Suffix = Info.Suffix or '';
            DisplayLabel.Text = string.format('%s/%s', Slider.Value .. Suffix, Slider.Max .. Suffix);

            local X = math.ceil(Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Slider.MaxSize));
            Fill.Size = UDim2.new(0, X, 1, 0);

            HideBorderRight.Visible = not (X == Slider.MaxSize or X == 0);
        end;

        function Slider:OnChanged(Func)
            Slider.Changed = Func;
            Func();
        end;

        local function Round(Value)
            if Slider.Rounding == 0 then
                return math.floor(Value);
            end;

            local Str = Value .. '';
            local Dot = Str:find('%.');

            return Dot and tonumber(Str:sub(1, Dot + Slider.Rounding)) or Value;
        end;

        function Slider:GetValueFromXOffset(X)
            return Round(Library:MapValue(X, 0, Slider.MaxSize, Slider.Min, Slider.Max));
        end;

        function Slider:SetValue(Str)
            local Num = tonumber(Str);

            if (not Num) then
                return;
            end;

            Num = math.clamp(Num, Slider.Min, Slider.Max);

            Slider.Value = Num;
            Slider:Display();

            if Slider.Changed then
                Slider.Changed();
            end;
        end;

        SliderInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                local mPos = Mouse.X;
                local gPos = Fill.Size.X.Offset;
                local Diff = mPos - (Fill.AbsolutePosition.X + gPos);

                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local nMPos = Mouse.X;
                    local nX = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider.MaxSize);

                    local nValue = Slider:GetValueFromXOffset(nX);
                    local OldValue = Slider.Value;
                    Slider.Value = nValue;

                    Slider:Display();

                    if nValue ~= OldValue and Slider.Changed then
                        Slider.Changed();
                    end;

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        Slider:Display();
        Groupbox:AddBlank(Info.BlankSize or 6);
        Groupbox:Resize();

        Options[Idx] = Slider;

        return Slider;
    end;

    function Funcs:AddDropdown(Idx, Info)
        assert(Info.Text and Info.Values, 'Bad Dropdown Data');

        local Dropdown = {
            Values = Info.Values;
            Value = Info.Multi and {};
            Multi = Info.Multi;
            Type = 'Dropdown';
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local RelativeOffset = 0;

        local DropdownLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 10);
            TextSize = 14;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Bottom;
            ZIndex = 5;
            Parent = Container;
        });

        Groupbox:AddBlank(3);

        for _, Element in next, Container:GetChildren() do
            if not Element:IsA('UIListLayout') then
                RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
            end;
        end;

        local DropdownOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(DropdownOuter, {
            BorderColor3 = 'Black';
        });

        local DropdownInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DropdownOuter;
        });

        Library:AddToRegistry(DropdownInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = DropdownInner;
        });

        local DropdownArrow = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0, 0.5);
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -16, 0.5, 0);
            Size = UDim2.new(0, 12, 0, 12);
            Image = 'http://www.roblox.com/asset/?id=6282522798';
            ZIndex = 7;
            Parent = DropdownInner;
        });

        local ItemList = Library:CreateLabel({
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            TextSize = 14;
            Text = '--';
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = true;
            ZIndex = 7;
            Parent = DropdownInner;
        });

        Library:OnHighlight(DropdownOuter, DropdownOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        local MAX_DROPDOWN_ITEMS = 8;

        local ListOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 20 + RelativeOffset + 1 + 20);
            Size = UDim2.new(1, -8, 0, MAX_DROPDOWN_ITEMS * 20 + 2);
            ZIndex = 20;
            Visible = false;
            Parent = Container.Parent;
        });

        local ListInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListOuter;
        });

        Library:AddToRegistry(ListInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListInner;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 0);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        });

        function Dropdown:Display()
            local Values = Dropdown.Values;
            local Str = '';

            if Info.Multi then
                for Idx, Value in next, Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. Value .. ', ';
                    end;
                end;

                Str = Str:sub(1, #Str - 2);
            else
                Str = Dropdown.Value or '';
            end;

            ItemList.Text = (Str == '' and '--' or Str);
        end;

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local T = {};

                for Value, Bool in next, Dropdown.Value do
                    table.insert(T, Value);
                end;

                return T;
            else
                return Dropdown.Value and 1 or 0;
            end;
        end;

        function Dropdown:SetValues()
            local Values = Dropdown.Values;
            local Buttons = {};

            for _, Element in next, Scrolling:GetChildren() do
                if not Element:IsA('UIListLayout') then
                    -- Library:RemoveFromRegistry(Element);
                    Element:Destroy();
                end;
            end;

            local Count = 0;

            for Idx, Value in next, Values do
                local Table = {};

                Count = Count + 1;

                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Middle;
                    Size = UDim2.new(1, -1, 0, 20);
                    ZIndex = 23;
                    Parent = Scrolling;
                });

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                    BorderColor3 = 'OutlineColor';
                });

                local ButtonLabel = Library:CreateLabel({
                    Size = UDim2.new(1, -6, 1, 0);
                    Position = UDim2.new(0, 6, 0, 0);
                    TextSize = 14;
                    Text = Value;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 25;
                    Parent = Button;
                });

                Library:OnHighlight(Button, Button,
                    { BorderColor3 = 'AccentColor', ZIndex = 24 },
                    { BorderColor3 = 'OutlineColor', ZIndex = 23 }
                );

                local Selected;

                if Info.Multi then
                    Selected = Dropdown.Value[Value];
                else
                    Selected = Dropdown.Value == Value;
                end;

                function Table:UpdateButton()
                    if Info.Multi then
                        Selected = Dropdown.Value[Value];
                    else
                        Selected = Dropdown.Value == Value;
                    end;

                    ButtonLabel.TextColor3 = Selected and Library.AccentColor or Library.FontColor;
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or 'FontColor';
                end;

                ButtonLabel.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local Try = not Selected;

                        if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                        else
                            if Info.Multi then
                                Selected = Try;

                                if Selected then
                                    Dropdown.Value[Value] = true;
                                else
                                    Dropdown.Value[Value] = nil;
                                end;
                            else
                                Selected = Try;

                                if Selected then
                                    Dropdown.Value = Value;
                                else
                                    Dropdown.Value = nil;
                                end;

                                for _, OtherButton in next, Buttons do
                                    OtherButton:UpdateButton();
                                end;
                            end;

                            Table:UpdateButton();
                            Dropdown:Display();

                            if Dropdown.Changed then
                                Dropdown.Changed();
                            end;

                            Library:AttemptSave();
                        end;
                    end;
                end);

                Table:UpdateButton();
                Dropdown:Display();

                Buttons[Button] = Table;
            end;

            local Y = math.clamp(Count * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 1;
            ListOuter.Size = UDim2.new(1, -8, 0, Y);
            Scrolling.CanvasSize = UDim2.new(0, 0, 0, Count * 20);

            -- ListOuter.Size = UDim2.new(1, -8, 0, (#Values * 20) + 2);
        end;

        function Dropdown:OpenDropdown()
            ListOuter.Visible = true;
            Library.OpenedFrames[ListOuter] = true;
            DropdownArrow.Rotation = 180;
        end;

        function Dropdown:CloseDropdown()
            ListOuter.Visible = false;
            Library.OpenedFrames[ListOuter] = nil;
            DropdownArrow.Rotation = 0;
        end;

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func;
            Func();
        end;

        function Dropdown:SetValue(Val)
            if Dropdown.Multi then
                local nTable = {};

                for Value, Bool in next, Val do
                    if table.find(Dropdown.Values, Value) then
                        nTable[Value] = true
                    end;
                end;

                Dropdown.Value = nTable;
            else
                if (not Val) then
                    Dropdown.Value = nil;
                elseif table.find(Dropdown.Values, Val) then
                    Dropdown.Value = Val;
                end;
            end;

            Dropdown:SetValues();
            Dropdown:Display();
        end;

        DropdownOuter.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                if ListOuter.Visible then
                    Dropdown:CloseDropdown();
                else
                    Dropdown:OpenDropdown();
                end;
            end;
        end);

        InputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize;

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    Dropdown:CloseDropdown();
                end;
            end;
        end);

        Dropdown:SetValues();
        Dropdown:Display();

        if type(Info.Default) == 'string' then
            Info.Default = table.find(Dropdown.Values, Info.Default)
        end

        if Info.Default then
            if Info.Multi then
                Dropdown.Value[Dropdown.Values[Info.Default]] = true;
            else
                Dropdown.Value = Dropdown.Values[Info.Default];
            end;

            Dropdown:SetValues();
            Dropdown:Display();
        end;

        Groupbox:AddBlank(Info.BlankSize or 5);
        Groupbox:Resize();

        Options[Idx] = Dropdown;

        return Dropdown;
    end;

    BaseGroupbox.__index = Funcs;
    BaseGroupbox.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;

-- < Create other UI elements >
do
    Library.NotificationArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 40);
        Size = UDim2.new(0, 300, 0, 200);
        ZIndex = 100;
        Parent = ScreenGui;
    });

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Library.NotificationArea;
    });



    local WatermarkOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, -25);
        Size = UDim2.new(0, 213, 0, 20);
        ZIndex = 200;
        Visible = false;
        Parent = ScreenGui;
    });

    local WatermarkInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 201;
        Parent = WatermarkOuter;
    });

    Library:AddToRegistry(WatermarkInner, {
        BorderColor3 = 'AccentColor';
    });

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 202;
        Parent = WatermarkInner;
    });

    Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(27, 27, 27)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 52, 52))
        });
        Rotation = -90;
        Parent = InnerFrame;
    });

    local WatermarkLabel = Library:CreateLabel({
        Position = UDim2.new(0, 4, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 203;
        Parent = InnerFrame;
    });

    Library.Watermark = WatermarkOuter;
    Library.WatermarkText = WatermarkLabel;
    Library:MakeDraggable(Library.Watermark);



    local KeybindOuter = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 0.5);
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 10, 0.5, 0);
        Size = UDim2.new(0, 210, 0, 20);
        Visible = false;
        ZIndex = 100;
        Parent = ScreenGui;
    });

    local KeybindInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = KeybindOuter;
    });

    Library:AddToRegistry(KeybindInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local ColorFrame = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, 2);
        ZIndex = 102;
        Parent = KeybindInner;
    });

    Library:AddToRegistry(ColorFrame, {
        BackgroundColor3 = 'AccentColor';
    }, true);

    local KeybindLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 20);
        Text = 'Keybinds';
        ZIndex = 104;
        Parent = KeybindInner;
    });

    local KeybindContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 1, -20);
        Position = UDim2.new(0, 0, 0, 20);
        ZIndex = 1;
        Parent = KeybindInner;
    });

    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = KeybindContainer;
    });

    Library.KeybindFrame = KeybindOuter;
    Library.KeybindContainer = KeybindContainer;
    Library:MakeDraggable(KeybindOuter);
end;

function Library:SetWatermarkVisibility(Bool)
    Library.Watermark.Visible = Bool;
end;

function Library:SetWatermark(Text)
    local Size = Library:GetTextBounds(Text, Enum.Font.Code, 14);
    Library.Watermark.Size = UDim2.new(0, Size + 8 + 2, 0, 20);
    Library:SetWatermarkVisibility(true)

    Library.WatermarkText.Text = Text;
end;

function Library:Notify(Text, Time)
    local MaxSize = Library:GetTextBounds(Text, Enum.Font.Code, 14);

    local NotifyOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, 10);
        Size = UDim2.new(0, 0, 0, 20);
        ClipsDescendants = true;
        ZIndex = 100;
        Parent = Library.NotificationArea;
    });

    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = NotifyOuter;
    });

    Library:AddToRegistry(NotifyInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 102;
        Parent = NotifyInner;
    });

    Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(27, 27, 27)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 52, 52))
        });
        Rotation = -90;
        Parent = InnerFrame;
    });

    local NotifyLabel = Library:CreateLabel({
        Position = UDim2.new(0, 4, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        Text = Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextSize = 14;
        ZIndex = 103;
        Parent = InnerFrame;
    });

    local LeftColor = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, -1, 0, -1);
        Size = UDim2.new(0, 3, 1, 2);
        ZIndex = 104;
        Parent = NotifyOuter;
    });

    Library:AddToRegistry(LeftColor, {
        BackgroundColor3 = 'AccentColor';
    }, true);

    NotifyOuter:TweenSize(UDim2.new(0, MaxSize + 8 + 4, 0, 20), 'Out', 'Quad', 0.4, true);

    task.spawn(function()
        wait(5 or Time);

        NotifyOuter:TweenSize(UDim2.new(0, 0, 0, 20), 'Out', 'Quad', 0.4, true);

        wait(0.4);

        NotifyOuter:Destroy();
    end);
end;

function Library:CreateWindow(WindowTitle)
    local Window = {
        Tabs = {};
    };

    local Outer = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        AnchorPoint = Vector2.new(0.5,0.5);
        Position = UDim2.new(0.5,0,0.5,0);
        Size = UDim2.new(0, 550, 0, 600);
        Visible = true;
        ZIndex = 1;
        Parent = ScreenGui;
    });

    Library:MakeDraggable(Outer, 25);

    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 1;
        Parent = Outer;
    });

    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'AccentColor';
    });

    local WindowLabel = Library:CreateLabel({
        Position = UDim2.new(0, 7, 0, 0);
        Size = UDim2.new(0, 0, 0, 25);
        Text = WindowTitle or '';
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 1;
        Parent = Inner;
    });

    local MainSectionOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8, 0, 25);
        Size = UDim2.new(1, -16, 1, -33);
        ZIndex = 1;
        Parent = Inner;
    });

    Library:AddToRegistry(MainSectionOuter, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    });

    local MainSectionInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Color3.new(0, 0, 0);
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 1;
        Parent = MainSectionOuter;
    });

    Library:AddToRegistry(MainSectionInner, {
        BackgroundColor3 = 'BackgroundColor';
    });

    local TabArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 8, 0, 8);
        Size = UDim2.new(1, -16, 0, 21);
        ZIndex = 1;
        Parent = MainSectionInner;
    });

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 0);
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = TabArea;
    });

    local TabContainer = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8, 0, 30);
        Size = UDim2.new(1, -16, 1, -38);
        ZIndex = 2;
        Parent = MainSectionInner;
    });

    Library:AddToRegistry(TabContainer, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    function Window:SetWindowTitle(Title)
        WindowLabel.Text = Title;
    end;

    function Window:AddTab(Name)
        local Tab = {
            Groupboxes = {};
            Tabboxes = {};
        };

        local TabButtonWidth = Library:GetTextBounds(Name, Enum.Font.Code, 16);

        local TabButton = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            Size = UDim2.new(0, TabButtonWidth + 8 + 4, 1, 0);
            ZIndex = 1;
            Parent = TabArea;
        });

        Library:AddToRegistry(TabButton, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local TabButtonLabel = Library:CreateLabel({
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, -1);
            Text = Name;
            ZIndex = 1;
            Parent = TabButton;
        });

        local Blocker = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 1, 0);
            Size = UDim2.new(1, 0, 0, 1);
            BackgroundTransparency = 1;
            ZIndex = 3;
            Parent = TabButton;
        });

        Library:AddToRegistry(Blocker, {
            BackgroundColor3 = 'MainColor';
        });

        local TabFrame = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            Visible = false;
            ZIndex = 2;
            Parent = TabContainer;
        });

        local LeftSide = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 8, 0, 8);
            Size = UDim2.new(0.5, -12, 0, 507);
            ZIndex = 2;
            Parent = TabFrame;
        });

        local RightSide = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0.5, 4, 0, 8);
            Size = UDim2.new(0.5, -12, 0, 507);
            ZIndex = 2;
            Parent = TabFrame;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = LeftSide;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = RightSide;
        });

        function Tab:ShowTab()
            for _, Tab in next, Window.Tabs do
                Tab:HideTab();
            end;

            Blocker.BackgroundTransparency = 0;
            TabButton.BackgroundColor3 = Library.MainColor;
            TabFrame.Visible = true;
        end;

        function Tab:HideTab()
            Blocker.BackgroundTransparency = 1;
            TabButton.BackgroundColor3 = Library.BackgroundColor;
            TabFrame.Visible = false;
        end;

        function Tab:AddGroupbox(Info)
            local Groupbox = {};

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                Size = UDim2.new(1, 0, 0, 507);
                ZIndex = 2;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 4;
                Parent = BoxOuter;
            });

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            });

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 5;
                Parent = BoxInner;
            });

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor';
            });

            local GroupboxLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 18);
                Position = UDim2.new(0, 4, 0, 2);
                TextSize = 14;
                Text = Info.Name;
                TextXAlignment = Enum.TextXAlignment.Center;
                ZIndex = 5;
                Parent = BoxInner;
            });

            local Container = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 4, 0, 20);
                Size = UDim2.new(1, -4, 1, -20);
                ZIndex = 1;
                Parent = BoxInner;
            });

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = Container;
            });

            function Groupbox:Resize()
                local Size = 0;

                for _, Element in next, Groupbox.Container:GetChildren() do
                    if not Element:IsA('UIListLayout') then
                        Size = Size + Element.Size.Y.Offset;
                    end;
                end;

                BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2);
            end;

            Groupbox.Container = Container;
            setmetatable(Groupbox, BaseGroupbox);

            Groupbox:AddBlank(3);
            Groupbox:Resize();

            Tab.Groupboxes[Info.Name] = Groupbox;

            return Groupbox;
        end;

        function Tab:AddLeftGroupbox(Name)
            return Tab:AddGroupbox({ Side = 1; Name = Name; TextYAlignment = "Center"; TextXAlignment = "Center"; });
        end;

        function Tab:AddRightGroupbox(Name)
            return Tab:AddGroupbox({ Side = 2; Name = Name; TextYAlignment = "Center"; TextXAlignment = "Center"; });
        end;

        function Tab:AddTabbox(Info)
            local Tabbox = {
                Tabs = {};
            };

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                Size = UDim2.new(1, 0, 0, 0);
                ZIndex = 2;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 4;
                Parent = BoxOuter;
            });

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            });

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 10;
                Parent = BoxInner;
            });

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor';
            });

            local TabboxButtons = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 1);
                Size = UDim2.new(1, 0, 0, 18);
                ZIndex = 5;
                Parent = BoxInner;
            });

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Left;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TabboxButtons;
            });

            function Tabbox:AddTab(Name)
                local Tab = {};

                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Color3.new(0, 0, 0);
                    Size = UDim2.new(0.5, 0, 1, 0);
                    ZIndex = 6;
                    Parent = TabboxButtons;
                });

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                });

                local ButtonLabel = Library:CreateLabel({
                    Size = UDim2.new(1, 0, 1, 0);
                    TextSize = 14;
                    Text = Name;
                    TextXAlignment = Enum.TextXAlignment.Center;
                    ZIndex = 7;
                    Parent = Button;
                });

                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 1, 0);
                    Size = UDim2.new(1, 0, 0, 1);
                    Visible = false;
                    ZIndex = 9;
                    Parent = Button;
                });

                Library:AddToRegistry(Block, {
                    BackgroundColor3 = 'BackgroundColor';
                });

                local Container = Library:Create('Frame', {
                    Position = UDim2.new(0, 4, 0, 20);
                    Size = UDim2.new(1, -4, 1, -20);
                    ZIndex = 1;
                    Visible = false;
                    Parent = BoxInner;
                });

                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = Container;
                });

                function Tab:Show()
                    for _, Tab in next, Tabbox.Tabs do
                        Tab:Hide();
                    end;

                    Container.Visible = true;
                    Block.Visible = true;

                    Button.BackgroundColor3 = Library.BackgroundColor;
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';
                end;

                function Tab:Hide()
                    Container.Visible = false;
                    Block.Visible = false;

                    Button.BackgroundColor3 = Library.MainColor;
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
                end;

                function Tab:Resize()
                    local TabCount = 0;

                    for _, Tab in next, Tabbox.Tabs do
                        TabCount = TabCount +  1;
                    end;

                    for _, Button in next, TabboxButtons:GetChildren() do
                        if not Button:IsA('UIListLayout') then
                            Button.Size = UDim2.new(1 / TabCount, 0, 1, 0);
                        end;
                    end;

                    local Size = 0;

                    for _, Element in next, Tab.Container:GetChildren() do
                        if not Element:IsA('UIListLayout') then
                            Size = Size + Element.Size.Y.Offset;
                        end;
                    end;

                    if BoxOuter.Size.Y.Offset < 20 + Size + 2 then
                        BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2);
                    end;
                end;

                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                        Tab:Show();
                    end;
                end);

                Tab.Container = Container;
                Tabbox.Tabs[Name] = Tab;

                setmetatable(Tab, BaseGroupbox);

                Tab:AddBlank(3);
                Tab:Resize();

                if #TabboxButtons:GetChildren() == 2 then
                    Tab:Show();
                end;

                return Tab;
            end;

            Tab.Tabboxes[Info.Name or ''] = Tabbox;

            return Tabbox;
        end;

        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 1; });
        end;

        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 2; });
        end;

        TabButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Tab:ShowTab();
            end;
        end);

        -- This was the first tab added, so we show it by default.
        if #TabContainer:GetChildren() == 1 then
            Tab:ShowTab();
        end;

        Window.Tabs[Name] = Tab;
        return Tab;
    end;

    local ModalElement = Library:Create('TextButton', {
        BackgroundTransparency = 1;
        Size = UDim2.new(0, 0, 0, 0);
        Visible = true;
        Text = '';
        Modal = false;
        Parent = ScreenGui;
    });

    InputService.InputBegan:Connect(function(Input, Processed)
        if Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
            Outer.Visible = not Outer.Visible;
            ModalElement.Modal = Outer.Visible;

            local oIcon = Mouse.Icon;
            local State = InputService.MouseIconEnabled;

            local Cursor = Drawing.new('Triangle');
            Cursor.Thickness = 1;
            Cursor.Filled = true;

            while Outer.Visible do
                local mPos = workspace.CurrentCamera:WorldToViewportPoint(Mouse.Hit.p);

                Cursor.Color = Library.AccentColor;
                Cursor.PointA = Vector2.new(mPos.X, mPos.Y);
                Cursor.PointB = Vector2.new(mPos.X, mPos.Y) + Vector2.new(6, 14);
                Cursor.PointC = Vector2.new(mPos.X, mPos.Y) + Vector2.new(-6, 14);

                Cursor.Visible = not InputService.MouseIconEnabled;

                RenderStepped:Wait();
            end;

            Cursor:Remove();
        end;
    end);

    Window.Holder = Outer;

    return Window;
end;

_G.SettingsFile = {
    Auto_Don_Swan = false;
    Auto_Don_Swan_Hop = false;
    Auto_Stone_Hop = false;
    Auto_Stone = false;
    Auto_Cursed_Captain_Hop = false;
    Auto_Cursed_Captain = false;
    Damage_Aura = false;
    Kill_Aura = false;
	AncientOne_Quest = false;
    NotifyMythicIsland = false;
    Webhook_URL = "";
    Find_Mythic_Island_Hop = false;
    SelectWeaponType = "Melee";
    BypassTeleport = false;
    Auto_Elite_Hunter = false;
    Auto_Elite_Hunter_Hop = false;
    StopWhenGotGodChalice = false;
    NotifyGodChalice = false;
    PingEveryone = false;
    PingHere = false;
    RoleId = "";
    PingRoleId = false;
    Auto_Cake_Prince = false;
    Auto_Dough_King = false;
    AutoResetCharacter = false;
}

local foldername = "GlitchHub"
local filename = game.Players.LocalPlayer.Name.." Config.json"
 
function saveSettings()
    print("")
	--[[local HttpService = game:GetService("HttpService")
	local json = HttpService:JSONEncode(_G.SettingsFile)
	if (writefile) then
		if isfolder(foldername) then
			if isfile(foldername.."\\"..filename) then
				writefile(foldername.."\\"..filename, json)
			else
				writefile(foldername.."\\"..filename, json)
			end
		else
			makefolder(foldername)
			writefile(foldername.."\\"..filename, json)
		end
	end]]
end

function loadSettings()
	local HttpService = game:GetService("HttpService")
	if isfile(foldername.."\\"..filename) then
		_G.SettingsFile = HttpService:JSONDecode(readfile(foldername.."\\"..filename))
	end
end

loadSettings()

MansionPos = CFrame.new(-12506.6181640625, 337.2078857421875, -7470.96923828125)

function topos2(Pos)
    if game.Players.LocalPlayer.Character.Humanoid.Sit == true then game.Players.LocalPlayer.Character.Humanoid.Sit = false end
    pcall(function() tween = game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart,TweenInfo.new(Distance/310, Enum.EasingStyle.Linear),{CFrame = Pos}) end)
    tween:Play()
end

function topos(Pos)
    Distance = (Pos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    if _G.Sit then if game.Players.LocalPlayer.Character.Humanoid.Sit == true then game.Players.LocalPlayer.Character.Humanoid.Sit = false end end
    pcall(function() tween = game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart,TweenInfo.new(Distance/310, Enum.EasingStyle.Linear),{CFrame = Pos}) end)
    tween:Play()
    if Distance <= 100 then
        tween:Cancel()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Pos
    end
    if _G.StopTween == true then
        topos2(game.Players.localPlayer.Character.HumanoidRootPart.Position)
        tween:Cancel()
        _G.Clip = false
        game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(18)
    end

    if _G.BypassTeleport and not _G.AutoCompleteTrial and not _G.Teleport_to_Mythic_Island and not _G.Teleport_to_Gear and not game.Players.LocalPlayer.Backpack:FindFirstChild("God's Chalice") and not game.Players.LocalPlayer.Character:FindFirstChild("God's Chalice") and not game.Players.LocalPlayer.Backpack:FindFirstChild("Sweet Chalice") and not game.Players.LocalPlayer.Character:FindFirstChild("Sweet Chalice") then
        if Distance > 3000 then
            if _G.Auto_Cursed_Captain and not game.Players.LocalPlayer.Backpack:FindFirstChild("Hellfire Torch") and not game.Players.LocalPlayer.Character:FindFirstChild("Hellfire Torch") then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(921.5810546875, 125.0942611694336, 32843.96484375))
            else
                pcall(function()
                    tween:Cancel()
                    fkwarp = false
                    if game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").Health > 0 then
                        if fkwarp == false then
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Pos
                        end
                        fkwarp = true
                    end
                    wait(.08)
                    game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid"):ChangeState(15)
                    repeat task.wait() until game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").Health > 0
                    wait(0.2)
                    return
                end)
            end
        end
    end
end

function totarget(Pos)
    Distance = (Pos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    if game.Players.LocalPlayer.Character.Humanoid.Sit == true then game.Players.LocalPlayer.Character.Humanoid.Sit = false end
    pcall(function() tween = game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart,TweenInfo.new(Distance/310, Enum.EasingStyle.Linear),{CFrame = Pos}) end)
    tween:Play()
    if Distance <= 200 then
        tween:Cancel()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Pos
    end
    if _G.StopTween == true then
        topos2(game.Players.localPlayer.Character.HumanoidRootPart.Position)
        tween:Cancel()
        wait(.2)
        _G.Clip = false
    end

    if _G.BypassTeleport and not _G.Teleport_to_Mythic_Island and not _G.Teleport_to_Gear and not game.Players.LocalPlayer.Backpack:FindFirstChild("God's Chalice") and not game.Players.LocalPlayer.Character:FindFirstChild("God's Chalice") then
		if Distance > 3000 then
			pcall(function()
				tween:Cancel()
				fkwarp = false
                if game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").Health > 0 then
                    if fkwarp == false then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Pos
                    end
                    fkwarp = true
                end
                wait(.08)
                game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid"):ChangeState(15)
                repeat task.wait() until game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").Health > 0
				wait(0.2)

				return
			end)
		end
    end
end

function toposMob(target)
    topos(target * CFrame.new(0,50,0))
end

function StopTween(target)
    if not target then
        _G.StopTween = true
        wait()
        topos(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame)
        topos(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame)
        wait()
        if game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip"):Destroy()
        end
        wait(1)
        _G.StopTween = false
        _G.NoClip = false
    end
end



if game.PlaceId == 2753915549 then
	World1 = true
elseif game.PlaceId == 4442272183 then
	World2 = true
elseif game.PlaceId == 7449423635 then
	World3 = true
end

local Window = Library:CreateWindow('SixMa Hub - Standard Edition')

local Tabs = {
    General = Window:AddTab('General'), 
    Notify = Window:AddTab('Notify'), 
    Travel = Window:AddTab('Travel'), 
    Visual = Window:AddTab('Visual'),
}


local SettingsNotify = Tabs.Notify:AddLeftGroupbox('\\\\ Settings //')
local OptionNotify = Tabs.Notify:AddLeftGroupbox('\\\\ Option //')
local MethodSettings = Tabs.Notify:AddRightGroupbox('\\\\ Method //')

local Teleport_to_Island = Tabs.Travel:AddLeftGroupbox('\\\\ Teleport to Island //')
local Teleport_to_World = Tabs.Travel:AddRightGroupbox('\\\\ Teleport to World //')


local FightingStyle = Tabs.Visual:AddLeftGroupbox('\\\\ Fighting Style //')
local Raid = Tabs.Visual:AddLeftGroupbox('\\\\ Raid //')
local Server = Tabs.Visual:AddRightGroupbox('\\\\ Server //')
local Misc = Tabs.Visual:AddRightGroupbox('\\\\ Misc //')
local Team = Tabs.Visual:AddRightGroupbox('\\\\ Team //')

Team:AddButton('Pirates', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam","Pirates") 
end)

Team:AddButton('Marines', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam","Marines") 
end)

FightingStyle:AddButton('Buy Black Leg', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyBlackLeg")
end)

FightingStyle:AddButton('Buy Electric', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyElectro")
end)

FightingStyle:AddButton('Buy Fishman Karate', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyFishmanKarate")
end)

FightingStyle:AddButton('Buy Dragon Claw', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BlackbeardReward","DragonClaw","1")
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BlackbeardReward","DragonClaw","2")
end)

FightingStyle:AddButton('Buy Superhuman', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuySuperhuman")
end)

FightingStyle:AddButton('Buy Death Step', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyDeathStep")
end)

FightingStyle:AddButton('Buy Sharkman Karate', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuySharkmanKarate",true)
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuySharkmanKarate")
end)

FightingStyle:AddButton('Buy Electric Claw', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyElectricClaw")
end)

FightingStyle:AddButton('Buy Dragon Talon', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyDragonTalon")
end)

FightingStyle:AddButton('Buy Godhuman', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyGodhuman")
end)

Teleport_to_World:AddButton('Travel Main', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelMain")
end)

Teleport_to_World:AddButton('Travel Dressrosa', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelDressrosa")
end)

Teleport_to_World:AddButton('Travel Zou', function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelZou")
end)

Server:AddInput('JobId', {
    Default = "",
    Numeric = false, -- true / false, only allows numbers
    Finished = false, -- true / false, only call s callback when you press enter
    Text = 'JobId',
    Placeholder = 'Enter JobId',
})

Options.JobId:OnChanged(function()
    _G.JobId = Options.JobId.Value
end)

Server:AddButton('Join JobId', function()
    game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId,_G.JobId,game.Players.LocalPlayer)
end)

Server:AddButton('Copy JobId', function()
    setclipboard(tostring(game.JobId))
end)

Server:AddButton('Hop Server', function()
    Teleport()
end)

Server:AddButton('Rejoin Server', function()
    game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId,game.JobId,game.Players.LocalPlayer)
end)

Server:AddToggle('Join_JobId', {
    Text = 'Join JobId',
    Default = _G.SettingsFile.Join_JobId,
    Value = _G.SettingsFile.Join_JobId,
})

Toggles.Join_JobId:OnChanged(function()
    _G.Join_JobId = Toggles.Join_JobId.Value
end)

Misc:AddToggle('W', {
    Text = 'Auto Press W',
    Default = _G.SettingsFile.AutoPressW,
    Value = _G.SettingsFile.AutoPressW,
})

Toggles.W:OnChanged(function()
    _G.AutoPressW = Toggles.W.Value
end)

Misc:AddButton('Remove Fog', function()
    game:GetService("Lighting").LightingLayers.MirageFog:Destroy()
    game:GetService("Lighting").BaseAtmosphere:Destroy()
end)

Misc:AddButton('Skypiea Part', function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Map.SkyTrial.Model:FindFirstChild("FinishPart").CFrame
end)

Misc:AddToggle('Auto_Cursed_Captain', {
    Text = 'Auto Cursed Captain',
    Default = _G.SettingsFile.Auto_Cursed_Captain,
    Value = _G.Auto_Cursed_Captain,
})

Toggles.Auto_Cursed_Captain:OnChanged(function()
    _G.Auto_Cursed_Captain = Toggles.Auto_Cursed_Captain.Value
    _G.SettingsFile.Auto_Cursed_Captain = Toggles.Auto_Cursed_Captain.Value
    saveSettings()
    StopTween(_G.Auto_Cursed_Captain)
end)

spawn(function()
    while _G.Auto_Cursed_Captain do
        wait()
        if World2 then
            pcall(function()
                if game:GetService("Workspace").Enemies:FindFirstChild("Cursed Captain") then
                    for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                        if v.Name == "Cursed Captain" then
                            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                repeat task.wait()
                                    FastAttackSpeed = true
                                    AutoHaki()
                                    EquipWeapon(_G.Select_Weapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.Humanoid.JumpPower = 0
                                    v.HumanoidRootPart.Locked = true
                                    v.Humanoid:ChangeState(14)
                                    v.Humanoid:ChangeState(11)
                                    v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                                    if v.Humanoid:FindFirstChild("Animator") then
                                        v.Humanoid.Animator:Destroy()
                                    end                        
                                    topos(v.HumanoidRootPart.CFrame * CFrame.new(0,50,0))
                                    sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                                until not _G.Auto_Cursed_Captain or not v.Parent or v.Humanoid.Health <= 0
                                FastAttackSpeed = false
                            end
                        end
                    end
                else
                    if game:GetService("ReplicatedStorage"):FindFirstChild("Cursed Captain") then
                        topos(game:GetService("ReplicatedStorage"):FindFirstChild("Cursed Captain").HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                    else
                        _G.FastAttackCC = false
                        if _G.Auto_Cursed_Captain_Hop then
                            if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Hellfire Torch") or game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Hellfire Torch") then
                                wait()
                            else
                                wait(5)
                                Teleport()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

spawn(function()
	while wait() do
		pcall(function()
			if _G.Join_JobId then
                wait(0.8)
                game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId,_G.JobId,game.Players.LocalPlayer)
			end
		end)
	end
end)

spawn(function()
	while wait() do
		pcall(function()
			if _G.AutoPressW then
				local VirtualInputManager = game:GetService('VirtualInputManager')
				VirtualInputManager:SendKeyEvent(true, "W", false, game)
				wait()
				VirtualInputManager:SendKeyEvent(false, "W", false, game)
			end
		end)
	end
end)

local WebhookURL SettingsNotify:AddInput('WebhookNotify', {
    Default = _G.SettingsFile.Webhook_URL,
    Numeric = false, -- true / false, only allows numbers
    Finished = false, -- true / false, only call s callback when you press enter
    Text = 'Webhook Link',
    Placeholder = 'Enter Webhook (Discord)',
})


spawn(function()
	while wait() do
		pcall(function()
            local urlmi = _G.Webhook_URL
            local datami = {
            ["content"] = method,
            }
            local newdatami = game:GetService("HttpService"):JSONEncode(datami)
            
            local headersmi = {
            ["content-type"] = "application/json"
            }
            request = http_request or request or HttpPost or syn.request
            local Test = {Url = urlmi, Body = newdatami, Method = "POST", Headers = headersmi}
            function test()
                request(Test)
            end
		end)	
	end
end)

SettingsNotify:AddButton('Test Webhook', function()
    test()
end)

Options.WebhookNotify:OnChanged(function()
    _G.Webhook_URL = Options.WebhookNotify.Value
    _G.SettingsFile.Webhook_URL = Options.WebhookNotify.Value
    saveSettings()
end)

OptionNotify:AddToggle('NotifyMythicIsland', {
    Text = 'Mythic Island',
    Default = _G.SettingsFile.NotifyMythicIsland,
    Value = _G.SettingsFile.NotifyMythicIsland,
})

Toggles.NotifyMythicIsland:OnChanged(function()
    _G.NotifyMythicIsland = Toggles.NotifyMythicIsland.Value
    _G.SettingsFile.NotifyMythicIsland = Toggles.NotifyMythicIsland.Value
    saveSettings()
end)

OptionNotify:AddToggle('NotifyGodChalice', {
    Text = "God's Chalice",
    Default = _G.SettingsFile.NotifyGodChalice,
    Value = _G.SettingsFile.NotifyGodChalice,
})

Toggles.NotifyGodChalice:OnChanged(function()
    _G.NotifyGodChalice = Toggles.NotifyGodChalice.Value
    _G.SettingsFile.NotifyGodChalice = Toggles.NotifyGodChalice.Value
    saveSettings()
end)

local header = {["content-type"] = "application/json"}
request = http_request or request or HttpPost or syn.request

local datami = {
    ["content"] = method,
    ["embeds"] = {
        {
            ["title"] = "SixMaHub Notify Mythic Island",
            ["description"] = "**Username**\n```"..game.Players.localPlayer.Name.."```\n**Place Id**\n```"..game.placeId.."```\n**Job Id**\n```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId,'"..game.JobId.."',game.Players.LocalPlayer)```",
            ["type"] = "rich",
            ["color"] = tonumber(0xf1412f),
        }
    }
}
local newdatami = game:GetService("HttpService"):JSONEncode(datami)
local datagc = {
    ["content"] = method,
    ["embeds"] = {
        {
            ["title"] = "SixMaHub Notify God's Chalice",
            ["description"] = "**Username**\n```"..game.Players.localPlayer.Name.."```\n**Place Id**\n```"..game.placeId.."```\n**Job Id**\n```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId,'"..game.JobId.."',game.Players.LocalPlayer)```",
            ["type"] = "rich",
            ["color"] = tonumber(0xf1412f),
        }
    }
    }
local newdatagc = game:GetService("HttpService"):JSONEncode(datagc)

spawn(function()
	while wait() do
		pcall(function()
			if _G.NotifyMythicIsland then
				if game:GetService("Workspace").Map:FindFirstChild("MysticIsland") then
                    local requestwebhook = {Url = _G.Webhook_URL, Body = newdatami, Method = "POST", Headers = header}
					request(requestwebhook)
					wait(900)
				end
			end
            if _G.NotifyGodChalice then
                if game.Players.LocalPlayer.Backpack:FindFirstChild("God's Chalice") or game.Players.LocalPlayer.Character:FindFirstChild("God's Chalice") then
                    local requestwebhook = {Url = _G.Webhook_URL, Body = newdatagc, Method = "POST", Headers = headersgc}
                    request(requestwebhook)
                    wait(900)
                end 
            end
		end)	
	end
end)

MethodSettings:AddInput('RoleId', {
    Default = _G.SettingsFile.RoleId,
    Numeric = false, -- true / false, only allows numbers
    Finished = false, -- true / false, only call s callback when you press enter
    Text = 'RoleId',
    Placeholder = 'Enter RoleId',
})

Options.RoleId:OnChanged(function()
    _G.RoleId = Options.RoleId.Value
    _G.SettingsFile.RoleId = Options.RoleId.Value
    saveSettings()
end)

spawn(function()
    while wait() do
        pcall(function()
            if _G.PingHere and not _G.PingEveryone and not _G.PingRoleId then
                method = "@here"
            elseif not _G.PingHere and _G.PingEveryone and not _G.PingRoleId then
                method = "@everyone"
            elseif _G.PingRoleId and not _G.PingHere and not _G.PingEveryone then
                method = "<@&".._G.RoleId..">"
            elseif _G.PingEveryone and _G.PingHere and not _G.PingRoleId then
                method = "@here @everyone"
            elseif not _G.PingEveryone and _G.PingHere and _G.PingRoleId then
                method = "@here <@&".._G.RoleId..">"
            elseif _G.PingEveryone and not _G.PingHere and _G.PingRoleId then
                method = "@everyone <@&".._G.RoleId..">"
            elseif _G.PingEveryone and _G.PingHere and _G.PingRoleId then
                method = "@here @everyone <@&".._G.RoleId..">"
            else
                method = ""
            end
        end)
    end
end)

MethodSettings:AddToggle('PingRoleId', {
    Text = '@RoleId',
    Default = _G.SettingsFile.PingRoleId,
    Value = _G.SettingsFile.PingRoleId,
})

Toggles.PingRoleId:OnChanged(function()
    _G.PingRoleId = Toggles.PingRoleId.Value
    _G.SettingsFile.PingRoleId = Toggles.PingRoleId.Value
    saveSettings()
end)

MethodSettings:AddToggle('PingHere', {
    Text = '@Here',
    Default = _G.SettingsFile.PingHere,
    Value = _G.SettingsFile.PingHere,
})

Toggles.PingHere:OnChanged(function()
    _G.PingHere = Toggles.PingHere.Value
    _G.SettingsFile.PingHere = Toggles.PingHere.Value
    saveSettings()
end)

MethodSettings:AddToggle('PingEveryone', {
    Text = '@Everyone',
    Default = _G.SettingsFile.PingEveryone,
    Value = _G.SettingsFile.PingEveryone,
})

Toggles.PingEveryone:OnChanged(function()
    _G.PingEveryone = Toggles.PingEveryone.Value
    _G.SettingsFile.PingEveryone = Toggles.PingEveryone.Value
    saveSettings()
end)



if World1 then
	Island = {
		"WindMill",
		"Marine",
		"Middle Town",
		"Jungle",
		"Pirate Village",
		"Desert",
		"Snow Island",
		"MarineFord",
		"Colosseum",
		"Sky Island 1",
		"Sky Island 2",
		"Sky Island 3",
		"Prison",
		"Magma Village",
		"Under Water Island",
		"Fountain City",
		"Shank Room",
		"Mob Island"
		}
elseif World2 then  
	Island = {
		"The Cafe",
		"Frist Spot",
		"Dark Area",
		"Flamingo Mansion",
		"Flamingo Room",
		"Green Zone",
		"Factory",
		"Colossuim",
		"Zombie Island",
		"Two Snow Mountain",
		"Punk Hazard",
		"Cursed Ship",
		"Ice Castle",
		"Forgotten Island",
		"Ussop Island",
		"Mini Sky Island"
		}
else
	Island = {
		"Mansion",
		"Port Town",
		"Great Tree",
		"Castle On The Sea",
		"MiniSky", 
		"Hydra Island",
		"Floating Turtle",
		"Haunted Castle",
		"Ice Cream Island",
		"Peanut Island",
		"Cake Island",
        "Tiki Outpost",
        "Temple of Time",
        "Ancient Clock Room",
        "Trial Gate"
		}	
end

Teleport_to_Island:AddDropdown('IslandList', {
    Values = Island,
    Default = 1,
    Multi = false,
    Text = 'Select Island',
})

Options.IslandList:OnChanged(function()
    _G.Island = Options.IslandList.Value
end)

Teleport_to_Island:AddToggle('TeleporttoIsland', {
    Text = 'Teleport to Island',
    Default = false,
    Value = _G.TeleporttoIsland,
})

local TempleofTime = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875)

Toggles.TeleporttoIsland:OnChanged(function()
    _G.TeleporttoIsland = Toggles.TeleporttoIsland.Value
    StopTween(_G.TeleporttoIsland)
end)

spawn(function()
    pcall(function()
        while wait() do
            if _G.TeleporttoIsland == true then
                repeat wait()
                    if _G.Island == "WindMill" then
                        topos(CFrame.new(979.79895019531, 16.516613006592, 1429.0466308594))
                    elseif _G.Island == "Marine" then
                        topos(CFrame.new(-2566.4296875, 6.8556680679321, 2045.2561035156))
                    elseif _G.Island == "Middle Town" then
                        topos(CFrame.new(-690.33081054688, 15.09425163269, 1582.2380371094))
                    elseif _G.Island == "Jungle" then
                        topos(CFrame.new(-1612.7957763672, 36.852081298828, 149.12843322754))
                    elseif _G.Island == "Pirate Village" then
                        topos(CFrame.new(-1181.3093261719, 4.7514905929565, 3803.5456542969))
                    elseif _G.Island == "Desert" then
                        topos(CFrame.new(944.15789794922, 20.919729232788, 4373.3002929688))
                    elseif _G.Island == "Snow Island" then
                        topos(CFrame.new(1347.8067626953, 104.66806030273, -1319.7370605469))
                    elseif _G.Island == "MarineFord" then
                        topos(CFrame.new(-4914.8212890625, 50.963626861572, 4281.0278320313))
                    elseif _G.Island == "Colosseum" then
                        topos( CFrame.new(-1427.6203613281, 7.2881078720093, -2792.7722167969))
                    elseif _G.Island == "Sky Island 1" then
                        topos(CFrame.new(-4869.1025390625, 733.46051025391, -2667.0180664063))
                    elseif _G.Island == "Sky Island 2" then  
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82275, 872.54248, -1667.55688))
                    elseif _G.Island == "Sky Island 3" then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
                    elseif _G.Island == "Prison" then
                        topos( CFrame.new(4875.330078125, 5.6519818305969, 734.85021972656))
                    elseif _G.Island == "Magma Village" then
                        topos(CFrame.new(-5247.7163085938, 12.883934020996, 8504.96875))
                    elseif _G.Island == "Under Water Island" then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
                    elseif _G.Island == "Fountain City" then
                        topos(CFrame.new(5127.1284179688, 59.501365661621, 4105.4458007813))
                    elseif _G.Island == "Shank Room" then
                        topos(CFrame.new(-1442.16553, 29.8788261, -28.3547478))
                    elseif _G.Island == "Mob Island" then
                        topos(CFrame.new(-2850.20068, 7.39224768, 5354.99268))
                    elseif _G.Island == "The Cafe" then
                        topos(CFrame.new(-380.47927856445, 77.220390319824, 255.82550048828))
                    elseif _G.Island == "Frist Spot" then
                        topos(CFrame.new(-11.311455726624, 29.276733398438, 2771.5224609375))
                    elseif _G.Island == "Dark Area" then
                        topos(CFrame.new(3780.0302734375, 22.652164459229, -3498.5859375))
                    elseif _G.Island == "Flamingo Mansion" then
                        topos(CFrame.new(-483.73370361328, 332.0383605957, 595.32708740234))
                    elseif _G.Island == "Flamingo Room" then
                        topos(CFrame.new(2284.4140625, 15.152037620544, 875.72534179688))
                    elseif _G.Island == "Green Zone" then
                        topos( CFrame.new(-2448.5300292969, 73.016105651855, -3210.6306152344))
                    elseif _G.Island == "Factory" then
                        topos(CFrame.new(424.12698364258, 211.16171264648, -427.54049682617))
                    elseif _G.Island == "Colossuim" then
                        topos( CFrame.new(-1503.6224365234, 219.7956237793, 1369.3101806641))
                    elseif _G.Island == "Zombie Island" then
                        topos(CFrame.new(-5622.033203125, 492.19604492188, -781.78552246094))
                    elseif _G.Island == "Two Snow Mountain" then
                        topos(CFrame.new(753.14288330078, 408.23559570313, -5274.6147460938))
                    elseif _G.Island == "Punk Hazard" then
                        topos(CFrame.new(-6127.654296875, 15.951762199402, -5040.2861328125))
                    elseif _G.Island == "Cursed Ship" then
                        topos(CFrame.new(923.40197753906, 125.05712890625, 32885.875))
                    elseif _G.Island == "Ice Castle" then
                        topos(CFrame.new(6148.4116210938, 294.38687133789, -6741.1166992188))
                    elseif _G.Island == "Forgotten Island" then
                        topos(CFrame.new(-3032.7641601563, 317.89672851563, -10075.373046875))
                    elseif _G.Island == "Ussop Island" then
                        topos(CFrame.new(4816.8618164063, 8.4599885940552, 2863.8195800781))
                    elseif _G.Island == "Mini Sky Island" then
                        topos(CFrame.new(-288.74060058594, 49326.31640625, -35248.59375))
                    elseif _G.Island == "Great Tree" then
                        topos(CFrame.new(2681.2736816406, 1682.8092041016, -7190.9853515625))
                    elseif _G.Island == "Castle On The Sea" then
                        topos(CFrame.new(-5074.45556640625, 314.5155334472656, -2991.054443359375))
                    elseif _G.Island == "MiniSky" then
                        topos(CFrame.new(-260.65557861328, 49325.8046875, -35253.5703125))
                    elseif _G.Island == "Port Town" then
                        topos(CFrame.new(-290.7376708984375, 6.729952812194824, 5343.5537109375))
                    elseif _G.Island == "Hydra Island" then
                        topos(CFrame.new(5228.8842773438, 604.23400878906, 345.0400390625))
                    elseif _G.Island == "Floating Turtle" then
                        topos(CFrame.new(-13274.528320313, 531.82073974609, -7579.22265625))
                    elseif _G.Island == "Mansion" then 
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375))
                    elseif _G.Island == "Haunted Castle" then
                        topos(CFrame.new(-9515.3720703125, 164.00624084473, 5786.0610351562))
                    elseif _G.Island == "Ice Cream Island" then
                        topos(CFrame.new(-902.56817626953, 79.93204498291, -10988.84765625))
                    elseif _G.Island == "Peanut Island" then
                        topos(CFrame.new(-2062.7475585938, 50.473892211914, -10232.568359375))
                    elseif _G.Island == "Cake Island" then
                        topos(CFrame.new(-1884.7747802734375, 19.327526092529297, -11666.8974609375))
                    elseif _G.Island == "Tiki Outpost" then
                        topos(CFrame.new(-16228.080078125, 9.086336135864258, 480.37652587890625))
                    elseif _G.Island == "Temple of Time" then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875)
                    elseif _G.Island == "Ancient Clock Room" then
                        if (TempleofTime.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 1500 then
                            topos(CFrame.new(29493.55078125, 15068.72265625, -85.73710632324219))
                        else
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875) 
                        end
                    elseif _G.Island == "Trial Gate" then
                        if (TempleofTime.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 1500 then
                            if game:GetService("Players")["LocalPlayer"].Data.Race.Value == "Human" then
                                topos(CFrame.new(29231.283203125, 14890.9755859375, -205.39077758789062))
                            elseif game:GetService("Players")["LocalPlayer"].Data.Race.Value == "Fishman" then           
                                topos(CFrame.new(28228.47265625, 14890.978515625, -212.1103515625))
                            elseif game:GetService("Players")["LocalPlayer"].Data.Race.Value == "Cyborg" then
                                topos(CFrame.new(28496.66015625, 14895.9755859375, -422.5971374511719))
                            elseif game:GetService("Players")["LocalPlayer"].Data.Race.Value == "Ghoul" then
                                topos(CFrame.new(28673.232421875, 14890.359375, 454.6542663574219))
                            elseif game:GetService("Players")["LocalPlayer"].Data.Race.Value == "Skypiea" then
                                topos(CFrame.new(28962.220703125, 14919.6240234375, 234.61563110351562))
                            elseif game:GetService("Players")["LocalPlayer"].Data.Race.Value == "Mink" then
                                topos(CFrame.new(29014.6171875, 14890.9755859375, -378.9480285644531))
                            end
                        else
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875) 
                        end
                    end
                until not _G.TeleporttoIsland
            end
        end
    end)
end)

Time = 1 -- seconds
repeat wait() until game:IsLoaded()
wait(Time)
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
function TPReturner()
   local Site;
   if foundAnything == "" then
       Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
   else
       Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
   end
   local ID = ""
   if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
       foundAnything = Site.nextPageCursor
   end
   local num = 0;
   for i,v in pairs(Site.data) do
       local Possible = true
       ID = tostring(v.id)
       if tonumber(v.maxPlayers) > tonumber(v.playing) then
           for _,Existing in pairs(AllIDs) do
               if num ~= 0 then
                   if ID == tostring(Existing) then
                       Possible = false
                   end
               else
                   if tonumber(actualHour) ~= tonumber(Existing) then
                       local delFile = pcall(function()
                           delfile("NotSameServers.json")
                           AllIDs = {}
                           table.insert(AllIDs, actualHour)
                       end)
                   end
               end
               num = num + 1
           end
           if Possible == true then
               table.insert(AllIDs, ID)
               wait()
               pcall(function()
                   writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                   wait()
                   game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
               end)
               wait(4)
           end
       end
   end
end
 
function Teleport()
   while wait() do
       pcall(function()
           TPReturner()
           if foundAnything ~= "" then
               TPReturner()
           end
       end)
   end
end

Raid:AddToggle('Auto_Raid', {
    Text = 'Auto Raid',
    Default = false,
    Value = _G.Auto_Raid,
})

Toggles.Auto_Raid:OnChanged(function()
    _G.Auto_Raid = Toggles.Auto_Raid.Value
    StopTween(_G.Auto_Raid)
end)

spawn(function()
    pcall(function()
        while wait() do
            if _G.Auto_Raid then
                if game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == true then
                    if game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 5") then
                        topos(game:GetService("Workspace")["_WorldOrigin"].Locations["Island 5"].CFrame*CFrame.new(0,80,0))
                    elseif game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 4") then
                        topos(game:GetService("Workspace")["_WorldOrigin"].Locations["Island 4"].CFrame*CFrame.new(0,80,0))
                    elseif game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 3") then
                        topos(game:GetService("Workspace")["_WorldOrigin"].Locations["Island 3"].CFrame*CFrame.new(0,80,0))
                    elseif game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 2") then
                        topos(game:GetService("Workspace")["_WorldOrigin"].Locations["Island 2"].CFrame*CFrame.new(0,80,0))
                    elseif game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 1") then
                        topos(game:GetService("Workspace")["_WorldOrigin"].Locations["Island 1"].CFrame*CFrame.new(0,80,0))
                    end
                else
                    if not game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 1") and game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Special Microchip") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Special Microchip") then
                        if World2 then
                            fireclickdetector(game:GetService("Workspace").Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector)
                        elseif World3 then
                            fireclickdetector(game:GetService("Workspace").Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector)
                        end
                    end
                    if not game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Special Microchip") and not game:GetService("Players").LocalPlayer.Character:FindFirstChild("Special Microchip") then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("RaidsNpc","Select","Flame")
                    end
                end
            end
        end
    end)
end)

spawn(function()
    pcall(function()
        while wait() do
            if _G.Auto_Raid then
                for i,v in pairs(game.Workspace.Enemies:GetDescendants()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        pcall(function()
                            repeat wait(.1)
                                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                                v.Humanoid.Health = 0
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                            until not _G.Auto_Raid or not v.Parent or v.Humanoid.Health <= 0
                        end)
                    end
                end
            end
        end
    end)
end)

Raid:AddButton("Buy Selected Chip", function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("RaidsNpc","Select","Flame")
end)

local Main = Tabs.General:AddLeftGroupbox('\\\\ Main //')

local AdvancedRace = Tabs.General:AddLeftGroupbox('\\\\ Advanced Race //')

local Setting = Tabs.General:AddRightGroupbox('\\\\ Settings //')

local KitsuneIsland = Tabs.General:AddRightGroupbox('\\\\ Kitsune Island //')

local MythicIsland = Tabs.General:AddLeftGroupbox('\\\\ Mythic Island //')

local EliteHunter = Tabs.General:AddLeftGroupbox('\\\\ Elite Hunter //')

local CakePrince = Tabs.General:AddLeftGroupbox('\\\\ Cake Prince //')

local LegendarySword = Tabs.General:AddRightGroupbox('\\\\ Legendary Sword //')

local Kitsune_Island_Status = KitsuneIsland:AddLabel('Kitsune Island : N/A')
spawn(function()
	while wait() do
		pcall(function()
			if game:GetService("Workspace").Map:FindFirstChild("KitsuneIsland") then
				Kitsune_Island_Status:Set("Kitsune Island : Spawned")	
			else
				Kitsune_Island_Status:Set("Kitsune Island : Not Spawned")
			end
		end)
	end
end)

KitsuneIsland:AddToggle('KitsuneIsland', {
    Text = 'Teleport to Kitsune Island',
    Default = false,
    Value = _G.Teleport_to_Kitsune_Island,
})

Toggles.KitsuneIsland:OnChanged(function()
    _G.Teleport_to_Kitsune_Island = Toggles.KitsuneIsland.Value
    StopTween(_G.Teleport_to_Kitsune_Island)
end)

KitsuneIsland:AddToggle('Collect_Azure_Ember', {
    Text = 'Collect Azure Ember',
    Default = false,
    Value = _G.Collect_Azure_Ember,
})

Toggles.Collect_Azure_Ember:OnChanged(function()
    _G.Collect_Azure_Ember = Toggles.Collect_Azure_Ember.Value
    StopTween(_G.Collect_Azure_Ember)
end)

KitsuneIsland:AddToggle('Find_Kitsune_Island', {
    Text = 'Find Kitsune Island',
    Default = false,
    Value = _G.Find_Kitsune_Island,
})

Toggles.Find_Kitsune_Island:OnChanged(function()
    _G.Find_Kitsune_Island = Toggles.Find_Kitsune_Island.Value
    StopTween(_G.Find_Kitsune_Island)
end)

SeaPos = CFrame.new(-36995.89453125, 5.8291916847229004, 19408.634765625)

spawn(function()
	while _G.Find_Kitsune_Island do
        wait()
		pcall(function()
            if game:GetService("Workspace").Map:FindFirstChild("KitsuneIsland") then
                --_G.Sit = true
                toposMob(game:GetService("Workspace").Map.KitsuneIsland.Part.CFrame)
            else
                for i,v in pairs(Workspace.Boats:GetChildren()) do
                    if v:FindFirstChild("Owner") then
                        local Owner = (tostring(v.Owner.Value))
                        if Owner == game.Players.LocalPlayer.Name then
                            if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - SeaPos.Position).Magnitude <= 500 then
                                if game.Players.LocalPlayer.Character.Humanoid.Sit == true and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.VehicleSeat.Position).Magnitude < 2 then

                                else
                                    --_G.Sit = false
                                    game.Players.LocalPlayer.Character.HumanoidRootPart.Position = v.VehicleSeat.Position
                                end
                            elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - SeaPos.Position).Magnitude >= 50 and game.Players.LocalPlayer.Character.Humanoid.Sit == false then
                                topos(CFrame.new(-36995.89453125, 5.8291916847229004, 19408.634765625))
                            end
                        else
                            --ซื้อเรือ
                        end
                    else
                    end
                end
            end
        end)
    end
end)

spawn(function()
	while wait() do
        pcall(function()
            if _G.Collect_Azure_Ember then
                if game:GetService("Workspace").Map:FindFirstChild("KitsuneIsland") then
                    topos(game:GetService("Workspace"):FindFirstChild("EmberTemplate").Part.CFrame * CFrame.new(0,1,0))
                end
            end
        end)
	end
end)

Main:AddToggle('Damage_Aura', {
    Text = 'Damage Aura',
    Default = _G.SettingsFile.Damage_Aura,
    Value = _G.Damage_Aura,
})

Toggles.Damage_Aura:OnChanged(function()
    _G.Damage_Aura = Toggles.Damage_Aura.Value
    _G.SettingsFile.Damage_Aura = Toggles.Damage_Aura.Value
    saveSettings()
    StopTween(_G.Damage_Aura)
end)

Main:AddToggle('Kill_Aura', {
    Text = 'Kill Aura',
    Default = _G.SettingsFile.Kill_Aura,
    Value = _G.Kill_Aura,
})

Toggles.Kill_Aura:OnChanged(function()
    _G.Kill_Aura = Toggles.Kill_Aura.Value
    _G.SettingsFile.Kill_Aura = Toggles.Kill_Aura.Value
    saveSettings()
end)

spawn(function()
    while wait() do
        if _G.Kill_Aura then
            for i,v in pairs(game.Workspace.Enemies:GetDescendants()) do
                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude <= 300 then
                        pcall(function()
                            repeat wait(.1)
                                v.Humanoid.Health = 0
                                v.HumanoidRootPart.CanCollide = false
                                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                            until not _G.Kill_Aura or not v.Parent or v.Humanoid.Health <= 0
                        end)
                    end
                end
            end
        end
    end
end)

spawn(function()
	while wait() do
		pcall(function()
            if _G.Teleport_to_Kitsune_Island then
                if game:GetService("Workspace").Map:FindFirstChild("KitsuneIsland") then
                    for i,v in pairs(game:GetService("Workspace").Map.KitsuneIsland:GetChildren()) do
                        toposMob(game:GetService("Workspace").Map.KitsuneIsland.Part.CFrame)
                    end
                end
            end
		end)
	end
end)

spawn(function()
    while wait() do
        if _G.Damage_Aura then
            for i,v in pairs(game.Workspace.Enemies:GetDescendants()) do
                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude <= 1000 then
                        pcall(function()
                            repeat wait(.1)
                                AutoHaki()
                                EquipWeapon(_G.Select_Weapon)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.Humanoid.JumpPower = 0
                                v.HumanoidRootPart.Locked = true
                                v.Humanoid:ChangeState(14)
                                v.Humanoid:ChangeState(11)
                                v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                                if v.Humanoid:FindFirstChild("Animator") then
                                    --v.Humanoid.Animator:Destroy()
                                end
                                MobAura = v.HumanoidRootPart.CFrame
                                MobAuraName = v.Name
                                FastAttackSpeed = true
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(0,50,0))
                                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                            until not _G.Damage_Aura  or not v.Parent or v.Humanoid.Health <= 0 or game.Players.LocalPlayer.Character.Humanoid.Health < 6000
                            FastAttackSpeed = false
                        end)
                    end
                end
            end
        end
    end
end)

--[[spawn(function()
game:GetService("RunService").Heartbeat:Connect(function()
    pcall(function()
        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
            if _G.Damage_Aura and _G.BypassTeleport and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude <= 1000 then
                if v.Name == MobAuraName then
                    v.HumanoidRootPart.CFrame = MobAura
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                    if v.Humanoid:FindFirstChild("Animator") then
                        v.Humanoid.Animator:Destroy()
                    end
                    sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius",  math.huge)
                end
            end
        end
    end)
end)
end)]]--

LegendarySword:AddToggle('AutoLegendarySword', {
    Text = 'Auto Legendary Sword',
    Default = _G.SettingsFile.AutoLegendarySword,
    Value = _G.AutoLegendarySword,
})

Toggles.AutoLegendarySword:OnChanged(function()
    _G.AutoLegendarySword = Toggles.AutoLegendarySword.Value
    _G.SettingsFile.AutoLegendarySword = Toggles.AutoLegendarySword.Value
    saveSettings()
end)

LegendarySword:AddToggle('AutoLegendarySwordHop', {
    Text = 'Auto Legendary Sword [Hop]',
    Default = _G.SettingsFile.AutoLegendarySwordHop,
    Value = _G.AutoLegendarySwordHop,
})

Toggles.AutoLegendarySwordHop:OnChanged(function()
    _G.AutoLegendarySwordHop = Toggles.AutoLegendarySwordHop.Value
    _G.SettingsFile.AutoLegendarySwordHop = Toggles.AutoLegendarySwordHop.Value
    saveSettings()
end)

spawn(function()
    while _G.AutoLegendarySword do
        wait()
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("LegendarySwordDealer", "1")
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("LegendarySwordDealer", "2")
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("LegendarySwordDealer", "3")
            if _G.AutoLegendarySwordHop and World2 then
                wait(1)
                Teleport()
            end
        end)
    end
end)

CakePrince:AddToggle('AutoCakePrince', {
    Text = 'Auto Cake Prince',
    Default = _G.SettingsFile.Auto_Cake_Prince,
    Value = _G.Auto_Cake_Prince,
})

Toggles.AutoCakePrince:OnChanged(function()
    _G.Auto_Cake_Prince = Toggles.AutoCakePrince.Value
    _G.SettingsFile.Auto_Cake_Prince = Toggles.AutoCakePrince.Value
    saveSettings()
    StopTween(_G.Auto_Cake_Prince)
end)

CakePrince:AddToggle('AutoDoughKing', {
    Text = 'Auto Dough King',
    Default = _G.SettingsFile.Auto_Dough_King,
    Value = _G.Auto_Dough_King,
})

Toggles.AutoDoughKing:OnChanged(function()
    _G.Auto_Dough_King = Toggles.AutoDoughKing.Value
    _G.SettingsFile.Auto_Dough_King = Toggles.AutoDoughKing.Value
    saveSettings()
    StopTween(_G.Auto_Dough_King)
end)

local Elite_Hunter_Status = EliteHunter:AddLabel('Elite Hunter : N/A')

spawn(function()
	while wait() do
		pcall(function()
			if game:GetService("ReplicatedStorage"):FindFirstChild("Diablo") or game:GetService("ReplicatedStorage"):FindFirstChild("Deandre") or game:GetService("ReplicatedStorage"):FindFirstChild("Urban") or game:GetService("Workspace").Enemies:FindFirstChild("Diablo") or game:GetService("Workspace").Enemies:FindFirstChild("Deandre") or game:GetService("Workspace").Enemies:FindFirstChild("Urban") then
				Elite_Hunter_Status:Set("Elite Hunter : Spawned")	
			else
				Elite_Hunter_Status:Set("Elite Hunter : Not Spawned")	
			end
		end)
	end
end)

local Elite_Hunter_Processed = EliteHunter:AddLabel('Hunted : N/A')

spawn(function()
	while wait() do
		pcall(function()
            Elite_Hunter_Processed:Set("Hunted : "..game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("EliteHunter","Progress"))
		end)
	end
end)

EliteHunter:AddToggle('AutoEliteHunter', {
    Text = 'Auto Elite Hunter',
    Default = _G.SettingsFile.Auto_Elite_Hunter,
    Value = _G.Auto_Elite_Hunter,
})

Toggles.AutoEliteHunter:OnChanged(function()
    _G.Auto_Elite_Hunter = Toggles.AutoEliteHunter.Value
    _G.SettingsFile.Auto_Elite_Hunter = Toggles.AutoEliteHunter.Value
    saveSettings()
    StopTween(_G.Auto_Elite_Hunter)
end)

EliteHunter:AddToggle('AutoEliteHunterHop', {
    Text = 'Auto Elite Hunter [Hop]',
    Default = _G.SettingsFile.Auto_Elite_Hunter_Hop,
    Value = _G.Auto_Elite_Hunter_Hop,
})

Toggles.AutoEliteHunterHop:OnChanged(function()
    _G.Auto_Elite_Hunter_Hop = Toggles.AutoEliteHunterHop.Value
    _G.SettingsFile.Auto_Elite_Hunter_Hop = Toggles.AutoEliteHunterHop.Value
    saveSettings()
    StopTween(_G.Auto_Elite_Hunter_Hop)
end)

EliteHunter:AddToggle('StopWhenGotGodChalice', {
    Text = "Stop When God's Chalice",
    Default = _G.SettingsFile.StopWhenGotGodChalice,
    Value = _G.StopWhenGotGodChalice,
})

Toggles.StopWhenGotGodChalice:OnChanged(function()
    _G.StopWhenGotGodChalice = Toggles.StopWhenGotGodChalice.Value
    _G.SettingsFile.StopWhenGotGodChalice = Toggles.StopWhenGotGodChalice.Value
    saveSettings()
end)

local Mythic_Island_Status = MythicIsland:AddLabel('Mythic Island : N/A')

spawn(function()
	while wait() do
		pcall(function()
			if game:GetService("Workspace").Map:FindFirstChild("MysticIsland") then
				Mythic_Island_Status:Set("Mythic Island : Spawned")	
			else
				Mythic_Island_Status:Set("Mythic Island : Not Spawned")
			end
		end)
	end
end)

MythicIsland:AddToggle('MythicIsland', {
    Text = 'Teleport to Mythic Island',
    Default = false,
    Value = _G.Teleport_to_Mythic_Island,
})

MythicIsland:AddToggle('Gear', {
    Text = 'Teleport to Gear',
    Default = false,
    Value = _G.Teleport_to_Gear,
})

MythicIsland:AddToggle('CameraToMoon', {
    Text = 'Lock Camera To Moon',
    Default = false,
    Value = _G.LockCameraToMoon,
})

MythicIsland:AddToggle('MythicIslandHop', {
    Text = 'Find Mythic Island [Hop]',
    Default = _G.SettingsFile.Find_Mythic_Island_Hop,
    Value = _G.Find_Mythic_Island_Hop,
})

Toggles.MythicIslandHop:OnChanged(function()
    _G.Find_Mythic_Island_Hop = Toggles.MythicIslandHop.Value
    _G.SettingsFile.Find_Mythic_Island_Hop = Toggles.MythicIslandHop.Value
    saveSettings()
end)

Toggles.CameraToMoon:OnChanged(function()
    _G.LockCameraToMoon = Toggles.CameraToMoon.Value
end)

Toggles.MythicIsland:OnChanged(function()
    _G.Teleport_to_Mythic_Island = Toggles.MythicIsland.Value
    StopTween(_G.Teleport_to_Mythic_Island)
end)


Toggles.Gear:OnChanged(function()
    _G.Teleport_to_Gear = Toggles.Gear.Value
    StopTween(_G.Teleport_to_Gear)
end)

spawn(function()
    while wait() do
        pcall(function()
            if _G.LockCameraToMoon then
                wait(1)
                local moonDir = game.Lighting:GetMoonDirection()
                local lookAtPos = game.Workspace.CurrentCamera.CFrame.p + moonDir * 100
                game.Workspace.CurrentCamera.CFrame = CFrame.lookAt(game.Workspace.CurrentCamera.CFrame.p, lookAtPos)
            end
        end)
    end
end)


spawn(function()
    while wait() do
        pcall(function()
            if _G.Find_Mythic_Island_Hop then
                if game:GetService("Workspace").Map:FindFirstChild("MysticIsland") then
                    _G.Find_Mythic_Island_Hop = false
                else
                    Teleport()
                end
            end
        end)
    end
end)

spawn(function()
	while wait() do
		pcall(function()
            if _G.Teleport_to_Mythic_Island then
                if game:GetService("Workspace").Map:FindFirstChild("MysticIsland") and World3 then
                    for i,v in pairs(game:GetService("Workspace").Map.MysticIsland:GetChildren()) do
                        toposMob(game:GetService("Workspace").Map.MysticIsland.PluginGrass.CFrame)
                    end
                end
            end
		end)
	end
end)

spawn(function()
	while wait() do
		pcall(function()
            if _G.Teleport_to_Gear then
                for i,v in pairs(game:GetService("Workspace").Map.MysticIsland:GetChildren()) do
                    if v.Name == "Part" then
                        if v.ClassName == "MeshPart" then
                            topos(CFrame.new(v.Position))
                        end	
                    end
                end
            end
		end)
	end
end)

Setting:AddDropdown('WeaponList', {
    Values = {"Melee","Sword","Gun","Blox Fruit"},
    Default = _G.SettingsFile.SelectWeaponType,
    Multi = false,
    Text = 'Select Weapon / Combat',
})

Setting:AddToggle('BypassTeleport', {
    Text = 'Bypass Teleport',
    Default = _G.SettingsFile.BypassTeleport,
    Value = _G.SettingsFile.BypassTeleport,
})

Toggles.BypassTeleport:OnChanged(function()
    _G.BypassTeleport = Toggles.BypassTeleport.Value
    _G.SettingsFile.BypassTeleport = Toggles.BypassTeleport.Value
    saveSettings()
end)

Options.WeaponList:OnChanged(function()
    _G.SelectWeaponType = Options.WeaponList.Value
    _G.SettingsFile.SelectWeaponType = Options.WeaponList.Value
    for i,v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
        if v.ToolTip == _G.SelectWeaponType then
            _G.Select_Weapon = v.Name
        end
    end
    saveSettings()
end)

local V4Tier = AdvancedRace:AddLabel('Tier : N/A')

V4Tier:Set("Tier : "..game:GetService("Players").LocalPlayer.Data.Race.C.Value)
game:GetService("Players").LocalPlayer.Data.Race.C.Changed:Connect(function()
    V4Tier:Set("Tier : "..game:GetService("Players").LocalPlayer.Data.Race.C.Value)
end)

AdvancedRace:AddToggle('AutoAncientOneQuest', {
    Text = 'Auto AncientOne Quest',
    Default = _G.SettingsFile.AncientOne_Quest,
    Value = _G.SettingsFile.AncientOne_Quest,
})

Toggles.AutoAncientOneQuest:OnChanged(function()
    _G.AncientOne_Quest = Toggles.AutoAncientOneQuest.Value
    _G.SettingsFile.AncientOne_Quest = Toggles.AutoAncientOneQuest.Value
    saveSettings()
    StopTween(_G.AncientOne_Quest)
end)

AdvancedRace:AddToggle('AutoCompleteTrial', {
    Text = 'Auto Complete Trial',
    Default = false,
    Value = _G.AutoCompleteTrial,
})

Toggles.AutoCompleteTrial:OnChanged(function()
    _G.AutoCompleteTrial = Toggles.AutoCompleteTrial.Value
    StopTween(_G.AutoCompleteTrial)
end)

AdvancedRace:AddToggle('AutoResetCharacter', {
    Text = 'Auto Reset Character',
    Default = _G.SettingsFile.AutoResetCharacter,
    Value = _G.SettingsFile.AutoResetCharacter,
})

Toggles.AutoResetCharacter:OnChanged(function()
    _G.AutoResetCharacter = Toggles.AutoResetCharacter.Value
    _G.SettingsFile.AutoResetCharacter = Toggles.AutoResetCharacter.Value
    saveSettings()
end)

spawn(function()
    pcall(function()
        while wait() do
            if _G.AutoCompleteTrial then
                if game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == true then
                    if (TempleofTime.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 1500 and _G.AutoResetCharacter and game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == true then
                        game.Players.LocalPlayer.Character.Head:Destroy()
                    end
                    if game:GetService("Players").LocalPlayer.Data.Race.Value == "Human" then
                        for i,v in pairs(game.Workspace.Enemies:GetDescendants()) do
                            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude <= 1000 then
                                pcall(function()
                                    repeat wait(.1)
                                        v.Humanoid.Health = 0
                                        v.HumanoidRootPart.CanCollide = false
                                        sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                                    until not _G.AutoCompleteTrial or not v.Parent or v.Humanoid.Health <= 0
                                end)
                            end
                        end
                    elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Skypiea" then
                        if game:GetService("Workspace").Map.SkyTrial.Model:FindFirstChild("FinishPart") then
                            repeat wait()
                                topos(game:GetService("Workspace").Map.SkyTrial.Model.FinishPart.CFrame)
                            until not _G.AutoCompleteTrial or not game:GetService("Workspace").Map.SkyTrial.Model:FindFirstChild("FinishPart") or not game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        end
                        --game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Map.SkyTrial.Model.FinishPart.CFrame
                    elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Fishman" then
                        for i,v in pairs(game:GetService("Workspace").SeaBeasts.SeaBeast1:GetDescendants()) do
                            if v.Name ==  "HumanoidRootPart" and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Position).magnitude <= 1000 then
                                topos(v.CFrame * CFrame.new(0,0,-30))
                                for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                    if v:IsA("Tool") then
                                        if v.ToolTip == "Melee" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
                                            game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                                        end
                                    end
                                end
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,122,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false,122,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                wait(1)
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,120,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false,120,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                wait(1)
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,99,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false,99,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                    if v:IsA("Tool") then
                                        if v.ToolTip == "Blox Fruit" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
                                            game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                                        end
                                    end
                                end
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,122,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false,122,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                wait(1)
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,120,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false,120,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                wait(1)
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,99,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false,99,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                        
                                wait(0.5)
                                for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                    if v:IsA("Tool") then
                                        if v.ToolTip == "Sword" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
                                            game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                                        end
                                    end
                                end
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,122,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false,122,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                wait(1)
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,120,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false,120,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                wait(1)
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,99,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false,99,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                            end
                        end
                    elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Cyborg" then
                        if (TempleofTime.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude >= 1500 then
                            repeat wait()
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875) 
                            until (TempleofTime.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 1500
                        end
                    elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Ghoul" then
                        for i,v in pairs(game.Workspace.Enemies:GetDescendants()) do
                            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude <= 1000 then
                                pcall(function()
                                    repeat wait(.1)
                                        v.Humanoid.Health = 0
                                        v.HumanoidRootPart.CanCollide = false
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                                        sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                                    until not _G.AutoCompleteTrial or not v.Parent or v.Humanoid.Health <= 0
                                end)
                            end
                        end
                    elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Mink" then
                        for i,v in pairs(game:GetService("Workspace"):GetDescendants()) do
                            if v.Name == "StartPoint" then
                                topos(v.CFrame* CFrame.new(0,10,0))
                            end
                        end
                    end
                else
                    if (TempleofTime.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 1500 then
                        if game:GetService("Players")["LocalPlayer"].Data.Race.Value == "Human" then
                            topos(CFrame.new(29231.283203125, 14890.9755859375, -205.39077758789062))
                        elseif game:GetService("Players")["LocalPlayer"].Data.Race.Value == "Fishman" then           
                            topos(CFrame.new(28228.47265625, 14890.978515625, -212.1103515625))
                        elseif game:GetService("Players")["LocalPlayer"].Data.Race.Value == "Cyborg" then
                            topos(CFrame.new(28496.66015625, 14895.9755859375, -422.5971374511719))
                        elseif game:GetService("Players")["LocalPlayer"].Data.Race.Value == "Ghoul" then
                            topos(CFrame.new(28673.232421875, 14890.359375, 454.6542663574219))
                        elseif game:GetService("Players")["LocalPlayer"].Data.Race.Value == "Skypiea" then
                            topos(CFrame.new(28962.220703125, 14919.6240234375, 234.61563110351562))
                        elseif game:GetService("Players")["LocalPlayer"].Data.Race.Value == "Mink" then
                            topos(CFrame.new(29014.6171875, 14890.9755859375, -378.9480285644531))
                        end
                    else
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875) 
                    end
                end
            end
        end
    end)
end)

--[[spawn(function()
    while wait() do
        repeat wait() until game.CoreGui:FindFirstChild('RobloxPromptGui')
        local lp,po,ts = game:GetService('Players').LocalPlayer,game.CoreGui.RobloxPromptGui.promptOverlay,game:GetService('TeleportService')							
        po.ChildAdded:connect(function(a)
            if a.Name == 'ErrorPrompt' then
                repeat
                    wait(10)
                    ts:Teleport(game.PlaceId)
                    wait(2)
                until false
            end
        end)
    end
end)
]]--

FastAttackSpeed = true ------------------ ไว้บนสคริป
_G.Fast_Delay = 0.01 ------------------ ไว้บนสคริป
------------------ ------------------ ------------------ 
local CurveFrame = debug.getupvalues(require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework")))[2]
local VirtualUser = game:GetService("VirtualUser")
local RigControllerR = debug.getupvalues(require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework.RigController))[2]
local Client = game:GetService("Players").LocalPlayer
local DMG = require(Client.PlayerScripts.CombatFramework.Particle.Damage)
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
CameraShaker:Stop()
function CurveFuckWeapon()
    local p13 = CurveFrame.activeController
    local wea = p13.blades[1]
    if not wea then
        return
    end
    while wea.Parent ~= game.Players.LocalPlayer.Character do
        wea = wea.Parent
    end
    return wea
end

function getHits(Size)
    local Hits = {}
    local Enemies = workspace.Enemies:GetChildren()
    local Characters = workspace.Characters:GetChildren()
    for i = 1, #Enemies do
        local v = Enemies[i]
        local Human = v:FindFirstChildOfClass("Humanoid")
        if
            Human and Human.RootPart and Human.Health > 0 and
                game.Players.LocalPlayer:DistanceFromCharacter(Human.RootPart.Position) < Size + 5
         then
            table.insert(Hits, Human.RootPart)
        end
    end
    for i = 1, #Characters do
        local v = Characters[i]
        if v ~= game.Players.LocalPlayer.Character then
            local Human = v:FindFirstChildOfClass("Humanoid")
            if
                Human and Human.RootPart and Human.Health > 0 and
                    game.Players.LocalPlayer:DistanceFromCharacter(Human.RootPart.Position) < Size + 5
             then
                table.insert(Hits, Human.RootPart)
            end
        end
    end
    return Hits
end

function Boost()
    task.spawn(function()
    	game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(CurveFuckWeapon()))
    end)
end

function Unboost()
    tsak.spawn(function()
    	game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("unequipWeapon",tostring(CurveFuckWeapon()))
    end)
end

local cdnormal = 0
local Animation = Instance.new("Animation")
local CooldownFastAttack = 0

FastAttack = function()
    local ac = CurveFrame.activeController
    if ac and ac.equipped then
        task.spawn(function()
            if tick() - cdnormal > 0.5 then
                ac:attack()
                cdnormal = tick()
            else
                Animation.AnimationId = ac.anims.basic[2]
                ac.humanoid:LoadAnimation(Animation):Play(1, 1)
                game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", getHits(120), 2, "")
            end
        end)
    end
end

bs = tick()
task.spawn(function()
	while task.wait(_G.Fast_Delay) do
		if FastAttackSpeed then
		    _G.Fast = true
			if bs - tick() > 0.72 then
				task.wait()
				bs = tick()
			end
			pcall(function()
				for i, v in pairs(game.Workspace.Enemies:GetChildren()) do
					if v.Humanoid.Health > 0 then
						if (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 100 then
							FastAttack()
							task.wait()
							Boost()
						end
					end
				end
			end)
		end
	end
end)

k = tick()
task.spawn(function()
    if _G.Fast then
    while task.wait(.2) do
            if k - tick() > 0.72 then
                task.wait()
                k = tick()
            end
            end
            pcall(function()
                for i, v in pairs(game.Workspace.Enemies:GetChildren()) do
                    if v.Humanoid.Health > 0 then
                        if (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 100 then
                            task.wait(.000025)
                            Unboost()
                        end
                    end
                end
            end)
    end
end)

task.spawn(function()
    while task.wait() do
        if _G.Fast then
	   pcall(function()
		CurveFrame.activeController.timeToNextAttack = -1
		CurveFrame.activeController.focusStart = 0
		CurveFrame.activeController.hitboxMagnitude = 100
		CurveFrame.activeController.humanoid.AutoRotate = true
		CurveFrame.activeController.increment = 1 + 1 / 1
	   end)
    end
    end
end)

abc = true
task.spawn(function()
    local a = game.Players.LocalPlayer
    local b = require(a.PlayerScripts.CombatFramework.Particle)
    local c = require(game:GetService("ReplicatedStorage").CombatFramework.RigLib)
    if not shared.orl then
        shared.orl = c.wrapAttackAnimationAsync
    end
    if not shared.cpc then
        shared.cpc = b.play
    end
    if abc then
        pcall(function()
            c.wrapAttackAnimationAsync = function(d, e, f, g, h)
            local i = c.getBladeHits(e, f, g)
            if i then
                b.play = function()
                end
                d:Play(0.25, 0.25, 0.25)
                h(i)
                b.play = shared.cpc
                wait(.5)
                d:Stop()
            end
            end
        end)
    end
end)

    spawn(function()
        pcall(function()
            game:GetService("RunService").Stepped:Connect(function()
                if _G.Auto_Raid or _G.Auto_Don_Swan or _G.Auto_Stone or _G.Auto_Sea_Beasts or _G.Find_Kitsune_Island or _G.Collect_Azure_Ember or _G.Teleport_to_Kitsune_Island or _G.Auto_Cursed_Captain or _G.Damage_Aura or _G.AutoCompleteTrial or _G.AncientOne_Quest or _G.TeleporttoIsland or _G.Teleport_to_Gear or _G.Teleport_to_Mythic_Island or _G.Auto_Elite_Hunter or _G.Auto_Cake_Prince or _G.Auto_Dough_King then
                    if not game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                        local Noclip = Instance.new("BodyVelocity")
                        Noclip.Name = "BodyClip"
                        Noclip.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
                        Noclip.MaxForce = Vector3.new(100000,100000,100000)
                        Noclip.Velocity = Vector3.new(0,0,0)
                    end
                else	
                    if game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                        game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip"):Destroy()
                    end
                end
            end)
        end)
    end)
     
    spawn(function()
        pcall(function()
            game:GetService("RunService").Stepped:Connect(function()
                if _G.Auto_Raid or _G.Auto_Don_Swan or _G.Auto_Stone or _G.Auto_Sea_Beasts or _G.Find_Kitsune_Island or _G.Collect_Azure_Ember or _G.Teleport_to_Kitsune_Island or _G.Auto_Cursed_Captain or _G.Damage_Aura or _G.AutoCompleteTrial or _G.AncientOne_Quest or _G.TeleporttoIsland or _G.Teleport_to_Gear or _G.Teleport_to_Mythic_Island or _G.Auto_Elite_Hunter or _G.Auto_Cake_Prince or _G.Auto_Dough_King then
                    for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                else
                    for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = true
                        end
                    end
                end
            end)
        end)
    end)

    spawn(function()
        game:GetService("RunService").Heartbeat:Connect(function()
            if _G.Auto_Raid or _G.Auto_Don_Swan or _G.Auto_Stone or _G.Auto_Sea_Beasts or _G.Find_Kitsune_Island or _G.Collect_Azure_Ember or _G.Teleport_to_Kitsune_Island or _G.Auto_Cursed_Captain or _G.Damage_Aura or _G.AutoCompleteTrial or _G.AncientOne_Quest or _G.TeleporttoIsland or _G.Teleport_to_Gear or _G.Teleport_to_Mythic_Island or _G.Auto_Elite_Hunter or _G.Auto_Cake_Prince or _G.Auto_Dough_King then
                if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") then
                    setfflag("HumanoidParallelRemoveNoPhysics", "False")
                    setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
                    game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(11)
                end
            end
        end)
    end)


function EquipWeapon(ToolSe)
    if not _G.NotAutoEquip then
        if game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe) then
            Tool = game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe)
            wait(.1)
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(Tool)
        end
    end
end

function UnEquipWeapon(Weapon)
    if game.Players.LocalPlayer.Character:FindFirstChild(Weapon) then
        _G.NotAutoEquip = true
        wait(.5)
        game.Players.LocalPlayer.Character:FindFirstChild(Weapon).Parent = game.Players.LocalPlayer.Backpack
        wait(.1)
        _G.NotAutoEquip = false
    end
end

function AutoHaki()
    if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end
end

local VirtualInputManager = game:GetService('VirtualInputManager')

function AutoUseAwakening()
    VirtualInputManager:SendKeyEvent(true, "Y", false, game)
    wait()
    VirtualInputManager:SendKeyEvent(false, "Y", false, game)
end

spawn(function()
    while wait() do
        pcall(function()
            if _G.AncientOne_Quest then
                AutoUseAwakening()
            end
        end)
    end
end)

HauntedCastlePoint = CFrame.new(-9513.0771484375, 142.13059997558594, 5535.80859375)

spawn(function()
    while wait(.3) do
        pcall(function()
            if not _G.FastAttack and not _G.FastAttackEL and not _G.FastAttackDK and not _G.FastAttackCP and not _G.FastAttackDA and not _G.FastAttackCC and not _G.FastAttackST and not _G.FastAttackDSW then
                FastAttackSpeed = false
            else
                FastAttackSpeed = true
            end
        end)
    end
end)
spawn(function()
    while wait() do
        pcall(function()
            if _G.AncientOne_Quest then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("UpgradeRace","Buy")
                if game:GetService("Workspace").Enemies:FindFirstChild("Reborn Skeleton") or game:GetService("Workspace").Enemies:FindFirstChild("Living Zombie") or game:GetService("Workspace").Enemies:FindFirstChild("Domenic Soul") or game:GetService("Workspace").Enemies:FindFirstChild("Posessed Mummy") then
                    for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                        if v.Name == "Reborn Skeleton" or v.Name == "Living Zombie" or v.Name == "Demonic Soul" or v.Name == "Posessed Mummy" then
                            if v.Humanoid.Health > 0 then
                                repeat wait()
                                    AutoHaki()
                                    EquipWeapon(_G.Select_Weapon)
                                    FastAttackSpeed = true
                                    v.HumanoidRootPart.CanCollide = false
                                    v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                    AncientOneMon = v.HumanoidRootPart.CFrame
                                    AncientOneMonName = v.Name
                                    toposMob(v.HumanoidRootPart.CFrame)
                                until not _G.AncientOne_Quest or not v.Parent or v.Humanoid.Health <= 0
                                FastAttackSpeed = false
                            end
                        end
                    end
                else
                    topos(CFrame.new(-9513.0771484375, 142.13059997558594, 5535.80859375))
                end
            end
        end)
    end
end)

spawn(function()
    game:GetService("RunService").Heartbeat:Connect(function()
		pcall(function()
			for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
				if _G.AncientOne_Quest and (v.Name == "Reborn Skeleton" or v.Name == "Living Zombie" or v.Name == "Demonic Soul" or v.Name == "Posessed Mummy") and (v.HumanoidRootPart.Position - AncientOneMon.Position).magnitude <= 200 then
                    if AncientOneMonName == v.Name then
                        v.HumanoidRootPart.CFrame = AncientOneMon
                        v.HumanoidRootPart.CanCollide = false
                        v.Humanoid.WalkSpeed = 0
                        v.Humanoid.JumpPower = 0
                        v.HumanoidRootPart.Locked = true
                        v.Humanoid:ChangeState(14)
                        v.Humanoid:ChangeState(11)
                        v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                        if v.Humanoid:FindFirstChild("Animator") then
                            v.Humanoid.Animator:Destroy()
                        end
                        sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius",  math.huge)
                    end
				end
			end
		end)
    end)
end)

spawn(function()
    while wait(.3) do
        pcall(function()
            if FastAttackSpeed then
                repeat wait(.3)
                    AttackNoCD()
                until not FastAttackSpeed
            end
        end)
    end
end)

HydraIslandPos = CFrame.new(5290.0498046875, 602.1102294921875, 347.9987487792969)

spawn(function()
	while wait() do
		if _G.Auto_Elite_Hunter then
			pcall(function()
				if game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == true then
					if string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text,"Diablo") or string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text,"Deandre") or string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text,"Urban") then
						if game:GetService("Workspace").Enemies:FindFirstChild("Diablo") or game:GetService("Workspace").Enemies:FindFirstChild("Deandre") or game:GetService("Workspace").Enemies:FindFirstChild("Urban") then
							for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
								if v.Name == "Diablo" or v.Name == "Deandre" or v.Name == "Urban" then
									if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
										repeat wait()
											AutoHaki()
											EquipWeapon(_G.Select_Weapon)
                                            ElitePos = v.HumanoidRootPart.CFrame
                                            FastAttackSpeed = true
                                            v.HumanoidRootPart.CanCollide = false
                                            v.Humanoid.WalkSpeed = 0
                                            v.Humanoid.JumpPower = 0
                                            v.HumanoidRootPart.Locked = true
                                            v.Humanoid:ChangeState(14)
                                            v.Humanoid:ChangeState(11)
                                            v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                                            if v.Humanoid:FindFirstChild("Animator") then
                                                v.Humanoid.Animator:Destroy()
                                            end
                                            sethiddenproperty(game:GetService("Players").LocalPlayer,"SimulationRadius",math.huge)
                                            toposMob(v.HumanoidRootPart.CFrame)
										until _G.Auto_Elite_Hunter == false or v.Humanoid.Health <= 0 or not v.Parent
                                        FastAttackSpeed = false
									end
								end
							end
						else
							if game:GetService("ReplicatedStorage"):FindFirstChild("Diablo") then
                                if _G.Auto_Elite_Hunter and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - game:GetService("ReplicatedStorage"):FindFirstChild("Diablo").HumanoidRootPart.Position).Magnitude >= 3000 and (MansionPos.Position - game:GetService("ReplicatedStorage"):FindFirstChild("Diablo").HumanoidRootPart.Position).Magnitude <= 3000 then
                                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375))
                                elseif _G.Auto_Elite_Hunter and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - game:GetService("ReplicatedStorage"):FindFirstChild("Diablo").HumanoidRootPart.Position).Magnitude >= 4000 and (HydraIslandPos.Position - game:GetService("ReplicatedStorage"):FindFirstChild("Diablo").HumanoidRootPart.Position).Magnitude <= 4000 then
                                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-5099.0234375, 316.5068054199219, -3169.302978515625))
                                else
									topos(game:GetService("ReplicatedStorage"):FindFirstChild("Diablo").HumanoidRootPart.CFrame * CFrame.new(0,50,0))
                                end
							elseif game:GetService("ReplicatedStorage"):FindFirstChild("Deandre") then
                                if _G.Auto_Elite_Hunter and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - game:GetService("ReplicatedStorage"):FindFirstChild("Deandre").HumanoidRootPart.Position).Magnitude >= 3000 and (MansionPos.Position - game:GetService("ReplicatedStorage"):FindFirstChild("Deandre").HumanoidRootPart.Position).Magnitude <= 3000 then
									game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375))
                                elseif _G.Auto_Elite_Hunter and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - game:GetService("ReplicatedStorage"):FindFirstChild("Deandre").HumanoidRootPart.Position).Magnitude >= 4000 and (HydraIslandPos.Position - game:GetService("ReplicatedStorage"):FindFirstChild("Deandre").HumanoidRootPart.Position).Magnitude <= 4000 then
                                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-5099.0234375, 316.5068054199219, -3169.302978515625))
                                else
                                    topos(game:GetService("ReplicatedStorage"):FindFirstChild("Deandre").HumanoidRootPart.CFrame * CFrame.new(0,50,0))
                                end  
							elseif game:GetService("ReplicatedStorage"):FindFirstChild("Urban") then
                                --[[if _G.Auto_Elite_Hunter and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - game:GetService("ReplicatedStorage"):FindFirstChild("Urban").HumanoidRootPart.Position).Magnitude >= 3000 and (MansionPos.Position - game:GetService("ReplicatedStorage"):FindFirstChild("Urban").HumanoidRootPart.Position).Magnitude <= 3000 then
									game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375))
                                elseif _G.Auto_Elite_Hunter and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - game:GetService("ReplicatedStorage"):FindFirstChild("Urban").HumanoidRootPart.Position).Magnitude >= 4000 and (HydraIslandPos.Position - game:GetService("ReplicatedStorage"):FindFirstChild("Urban").HumanoidRootPart.Position).Magnitude <= 4000 then
                                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-5099.0234375, 316.5068054199219, -3169.302978515625))
                                else
                                    topos(game:GetService("ReplicatedStorage"):FindFirstChild("Urban").HumanoidRootPart.CFrame * CFrame.new(0,50,0))
                                end]]
                                topos(game:GetService("ReplicatedStorage"):FindFirstChild("Urban").HumanoidRootPart.CFrame * CFrame.new(0,50,0))
							end
						end                    
					end
				else
					if _G.Auto_Elite_Hunter_Hop and game:GetService("ReplicatedStorage").Remotes["CommF_"]:InvokeServer("EliteHunter") == "I don't have anything for you right now. Come back later." then
						if _G.StopWhenGotGodChalice then
							if game.Players.LocalPlayer.Backpack:FindFirstChild("God's Chalice") or game.Players.LocalPlayer.Character:FindFirstChild("God's Chalice") then
								_G.Auto_Elite_Hunter_Hop = false
								wait()
							else
								Teleport()
							end
						else
							Teleport()
						end
					else
						game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("EliteHunter")
					end
				end
			end)
		end
	end
end)

local MirrorRoom = CFrame.new(-2009.2802734375, 4532.97216796875, -14937.3076171875)
local DoorMirror = CFrame.new(-2130.915283203125, 70.00882720947266, -12399.0380859375)

spawn(function()
    while wait() do
        pcall(function()
            if _G.Auto_Dough_King then
                if game.Players.LocalPlayer.Backpack:FindFirstChild("God's Chalice") or game.Players.LocalPlayer.Character:FindFirstChild("God's Chalice") then
                    if string.find(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SweetChaliceNpc"),"Where") then
                        repeat wait() until not string.find(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SweetChaliceNpc"),"Where")
                    else
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SweetChaliceNpc")
                    end
                elseif game.Players.LocalPlayer.Backpack:FindFirstChild("Sweet Chalice") or game.Players.LocalPlayer.Character:FindFirstChild("Sweet Chalice") then
                    if string.find(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner"),"Do you want to open the portal now?") then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                    else
                        if game.Workspace.Enemies:FindFirstChild("Baking Staff") or game.Workspace.Enemies:FindFirstChild("Head Baker") or game.Workspace.Enemies:FindFirstChild("Cake Guard") or game.Workspace.Enemies:FindFirstChild("Cookie Crafter")  then
                            for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do  
                                if (v.Name == "Baking Staff" or v.Name == "Head Baker" or v.Name == "Cake Guard" or v.Name == "Cookie Crafter") and v.Humanoid.Health > 0 then
                                    repeat wait()
                                        AutoHaki()
                                        EquipWeapon(_G.Select_Weapon)
                                        CakeMon = v.HumanoidRootPart.CFrame
                                        CakeMonName = v.Name
                                        FastAttackSpeed = true
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.Humanoid.JumpPower = 0
                                        v.HumanoidRootPart.Locked = true
                                        v.Humanoid:ChangeState(14)
                                        v.Humanoid:ChangeState(11)
                                        v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                                        if v.Humanoid:FindFirstChild("Animator") then
                                            v.Humanoid.Animator:Destroy()
                                        end
                                        sethiddenproperty(game:GetService("Players").LocalPlayer,"SimulationRadius",math.huge)
                                        toposMob(v.HumanoidRootPart.CFrame)
                                    until _G.Auto_Dough_King == false or game:GetService("ReplicatedStorage"):FindFirstChild("Cake Prince") or not v.Parent or v.Humanoid.Health <= 0
                                    FastAttackSpeed = false
                                end
                            end
                        else
                            topos(CFrame.new(-1820.0634765625, 210.74781799316406, -12297.49609375))
                        end
                    end						
                elseif game.ReplicatedStorage:FindFirstChild("Dough King") or game:GetService("Workspace").Enemies:FindFirstChild("Dough King") then
                    if game:GetService("Workspace").Enemies:FindFirstChild("Dough King") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do 
                            if v.Name == "Dough King" then
                                repeat wait()
                                    AutoHaki()
                                    EquipWeapon(_G.Select_Weapon)
                                    FastAttackSpeed = true
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.Humanoid.JumpPower = 0
                                    v.HumanoidRootPart.Locked = true
                                    v.Humanoid:ChangeState(14)
                                    v.Humanoid:ChangeState(11)
                                    v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                                    if v.Humanoid:FindFirstChild("Animator") then
                                        v.Humanoid.Animator:Destroy()
                                    end
                                    sethiddenproperty(game:GetService("Players").LocalPlayer,"SimulationRadius",math.huge)
                                    toposMob(v.HumanoidRootPart.CFrame)
                                until _G.Auto_Dough_King == false or not v.Parent or v.Humanoid.Health <= 0
                                FastAttackSpeed = false
                            end    
                        end    
                    else
                        if (MirrorRoom.Position - DoorMirror.Position).Magnitude >= 1500 then
                            repeat wait()
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2130.915283203125, 70.00882720947266, -12399.0380859375)
                            until not game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        else
                            topos(CFrame.new(-2009.2802734375, 4532.97216796875, -14937.3076171875))
                        end
                         
                    end
                end
            end
        end)
    end
end)

spawn(function()
    game:GetService("RunService").Heartbeat:Connect(function()
		pcall(function()
			for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
				if _G.Auto_Dough_King or _G.Auto_Cake_Prince then
                    if (v.Name == "Cookie Crafter" or v.Name == "Cake Guard" or v.Name == "Baking Staff" or v.Name == "Head Baker") and (v.HumanoidRootPart.Position - CakeMon.Position).magnitude <= 350 then
                        if CakeMonName == v.Name then
                            v.HumanoidRootPart.CFrame = CakeMon
                            v.HumanoidRootPart.CanCollide = false
                            v.Humanoid.WalkSpeed = 0
                            v.Humanoid.JumpPower = 0
                            v.HumanoidRootPart.Locked = true
                            v.Humanoid:ChangeState(14)
                            v.Humanoid:ChangeState(11)
                            v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                            if v.Humanoid:FindFirstChild("Animator") then
                                v.Humanoid.Animator:Destroy()
                            end
                            sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius",  math.huge)
                        end
                    end
				end
			end
		end)
    end)
end)

spawn(function()
    while _G.Auto_Cake_Prince do
        pcall(function()
            if game.ReplicatedStorage:FindFirstChild("Cake Prince [Lv. 2300] [Raid Boss]") or game:GetService("Workspace").Enemies:FindFirstChild("Cake Prince [Lv. 2300] [Raid Boss]") then   
                if game:GetService("Workspace").Enemies:FindFirstChild("Cake Prince [Lv. 2300] [Raid Boss]") then
                    for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do 
                        if v.Name == "Cake Prince [Lv. 2300] [Raid Boss]" then
                            repeat wait()
                                AutoHaki()
                                EquipWeapon(_G.Select_Weapon)
                                FastAttackSpeed = true
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.Humanoid.JumpPower = 0
                                v.HumanoidRootPart.Locked = true
                                v.Humanoid:ChangeState(14)
                                v.Humanoid:ChangeState(11)
                                v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                                if v.Humanoid:FindFirstChild("Animator") then
                                    v.Humanoid.Animator:Destroy()
                                end
                                sethiddenproperty(game:GetService("Players").LocalPlayer,"SimulationRadius",math.huge)
                                toposMob(v.HumanoidRootPart.CFrame)
                            until _G.Auto_Cake_Prince == false or not v.Parent or v.Humanoid.Health <= 0
                            FastAttackSpeed = false
                        end    
                    end    
                else
                    topos(CFrame.new(-2009.2802734375, 4532.97216796875, -14937.3076171875)) 
                end
            else
                if game.Workspace.Enemies:FindFirstChild("Baking Staff [Lv. 2250]") or game.Workspace.Enemies:FindFirstChild("Head Baker [Lv. 2275]") or game.Workspace.Enemies:FindFirstChild("Cake Guard [Lv. 2225]") or game.Workspace.Enemies:FindFirstChild("Cookie Crafter [Lv. 2200]")  then
                    for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do  
                        if (v.Name == "Baking Staff [Lv. 2250]" or v.Name == "Head Baker [Lv. 2275]" or v.Name == "Cake Guard [Lv. 2225]" or v.Name == "Cookie Crafter [Lv. 2200]") and v.Humanoid.Health > 0 then
                            repeat wait()
                                AutoHaki()
                                EquipWeapon(_G.Select_Weapon)
                                CakeMon = v.HumanoidRootPart.CFrame
                                CakeMonName = v.Name
                                FastAttackSpeed = true
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.Humanoid.JumpPower = 0
                                v.HumanoidRootPart.Locked = true
                                v.Humanoid:ChangeState(14)
                                v.Humanoid:ChangeState(11)
                                v.HumanoidRootPart.Size = Vector3.new(50,50,50)
                                if v.Humanoid:FindFirstChild("Animator") then
                                    v.Humanoid.Animator:Destroy()
                                end
                                sethiddenproperty(game:GetService("Players").LocalPlayer,"SimulationRadius",math.huge)
                                toposMob(v.HumanoidRootPart.CFrame)
                            until _G.Auto_Cake_Prince == false or game:GetService("ReplicatedStorage"):FindFirstChild("Cake Prince [Lv. 2300] [Raid Boss]") or not v.Parent or v.Humanoid.Health <= 0
                            FastAttackSpeed = false
                        end
                    end
                else
                    topos(CFrame.new(-1820.0634765625, 210.74781799316406, -12297.49609375))
                end
            end
        end)
    end
end)

return Library;
