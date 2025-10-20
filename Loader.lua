repeat wait() until _G.Key == "I OAT NA HEE"

repeat wait() until game.Players
repeat wait() until game.Players.LocalPlayer
repeat wait() until game.ReplicatedStorage
repeat wait() until game.ReplicatedStorage:FindFirstChild("Remotes");
repeat wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui");
repeat wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)") or game.Players.LocalPlayer.PlayerGui:FindFirstChild("Main");
repeat wait() until game:GetService("Players")
if not game:IsLoaded() then repeat game.Loaded:Wait() until game:IsLoaded() end
if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)") then
    if game:GetService("Players").LocalPlayer.PlayerGui["Main (minimal)"]:FindFirstChild("ChooseTeam") then
        repeat wait()
            if game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Main (minimal)").ChooseTeam.Visible == true then
                if _G.Team == "Pirate" then
                    for i, v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui["Main (minimal)"].ChooseTeam.Container.Pirates.Frame.TextButton.Activated)) do                                                                                                
                        v.Function()
                    end
                elseif _G.Team == "Marine" then
                    for i, v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui["Main (minimal)"].ChooseTeam.Container.Marines.Frame.TextButton.Activated)) do                                                                                                
                        v.Function()
                    end
                else
                    for i, v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui["Main (minimal)"].ChooseTeam.Container.Pirates.Frame.TextButton.Activated)) do                                                                                                
                        v.Function()
                    end
                end
            end
        until game.Players.LocalPlayer.Team ~= nil and game:IsLoaded()
    end
end

wait(1)


local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")

local Workspace = game:GetService("Workspace")
local Enemies = Workspace:FindFirstChild("Enemies")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ShootGunEvent = Net:WaitForChild("RE/ShootGunEvent")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local TempleofTime = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875)

PlayerRole = "None"

local Helper = _G.Helpers

if table.find(Helper, Player.Name) then
    HelperRole = true
    PlayerRole = "Helper"
    AutoResetCharacter = true
else
    HeadRole = true
    PlayerRole = "Head"
end

local function SafeCharacter()
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        repeat task.wait() until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        char = Player.Character
    end
    return char
end

function inRange(object, range)
    local Char = SafeCharacter()
    if not Char then return end
    if (object.Position - Char:GetPivot().Position).Magnitude <= range then
        return true
    end
    return false
end

function StartTween(Pos)
    if Pos ~= "Stop" then
        local Char = SafeCharacter()
        if not Char then return end
        _G.Clip = true
        local Distance = (Pos.Position - Char.HumanoidRootPart.Position).Magnitude
        if Char.Humanoid.Sit then 
            Char.Humanoid.Sit = false
        end
        pcall(function() 
            Tween = TweenService:Create(Char.HumanoidRootPart,TweenInfo.new(Distance/360, Enum.EasingStyle.Linear),{CFrame = Pos}) 
        end)
        Tween:Play()
    else
        local Char = SafeCharacter()
        local TW2 = TweenService:Create(Char.HumanoidRootPart, TweenInfo.new(0.1), {CFrame = Char.HumanoidRootPart.CFrame})
        Tween:Cancel()
    end
end

function CheckBlueGear()
    if not game:GetService("Workspace").Map:FindFirstChild("MysticIsland") then return end
    for i,v in pairs(game:GetService("Workspace").Map.MysticIsland:GetChildren()) do
        if v.Name == "Part" and v:IsA("MeshPart") and v.Transparency == 0 then
            return true, v.CFrame
        end	
    end
    return nil
end

function EquipWeapon()
    if not Player.Character.HumanoidRootPart or not Player.Character.Humanoid then return end
    for _,tool in ipairs(Player.Backpack:GetChildren()) do
        if tool.ToolTip == "Melee" then
            Player.Character.Humanoid:EquipTool(tool)
        end
    end
end

function AutoHaki()
    if not Player.Character.HumanoidRootPart or not Player.Character.Humanoid then return end
    if not Player.Character:FindFirstChild("HasBuso") then
        Remotes.CommF_:InvokeServer("Buso")
    end
end

function ActiveRaceV3()
    game:GetService("ReplicatedStorage").Remotes.CommE:FireServer("ActivateAbility")
end

local AttackConfig = {
    AttackDistance = 100,
    AttackMobs = true,
    AttackPlayers = false,
    AttackCooldown = 0.001,
    ComboResetTime = 0.001,
    MaxCombo = 2,
    HitboxLimbs = {"RightLowerArm", "RightUpperArm", "LeftLowerArm", "LeftUpperArm", "RightHand", "LeftHand"},
    AutoClickEnabled = true
}

local FastAttack = {}
FastAttack.__index = FastAttack

function FastAttack.new()
    local self = setmetatable({
        Debounce = 0,
        ComboDebounce = 0,
        ShootDebounce = 0,
        M1Combo = 0,
        EnemyRootPart = nil,
        Connections = {},
        Overheat = {
            Dragonstorm = {
                Cooldown = 0,
                Distance = 350,
            }
        },
    }, FastAttack)

    pcall(function()

        self.CombatFlags = require(Modules.Flags).COMBAT_REMOTE_THREAD

        self.ShootFunction = getupvalue(require(ReplicatedStorage.Controllers.CombatController).Attack, 9)
        local LocalScript = Player:WaitForChild("PlayerScripts"):FindFirstChildOfClass("LocalScript")
        if LocalScript and getsenv then
            self.HitFunction = getsenv(LocalScript)._G.SendHitsToServer
        end
    end)

    return self
end

function FastAttack:IsEntityAlive(entity)
    local humanoid = entity and entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

function FastAttack:CheckStun(Character, Humanoid, ToolTip)
    local Stun = Character:FindFirstChild("Stun")
    local Busy = Character:FindFirstChild("Busy")
    if Humanoid.Sit and (ToolTip == "Sword" or ToolTip == "Melee" or ToolTip == "Blox Fruit") then
        return false
    elseif Stun and Stun.Value > 0 or Busy and Busy.Value then
        return false
    end
    return true
end


