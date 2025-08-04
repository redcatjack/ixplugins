# Helix Clearance System

A comprehensive clearance and access control system for [Helix](https://github.com/NebulousCloud/helix) based Garry's Mod servers. This plugin allows for granular control over entity and door access through a flexible clearance level system assigned to characters and factions.

## Features

-   **Character & Faction Clearances**: Assign clearance levels directly to a character or set default levels for an entire faction.
-   **Dynamic Door Access**: Admins can look at any map door and assign one or more clearance levels required for access.
-   **Persistent Door Settings**: Door clearance settings are automatically saved on a per-map basis and reloaded on server start.
-   **Configurable Button System**: Define required clearance levels, custom sounds, and delays for any named button entity on the map via a simple configuration file.
-   **Admin Commands**: Admin commands to manage character and door clearances on the fly.
-   **Player Show ID Command**: A simple command for players to display their name, role, and clearance levels in the chat.

## Installation

1.  Place the plugin folder; (`clearancesystem`) into the plugins folder within your Helix schema.
2.  Modify the `sh_config.lua` file to configure button access and review the faction setup instructions.
3.  Restart the server after installation.

## Configuration

All primary configuration is handled in `sh_config.lua`.

### Button Configuration

You can link any named button on your map to a clearance check. The system supports custom sounds and delays for each button. Use the in-game `/ShowEntityName` command while looking at a button to get its name for the config.

**Example `BUTTON_CONFIG` entry from `sh_config.lua`:**

```lua
-- A character needs EITHER "S" or "A" clearance
["main_gate_control"] = { -- The name of the button entity. You can use '/ShowEntityName' to find it.
    clearance = { "S", "A" }, -- The clearances required to activate the button. Only only need to have ONE of these for the button to activate.
    successSound = "buttons/latch3.wav", -- The sound that will play when you have the correct clearance.
    failureSound = "doors/default_locked.wav", -- The sound that will play when you don't have the correct clearance.
    triggerDelay = 0.5 -- Delay of how long before the button's output triggers.
},
```

### Faction Configuration

To set default clearance levels for a faction, add the `ClearanceLevels` field to the faction's definition file (e.g., `sh_citizen.lua`). A character's effective clearance is a combination of their personally assigned levels and their faction's default levels.

-   **For a single default level:**
    ```lua
    FACTION.ClearanceLevels = "1"
    ```
-   **For multiple default levels:**
    ```lua
    FACTION.ClearanceLevels = { "1", "2", "S" }
    ```

## Commands

Commands are prefixed with `/` in the chat (e.g., `/ShowID`).

### Player Command

| Command  | Description                                                                 |
| :------- | :-------------------------------------------------------------------------- |
| `/ShowID` | Displays your character's ID card, showing your name, role, and effective clearance levels. |

### Admin Commands

| Command                 | Description                                                              | Arguments                       |
| :---------------------- | :----------------------------------------------------------------------- | :------------------------------ |
| `/CharClearanceCheck`    | Check a character's specific, faction, and effective clearance levels. | `[Character]`                   |
| `/CharClearanceGive`     | Give a clearance level to a character.                                   | `[Character] [Level]`           |
| `/CharClearanceTake`     | Take a clearance level from a character.                                 | `[Character] [Level]`           |
| `/CharClearanceSet`      | Overwrite a character's levels with a new comma-separated list.        | `[Character] [Levels]`          |
| `/CharClearanceClear`    | Clear all character-specific clearance levels.                           | `[Character]`                   |
| `/DoorClearanceAdd`      | Add a clearance level to the door you are looking at.                    | `[Level]`                       |
| `/DoorClearanceRemove`   | Remove a clearance level from the door you are looking at.               | `[Level]`                       |
| `/DoorClearanceList`     | List all clearance levels on the door you are looking at.                | -                               |
| `/DoorClearanceClear`    | Remove all clearance levels from the door you are looking at.            | -                               |
| `/ShowEntityName`        | Displays the name of the entity you are looking at.                      | -                               |

