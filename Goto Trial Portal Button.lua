repeat wait() until game.Players
repeat wait() until game.Players.LocalPlayer
repeat wait() until game.ReplicatedStorage
repeat wait() until game.ReplicatedStorage:FindFirstChild("Remotes");
repeat wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui");
repeat wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("Main");
repeat wait() until game:GetService("Players")
repeat wait() until game:GetService("Players").LocalPlayer.Character:FindFirstChild("Energy")

local CoreGui = game:GetService('CoreGui'):FindFirstChild("RobloxGui") 
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScreenGui

local CloseOpen = Instance.new("TextButton")
CloseOpen.Text = "Open/Close"
CloseOpen.Parent = ScreenGui
CloseOpen.Size = UDim2.new(0.09,0,0,15)
CloseOpen.BackgroundColor3 = Color3.fromRGB(255,164,164)

local AutoCompleteTrial = Instance.new("TextButton")
AutoCompleteTrial.Text = "Auto Complete Trial"
AutoCompleteTrial.Parent = ScreenGui
AutoCompleteTrial.Size = UDim2.new(0.09,0,0,15)
AutoCompleteTrial.BackgroundColor3 = Color3.fromRGB(255,164,164)

local AutoAncientOneQuest = Instance.new("TextButton")
AutoAncientOneQuest.Text = "Auto AncientOne Quest"
AutoAncientOneQuest.Parent = ScreenGui
AutoAncientOneQuest.Size = UDim2.new(0.09,0,0,15)
AutoAncientOneQuest.BackgroundColor3 = Color3.fromRGB(255,164,164)

local TeleportToClockRoom = Instance.new("TextButton")
TeleportToClockRoom.Text = "Teleport To Clock Room"
TeleportToClockRoom.Parent = ScreenGui
TeleportToClockRoom.Size = UDim2.new(0.09,0,0,15)
TeleportToClockRoom.BackgroundColor3 = Color3.fromRGB(255,164,164)

local CompleteSkyTrial = Instance.new("TextButton")
CompleteSkyTrial.Text = "Complete Sky Trial"
CompleteSkyTrial.Parent = ScreenGui
CompleteSkyTrial.Size = UDim2.new(0.09,0,0,15)
CompleteSkyTrial.BackgroundColor3 = Color3.fromRGB(255,164,164)

local CompleteMinkTrial = Instance.new("TextButton")
CompleteMinkTrial.Text = "Complete Mink Trial"
CompleteMinkTrial.Parent = ScreenGui
CompleteMinkTrial.Size = UDim2.new(0.09,0,0,15)
CompleteMinkTrial.BackgroundColor3 = Color3.fromRGB(255,164,164)

local AutoRaid = Instance.new("TextButton")
AutoRaid.Text = "Auto Raid"
AutoRaid.Parent = ScreenGui
AutoRaid.Size = UDim2.new(0.09,0,0,15)
AutoRaid.BackgroundColor3 = Color3.fromRGB(255,164,164)

local TeleportToMythicIsland = Instance.new("TextButton")
TeleportToMythicIsland.Text = "Teleport To Mythic Island"
TeleportToMythicIsland.Parent = ScreenGui
TeleportToMythicIsland.Size = UDim2.new(0.09,0,0,15)
TeleportToMythicIsland.BackgroundColor3 = Color3.fromRGB(255,164,164)

local TeleportToGear = Instance.new("TextButton")
TeleportToGear.Text = "Teleport To Gear"
TeleportToGear.Parent = ScreenGui
TeleportToGear.Size = UDim2.new(0.09,0,0,15)
TeleportToGear.BackgroundColor3 = Color3.fromRGB(255,164,164)

local LockCameraToMoon = Instance.new("TextButton")
LockCameraToMoon.Text = "Lock Camera To Moon"
LockCameraToMoon.Parent = ScreenGui
LockCameraToMoon.Size = UDim2.new(0.09,0,0,15)
LockCameraToMoon.BackgroundColor3 = Color3.fromRGB(255,164,164)

local RemoveFog = Instance.new("TextButton")
RemoveFog.Text = "Remove Fog"
RemoveFog.Parent = ScreenGui
RemoveFog.Size = UDim2.new(0.09,0,0,15)
RemoveFog.BackgroundColor3 = Color3.fromRGB(255,164,164)

