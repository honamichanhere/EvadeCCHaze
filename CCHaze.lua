local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local function getCosmeticsFolder()
    local items = ReplicatedStorage:WaitForChild("Items", 5)
    if not items then return nil end
    local itemPack = items:FindFirstChild("ItemPacks")
    if not itemPack then return nil end
    local base = itemPack:FindFirstChild("Base")
    if not base then return nil end
    local special = base:FindFirstChild("Special")
    if not special then return nil end
    local cosmetics = special:FindFirstChild("Cosmetics")
    if not cosmetics then return nil end
    
    return cosmetics:FindFirstChild("CCHaze")
end

local cosmeticsFolder = getCosmeticsFolder()
if not cosmeticsFolder then
    return 
end 

local sourceR6 = cosmeticsFolder:FindFirstChild("CharacterClassic")
local sourceR15 = cosmeticsFolder:FindFirstChild("Character")

local memoryRigs = {}
local memoryPlayers = {}

local function simpenKeMemory(sourceFolder)
    if not sourceFolder then return end
    
    for _, partFolder in ipairs(sourceFolder:GetChildren()) do
        
        local unusualAttach = partFolder:FindFirstChild("UnusualAttach")
        if unusualAttach then
            local clone = unusualAttach:Clone()
            clone.Name = "CCHaze_" .. partFolder.Name
            memoryRigs[partFolder.Name] = clone
        end

        if partFolder.Name == "HumanoidRootPart" then
            local smoke = partFolder:FindFirstChild("SmokeAttack")
            if smoke then
                local clone = smoke:Clone()
                clone.Name = "CCHaze_SmokeAttack" 
                memoryPlayers["SmokeAttack"] = clone
            end
            
            local dots = partFolder:FindFirstChild("dots")
            if dots then
                local clone = dots:Clone()
                clone.Name = "CCHaze_dots"
                memoryPlayers["dots"] = clone
            end
        end
    end
end

simpenKeMemory(sourceR6)
simpenKeMemory(sourceR15)

local function applyCosmeticsToRig(rig)
    if not rig then return end
    
    for partName, storedItem in pairs(memoryRigs) do
        local targetBodyPart = rig:FindFirstChild(partName)
        
        if targetBodyPart then
            local function attachItem()
                if targetBodyPart:FindFirstChild(storedItem.Name) then return end
                
                local finalClone = storedItem:Clone()
                finalClone.Parent = targetBodyPart
                
                local connection
                connection = finalClone.AncestryChanged:Connect(function(_, newParent)
                    if not newParent then
                        connection:Disconnect()
                        task.defer(function()
                            if targetBodyPart and targetBodyPart.Parent then attachItem() end
                        end)
                    end
                end)
            end
            attachItem()
        end
    end
end

local function applyCosmeticsToPlayerModel(playerModel)
    if not playerModel then return end
    
    local hrp = playerModel:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, storedItem in pairs(memoryPlayers) do
        local function attachHrpItem()
            if hrp:FindFirstChild(storedItem.Name) then return end
            
            local finalClone = storedItem:Clone()
            finalClone.Parent = hrp
            
            local connection
            connection = finalClone.AncestryChanged:Connect(function(_, newParent)
                if not newParent then
                    connection:Disconnect()
                    task.defer(function()
                        if hrp and hrp.Parent then attachHrpItem() end
                    end)
                end
            end)
        end
        attachHrpItem()
    end
end

local rigsFolder = Workspace:WaitForChild("Rigs")
local playersFolder = Workspace:WaitForChild("Players")

local function checkInitial()
    local myRig = rigsFolder:FindFirstChild(LocalPlayer.Name)
    if myRig then 
        task.wait(1)
        applyCosmeticsToRig(myRig) 
    end
    
    local myPlayerModel = playersFolder:FindFirstChild(LocalPlayer.Name)
    if myPlayerModel then
        task.wait(1)
        applyCosmeticsToPlayerModel(myPlayerModel)
    end
end
checkInitial()

rigsFolder.ChildAdded:Connect(function(child)
    if child.Name == LocalPlayer.Name then
        task.wait(1) 
        applyCosmeticsToRig(child)
    end
end)

playersFolder.ChildAdded:Connect(function(child)
    if child.Name == LocalPlayer.Name then
        task.wait(1) 
        applyCosmeticsToPlayerModel(child)
    end
end)
