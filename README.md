# Mega Man Battle Arena (Rockmanite)

A Fortnite Creative experience built in Unreal Editor for Fortnite (UEFN), featuring Mega Man-style boss battles in a multiplayer arena.

## Overview

Inspired by Mega Man: Dr. Wily's Revenge, this experience recreates the classic "Final Rebattles" concept where players face off against 8 Robot Masters in a central hub with portals.

### Features

- **8 Robot Masters** from Mega Man 1 and 2:
  - Cut Man, Ice Man, Fire Man, Elec Man (MM1)
  - Quick Man, Flash Man, Heat Man, Bubble Man (MM2)

- **9 Weapons** including the chargeable Mega Buster
- **Rock-Paper-Scissors weakness system** - Use the right weapon for bonus damage
- **L/R weapon switching** - Quickly cycle through acquired weapons (Mega Man X style)
- **Multiplayer support** - Team up to take down bosses
- **Homing projectiles** - Easy-to-use weapons that track targets

## Quick Start

See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for detailed setup instructions.

## Project Structure

```
Content/MegaManBattleArena/
├── Verse/                    # Verse source code
│   ├── WeaponTypes.verse     # Weapon/boss configuration
│   ├── HomingProjectile.verse
│   ├── PlayerWeaponManager.verse
│   ├── BossAI.verse
│   ├── PortalSystem.verse
│   ├── CombatSystem.verse
│   ├── PlayerInputHandler.verse
│   └── MegaManBattleArenaManager.verse
└── Assets/                   # Art and audio assets
```

## Gameplay

1. Start in the central hub room
2. Jump on platforms to reach one of 8 boss portals
3. Enter a portal to battle a Robot Master
4. Defeat the boss to acquire their special weapon
5. Use acquired weapons to exploit other bosses' weaknesses
6. Defeat all 8 bosses to win!

## Controls

| Action | Description |
|--------|-------------|
| Fire | Shoot current weapon |
| Hold Fire | Charge Mega Buster (3 levels) |
| Next Weapon (R) | Switch to next acquired weapon |
| Prev Weapon (L) | Switch to previous acquired weapon |

## Weakness Chart

| Boss | Weak To |
|------|---------|
| Cut Man | Fire Storm |
| Ice Man | Thunder Beam |
| Fire Man | Ice Slasher |
| Elec Man | Rolling Cutter |
| Quick Man | Time Stopper |
| Flash Man | Ice Slasher |
| Heat Man | Fire Storm |
| Bubble Man | Quick Boomerang |

## License

See [LICENSE](./LICENSE) for details.

---

*Inspired by the Mega Man (Rockman) series by Capcom*