function FastAttack:GetBladeHits(Character, Distance)
    local Position = Character:GetPivot().Position
    local BladeHits = {}
    Distance = Distance or AttackConfig.AttackDistance
    local function ProcessTargets(Folder, CanAttack)
        for _, Enemy in ipairs(Folder:GetChildren()) do
            pcall(function()
                if Enemy ~= Character and self:IsEntityAlive(Enemy) then
                    local BasePart = Enemy:FindFirstChild(
                    AttackConfig.HitboxLimbs[math.random(#AttackConfig.HitboxLimbs)]) or
                    Enemy:FindFirstChild("HumanoidRootPart")
                    if BasePart and (Position - BasePart.Position).Magnitude <= Distance then
                        if not self.EnemyRootPart then
                            self.EnemyRootPart = BasePart
                        else
                            table.insert(BladeHits, {Enemy, BasePart})
                            table.insert(BladeHits, {})
                        end
                    end
                end
            end)
        end
    end
    if AttackConfig.AttackMobs then
        pcall(ProcessTargets, Enemies)
    end
    if AttackConfig.AttackPlayers then
        pcall(ProcessTargets, Workspace.Characters, true)
    end
    return BladeHits
end

function FastAttack:GetClosestEnemy(Character, Range)
    local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, shortest = nil, Range or 100
    for _, enemy in pairs(Enemies:GetChildren()) do
        local eHumanoid = enemy:FindFirstChildOfClass("Humanoid")
        local eHRP = enemy:FindFirstChild("HumanoidRootPart")
        if eHumanoid and eHRP and eHumanoid.Health > 0 then
            local distance = (hrp.Position - eHRP.Position).Magnitude
            if distance < shortest then
                nearest = eHRP
                shortest = distance
            end
        end
    end
    return nearest
end


function FastAttack:GetValidator2()
    if not self.ShootFunction then return 0, 0 end
    local v1 = getupvalue(self.ShootFunction, 15)
    local v2 = getupvalue(self.ShootFunction, 13)
    local v3 = getupvalue(self.ShootFunction, 16)
    local v4 = getupvalue(self.ShootFunction, 17)
    local v5 = getupvalue(self.ShootFunction, 14)
    local v6 = getupvalue(self.ShootFunction, 12)
    local v7 = getupvalue(self.ShootFunction, 18)

    local v8 = v6 * v2
    local v9 = (v5 * v2 + v6 * v1) % v3
    v9 = (v9 * v3 + v8) % v4
    v5 = math.floor(v9 / v3)
    v6 = v9 - v5 * v3
    v7 = v7 + 1
    setupvalue(self.ShootFunction, 15, v1)
    setupvalue(self.ShootFunction, 13, v2)
    setupvalue(self.ShootFunction, 16, v3)
    setupvalue(self.ShootFunction, 17, v4)
    setupvalue(self.ShootFunction, 14, v5)
    setupvalue(self.ShootFunction, 12, v6)
    setupvalue(self.ShootFunction, 18, v7)

    return math.floor(v9 / v4 * 16777215), v7
end

function FastAttack:UseNormalClick(Character, Humanoid, Cooldown)
    self.EnemyRootPart = nil
    local BladeHits = self:GetBladeHits(Character)

    if self.EnemyRootPart then
        pcall(function()
            RegisterAttack:FireServer(Cooldown)
        end)
        if self.CombatFlags and self.HitFunction then
            pcall(function()
                self.HitFunction(self.EnemyRootPart, BladeHits)
            end)
        else
            pcall(function()
                RegisterHit:FireServer(self.EnemyRootPart, BladeHits)
            end)
        end
    end
end

function FastAttack:UseFruitM1(Character, Equipped, Combo)
    local Targets = self:GetBladeHits(Character)
    if not Targets[1] then
        return
    end
    local Direction = (Targets[1][2].Position - Character:GetPivot().Position).Unit
    if Equipped and Equipped:FindFirstChild("LeftClickRemote") then
        pcall(function()
            Equipped.LeftClickRemote:FireServer(Direction, Combo)
        end)
    end
end

function FastAttack:ShootInTarget(TargetPosition)
    if not TargetPosition then return end
    if ShootGunEvent then
        pcall(function()
            ShootGunEvent:FireServer(TargetPosition)
        end)
        self.ShootDebounce = tick()
        return
    end
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    self.ShootDebounce = tick()
end

function FastAttack:GetCombo()
    if not self.M1Combo then self.M1Combo = 0 end
    return self.M1Combo
end

function FastAttack:Attack()
    if not AttackConfig.AutoClickEnabled or (tick() - self.Debounce) < AttackConfig.AttackCooldown then
        return
    end
    local Character = Player.Character
    if not Character or not self:IsEntityAlive(Character) then
        return
    end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Equipped = Character:FindFirstChildOfClass("Tool")
    if not Equipped then
        return
    end
    local ToolTip = Equipped.ToolTip
    if not table.find({"Melee", "Blox Fruit", "Sword", "Gun"}, ToolTip) then
        return
    end
    local Cooldown = Equipped:FindFirstChild("Cooldown") and Equipped.Cooldown.Value or AttackConfig.AttackCooldown
    if not self:CheckStun(Character, Humanoid, ToolTip) then
        return
    end
    local Combo = self:GetCombo()
    Cooldown = Cooldown + (Combo >= AttackConfig.MaxCombo and 0.05 or 0)
    self.Debounce = Combo >= AttackConfig.MaxCombo and ToolTip ~= "Gun" and (tick() + 0.05) or tick()

    if ToolTip == "Blox Fruit" and Equipped:FindFirstChild("LeftClickRemote") then
        self:UseFruitM1(Character, Equipped, Combo)
    elseif ToolTip == "Gun" then
        local Target = self:GetClosestEnemy(Character, 120)
        if Target then
            self:ShootInTarget(Target.Position)
        end
    else
        self:UseNormalClick(Character, Humanoid, Cooldown)
    end
end

local AttackInstance = FastAttack.new()

table.insert(AttackInstance.Connections, RunService.Stepped:Connect(function()
end))

pcall(function()
    for _, v in pairs(getgc and getgc(true) or {}) do
        if typeof(v) == "function" and iscclosure and iscclosure(v) then
            local info = debug.getinfo(v)
            local name = info and info.name
            if name == "Attack" or name == "attack" or name == "RegisterHit" then
                if hookfunction then
                    local ok, err = pcall(function()
                        hookfunction(v, function(...)
                            pcall(function() AttackInstance:Attack() end)
                            return v(...)
                        end)
                    end)
                    if not ok then
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(AttackConfig.AttackCooldown) do
        pcall(function()
            if FastAttackSpeed then
                AttackInstance:Attack()
            end
        end)
    end
end)

spawn(function()
    if ReplicatedStorage.MapStash:FindFirstChild("Temple of Time") then
        ReplicatedStorage.MapStash["Temple of Time"].Parent = game.Workspace.Map
    end
end)

spawn(function()
    pcall(function()
        game:GetService("RunService").Stepped:Connect(function()
            if _G.Clip then
                if not Player.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                    local Noclip = Instance.new("BodyVelocity")
                    Noclip.Name = "BodyClip"
                    Noclip.Parent = Player.Character.HumanoidRootPart
                    Noclip.MaxForce = Vector3.new(100000,100000,100000)
                    Noclip.Velocity = Vector3.new(0,0,0)
                end
            else	
                if Player.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                    Player.Character.HumanoidRootPart:FindFirstChild("BodyClip"):Destroy()
                end
            end
        end)
    end)
end)

spawn(function()
    pcall(function()
        game:GetService("RunService").Stepped:Connect(function()
            if _G.Clip then
                for i,v in pairs(Player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            else
                Player.Character.HumanoidRootPart.CanCollide = true
            end
        end)
    end)
end)

local RaceV3tbl = {
    "Last Resort",
    "Agility",
    "Water Body",
    "Heavenly Blood",
    "Heightened Senses",
    "Energy Core",
    "Primordial Reign"
}

--[[spawn(function()
    pcall(function()
        while task.wait() do
            UpdateData()
            if HelperRole then
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if table.find(Head, player.Name) then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            for _2,race in RaceV3tbl do
                                if player.Character.HumanoidRootPart:FindFirstChild(race) and player.Character.HumanoidRootPart:FindFirstChild(race):IsA("ParticleEmitter") then
                                    if Player.Character then
                                        ActiveRaceV3()
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end)]]

spawn(function()
    pcall(function()
        while task.wait(0.1) do
            if LockCameraToMoon then
                local moonDir = game.Lighting:GetMoonDirection()
                local lookAtPos = Workspace.CurrentCamera.CFrame.p + moonDir * 100
                Workspace.CurrentCamera.CFrame = CFrame.lookAt(Workspace.CurrentCamera.CFrame.p, lookAtPos)
            end
        end
    end)
end)

function CheckTime()
    if game.Lighting.ClockTime >= 17.816 and game.Lighting.ClockTime <= 23.999 then
        return true
    elseif game.Lighting.ClockTime >= 0.000 and game.Lighting.ClockTime <= 5.000 then
        return true
    else
        return false
    end
end

spawn(function()
    pcall(function()
        while task.wait(0.3) do
            local CheckLever = Remotes:WaitForChild("CommF_"):InvokeServer("CheckTempleDoor")
            local CheckQuestLever = Remotes:WaitForChild("CommF_"):InvokeServer("RaceV4Progress","Check")
            if CheckLever == false then
                if CheckQuestLever == 4 then
                    if game:GetService("Workspace").Map:FindFirstChild("MysticIsland") then
                        local value, BlueGear = CheckBlueGear()
                        if value == true then
                            repeat wait()
                                StartTween(BlueGear)
                                Player.CameraMaxZoomDistance = 200
                                LockCameraToMoon = false
                            until CheckBlueGear() == nil or not Player.Character or not game.Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island") or not game:GetService("Workspace").Map:FindFirstChild("MysticIsland")
                        else
                            if CheckTime() == true and game:GetService("Workspace").Map:FindFirstChild("MysticIsland") and inRange(Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island").CFrame * CFrame.new(0,600,0), 10) then
                                Player.CameraMaxZoomDistance = 0.5
                                LockCameraToMoon = true
                                task.wait(0.2)
                                ActiveRaceV3()
                            end
                            StartTween(Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island").CFrame * CFrame.new(0,600,0))
                            if not game:GetService("Workspace").Map:FindFirstChild("MysticIsland") then
                                StartTween("Stop")
                            end
                        end
                    else
                        if game.Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island") then
                            repeat wait()
                                StartTween(Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island").CFrame * CFrame.new(0,600,0))
                            until not game.Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island") or not Player.Character or game:GetService("Workspace").Map:FindFirstChild("MysticIsland")
                            StartTween("Stop")
                        else
                            Player.CameraMaxZoomDistance = 200
                            LockCameraToMoon = false
                        end
                    end
                elseif CheckQuestLever == 3 then
                    Remotes:WaitForChild("CommF_"):InvokeServer("RaceV4Progress","Continue")
                elseif CheckQuestLever == 2 then
                    if inRange(CFrame.new(3032, 2281, -7324), 5) then
                        Remotes:WaitForChild("CommF_"):InvokeServer("RaceV4Progress","Teleport")
                    else
                        if not inRange(CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875), 1000) then
                            repeat wait() 
                                Player.Character:SetPrimaryPartCFrame(CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875)) 
                            until inRange(CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875), 1000)
                        else
                            if inRange(CFrame.new(28609, 14897, 106), 2) then
                                Remotes:WaitForChild("CommF_"):InvokeServer("RaceV4Progress","TeleportBack")
                            else
                                repeat wait()
                                    StartTween(CFrame.new(28609, 14897, 106))
                                until inRange(CFrame.new(28609, 14897, 106), 2)
                            end
                        end
                    end
                elseif CheckQuestLever == 1 then
                    Remotes:WaitForChild("CommF_"):InvokeServer("RaceV4Progress","Begin")
                end
            end
        end
    end)
end)

--[[
local AncientOneStatus, tier = Remotes:WaitForChild("CommF_"):InvokeServer("UpgradeRace","Check")
local AncientOneStatus, tier = game.ReplicatedStorage.Remotes:WaitForChild("CommF_"):InvokeServer("UpgradeRace","Check")
print(tier)]]

local RaidTimer = Player.PlayerGui.Main.TopHUDList.RaidTimer

spawn(function()
    pcall(function()
        while task.wait() do
            if UseSkill then
                local Char = SafeCharacter()
                for i,v in pairs(Player.Backpack:GetChildren()) do
                    if v:IsA("Tool") then
                        if v.ToolTip == "Melee" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
                            Char.Humanoid:EquipTool(v)
                        end
                    end
                end
                VirtualInputManager:SendKeyEvent(true,122,false,Char.HumanoidRootPart)
                VirtualInputManager:SendKeyEvent(false,122,false,Char.HumanoidRootPart)
                wait(.3)
                VirtualInputManager:SendKeyEvent(true,120,false,Char.HumanoidRootPart)
                VirtualInputManager:SendKeyEvent(false,120,false,Char.HumanoidRootPart)
                wait(.3)
                VirtualInputManager:SendKeyEvent(true,99,false,Char.HumanoidRootPart)
                VirtualInputManager:SendKeyEvent(false,99,false,Char.HumanoidRootPart)
                wait(0.5)
                for i,v in pairs(Player.Backpack:GetChildren()) do
                    if v:IsA("Tool") then
                        if v.ToolTip == "Blox Fruit" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
                            Char.Humanoid:EquipTool(v)
                        end
                    end
                end
                VirtualInputManager:SendKeyEvent(true,122,false,Char.HumanoidRootPart)
                VirtualInputManager:SendKeyEvent(false,122,false,Char.HumanoidRootPart)
                wait(.3)
                VirtualInputManager:SendKeyEvent(true,120,false,Char.HumanoidRootPart)
                VirtualInputManager:SendKeyEvent(false,120,false,Char.HumanoidRootPart)
                wait(.3)
                VirtualInputManager:SendKeyEvent(true,99,false,Char.HumanoidRootPart)
                VirtualInputManager:SendKeyEvent(false,99,false,Char.HumanoidRootPart)
                wait(0.5)
                for i,v in pairs(Player.Backpack:GetChildren()) do
                    if v:IsA("Tool") then
                        if v.ToolTip == "Sword" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
                            Char.Humanoid:EquipTool(v)
                        end
                    end
                end
                VirtualInputManager:SendKeyEvent(true,122,false,Char.HumanoidRootPart)
                VirtualInputManager:SendKeyEvent(false,122,false,Char.HumanoidRootPart)
                wait(.3)
                VirtualInputManager:SendKeyEvent(true,120,false,Char.HumanoidRootPart)
                VirtualInputManager:SendKeyEvent(false,120,false,Char.HumanoidRootPart)
                wait(0.5)
            end
        end
    end)
end)

spawn(function()
    local success, err = pcall(function()
        while task.wait(0.3) do
            Char = SafeCharacter()
            local CheckLever = Remotes:WaitForChild("CommF_"):InvokeServer("CheckTempleDoor")
            if AutoCompleteTrial and Char and CheckLever then
                local PlayerRace = Player.Data.Race.Value
                if inRange(CFrame.new(28746.4296875, 14887.5615234375, -94.38116455078125), 200) and Workspace.Map["Temple of Time"].FFABorder.Forcefield.Transparency ~= 1 and AutoResetCharacter then
                    if Char:FindFirstChild("Head") then
                        Char:FindFirstChild("Head"):Destroy()
                    end
                    Char = SafeCharacter()
                end
                if RaidTimer.Visible == true and Char then
                    if not inRange(TempleofTime, 1000) then
                        if PlayerRace == "Human" then
                            for i,v in ipairs(Enemies:GetChildren()) do
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and inRange(v.HumanoidRootPart, 1000) then
                                    repeat wait(.1)
                                        AutoHaki()
                                        EquipWeapon()
                                        FastAttackSpeed = true
                                        StartTween(v.HumanoidRootPart.CFrame * CFrame.new(0,50,0))
                                        sethiddenproperty(Player, "SimulationRadius", math.huge)
                                    until not AutoCompleteTrial or not Char or not v.Parent or v.Humanoid.Health <= 0 or not v:FindFirstChild("Humanoid") or RaidTimer.Visible == false
                                    FastAttackSpeed = false
                                end
                                if not AutoCompleteTrial or not Char or RaidTimer.Visible == false then
                                    break
                                end
                            end
                        elseif PlayerRace == "Skypiea" then
                            if game:GetService("Workspace").Map.SkyTrial.Model:FindFirstChild("FinishPart") then
                                Char:SetPrimaryPartCFrame(game:GetService("Workspace").Map.SkyTrial.Model.FinishPart.CFrame)
                                if not success then
                                    warn("Error:", err)
                                end
                            end
                        elseif PlayerRace == "Fishman" then
                            for i,v in pairs(game:GetService("Workspace").SeaBeasts.SeaBeast1:GetDescendants()) do
                                if v.Name ==  "HumanoidRootPart" and inRange(v, 1000) then
                                    repeat wait()
                                        StartTween(v.CFrame * CFrame.new(0,300,50))
                                        AimBotSkillPosition = v.Position
                                        UseSkill = true
                                    until not AutoCompleteTrial or not Char or v == nil or RaidTimer.Visible == false
                                    UseSkill = false
                                end
                                if not AutoCompleteTrial or not Char or RaidTimer.Visible == false then
                                    break
                                end
                            end
                        elseif PlayerRace == "Cyborg" then
                            if not inRange(TempleofTime, 1000) or RaidTimer.Visible == false then
                                Char:SetPrimaryPartCFrame(CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875))
                            end
                        elseif PlayerRace == "Ghoul" then
                            for i,v in pairs(Enemies:GetChildren()) do
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and inRange(v.HumanoidRootPart, 1000) then
                                    repeat wait(.1)
                                        AutoHaki()
                                        EquipWeapon()
                                        FastAttackSpeed = true
                                        StartTween(v.HumanoidRootPart.CFrame * CFrame.new(0,50,0))
                                        sethiddenproperty(Player, "SimulationRadius", math.huge)
                                    until not AutoCompleteTrial or not Char or not v.Parent or v.Humanoid.Health <= 0 or RaidTimer.Visible == false
                                    FastAttackSpeed = false
                                end
                                if not AutoCompleteTrial or not Char or RaidTimer.Visible == false then
                                    break
                                end
                            end
                        elseif PlayerRace == "Mink" then
                            for i,v in pairs(Workspace:GetDescendants()) do
                                if v.Name == "StartPoint" then
                                    Char:SetPrimaryPartCFrame(v.CFrame)
                                    if inRange(TempleofTime, 1000) or RaidTimer.Visible == false then
                                        break
                                    end
                                end
                            end
                        end
                    end
                else
                    if inRange(TempleofTime, 1000) then
                        if PlayerRace == "Human" then
                            StartTween(CFrame.new(29231.283203125, 14890.9755859375, -205.39077758789062))
                        elseif PlayerRace == "Fishman" then           
                            StartTween(CFrame.new(28228.47265625, 14890.978515625, -212.1103515625))
                        elseif PlayerRace == "Cyborg" then
                            StartTween(CFrame.new(28496.66015625, 14895.9755859375, -422.5971374511719))
                        elseif PlayerRace == "Ghoul" then
                            StartTween(CFrame.new(28673.232421875, 14890.359375, 454.6542663574219))
                        elseif PlayerRace == "Skypiea" then
                            StartTween(CFrame.new(28962.220703125, 14919.6240234375, 234.61563110351562))
                        elseif PlayerRace == "Mink" then
                            StartTween(CFrame.new(29014.6171875, 14890.9755859375, -378.9480285644531))
                        end
                    else
                        Char:SetPrimaryPartCFrame(CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875))
                    end
                end
            end
        end
    end)
end)

spawn(function()
    pcall(function()
        while task.wait(0.3) do
            if SpendPoint then
                local PlayerRace = Player.Data.Race.Value
                local GearCheck = Remotes:WaitForChild("CommF_"):InvokeServer("TempleClock","Check")
                if inRange(TempleofTime, 1000) then
                    if PlayerRace == "Human" then
                        StartTween(CFrame.new(29231.283203125, 14890.9755859375, -205.39077758789062))
                    elseif PlayerRace == "Fishman" then           
                        StartTween(CFrame.new(28228.47265625, 14890.978515625, -212.1103515625))
                    elseif PlayerRace == "Cyborg" then
                        StartTween(CFrame.new(28496.66015625, 14895.9755859375, -422.5971374511719))
                    elseif PlayerRace == "Ghoul" then
                        StartTween(CFrame.new(28673.232421875, 14890.359375, 454.6542663574219))
                    elseif PlayerRace == "Skypiea" then
                        StartTween(CFrame.new(28962.220703125, 14919.6240234375, 234.61563110351562))
                    elseif PlayerRace == "Mink" then
                        StartTween(CFrame.new(29014.6171875, 14890.9755859375, -378.9480285644531))
                    end

                    if GearCheck ~= nil then
                        if #GearCheck.RaceDetails.Gears == 0 and GearCheck.RaceDetails.C == 0 then -- Gear 1
                            Remotes:WaitForChild("CommF_"):InvokeServer("TempleClock","SpendPoint")
                        elseif #GearCheck.RaceDetails.Gears == 0 then -- Gear 2
                            Remotes:WaitForChild("CommF_"):InvokeServer("TempleClock","SpendPoint","Gear2","Alpha")
                            Remotes:WaitForChild("CommF_"):InvokeServer("TempleClock","SpendPoint","Gear2","Omega")
                        elseif #GearCheck.RaceDetails.Gears == 1 then
                            Remotes:WaitForChild("CommF_"):InvokeServer("TempleClock","SpendPoint","Gear3","Omega")
                            Remotes:WaitForChild("CommF_"):InvokeServer("TempleClock","SpendPoint","Gear3","Alpha")
                        elseif #GearCheck.RaceDetails.Gears == 2 then
                            Remotes:WaitForChild("CommF_"):InvokeServer("TempleClock","SpendPoint","Gear4","Alpha")
                            Remotes:WaitForChild("CommF_"):InvokeServer("TempleClock","SpendPoint","Gear4","Omega")
                        end
                    end

                else
                    Player.Character:SetPrimaryPartCFrame(CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875))
                end
            end
        end
    end)
end)

SwtichCake = false

spawn(function()
    local success, err = pcall(function()
        while task.wait(0.3) do
            local Char = SafeCharacter()
            if AutoAncientOneQuest and Player.Character and SwtichCake == true then
                if Enemies:FindFirstChild("Baking Staff") or Enemies:FindFirstChild("Head Baker") or Enemies:FindFirstChild("Cake Guard") or Enemies:FindFirstChild("Cookie Crafter") then
                    for i,v in pairs(Enemies:GetChildren()) do
                        if v.Name == "Baking Staff" or v.Name == "Head Baker" or v.Name == "Cake Guard" or v.Name == "Cookie Crafter" then
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and Player.Character then
                                if Player.Character then
                                    repeat wait()
                                        AutoHaki()
                                        EquipWeapon()
                                        FastAttackSpeed = true
                                        AncientOneMon = v.HumanoidRootPart.CFrame
                                        AncientOneMonName = v.Name
                                        AncientOneMonHealth = v.Humanoid.Health
                                        spawn(function()
                                            if AncientOneMonHealth == v.Humanoid.Health and AncientOneMonHealth ~= nil and inRange(AncientOneMon, 120) then
                                                task.wait(3)
                                                if AncientOneMonHealth == v.Humanoid.Health and inRange(AncientOneMon, 120) then
                                                    stoploop = true
                                                end
                                            end
                                        end)
                                        StartTween(v.HumanoidRootPart.CFrame * CFrame.new(0,50,0))
                                    until stoploop or not AutoAncientOneQuest or not Char or not v.Parent or v.Humanoid.Health <= 0 or not v:FindFirstChild("HumanoidRootPart") or SwtichCake == false
                                end
                                FastAttackSpeed = false
                                stoploop = false
                            end
                            if not AutoAncientOneQuest or not Char or SwtichCake == false then
                                StartTween("Stop")
                                break
                            end
                        end
                    end
                else
                    if inRange(CFrame.new(-12471.169921875, 374.94024658203, -7551.677734375), 13000) then
                        StartTween(CFrame.new(-1820.0634765625, 210.74781799316406, -12297.49609375))
                        if not AutoAncientOneQuest or not Char or SwtichCake == false then
                            StartTween("Stop")
                        end
                    else
                        Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375))
                        task.wait(0.5)
                    end
                end
            end
        end
    end)
end)

