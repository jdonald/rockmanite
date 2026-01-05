# WeaponTypes.verse
# Defines all weapon types and their properties for the Mega Man Battle Arena

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Weapon type enumeration - all 9 weapons (8 boss weapons + Mega Buster)
weapon_type := enum:
    MegaBuster          # Default weapon, can be charged
    RollingCutter       # Cut Man's weapon
    IceSlasher          # Ice Man's weapon
    FireStorm           # Fire Man's weapon
    ThunderBeam         # Elec Man's weapon
    QuickBoomerang      # Quick Man's weapon
    AtomicFire          # Flash Man's weapon (in this remix)
    CrashBomber         # Heat Man's weapon (in this remix)
    TimeStopper         # Bubble Man's weapon (in this remix) - implemented as thrown clocks

# Boss type enumeration
boss_type := enum:
    CutMan
    IceMan
    FireMan
    ElecMan
    QuickMan
    FlashMan
    HeatMan
    BubbleMan

# Weapon configuration data
weapon_config := struct:
    WeaponType : weapon_type
    DisplayName : string
    Damage : float
    ProjectileSpeed : float
    HomingStrength : float      # How strongly the projectile tracks targets
    CooldownTime : float        # Time between shots
    EnergyCost : float          # Energy consumed per shot
    # Color values for player skin when using this weapon (RGB 0-255)
    SkinColorR : float
    SkinColorG : float
    SkinColorB : float

# Boss configuration data
boss_config := struct:
    BossType : boss_type
    DisplayName : string
    MaxHealth : float
    MoveSpeed : float
    AttackCooldown : float
    WeaponUsed : weapon_type
    Weakness : weapon_type      # Weapon this boss is weak to
    WeaknessDamageMultiplier : float  # Extra damage when hit by weakness

# Static weapon configurations
GetWeaponConfig(Type : weapon_type) : weapon_config =
    case(Type):
        weapon_type.MegaBuster =>
            weapon_config:
                WeaponType := weapon_type.MegaBuster
                DisplayName := "Mega Buster"
                Damage := 10.0
                ProjectileSpeed := 2000.0
                HomingStrength := 0.5
                CooldownTime := 0.3
                EnergyCost := 0.0  # Mega Buster has no energy cost
                SkinColorR := 0.0
                SkinColorG := 112.0
                SkinColorB := 255.0  # Classic Mega Man blue

        weapon_type.RollingCutter =>
            weapon_config:
                WeaponType := weapon_type.RollingCutter
                DisplayName := "Rolling Cutter"
                Damage := 15.0
                ProjectileSpeed := 1800.0
                HomingStrength := 0.8
                CooldownTime := 0.5
                EnergyCost := 2.0
                SkinColorR := 255.0
                SkinColorG := 255.0
                SkinColorB := 255.0  # White/Silver

        weapon_type.IceSlasher =>
            weapon_config:
                WeaponType := weapon_type.IceSlasher
                DisplayName := "Ice Slasher"
                Damage := 12.0
                ProjectileSpeed := 1600.0
                HomingStrength := 0.7
                CooldownTime := 0.4
                EnergyCost := 1.5
                SkinColorR := 150.0
                SkinColorG := 220.0
                SkinColorB := 255.0  # Ice blue

        weapon_type.FireStorm =>
            weapon_config:
                WeaponType := weapon_type.FireStorm
                DisplayName := "Fire Storm"
                Damage := 18.0
                ProjectileSpeed := 2200.0
                HomingStrength := 0.6
                CooldownTime := 0.6
                EnergyCost := 2.5
                SkinColorR := 255.0
                SkinColorG := 100.0
                SkinColorB := 0.0  # Orange-red

        weapon_type.ThunderBeam =>
            weapon_config:
                WeaponType := weapon_type.ThunderBeam
                DisplayName := "Thunder Beam"
                Damage := 20.0
                ProjectileSpeed := 2500.0
                HomingStrength := 0.4
                CooldownTime := 0.7
                EnergyCost := 3.0
                SkinColorR := 255.0
                SkinColorG := 255.0
                SkinColorB := 0.0  # Electric yellow

        weapon_type.QuickBoomerang =>
            weapon_config:
                WeaponType := weapon_type.QuickBoomerang
                DisplayName := "Quick Boomerang"
                Damage := 8.0
                ProjectileSpeed := 2800.0
                HomingStrength := 0.9  # Very strong homing
                CooldownTime := 0.2  # Fast fire rate
                EnergyCost := 0.5
                SkinColorR := 255.0
                SkinColorG := 50.0
                SkinColorB := 50.0  # Red

        weapon_type.AtomicFire =>
            weapon_config:
                WeaponType := weapon_type.AtomicFire
                DisplayName := "Atomic Fire"
                Damage := 25.0
                ProjectileSpeed := 1500.0
                HomingStrength := 0.5
                CooldownTime := 1.0  # Slow but powerful
                EnergyCost := 4.0
                SkinColorR := 255.0
                SkinColorG := 150.0
                SkinColorB := 0.0  # Bright orange

        weapon_type.CrashBomber =>
            weapon_config:
                WeaponType := weapon_type.CrashBomber
                DisplayName := "Crash Bomber"
                Damage := 22.0
                ProjectileSpeed := 1800.0
                HomingStrength := 0.6
                CooldownTime := 0.8
                EnergyCost := 3.5
                SkinColorR := 200.0
                SkinColorG := 50.0
                SkinColorB := 0.0  # Dark red/maroon

        weapon_type.TimeStopper =>
            weapon_config:
                WeaponType := weapon_type.TimeStopper
                DisplayName := "Time Stopper"
                Damage := 5.0  # Low damage per clock
                ProjectileSpeed := 1200.0
                HomingStrength := 0.95  # Very high homing (clocks seek targets)
                CooldownTime := 0.15  # Rapid fire clocks
                EnergyCost := 0.3
                SkinColorR := 128.0
                SkinColorG := 0.0
                SkinColorB := 128.0  # Purple

        _ =>
            # Default fallback
            weapon_config:
                WeaponType := weapon_type.MegaBuster
                DisplayName := "Mega Buster"
                Damage := 10.0
                ProjectileSpeed := 2000.0
                HomingStrength := 0.5
                CooldownTime := 0.3
                EnergyCost := 0.0
                SkinColorR := 0.0
                SkinColorG := 112.0
                SkinColorB := 255.0

