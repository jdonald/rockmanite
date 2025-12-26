# CombatSystem.verse
# Handles combat interactions between players, projectiles, and bosses

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Import modules
using { WeaponTypes }

# Damage result for feedback
damage_result := struct:
    DamageDealt : float
    WasWeakness : logic
    WasCritical : logic
    TargetDefeated : logic

# Hit info for collision
hit_info := struct:
    HitPosition : vector3
    DamageAmount : float
    WeaponUsed : weapon_type
    Attacker : agent
    WasWeakness : logic

# Combat system device
combat_system := class(creative_device):
    # Collision detection volume for projectiles hitting bosses
    @editable
    BossHitVolume : trigger_device = trigger_device{}

    # Player hit volume
    @editable
    PlayerHitVolume : trigger_device = trigger_device{}

    # Damage number popup
    @editable
    DamagePopupUI : billboard_device = billboard_device{}

    # Hit effects
    @editable
    NormalHitVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    WeaknessHitVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    CriticalHitVFX : vfx_spawner_device = vfx_spawner_device{}

    # Hit sounds
    @editable
    NormalHitSFX : audio_player_device = audio_player_device{}

    @editable
    WeaknessHitSFX : audio_player_device = audio_player_device{}

    @editable
    CriticalHitSFX : audio_player_device = audio_player_device{}

    @editable
    PlayerDamagedSFX : audio_player_device = audio_player_device{}

    # Damage events
    BossDamagedEvent : event(hit_info) = event(hit_info){}
    PlayerDamagedEvent : event(agent, float) = event(agent, float){}

    # Collision detection radius
    HitRadius : float = 50.0

    # Initialize
    OnBegin<override>()<suspends> : void =
        Print("Combat system initialized")

    # Calculate damage with modifiers
    CalculateDamage(
        BaseDamage : float,
        WeaponUsed : weapon_type,
        TargetBossType : boss_type,
        ChargeLevel : int  # 0-3 for Mega Buster charge levels
    ) : damage_result =
        BossConfig := GetBossConfig(TargetBossType)

        # Check for weakness
        IsWeakness := WeaponUsed = BossConfig.Weakness

        # Calculate damage multiplier
        WeaknessMultiplier := if (IsWeakness):
            BossConfig.WeaknessDamageMultiplier
        else:
            1.0

        # Charge level multiplier (for Mega Buster)
        ChargeMultiplier := case(ChargeLevel):
            0 => 1.0
            1 => 1.5
            2 => 2.5
            3 => 4.0
            _ => 1.0

        # Random critical hit chance (10%)
        # In actual implementation, would use RNG
        IsCritical := false
        CriticalMultiplier := if (IsCritical) then 2.0 else 1.0

        # Calculate final damage
        FinalDamage := BaseDamage * WeaknessMultiplier * ChargeMultiplier * CriticalMultiplier

        damage_result{
            DamageDealt := FinalDamage,
            WasWeakness := IsWeakness,
            WasCritical := IsCritical,
            TargetDefeated := false  # Will be set by caller
        }

    # Process a hit on a boss
    ProcessBossHit(
        WeaponUsed : weapon_type,
        TargetBossType : boss_type,
        HitPosition : vector3,
        Attacker : agent,
        ChargeLevel : int
    ) : damage_result =
        WeaponConfig := GetWeaponConfig(WeaponUsed)
        BaseDamage := WeaponConfig.Damage

        # Calculate damage
        Result := CalculateDamage(BaseDamage, WeaponUsed, TargetBossType, ChargeLevel)

        # Play appropriate effects
        if (Result.WasWeakness = true):
            WeaknessHitVFX.Activate()
            WeaknessHitSFX.Play()
            Print("SUPER EFFECTIVE! {Result.DamageDealt} damage!")
        else if (Result.WasCritical = true):
            CriticalHitVFX.Activate()
            CriticalHitSFX.Play()
            Print("CRITICAL HIT! {Result.DamageDealt} damage!")
        else:
            NormalHitVFX.Activate()
            NormalHitSFX.Play()
            Print("{Result.DamageDealt} damage!")

        # Show damage popup
        ShowDamagePopup(Result.DamageDealt, HitPosition, Result.WasWeakness)

        # Signal event
        Info := hit_info{
            HitPosition := HitPosition,
            DamageAmount := Result.DamageDealt,
            WeaponUsed := WeaponUsed,
            Attacker := Attacker,
            WasWeakness := Result.WasWeakness
        }
        BossDamagedEvent.Signal(Info)

        Result

    # Process a hit on a player
    ProcessPlayerHit(Player : agent, Damage : float, FromBoss : boss_type) : void =
        PlayerDamagedSFX.Play()
        PlayerDamagedEvent.Signal(Player, Damage)
        BossConfig := GetBossConfig(FromBoss)
        Print("Player hit by {BossConfig.DisplayName}! {Damage} damage!")

    # Show floating damage number
    ShowDamagePopup(Damage : float, Position : vector3, IsWeakness : logic) : void =
        # In full implementation, would show floating damage numbers
        # Different colors for normal vs weakness hits
        if (IsWeakness = true):
            Print("[WEAKNESS] {Damage}")
        else:
            Print("{Damage}")

    # Check if a point is within hit radius of target
    IsWithinHitRadius(Point : vector3, Target : vector3) : logic =
        DiffX := Point.X - Target.X
        DiffY := Point.Y - Target.Y
        DiffZ := Point.Z - Target.Z
        DistanceSq := DiffX * DiffX + DiffY * DiffY + DiffZ * DiffZ
        DistanceSq <= HitRadius * HitRadius

    # Get weakness effectiveness message
    GetWeaknessMessage(WeaponUsed : weapon_type, TargetBoss : boss_type) : string =
        BossConfig := GetBossConfig(TargetBoss)
        WeaponConfig := GetWeaponConfig(WeaponUsed)

        if (WeaponUsed = BossConfig.Weakness):
            "It's super effective! {WeaponConfig.DisplayName} is {BossConfig.DisplayName}'s weakness!"
        else:
            ""


