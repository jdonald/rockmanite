# HomingProjectile.verse
# Homing projectile device for all weapons in Mega Man Battle Arena
# All weapons use this same projectile with different visual effects and properties

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Import our weapon types
using { WeaponTypes }

# Projectile state
projectile_state := enum:
    Active
    Expired
    Hit

# Homing projectile device
homing_projectile_device := class(creative_device):
    # Visual representation (prop device to spawn projectile visual)
    @editable
    ProjectileProp : creative_prop_asset = external {}

    # Damage device for when projectile hits
    @editable
    DamageVolume : damage_volume_device = damage_volume_device{}

    # Visual effect on impact
    @editable
    ImpactVFX : vfx_spawner_device = vfx_spawner_device{}

    # Sound effect on fire
    @editable
    FireSFX : audio_player_device = audio_player_device{}

    # Sound effect on impact
    @editable
    ImpactSFX : audio_player_device = audio_player_device{}

    # Projectile configuration
    var Config : weapon_config = weapon_config{}
    var CurrentState : projectile_state = projectile_state.Expired
    var Position : vector3 = vector3{}
    var Velocity : vector3 = vector3{}
    var TargetPosition : vector3 = vector3{}
    var HasTarget : logic = false
    var OwnerAgent : ?agent = false
    var Lifetime : float = 5.0  # Max seconds before expiring
    var ElapsedTime : float = 0.0

    # Initialize the projectile
    Initialize(WeaponType : weapon_type, StartPos : vector3, InitialDirection : vector3, Owner : agent) : void =
        set Config = GetWeaponConfig(WeaponType)
        set Position = StartPos
        set Velocity = InitialDirection * Config.ProjectileSpeed
        set OwnerAgent = option{Owner}
        set CurrentState = projectile_state.Active
        set ElapsedTime = 0.0
        set HasTarget = false

        # Play fire sound
        FireSFX.Play()

    # Set a target for homing behavior
    SetTarget(TargetPos : vector3) : void =
        set TargetPosition = TargetPos
        set HasTarget = true

    # Update projectile each frame
    UpdateProjectile(DeltaTime : float) : projectile_state =
        if (CurrentState <> projectile_state.Active):
            return CurrentState

        # Update elapsed time
        set ElapsedTime = ElapsedTime + DeltaTime

        # Check if lifetime expired
        if (ElapsedTime >= Lifetime):
            set CurrentState = projectile_state.Expired
            return CurrentState

        # Apply homing behavior if we have a target
        if (HasTarget = true):
            DirectionToTarget := TargetPosition - Position
            DistanceToTarget := Sqrt(
                DirectionToTarget.X * DirectionToTarget.X +
                DirectionToTarget.Y * DirectionToTarget.Y +
                DirectionToTarget.Z * DirectionToTarget.Z
            )

            if (DistanceToTarget > 1.0):
                NormalizedDirection := vector3{
                    X := DirectionToTarget.X / DistanceToTarget,
                    Y := DirectionToTarget.Y / DistanceToTarget,
                    Z := DirectionToTarget.Z / DistanceToTarget
                }

                # Interpolate velocity towards target direction
                HomingFactor := Config.HomingStrength * DeltaTime * 5.0
                set Velocity = vector3{
                    X := Velocity.X + (NormalizedDirection.X * Config.ProjectileSpeed - Velocity.X) * HomingFactor,
                    Y := Velocity.Y + (NormalizedDirection.Y * Config.ProjectileSpeed - Velocity.Y) * HomingFactor,
                    Z := Velocity.Z + (NormalizedDirection.Z * Config.ProjectileSpeed - Velocity.Z) * HomingFactor
                }

        # Update position
        set Position = vector3{
            X := Position.X + Velocity.X * DeltaTime,
            Y := Position.Y + Velocity.Y * DeltaTime,
            Z := Position.Z + Velocity.Z * DeltaTime
        }

        return CurrentState

    # Handle projectile hitting a target
    OnHit() : void =
        if (CurrentState = projectile_state.Active):
            set CurrentState = projectile_state.Hit
            ImpactVFX.Activate()
            ImpactSFX.Play()

    # Get the damage value
    GetDamage() : float =
        Config.Damage

    # Get current position
    GetPosition() : vector3 =
        Position

    # Check if projectile is still active
    IsActive() : logic =
        CurrentState = projectile_state.Active

    # Clean up projectile
    Cleanup() : void =
        set CurrentState = projectile_state.Expired

