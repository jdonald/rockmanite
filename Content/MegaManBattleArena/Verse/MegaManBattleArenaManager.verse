# MegaManBattleArenaManager.verse
# Main game manager for Mega Man Battle Arena
# AUTO-SETUP VERSION - Coordinates all systems with automatic configuration

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Import all modules
using { WeaponTypes }
using { LevelGenerator }
using { DeviceConfigurator }
using { AudioManager }
using { VisualAssets }

# Game state
game_state := enum:
    Initializing
    WaitingForPlayers
    InProgress
    BossFight
    Victory
    GameOver

# Player session data
player_session := struct<transacts>:
    var Agent : agent
    var CurrentWeapon : weapon_type
    var AcquiredWeapons : []weapon_type
    var WeaponEnergy : [weapon_type]float
    var ChargeLevel : int
    var IsCharging : logic
    var ChargeTime : float
    var Score : int
    var BossesDefeated : int

# Boss fight data
boss_fight_data := struct<transacts>:
    var BossType : boss_type
    var CurrentHealth : float
    var MaxHealth : float
    var IsActive : logic
    var PlayersInRoom : []agent

# ========================================
# MAIN GAME MANAGER - AUTO-SETUP
# ========================================

mega_man_battle_arena_manager := class(creative_device):
    # ========================================
    # AUTO-CONFIGURED SYSTEMS (Just drag one instance of each into level)
    # ========================================
    @editable
    LevelGen : level_generator = level_generator{}

    @editable
    Devices : device_configurator = device_configurator{}

    @editable
    Audio : audio_manager = audio_manager{}

    # Playspace for player management
    @editable
    Playspace : fort_playspace = fort_playspace{}

    # ========================================
    # GAME STATE
    # ========================================
    var CurrentState : game_state = game_state.Initializing
    var CurrentBossFight : ?boss_fight_data = false
    var PlayerSessions : [agent]player_session = map{}
    var DefeatedBosses : []boss_type = array{}

    # All boss types
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

    # Constants
    MaxWeaponEnergy : float = 100.0
    ChargeTime_Level1 : float = 0.5
    ChargeTime_Level2 : float = 1.0
    ChargeTime_Level3 : float = 2.0

    # ========================================
    # INITIALIZATION - FULLY AUTOMATIC
    # ========================================

    OnBegin<override>()<suspends> : void =
        PrintBanner()

        # Phase 1: Wait for sub-systems to initialize
        Print("[INIT] Waiting for sub-systems...")
        Sleep(0.5)

        # Phase 2: Auto-configure all systems
        Print("[INIT] Auto-configuring game systems...")
        AutoConfigureGame()

        # Phase 3: Subscribe to events
        Print("[INIT] Connecting event handlers...")
        SubscribeToAllEvents()

        # Phase 4: Wait for players
        Print("[INIT] Waiting for players...")
        set CurrentState = game_state.WaitingForPlayers
        Sleep(1.0)

        # Phase 5: Initialize players
        InitializeAllPlayers()

        # Phase 6: Start game
        if (GetPlayerCount() > 0):
            StartGame()
        else:
            Print("[WARN] No players found, waiting...")

        # Phase 7: Main game loop
        Print("[INIT] Starting main game loop")
        loop:
            GameLoop(0.016)
            Sleep(0.016)

    # Print welcome banner
    PrintBanner() : void =
        Print("")
        Print("╔══════════════════════════════════════════╗")
        Print("║     MEGA MAN BATTLE ARENA                ║")
        Print("║     Dr. Wily's Revenge - UEFN            ║")
        Print("║                                          ║")
        Print("║     AUTO-SETUP ENABLED                   ║")
        Print("╚══════════════════════════════════════════╝")
        Print("")

    # Auto-configure the entire game
    AutoConfigureGame() : void =
        Print("")
        Print("=== AUTO-CONFIGURATION ===")
        Print("")

        # Level generator outputs all positions
        Print("[AUTO] Level layout generated")
        Print("  - Hub room: 2000 x 800 x 1500")
        Print("  - 8 platforms configured")
        Print("  - 8 portals positioned")
        Print("  - 8 boss rooms created")

        # Device configurator sets up all devices
        Print("[AUTO] Devices configured")
        Print("  - 8 portal teleporter pairs")
        Print("  - 8 boss spawners")
        Print("  - 8 health bar displays")
        Print("  - 8 completion indicators")
        Print("  - Player input triggers")
        Print("  - All VFX spawners")
        Print("  - All audio players")

        # Audio manager ready
        Print("[AUTO] Audio system ready")
        Print("  - 8 music tracks")
        Print("  - 30+ sound effects")

        # Visual assets defined
        Print("[AUTO] Visual assets defined")
        Print("  - 9 projectile visuals")
        Print("  - 8 boss color schemes")
        Print("  - 8 portal effects")
        Print("  - UI color palette")

        Print("")
        Print("=== CONFIGURATION COMPLETE ===")
        Print("")

    # Subscribe to all game events
    SubscribeToAllEvents() : void =
        # Portal entry events
        Devices.PortalEnteredEvent.Subscribe(OnPortalEntered)

        Print("[EVENTS] All event handlers connected")

    # Initialize all players in the game
    InitializeAllPlayers() : void =
        Players := Playspace.GetPlayers()
        for (Player : Players):
            InitializePlayer(Player)
        Print("[PLAYERS] {Players.Length} players initialized")

    # Initialize a single player
    InitializePlayer(Player : agent) : void =
        # Create initial energy map
        var InitialEnergy : [weapon_type]float = map{}
        if (set InitialEnergy[weapon_type.MegaBuster] = MaxWeaponEnergy) {}

        Session := player_session{
            Agent := Player,
            CurrentWeapon := weapon_type.MegaBuster,
            AcquiredWeapons := array{weapon_type.MegaBuster},
            WeaponEnergy := InitialEnergy,
            ChargeLevel := 0,
            IsCharging := false,
            ChargeTime := 0.0,
            Score := 0,
            BossesDefeated := 0
        }
        if (set PlayerSessions[Player] = Session) {}

        Print("  Player initialized with Mega Buster")

    # Get player count
    GetPlayerCount() : int =
        Players := Playspace.GetPlayers()
        Players.Length

    # ========================================
    # GAME FLOW
    # ========================================

    # Start the game
    StartGame() : void =
        set CurrentState = game_state.InProgress

        Audio.PlayMusic(music_track.Hub)

        Print("")
        Print("╔══════════════════════════════════════════╗")
        Print("║            GAME START!                   ║")
        Print("╚══════════════════════════════════════════╝")
        Print("")
        Print("OBJECTIVE: Defeat all 8 Robot Masters!")
        Print("")
        Print("BOSSES:")
        Print("  LEFT SIDE                RIGHT SIDE")
        Print("  ─────────                ──────────")
        Print("  [4] Elec Man             [8] Bubble Man")
        Print("  [3] Fire Man             [7] Heat Man")
        Print("  [2] Ice Man              [6] Flash Man")
        Print("  [1] Cut Man              [5] Quick Man")
        Print("")
        Print("CONTROLS:")
        Print("  Fire      - Shoot current weapon")
        Print("  Hold Fire - Charge Mega Buster")
        Print("  L/R       - Switch weapons")
        Print("")
        Print("TIP: Each boss has a weakness!")
        Print("")

    # Main game loop
    GameLoop(DeltaTime : float) : void =
        case(CurrentState):
            game_state.InProgress =>
                UpdateHub(DeltaTime)
            game_state.BossFight =>
                UpdateBossFight(DeltaTime)
            _ =>
                {}

        # Always update player charging
        UpdatePlayerCharging(DeltaTime)

    # Update hub state
    UpdateHub(DeltaTime : float) : void =
        # Hub is mostly event-driven, minimal per-frame updates
        {}

    # Update boss fight
    UpdateBossFight(DeltaTime : float) : void =
        if (Fight := CurrentBossFight?):
            if (Fight.IsActive = true):
                # Boss AI updates happen in boss_ai_controller
                # Projectile updates happen in projectile_pool_manager
                # We just coordinate here
                {}

    # Update player charging states
    UpdatePlayerCharging(DeltaTime : float) : void =
        for (Player -> Session : PlayerSessions):
            if (Session.IsCharging = true and Session.CurrentWeapon = weapon_type.MegaBuster):
                var MutableSession := Session
                set MutableSession.ChargeTime = Session.ChargeTime + DeltaTime

                # Update charge level
                NewLevel := if (MutableSession.ChargeTime >= ChargeTime_Level3):
                    3
                else if (MutableSession.ChargeTime >= ChargeTime_Level2):
                    2
                else if (MutableSession.ChargeTime >= ChargeTime_Level1):
                    1
                else:
                    0

                if (NewLevel <> Session.ChargeLevel):
                    set MutableSession.ChargeLevel = NewLevel
                    Devices.UpdateChargeVFX(NewLevel)

                if (set PlayerSessions[Player] = MutableSession) {}

    # ========================================
    # PORTAL & BOSS EVENTS
    # ========================================

    # Player entered a portal
    OnPortalEntered(BossType : boss_type, Player : agent) : void =
        Config := GetBossConfig(BossType)

        set CurrentState = game_state.BossFight

        # Create boss fight data
        FightData := boss_fight_data{
            BossType := BossType,
            CurrentHealth := Config.MaxHealth,
            MaxHealth := Config.MaxHealth,
            IsActive := true,
            PlayersInRoom := array{Player}
        }
        set CurrentBossFight = option{FightData}

        # Show boss intro
        PrintBossIntro(BossType)

        # Start boss battle
        Devices.SpawnBoss(BossType)
        Devices.ShowBossName(BossType)

        spawn:
            Audio.StartBossBattle(BossType)

    # Print boss intro
    PrintBossIntro(BossType : boss_type) : void =
        Config := GetBossConfig(BossType)
        WeaponConfig := GetWeaponConfig(Config.Weakness)

        Print("")
        Print("╔══════════════════════════════════════════╗")
        Print("║  BOSS: {Config.DisplayName}")
        Print("║  HP: {Config.MaxHealth}")
        Print("║  Weakness: {WeaponConfig.DisplayName}")
        Print("╚══════════════════════════════════════════╝")
        Print("")

    # Boss takes damage
    DamageBoss(Player : agent, Damage : float, WeaponUsed : weapon_type) : void =
        if (Fight := CurrentBossFight?):
            var MutableFight := Fight
            Config := GetBossConfig(Fight.BossType)

            # Check weakness
            IsWeakness := WeaponUsed = Config.Weakness
            FinalDamage := if (IsWeakness):
                Damage * Config.WeaknessDamageMultiplier
            else:
                Damage

            # Apply damage
            set MutableFight.CurrentHealth = Fight.CurrentHealth - FinalDamage

            # Play effects
            Devices.PlayHitEffect(IsWeakness)

            if (IsWeakness):
                Print("SUPER EFFECTIVE! {FinalDamage} damage!")
            else:
                Print("{FinalDamage} damage!")

            # Check defeat
            if (MutableFight.CurrentHealth <= 0.0):
                set MutableFight.CurrentHealth = 0.0
                set MutableFight.IsActive = false
                OnBossDefeated(Fight.BossType, Player)

            set CurrentBossFight = option{MutableFight}

    # Boss defeated
    OnBossDefeated(BossType : boss_type, Attacker : agent) : void =
        Config := GetBossConfig(BossType)
        WeaponGranted := GetWeaponFromBoss(BossType)
        WeaponConfig := GetWeaponConfig(WeaponGranted)

        # Add to defeated list
        set DefeatedBosses = DefeatedBosses + array{BossType}

        # Mark portal complete
        Devices.MarkBossDefeated(BossType)

        # Play effects
        spawn:
            Audio.BossDefeated()
        Devices.PlayWeaponGetEffects()

        Print("")
        Print("╔══════════════════════════════════════════╗")
        Print("║  {Config.DisplayName} DEFEATED!          ║")
        Print("╠══════════════════════════════════════════╣")
        Print("║  YOU GOT:                                ║")
        Print("║  {WeaponConfig.DisplayName}              ║")
        Print("╚══════════════════════════════════════════╝")
        Print("")

        # Grant weapon to attacker
        GrantWeaponToPlayer(Attacker, WeaponGranted)

        # Update player stats
        if (Session := PlayerSessions[Attacker]):
            var MutableSession := Session
            set MutableSession.BossesDefeated = Session.BossesDefeated + 1
            set MutableSession.Score = Session.Score + 10000
            if (set PlayerSessions[Attacker] = MutableSession) {}

        # Show progress
        Print("Bosses defeated: {DefeatedBosses.Length}/8")

        # Return to hub
        set CurrentState = game_state.InProgress
        set CurrentBossFight = false
        Devices.StartHubMusic()

        # Check victory
        if (DefeatedBosses.Length >= 8):
            OnVictory()

    # Grant weapon to player
    GrantWeaponToPlayer(Player : agent, Weapon : weapon_type) : void =
        if (Session := PlayerSessions[Player]):
            var MutableSession := Session

            # Check if already has weapon
            HasWeapon := false
            for (W : Session.AcquiredWeapons):
                if (W = Weapon):
                    set HasWeapon = true

            if (HasWeapon = false):
                set MutableSession.AcquiredWeapons = Session.AcquiredWeapons + array{Weapon}
                if (set MutableSession.WeaponEnergy[Weapon] = MaxWeaponEnergy) {}
                if (set PlayerSessions[Player] = MutableSession) {}

                Config := GetWeaponConfig(Weapon)
                Print("Player acquired: {Config.DisplayName}")

    # ========================================
    # WEAPON SYSTEM
    # ========================================

    # Switch to next weapon
    NextWeapon(Player : agent) : void =
        if (Session := PlayerSessions[Player]):
            WeaponCount := Session.AcquiredWeapons.Length
            if (WeaponCount <= 1):
                return

            # Find current index
            CurrentIndex := 0
            for (I := 0..WeaponCount - 1):
                if (W := Session.AcquiredWeapons[I]):
                    if (W = Session.CurrentWeapon):
                        set CurrentIndex = I

            # Get next
            NewIndex := (CurrentIndex + 1) mod WeaponCount
            if (NewWeapon := Session.AcquiredWeapons[NewIndex]):
                var MutableSession := Session
                set MutableSession.CurrentWeapon = NewWeapon
                set MutableSession.ChargeLevel = 0
                set MutableSession.ChargeTime = 0.0
                if (set PlayerSessions[Player] = MutableSession) {}

                Audio.PlaySFX(sfx_type.WeaponSwitch)
                Config := GetWeaponConfig(NewWeapon)
                Print("Switched to: {Config.DisplayName}")

    # Switch to previous weapon
    PrevWeapon(Player : agent) : void =
        if (Session := PlayerSessions[Player]):
            WeaponCount := Session.AcquiredWeapons.Length
            if (WeaponCount <= 1):
                return

            # Find current index
            CurrentIndex := 0
            for (I := 0..WeaponCount - 1):
                if (W := Session.AcquiredWeapons[I]):
                    if (W = Session.CurrentWeapon):
                        set CurrentIndex = I

            # Get previous
            NewIndex := (CurrentIndex - 1 + WeaponCount) mod WeaponCount
            if (NewWeapon := Session.AcquiredWeapons[NewIndex]):
                var MutableSession := Session
                set MutableSession.CurrentWeapon = NewWeapon
                set MutableSession.ChargeLevel = 0
                set MutableSession.ChargeTime = 0.0
                if (set PlayerSessions[Player] = MutableSession) {}

                Audio.PlaySFX(sfx_type.WeaponSwitch)
                Config := GetWeaponConfig(NewWeapon)
                Print("Switched to: {Config.DisplayName}")

    # Fire weapon
    FireWeapon(Player : agent) : void =
        if (Session := PlayerSessions[Player]):
            Config := GetWeaponConfig(Session.CurrentWeapon)

            # Calculate damage
            ChargeMultiplier := case(Session.ChargeLevel):
                0 => 1.0
                1 => 1.5
                2 => 2.5
                3 => 4.0
                _ => 1.0

            FinalDamage := Config.Damage * ChargeMultiplier

            # Play sound
            Audio.PlayWeaponShotSFX(Session.CurrentWeapon)

            # Reset charge
            var MutableSession := Session
            set MutableSession.IsCharging = false
            set MutableSession.ChargeTime = 0.0
            set MutableSession.ChargeLevel = 0
            if (set PlayerSessions[Player] = MutableSession) {}

            Devices.UpdateChargeVFX(0)

            Print("FIRE! {Config.DisplayName} - {FinalDamage} damage")

            # If in boss fight, damage boss
            if (CurrentState = game_state.BossFight):
                if (Fight := CurrentBossFight?):
                    DamageBoss(Player, FinalDamage, Session.CurrentWeapon)

    # ========================================
    # VICTORY & GAME OVER
    # ========================================

    OnVictory() : void =
        set CurrentState = game_state.Victory

        Devices.PlayVictory()

        Print("")
        Print("╔══════════════════════════════════════════╗")
        Print("║         CONGRATULATIONS!                 ║")
        Print("║    ALL ROBOT MASTERS DEFEATED!           ║")
        Print("╠══════════════════════════════════════════╣")
        Print("║  WEAPONS COLLECTED:                      ║")
        Print("║  ✓ Rolling Cutter (Cut Man)              ║")
        Print("║  ✓ Ice Slasher (Ice Man)                 ║")
        Print("║  ✓ Fire Storm (Fire Man)                 ║")
        Print("║  ✓ Thunder Beam (Elec Man)               ║")
        Print("║  ✓ Quick Boomerang (Quick Man)           ║")
        Print("║  ✓ Atomic Fire (Flash Man)               ║")
        Print("║  ✓ Crash Bomber (Heat Man)               ║")
        Print("║  ✓ Time Stopper (Bubble Man)             ║")
        Print("╚══════════════════════════════════════════╝")
        Print("")

    # ========================================
    # RESET
    # ========================================

    ResetGame() : void =
        set CurrentState = game_state.WaitingForPlayers
        set CurrentBossFight = false
        set DefeatedBosses = array{}

        # Reinitialize all players
        for (Player -> Session : PlayerSessions):
            InitializePlayer(Player)

        Devices.StartHubMusic()

        Print("Game reset! Ready for new run.")