# Projectile-Boss collision checker
projectile_collision_checker := class(creative_device):
    # Reference to combat system
    @editable
    CombatSystem : combat_system = combat_system{}

    # Collision check interval
    CheckInterval : float = 0.016  # ~60Hz

    # Active projectile positions (would be updated by projectile pool)
    var ProjectilePositions : []vector3 = array{}
    var ProjectileWeapons : []weapon_type = array{}
    var ProjectileOwners : []agent = array{}

    # Boss positions (would be updated by boss controllers)
    var BossPositions : [boss_type]vector3 = map{}
    var ActiveBosses : []boss_type = array{}

    # Hit radius for collision
    CollisionRadius : float = 75.0

    # Initialize
    OnBegin<override>()<suspends> : void =
        # Start collision check loop
        loop:
            CheckAllCollisions()
            Sleep(CheckInterval)

    # Check all projectile-boss collisions
    CheckAllCollisions() : void =
        for (I := 0..ProjectilePositions.Length - 1):
            if (ProjPos := ProjectilePositions[I]):
                if (ProjWeapon := ProjectileWeapons[I]):
                    if (ProjOwner := ProjectileOwners[I]):
                        # Check against all active bosses
                        for (BossType : ActiveBosses):
                            if (BossPos := BossPositions[BossType]):
                                if (CheckCollision(ProjPos, BossPos)):
                                    # Hit detected!
                                    OnProjectileHitBoss(I, BossType, ProjWeapon, ProjOwner, ProjPos)

    # Check if two positions are colliding
    CheckCollision(Pos1 : vector3, Pos2 : vector3) : logic =
        DiffX := Pos1.X - Pos2.X
        DiffY := Pos1.Y - Pos2.Y
        DiffZ := Pos1.Z - Pos2.Z
        DistanceSq := DiffX * DiffX + DiffY * DiffY + DiffZ * DiffZ
        DistanceSq <= CollisionRadius * CollisionRadius

    # Handle projectile hitting a boss
    OnProjectileHitBoss(
        ProjectileIndex : int,
        BossType : boss_type,
        WeaponUsed : weapon_type,
        Attacker : agent,
        HitPosition : vector3
    ) : void =
        # Process the hit through combat system
        CombatSystem.ProcessBossHit(
            WeaponUsed,
            BossType,
            HitPosition,
            Attacker,
            0  # Charge level, would come from weapon manager
        )

        # Remove the projectile (mark for cleanup)
        # In full implementation, would signal to projectile pool

    # Register a new projectile
    RegisterProjectile(Position : vector3, Weapon : weapon_type, Owner : agent) : int =
        set ProjectilePositions = ProjectilePositions + array{Position}
        set ProjectileWeapons = ProjectileWeapons + array{Weapon}
        set ProjectileOwners = ProjectileOwners + array{Owner}
        ProjectilePositions.Length - 1

    # Update projectile position
    UpdateProjectilePosition(Index : int, NewPosition : vector3) : void =
        if (Index >= 0 and Index < ProjectilePositions.Length):
            if (set ProjectilePositions[Index] = NewPosition) {}

    # Remove projectile
    RemoveProjectile(Index : int) : void =
        # Mark as removed by setting to very far position
        if (Index >= 0 and Index < ProjectilePositions.Length):
            FarAway := vector3{X := 999999.0, Y := 999999.0, Z := 999999.0}
            if (set ProjectilePositions[Index] = FarAway) {}

    # Register a boss
    RegisterBoss(BossType : boss_type, Position : vector3) : void =
        if (set BossPositions[BossType] = Position) {}
        set ActiveBosses = ActiveBosses + array{BossType}

    # Update boss position
    UpdateBossPosition(BossType : boss_type, NewPosition : vector3) : void =
        if (set BossPositions[BossType] = NewPosition) {}

    # Unregister a boss (when defeated)
    UnregisterBoss(BossType : boss_type) : void =
        # Remove from active list
        var NewActiveBosses : []boss_type = array{}
        for (Boss : ActiveBosses):
            if (Boss <> BossType):
                set NewActiveBosses = NewActiveBosses + array{Boss}
        set ActiveBosses = NewActiveBosses