# Projectile pool manager - manages a pool of projectiles for efficiency
projectile_pool_manager := class(creative_device):
    # Pool size
    @editable
    PoolSize : int = 50

    # Array of projectile visual props (assign in editor)
    @editable
    ProjectileProps : []creative_prop = array{}

    # Projectile configurations
    var ActiveProjectiles : []projectile_data = array{}

    # Projectile data struct (for pooling without full device)
    projectile_data := struct:
        var IsActive : logic
        var WeaponType : weapon_type
        var Position : vector3
        var Velocity : vector3
        var TargetPosition : vector3
        var HasTarget : logic
        var OwnerAgent : ?agent
        var ElapsedTime : float
        var Damage : float
        var HomingStrength : float
        var Speed : float

    # Initialize pool
    OnBegin<override>()<suspends> : void =
        InitializePool()
        # Start update loop
        loop:
            UpdateAllProjectiles(0.016)  # ~60 FPS
            Sleep(0.016)

    InitializePool() : void =
        for (I := 0..PoolSize - 1):
            NewProjectile := projectile_data{
                IsActive := false,
                WeaponType := weapon_type.MegaBuster,
                Position := vector3{X := 0.0, Y := 0.0, Z := 0.0},
                Velocity := vector3{X := 0.0, Y := 0.0, Z := 0.0},
                TargetPosition := vector3{X := 0.0, Y := 0.0, Z := 0.0},
                HasTarget := false,
                OwnerAgent := false,
                ElapsedTime := 0.0,
                Damage := 0.0,
                HomingStrength := 0.0,
                Speed := 0.0
            }
            set ActiveProjectiles = ActiveProjectiles + array{NewProjectile}

    # Spawn a new projectile from the pool
    SpawnProjectile(
        WeaponType : weapon_type,
        StartPos : vector3,
        Direction : vector3,
        Owner : agent,
        Target : ?vector3
    ) : int =
        Config := GetWeaponConfig(WeaponType)

        # Find inactive projectile in pool
        for (I := 0..ActiveProjectiles.Length - 1):
            if (Projectile := ActiveProjectiles[I]):
                if (Projectile.IsActive = false):
                    # Activate this projectile
                    UpdatedProjectile := projectile_data{
                        IsActive := true,
                        WeaponType := WeaponType,
                        Position := StartPos,
                        Velocity := vector3{
                            X := Direction.X * Config.ProjectileSpeed,
                            Y := Direction.Y * Config.ProjectileSpeed,
                            Z := Direction.Z * Config.ProjectileSpeed
                        },
                        TargetPosition := if (T := Target?) then T else vector3{X := 0.0, Y := 0.0, Z := 0.0},
                        HasTarget := if (Target?) then true else false,
                        OwnerAgent := option{Owner},
                        ElapsedTime := 0.0,
                        Damage := Config.Damage,
                        HomingStrength := Config.HomingStrength,
                        Speed := Config.ProjectileSpeed
                    }

                    if (set ActiveProjectiles[I] = UpdatedProjectile) {}
                    return I

        # No available projectile in pool
        return -1

    # Update all active projectiles
    UpdateAllProjectiles(DeltaTime : float) : void =
        MaxLifetime := 5.0

        for (I := 0..ActiveProjectiles.Length - 1):
            if (Projectile := ActiveProjectiles[I]):
                if (Projectile.IsActive = true):
                    # Update elapsed time
                    NewElapsed := Projectile.ElapsedTime + DeltaTime

                    # Check lifetime
                    if (NewElapsed >= MaxLifetime):
                        # Deactivate projectile
                        DeactivatedProjectile := projectile_data{
                            IsActive := false,
                            WeaponType := Projectile.WeaponType,
                            Position := Projectile.Position,
                            Velocity := Projectile.Velocity,
                            TargetPosition := Projectile.TargetPosition,
                            HasTarget := Projectile.HasTarget,
                            OwnerAgent := Projectile.OwnerAgent,
                            ElapsedTime := 0.0,
                            Damage := Projectile.Damage,
                            HomingStrength := Projectile.HomingStrength,
                            Speed := Projectile.Speed
                        }
                        if (set ActiveProjectiles[I] = DeactivatedProjectile) {}
                    else:
                        # Calculate new velocity with homing
                        NewVelocity := if (Projectile.HasTarget = true):
                            DirectionToTarget := vector3{
                                X := Projectile.TargetPosition.X - Projectile.Position.X,
                                Y := Projectile.TargetPosition.Y - Projectile.Position.Y,
                                Z := Projectile.TargetPosition.Z - Projectile.Position.Z
                            }
                            DistSq := DirectionToTarget.X * DirectionToTarget.X +
                                      DirectionToTarget.Y * DirectionToTarget.Y +
                                      DirectionToTarget.Z * DirectionToTarget.Z
                            if (DistSq > 1.0):
                                Dist := Sqrt(DistSq)
                                NormDir := vector3{
                                    X := DirectionToTarget.X / Dist,
                                    Y := DirectionToTarget.Y / Dist,
                                    Z := DirectionToTarget.Z / Dist
                                }
                                HomingFactor := Projectile.HomingStrength * DeltaTime * 5.0
                                vector3{
                                    X := Projectile.Velocity.X + (NormDir.X * Projectile.Speed - Projectile.Velocity.X) * HomingFactor,
                                    Y := Projectile.Velocity.Y + (NormDir.Y * Projectile.Speed - Projectile.Velocity.Y) * HomingFactor,
                                    Z := Projectile.Velocity.Z + (NormDir.Z * Projectile.Speed - Projectile.Velocity.Z) * HomingFactor
                                }
                            else:
                                Projectile.Velocity
                        else:
                            Projectile.Velocity

                        # Calculate new position
                        NewPosition := vector3{
                            X := Projectile.Position.X + NewVelocity.X * DeltaTime,
                            Y := Projectile.Position.Y + NewVelocity.Y * DeltaTime,
                            Z := Projectile.Position.Z + NewVelocity.Z * DeltaTime
                        }

                        # Update projectile
                        UpdatedProjectile := projectile_data{
                            IsActive := true,
                            WeaponType := Projectile.WeaponType,
                            Position := NewPosition,
                            Velocity := NewVelocity,
                            TargetPosition := Projectile.TargetPosition,
                            HasTarget := Projectile.HasTarget,
                            OwnerAgent := Projectile.OwnerAgent,
                            ElapsedTime := NewElapsed,
                            Damage := Projectile.Damage,
                            HomingStrength := Projectile.HomingStrength,
                            Speed := Projectile.Speed
                        }
                        if (set ActiveProjectiles[I] = UpdatedProjectile) {}

    # Deactivate a specific projectile
    DeactivateProjectile(Index : int) : void =
        if (Projectile := ActiveProjectiles[Index]):
            DeactivatedProjectile := projectile_data{
                IsActive := false,
                WeaponType := Projectile.WeaponType,
                Position := Projectile.Position,
                Velocity := Projectile.Velocity,
                TargetPosition := Projectile.TargetPosition,
                HasTarget := Projectile.HasTarget,
                OwnerAgent := Projectile.OwnerAgent,
                ElapsedTime := 0.0,
                Damage := Projectile.Damage,
                HomingStrength := Projectile.HomingStrength,
                Speed := Projectile.Speed
            }
            if (set ActiveProjectiles[Index] = DeactivatedProjectile) {}

    # Get projectile at index
    GetProjectile(Index : int) : ?projectile_data =
        if (Index >= 0 and Index < ActiveProjectiles.Length):
            ActiveProjectiles[Index]
        else:
            false
