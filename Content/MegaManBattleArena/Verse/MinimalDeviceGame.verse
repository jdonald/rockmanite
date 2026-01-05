# MinimalDeviceGame.verse
# MINIMAL DEVICE VERSION - Requires only 1-2 physical devices!
# All game logic implemented in pure Verse code

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Playspaces }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# Import weapon types
using { WeaponTypes }

# ============================================================
# MINIMAL DEVICE MEGA MAN BATTLE ARENA
# ============================================================
# This version requires ONLY:
#   1. One player_spawner_device (required by Fortnite)
#   2. One trigger_device per portal (8 total) - OR use position detection
#
# Everything else is pure Verse code!
# ============================================================

# Game state
minimal_game_state := enum:
    Initializing
    Hub
    EnteringBoss
    BossFight
    BossDefeated
    Victory

# Player data (all tracked in Verse, no devices needed)
player_data := class:
    var Agent : agent
    var Character : ?fort_character = false
    var CurrentWeapon : weapon_type = weapon_type.MegaBuster
    var AcquiredWeapons : []weapon_type = array{weapon_type.MegaBuster}
    var WeaponEnergy : [weapon_type]float = map{}
    var IsCharging : logic = false
    var ChargeTime : float = 0.0
    var ChargeLevel : int = 0
    var Position : vector3 = vector3{}
    var Score : int = 0

# Boss data (all tracked in Verse, no devices needed)
boss_data := class:
    var BossType : boss_type
    var Config : boss_config
    var CurrentHealth : float = 0.0
    var Position : vector3 = vector3{}
    var IsActive : logic = false
    var IsDefeated : logic = false
    var BehaviorTimer : float = 0.0
    var AttackCooldown : float = 0.0
    var CurrentBehavior : int = 0  # 0=idle, 1=move, 2=attack, 3=jump

# Portal zone (position-based detection, no device needed)
portal_zone := struct:
    BossType : boss_type
    Center : vector3
    Radius : float
    BossRoomPosition : vector3

# ============================================================
# MAIN GAME CLASS - MINIMAL DEVICES
# ============================================================

