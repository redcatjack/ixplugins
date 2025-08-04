-- Created by redcatjack https://steamcommunity.com/id/redcatjack/

local PLUGIN = PLUGIN

-- --------------------------------------------------------------------------------------------------
-- PLAYER COMMANDS - I don't recommend editing in here unless you know what you are doing.
-- --------------------------------------------------------------------------------------------------

-- Add Show ID command
ix.command.Add("ShowID", {
    name = "Show ID",
    description = "Display your character's ID card.",
    OnRun = function(self, client)
        local character = client:GetCharacter()
        if (not character) then return end

        local faction = ix.faction.Get(character:GetFaction())
        if (not faction) then return end

        -- Get character-specific levels
        local charLevels = character:GetData("clearanceLevels", {})

        -- Get faction default levels
        local factionLevels = {}
        if (faction and faction.ClearanceLevels) then
            if (type(faction.ClearanceLevels) == "table") then
                factionLevels = faction.ClearanceLevels
            elseif (type(faction.ClearanceLevels) == "string") then
                factionLevels = { faction.ClearanceLevels }
            end
        end

        -- Combine and get effective levels
        local combinedLevels = {}
        for _, level in ipairs(charLevels) do combinedLevels[level] = true end
        for _, level in ipairs(factionLevels) do combinedLevels[level] = true end
        local effectiveLevels = {}
        for level, _ in pairs(combinedLevels) do table.insert(effectiveLevels, level) end
        local effectiveLevelsString = table.concat(effectiveLevels, ", ")
        if (effectiveLevelsString == "") then effectiveLevelsString = "None" end

        -- Construct the ID string and send it via the /me chat class.
        local idString = string.format("shows their ID. Name: %s | Role: %s | Clearance(s): %s",
            character:GetName(),
            faction.name,
            effectiveLevelsString
        )
        
        ix.chat.Send(client, "me", idString)
    end
})

-- --------------------------------------------------------------------------------------------------
-- ADMIN COMMANDS - I don't recommend editing in here unless you know what you are doing.
-- --------------------------------------------------------------------------------------------------

-- Add a command to check a character's clearance levels.
ix.command.Add("CharClearanceCheck", {
    name = "Check Clearance",
    description = "Check a character's clearance levels.",
    adminOnly = true,
    arguments = { ix.type.character },
    OnRun = function(self, client, target)
        -- Character-specific levels
        local charLevels = target:GetData("clearanceLevels", {})
        local charLevelsString = table.concat(charLevels, ", ")
        if (charLevelsString == "") then charLevelsString = "None" end
        ix.util.Notify("Character-Specific Levels: "..charLevelsString, client)

        -- Faction default levels
        local faction = ix.faction.Get(target:GetFaction())
        local factionLevels = {}
        local factionLevelsString = "None (Faction has no defaults)"
        if (faction and faction.ClearanceLevels) then
            if (type(faction.ClearanceLevels) == "table") then
                factionLevels = faction.ClearanceLevels
            elseif (type(faction.ClearanceLevels) == "string") then
                factionLevels = { faction.ClearanceLevels }
            end
            factionLevelsString = table.concat(factionLevels, ", ")
        end
        ix.util.Notify("Faction ('"..faction.name.."') Default Levels: "..factionLevelsString, client)

        -- Effective levels (merged)
        local combinedLevels = {}
        for _, level in ipairs(charLevels) do combinedLevels[level] = true end
        for _, level in ipairs(factionLevels) do combinedLevels[level] = true end
        local effectiveLevels = {}
        for level, _ in pairs(combinedLevels) do table.insert(effectiveLevels, level) end
        local effectiveLevelsString = table.concat(effectiveLevels, ", ")
        if (effectiveLevelsString == "") then effectiveLevelsString = "None" end

        ix.util.Notify(target:GetName().."'s Effective Clearance: "..effectiveLevelsString, client)
    end
})

