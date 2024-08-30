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

print("Polygon Hub Is Loading...")

wait(1)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()


if game.PlaceId == 2753915549 then
	World1 = true
elseif game.PlaceId == 4442272183 then
	World2 = true
elseif game.PlaceId == 7449423635 then
	World3 = true
end

-- Main

local Window = Fluent:CreateWindow({
    Title = "Polygon Hub | Blox Fruits",
    SubTitle = "by mhooyongtar",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 430),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "tv-2" }),
    Travel = Window:AddTab({ Title = "Travel", Icon = "star" }),
    Server = Window:AddTab({ Title = "Server", Icon = "list" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local General = Tabs.Main:AddSection("General")
local AdvancedRace = Tabs.Main:AddSection("Advanced Race")
local MirageIsland = Tabs.Main:AddSection("Mirage Island")

local Island = Tabs.Travel:AddSection("Island")

do

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
    
    FastAttackSpeed = false
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
    
    function topos2(Pos)
        if game.Players.LocalPlayer.Character.Humanoid.Sit == true then game.Players.LocalPlayer.Character.Humanoid.Sit = false end
        pcall(function() tween = game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart,TweenInfo.new(Distance/310, Enum.EasingStyle.Linear),{CFrame = Pos}) end)
        tween:Play()
    end
    
    function topos(Pos)
        _G.Clip = true
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
    
        if _G.BypassTeleport and not _G.AutoCompleteTrial and not _G.Teleport_to_Mirage_Island and not _G.Teleport_to_Gear and not game.Players.LocalPlayer.Backpack:FindFirstChild("God's Chalice") and not game.Players.LocalPlayer.Character:FindFirstChild("God's Chalice") and not game.Players.LocalPlayer.Backpack:FindFirstChild("Sweet Chalice") and not game.Players.LocalPlayer.Character:FindFirstChild("Sweet Chalice") then
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
    
    function toposMob(target)
        topos(target * CFrame.new(0,50,0))
    end
    
    function toposSeaBeasts(target)
        topos(target * CFrame.new(0,0,60))
        wait(1)
        topos(target * CFrame.new(0,0,30))
        wait(1)
        topos(target * CFrame.new(0,0,0))
        wait(1)
        topos(target * CFrame.new(0,0,-30))
        wait(1)
        topos(target * CFrame.new(0,0,-60))
    end
    
    
    function StopTween(target)
        if not target then
            _G.StopTween = true
            topos(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame)
            topos(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame)
            wait()
            if game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip"):Destroy()
            end
            _G.StopTween = false
            _G.NoClip = false
        end
    end
    
    function InstantStopTween()
        _G.StopTween = true
        topos(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame)
        topos(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame)
        wait()
        if game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip"):Destroy()
        end
        _G.StopTween = false
        _G.NoClip = false
    end
    
    spawn(function()
        pcall(function()
            game:GetService("RunService").Stepped:Connect(function()
                if _G.Clip then
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
                if _G.Clip then
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
            if _G.Clip then
                if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") then
                    setfflag("HumanoidParallelRemoveNoPhysics", "False")
                    setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
                    game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(11)
                end
            end
        end)
    end)

    local Weapon = General:AddDropdown("SelectWapon", {
        Title = "Select Weapon / Combat",
        Values = {"Melee","Sword","Gun","Blox Fruit"},
        Multi = false,
        Default = 1,
    })

    Weapon:OnChanged(function(Value)
        for i,v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
            if v.ToolTip == Value then
                _G.Select_Weapon = v.Name
            end
        end
    end)

    local Tier = AdvancedRace:AddParagraph({
        Title = "Advance Race Tier",
        Content = "Tier: Loading..."
    })

    Tier:SetDesc("Tier: "..game:GetService("Players").LocalPlayer.Data.Race.C.Value)
    game:GetService("Players").LocalPlayer.Data.Race.C.Changed:Connect(function()
        Tier:SetDesc("Tier: "..game:GetService("Players").LocalPlayer.Data.Race.C.Value)
    end)

    local AutoCompleteTrial = AdvancedRace:AddToggle("AutoCompleteTrial", {
        Title = "Auto Complete Trial",
        Default = false 
    })

    local TempleofTime = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875)

    AutoCompleteTrial:OnChanged(function()
        _G.AutoCompleteTrial = AutoCompleteTrial.Value
        StopTween(_G.AutoCompleteTrial)
    end)

    spawn(function()
        pcall(function()
            while wait() do
                if _G.AutoCompleteTrial then
                    if game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == true then
                        if (CFrame.new(28746.4296875, 14887.5615234375, -94.38116455078125).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 200 and _G.AutoResetCharacter and game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == true then
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
                                until not _G.AutoCompleteTrial or not game:GetService("Workspace").Map.SkyTrial.Model:FindFirstChild("FinishPart") or not game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or (TempleofTime.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 1000
                                InstantStopTween()
                            end
                            --game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Map.SkyTrial.Model.FinishPart.CFrame
                        elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Fishman" then
                            for i,v in pairs(game:GetService("Workspace").SeaBeasts.SeaBeast1:GetDescendants()) do
                                if v.Name ==  "HumanoidRootPart" and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Position).magnitude <= 1000 then
                                    toposSeaBeasts(v.CFrame)
                                    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                        if v:IsA("Tool") then
                                            if v.ToolTip == "Melee" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
                                                game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                                            end
                                        end
                                    end
                                    wait()
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,122,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false,122,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    wait()
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,120,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false,120,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    wait()
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,99,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false,99,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                        if v:IsA("Tool") then
                                            if v.ToolTip == "Blox Fruit" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
                                                game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                                            end
                                        end
                                    end
                                    wait()
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,122,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false,122,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    wait()
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,120,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false,120,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    wait()
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,99,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false,99,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                        if v:IsA("Tool") then
                                            if v.ToolTip == "Sword" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
                                                game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                                            end
                                        end
                                    end
                                    wait()
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,122,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false,122,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    wait()
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,120,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false,120,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
                                    wait()
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
                                    repeat wait()
                                        topos(v.CFrame * CFrame.new(0,10,0))
                                    until not _G.AutoCompleteTrial or not v.P or not game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or (TempleofTime.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 1000
                                    InstantStopTween()
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

    local AncientOneQuest = AdvancedRace:AddToggle("AncientOneQuest", {
        Title = "Auto Ancient One Quest",
        Default = false 
    })

    AncientOneQuest:OnChanged(function()
        _G.AncientOne_Quest = AncientOneQuest.Value
    end)

    spawn(function()
        while wait() do
            pcall(function()
                if _G.AncientOne_Quest then
                    VirtualInputManager:SendKeyEvent(true, "Y", false, game)
                    wait()
                    VirtualInputManager:SendKeyEvent(false, "Y", false, game)
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

    local AutoResetCharacter = AdvancedRace:AddToggle("AutoResetCharacter", {
        Title = "Auto Reset Character",
        Default = false 
    })

    AutoResetCharacter:OnChanged(function()
        _G.AutoResetCharacter = AutoResetCharacter.Value
    end)

    AdvancedRace:AddButton({
        Title = "Activate Ability",
        Callback = function()
            game:GetService("ReplicatedStorage").Remotes.CommE:FireServer("ActivateAbility")
        end
    })

    local AutoResetCharacter = AdvancedRace:AddToggle("AutoResetCharacter", {
        Title = "Auto Reset Character",
        Default = false 
    })

    AutoResetCharacter:OnChanged(function()
        _G.AutoResetCharacter = AutoResetCharacter.Value
    end)

    local Mirage_Island_Status = MirageIsland:AddParagraph({
        Title = "Mirage Island Status",
        Content = "Mirage Island : Loading..."
    })

    spawn(function()
        while wait() do
            pcall(function()
                if game:GetService("Workspace").Map:FindFirstChild("MysticIsland") then
                    Mirage_Island_Status:SetDesc("Mirage Island : Spawned")	
                else
                    Mirage_Island_Status:SetDesc("Mirage Island : Not Spawned")
                end
            end)
        end
    end)

    local TeleporttoMirageIsland = MirageIsland:AddToggle("TeleporttoMirageIsland", {
        Title = "Teleport to Mirage Island",
        Default = false 
    })

    TeleporttoMirageIsland:OnChanged(function()
        _G.Teleport_to_Mirage_Island = TeleporttoMirageIsland.Value
        StopTween(_G.Teleport_to_Mirage_Island)
    end)

    local TeleporttoGear = MirageIsland:AddToggle("TeleporttoGear", {
        Title = "Teleport to Gear",
        Default = false 
    })

    TeleporttoGear:OnChanged(function()
        _G.Teleport_to_Gear = TeleporttoGear.Value
        StopTween(_G.Teleport_to_Gear)
    end)

    local LockCameratoMoon = MirageIsland:AddToggle("LockCameratoMoon", {
        Title = "Lock Camera to Moon",
        Default = false 
    })

    LockCameratoMoon:OnChanged(function()
        _G.LockCameraToMoon = LockCameratoMoon.Value
    end)

    AdvancedRace:AddButton({
        Title = "Remove Mirage Fog",
        Callback = function()
            game:GetService("Lighting").LightingLayers.MirageFog:Destroy()
            game:GetService("Lighting").BaseAtmosphere:Destroy()
        end
    })

    spawn(function()
        while wait() do
            pcall(function()
                if _G.Teleport_to_Mirage_Island then
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

    if World1 then
        Islands = {
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
        Islands = {
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
        Islands = {
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
    
    local IslandList = Island:AddDropdown("SelectIsland", {
        Title = "Select Island",
        Values = Islands,
        Multi = false,
        Default = 1,
    })

    IslandList:OnChanged(function(Value)
        _G.Island = Value
    end)

    local TeleporttoIsland = Island:AddToggle("Teleport to Island", {
        Title = "Teleport to Island",
        Default = false 
    })

    TeleporttoIsland:OnChanged(function(Value)
        _G.TeleporttoIsland = Value
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
        StopTween(_G.TeleporttoIsland)
    end)

    local JobId = Tabs.Server:AddInput("JobId", {
        Title = "JobId",
        Default = "",
        Placeholder = "Placeholder",
        Numeric = false, -- Only allows numbers
        Finished = true, -- Only calls callback when you press enter
        Callback = function(Value)
            _G.JobId = Value
        end
    })

    JobId:OnChanged(function()
        _G.JobId = JobId.Value
    end)

    Tabs.Server:AddButton({
        Title = "Join JobId",
        Description = "",
        Callback = function()
            game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId,_G.JobId,game.Players.LocalPlayer)
        end
    })

    Tabs.Server:AddButton({
        Title = "Copy JobId",
        Description = "",
        Callback = function()
            setclipboard(tostring(game.JobId))
        end
    })

end


-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
