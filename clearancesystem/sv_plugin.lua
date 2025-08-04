-- --------------------------------------------------------------------------------------------------
-- SERVERSIDE CODE - I don't recommend editing in here unless you know what you are doing.
-- --------------------------------------------------------------------------------------------------
local PLUGIN = PLUGIN
   

-- Check if player has required clearance
local function HasRequiredClearance(player, requiredLevels)
    local character = player:GetCharacter()
    if not character then return false end

    local charLevels = character:GetData("clearanceLevels", {})
    local faction = ix.faction.Get(character:GetFaction())
    local factionLevels = {}

    if faction and faction.ClearanceLevels then
        if type(faction.ClearanceLevels) == "table" then
            factionLevels = faction.ClearanceLevels
        else
            factionLevels = { faction.ClearanceLevels }
        end
    end

    local combined = {}
    for _, level in ipairs(charLevels) do combined[level] = true end
    for _, level in ipairs(factionLevels) do combined[level] = true end

    for _, required in ipairs(requiredLevels) do
        if combined[required] then return true end
    end

    return false
end

-- Handle button use and clearance check
local playerCooldowns = {}

hook.Add("AcceptInput", "zz_ClearanceButtonCheck", function(entity, input, activator, caller)
    if not SERVER or input ~= "Use" or not IsValid(activator) or not activator:IsPlayer() then return end

    local entityName = entity:GetName()
    local config = BUTTON_CONFIG[entityName]
    
    local doorClearances = {}
    if (entity and IsValid(entity) and entity.GetClearanceLevels) then
        doorClearances = entity:GetClearanceLevels() or {}
    end

    local player = activator
    local plySteamID = player:SteamID()
    playerCooldowns[plySteamID] = playerCooldowns[plySteamID] or {}

    -- If there's no clearance config for this entity at all, ignore it and allow default behavior.
    if not config and #doorClearances == 0 then
        return
    end

    -- Prevent spamming
    if playerCooldowns[plySteamID][entityName] and CurTime() < playerCooldowns[plySteamID][entityName] then
        return true
    end

    -- Determine required clearances. Button config takes precedence over generic door clearances.
    local required = (config and config.clearance) or doorClearances

    if #required == 0 then
        return
    end

    -- Perform the clearance check
    if not HasRequiredClearance(player, required) then
    -- ACCESS DENIED
        local failureSound = (config and config.failureSound) or "doors/default_locked.wav"
        entity:EmitSound(failureSound)
        ix.util.Notify("Access denied! You do not have the required clearance level.", player)
        playerCooldowns[plySteamID][entityName] = CurTime() + 2
        return true -- Block the 'Use' action
    end

-- ACCESS GRANTED
    local successSound = (config and config.successSound)
    local delay = (config and config.triggerDelay) or 0 
    if (successSound) then
        entity:EmitSound(successSound)
    end
    
    -- Set a cooldown to prevent spam
    playerCooldowns[plySteamID][entityName] = CurTime() + delay + 4

    timer.Simple(delay, function()
        if not IsValid(entity) then return end

        -- Check to see if the entity is a door
        local isDoor = (entity:IsDoor() or string.find(entity:GetClass():lower(), "door"))

        -- If the entity is a door and has clearances, run the automated cycle.
        -- This logic now correctly takes priority for any entity that is a door.
        if isDoor and #doorClearances > 0 then
            entity:Fire("Unlock", "", 0)
            entity:Fire("Open", "", 0.1)

            -- Timer to close and re-lock the door
            timer.Simple(4, function()
                if IsValid(entity) then
                    entity:Fire("Close", "", 0)
                    entity:Fire("Lock", "", 0.1)
                end
            end)
        -- Otherwise, if it's just a configured button and not a door
        elseif config then
            local outputsFired = false
            if entity.GetOutputs then
                local outputs = entity:GetOutputs()
                if outputs and #outputs > 0 then
                    for _, output in ipairs(outputs) do
                        if output.output == "OnPressed" then
                            local targets = ents.FindByName(output.target)
                            for _, targetEnt in ipairs(targets) do
                                if IsValid(targetEnt) then
                                    targetEnt:Fire(output.input, output.parm, output.delay)
                                    outputsFired = true
                                end
                            end
                        end
                    end
                end
            end

            if not outputsFired then
                entity:Fire("Use", "", 0)
            end
        end
    end)

    return true
end)


local entityMeta = FindMetaTable("Entity")

function entityMeta:SetClearanceLevels(levels)
    self:SetNetVar("clearanceLevels", levels or {})
end


function entityMeta:GetClearanceLevels()
    return self:GetNetVar("clearanceLevels", {})
end

local function SaveDoorClearances()
    local data = {}

    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:IsDoor() and ent.GetClearanceLevels and #ent:GetClearanceLevels() > 0 then
            local pos = ent:GetPos()
            local id = tostring(pos.x) .. "_" .. tostring(pos.y) .. "_" .. tostring(pos.z)

            data[id] = {
                pos = {x = pos.x, y = pos.y, z = pos.z},
                levels = ent:GetClearanceLevels()
            }
        end
    end
    
    local fileName = game.GetMap() .. "_door_clearances.txt"
    file.Write(fileName, util.TableToJSON(data, true))
    print("[ClearanceSystem] Saved door clearance data for map " .. game.GetMap())
end

hook.Add("ShutDown", "SaveDoorClearancesOnShutdown", SaveDoorClearances)

function PLUGIN:SaveDoorClearances()
    local data = {}

    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:IsDoor() and ent.GetClearanceLevels and #ent:GetClearanceLevels() > 0 then
            local pos = ent:GetPos()
            local id = tostring(pos.x) .. "_" .. tostring(pos.y) .. "_" .. tostring(pos.z)

            data[id] = {
                pos = {x = pos.x, y = pos.y, z = pos.z},
                levels = ent:GetClearanceLevels()
            }
        end
    end

    local fileName = game.GetMap() .. "_door_clearances.txt"
    file.Write(fileName, util.TableToJSON(data, true))
    print("[ClearanceSystem] Saved door clearance data for map " .. game.GetMap())
end

local function LoadDoorClearances()
    local fileName = game.GetMap() .. "_door_clearances.txt"

    if not file.Exists(fileName, "DATA") then
        print("[ClearanceSystem] No saved door clearance data found for map " .. game.GetMap())
        return
    end

    local raw = file.Read(fileName, "DATA")
    if not raw or raw == "" then return end
    local data = util.JSONToTable(raw)

    if not data then return end

    local restored = 0

    for id, info in pairs(data) do
        local pos = Vector(info.pos.x, info.pos.y, info.pos.z)

        for _, ent in ipairs(ents.FindInSphere(pos, 5)) do
            if IsValid(ent) and ent:IsDoor() and ent.SetClearanceLevels then
                ent:SetClearanceLevels(info.levels)
                ent:Fire("Lock", "", 0)
                restored = restored + 1
                break
            end
        end
    end

    print("[ClearanceSystem] Loaded " .. restored .. " door(s) for map " .. game.GetMap())
end

hook.Add("InitPostEntity", "LoadDoorClearancesOnStart", LoadDoorClearances)