local ActiveRaceSkill = Instance.new("TextButton")
ActiveRaceSkill.Text = "Active Race Skill"
ActiveRaceSkill.Parent = ScreenGui
ActiveRaceSkill.Size = UDim2.new(0.09,0,0,15)
ActiveRaceSkill.BackgroundColor3 = Color3.fromRGB(255,164,164)

local ResetCharacter = Instance.new("TextButton")
ResetCharacter.Text = "Reset Character"
ResetCharacter.Parent = ScreenGui
ResetCharacter.Size = UDim2.new(0.09,0,0,15)
ResetCharacter.BackgroundColor3 = Color3.fromRGB(255,164,164)

local function CloseOpenFunc()
    if game:GetService("CoreGui"):FindFirstChild("SixMaHub").Enabled then
        game:GetService("CoreGui"):FindFirstChild("SixMaHub").Enabled = false
    else
        game:GetService("CoreGui"):FindFirstChild("SixMaHub").Enabled = true
    end
end

local function AutoCompleteTrialFunc()
    if _G.AutoCompleteTrial == true then
        _G.AutoCompleteTrial = false
    else
        _G.AutoCompleteTrial = true
    end
end

local function AutoAncientOneQuestFunc()
    if _G.AncientOne_Quest == true then
        _G.AncientOne_Quest = false
    else
        _G.AncientOne_Quest = true
    end
end

local function TeleportToClockRoomFunc()
    if _G.TeleporttoIsland == true then
        _G.TeleporttoIsland = false
    else
        _G.Island = "Ancient Clock Room"
        _G.TeleporttoIsland = true
    end
end

local function CompleteSkyTrialFunc()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Map.SkyTrial.Model:FindFirstChild("FinishPart").CFrame
end

local function CompleteMinkTrialFunc()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace"):FindFirstChild("StartPoint").CFrame
end

local function AutoRaidFunc()
    if _G.Auto_Raid == true then
        _G.Auto_Raid = false
    else
        _G.Auto_Raid = true
    end
end

local function TeleportToMythicIslandFunc()
    if _G.Teleport_to_Mythic_Island == true then
        _G.Teleport_to_Mythic_Island = false
    else
        _G.Teleport_to_Mythic_Island = true
    end
end

local function TeleportToGearFunc()
    if _G.Teleport_to_Gear == true then
        _G.Teleport_to_Gear = false
    else
        _G.Teleport_to_Gear = true
    end
end

local function LockCameraToMoonFunc()
    if _G.LockCameraToMoon == true then
        _G.LockCameraToMoon = false
    else
        _G.LockCameraToMoon = true
    end
end

local function RemoveFogFunc()
    game:GetService("Lighting").LightingLayers.MirageFog:Destroy()
    game:GetService("Lighting").BaseAtmosphere:Destroy()
end

local function ActiveRaceSkillFunc()
    VirtualInputManager:SendKeyEvent(true, "T", false, game)
    wait()
    VirtualInputManager:SendKeyEvent(false, "T", false, game)
end

local function ResetCharacterFunc()
    game.Players.LocalPlayer.Character.Humanoid.Health = 0
end

CloseOpen.Activated:Connect(CloseOpenFunc)
AutoCompleteTrial.Activated:Connect(AutoCompleteTrialFunc)
AutoAncientOneQuest.Activated:Connect(AutoAncientOneQuestFunc)
TeleportToClockRoom.Activated:Connect(TeleportToClockRoomFunc)
CompleteSkyTrial.Activated:Connect(CompleteSkyTrialFunc)
CompleteMinkTrial.Activated:Connect(CompleteMinkTrialFunc)
AutoRaid.Activated:Connect(AutoRaidFunc)
TeleportToMythicIsland.Activated:Connect(TeleportToMythicIslandFunc)
TeleportToGear.Activated:Connect(TeleportToGearFunc)
LockCameraToMoon.Activated:Connect(LockCameraToMoonFunc)
RemoveFog.Activated:Connect(RemoveFogFunc)
ActiveRaceSkill.Activated:Connect(ActiveRaceSkillFunc)
ResetCharacter.Activated:Connect(ResetCharacterFunc)
