function topos(Pos)
    Distance = (Pos.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    if game.Players.LocalPlayer.Character.Humanoid.Sit == true then game.Players.LocalPlayer.Character.Humanoid.Sit = false end
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
    end

    if _G.BypassTeleport and not _G.AutoCompleteTrial and not _G.Teleport_to_Mythic_Island and not _G.Teleport_to_Gear and not game.Players.LocalPlayer.Backpack:FindFirstChild("God's Chalice") and not game.Players.LocalPlayer.Character:FindFirstChild("God's Chalice") and not game.Players.LocalPlayer.Backpack:FindFirstChild("Sweet Chalice") and not game.Players.LocalPlayer.Character:FindFirstChild("Sweet Chalice") then
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

local CoreGui = game:GetService('CoreGui'):FindFirstChild("RobloxGui")
local gototialportal = Instance.new("TextButton")
gototialportal.Text = "Goto Trial Portal"
gototialportal.Parent = CoreGui
gototialportal.Size = UDim2.new(0.09,0,0,15)
gototialportal.BackgroundColor3 = Color3.fromRGB(255,164,164)

TempleofTime = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875)

local function onActivated()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875, 14896.5341796875, 102.62469482421875)   
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
end
end

gototialportal.Activated:Connect(onActivated)