minimal_mega_man_arena := class(creative_device):
    # ========================================
    # REQUIRED DEVICE (only 1!)
    # ========================================
    @editable
    PlayerSpawner : player_spawner_device = player_spawner_device{}

    # ========================================
    # OPTIONAL: Portal triggers (can use position detection instead)
    # If not linked, game uses position-based portal detection
    # ========================================
    @editable
    PortalTrigger_CutMan : ?trigger_device = false
    @editable
    PortalTrigger_IceMan : ?trigger_device = false
    @editable
    PortalTrigger_FireMan : ?trigger_device = false
    @editable
    PortalTrigger_ElecMan : ?trigger_device = false
    @editable
    PortalTrigger_QuickMan : ?trigger_device = false
    @editable
    PortalTrigger_FlashMan : ?trigger_device = false
    @editable
    PortalTrigger_HeatMan : ?trigger_device = false
    @editable
    PortalTrigger_BubbleMan : ?trigger_device = false

    # ========================================
    # OPTIONAL: HUD device for messages
    # If not linked, game uses Print() for debug output
    # ========================================
    @editable
    HUDDevice : ?hud_message_device = false

    # ========================================
    # GAME STATE (all in Verse!)
    # ========================================
    var GameState : minimal_game_state = minimal_game_state.Initializing
    var Players : [agent]player_data = map{}
    var Bosses : [boss_type]boss_data = map{}
    var DefeatedBosses : []boss_type = array{}
    var CurrentBossFight : ?boss_type = false
    var PortalZones : []portal_zone = array{}

    # Random number generator
    var RNG : random_number_generator = random_number_generator{}

    # ========================================
    # LEVEL LAYOUT CONSTANTS (in Verse!)
    # ========================================
    # Hub room
    HubCenter : vector3 = vector3{X := 0.0, Y := 0.0, Z := 100.0}
    HubSize : vector3 = vector3{X := 2000.0, Y := 800.0, Z := 1500.0}

    # Portal positions (4 left, 4 right)
    Portal_CutMan_Pos : vector3 = vector3{X := -900.0, Y := 0.0, Z := 150.0}
    Portal_IceMan_Pos : vector3 = vector3{X := -900.0, Y := 0.0, Z := 400.0}
    Portal_FireMan_Pos : vector3 = vector3{X := -900.0, Y := 0.0, Z := 650.0}
    Portal_ElecMan_Pos : vector3 = vector3{X := -900.0, Y := 0.0, Z := 900.0}
    Portal_QuickMan_Pos : vector3 = vector3{X := 900.0, Y := 0.0, Z := 150.0}
    Portal_FlashMan_Pos : vector3 = vector3{X := 900.0, Y := 0.0, Z := 400.0}
    Portal_HeatMan_Pos : vector3 = vector3{X := 900.0, Y := 0.0, Z := 650.0}
    Portal_BubbleMan_Pos : vector3 = vector3{X := 900.0, Y := 0.0, Z := 900.0}

    # Boss room positions
    BossRoom_CutMan : vector3 = vector3{X := -3000.0, Y := 0.0, Z := 100.0}
    BossRoom_IceMan : vector3 = vector3{X := -3000.0, Y := 0.0, Z := 1500.0}
    BossRoom_FireMan : vector3 = vector3{X := -3000.0, Y := 0.0, Z := 3000.0}
    BossRoom_ElecMan : vector3 = vector3{X := -3000.0, Y := 0.0, Z := 4500.0}
    BossRoom_QuickMan : vector3 = vector3{X := 3000.0, Y := 0.0, Z := 100.0}
    BossRoom_FlashMan : vector3 = vector3{X := 3000.0, Y := 0.0, Z := 1500.0}
    BossRoom_HeatMan : vector3 = vector3{X := 3000.0, Y := 0.0, Z := 3000.0}
    BossRoom_BubbleMan : vector3 = vector3{X := 3000.0, Y := 0.0, Z := 4500.0}

    PortalRadius : float = 150.0
    BossHitRadius : float = 100.0
    ProjectileHitRadius : float = 50.0

    # ========================================
    # INITIALIZATION
    # ========================================

    OnBegin<override>()<suspends> : void =
        Print("╔════════════════════════════════════════════════╗")
        Print("║  MEGA MAN BATTLE ARENA                         ║")
        Print("║  MINIMAL DEVICE VERSION                        ║")
        Print("║                                                 ║")
        Print("║  Required devices: 1 (Player Spawner)          ║")
        Print("║  Optional devices: 8 (Portal Triggers)         ║")
        Print("║  Everything else: Pure Verse code!             ║")
        Print("╚════════════════════════════════════════════════╝")
        Print("")

        # Initialize systems
        InitializePortalZones()
        InitializeBosses()
        SetupOptionalTriggers()

        # Wait for game to fully load
        Sleep(1.0)

        # Initialize players
        InitializePlayers()

        # Start game
        set GameState = minimal_game_state.Hub
        ShowMessage("GAME START! Approach a portal to battle a Robot Master!")

        Print("")
        Print("CONTROLS:")
        Print("  Primary Fire = Shoot")
        Print("  Secondary Fire = Switch Weapon")
        Print("  Hold Primary = Charge Mega Buster")
        Print("")

        # Main game loop - ALL game logic runs here in Verse!
        loop:
            GameUpdate(0.033)  # ~30 FPS update
            Sleep(0.033)

    # Initialize portal zones (position-based detection)
    InitializePortalZones() : void =
        Print("[INIT] Setting up portal zones...")

        set PortalZones = array{
            portal_zone{BossType := boss_type.CutMan, Center := Portal_CutMan_Pos, Radius := PortalRadius, BossRoomPosition := BossRoom_CutMan},
            portal_zone{BossType := boss_type.IceMan, Center := Portal_IceMan_Pos, Radius := PortalRadius, BossRoomPosition := BossRoom_IceMan},
            portal_zone{BossType := boss_type.FireMan, Center := Portal_FireMan_Pos, Radius := PortalRadius, BossRoomPosition := BossRoom_FireMan},
            portal_zone{BossType := boss_type.ElecMan, Center := Portal_ElecMan_Pos, Radius := PortalRadius, BossRoomPosition := BossRoom_ElecMan},
            portal_zone{BossType := boss_type.QuickMan, Center := Portal_QuickMan_Pos, Radius := PortalRadius, BossRoomPosition := BossRoom_QuickMan},
            portal_zone{BossType := boss_type.FlashMan, Center := Portal_FlashMan_Pos, Radius := PortalRadius, BossRoomPosition := BossRoom_FlashMan},
            portal_zone{BossType := boss_type.HeatMan, Center := Portal_HeatMan_Pos, Radius := PortalRadius, BossRoomPosition := BossRoom_HeatMan},
            portal_zone{BossType := boss_type.BubbleMan, Center := Portal_BubbleMan_Pos, Radius := PortalRadius, BossRoomPosition := BossRoom_BubbleMan}
        }

        Print("  8 portal zones configured (position-based detection)")

    # Initialize all bosses (pure Verse, no spawner devices!)
    InitializeBosses() : void =
        Print("[INIT] Setting up bosses...")

        AllBossTypes := array{
            boss_type.CutMan, boss_type.IceMan, boss_type.FireMan, boss_type.ElecMan,
            boss_type.QuickMan, boss_type.FlashMan, boss_type.HeatMan, boss_type.BubbleMan
        }

        for (BT : AllBossTypes):
            Config := GetBossConfig(BT)
            NewBoss := boss_data{
                BossType := BT,
                Config := Config,
                CurrentHealth := Config.MaxHealth,
                Position := GetBossRoomCenter(BT),
                IsActive := false,
                IsDefeated := false,
                BehaviorTimer := 0.0,
                AttackCooldown := Config.AttackCooldown,
                CurrentBehavior := 0
            }
            if (set Bosses[BT] = NewBoss):
                Print("  {Config.DisplayName} initialized")

    # Get boss room center position
    GetBossRoomCenter(BT : boss_type) : vector3 =
        case(BT):
            boss_type.CutMan => BossRoom_CutMan
            boss_type.IceMan => BossRoom_IceMan
            boss_type.FireMan => BossRoom_FireMan
            boss_type.ElecMan => BossRoom_ElecMan
            boss_type.QuickMan => BossRoom_QuickMan
            boss_type.FlashMan => BossRoom_FlashMan
            boss_type.HeatMan => BossRoom_HeatMan
            boss_type.BubbleMan => BossRoom_BubbleMan
            _ => HubCenter

    # Setup optional trigger devices (if provided)
    SetupOptionalTriggers() : void =
        Print("[INIT] Checking optional trigger devices...")

        TriggersLinked := 0

        if (Trigger := PortalTrigger_CutMan?):
            Trigger.TriggeredEvent.Subscribe(OnTrigger_CutMan)
            set TriggersLinked = TriggersLinked + 1

        if (Trigger := PortalTrigger_IceMan?):
            Trigger.TriggeredEvent.Subscribe(OnTrigger_IceMan)
            set TriggersLinked = TriggersLinked + 1

        if (Trigger := PortalTrigger_FireMan?):
            Trigger.TriggeredEvent.Subscribe(OnTrigger_FireMan)
            set TriggersLinked = TriggersLinked + 1

        if (Trigger := PortalTrigger_ElecMan?):
            Trigger.TriggeredEvent.Subscribe(OnTrigger_ElecMan)
            set TriggersLinked = TriggersLinked + 1

        if (Trigger := PortalTrigger_QuickMan?):
            Trigger.TriggeredEvent.Subscribe(OnTrigger_QuickMan)
            set TriggersLinked = TriggersLinked + 1

        if (Trigger := PortalTrigger_FlashMan?):
            Trigger.TriggeredEvent.Subscribe(OnTrigger_FlashMan)
            set TriggersLinked = TriggersLinked + 1

        if (Trigger := PortalTrigger_HeatMan?):
            Trigger.TriggeredEvent.Subscribe(OnTrigger_HeatMan)
            set TriggersLinked = TriggersLinked + 1

        if (Trigger := PortalTrigger_BubbleMan?):
            Trigger.TriggeredEvent.Subscribe(OnTrigger_BubbleMan)
            set TriggersLinked = TriggersLinked + 1

        if (TriggersLinked > 0):
            Print("  {TriggersLinked} trigger devices linked")
        else:
            Print("  No triggers linked - using position-based detection")

    # Trigger handlers
    OnTrigger_CutMan(MaybeAgent : ?agent) : void = if (Agent := MaybeAgent?) then EnterBossRoom(Agent, boss_type.CutMan)
    OnTrigger_IceMan(MaybeAgent : ?agent) : void = if (Agent := MaybeAgent?) then EnterBossRoom(Agent, boss_type.IceMan)
    OnTrigger_FireMan(MaybeAgent : ?agent) : void = if (Agent := MaybeAgent?) then EnterBossRoom(Agent, boss_type.FireMan)
    OnTrigger_ElecMan(MaybeAgent : ?agent) : void = if (Agent := MaybeAgent?) then EnterBossRoom(Agent, boss_type.ElecMan)
    OnTrigger_QuickMan(MaybeAgent : ?agent) : void = if (Agent := MaybeAgent?) then EnterBossRoom(Agent, boss_type.QuickMan)
    OnTrigger_FlashMan(MaybeAgent : ?agent) : void = if (Agent := MaybeAgent?) then EnterBossRoom(Agent, boss_type.FlashMan)
    OnTrigger_HeatMan(MaybeAgent : ?agent) : void = if (Agent := MaybeAgent?) then EnterBossRoom(Agent, boss_type.HeatMan)
    OnTrigger_BubbleMan(MaybeAgent : ?agent) : void = if (Agent := MaybeAgent?) then EnterBossRoom(Agent, boss_type.BubbleMan)

    # Initialize players
    InitializePlayers() : void =
        Print("[INIT] Initializing players...")

        AllPlayers := GetPlayspace().GetPlayers()
        for (Agent : AllPlayers):
            InitializePlayer(Agent)

        Print("  {AllPlayers.Length} players initialized")

    # Initialize single player
    InitializePlayer(Agent : agent) : void =
        var InitialEnergy : [weapon_type]float = map{}
        if (set InitialEnergy[weapon_type.MegaBuster] = 100.0) {}

        NewPlayer := player_data{
            Agent := Agent,
            CurrentWeapon := weapon_type.MegaBuster,
            AcquiredWeapons := array{weapon_type.MegaBuster},
            WeaponEnergy := InitialEnergy
        }

        # Get character reference
        if (FC := Agent.GetFortCharacter[]):
            set NewPlayer.Character = option{FC}

        if (set Players[Agent] = NewPlayer) {}

    # ========================================
    # MAIN GAME LOOP (Pure Verse!)
    # ========================================

    GameUpdate(DeltaTime : float) : void =
        # Update all player positions and check portals
        UpdatePlayers(DeltaTime)

        # Update boss AI during boss fights
        if (GameState = minimal_game_state.BossFight):
            UpdateBossFight(DeltaTime)

    # Update all players
    UpdatePlayers(DeltaTime : float) : void =
        for (Agent -> PlayerInfo : Players):
            # Update player position from character
            if (FC := PlayerInfo.Character?):
                set PlayerInfo.Position = FC.GetTransform().Translation

            # Update charging
            if (PlayerInfo.IsCharging = true):
                set PlayerInfo.ChargeTime = PlayerInfo.ChargeTime + DeltaTime
                NewLevel := GetChargeLevel(PlayerInfo.ChargeTime)
                if (NewLevel <> PlayerInfo.ChargeLevel):
                    set PlayerInfo.ChargeLevel = NewLevel
                    ShowChargeLevel(Agent, NewLevel)

            # Check portal proximity (if in hub)
            if (GameState = minimal_game_state.Hub):
                CheckPortalProximity(Agent, PlayerInfo)

            # Update player data
            if (set Players[Agent] = PlayerInfo) {}

    # Get charge level from time
    GetChargeLevel(Time : float) : int =
        if (Time >= 2.0):
            3
        else if (Time >= 1.0):
            2
        else if (Time >= 0.5):
            1
        else:
            0

    # Show charge level feedback
    ShowChargeLevel(Agent : agent, Level : int) : void =
        case(Level):
            1 => Print("Charge: [=]")
            2 => Print("Charge: [==]")
            3 => Print("Charge: [===] MAX!")
            _ => {}

    # Check if player is near a portal
    CheckPortalProximity(Agent : agent, PlayerInfo : player_data) : void =
        for (Zone : PortalZones):
            if (IsInRadius(PlayerInfo.Position, Zone.Center, Zone.Radius)):
                # Check if boss not already defeated
                IsDefeated := false
                for (DB : DefeatedBosses):
                    if (DB = Zone.BossType):
                        set IsDefeated = true

                if (IsDefeated = false):
                    EnterBossRoom(Agent, Zone.BossType)
                    return  # Only enter one portal

    # Check if point is within radius of target
    IsInRadius(Point : vector3, Target : vector3, Radius : float) : logic =
        DX := Point.X - Target.X
        DY := Point.Y - Target.Y
        DZ := Point.Z - Target.Z
        DistSq := DX * DX + DY * DY + DZ * DZ
        DistSq <= Radius * Radius

    # ========================================
    # BOSS ROOM ENTRY (Pure Verse teleport!)
    # ========================================

    EnterBossRoom(Agent : agent, BT : boss_type) : void =
        if (GameState <> minimal_game_state.Hub):
            return  # Already in a boss fight

        Config := GetBossConfig(BT)
        BossRoomPos := GetBossRoomCenter(BT)

        Print("")
        Print("╔════════════════════════════════════════════════╗")
        Print("║  ENTERING: {Config.DisplayName}'s Room")
        Print("╚════════════════════════════════════════════════╝")

        # Teleport player using pure Verse!
        if (PlayerInfo := Players[Agent]):
            if (FC := PlayerInfo.Character?):
                # Teleport to boss room
                TeleportResult := FC.TeleportTo[BossRoomPos, FC.GetTransform().Rotation]
                if (TeleportResult):
                    Print("  Teleported to boss room!")

        # Activate boss
        if (Boss := Bosses[BT]):
            set Boss.IsActive = true
            set Boss.CurrentHealth = Boss.Config.MaxHealth
            set Boss.Position = BossRoomPos + vector3{X := 300.0, Y := 0.0, Z := 0.0}
            if (set Bosses[BT] = Boss) {}

        set CurrentBossFight = option{BT}
        set GameState = minimal_game_state.BossFight

        # Show boss intro
        WeaknessConfig := GetWeaponConfig(Config.Weakness)
        ShowMessage("BOSS: {Config.DisplayName} | HP: {Config.MaxHealth} | Weak to: {WeaknessConfig.DisplayName}")

    # ========================================
    # BOSS FIGHT (Pure Verse AI!)
    # ========================================

    UpdateBossFight(DeltaTime : float) : void =
        if (BT := CurrentBossFight?):
            if (Boss := Bosses[BT]):
                if (Boss.IsActive = true):
                    UpdateBossAI(Boss, DeltaTime)
                    if (set Bosses[BT] = Boss) {}

    # Update boss AI behavior
    UpdateBossAI(Boss : boss_data, DeltaTime : float) : void =
        # Update timers
        set Boss.BehaviorTimer = Boss.BehaviorTimer + DeltaTime
        set Boss.AttackCooldown = Boss.AttackCooldown - DeltaTime

        # Simple AI state machine
        case(Boss.CurrentBehavior):
            0 =>  # Idle
                if (Boss.BehaviorTimer > 0.5):
                    set Boss.CurrentBehavior = 1  # Start moving
                    set Boss.BehaviorTimer = 0.0

            1 =>  # Moving
                # Move towards random direction
                MoveDir := if (RNG.GetRandomFloat() > 0.5) then 1.0 else -1.0
                NewX := Boss.Position.X + MoveDir * Boss.Config.MoveSpeed * DeltaTime
                set Boss.Position = vector3{X := NewX, Y := Boss.Position.Y, Z := Boss.Position.Z}

                if (Boss.BehaviorTimer > 1.0):
                    if (Boss.AttackCooldown <= 0.0):
                        set Boss.CurrentBehavior = 2  # Attack
                        set Boss.BehaviorTimer = 0.0
                    else if (RNG.GetRandomFloat() > 0.7):
                        set Boss.CurrentBehavior = 3  # Jump
                        set Boss.BehaviorTimer = 0.0

            2 =>  # Attacking
                if (Boss.BehaviorTimer < 0.1):
                    # Fire projectile at player
                    BossAttack(Boss)

                if (Boss.BehaviorTimer > 0.5):
                    set Boss.CurrentBehavior = 1  # Back to moving
                    set Boss.BehaviorTimer = 0.0
                    set Boss.AttackCooldown = Boss.Config.AttackCooldown

            3 =>  # Jumping
                # Simple jump arc
                JumpProgress := Boss.BehaviorTimer / 0.8
                if (JumpProgress < 1.0):
                    JumpHeight := Sin(JumpProgress * 3.14159) * 200.0
                    BaseZ := GetBossRoomCenter(Boss.BossType).Z
                    set Boss.Position = vector3{X := Boss.Position.X, Y := Boss.Position.Y, Z := BaseZ + JumpHeight}
                else:
                    set Boss.CurrentBehavior = 1  # Back to moving
                    set Boss.BehaviorTimer = 0.0

            _ =>
                set Boss.CurrentBehavior = 0

    # Boss attacks (pure Verse!)
    BossAttack(Boss : boss_data) : void =
        Config := GetWeaponConfig(Boss.Config.WeaponUsed)
        Print("  {Boss.Config.DisplayName} attacks with {Config.DisplayName}!")

        # In a full implementation, this would spawn a projectile
        # For now, we'll do instant damage check against nearby players
        for (Agent -> PlayerInfo : Players):
            if (IsInRadius(PlayerInfo.Position, Boss.Position, 500.0)):
                DamagePlayer(Agent, Config.Damage)

    # Damage player (pure Verse!)
    DamagePlayer(Agent : agent, Damage : float) : void =
        if (PlayerInfo := Players[Agent]):
            if (FC := PlayerInfo.Character?):
                # Apply damage through fort_character
                FC.Damage(Damage)
                Print("  Player took {Damage} damage!")

    # ========================================
    # PLAYER COMBAT (Pure Verse!)
    # ========================================

    # Called when player fires (hook this to input)
    PlayerFire(Agent : agent) : void =
        if (PlayerInfo := Players[Agent]):
            Config := GetWeaponConfig(PlayerInfo.CurrentWeapon)

            # Calculate damage with charge multiplier
            ChargeMultiplier := case(PlayerInfo.ChargeLevel):
                0 => 1.0
                1 => 1.5
                2 => 2.5
                3 => 4.0
                _ => 1.0

            FinalDamage := Config.Damage * ChargeMultiplier

            Print("FIRE! {Config.DisplayName} ({FinalDamage} damage)")

            # Reset charge
            set PlayerInfo.IsCharging = false
            set PlayerInfo.ChargeTime = 0.0
            set PlayerInfo.ChargeLevel = 0
            if (set Players[Agent] = PlayerInfo) {}

            # Damage boss if in boss fight
            if (BT := CurrentBossFight?):
                DamageBoss(Agent, FinalDamage, PlayerInfo.CurrentWeapon)

    # Damage boss (pure Verse!)
    DamageBoss(Agent : agent, Damage : float, WeaponUsed : weapon_type) : void =
        if (BT := CurrentBossFight?):
            if (Boss := Bosses[BT]):
                # Check weakness
                IsWeakness := WeaponUsed = Boss.Config.Weakness
                FinalDamage := if (IsWeakness):
                    Damage * Boss.Config.WeaknessDamageMultiplier
                else:
                    Damage

                # Apply damage
                set Boss.CurrentHealth = Boss.CurrentHealth - FinalDamage

                if (IsWeakness):
                    Print("  SUPER EFFECTIVE! {FinalDamage} damage!")
                else:
                    Print("  {FinalDamage} damage!")

                Print("  {Boss.Config.DisplayName} HP: {Boss.CurrentHealth}/{Boss.Config.MaxHealth}")

                # Check defeat
                if (Boss.CurrentHealth <= 0.0):
                    set Boss.CurrentHealth = 0.0
                    set Boss.IsActive = false
                    set Boss.IsDefeated = true
                    if (set Bosses[BT] = Boss) {}
                    OnBossDefeated(Agent, BT)
                else:
                    if (set Bosses[BT] = Boss) {}

    # ========================================
    # BOSS DEFEATED (Pure Verse!)
    # ========================================

    OnBossDefeated(Agent : agent, BT : boss_type) : void =
        Config := GetBossConfig(BT)
        WeaponGranted := GetWeaponFromBoss(BT)
        WeaponConfig := GetWeaponConfig(WeaponGranted)

        Print("")
        Print("╔════════════════════════════════════════════════╗")
        Print("║  {Config.DisplayName} DEFEATED!")
        Print("╠════════════════════════════════════════════════╣")
        Print("║  YOU GOT: {WeaponConfig.DisplayName}")
        Print("╚════════════════════════════════════════════════╝")
        Print("")

        # Grant weapon
        GrantWeapon(Agent, WeaponGranted)

        # Add to defeated list
        set DefeatedBosses = DefeatedBosses + array{BT}
        set CurrentBossFight = false

        Print("  Bosses defeated: {DefeatedBosses.Length}/8")

        # Teleport back to hub
        if (PlayerInfo := Players[Agent]):
            if (FC := PlayerInfo.Character?):
                FC.TeleportTo[HubCenter, FC.GetTransform().Rotation]

        # Check victory
        if (DefeatedBosses.Length >= 8):
            OnVictory()
        else:
            set GameState = minimal_game_state.Hub
            ShowMessage("Returned to hub! {8 - DefeatedBosses.Length} bosses remaining.")

    # Grant weapon to player
    GrantWeapon(Agent : agent, Weapon : weapon_type) : void =
        if (PlayerInfo := Players[Agent]):
            # Check if already has
            HasWeapon := false
            for (W : PlayerInfo.AcquiredWeapons):
                if (W = Weapon):
                    set HasWeapon = true

            if (HasWeapon = false):
                set PlayerInfo.AcquiredWeapons = PlayerInfo.AcquiredWeapons + array{Weapon}
                if (set PlayerInfo.WeaponEnergy[Weapon] = 100.0) {}
                if (set Players[Agent] = PlayerInfo) {}

                Config := GetWeaponConfig(Weapon)
                Print("  Acquired: {Config.DisplayName}")

    # ========================================
    # WEAPON SWITCHING (Pure Verse!)
    # ========================================

    SwitchWeapon(Agent : agent, Direction : int) : void =
        if (PlayerInfo := Players[Agent]):
            WeaponCount := PlayerInfo.AcquiredWeapons.Length
            if (WeaponCount <= 1):
                return

            # Find current index
            CurrentIndex := 0
            for (I := 0..WeaponCount - 1):
                if (W := PlayerInfo.AcquiredWeapons[I]):
                    if (W = PlayerInfo.CurrentWeapon):
                        set CurrentIndex = I

            # Calculate new index
            NewIndex := (CurrentIndex + Direction + WeaponCount) mod WeaponCount

            if (NewWeapon := PlayerInfo.AcquiredWeapons[NewIndex]):
                set PlayerInfo.CurrentWeapon = NewWeapon
                set PlayerInfo.ChargeLevel = 0
                set PlayerInfo.ChargeTime = 0.0
                if (set Players[Agent] = PlayerInfo) {}

                Config := GetWeaponConfig(NewWeapon)
                ShowMessage("Weapon: {Config.DisplayName}")

    # ========================================
    # VICTORY
    # ========================================

    OnVictory() : void =
        set GameState = minimal_game_state.Victory

        Print("")
        Print("╔════════════════════════════════════════════════╗")
        Print("║         CONGRATULATIONS!                       ║")
        Print("║    ALL ROBOT MASTERS DEFEATED!                 ║")
        Print("╠════════════════════════════════════════════════╣")
        Print("║  WEAPONS COLLECTED:                            ║")
        Print("║  ✓ Rolling Cutter   ✓ Quick Boomerang          ║")
        Print("║  ✓ Ice Slasher      ✓ Atomic Fire              ║")
        Print("║  ✓ Fire Storm       ✓ Crash Bomber             ║")
        Print("║  ✓ Thunder Beam     ✓ Time Stopper             ║")
        Print("╚════════════════════════════════════════════════╝")
        Print("")

        ShowMessage("VICTORY! All 8 Robot Masters defeated!")

    # ========================================
    # UTILITY
    # ========================================

    ShowMessage(Msg : string) : void =
        Print(Msg)
        # If HUD device is linked, use it too
        if (HUD := HUDDevice?):
            HUD.Show()

    # Sin function approximation for jump arc
    Sin(X : float) : float =
        # Taylor series approximation
        X3 := X * X * X
        X5 := X3 * X * X
        X - (X3 / 6.0) + (X5 / 120.0)
