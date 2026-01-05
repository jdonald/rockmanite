# Mega Man Battle Arena - UEFN Setup Guide

A Fortnite Creative experience inspired by Mega Man: Dr. Wily's Revenge.

## Choose Your Setup Method

| Method | Devices Required | Complexity | Features |
|--------|------------------|------------|----------|
| **Minimal (Recommended)** | 1 device | Very Easy | Full gameplay, pure Verse |
| Standard | ~10 devices | Easy | Full gameplay + audio |
| Full | 50+ devices | Complex | All VFX, audio, UI |

---

## MINIMAL SETUP (Recommended)

**Total devices required: 1**

### Step 1: Create UEFN Project
1. Open Unreal Editor for Fortnite (UEFN)
2. Create a new Fortnite Creative project
3. Copy `Content/MegaManBattleArena` folder into your project

### Step 2: Compile Verse Code
1. Open Verse Explorer (Window → Verse Explorer)
2. Build all code (Ctrl+Shift+B)
3. Verify no errors

### Step 3: Add ONE Device
1. In Content Browser, find `MegaManBattleArena/Verse`
2. Drag `minimal_mega_man_arena` into your level
3. In Details panel, link ONE device:
   - `PlayerSpawner` → Add a Player Spawner Device

**That's it! Everything else is pure Verse code.**

### What the Minimal Version Does Automatically:
- ✅ Level layout (hub room, platforms, portal zones)
- ✅ Teleportation (using `TeleportTo[]` API)
- ✅ Boss AI (movement, attacks, jumping)
- ✅ Combat system (damage, weakness multipliers)
- ✅ Weapon acquisition and switching
- ✅ Victory detection
- ✅ All 8 bosses with unique stats
- ✅ Portal detection (position-based)
- ✅ Player charging system

### Optional Enhancements (0-8 more devices):
If you want physical portal triggers instead of position-based detection:

```
PortalTrigger_CutMan   → Trigger Device at (-900, 0, 150)
PortalTrigger_IceMan   → Trigger Device at (-900, 0, 400)
PortalTrigger_FireMan  → Trigger Device at (-900, 0, 650)
PortalTrigger_ElecMan  → Trigger Device at (-900, 0, 900)
PortalTrigger_QuickMan → Trigger Device at (900, 0, 150)
PortalTrigger_FlashMan → Trigger Device at (900, 0, 400)
PortalTrigger_HeatMan  → Trigger Device at (900, 0, 650)
PortalTrigger_BubbleMan → Trigger Device at (900, 0, 900)
```

---

## How the Minimal Version Works

### Pure Verse Teleportation
```verse
# No teleporter device needed!
if (FC := PlayerInfo.Character?):
    FC.TeleportTo[BossRoomPosition, FC.GetTransform().Rotation]
```

### Pure Verse Damage
```verse
# No damage volume device needed!
FC.Damage(DamageAmount)
```

### Position-Based Portal Detection
```verse
# No trigger device needed!
if (IsInRadius(PlayerPosition, PortalCenter, PortalRadius)):
    EnterBossRoom(Agent, BossType)
```

### Pure Verse Boss AI
```verse
# No NPC spawner device needed!
# Boss is tracked as data, position updated in game loop
set Boss.Position = vector3{X := NewX, Y := NewY, Z := NewZ}
```

---

## Gameplay Reference

### Bosses and Weapons

| Boss | Weapon | Weakness | Multiplier |
|------|--------|----------|------------|
| Cut Man | Rolling Cutter | Fire Storm | 3.0x |
| Ice Man | Ice Slasher | Thunder Beam | 2.5x |
| Fire Man | Fire Storm | Ice Slasher | 3.0x |
| Elec Man | Thunder Beam | Rolling Cutter | 2.5x |
| Quick Man | Quick Boomerang | Time Stopper | 4.0x |
| Flash Man | Atomic Fire | Ice Slasher | 3.0x |
| Heat Man | Crash Bomber | Fire Storm | 2.0x |
| Bubble Man | Time Stopper | Quick Boomerang | 3.5x |

### Portal Layout

```
   LEFT SIDE                RIGHT SIDE
   ─────────                ──────────
   [Elec Man]    (900z)     [Bubble Man]
   [Fire Man]    (650z)     [Heat Man]
   [Ice Man]     (400z)     [Flash Man]
   [Cut Man]     (150z)     [Quick Man]

   X: -900                   X: +900
```

### Charge Levels (Mega Buster)

| Level | Hold Time | Damage |
|-------|-----------|--------|
| 0 | < 0.5s | 1.0x |
| 1 | 0.5-1.0s | 1.5x |
| 2 | 1.0-2.0s | 2.5x |
| 3 | > 2.0s | 4.0x |

---

## Project Structure

```
Content/MegaManBattleArena/Verse/
├── MinimalDeviceGame.verse      ← USE THIS (1 device!)
├── WeaponTypes.verse            ← Boss/weapon data
└── [other files for full version]
```

---

## Customization

### Change Boss Stats
Edit `WeaponTypes.verse`:
```verse
boss_type.CutMan =>
    boss_config:
        MaxHealth := 200.0       # HP
        MoveSpeed := 400.0       # Speed
        AttackCooldown := 1.5    # Attack rate
        WeaknessDamageMultiplier := 3.0
```

### Change Weapon Stats
```verse
weapon_type.MegaBuster =>
    weapon_config:
        Damage := 10.0           # Base damage
        ProjectileSpeed := 2000.0
        HomingStrength := 0.5
```

### Change Portal Positions
Edit `MinimalDeviceGame.verse`:
```verse
Portal_CutMan_Pos : vector3 = vector3{X := -900.0, Y := 0.0, Z := 150.0}
```

---

## Testing Checklist

- [ ] Verse compiles without errors
- [ ] `minimal_mega_man_arena` device in level
- [ ] Player Spawner linked
- [ ] Walk near portal location → teleports to boss room
- [ ] Boss takes damage when firing
- [ ] Weakness weapons deal bonus damage
- [ ] Defeating boss grants weapon
- [ ] Can switch weapons after acquiring
- [ ] Defeating all 8 → victory message

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Module not found" | Ensure all .verse files in Verse folder |
| No teleportation | Check player spawner is linked |
| Boss doesn't appear | Boss is data-only in minimal version; damage still works |
| No damage | Ensure you're calling PlayerFire() on input |

---

## Full Version (50+ devices)

If you want the complete experience with audio, VFX, and physical boss NPCs, see the other Verse files:

- `MegaManBattleArenaManager.verse` - Full game manager
- `DeviceConfigurator.verse` - Device linking
- `AudioManager.verse` - Music and SFX
- `LevelGenerator.verse` - Level construction

This requires linking 50+ devices but provides full audio-visual feedback.

---

## Credits

Inspired by Mega Man (Rockman) series by Capcom
- Mega Man 1 (1987)
- Mega Man 2 (1988)
- Mega Man: Dr. Wily's Revenge (1991)