-- Add command to give a clearance level to a character.
ix.command.Add("CharClearanceGive", {
    name = "Give Clearance",
    description = "Give a clearance level to a character.",
    adminOnly = true,
    arguments = { ix.type.character, ix.type.string },
    OnRun = function(self, client, target, level)
        local levels = target:GetData("clearanceLevels", {})
        
        -- Avoid adding duplicate levels
        for _, existingLevel in ipairs(levels) do
            if (existingLevel == level) then
                ix.util.Notify(target:GetName().." already has the '"..level.."' clearance level.", client)
                return
            end
        end

        table.insert(levels, level)
        target:SetData("clearanceLevels", levels)

        ix.util.Notify(client:Name().." gave you the '"..level.."' clearance level.", target:GetPlayer())
        ix.util.Notify("You gave "..target:GetName().." the '"..level.."' clearance level.", client)
    end
})

-- Add command to take a clearance level from a character.
ix.command.Add("CharClearanceTake", {
    name = "Take Clearance",
    description = "Take a clearance level from a character.",
    adminOnly = true,
    arguments = { ix.type.character, ix.type.string },
    OnRun = function(self, client, target, level)
        local levels = target:GetData("clearanceLevels", {})
        local newLevels = {}
        local found = false

        for _, existingLevel in ipairs(levels) do
            if (existingLevel ~= level) then
                table.insert(newLevels, existingLevel)
            else
                found = true
            end
        end

        if (not found) then
            ix.util.Notify(target:GetName().." does not have the '"..level.."' clearance level.", client)
            return
        end

        target:SetData("clearanceLevels", newLevels)

        ix.util.Notify(client:Name().." took your '"..level.."' clearance level.", target:GetPlayer())
        ix.util.Notify("You took the '"..level.."' clearance level from "..target:GetName()..".", client)
    end
})

-- Add a command to set a character's clearance levels, overwriting old ones.
ix.command.Add("CharClearanceSet", {
    name = "Set Clearance",
    description = "Set a character's clearance levels (comma separated).",
    adminOnly = true,
    arguments = { ix.type.character, ix.type.text },
    OnRun = function(self, client, target, levelsString)
        local levels = {}
        for level in string.gmatch(levelsString, "([^,]+)") do
            table.insert(levels, string.Trim(level))
        end

        target:SetData("clearanceLevels", levels)
        local newLevelsString = table.concat(levels, ", ")
        if (newLevelsString == "") then newLevelsString = "None" end

        ix.util.Notify(client:Name().." set your clearance levels to: "..newLevelsString, target:GetPlayer())
        ix.util.Notify("You set "..target:GetName().."'s clearance levels to: "..newLevelsString, client)
    end
})

-- Add a command to clear all clearance levels from a character.
ix.command.Add("CharClearanceClear", {
    name = "Clear Clearance",
    description = "Clear all character-specific clearance levels.",
    adminOnly = true,
    arguments = { ix.type.character },
    OnRun = function(self, client, target)
        target:SetData("clearanceLevels", {})

        ix.util.Notify(client:Name().." cleared all of your character-specific clearance levels.", target:GetPlayer())
        ix.util.Notify("You cleared all character-specific clearance levels from "..target:GetName()..".", client)
    end
})

-- --------------------------------------------------------------------------------------------------
-- DOOR COMMANDS - I don't recommend editing in here unless you know what you are doing.
-- --------------------------------------------------------------------------------------------------

--A dd a command to add clearance levels to doors.
ix.command.Add("DoorClearanceAdd", {
    description = "Add a clearance level to the door you're looking at.",
    adminOnly = true,
    arguments = {ix.type.string},
    OnRun = function(self, client, level)
        local trace = util.TraceLine({
            start = client:EyePos(),
            endpos = client:EyePos() + client:GetAimVector() * 96,
            filter = client
        })

        local target = trace.Entity or trace.entity

        if not IsValid(target) then
            return client:Notify("You're not looking at a valid object.")
        end

        if not target:IsDoor() and not target:GetClass():lower():find("door") then
            return client:Notify("The object you're looking at is not a door.")
        end

        local levels = target:GetClearanceLevels()
        for _, v in ipairs(levels) do
            if v == level then
                return client:Notify("That door already has that clearance level.")
            end
        end

        -- Add the clearance level
        table.insert(levels, level)
        target:SetClearanceLevels(levels)

        -- Lock the door
        target:Fire("Lock", "", 0)

        -- Attempt to disable touch activation, doesn't always work though, but we do lock the door :)
        local currentFlags = target:GetSpawnFlags()
        local newFlags = bit.bor(currentFlags, 256) -- 256 = Starts Locked
        target:SetKeyValue("spawnflags", tostring(newFlags))

        -- Save updated data
        PLUGIN:SaveDoorClearances()

        client:Notify("Added clearance level '" .. level .. "' to the door and locked it.")
    end
})

