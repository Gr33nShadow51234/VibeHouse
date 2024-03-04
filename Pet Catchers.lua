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
-- Locals
local DataSave = getupvalues(require(game:GetService("ReplicatedStorage").Client.Framework.Services.LocalData).Get)[1]
local BossRecords = DataSave.BossRecords
local CraftingList = DataSave.Crafting

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
local BossStuff = require(game:GetService("ReplicatedStorage").Client.Boss)
local BossAreas = workspace.Bosses
local Bosses = {"king-slime","the-kraken"}
local CraftingRecipes = {'rare-cube', 'epic-cube', 'legendary-cube', 'mystery-egg', 'elite-mystery-egg', 'coin-elixir', 'xp-elixir', 'sea-elixir'}
local BossLeft = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossPanel.Frame.Info.Scaling.Left.Button
local BossRight = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossPanel.Frame.Info.Scaling.Right.Button
local InsideBoss = false
local InsideMinigame = false
-- Functions
function find_nearest_enemy()
    local nearest, rarity, nearest_distance = nil, "Common", math.huge
    for i,v in PetRender.WorldPets do
        local dist = (PlayerPart.Position - v.Model.PrimaryPart.Position).Magnitude
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

function find_rare_enemy()
    local rare = nil
    for i,v in PetRender.WorldPets do
        if PetTable[v.Name].Rarity == "Legendary" or PetTable[v.Name].Rarity == "Secret" then
            rare = v
        end
    end
    return rare
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
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Groups
local GeneralBox = Tabs.Main:AddLeftGroupbox('General')
local PetBox = Tabs.Main:AddLeftGroupbox('Pets')
local CraftBox = Tabs.Main:AddLeftTabbox('Crafting')
local MobsBox = Tabs.Main:AddRightGroupbox('Mobs')
local FishBox = Tabs.Main:AddRightGroupbox('Fish')
local MinigameBox = Tabs.Main:AddRightGroupbox('Minigames')

-- Group Tabs
local CraftSlot1 = CraftBox:AddTab('Slot 1')
local CraftSlot2 = CraftBox:AddTab('Slot 2')
local CraftSlot3 = CraftBox:AddTab('Slot 3')
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

