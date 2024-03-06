--------Anti AFK--------
if not game:IsLoaded() then game.Loaded:Wait() end
for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
    v:Disable()
end
print("Anti AFK | Active")

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local Window = Library:CreateWindow({
    Title = 'Pet Catchers by 🐟',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Threads = {}
local Debug = false

function empty() end
function set_table(path) local Temp = {}; for i,v in path:GetChildren() do table.insert(Temp, v.Name) end; return Temp end

-- Locals
local DataSave = getupvalues(require(game:GetService("ReplicatedStorage").Client.Framework.Services.LocalData).Get)[1]
local BossRecords = DataSave.BossRecords
local CraftingList = DataSave.Crafting
local Index = DataSave.Index
local Shops = DataSave.Shops
local ScreenTransition = require(game:GetService("ReplicatedStorage").Client.Gui.ScreenTransition)
local ShrinesTable = require(game:GetService("ReplicatedStorage").Shared.Data.Shrines)
local ChestTable = require(game:GetService("ReplicatedStorage").Shared.Data.Chests)
local Fish = require(game:GetService("ReplicatedStorage").Client.Handlers.Fishing)
local PetRender = require(game:GetService("ReplicatedStorage").Client.Pets.PetRender)
local WorldPets = PetRender.WorldPets
local PlayerChar = game.Players.LocalPlayer.Character
local PetRarity = {"Secret","Legendary","Epic","Rare","Common"}
local ShopRespawn = {
    ["gem-trader"] = 3600,
    ["magic-shop"] = 3600,
    ["auburn-shop"] = 1200,
    ["the-blackmarket"] = 7200
}
local AllShrines = set_table(workspace.Shrines)
local CubeRarity = {"Legendary","Epic","Rare","Common"}
local PetTable = require(game:GetService("ReplicatedStorage").Shared.Data.Pets)
local nearest_table = {}
local Invoke = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Function")
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event")
local BossStuff = require(game:GetService("ReplicatedStorage").Client.Boss)
local BossAreas = workspace.Bosses
local Bosses = {"king-slime","the-kraken"}
local CraftingRecipes = {'rare-cube', 'epic-cube', 'legendary-cube', 'mystery-egg', 'elite-mystery-egg', 'coin-elixir', 'xp-elixir', 'sea-elixir'}
local DanceOrder = {}
local BossLeft = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossPanel.Frame.Info.Scaling.Left.Button
local BossRight = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossPanel.Frame.Info.Scaling.Right.Button
local BossBypass = false
local WaitJoinMinigame = false
local WaitJoinBoss = false
local InsideMinigame = false
local InsideBoss = false

-- Functions
function find_nearest_enemy()
    local nearest, rarity, nearest_distance = nil, "Common", math.huge
    for i,v in WorldPets do
        local dist = (PlayerChar.HumanoidRootPart.Position - v.Model.PrimaryPart.Position).Magnitude
        local Rarity = PetTable[v.Name].Rarity
        if dist > nearest_distance then continue end
        nearest = v
        nearest_distance = dist
        rarity = Rarity
    end
    return nearest, rarity, nearest_distance
end

function find_highest_enemy()
    local highest, highest_rarity = nil, "Common"
    for i,v in WorldPets do
        local Rarity = PetTable[v.Name].Rarity
        if table.find(PetRarity, Rarity) > table.find(PetRarity, highest_rarity) then continue end
        highest = v
        highest_rarity = Rarity
    end
    return highest, highest_rarity
end

function find_lowest_enemy()
    local highest, highest_rarity = nil, "Secret"
    for i,v in WorldPets do
        local Rarity = PetTable[v.Name].Rarity
        if table.find(PetRarity, Rarity) < table.find(PetRarity, highest_rarity) then continue end
        highest = v
        highest_rarity = Rarity
    end
    return highest, highest_rarity
end

function find_shiny_enemy()
    local shiny = nil
    for i,v in WorldPets do
        if not v.Shiny then continue end

        shiny = v
    end
    return shiny
end

function find_rare_enemy()
    local rare = nil
    print(WorldPets)
    for i,v in WorldPets do
        if PetTable[v.Name].Rarity == "Legendary" or PetTable[v.Name].Rarity == "Secret" then
            rare = v
        end
    end
    return rare
end

function get_index_pet()
    local index_pet = nil

    for i,v in WorldPets do
        local Version = "Normal"

        if v.Shiny then
            Version = "Shiny"
        end

        if Index[v.Name][Version].Caught == 0 then
            index_pet = v
            
            if Debug then
                print(Version, v.Name ,Index[v.Name][Version].Caught)
            end
        end
    end

    return index_pet
end

function find_nearest_monster()
    local nearest, nearest_distance = nil, math.huge
    for i,v in workspace.Rendered.Enemies:GetChildren() do
        local dist = (PlayerChar.HumanoidRootPart.Position - v.WorldPivot.Position).Magnitude
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

function canDoBoss()
    if not BossStuff.Current then return true end
    if not BossStuff.Current.State then return true end
    if BossStuff.Current.State.BossDied == true then
        return true
    end
    if BossStuff.Current.State.Finishing == true then
        return false, BossStuff.Current.State.Health, BossStuff.Current.State.MaxHealth
    end
    
    return false, BossStuff.Current.State.Health, BossStuff.Current.State.MaxHealth
end

function get_minigame_pet()
    local id, HighestGamer = nil, 0
    for i,v in DataSave.Pets do
        if not v.Charms then continue end

        for _,Charm in v.Charms do
            if Charm.Name ~= "Gamer" then continue end
            if HighestGamer > Charm.Level then continue end
            id = v.Id
            HighestGamer = Charm.Level
        end
    end
    return id, HighestGamer
end

function set_boss_page(page)
    repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossPanel.Visible
    local lvl = tonumber(string.split(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossPanel.Frame.Info.Scaling.Level.Text, "x")[2])

    if lvl == page then
        return true
    end

    if lvl > page then
        repeat 
            firesignal(BossLeft.Activated)
            task.wait()
            lvl = tonumber(string.split(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossPanel.Frame.Info.Scaling.Level.Text, "x")[2])

        until lvl == page

        return true
    elseif lvl < page then
        repeat 
            firesignal(BossRight.Activated)
            task.wait()
            lvl = tonumber(string.split(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossPanel.Frame.Info.Scaling.Level.Text, "x")[2])

        until lvl == page
        
        return true
    end
end



-- Tabs
local Tabs = {
    ['Main'] = Window:AddTab('Main'),
    ['Stat'] = Window:AddTab('Stat'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Groups
local GeneralBox = Tabs.Main:AddLeftGroupbox('General')
local PetBox = Tabs.Main:AddLeftGroupbox('Pets')
local FishBox = Tabs.Main:AddLeftGroupbox('Fish')

local MobBossBox = Tabs.Main:AddRightTabbox('Mob&Boss')
local CraftBox = Tabs.Main:AddRightTabbox('Crafting')
local MinigameBox = Tabs.Main:AddRightGroupbox('Minigames')
local MerchantBox = Tabs.Main:AddRightGroupbox('Merchants')

-- Group Tabs
local CraftSlot1 = CraftBox:AddTab('Slot 1')
local CraftSlot2 = CraftBox:AddTab('Slot 2')
local CraftSlot3 = CraftBox:AddTab('Slot 3')
local MobTab = MobBossBox:AddTab('Mobs')
local BossTab = MobBossBox:AddTab('Bosses')
-- toggles
GeneralBox:AddToggle('AutoCollect', {
    Text = 'Auto Collect',
    Default = false, -- Default value (true / false)
    Tooltip = 'Collects all Orbs/Items on Ground', -- Information shown when you hover over the toggle

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
GeneralBox:AddToggle('Godmode1', {
    Text = 'Godmode #1',
    Default = false, -- Default value (true / false)
    Tooltip = 'Invis Shield', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
GeneralBox:AddToggle('Godmode2', {
    Text = 'Godmode #2',
    Default = false, -- Default value (true / false)
    Tooltip = 'Set Health', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
local AutoChest = GeneralBox:AddButton({
    Text = 'Auto Chest',
    Func = function()
        for i,v in ChestTable do
            Remote:FireServer("OpenWorldChest",i)
        end
    end,
    DoubleClick = false,
    Tooltip = 'Collects All Chest'
})

PetBox:AddDropdown('ModeDropdown', {
    Values = {'Nearest', 'Highest Star', 'Lowest Star'},
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'Modes',
    Tooltip = 'Choose Mode', -- Information shown when you hover over the dropdown

    Callback = function(Value)
    end
})
PetBox:AddToggle('PrioritizeRare', {
    Text = 'Prioritize Leg & Secret',
    Default = false, -- Default value (true / false)
    Tooltip = 'Prioritize Leg & Secret', -- Information shown when you hover over the toggle

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
PetBox:AddToggle('PrioritizeIndex', {
    Text = 'Prioritize Index',
    Default = false, -- Default value (true / false)
    Tooltip = 'Prioritize Index', -- Information shown when you hover over the toggle

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
    Tooltip = 'Sells 🐟', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
BossTab:AddToggle('DigsiteBoss', {
    Text = 'Support for Boss + Minigame',
    Default = false, -- Default value (true / false)
    Tooltip = 'Removes Kraken Attacks', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
BossTab:AddToggle('AutoBosslvl25', {
    Text = 'Set Max lvl 25',
    Default = false, -- Default value (true / false)
    Tooltip = 'Doing bosses without touching', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

BossTab:AddToggle('AutoBoss', {
    Text = 'Auto Boss',
    Default = false, -- Default value (true / false)
    Tooltip = 'Doing bosses without touching', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
BossTab:AddToggle('DisableKraken', {
    Text = 'Disable Kraken',
    Default = false, -- Default value (true / false)
    Tooltip = 'Removes Kraken Attacks', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
BossTab:AddToggle('RespawnKraken', {
    Text = 'Respawn Kraken',
    Default = false, -- Default value (true / false)
    Tooltip = 'Respawn Kraken', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
BossTab:AddToggle('RespawnSlime', {
    Text = 'Respawn Slime',
    Default = false, -- Default value (true / false)
    Tooltip = 'Respawn Slime', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})


MobTab:AddToggle('TPMobs', {
    Text = 'TP to Mobs',
    Default = false, -- Default value (true / false)
    Tooltip = 'Teleport to mobs', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})


BossTab:AddToggle('BossGodmode', {
    Text = 'Boss Godmode',
    Default = false, -- Default value (true / false)
    Tooltip = 'Only for Bosses', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

MinigameBox:AddToggle('DigSite', {
    Text = 'Auto Excavation',
    Default = false, -- Default value (true / false)
    Tooltip = '', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
MinigameBox:AddToggle('DanceOff', {
    Text = 'Auto Dance Off',
    Default = false, -- Default value (true / false)
    Tooltip = '', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

CraftSlot1:AddDropdown('SelectRecipe1', {
    Values = CraftingRecipes,
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'Select Recipe',
    Tooltip = 'Recipe for Slot 1', -- Information shown when you hover over the dropdown

    Callback = function(Value)
    end
})
CraftSlot1:AddSlider('SelectAmount1', {
    Text = 'Select Amount',
    Default = 1,
    Min = 1,
    Max = 999,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
    end
})
CraftSlot1:AddToggle('AutoCraftClaim1', {
    Text = 'Craft & Claim',
    Default = false, -- Default value (true / false)
    Tooltip = '', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

CraftSlot2:AddDropdown('SelectRecipe2', {
    Values = CraftingRecipes,
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'Select Recipe',
    Tooltip = 'Recipe for Slot 2', -- Information shown when you hover over the dropdown

    Callback = function(Value)
    end
})
CraftSlot2:AddSlider('SelectAmount2', {
    Text = 'Select Amount',
    Default = 1,
    Min = 1,
    Max = 999,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
    end
})
CraftSlot2:AddToggle('AutoCraftClaim2', {
    Text = 'Craft & Claim',
    Default = false, -- Default value (true / false)
    Tooltip = '', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

CraftSlot3:AddDropdown('SelectRecipe3', {
    Values = CraftingRecipes,
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'Select Recipe',
    Tooltip = 'Recipe for Slot 3', -- Information shown when you hover over the dropdown

    Callback = function(Value)
    end
})
CraftSlot3:AddSlider('SelectAmount3', {
    Text = 'Select Amount',
    Default = 1,
    Min = 1,
    Max = 999,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
    end
})
CraftSlot3:AddToggle('AutoCraftClaim3', {
    Text = 'Craft & Claim',
    Default = false, -- Default value (true / false)
    Tooltip = '', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})


MerchantBox:AddDropdown('TPDropdown', {
    Values = set_table(workspace.Activations),
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'Teleport to Shops',
    Tooltip = 'Choose Teleport', -- Information shown when you hover over the dropdown

    Callback = function(Value)
        PlayerChar.HumanoidRootPart.Position = workspace.Activations[Value].WorldPivot.Position
    end
})

MerchantBox:AddToggle('BLACKMARKET', {
    Text = 'Buy Blackmarket',
    Default = false, -- Default value (true / false)
    Tooltip = '', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
MerchantBox:AddToggle('GTrader', {
    Text = 'Buy Gem Trader',
    Default = false, -- Default value (true / false)
    Tooltip = '', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
MerchantBox:AddToggle('MShop', {
    Text = 'Buy Magic Shop',
    Default = false, -- Default value (true / false)
    Tooltip = '', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
MerchantBox:AddToggle('AShop', {
    Text = 'Buy Auburn Shop',
    Default = false, -- Default value (true / false)
    Tooltip = '', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

table.insert(Threads, task.spawn(function() --AutoCollect
    while task.wait() do
        if not Toggles.AutoCollect.Value then continue end

        for i,v in workspace.Rendered.Pickups:GetChildren() do
            v.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoCatch
    while task.wait() do
        if not Toggles.AutoCatch.Value then continue end

        local Pet = nil
        local success = false
        local Rarity = nil
        local Cube = "Common"
        local STOP = false
        local PRIO = false

        if Debug then
            print(Options.ModeDropdown.Value)
        end

        if Options.ModeDropdown.Value == "Nearest" then
            Pet, Rarity = find_nearest_enemy()

            if Debug then
                print(find_nearest_enemy())
            end
        elseif Options.ModeDropdown.Value == "Highest Star" then
            Pet, Rarity = find_highest_enemy()

            if Debug then
                print(find_highest_enemy())
            end
        elseif Options.ModeDropdown.Value == "Lowest Star" then
            Pet, Rarity = find_lowest_enemy()

            if Debug then
                print(find_lowest_enemy())
            end
        end
        --local old1, old2 = Pet.Model.PrimaryPart.Transparency, Pet.Model.PrimaryPart.Color

        --Pet.Model.PrimaryPart.Transparency = 0.2
        --et.Model.PrimaryPart.Color = Color3.new(0,0,0)

        if Toggles.PrioritizeShiny.Value then 
            if find_shiny_enemy() then
                Pet = find_shiny_enemy()
                Cube = "Epic"
                PRIO = true

                if Debug then
                    print("SHINY!!!!!!!!!!!!!!!!!!!")
                end
            end
        elseif Toggles.PrioritizeRare.Value then 
            if find_rare_enemy() then
                Pet = find_rare_enemy()
                Cube = get_highest_ball()
                PRIO = true

                if Debug then
                    print("LEG / SECRET")
                end
            end
        elseif Toggles.PrioritizeIndex.Value then 
            if get_index_pet() then
                Pet = get_index_pet()
                Cube = get_highest_ball()
                PRIO = true

                if Debug then
                    print("INDEX PET")
                end
            end
        end
        
        while task.wait() do
            if success or Pet.Model.Parent == nil or Toggles.AutoCatch.Value == false or STOP then break end

            if not PRIO then
                if Toggles.PrioritizeShiny.Value then 
                    if find_shiny_enemy() then
                        STOP = true
                    end
                elseif Toggles.PrioritizeRare.Value then 
                    if find_rare_enemy() then
                        STOP = true
                    end
                elseif Toggles.PrioritizeIndex.Value then 
                    if get_index_pet() then
                        STOP = true
                    end
                end

                if table.find(PetRarity, Rarity) <= 2 then
                    Cube = get_highest_ball()
                end
            end
            success = Invoke:InvokeServer("CapturePet", Pet.GUID, Cube)
        end

        if Pet.Model.Parent ~= nil and success then
            Pet.Model:Destroy()
        end

        --Pet.Model.PrimaryPart.Transparency = old1
        --Pet.Model.PrimaryPart.Color = old2

        if Debug then
            print("GOTCHA")
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoCraftClaim1
    while task.wait() do
        if not Toggles.AutoCraftClaim1.Value then continue end

        if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Crafting.Frame.Body.Slot1.Content.Craft.Visible then 
            Remote:FireServer("StartCrafting", 1, Options.SelectRecipe1.Value, Options.SelectAmount1.Value)   
        elseif game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Crafting.Frame.Body.Slot1.Content.Claim.Visible then
            Remote:FireServer("ClaimCrafting", 1)
        else 
            if Debug then
                print("Wait Slot 1")
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoCraftClaim2
    while task.wait() do
        if not Toggles.AutoCraftClaim2.Value then continue end

        if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Crafting.Frame.Body.Slot2.Content.Craft.Visible then 
            Remote:FireServer("StartCrafting", 2, Options.SelectRecipe2.Value, Options.SelectAmount2.Value)  
        elseif game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Crafting.Frame.Body.Slot2.Content.Claim.Visible then
            Remote:FireServer("ClaimCrafting", 2)
        else 
            if Debug then
                print("Wait Slot 2")
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoCraftClaim3
    while task.wait() do
        if not Toggles.AutoCraftClaim3.Value then continue end
        
        if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Crafting.Frame.Body.Slot3.Content.Craft.Visible then 
            Remote:FireServer("StartCrafting", 3, Options.SelectRecipe3.Value, Options.SelectAmount3.Value)  
        elseif game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Crafting.Frame.Body.Slot3.Content.Claim.Visible then
            Remote:FireServer("ClaimCrafting", 3)
        else 
            if Debug then
                print("Wait Slot 3")
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --Godmode1
    while task.wait() do
        if not Toggles.Godmode1.Value then continue end

        if not PlayerChar:FindFirstChild("Fishy Capsule") then
            local Y = Instance.new("ForceField", PlayerChar)
            Y.Name = "Fishy Capsule"
            Y.Visible = false
        end
    end
end))
table.insert(Threads, task.spawn(function() --Godmode2
    while task.wait() do
        if not Toggles.Godmode2.Value then continue end

        PlayerChar.Humanoid.Health = PlayerChar.Humanoid.MaxHealth
    end
end))
table.insert(Threads, task.spawn(function() --AutoOpen
    while task.wait() do
        if not Toggles.AutoOpen.Value then continue end

        if Options.EggDropdown.Value == "" then continue end
        Invoke:InvokeServer("TryHatchEgg",Options.EggDropdown.Value)            
    end
end))
table.insert(Threads, task.spawn(function() --AutoFish
    while task.wait() do
        if not Toggles.AutoFish.Value then continue end

        if Fish.Casting then continue end
        Fish.Casting = true
        Remote:FireServer("StartCastFishing")
    end
end))
table.insert(Threads, task.spawn(function() --AutoFishSell
    while task.wait() do
        if not Toggles.AutoFishSell.Value then continue end

        Remote:FireServer("SellFish")
    end
end))
table.insert(Threads, task.spawn(function() --AutoShrines
    while task.wait() do
        if not Toggles.AutoShrines.Value then continue end
        for i,v in AllShrines do
            if not DataSave.Shrines[v] then 
                Remote:FireServer("UseShrine",v)
            else
                local TicketsAmount = (DataSave.GoldenTickets) or 0

                if os.time() < DataSave.Shrines[v].LastUpdateTime + DataSave.Shrines[v].Duration then continue end
                if v == "ticket" and TicketsAmount >= 6 then continue end

                Remote:FireServer("UseShrine",v)
                
                if Debug then
                    print(v)
                end
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --TPMobs
    while task.wait() do
        if not Toggles.TPMobs.Value then continue end
        local Monster = find_nearest_monster()

        if not Monster then continue end
            
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Monster.WorldPivot.Position) * CFrame.new(0, 15, 0)
    end
end))
table.insert(Threads, task.spawn(function() --AutoBoss
    while task.wait() do
        if not Toggles.AutoBoss.Value then continue end

        for i,v in Bosses do
            local State, CurrentHP, MaxHP = canDoBoss()
            local TicketsAmount = (DataSave.GoldenTickets) or 0

            if not State then continue end

            if Toggles.DigsiteBoss.Value then
                if InsideMinigame then continue end
                if TicketsAmount > 0 then continue end
            end

            if workspace.Bosses[v].Display.SurfaceGui.BossDisplay.Cooldown.Visible then continue end
            if workspace.Rendered:FindFirstChild("Generic"):FindFirstChild("Kraken") or workspace.Rendered:FindFirstChild("King Slime") then continue end

            WaitJoinBoss = true

            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(BossAreas[v].Gate.Activation.WorldPivot.Position) * CFrame.new(0, 5, 0)

            repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossPanel.Visible == true or not Toggles.AutoBoss.Value
            if not Toggles.AutoBoss.Value then break end

            local success = nil

            if v == "the-kraken" then
                if Toggles.AutoBosslvl25.Value then
                    success = set_boss_page(math.clamp(BossRecords["the-kraken"] + 1, 0, 25))
                else
                    success = set_boss_page(BossRecords["the-kraken"] + 1)
                end
            elseif v == "king-slime" then
                if Toggles.AutoBosslvl25.Value then
                    success = set_boss_page(math.clamp(BossRecords["king-slime"] + 1, 0, 25))
                else
                    success = set_boss_page(BossRecords["king-slime"] + 1)
                end
            end

            if Debug then
                print(success)
            end

            repeat task.wait() until success or not Toggles.AutoBoss.Value
            if not Toggles.AutoBoss.Value then break end

            if Toggles.DisableKraken.Value then
                BossBypass = true
        
                local old; old = hookfunction(ScreenTransition, function(...)
                    local Table = {...}
            
                    getupvalue(Table[1], 4).FallingAttack = empty
                    getupvalue(Table[1], 4).JumpAttack = empty
                    getupvalue(Table[1], 4).SlamAttack = empty
                    getupvalue(Table[1], 4).SetAngry = empty
                    
                    if Debug then
                        print("Used")
                    end

                    return old(...)
                end)

                if Debug then
                    print("HOOKED")
                end

                while task.wait() do
                    if workspace.Rendered:FindFirstChild("Generic"):FindFirstChild("Kraken") then break end
                    
                    firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossPanel.Frame.Info.Start.Button.Activated)
                    task.wait(3)
                end

                hookfunction(ScreenTransition, old)

                if Debug then
                    print("REWOKED")
                end

                task.wait(1)
                BossBypass = false
            else
                local first = false
                while task.wait() do
                    if workspace.Rendered:FindFirstChild("Generic"):FindFirstChild("Kraken") or workspace.Rendered:FindFirstChild("King Slime") then break end
                    firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossPanel.Frame.Info.Start.Button.Activated)
                    task.wait(3)
                end
            end

            InsideBoss = true
            WaitJoinBoss = false

            repeat 
                task.wait() 
                if not game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossHUD.Visible then
                    game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossHUD.Visible = true
                end
            until game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Visible or not Toggles.AutoBoss.Value

            if not Toggles.AutoBoss.Value then break end
            
            repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.ScreenTransition:FindFirstChild("Circle")

            task.wait(2)
            firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Frame.Body.Buttons.Template.Button.Activated)
            InsideBoss = false

            break
        end
    end
end))
table.insert(Threads, task.spawn(function() --BossGodmode
    while task.wait() do
        if not Toggles.BossGodmode.Value then continue end

        if workspace.Rendered:FindFirstChild("King Slime") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Rendered["King Slime"].PrimaryPart.CFrame * CFrame.new(0, 16, -15)
        elseif workspace.Rendered:FindFirstChild("Generic"):FindFirstChild("Kraken") then
            workspace.Rendered.Generic.Kraken:WaitForChild("Area")
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Rendered.Generic.Kraken.Area.CFrame * CFrame.new(-280, 50, 300)
        end
    end
end))
table.insert(Threads, task.spawn(function() --RespawnKraken
    while task.wait() do
        if not Toggles.RespawnKraken.Value then continue end
        if not workspace.Bosses["the-kraken"].Display.SurfaceGui.BossDisplay.Cooldown.Visible then continue end

        Remote:FireServer("RespawnBoss","the-kraken")
    end
end))
table.insert(Threads, task.spawn(function() --RespawnSlime
    while task.wait() do
        if not Toggles.RespawnSlime.Value then continue end
        if not workspace.Bosses["king-slime"].Display.SurfaceGui.BossDisplay.Cooldown.Visible then continue end 

        Remote:FireServer("RespawnBoss","king-slime")
    end
end))
table.insert(Threads, task.spawn(function() --AutoDigSite
    while task.wait() do
        if not Toggles.DigSite.Value then continue end

        if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.MinigameHUD.Visible then 
            
            WaitJoinMinigame = false

            while task.wait() do
                if not game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.MinigameHUD.Visible then break end

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

                        task.delay(5, function ()
                            table.remove(nearest_table, nearest)
                        end)
                    end
                end

                for _,v in nearest_table do
                    Remote:FireServer("TryMinigameInput",tostring(v))    
                end
            end

            if Debug then
                print("FINISHED GAME!!!")
            end
            task.wait(4)
            InsideMinigame = false
        else
            nearest_table = {}
            if BossBypass then continue end
            if WaitJoinBoss then continue end

            if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Visible then
                firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Frame.Body.Buttons.Template.Button.Activated)
                task.wait(2)
            end
            if DataSave.GoldenTickets == 0 then continue end

            local BestPet = get_minigame_pet()
        
            if Debug then
                print(get_minigame_pet())
            end

            if not Toggles.DigSite.Value then break end
            
            WaitJoinMinigame = true   
            InsideMinigame = true

            task.wait(.1)

            if not game:GetService("UserInputService").TouchEnabled then
                fireproximityprompt(workspace.Rendered.NPCs.Archeologist.HumanoidRootPart.MinigamePrompt)
            end

            task.wait(.5)
            firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Minigame.Frame.Rules.Buy.Button.Activated)
            task.wait(.3)

            game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.PetChoosePrompt.Frame.Body.Content.Pets.Grid.Content.UIGridLayout.CellSize = UDim2.new(0 , 1, 0, 1)
            repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.PetChoosePrompt.Frame.Body.Content.Pets.Grid.Content:FindFirstChild(BestPet)

            firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.PetChoosePrompt.Frame.Body.Content.Pets.Grid.Content[BestPet].Button.Activated) 
            task.wait(.1)

            for _,Start in game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Tooltip.Frame.Buttons:GetChildren() do
                if Start:IsA("Frame") then
                    if Start.Button.BackgroundColor3 ~= Color3.fromRGB(251, 121, 255) then continue end
                    
                    firesignal(Start.Button.Activated)
                end
            end
            game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.PetChoosePrompt.Frame.Body.Content.Pets.Grid.Content.UIGridLayout.CellSize = UDim2.new(0 , 100, 0, 100)
            task.wait(3)
        end
    end
end))
table.insert(Threads, task.spawn(function() --DanceOff
    while task.wait() do
        if not Toggles.DanceOff.Value then continue end

        if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.MinigameHUD.Visible then
            while task.wait() do
                if not game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.MinigameHUD["dance-off"].Visible then break end

                for _,Directions in game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.MinigameHUD["dance-off"]:GetChildren() do
                    if not Directions.Visible then continue end
                    if Directions.Name ~= "Directions" then continue end


                    for i,v in Directions:GetChildren() do
                        if v.Parent == nil then break end
                        if v.Parent.Position == UDim2.new(0, 1524, 0, 566) then 
                            if v.Button.BackgroundTransparency ~= 0 then continue end
                    
                            table.insert(DanceOrder, v)

                            while task.wait() do
                                if v.Button.BackgroundTransparency > 0 then break end
                            end
                        else
                            for i2,v2 in DanceOrder do
                                local args = {
                                    [1] = "TryMinigameInput",
                                    [2] = v2.Name
                                }
                                
                                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                            end

                            DanceOrder = {}

                            while task.wait() do
                                if v.Parent == nil then break end
                                if v.Parent.Position == UDim2.new(0, 1524, 0, 566) then break end
                            end
                        end
                    end
                end
            end

            if Debug then
                print("FINISHED GAME!!!")
            end
            task.wait(4)

            if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Visible then
                firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Frame.Body.Buttons.Template.Button.Activated)
                task.wait(1)
            end
            InsideMinigame = false
        else
            if BossBypass then continue end
            if WaitJoinBoss then continue end
            if InsideBoss then continue end

            if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Visible then
                firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Frame.Body.Buttons.Template.Button.Activated)
                task.wait(2)
            end

            if DataSave.GoldenTickets == 0 then continue end

            local BestPet = get_minigame_pet()
        
            if Debug then
                print(get_minigame_pet())
            end

            if not Toggles.DanceOff.Value then break end
            
            WaitJoinMinigame = true   
            InsideMinigame = true

            task.wait(.1)

            if not game:GetService("UserInputService").TouchEnabled then
                fireproximityprompt(workspace.Rendered.NPCs["Dance Champion"].HumanoidRootPart.MinigamePrompt)
            end

            task.wait(.5)
            firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Minigame.Frame.Rules.Buy.Button.Activated)
            task.wait(.3)

            game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.PetChoosePrompt.Frame.Body.Content.Pets.Grid.Content.UIGridLayout.CellSize = UDim2.new(0 , 1, 0, 1)
            repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.PetChoosePrompt.Frame.Body.Content.Pets.Grid.Content:FindFirstChild(BestPet)

            firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.PetChoosePrompt.Frame.Body.Content.Pets.Grid.Content[BestPet].Button.Activated) 
            task.wait(.1)

            for _,Start in game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Tooltip.Frame.Buttons:GetChildren() do
                if Start:IsA("Frame") then
                    if Start.Button.BackgroundColor3 ~= Color3.fromRGB(251, 121, 255) then continue end
                    
                    firesignal(Start.Button.Activated)
                end
            end
            game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.PetChoosePrompt.Frame.Body.Content.Pets.Grid.Content.UIGridLayout.CellSize = UDim2.new(0 , 100, 0, 100)
            task.wait(3)
        end
    end
end))
table.insert(Threads, task.spawn(function() --BLACKMARKET
    while task.wait() do
        if not Toggles.BLACKMARKET.Value then continue end

        for i2,v2 in Shops["the-blackmarket"].Bought do
            local args = {
                [1] = "BuyShopItem",
                [2] = "the-blackmarket",
                [3] = i2
            }
            
            Remote:FireServer(unpack(args))
        end
        task.wait(1)
    end
end))
table.insert(Threads, task.spawn(function() --Aauburn-shop
    while task.wait() do
        if not Toggles.AShop.Value then continue end

        for i2,v2 in Shops["auburn-shop"].Bought do
            Remote:FireServer("BuyShopItem", "auburn-shop", i2)
        end
        task.wait(1)
    end
end))
table.insert(Threads, task.spawn(function() --Amagic-shop
    while task.wait() do
        if not Toggles.MShop.Value then continue end

        for i2,v2 in Shops["magic-shop"].Bought do
            Remote:FireServer("BuyShopItem", "magic-shop", i2)
        end
        task.wait(1)
    end
end))
table.insert(Threads, task.spawn(function() --Agem-trader
    while task.wait() do
        if not Toggles.GTrader.Value then continue end

        for i2,v2 in Shops["gem-trader"].Bought do
            Remote:FireServer("BuyShopItem", "gem-trader", i2)
        end
        task.wait(1)
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
MenuGroup:AddButton('Unload', function() Library:Unload() end)
local DebugMode; DebugMode = MenuGroup:AddButton('Debug Mode: ' .. tostring(Debug), function() 
    Debug = not Debug
    DebugMode.Label.Text = 'Debug Mode: ' .. tostring(Debug)
end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })
