-- Created by redcatjack https://steamcommunity.com/id/redcatjack/

local PLUGIN = PLUGIN

-- --------------------------------------------------------------------------------------------------
-- CONFIGURATION
-- --------------------------------------------------------------------------------------------------

--[[
This table maps button names to their required clearance levels and sounds.
A character only needs ONE of the listed clearance levels to gain access.
Clearances can be anything you want, for example full words like "Security" and "level_1" but I recommend using single letters or digits to keep things easier, such as "S" and "1".

Recommended clearances: "1", "2", "3", "4", "X", "M", "S", "H", "A"


Format for a single clearance:
    ["button_entity_name"] = { -- Name of the button
        clearance = { "1" }, -- What clearances can access it
        successSound = "buttons/button14.wav", -- Example sound path
        failureSound = "bms_objects/doors/retinalscanner_access_denied01.wav", -- Example sound path
        triggerDelay = 1.5 -- Delay before the button fires in seconds
},

Format for multiple clearances, seperate with commas:
    ["button_entity_name"] = { -- Name of the button
        clearance = { "1", "2", "S" }, -- What clearances can access it
        successSound = "buttons/button14.wav", -- Example sound path
        failureSound = "bms_objects/doors/retinalscanner_access_denied01.wav", -- Example sound path
        triggerDelay = 5 -- Delay before the button fires in seconds
},

--]]

BUTTON_CONFIG = {
    ["main_door_scanner_button1a"] = {
        clearance = { "1" },
        successSound = "buttons/button14.wav",
        failureSound = "bms_objects/doors/retinalscanner_access_denied01.wav",
        triggerDelay = 0
    },
    ["main_door_scanner_button1b"] = {
        clearance = { "1" },
        successSound = "buttons/button14.wav",
        failureSound = "bms_objects/doors/retinalscanner_access_denied01.wav",
        triggerDelay = 0
    },
    ["restricted_area_button"] = {
        clearance = { "S" },
        successSound = "buttons/button10.wav",
        failureSound = "bms_objects/doors/retinalscanner_access_denied01.wav",
        triggerDelay = 2
    },
    ["main_gate_control"] = {
        clearance = { "S", "A" },
        successSound = "buttons/latch3.wav",
        failureSound = "doors/default_locked.wav",
        triggerDelay = 0.5
    }
}

--[[
    FACTION SETUP:
    To set default clearance levels for a faction, add the 'ClearanceLevels' field
    to your faction file (e.g., sh_citizen.lua).

    Example for a single level:
    FACTION.ClearanceLevels = "1"

    Example for multiple levels:
    FACTION.ClearanceLevels = { "1", "2", "S" }
]]