spawn(function()
    local success, err = pcall(function()
        while task.wait(0.3) do
            local Char = SafeCharacter()
            if AutoAncientOneQuest and Player.Character and SwtichCake == false then
                if Enemies:FindFirstChild("Reborn Skeleton") or Enemies:FindFirstChild("Living Zombie") or Enemies:FindFirstChild("Domenic Soul") or Enemies:FindFirstChild("Posessed Mummy") then
                    for i,v in pairs(Enemies:GetChildren()) do
                        if v.Name == "Reborn Skeleton" or v.Name == "Living Zombie" or v.Name == "Demonic Soul" or v.Name == "Posessed Mummy" then
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and Player.Character then
                                if Player.Character then
                                    repeat wait()
                                        AutoHaki()
                                        EquipWeapon()
                                        FastAttackSpeed = true
                                        AncientOneMon = v.HumanoidRootPart.CFrame
                                        AncientOneMonName = v.Name
                                        AncientOneMonHealth = v.Humanoid.Health
                                        spawn(function()
                                            if AncientOneMonHealth == v.Humanoid.Health and AncientOneMonHealth ~= nil and inRange(AncientOneMon, 120) then
                                                task.wait(3)
                                                if AncientOneMonHealth == v.Humanoid.Health and inRange(AncientOneMon, 120) then
                                                    stoploop = true
                                                end
                                            end
                                            if not success then
                                                warn("Error:", err)
                                            end
                                        end)
                                        StartTween(v.HumanoidRootPart.CFrame * CFrame.new(0,50,0))
                                    until stoploop or not AutoAncientOneQuest or not Char or not v.Parent or v.Humanoid.Health <= 0 or not v:FindFirstChild("HumanoidRootPart") or SwtichCake == true
                                end
                                FastAttackSpeed = false
                                stoploop = false
                            end
                            if not AutoAncientOneQuest or not Char or SwtichCake == true then
                                StartTween("Stop")
                                break
                            end
                        end
                    end
                else
                    if inRange(CFrame.new(-9501, 580, 6033), 11000) then
                        StartTween(CFrame.new(-9513.0771484375, 142.13059997558594, 5535.80859375))
                        if not AutoAncientOneQuest or not Char or SwtichCake == true then
                            StartTween("Stop")
                        end
                    else
                        Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-5056, 314, -3182))
                        task.wait(0.5)
                    end
                end
            end
        end
    end)
