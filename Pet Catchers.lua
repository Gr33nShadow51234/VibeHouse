--------Anti AFK--------
if not game:IsLoaded() then game.Loaded:Wait() end
for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
    v:Disable()
end

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local Window = Library:CreateWindow({
    Title = 'Pet Catchers by Pryxo',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Threads = {}

-- Locals
local DataSave = getupvalues(require(game:GetService("ReplicatedStorage").Client.Framework.Services.LocalData).Get)[1]
local ShrinesTable = require(game:GetService("ReplicatedStorage").Shared.Data.Shrines)
local ChestTable = require(game:GetService("ReplicatedStorage").Shared.Data.Chests)
local Fish = require(game:GetService("ReplicatedStorage").Client.Handlers.Fishing)
local PetRender = require(game:GetService("ReplicatedStorage").Client.Pets.PetRender)
local PlayerPart = game.Players.LocalPlayer.Character.HumanoidRootPart
local PetRarity = {"Secret","Legendary","Epic","Rare","Common"}
local CubeRarity = {"Legendary","Epic","Rare","Common"}
local PetTable = require(game:GetService("ReplicatedStorage").Shared.Data.Pets)
local nearest_table = {}
local Invoke = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Function")


-- Functions
function find_nearest_enemy()
    local nearest, nearest_distance = nil, math.huge
    for i,v in PetRender.WorldPets do
        local dist = (PlayerPart.Position - v.Model.PrimaryPart.Position).Magnitude
        if dist > nearest_distance then continue end
        nearest = v
        nearest_distance = dist
    end
    return nearest, nearest_distance
end

function find_highest_enemy()
    local highest, highest_rarity = nil, "Common"
    for i,v in PetRender.WorldPets do
        local Rarity = PetTable[v.Name].Rarity
        if table.find(PetRarity, Rarity) > table.find(PetRarity, highest_rarity) then continue end
        highest = v
        highest_rarity = Rarity
    end
    return highest, highest_rarity
end

function find_lowest_enemy()
    local highest, highest_rarity = nil, "Secret"
    for i,v in PetRender.WorldPets do
        local Rarity = PetTable[v.Name].Rarity
        if table.find(PetRarity, Rarity) < table.find(PetRarity, highest_rarity) then continue end
        highest = v
        highest_rarity = Rarity
    end
    return highest, highest_rarity
end

function find_shiny_enemy()
    local shiny = nil
    for i,v in PetRender.WorldPets do
        if not v.Shiny then continue end
        shiny = v
    end
    return shiny
end

function find_nearest_monster()
    local nearest, nearest_distance = nil, math.huge
    for i,v in workspace.Rendered.Enemies:GetChildren() do
        local dist = (PlayerPart.Position - v.WorldPivot.Position).Magnitude
        if dist > nearest_distance then continue end
        nearest = v
        nearest_distance = dist
    end
    return nearest, nearest_distance
end

function get_highest_ball()
    local amount, highest_rarity = nil, "Common"
    for i,v in DataSave.CaptureCubes do
        local Rarity = i
        if table.find(CubeRarity, Rarity) > table.find(CubeRarity, highest_rarity) then continue end
        amount = v
        highest_rarity = Rarity
    end
    return highest_rarity, amount
end
-- Tabs
local Tabs = {
    ['Main'] = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Groups
local GeneralBox = Tabs.Main:AddLeftGroupbox('General')
local PetBox = Tabs.Main:AddLeftGroupbox('Pets')
local FishBox = Tabs.Main:AddRightGroupbox('Fish')
local MobsBox = Tabs.Main:AddRightGroupbox('Mobs')
local MinigameBox = Tabs.Main:AddRightGroupbox('Minigames')

-- toggles
PetBox:AddDropdown('ModeDropdown', {
    Values = {'Nearest', 'Highest Star', 'Lowest Star'},
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'Modes',
    Tooltip = 'Choose Mode', -- Information shown when you hover over the dropdown

    Callback = function(Value)
    end
})
PetBox:AddToggle('PrioritizeShiny', {
    Text = 'Prioritize Shiny',
    Default = false, -- Default value (true / false)
    Tooltip = 'Prioritize Shiny', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
PetBox:AddToggle('AutoCatch', {
    Text = 'Auto Catch',
    Default = false, -- Default value (true / false)
    Tooltip = 'Collects All Shrines', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

GeneralBox:AddToggle('AutoShrines', {
    Text = 'Auto Shrines',
    Default = false, -- Default value (true / false)
    Tooltip = 'Collects All Shrines', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

local AutoChest = GeneralBox:AddButton({
    Text = 'Auto Chest',
    Func = function()
        for i,v in ChestTable do
            game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("OpenWorldChest",i)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Collects All Chest'
})

PetBox:AddDivider()

PetBox:AddDropdown('EggDropdown', {
    Values = {'Mystery Egg', 'Elite Mystery Egg'},
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'Eggs',
    Tooltip = 'Choose Egg', -- Information shown when you hover over the dropdown

    Callback = function(Value)
    end
})

PetBox:AddToggle('AutoOpen', {
    Text = 'Auto Open',
    Default = false, -- Default value (true / false)
    Tooltip = 'Opens Eggs for you', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

FishBox:AddToggle('AutoFish', {
    Text = 'Auto Fish',
    Default = false, -- Default value (true / false)
    Tooltip = 'Use rod for you', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
FishBox:AddToggle('AutoFishSell', {
    Text = 'Auto Sell',
    Default = false, -- Default value (true / false)
    Tooltip = 'Use rod for you', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

MobsBox:AddToggle('TPMobs', {
    Text = 'TP to Mobs',
    Default = false, -- Default value (true / false)
    Tooltip = 'teleport to mobs', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

MobsBox:AddToggle('Godmode', {
    Text = 'Godmode',
    Default = false, -- Default value (true / false)
    Tooltip = 'God', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

MobsBox:AddToggle('SlimeGodmode', {
    Text = 'Slime Godmode',
    Default = false, -- Default value (true / false)
    Tooltip = 'Only for Slime', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
MobsBox:AddToggle('KrakenGodmode', {
    Text = 'Kraken Godmode',
    Default = false, -- Default value (true / false)
    Tooltip = 'Only for Kraken', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
MinigameBox:AddToggle('DigSite', {
    Text = 'Auto Excavation',
    Default = false, -- Default value (true / false)
    Tooltip = 'REJOIN AFTER USE', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})




table.insert(Threads, task.spawn(function() --Godmode
    while task.wait() do
        if Toggles.AutoCatch.Value then
            local Pet = nil
            local success = false
            local Rarity = nil
            local Cube = "Common"

            --print(Options.ModeDropdown.Value)
            if Options.ModeDropdown.Value == "Nearest" then
                Pet = find_nearest_enemy()
                --print(find_nearest_enemy())
            elseif Options.ModeDropdown.Value == "Highest Star" then
                Pet, Rarity = find_highest_enemy()
                --print(find_highest_enemy())
            elseif Options.ModeDropdown.Value == "Lowest Star" then
                Pet, Rarity = find_lowest_enemy()
                --print(find_lowest_enemy())
            end

            if Toggles.AutoCatch.PrioritizeShiny then 
                find_shiny_enemy()
                --print("SHINY!!!!!!!!!!!!!!!!!!!")
            end

            local old1, old2 = Pet.Model.PrimaryPart.Transparency, Pet.Model.PrimaryPart.Color

            Pet.Model.PrimaryPart.Transparency = 0.2
            Pet.Model.PrimaryPart.Color = Color3.new(0,0,0)

            repeat
                if table.find(PetRarity, Rarity) <= 2 then
                    Cube = get_highest_ball()
                end
                print(Cube)
                    success = Invoke:InvokeServer("CapturePet",Pet.GUID,Cube)
                task.wait()
            until success or Pet.Model == nil or Toggles.AutoCatch.Value == false

            Pet.Model.PrimaryPart.Transparency = old1
            Pet.Model.PrimaryPart.Color = old2

            print("GOTCHA")
        end
    end
end))

table.insert(Threads, task.spawn(function() --Godmode
    while task.wait() do
        if Toggles.Godmode.Value then
            game.Players.LocalPlayer.Character.Humanoid.Health = math.huge
        end
    end
end))
table.insert(Threads, task.spawn(function() --Godmode
    while task.wait() do
        if Toggles.AutoOpen.Value then
            if Options.EggDropdown.Value == "" then continue end
            game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Function"):InvokeServer("TryHatchEgg",Options.EggDropdown.Value)            
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoFish
    while task.wait() do
        if Toggles.AutoFish.Value then
            if Fish.Casting then continue end
            Fish.Casting = true
            game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("StartCastFishing")
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoFishSell
    while task.wait() do
        if Toggles.AutoFishSell.Value then
            game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("SellFish")
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoShrines
    while task.wait() do
        if Toggles.AutoShrines.Value then
            for i,v in DataSave.Shrines do
                local unixT = os.time()
                local Time = v.LastUpdateTime + v.Duration
                if os.time() >= v.LastUpdateTime + v.Duration then
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("UseShrine",i)
                    print(i)
                end
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --SlimeGodmode
    while task.wait() do
        if Toggles.TPMobs.Value then
            local Monster = find_nearest_monster()
            if Monster then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Monster.WorldPivot.Position) * CFrame.new(0, 15, 0)
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --SlimeGodmode
    while task.wait() do
        if Toggles.SlimeGodmode.Value then
            if workspace.Rendered:FindFirstChild("King Slime") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Rendered["King Slime"].PrimaryPart.CFrame * CFrame.new(0, 16, -15)
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --KrakenGodmode
    while task.wait() do
        if Toggles.SlimeGodmode.Value then
            if workspace.Rendered:FindFirstChild("Generic"):FindFirstChild("Kraken"):FindFirstChild("Area") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Rendered.Generic.Kraken.Area.CFrame * CFrame.new(-280, 50, 300)
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoDigSite
    while task.wait() do
        if Toggles.DigSite.Value then
            if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.MinigameHUD.Visible then 
                for i,v in workspace.Rendered.Generic:GetChildren() do
                    if v:IsA("Part") and v.Name == "Glow" then
                        local nearest, nearest_distance = nil, math.huge
                        for i2,v2 in workspace.Map["Dusty Dunes"].Excavation.Tiles:GetChildren() do
                            local dist = (v.Position - v2.Position).Magnitude
                            
                            if dist > nearest_distance then continue end
                            nearest = v2
                            nearest_distance = dist
                        end
            
                        if table.find(nearest_table, nearest) then continue end
                        
                        table.insert(nearest_table, nearest)
                    end
                end
            
                for _,v in nearest_table do
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("TryMinigameInput",tostring(v))    
                end
            else
                nearest_table = {}
            end
        end
    end
end))

Library:OnUnload(function()
    print('Unloaded!')
    Library.Unloaded = true
    local ThreadCount = 0
    for i,v in Threads do
        task.cancel(v)
        ThreadCount += 1
    end
    print('Canceld '.. ThreadCount ..' Threads!')
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() 
end)

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