MobsBox:AddToggle('AutoBosslvl25', {
    Text = 'Auto Boss lvl 25',
    Default = false, -- Default value (true / false)
    Tooltip = 'Doing bosses without touching', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

MobsBox:AddToggle('AutoBoss', {
    Text = 'Auto Boss',
    Default = false, -- Default value (true / false)
    Tooltip = 'Doing bosses without touching', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
MobsBox:AddToggle('RespawnKraken', {
    Text = 'Respawn Kraken',
    Default = false, -- Default value (true / false)
    Tooltip = 'Respawn Kraken', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})
MobsBox:AddToggle('RespawnSlime', {
    Text = 'Respawn Slime',
    Default = false, -- Default value (true / false)
    Tooltip = 'Respawn Slime', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})


MobsBox:AddToggle('TPMobs', {
    Text = 'TP to Mobs',
    Default = false, -- Default value (true / false)
    Tooltip = 'Teleport to mobs', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

MobsBox:AddToggle('Godmode', {
    Text = 'Godmode',
    Default = false, -- Default value (true / false)
    Tooltip = 'Literally God', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

MobsBox:AddToggle('BossGodmode', {
    Text = 'Boss Godmode',
    Default = false, -- Default value (true / false)
    Tooltip = 'Only for Bosses', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})

MinigameBox:AddToggle('DigSiteMobile', {
    Text = 'Mobile Support | ENABLE ON MOBILE',
    Default = false, -- Default value (true / false)
    Tooltip = '', -- Information shown when you hover over the toggle

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
        print('[cb] MySlider was changed! New value:', Value)
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
        print('[cb] MySlider was changed! New value:', Value)
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
        print('[cb] MySlider was changed! New value:', Value)
    end
})
CraftSlot3:AddToggle('AutoCraftClaim3', {
    Text = 'Craft & Claim',
    Default = false, -- Default value (true / false)
    Tooltip = '', -- Information shown when you hover over the toggle

    Callback = function(Value)
    end
})


table.insert(Threads, task.spawn(function() --AutoCollect
    while task.wait() do
        if Toggles.AutoCollect.Value then
            for i,v in workspace.Rendered.Pickups:GetChildren() do
                v.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoCatch
    while task.wait() do
        if Toggles.AutoCatch.Value then
            if InsideBoss then continue end
            if InsideMinigame then continue end

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
            end
            if Toggles.PrioritizeRare.Value then 

                if find_rare_enemy() then
                    Pet = find_rare_enemy()
                    Cube = get_highest_ball()
                    PRIO = true
                    if Debug then
                        print("Leg / Secret")
                    end
                end
            end

            print(find_highest_enemy())
            repeat
                if not PRIO then
                    if Toggles.PrioritizeShiny.Value then 
                        if find_shiny_enemy() then
                            STOP = true
                        end
                    end
                    if Toggles.PrioritizeRare.Value then 
                        if find_rare_enemy() then
                            STOP = true
                        end
                    end

                    if table.find(PetRarity, Rarity) <= 2 then
                        Cube = get_highest_ball()
                    end
                end

                success = Invoke:InvokeServer("CapturePet", Pet.GUID, Cube)
                task.wait()
            until success or Pet.Model.Parent == nil or Toggles.AutoCatch.Value == false or STOP or InsideBoss or InsideMinigame
            
            if Pet.Model.Parent ~= nil then
                Pet.Model:Destroy()
            end

            --Pet.Model.PrimaryPart.Transparency = old1
            --Pet.Model.PrimaryPart.Color = old2

            if Debug then
                print("GOTCHA")
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoCraftClaim1
    while task.wait() do
        if Toggles.AutoCraftClaim1.Value then
            if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Crafting.Frame.Body.Slot1.Content.Craft.Visible then 
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("StartCrafting", 1, Options.SelectRecipe1.Value, Options.SelectAmount1.Value)   
            elseif game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Crafting.Frame.Body.Slot1.Content.Claim.Visible then
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("ClaimCrafting", 1)
            else 
                if Debug then
                    print("Wait Slot 1")
                end
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoCraftClaim2
    while task.wait() do
        if Toggles.AutoCraftClaim2.Value then
            if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Crafting.Frame.Body.Slot2.Content.Craft.Visible then 
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("StartCrafting", 2, Options.SelectRecipe2.Value, Options.SelectAmount2.Value)  
            elseif game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Crafting.Frame.Body.Slot2.Content.Claim.Visible then
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("ClaimCrafting", 2)
            else 
                if Debug then
                    print("Wait Slot 2")
                end
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoCraftClaim3
    while task.wait() do
        if Toggles.AutoCraftClaim3.Value then
            if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Crafting.Frame.Body.Slot3.Content.Craft.Visible then 
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("StartCrafting", 3, Options.SelectRecipe3.Value, Options.SelectAmount3.Value)  
            elseif game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Crafting.Frame.Body.Slot3.Content.Claim.Visible then
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("ClaimCrafting", 3)
            else 
                if Debug then
                    print("Wait Slot 3")
                end
            end
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
table.insert(Threads, task.spawn(function() --AutoOpen
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
table.insert(Threads, task.spawn(function() --TPMobs
    while task.wait() do
        if Toggles.TPMobs.Value then
            local Monster = find_nearest_monster()
            if Monster then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Monster.WorldPivot.Position) * CFrame.new(0, 15, 0)
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoBoss
    while task.wait() do
        if Toggles.AutoBoss.Value then
            if InsideMinigame then continue end

            for i,v in Bosses do
                local State, CurrentHP, MaxHP = canDoBoss()
                if State then
                    if workspace.Bosses[v].Display.SurfaceGui.BossDisplay.Cooldown.Visible then continue end
                    if workspace.Rendered:FindFirstChild("Generic"):FindFirstChild("Kraken") or workspace.Rendered:FindFirstChild("King Slime") then continue end

                    InsideBoss = true

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

                    print(success)
                    repeat task.wait() until success or not Toggles.AutoBoss.Value
                    if not Toggles.AutoBoss.Value then break end

                    firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.BossPanel.Frame.Info.Start.Button.Activated)

                    repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Visible or not Toggles.AutoBoss.Value
                    if not Toggles.AutoBoss.Value then break end

                    firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Frame.Body.Buttons.Template.Button.Activated)
                    task.wait(2)
                    InsideBoss = false

                    break
                end
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --BossGodmode
    while task.wait() do
        if Toggles.BossGodmode.Value then
            if workspace.Rendered:FindFirstChild("King Slime") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Rendered["King Slime"].PrimaryPart.CFrame * CFrame.new(0, 16, -15)
            elseif workspace.Rendered:FindFirstChild("Generic"):FindFirstChild("Kraken") then
                workspace.Rendered.Generic.Kraken:WaitForChild("Area")
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Rendered.Generic.Kraken.Area.CFrame * CFrame.new(-280, 50, 300)
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --RespawnKraken
    while task.wait() do
        if Toggles.RespawnKraken.Value then
            if workspace.Bosses["the-kraken"].Display.SurfaceGui.BossDisplay.Cooldown.Visible then 
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("RespawnBoss","the-kraken")                
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --RespawnSlime
    while task.wait() do
        if Toggles.RespawnSlime.Value then
            if workspace.Bosses["king-slime"].Display.SurfaceGui.BossDisplay.Cooldown.Visible then 
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("RespawnBoss","king-slime")                
            end
        end
    end
end))
table.insert(Threads, task.spawn(function() --AutoDigSite
    while task.wait() do
        if Toggles.DigSite.Value then
            local State, CurrentHP, MaxHP = canDoBoss()

            if InsideBoss then continue end

            if not Toggles.DigSite.Value then break end

            if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.MinigameHUD.Visible then 
                repeat 
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
                    task.wait()

                until not game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.MinigameHUD.Visible

                repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Visible 
                firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Frame.Body.Buttons.Template.Button.Activated)

                print("FINISHED GAME!!!")
                task.wait(5)

                InsideMinigame = false
            else
                nearest_table = {}

                if not game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.HUD.Visible then continue end
                if not Toggles.DigSite.Value then break end

                if game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Visible then
                    firesignal(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Popup.Frame.Body.Buttons.Template.Button.Activated)
                    task.wait(2)
                end
                if not Toggles.DigSite.Value then break end

                if DataSave.GoldenTickets == 0 then continue end
                local BestPet = get_minigame_pet()
            
                if Debug then
                    print(get_minigame_pet())
                end

                if not Toggles.DigSite.Value then break end
                
                InsideMinigame = true
                
                if not Toggle.DigSiteMobile.Value then
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
MenuGroup:AddButton('Debug Mode', function() Debug = not Debug end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })
