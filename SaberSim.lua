--------------------------------------------------------Saber Simulator--------------------------------------------------------

if not game:IsLoaded() then game.Loaded:Wait() end

for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
    v:Disable()
end

_G.Swing = false
_G.BuyAll = false
_G.AttackBoss = false
_G.Loop = false

local a = require(game:GetService("Players").LocalPlayer.PlayerGui.Gui.LocalScript.Locations) a.CheckInArena = function() return true end
local b = require(game:GetService("Players").LocalPlayer.PlayerGui.Gui.LocalScript.Extra)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local candyFarmed = {}
local StatsModule = require(game.ReplicatedStorage.Modules:WaitForChild("StatsModule", math.huge))
local UpdateData = ReplicatedStorage.Events.UpdateData
local Clicked = ReplicatedStorage.Events.Clicked
local Sell = ReplicatedStorage.Events.Sell
local BuyAll = ReplicatedStorage.Events.BuyAll
local Clicked = ReplicatedStorage.Events.Clicked

if player.Character ~= nil then
    if player.Character:FindFirstChild("AntiPort") then
        player.Character.AntiPort:Remove()
    end
    if player.Character:FindFirstChild("AntiPortNew") then
        player.Character.AntiPortNew:Remove()
    end
end

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("AntiPort", math.huge):Remove()
    char:WaitForChild("AntiPortNew", math.huge):Remove()
end)


local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/Gr33nShadow51234/Glizzy/main/Mercury"))()

local GUI = Mercury:Create{
    Name = "SaberSim",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Vibe,
    Link = "https://vibehouse.de/"
}

-- Main Tab --

local mainTab = GUI:Tab{
	Name = "Main",
	Icon = "rbxassetid://9741693218"
}

mainTab:Toggle{
	Name = "Auto Swing",
	StartingState = _G.Swing,
	Description = nil,
	Callback = function(state)
    _G.Swing = state
        while _G.Swing and task.wait(.05) do
            Clicked:FireServer()
        end
    end
}

mainTab:Toggle{
	Name = "Auto Buy All Sabers",
	StartingState = _G.BuyAll,
	Description = nil,
	Callback = function(state)
        _G.BuyAll = state
        while _G.BuyAll and task.wait(4) do
            BuyAll:FireServer("Swords")
        end
    end
}

mainTab:Toggle{
	Name = "Auto Buy All DNA",
	StartingState = _G.BuyAll,
	Description = nil,
	Callback = function(state)
        _G.BuyAll = state
        while _G.BuyAll and task.wait(4) do
            BuyAll:FireServer("Backpacks")
        end
    end
}


mainTab:Toggle{
	Name = "Kill Boss",
	StartingState = _G.AttackBoss,
	Description = nil,
	Callback = function(state)
        _G.AttackBoss = state

        while _G.AttackBoss and task.wait(.05) do
            if player.Character ~= nil and player.Character:FindFirstChildOfClass("Tool") and player.Character:FindFirstChildOfClass("Tool"):FindFirstChild("TouchInterest", true) then
                if workspace:FindFirstChild("Boss") or workspace.Mobs:FindFirstChild("HumanoidRootPart", true) then
                    pcall(function()
                        player.Character:FindFirstChildOfClass("Tool").RemoteClick:FireServer()
                        if workspace:FindFirstChild("Boss") then
                            firetouchinterest(workspace.Boss.HumanoidRootPart, player.Character:FindFirstChildOfClass("Tool"):FindFirstChild("TouchInterest", true).Parent, 0)
                            firetouchinterest(workspace.Boss.HumanoidRootPart, player.Character:FindFirstChildOfClass("Tool"):FindFirstChild("TouchInterest", true).Parent, 1)
                        end
                        for i,v in pairs(workspace.Mobs:GetChildren()) do
                            if v:FindFirstChild("HumanoidRootPart") then
                                firetouchinterest(v.HumanoidRootPart, player.Character:FindFirstChildOfClass("Tool"):FindFirstChild("TouchInterest", true).Parent, 0)
                                firetouchinterest(v.HumanoidRootPart, player.Character:FindFirstChildOfClass("Tool"):FindFirstChild("TouchInterest", true).Parent, 1)
                            end
                        end
                    end)
                end 
            end
        end
    end
}

mainTab:Toggle{
	Name = "Farm Candy",
	StartingState = _G.Loop,
	Description = nil,
	Callback = function(state)
        _G.Loop = state

        player.PlayerScripts.Candy.Disabled = true

        while _G.Loop and task.wait() do
            for i,v in ipairs(workspace.CandyHolder:GetChildren()) do
                if not candyFarmed[v] and _G.Loop then
                    player.Character.HumanoidRootPart.CFrame = v.CFrame
                    task.wait(.15)
                    game.ReplicatedStorage.Events.CollectCandy:FireServer(v)
                    game.ReplicatedStorage.Events.UpdateData:InvokeServer()
                    candyFarmed[v] = tick()
                elseif (tick() - candyFarmed[v]) > 30 and _G.Loop then
                    player.Character.HumanoidRootPart.CFrame = v.CFrame
                    task.wait(.15)
                    game.ReplicatedStorage.Events.CollectCandy:FireServer(v)
                    game.ReplicatedStorage.Events.UpdateData:InvokeServer()
                    candyFarmed[v] = tick()
                end
            end
        end
    end
}

mainTab:Button{
	Name = "Sell Amount",
	Description = nil,
	Callback = function()
        local c = game.ReplicatedStorage.Events.UpdateData:InvokeServer()

        GUI:Notification{
            Title = "Sell Amount",
            Text = b.ShorterNumber(c.Strength * StatsModule.getSellMulti(game.Players.LocalPlayer,c)),
            Duration = 5,
            Callback = function() end
        }
    end
}
-- Misc Tab--

local miscTab = GUI:Tab{
	Name = "misc",
	Icon = nil
}

miscTab:Button{
	Name = "TP Last Island",
	Description = nil,
	Callback = function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(785, 531453, -336)
    end
}
miscTab:Button{
	Name = "TP Shop",
	Description = nil,
	Callback = function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(788, 560601, -326)
    end
}
-- Notification --

GUI:Notification{
	Title = "Notification!",
	Text = "U can close the GUI with RIGHTSHIFT",
	Duration = 8,
	Callback = function() end
}

GUI:Credit{
	Name = "ImperatorWeeds",
	Description = "Made 3/4 of the Scripts",
	V3rm = "https://v3rmillion.net/member.php?action=profile&uid=1337989",
	Discord = "ImperatorWeeds#8893"
}

warn("Scripts made by ImperatorWeeds")
warn("UI by Floppa")
