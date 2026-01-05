# Mega Man Battle Arena (Rockmanite)

A Fortnite Creative experience built in Unreal Editor for Fortnite (UEFN), featuring Mega Man-style boss battles in a multiplayer arena.

## Quick Start - Just 1 Device!

```
1. Copy Content/MegaManBattleArena to your UEFN project
2. Build Verse code (Ctrl+Shift+B)
3. Drag 'minimal_mega_man_arena' into level
4. Link ONE Player Spawner device
5. Play!
```

**Everything else is pure Verse code** - no manual device configuration needed.

See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for details.

## Overview

Inspired by Mega Man: Dr. Wily's Revenge, this experience recreates the classic "Final Rebattles" concept where players face off against 8 Robot Masters in a central hub with portals.

### Features

- **8 Robot Masters** from Mega Man 1 and 2:
  - Cut Man, Ice Man, Fire Man, Elec Man (MM1)
  - Quick Man, Flash Man, Heat Man, Bubble Man (MM2)
- **9 Weapons** including the chargeable Mega Buster
- **Rock-Paper-Scissors weakness system** - 2x to 4x bonus damage
- **L/R weapon switching** - Mega Man X style
- **Multiplayer support** - Team up against bosses
- **Homing projectiles** - All weapons track targets
- **Pure Verse implementation** - Minimal device requirements

## How It Works

The minimal version uses **pure Verse code** instead of dozens of devices:

| Feature | Traditional | This Project |
|---------|-------------|--------------|
| Teleportation | Teleporter Device | `FC.TeleportTo[]` |
| Damage | Damage Volume | `FC.Damage()` |
| Portal Detection | Trigger Device | Position math |
| Boss AI | Guard Spawner | Verse state machine |
| Combat | Multiple devices | Pure Verse |

## Project Structure

```
Content/MegaManBattleArena/Verse/
├── MinimalDeviceGame.verse    ← Main game (1 device!)
├── WeaponTypes.verse          ← All boss/weapon data
├── [Full version files...]    ← Optional: 50+ device version
```

## Gameplay

1. Start in the central hub room
2. Walk to one of 8 portal locations (4 left, 4 right)
3. Automatically teleport to boss room
4. Defeat the boss to acquire their weapon
5. Use weakness weapons for bonus damage
6. Defeat all 8 bosses to win!

## Controls

| Action | Description |
|--------|-------------|
| Fire | Shoot current weapon |
| Hold Fire | Charge Mega Buster (1.5x → 2.5x → 4x) |
| Secondary | Switch weapon |

## Weakness Chart

| Boss | Weapon | Weak To | Multiplier |
|------|--------|---------|------------|
| Cut Man | Rolling Cutter | Fire Storm | 3.0x |
| Ice Man | Ice Slasher | Thunder Beam | 2.5x |
| Fire Man | Fire Storm | Ice Slasher | 3.0x |
| Elec Man | Thunder Beam | Rolling Cutter | 2.5x |
| Quick Man | Quick Boomerang | Time Stopper | 4.0x |
| Flash Man | Atomic Fire | Ice Slasher | 3.0x |
| Heat Man | Crash Bomber | Fire Storm | 2.0x |
| Bubble Man | Time Stopper | Quick Boomerang | 3.5x |

## Portal Layout

```
LEFT SIDE (-900x)          RIGHT SIDE (+900x)
─────────────────          ──────────────────
[Elec Man]   900z          [Bubble Man]  900z
[Fire Man]   650z          [Heat Man]    650z
[Ice Man]    400z          [Flash Man]   400z
[Cut Man]    150z          [Quick Man]   150z
```

## License

See [LICENSE](./LICENSE) for details.

---

*Inspired by Mega Man (Rockman) by Capcom*