end)

function BringMon(mon, oldCFrame, newCFrame)
    if AutoAncientOneQuest then
        repeat task.wait(0.3)
            if mon:FindFirstChild("Humanoid") and mon:FindFirstChild("HumanoidRootPart") and mon:FindFirstChild("Humanoid").Health > 0 then
                mon:SetPrimaryPartCFrame(newCFrame)
                task.wait(3)
                mon:SetPrimaryPartCFrame(oldCFrame)
            end
        until not AutoAncientOneQuest or not mon:FindFirstChild("Humanoid") or not mon:FindFirstChild("HumanoidRootPart") or mon:FindFirstChild("Humanoid").Health <= 0
    end
end

spawn(function()
    while task.wait(0.3) do
        pcall(function()
            local AncientOneStatus, tier = Remotes:WaitForChild("CommF_"):InvokeServer("UpgradeRace","Check")
            for i,v in pairs(Enemies:GetChildren()) do
                if AutoAncientOneQuest and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and ((v.Name == "Reborn Skeleton" or v.Name == "Living Zombie" or v.Name == "Demonic Soul" or v.Name == "Posessed Mummy") or (v.Name == "Cookie Crafter" or v.Name == "Cake Guard" or v.Name == "Baking Staff" or v.Name == "Head Baker")) and (v.HumanoidRootPart.Position - AncientOneMon.Position).magnitude <= 350 and inRange(AncientOneMon, 120) then
                    if AncientOneMonName == v.Name and v ~= AncientOneMon then
                        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid").Health > 0 then
                            --coroutine.wrap(BringMon)(v, v.HumanoidRootPart.CFrame, AncientOneMon)
                            v:SetPrimaryPartCFrame(AncientOneMon)
                            sethiddenproperty(Player,"SimulationRadius",math.huge)
                        end
                    end
                end
            end
        end)
    end
end)