# Get boss configuration
GetBossConfig(Type : boss_type) : boss_config =
    case(Type):
        boss_type.CutMan =>
            boss_config:
                BossType := boss_type.CutMan
                DisplayName := "Cut Man"
                MaxHealth := 200.0
                MoveSpeed := 400.0
                AttackCooldown := 1.5
                WeaponUsed := weapon_type.RollingCutter
                Weakness := weapon_type.FireStorm
                WeaknessDamageMultiplier := 3.0

        boss_type.IceMan =>
            boss_config:
                BossType := boss_type.IceMan
                DisplayName := "Ice Man"
                MaxHealth := 180.0
                MoveSpeed := 350.0
                AttackCooldown := 1.8
                WeaponUsed := weapon_type.IceSlasher
                Weakness := weapon_type.ThunderBeam
                WeaknessDamageMultiplier := 2.5

        boss_type.FireMan =>
            boss_config:
                BossType := boss_type.FireMan
                DisplayName := "Fire Man"
                MaxHealth := 220.0
                MoveSpeed := 380.0
                AttackCooldown := 1.2
                WeaponUsed := weapon_type.FireStorm
                Weakness := weapon_type.IceSlasher
                WeaknessDamageMultiplier := 3.0

        boss_type.ElecMan =>
            boss_config:
                BossType := boss_type.ElecMan
                DisplayName := "Elec Man"
                MaxHealth := 190.0
                MoveSpeed := 450.0
                AttackCooldown := 1.0
                WeaponUsed := weapon_type.ThunderBeam
                Weakness := weapon_type.RollingCutter
                WeaknessDamageMultiplier := 2.5

        boss_type.QuickMan =>
            boss_config:
                BossType := boss_type.QuickMan
                DisplayName := "Quick Man"
                MaxHealth := 175.0
                MoveSpeed := 600.0  # Very fast
                AttackCooldown := 0.5
                WeaponUsed := weapon_type.QuickBoomerang
                Weakness := weapon_type.TimeStopper
                WeaknessDamageMultiplier := 4.0  # Very effective

        boss_type.FlashMan =>
            boss_config:
                BossType := boss_type.FlashMan
                DisplayName := "Flash Man"
                MaxHealth := 200.0
                MoveSpeed := 320.0
                AttackCooldown := 2.0
                WeaponUsed := weapon_type.AtomicFire
                Weakness := weapon_type.IceSlasher
                WeaknessDamageMultiplier := 3.0

        boss_type.HeatMan =>
            boss_config:
                BossType := boss_type.HeatMan
                DisplayName := "Heat Man"
                MaxHealth := 240.0
                MoveSpeed := 350.0
                AttackCooldown := 1.5
                WeaponUsed := weapon_type.CrashBomber
                Weakness := weapon_type.FireStorm  # Weak to its own element
                WeaknessDamageMultiplier := 2.0

        boss_type.BubbleMan =>
            boss_config:
                BossType := boss_type.BubbleMan
                DisplayName := "Bubble Man"
                MaxHealth := 160.0
                MoveSpeed := 300.0
                AttackCooldown := 0.8
                WeaponUsed := weapon_type.TimeStopper
                Weakness := weapon_type.QuickBoomerang
                WeaknessDamageMultiplier := 3.5

        _ =>
            # Default fallback
            boss_config:
                BossType := boss_type.CutMan
                DisplayName := "Cut Man"
                MaxHealth := 200.0
                MoveSpeed := 400.0
                AttackCooldown := 1.5
                WeaponUsed := weapon_type.RollingCutter
                Weakness := weapon_type.FireStorm
                WeaknessDamageMultiplier := 3.0

# Get weapon type from boss type (what weapon you get for defeating this boss)
GetWeaponFromBoss(Type : boss_type) : weapon_type =
    case(Type):
        boss_type.CutMan => weapon_type.RollingCutter
        boss_type.IceMan => weapon_type.IceSlasher
        boss_type.FireMan => weapon_type.FireStorm
        boss_type.ElecMan => weapon_type.ThunderBeam
        boss_type.QuickMan => weapon_type.QuickBoomerang
        boss_type.FlashMan => weapon_type.AtomicFire
        boss_type.HeatMan => weapon_type.CrashBomber
        boss_type.BubbleMan => weapon_type.TimeStopper
        _ => weapon_type.MegaBuster
