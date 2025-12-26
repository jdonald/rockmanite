# BossAI.verse
# Boss AI behavior and state management for Mega Man Battle Arena

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/AI }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Import types
using { WeaponTypes }

# Boss behavior states
boss_behavior_state := enum:
    Idle            # Waiting for player
    Pursuing        # Moving towards player
    Attacking       # Firing weapon
    Jumping         # Jump attack
    Stunned         # Hit by weakness weapon
    Defeated        # Boss has been defeated

# Boss instance data
boss_instance := struct<transacts>:
    var BossType : boss_type
    var Config : boss_config
    var CurrentHealth : float
    var MaxHealth : float
    var Position : vector3
    var BehaviorState : boss_behavior_state
    var StateTimer : float
    var AttackCooldown : float
    var TargetPlayer : ?agent
    var IsActive : logic
    var JumpVelocity : vector3
    var StunDuration : float

# Boss AI controller device
boss_ai_controller := class(creative_device):
    # The NPC spawner for this boss
    @editable
    BossSpawner : guard_spawner_device = guard_spawner_device{}

    # Boss type configuration
    @editable
    BossTypeIndex : int = 0  # 0-7 for the 8 bosses

    # Boss room boundaries
    @editable
    RoomMinX : float = -500.0
    @editable
    RoomMaxX : float = 500.0
    @editable
    RoomMinY : float = -500.0
    @editable
    RoomMaxY : float = 500.0
    @editable
    RoomFloorZ : float = 0.0

    # Visual effects
    @editable
    SpawnVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    DeathVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    HitVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    WeaknessHitVFX : vfx_spawner_device = vfx_spawner_device{}

    # Sound effects
    @editable
    SpawnSFX : audio_player_device = audio_player_device{}

    @editable
    DeathSFX : audio_player_device = audio_player_device{}

    @editable
    HitSFX : audio_player_device = audio_player_device{}

    @editable
    AttackSFX : audio_player_device = audio_player_device{}

    # Health bar UI
    @editable
    HealthBarUI : billboard_device = billboard_device{}

    # Boss defeated event (for game manager to listen to)
    BossDefeatedEvent : event(boss_type, agent) = event(boss_type, agent){}

    # Current boss instance
    var Boss : boss_instance = boss_instance{}
    var IsSpawned : logic = false

    # Random number generator
    var RNG : random_number_generator = random_number_generator{}

    # All boss types for lookup
    AllBossTypes : []boss_type = array{
        boss_type.CutMan,
        boss_type.IceMan,
        boss_type.FireMan,
        boss_type.ElecMan,
        boss_type.QuickMan,
        boss_type.FlashMan,
        boss_type.HeatMan,
        boss_type.BubbleMan
    }

    # Initialize
    OnBegin<override>()<suspends> : void =
        # Initialize RNG
        set RNG = random_number_generator{}

        # Start AI update loop
        loop:
            if (IsSpawned = true):
                UpdateBossAI(0.016)
            Sleep(0.016)

    # Spawn the boss
    SpawnBoss() : void =
        if (IsSpawned = true):
            return  # Already spawned

        # Get boss type from index
        if (BossType := AllBossTypes[BossTypeIndex]):
            Config := GetBossConfig(BossType)

            # Initialize boss instance
            set Boss = boss_instance{
                BossType := BossType,
                Config := Config,
                CurrentHealth := Config.MaxHealth,
                MaxHealth := Config.MaxHealth,
                Position := vector3{X := 0.0, Y := 0.0, Z := RoomFloorZ},
                BehaviorState := boss_behavior_state.Idle,
                StateTimer := 0.0,
                AttackCooldown := Config.AttackCooldown,
                TargetPlayer := false,
                IsActive := true,
                JumpVelocity := vector3{X := 0.0, Y := 0.0, Z := 0.0},
                StunDuration := 0.0
            }

            set IsSpawned = true

            # Spawn NPC and play effects
            BossSpawner.Enable()
            SpawnVFX.Activate()
            SpawnSFX.Play()

            Print("Boss spawned: {Config.DisplayName}")

    # Despawn the boss
    DespawnBoss() : void =
        if (IsSpawned = false):
            return

        BossSpawner.Disable()
        set IsSpawned = false

    # Update boss AI each frame
    UpdateBossAI(DeltaTime : float) : void =
        if (Boss.IsActive = false):
            return

        # Update state timer
        var MutableBoss := Boss
        set MutableBoss.StateTimer = Boss.StateTimer + DeltaTime

        # Update based on current behavior state
        case(Boss.BehaviorState):
            boss_behavior_state.Idle =>
                UpdateIdleState(set MutableBoss, DeltaTime)
            boss_behavior_state.Pursuing =>
                UpdatePursuingState(set MutableBoss, DeltaTime)
            boss_behavior_state.Attacking =>
                UpdateAttackingState(set MutableBoss, DeltaTime)
            boss_behavior_state.Jumping =>
                UpdateJumpingState(set MutableBoss, DeltaTime)
            boss_behavior_state.Stunned =>
                UpdateStunnedState(set MutableBoss, DeltaTime)
            boss_behavior_state.Defeated =>
                # Do nothing, boss is dead
                {}
            _ =>
                {}

        set Boss = MutableBoss

    # Idle state - wait for player to enter room
    UpdateIdleState(Boss : boss_instance, DeltaTime : float) : boss_instance =
        var MutableBoss := Boss

        # After brief idle, start pursuing
        if (Boss.StateTimer > 1.0):
            set MutableBoss.BehaviorState = boss_behavior_state.Pursuing
            set MutableBoss.StateTimer = 0.0

        MutableBoss

    # Pursuing state - move towards player
    UpdatePursuingState(Boss : boss_instance, DeltaTime : float) : boss_instance =
        var MutableBoss := Boss

        # Update attack cooldown
        set MutableBoss.AttackCooldown = Boss.AttackCooldown - DeltaTime

        # Move towards target (simplified - would use actual player position)
        MoveSpeed := Boss.Config.MoveSpeed * DeltaTime

        # Random movement pattern (simplified AI)
        RandomValue := RNG.GetRandomFloat()
        if (RandomValue < 0.3):
            # Move left
            NewX := Boss.Position.X - MoveSpeed
            set MutableBoss.Position = vector3{
                X := Clamp(NewX, RoomMinX, RoomMaxX),
                Y := Boss.Position.Y,
                Z := Boss.Position.Z
            }
        else if (RandomValue < 0.6):
            # Move right
            NewX := Boss.Position.X + MoveSpeed
            set MutableBoss.Position = vector3{
                X := Clamp(NewX, RoomMinX, RoomMaxX),
                Y := Boss.Position.Y,
                Z := Boss.Position.Z
            }

        # Chance to jump
        if (RandomValue > 0.9 and Boss.Position.Z <= RoomFloorZ + 10.0):
            set MutableBoss.BehaviorState = boss_behavior_state.Jumping
            set MutableBoss.StateTimer = 0.0
            set MutableBoss.JumpVelocity = vector3{
                X := (RNG.GetRandomFloat() - 0.5) * 400.0,
                Y := 0.0,
                Z := 600.0  # Jump velocity
            }

        # Attack when cooldown is ready
        if (MutableBoss.AttackCooldown <= 0.0):
            set MutableBoss.BehaviorState = boss_behavior_state.Attacking
            set MutableBoss.StateTimer = 0.0
            set MutableBoss.AttackCooldown = Boss.Config.AttackCooldown

        MutableBoss

    # Attacking state - fire weapon at player
    UpdateAttackingState(Boss : boss_instance, DeltaTime : float) : boss_instance =
        var MutableBoss := Boss

        # Brief attack animation
        if (Boss.StateTimer > 0.3):
            # Fire projectile (handled by projectile manager)
            AttackSFX.Play()
            Print("Boss attacks with {GetWeaponConfig(Boss.Config.WeaponUsed).DisplayName}!")

            # Return to pursuing
            set MutableBoss.BehaviorState = boss_behavior_state.Pursuing
            set MutableBoss.StateTimer = 0.0

        MutableBoss

    # Jumping state - aerial movement
    UpdateJumpingState(Boss : boss_instance, DeltaTime : float) : boss_instance =
        var MutableBoss := Boss

        # Apply gravity
        Gravity := 1200.0
        NewVelZ := Boss.JumpVelocity.Z - Gravity * DeltaTime
        set MutableBoss.JumpVelocity = vector3{
            X := Boss.JumpVelocity.X,
            Y := Boss.JumpVelocity.Y,
            Z := NewVelZ
        }

        # Update position
        NewPos := vector3{
            X := Clamp(Boss.Position.X + Boss.JumpVelocity.X * DeltaTime, RoomMinX, RoomMaxX),
            Y := Boss.Position.Y,
            Z := Boss.Position.Z + NewVelZ * DeltaTime
        }

        # Check if landed
        if (NewPos.Z <= RoomFloorZ):
            set MutableBoss.Position = vector3{X := NewPos.X, Y := NewPos.Y, Z := RoomFloorZ}
            set MutableBoss.JumpVelocity = vector3{X := 0.0, Y := 0.0, Z := 0.0}
            set MutableBoss.BehaviorState = boss_behavior_state.Pursuing
            set MutableBoss.StateTimer = 0.0
        else:
            set MutableBoss.Position = NewPos

        MutableBoss

    # Stunned state - hit by weakness weapon
    UpdateStunnedState(Boss : boss_instance, DeltaTime : float) : boss_instance =
        var MutableBoss := Boss

        set MutableBoss.StunDuration = Boss.StunDuration - DeltaTime

        if (MutableBoss.StunDuration <= 0.0):
            set MutableBoss.BehaviorState = boss_behavior_state.Pursuing
            set MutableBoss.StateTimer = 0.0

        MutableBoss

    # Apply damage to boss
    TakeDamage(Damage : float, WeaponUsed : weapon_type, Attacker : agent) : void =
        if (Boss.IsActive = false or Boss.BehaviorState = boss_behavior_state.Defeated):
            return

        var MutableBoss := Boss

        # Check for weakness
        FinalDamage := if (WeaponUsed = Boss.Config.Weakness):
            WeaknessHitVFX.Activate()
            # Stun the boss briefly
            set MutableBoss.BehaviorState = boss_behavior_state.Stunned
            set MutableBoss.StunDuration = 0.5
            set MutableBoss.StateTimer = 0.0
            Damage * Boss.Config.WeaknessDamageMultiplier
        else:
            HitVFX.Activate()
            Damage

        HitSFX.Play()

        # Apply damage
        set MutableBoss.CurrentHealth = Boss.CurrentHealth - FinalDamage
        Print("{Boss.Config.DisplayName} took {FinalDamage} damage! Health: {MutableBoss.CurrentHealth}/{Boss.MaxHealth}")

        # Update health bar
        UpdateHealthBar(MutableBoss.CurrentHealth, Boss.MaxHealth)

        # Check for defeat
        if (MutableBoss.CurrentHealth <= 0.0):
            set MutableBoss.CurrentHealth = 0.0
            set MutableBoss.BehaviorState = boss_behavior_state.Defeated
            set MutableBoss.IsActive = false
            OnBossDefeated(Attacker)

        set Boss = MutableBoss

    # Boss defeated handler
    OnBossDefeated(Attacker : agent) : void =
        DeathVFX.Activate()
        DeathSFX.Play()

        Print("{Boss.Config.DisplayName} has been defeated!")

        # Signal that boss was defeated
        BossDefeatedEvent.Signal(Boss.BossType, Attacker)

        # Despawn after delay
        spawn:
            Sleep(2.0)
            DespawnBoss()

    # Update health bar display
    UpdateHealthBar(CurrentHealth : float, MaxHealth : float) : void =
        HealthPercent := CurrentHealth / MaxHealth
        # Update billboard or health bar UI here
        Print("Health: {HealthPercent * 100.0}%")

    # Get current boss position
    GetBossPosition() : vector3 =
        Boss.Position

    # Check if boss is active
    IsBossActive() : logic =
        Boss.IsActive

    # Get boss type
    GetBossType() : boss_type =
        Boss.BossType

    # Helper: Clamp value between min and max
    Clamp(Value : float, Min : float, Max : float) : float =
        if (Value < Min):
            Min
        else if (Value > Max):
            Max
        else:
            Value
