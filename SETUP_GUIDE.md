# Mega Man Battle Arena - UEFN Setup Guide

A Fortnite Creative experience inspired by Mega Man: Dr. Wily's Revenge, featuring 8 Robot Masters from Mega Man 1 and 2 in a multiplayer boss rush format.

## Overview

This experience recreates the classic "Final Rebattles" stage from Mega Man games:
- A central hub room with 8 portals (4 on each side)
- Each portal leads to a boss fight
- Defeat bosses to acquire their weapons
- Use acquired weapons against other bosses (Rock-Paper-Scissors weakness system)

## Bosses and Weapons

| Boss | Weapon Acquired | Weakness |
|------|-----------------|----------|
| Cut Man | Rolling Cutter | Fire Storm |
| Ice Man | Ice Slasher | Thunder Beam |
| Fire Man | Fire Storm | Ice Slasher |
| Elec Man | Thunder Beam | Rolling Cutter |
| Quick Man | Quick Boomerang | Time Stopper |
| Flash Man | Atomic Fire | Ice Slasher |
| Heat Man | Crash Bomber | Fire Storm |
| Bubble Man | Time Stopper | Quick Boomerang |

## Project Structure

```
Content/MegaManBattleArena/
├── Verse/
│   ├── WeaponTypes.verse           # Weapon and boss configuration
│   ├── HomingProjectile.verse      # Projectile pool and homing logic
│   ├── PlayerWeaponManager.verse   # Player weapon state and switching
│   ├── BossAI.verse                # Boss AI behavior and states
│   ├── PortalSystem.verse          # Portal hub and teleportation
│   ├── CombatSystem.verse          # Damage calculation and collision
│   ├── PlayerInputHandler.verse    # Input handling (L/R weapon switch)
│   ├── MegaManBattleArenaManager.verse  # Main game controller
│   └── vmodule.build.verse         # Build configuration
├── Assets/
│   ├── Textures/                   # Projectile and boss textures
│   ├── Materials/                  # Materials for color changes
│   └── Sounds/                     # Sound effects and music
└── MegaManBattleArena.uplugin      # Plugin manifest
```

## Setup Instructions

### 1. Create New UEFN Project

1. Open Unreal Editor for Fortnite (UEFN)
2. Create a new Fortnite Creative project
3. Copy the `Content/MegaManBattleArena` folder into your project's Content directory

### 2. Build the Hub Room

Create a central arena room with:
- 8 platform locations for portals (4 on left wall, 4 on right wall)
- Platforms arranged vertically so players can jump between them
- Each platform should have enough space for a portal entrance

**Portal Layout (looking from center):**
```
LEFT SIDE                    RIGHT SIDE
[Elec Man]                   [Bubble Man]
[Fire Man]                   [Heat Man]
[Ice Man]                    [Flash Man]
[Cut Man]                    [Quick Man]
```

### 3. Configure Devices

For each boss, you'll need to place and configure:

#### Portal Devices (x8)
- `teleporter_device` - Entry portal
- `teleporter_device` - Exit portal (in boss room)
- `prop_mover_device` - Boss hologram display
- `vfx_spawner_device` - Portal visual effect
- `billboard_device` - Completed indicator
- `audio_player_device` - Enter/exit sounds

#### Boss Room Devices (x8)
- `guard_spawner_device` - Boss NPC spawner
- `damage_volume_device` - Boss attack damage
- `vfx_spawner_device` - Spawn, death, hit effects
- `audio_player_device` - Boss sounds
- `billboard_device` - Health bar display

#### Player Devices
- `button_device` (x3) - Fire, Next Weapon, Previous Weapon
- `billboard_device` (x3) - Weapon display, energy bar, charge indicator
- `vfx_spawner_device` (x3) - Charge level visual effects
- `audio_player_device` - Weapon sounds

#### Game Manager Devices
- `player_spawner_device` - Player spawn point
- `audio_player_device` (x6) - Music and sound effects

### 4. Link Verse Scripts to Devices

1. Create a new Creative Device for each Verse class
2. In the Details panel, assign the appropriate device references
3. Set the `BossTypeIndex` for each boss portal (0-7)

### 5. Projectile Visuals

For the prototype, all weapons use simple homing projectiles. Configure visual differences using:

| Weapon | Color | Shape Suggestion |
|--------|-------|------------------|
| Mega Buster | Blue | Small sphere |
| Rolling Cutter | White/Silver | Spinning blade |
| Ice Slasher | Ice Blue | Crystal shard |
| Fire Storm | Orange | Flame orb |
| Thunder Beam | Yellow | Lightning bolt |
| Quick Boomerang | Red | Boomerang shape |
| Atomic Fire | Bright Orange | Large fireball |
| Crash Bomber | Dark Red | Bomb shape |
| Time Stopper | Purple | Alarm clock |

### 6. Player Color Changes

When a player switches weapons, their skin color should change:

| Weapon | RGB Color |
|--------|-----------|
| Mega Buster | (0, 112, 255) - Classic Blue |
| Rolling Cutter | (255, 255, 255) - White |
| Ice Slasher | (150, 220, 255) - Ice Blue |
| Fire Storm | (255, 100, 0) - Orange |
| Thunder Beam | (255, 255, 0) - Yellow |
| Quick Boomerang | (255, 50, 50) - Red |
| Atomic Fire | (255, 150, 0) - Bright Orange |
| Crash Bomber | (200, 50, 0) - Dark Red |
| Time Stopper | (128, 0, 128) - Purple |

## Gameplay Features

### Weapon Switching (L/R Style)
- Press Next Weapon button to cycle forward through acquired weapons
- Press Previous Weapon button to cycle backward
- Only shows weapons the player has acquired
- All players start with Mega Buster only

### Mega Buster Charging
- Hold fire button to charge
- Level 1 (0.5s): 1.5x damage
- Level 2 (1.0s): 2.5x damage
- Level 3 (2.0s): 4.0x damage

### Weakness System
- Each boss takes extra damage from their weakness weapon
- Multiplier ranges from 2.0x to 4.0x
- Hitting with weakness weapon briefly stuns the boss
- Visual and audio feedback for super-effective hits

### Homing Projectiles
- All weapons home in on targets
- Homing strength varies by weapon (0.4 to 0.95)
- Quick Boomerang has strongest homing
- Makes it easier to hit fast-moving bosses

### Multiplayer Support
- Multiple players can enter boss rooms together
- The player who deals the final blow receives the weapon
- Cooperative boss fights are encouraged

## Testing Checklist

- [ ] All 8 portals teleport correctly
- [ ] Bosses spawn when entering rooms
- [ ] Bosses take damage from projectiles
- [ ] Weakness damage multiplier works
- [ ] Weapons are granted on boss defeat
- [ ] Weapon switching works (L/R buttons)
- [ ] Mega Buster charging works
- [ ] Player colors change with weapon
- [ ] Hub detects all bosses defeated
- [ ] Victory sequence plays

## Future Enhancements

1. **Unique weapon behaviors** - Different projectile patterns per weapon
2. **Boss attack patterns** - Unique AI behavior for each boss
3. **Energy pickups** - Refill weapon energy from defeated enemies
4. **Lives system** - Classic Mega Man lives and continues
5. **Stage select screen** - Visual boss selection menu
6. **Dr. Wily boss** - Final boss after defeating all 8 Robot Masters
7. **Leaderboard** - Track fastest completion times

## Credits

Inspired by Mega Man (Rockman) series by Capcom
- Mega Man 1 (1987)
- Mega Man 2 (1988)
- Mega Man: Dr. Wily's Revenge (1991)
