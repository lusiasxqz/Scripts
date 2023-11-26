local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SixMa Hub",
    SubTitle = "Blox Fruit",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Rose",
    MinimizeKey = Enum.KeyCode.LeftControl
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    General = Window:AddTab({ Title = "General", Icon = "globe" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    local SelectWeapon = Tabs.General:AddDropdown("SelectWeapon", {
        Title = "Select Combat / Weapon",
        Values = {"Melee","Sword","Devil Fruit"},
        Multi = false,
        Default = 1,
    })

    SelectWeapon:OnChanged(function(Value)
        print("Dropdown changed:", Value)
    end)

    Playerslist = {}
    for i,v in pairs(game:GetService("Players"):GetChildren()) do
        if v.Name ~= game.Players.LocalPlayer.Name then
            table.insert(Playerslist,v.Name)
        end
    end

    local Choosealeader = Tabs.General:AddDropdown("Choosealeader", {
        Title = "Choose a leader",
        Values = Playerslist,
        Multi = false,
        Default = 1,
    })

    Choosealeader:OnChanged(function(Value)
        _G.Choosealeader = Value
        Choosealeader = Value
    end)

    Tabs.General:AddButton({
        Title = "Refresh Players",
        Description = "",
        Callback = function()
            Playerslist = {}
            table.clear(Playerslist)
            for i,v in pairs(game:GetService("Players"):GetChildren()) do
                if v.Name ~= game.Players.LocalPlayer.Name then
                    table.insert(Playerslist,v.Name)
                end
            end
            Options.Choosealeader:SetValue(Playerslist)
        end
    })

    local AutoRaceV4 = Tabs.General:AddToggle("AutoRaceV4", {
        Title = "AutoRaceV4", 
        Default = false 
    })

    AutoRaceV4:OnChanged(function()
        print("Toggle changed:", Options.AutoRaceV4.Value)
    end)

    Options.AutoRaceV4:SetValue(false)
end