function ToggleFunction(func)
    if checkTier() then
        if func == "AutoCompleteTrial" then
            AutoCompleteTrial = true
            SpendPoint = false
            AutoAncientOneQuest = false
        elseif func == "SpendPoint" then
            AutoCompleteTrial = false
            SpendPoint = true
            AutoAncientOneQuest = false
        elseif func == "AutoAncientOneQuest" then
            AutoCompleteTrial = false
            SpendPoint = false
            AutoAncientOneQuest = true
        end
    end
end

spawn(function()
    while task.wait(0.2) do
        if not checkTier() then
            AutoCompleteTrial = false
            SpendPoint = false
            AutoAncientOneQuest = false
        end
    end
end)

function checkStairs()
    local AncientOneStatus, tier = Remotes:WaitForChild("CommF_"):InvokeServer("UpgradeRace","Check")
    local GearCheck = Remotes:WaitForChild("CommF_"):InvokeServer("TempleClock","Check")
    if tier >= 5 then
        if Workspace._WorldOrigin.LightingZones.TempleOfTimeStairs:GetAttribute("Disabled") == true and (GearCheck ~= nil and (GearCheck.HadPoint ~= nil or GearCheck.HadPoint == true)  and #GearCheck.RaceDetails.Gears == 3) then
            return false
        elseif Workspace._WorldOrigin.LightingZones.TempleOfTimeStairs:GetAttribute("Disabled") == true and (GearCheck == nil or (GearCheck ~= nil and (GearCheck.HadPoint == nil)) and #GearCheck.RaceDetails.Gears == 3) then
            return true
        elseif Workspace._WorldOrigin.LightingZones.TempleOfTimeStairs:GetAttribute("Disabled") == false then
            return true
        end
    end
end

function checkTier()
    local AncientOneStatus, tier = Remotes:WaitForChild("CommF_"):InvokeServer("UpgradeRace","Check")
    if tier == nil then return true end
    if tier < TierLock then
        return true
    elseif tier >= 5 then
        if checkStairs() then
            return true
        else
            return false
        end
    else
        return false
    end
end

spawn(function()
    pcall(function()
        while task.wait() do
            if checkTier() then
                local GearCheck = Remotes:WaitForChild("CommF_"):InvokeServer("TempleClock","Check")
                local AncientOneStatus, tier = Remotes:WaitForChild("CommF_"):InvokeServer("UpgradeRace","Check")
                if (GearCheck ~= nil and (GearCheck.HadPoint ~= nil or GearCheck.HadPoint == true)) and #GearCheck.RaceDetails.Gears ~= 3 then
                    ToggleFunction("SpendPoint")
                elseif (AncientOneStatus == 0 or AncientOneStatus == nil) or checkStairs() then
                    ToggleFunction("AutoCompleteTrial")
                elseif AncientOneStatus ~= 0 then
                    ToggleFunction("AutoAncientOneQuest")
                end
            end
        end
    end)
end)

spawn(function()
    pcall(function()
        while task.wait(1) do
            local AncientOneStatus, tier = Remotes:WaitForChild("CommF_"):InvokeServer("UpgradeRace","Check")
            if AncientOneStatus ~= 0 then
                VirtualInputManager:SendKeyEvent(true,"Y",false,game)
				wait(0.1)
                VirtualInputManager:SendKeyEvent(false,"Y",false,game)
                Remotes.CommF_:InvokeServer("UpgradeRace","Buy")
            end
        end
    end)
end)

local old; old = hookmetamethod(game, "__namecall", function(self, ...)
	local args = {...}
	local method = getnamecallmethod():lower()
	if not  checkcaller() and method == "fireserver" and tostring(self) == "RemoteEvent" then
        --if tostring(args[1]) ~= "true" and tostring(args[1]) ~= "false" then
            if UseSkill then
                if AimBotSkillPosition ~= nil then
                    args[1] = AimBotSkillPosition
                    return old(self,unpack(args))
                end
            end
        --end
    end
    return old(self,...)
end)

local G2L = {};

-- StarterGui.SixMa
G2L["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["Name"] = [[SixMa]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;


-- StarterGui.SixMa.MainFrame
G2L["2"] = Instance.new("Frame", G2L["1"]);
G2L["2"]["ZIndex"] = 111;
G2L["2"]["BorderSizePixel"] = 0;
G2L["2"]["BackgroundColor3"] = Color3.fromRGB(14, 14, 14);
G2L["2"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["2"]["Size"] = UDim2.new(0.30341, 0, 0.3423, 0);
G2L["2"]["Position"] = UDim2.new(0.18421, 0, 0.41769, 0);
G2L["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["2"]["Name"] = [[MainFrame]];


-- StarterGui.SixMa.MainFrame.UICorner
G2L["3"] = Instance.new("UICorner", G2L["2"]);



-- StarterGui.SixMa.MainFrame.Role
G2L["4"] = Instance.new("TextLabel", G2L["2"]);
G2L["4"]["TextWrapped"] = true;
G2L["4"]["BorderSizePixel"] = 0;
G2L["4"]["TextSize"] = 33;
G2L["4"]["TextScaled"] = true;
G2L["4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["4"]["TextColor3"] = Color3.fromRGB(240, 240, 240);
G2L["4"]["BackgroundTransparency"] = 1;
G2L["4"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["4"]["Size"] = UDim2.new(0.80152, 0, 0.1618, 0);
G2L["4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4"]["Text"] = [[Role: N/A]];
G2L["4"]["Name"] = [[Role]];
G2L["4"]["Position"] = UDim2.new(0.4921, 0, 0.49816, 0);


-- StarterGui.SixMa.MainFrame.Tier
G2L["5"] = Instance.new("TextLabel", G2L["2"]);
G2L["5"]["TextWrapped"] = true;
G2L["5"]["BorderSizePixel"] = 0;
G2L["5"]["TextSize"] = 33;
G2L["5"]["TextScaled"] = true;
G2L["5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["5"]["TextColor3"] = Color3.fromRGB(240, 240, 240);
G2L["5"]["BackgroundTransparency"] = 1;
G2L["5"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["5"]["Size"] = UDim2.new(0.80152, 0, 0.1618, 0);
G2L["5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5"]["Text"] = [[Tier: N/A]];
G2L["5"]["Name"] = [[Tier]];
G2L["5"]["Position"] = UDim2.new(0.49465, 0, 0.69456, 0);


-- StarterGui.SixMa.MainFrame.UIStroke
G2L["6"] = Instance.new("UIStroke", G2L["2"]);
G2L["6"]["Thickness"] = 6.3;
G2L["6"]["Color"] = Color3.fromRGB(237, 237, 237);


-- StarterGui.SixMa.MainFrame.Time
G2L["7"] = Instance.new("TextLabel", G2L["2"]);
G2L["7"]["TextWrapped"] = true;
G2L["7"]["BorderSizePixel"] = 0;
G2L["7"]["TextSize"] = 33;
G2L["7"]["TextScaled"] = true;
G2L["7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["7"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["7"]["TextColor3"] = Color3.fromRGB(240, 240, 240);
G2L["7"]["BackgroundTransparency"] = 1;
G2L["7"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["7"]["Size"] = UDim2.new(0.80152, 0, 0.1618, 0);
G2L["7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["7"]["Text"] = [[Time: N/A]];
G2L["7"]["Name"] = [[Time]];
G2L["7"]["Position"] = UDim2.new(0.4921, 0, 0.30695, 0);


-- StarterGui.SixMa.MainFrame.UIAspectRatioConstraint
G2L["8"] = Instance.new("UIAspectRatioConstraint", G2L["2"]);
G2L["8"]["AspectRatio"] = 1.40688;


-- StarterGui.SixMa.FunctionFrame
G2L["9"] = Instance.new("Frame", G2L["1"]);
G2L["9"]["ZIndex"] = 0;
G2L["9"]["BorderSizePixel"] = 0;
G2L["9"]["BackgroundColor3"] = Color3.fromRGB(19, 19, 19);
G2L["9"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["9"]["Size"] = UDim2.new(0.28947, 0, 0.24816, 0);
G2L["9"]["Position"] = UDim2.new(0.18395, 0, 0.71268, 0);
G2L["9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["9"]["Name"] = [[FunctionFrame]];


-- StarterGui.SixMa.FunctionFrame.UICorner
G2L["a"] = Instance.new("UICorner", G2L["9"]);



-- StarterGui.SixMa.FunctionFrame.UIStroke
G2L["b"] = Instance.new("UIStroke", G2L["9"]);
G2L["b"]["Thickness"] = 6.3;
G2L["b"]["Color"] = Color3.fromRGB(237, 237, 237);


-- StarterGui.SixMa.FunctionFrame.Head Role
G2L["c"] = Instance.new("TextLabel", G2L["9"]);
G2L["c"]["TextWrapped"] = true;
G2L["c"]["BorderSizePixel"] = 0;
G2L["c"]["TextSize"] = 33;
G2L["c"]["TextScaled"] = true;
G2L["c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["c"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["c"]["TextColor3"] = Color3.fromRGB(240, 240, 240);
G2L["c"]["BackgroundTransparency"] = 1;
G2L["c"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["c"]["Size"] = UDim2.new(0.47004, 0, 0.1328, 0);
G2L["c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["c"]["Text"] = [[Head Role]];
G2L["c"]["Name"] = [[Head Role]];
G2L["c"]["Position"] = UDim2.new(0.29697, 0, 0.17084, 0);


-- StarterGui.SixMa.FunctionFrame.Head Role.TextButton
G2L["d"] = Instance.new("TextButton", G2L["c"]);
G2L["d"]["TextWrapped"] = true;
G2L["d"]["BorderSizePixel"] = 0;
G2L["d"]["TextSize"] = 14;
G2L["d"]["TextScaled"] = true;
G2L["d"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["d"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["d"]["Size"] = UDim2.new(0.58591, 0, 0.89468, 0);
G2L["d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["d"]["Text"] = [[Click!]];
G2L["d"]["Position"] = UDim2.new(1.18066, 0, 0.10447, 0);


-- StarterGui.SixMa.FunctionFrame.Head Role.TextButton.UICorner
G2L["e"] = Instance.new("UICorner", G2L["d"]);



-- StarterGui.SixMa.FunctionFrame.Server Hop
G2L["f"] = Instance.new("TextLabel", G2L["9"]);
G2L["f"]["TextWrapped"] = true;
G2L["f"]["BorderSizePixel"] = 0;
G2L["f"]["TextSize"] = 33;
G2L["f"]["TextScaled"] = true;
G2L["f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["f"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["f"]["TextColor3"] = Color3.fromRGB(240, 240, 240);
G2L["f"]["BackgroundTransparency"] = 1;
G2L["f"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["f"]["Size"] = UDim2.new(0.47004, 0, 0.1328, 0);
G2L["f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["f"]["Text"] = [[Server Hop]];
G2L["f"]["Name"] = [[Server Hop]];
G2L["f"]["Position"] = UDim2.new(0.29697, 0, 0.39361, 0);


-- StarterGui.SixMa.FunctionFrame.Server Hop.TextButton
G2L["10"] = Instance.new("TextButton", G2L["f"]);
G2L["10"]["TextWrapped"] = true;
G2L["10"]["BorderSizePixel"] = 0;
G2L["10"]["TextSize"] = 14;
G2L["10"]["TextScaled"] = true;
G2L["10"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["10"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["10"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["10"]["Size"] = UDim2.new(0.58591, 0, 0.89468, 0);
G2L["10"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["10"]["Text"] = [[Click!]];
G2L["10"]["Position"] = UDim2.new(1.18066, 0, 0.10447, 0);


-- StarterGui.SixMa.FunctionFrame.Server Hop.TextButton.UICorner
G2L["11"] = Instance.new("UICorner", G2L["10"]);



-- StarterGui.SixMa.FunctionFrame.UIAspectRatioConstraint
G2L["12"] = Instance.new("UIAspectRatioConstraint", G2L["9"]);
G2L["12"]["AspectRatio"] = 1.85149;


-- StarterGui.SixMa.FunctionFrame.Join Head Server
G2L["13"] = Instance.new("TextLabel", G2L["9"]);
G2L["13"]["TextWrapped"] = true;
G2L["13"]["BorderSizePixel"] = 0;
G2L["13"]["TextSize"] = 33;
G2L["13"]["TextScaled"] = true;
G2L["13"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["13"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["13"]["TextColor3"] = Color3.fromRGB(240, 240, 240);
G2L["13"]["BackgroundTransparency"] = 1;
G2L["13"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["13"]["Size"] = UDim2.new(0.47004, 0, 0.1328, 0);
G2L["13"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["13"]["Text"] = [[Join Head Server]];
G2L["13"]["Name"] = [[Join Head Server]];
G2L["13"]["Position"] = UDim2.new(0.29697, 0, 0.61638, 0);


-- StarterGui.SixMa.FunctionFrame.Join Head Server.TextButton
G2L["14"] = Instance.new("TextButton", G2L["13"]);
G2L["14"]["TextWrapped"] = true;
G2L["14"]["BorderSizePixel"] = 0;
G2L["14"]["TextSize"] = 14;
G2L["14"]["TextScaled"] = true;
G2L["14"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["14"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["14"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["14"]["Size"] = UDim2.new(0.58591, 0, 0.89468, 0);
G2L["14"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["14"]["Text"] = [[Click!]];
G2L["14"]["Position"] = UDim2.new(1.18066, 0, 0.10447, 0);


-- StarterGui.SixMa.FunctionFrame.Join Head Server.TextButton.UICorner
G2L["15"] = Instance.new("UICorner", G2L["14"]);



-- StarterGui.SixMa.FunctionFrame.Set JobId
G2L["16"] = Instance.new("TextLabel", G2L["9"]);
G2L["16"]["TextWrapped"] = true;
G2L["16"]["BorderSizePixel"] = 0;
G2L["16"]["TextSize"] = 33;
G2L["16"]["TextScaled"] = true;
G2L["16"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["16"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["16"]["TextColor3"] = Color3.fromRGB(240, 240, 240);
G2L["16"]["BackgroundTransparency"] = 1;
G2L["16"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["16"]["Size"] = UDim2.new(0.47004, 0, 0.1328, 0);
G2L["16"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["16"]["Text"] = [[Set JobId]];
G2L["16"]["Name"] = [[Set JobId]];
G2L["16"]["Position"] = UDim2.new(0.29697, 0, 0.81935, 0);


-- StarterGui.SixMa.FunctionFrame.Set JobId.TextButton
G2L["17"] = Instance.new("TextButton", G2L["16"]);
G2L["17"]["TextWrapped"] = true;
G2L["17"]["BorderSizePixel"] = 0;
G2L["17"]["TextSize"] = 14;
G2L["17"]["TextScaled"] = true;
G2L["17"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["17"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["17"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["17"]["Size"] = UDim2.new(0.58591, 0, 0.89468, 0);
G2L["17"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["17"]["Text"] = [[Click!]];
G2L["17"]["Position"] = UDim2.new(1.18066, 0, 0.10447, 0);


-- StarterGui.SixMa.FunctionFrame.Set JobId.TextButton.UICorner
G2L["18"] = Instance.new("UICorner", G2L["17"]);



-- StarterGui.SixMa.Title
G2L["19"] = Instance.new("Frame", G2L["1"]);
G2L["19"]["BorderSizePixel"] = 0;
G2L["19"]["BackgroundColor3"] = Color3.fromRGB(19, 19, 19);
G2L["19"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["19"]["Size"] = UDim2.new(0.28947, 0, 0.10934, 0);
G2L["19"]["Position"] = UDim2.new(0.18318, 0, 0.22251, 0);
G2L["19"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["19"]["Name"] = [[Title]];


-- StarterGui.SixMa.Title.UICorner
G2L["1a"] = Instance.new("UICorner", G2L["19"]);
G2L["1a"]["CornerRadius"] = UDim.new(0, 30);


-- StarterGui.SixMa.Title.UIStroke
G2L["1b"] = Instance.new("UIStroke", G2L["19"]);
G2L["1b"]["Thickness"] = 6.3;
G2L["1b"]["Color"] = Color3.fromRGB(237, 237, 237);


-- StarterGui.SixMa.Title.Name
G2L["1c"] = Instance.new("TextLabel", G2L["19"]);
G2L["1c"]["TextWrapped"] = true;
G2L["1c"]["BorderSizePixel"] = 0;
G2L["1c"]["TextSize"] = 33;
G2L["1c"]["TextScaled"] = true;
G2L["1c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1c"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["1c"]["TextColor3"] = Color3.fromRGB(240, 240, 240);
G2L["1c"]["BackgroundTransparency"] = 1;
G2L["1c"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["1c"]["Size"] = UDim2.new(0.86309, 0, 0.38032, 0);
G2L["1c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1c"]["Text"] = [[Name: N/A]];
G2L["1c"]["Name"] = [[Name]];
G2L["1c"]["Position"] = UDim2.new(0.49884, 0, 0.34411, 0);


-- StarterGui.SixMa.Title.UIAspectRatioConstraint
G2L["1d"] = Instance.new("UIAspectRatioConstraint", G2L["19"]);
G2L["1d"]["AspectRatio"] = 4.20225;


-- StarterGui.SixMa.FunctionFrame2
G2L["1e"] = Instance.new("Frame", G2L["1"]);
G2L["1e"]["ZIndex"] = 0;
G2L["1e"]["BorderSizePixel"] = 0;
G2L["1e"]["BackgroundColor3"] = Color3.fromRGB(19, 19, 19);
G2L["1e"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["1e"]["Size"] = UDim2.new(0.28947, 0, 0.77273, 0);
G2L["1e"]["Position"] = UDim2.new(0.8403, 0, 0.48356, 0);
G2L["1e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1e"]["Name"] = [[FunctionFrame2]];


-- StarterGui.SixMa.FunctionFrame2.UICorner
G2L["1f"] = Instance.new("UICorner", G2L["1e"]);



-- StarterGui.SixMa.FunctionFrame2.UIStroke
G2L["20"] = Instance.new("UIStroke", G2L["1e"]);
G2L["20"]["Thickness"] = 6.3;
G2L["20"]["Color"] = Color3.fromRGB(237, 237, 237);


-- StarterGui.SixMa.FunctionFrame2.Go to 3rd Sea
G2L["21"] = Instance.new("TextLabel", G2L["1e"]);
G2L["21"]["TextWrapped"] = true;
G2L["21"]["BorderSizePixel"] = 0;
G2L["21"]["TextSize"] = 33;
G2L["21"]["TextScaled"] = true;
G2L["21"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["21"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["21"]["TextColor3"] = Color3.fromRGB(240, 240, 240);
G2L["21"]["BackgroundTransparency"] = 1;
G2L["21"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["21"]["Size"] = UDim2.new(0.47004, 0, 0.04218, 0);
G2L["21"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["21"]["Text"] = [[Go to 3rd Sea]];
G2L["21"]["Name"] = [[Go to 3rd Sea]];
G2L["21"]["Position"] = UDim2.new(0.32104, 0, 0.09055, 0);


-- StarterGui.SixMa.FunctionFrame2.Go to 3rd Sea.TextButton
G2L["22"] = Instance.new("TextButton", G2L["21"]);
G2L["22"]["TextWrapped"] = true;
G2L["22"]["BorderSizePixel"] = 0;
G2L["22"]["TextSize"] = 14;
G2L["22"]["TextScaled"] = true;
G2L["22"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["22"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["22"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["22"]["Size"] = UDim2.new(0.58591, 0, 0.89468, 0);
G2L["22"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["22"]["Text"] = [[Click!]];
G2L["22"]["Position"] = UDim2.new(1.18066, 0, 0.10447, 0);


-- StarterGui.SixMa.FunctionFrame2.Go to 3rd Sea.TextButton.UICorner
G2L["23"] = Instance.new("UICorner", G2L["22"]);



-- StarterGui.SixMa.FunctionFrame2.UIAspectRatioConstraint
G2L["24"] = Instance.new("UIAspectRatioConstraint", G2L["1e"]);
G2L["24"]["AspectRatio"] = 0.59459;


-- StarterGui.SixMa.FunctionFrame2.Switch to Cake
G2L["25"] = Instance.new("TextLabel", G2L["1e"]);
G2L["25"]["TextWrapped"] = true;
G2L["25"]["BorderSizePixel"] = 0;
G2L["25"]["TextSize"] = 33;
G2L["25"]["TextScaled"] = true;
G2L["25"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["25"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["25"]["TextColor3"] = Color3.fromRGB(240, 240, 240);
G2L["25"]["BackgroundTransparency"] = 1;
G2L["25"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["25"]["Size"] = UDim2.new(0.47004, 0, 0.04218, 0);
G2L["25"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["25"]["Text"] = [[Switch to Cake]];
G2L["25"]["Name"] = [[Switch to Cake]];
G2L["25"]["Position"] = UDim2.new(0.32104, 0, 0.16209, 0);


-- StarterGui.SixMa.FunctionFrame2.Switch to Cake.TextButton
G2L["26"] = Instance.new("TextButton", G2L["25"]);
G2L["26"]["TextWrapped"] = true;
G2L["26"]["BorderSizePixel"] = 0;
G2L["26"]["TextSize"] = 14;
G2L["26"]["TextScaled"] = true;
G2L["26"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["26"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["26"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["26"]["Size"] = UDim2.new(0.58591, 0, 0.89468, 0);
G2L["26"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["26"]["Text"] = [[Click!]];
G2L["26"]["Position"] = UDim2.new(1.18066, 0, 0.10447, 0);


-- StarterGui.SixMa.FunctionFrame2.Switch to Cake.TextButton.UICorner
G2L["27"] = Instance.new("UICorner", G2L["26"]);



-- StarterGui.SixMa.FunctionFrame2.Lock Tier
G2L["28"] = Instance.new("TextLabel", G2L["1e"]);
G2L["28"]["TextWrapped"] = true;
G2L["28"]["BorderSizePixel"] = 0;
G2L["28"]["TextSize"] = 33;
G2L["28"]["TextScaled"] = true;
G2L["28"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["28"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["28"]["TextColor3"] = Color3.fromRGB(240, 240, 240);
G2L["28"]["BackgroundTransparency"] = 1;
G2L["28"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["28"]["Size"] = UDim2.new(0.47004, 0, 0.04218, 0);
G2L["28"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["28"]["Text"] = [[Lock Tier]];
G2L["28"]["Name"] = [[Lock Tier]];
G2L["28"]["Position"] = UDim2.new(0.32104, 0, 0.23046, 0);


-- StarterGui.SixMa.FunctionFrame2.Lock Tier.TextBox
G2L["29"] = Instance.new("TextBox", G2L["28"]);
G2L["29"]["ClearTextOnFocus"] = false;
G2L["29"]["CursorPosition"] = -1;
G2L["29"]["BorderSizePixel"] = 0;
G2L["29"]["TextWrapped"] = true;
G2L["29"]["TextSize"] = 14;
G2L["29"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["29"]["TextScaled"] = true;
G2L["29"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["29"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["29"]["PlaceholderText"] = [[Input]];
G2L["29"]["Size"] = UDim2.new(0.586, 0, 0.905, 0);
G2L["29"]["Position"] = UDim2.new(1.178, 0, 0.075, 0);
G2L["29"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["29"]["Text"] = [[10]];


-- StarterGui.SixMa.FunctionFrame2.Lock Tier.TextBox.UICorner
G2L["2a"] = Instance.new("UICorner", G2L["29"]);

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
    spawn(function()
        while wait() do
            pcall(function()
                TPReturner()
                if foundAnything ~= "" then
                    TPReturner()
                end
            end)
        end
    end)
end

G2L["10"].Activated:Connect(function() -- Hop
    Teleport()
end)

G2L["d"].Activated:Connect(function() -- Head Role
    
end)

G2L["14"].Activated:Connect(function() -- Join Head
    --
end)

G2L["17"].Activated:Connect(function() -- Set JobId
    --
end)

G2L["22"].Activated:Connect(function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelZou")
end)

G2L["26"].Activated:Connect(function()
    if SwtichCake == false then 
        SwtichCake = true
    else
        SwtichCake = false
    end
end)

G2L["29"]:GetPropertyChangedSignal("Text"):Connect(function()
    if tonumber(G2L["29"].Text) ~= nil then
        TierLock = tonumber(G2L["29"].Text)
    end
end)

spawn(function()
    pcall(function()
        while task.wait(0.3) do
            G2L["1c"].Text = ("Name: "..Player.Name)
            G2L["7"].Text = ("Time: "..game.Lighting.TimeOfDay)
            G2L["4"].Text = ("Role: "..PlayerRole)
        end
    end)
end)


spawn(function()
    pcall(function()
        while task.wait(1) do
            local AncientOneStatus, tier = Remotes:WaitForChild("CommF_"):InvokeServer("UpgradeRace","Check")
            if tier ~= nil then
                G2L["5"].Text = ("Tier: "..tier)
            else tier == nil then
                G2L["5"].Text = ("Tier: N/A")
            end
        end
    end)
end)