-- Command to remove clearance levels from doors.
ix.command.Add("DoorClearanceRemove", {
    description = "Remove a clearance level from the door you're looking at.",
    adminOnly = true,
    arguments = {ix.type.string},
    OnRun = function(self, client, level)
        local trace = util.TraceLine({
            start = client:EyePos(),
            endpos = client:EyePos() + client:GetAimVector() * 96,
            filter = client
        })

        local target = trace.Entity or trace.entity

        if not IsValid(target) then
            return client:Notify("You're not looking at a valid object.")
        end

        if not target:IsDoor() and not target:GetClass():lower():find("door") then
            return client:Notify("The object you're looking at is not a door.")
        end

        local levels = target:GetClearanceLevels()
        local removed = false

        for i, v in ipairs(levels) do
            if v == level then
                table.remove(levels, i)
                removed = true
                break
            end
        end

        if not removed then
            return client:Notify("That clearance level was not found on the door.")
        end

        target:SetClearanceLevels(levels)
        PLUGIN:SaveDoorClearances()

        -- If no more clearance levels exist, unlock the door
        if #levels == 0 then
            target:Fire("Unlock", "", 0)
            client:Notify("Removed clearance level '" .. level .. "'. The door is now unlocked.")
        else
            client:Notify("Removed clearance level '" .. level .. "' from the door.")
        end
    end
})

-- Command to list all clearance levels on the door.
ix.command.Add("DoorClearanceList", {
    description = "List all clearance levels assigned to the door you're looking at.",
    adminOnly = true,
    OnRun = function(self, client)
        local trace = client:GetEyeTrace()
        local target = trace.Entity

        if not IsValid(target) or not target:IsDoor() then
            return "You're not looking at a valid door."
        end

        local levels = target:GetClearanceLevels()

        if #levels == 0 then
            return "This door has no clearance levels assigned."
        end

        return "Clearance levels on this door: " .. table.concat(levels, ", ")
    end
})

-- Command to remove ALL clearances from the door.
ix.command.Add("DoorClearanceClear", {
    description = "Remove all clearance levels from the door you're looking at.",
    adminOnly = true,
    OnRun = function(self, client)
        local trace = util.TraceLine({
            start = client:EyePos(),
            endpos = client:EyePos() + client:GetAimVector() * 96,
            filter = client
        })

        local target = trace.Entity or trace.entity

        if not IsValid(target) then
            return client:Notify("You're not looking at a valid object.")
        end

        if not target:IsDoor() and not target:GetClass():lower():find("door") then
            return client:Notify("The object you're looking at is not a door.")
        end

        target:SetClearanceLevels({})
        target:Fire("Unlock", "", 0) -- Unlock the door
        PLUGIN:SaveDoorClearances()

        client:Notify("All clearance levels have been removed from this door. It is now unlocked.")
    end
})

-- Command to show the name of the entity you are looking at. Useful for getting the names of buttons.
ix.command.Add("ShowEntityName", {
    name = "Show Entity Name",
    description = "Displays the name of the Entity you're looking at.",
    adminOnly = true,
    OnRun = function(self, client)
        local trace = client:GetEyeTrace()
        local ent = trace.Entity

        if (not IsValid(ent)) then
            ix.util.Notify("You're not looking at a valid entity.", client)
            return
        end

        local name = ent:GetName()
        if (name == "") then
            ix.util.Notify("This entity has no name set.", client)
        else
            client:ChatNotify("Entity name: " .. name, client)
        end
    end
})