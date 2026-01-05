# DeviceConfigurator.verse
# Automatically configures all devices at runtime
# Eliminates manual device setup in UEFN editor

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Import modules
using { WeaponTypes }

# Device configuration data
portal_device_config := struct:
    BossType : boss_type
    EntryPosition : vector3
    ExitPosition : vector3
    HologramPosition : vector3

boss_device_config := struct:
    BossType : boss_type
    SpawnPosition : vector3
    ArenaCenter : vector3
    ArenaBounds : vector3

player_device_config := struct:
    SpawnPosition : vector3
    WeaponUIPosition : vector3
    EnergyBarPosition : vector3

# Master device configurator - sets up all game devices
device_configurator := class(creative_device):
    # ========================================
    # PORTAL DEVICES (8 sets)
    # ========================================

    # Cut Man Portal
    @editable var PortalEntry_CutMan : teleporter_device = teleporter_device{}
    @editable var PortalExit_CutMan : teleporter_device = teleporter_device{}
    @editable var PortalVFX_CutMan : vfx_spawner_device = vfx_spawner_device{}
    @editable var BossHologram_CutMan : billboard_device = billboard_device{}

    # Ice Man Portal
    @editable var PortalEntry_IceMan : teleporter_device = teleporter_device{}
    @editable var PortalExit_IceMan : teleporter_device = teleporter_device{}
    @editable var PortalVFX_IceMan : vfx_spawner_device = vfx_spawner_device{}
    @editable var BossHologram_IceMan : billboard_device = billboard_device{}

    # Fire Man Portal
    @editable var PortalEntry_FireMan : teleporter_device = teleporter_device{}
    @editable var PortalExit_FireMan : teleporter_device = teleporter_device{}
    @editable var PortalVFX_FireMan : vfx_spawner_device = vfx_spawner_device{}
    @editable var BossHologram_FireMan : billboard_device = billboard_device{}

    # Elec Man Portal
    @editable var PortalEntry_ElecMan : teleporter_device = teleporter_device{}
    @editable var PortalExit_ElecMan : teleporter_device = teleporter_device{}
    @editable var PortalVFX_ElecMan : vfx_spawner_device = vfx_spawner_device{}
    @editable var BossHologram_ElecMan : billboard_device = billboard_device{}

    # Quick Man Portal
    @editable var PortalEntry_QuickMan : teleporter_device = teleporter_device{}
    @editable var PortalExit_QuickMan : teleporter_device = teleporter_device{}
    @editable var PortalVFX_QuickMan : vfx_spawner_device = vfx_spawner_device{}
    @editable var BossHologram_QuickMan : billboard_device = billboard_device{}

    # Flash Man Portal
    @editable var PortalEntry_FlashMan : teleporter_device = teleporter_device{}
    @editable var PortalExit_FlashMan : teleporter_device = teleporter_device{}
    @editable var PortalVFX_FlashMan : vfx_spawner_device = vfx_spawner_device{}
    @editable var BossHologram_FlashMan : billboard_device = billboard_device{}

    # Heat Man Portal
    @editable var PortalEntry_HeatMan : teleporter_device = teleporter_device{}
    @editable var PortalExit_HeatMan : teleporter_device = teleporter_device{}
    @editable var PortalVFX_HeatMan : vfx_spawner_device = vfx_spawner_device{}
    @editable var BossHologram_HeatMan : billboard_device = billboard_device{}

    # Bubble Man Portal
    @editable var PortalEntry_BubbleMan : teleporter_device = teleporter_device{}
    @editable var PortalExit_BubbleMan : teleporter_device = teleporter_device{}
    @editable var PortalVFX_BubbleMan : vfx_spawner_device = vfx_spawner_device{}
    @editable var BossHologram_BubbleMan : billboard_device = billboard_device{}

    # ========================================
    # BOSS SPAWNERS (8)
    # ========================================
    @editable var BossSpawner_CutMan : guard_spawner_device = guard_spawner_device{}
    @editable var BossSpawner_IceMan : guard_spawner_device = guard_spawner_device{}
    @editable var BossSpawner_FireMan : guard_spawner_device = guard_spawner_device{}
    @editable var BossSpawner_ElecMan : guard_spawner_device = guard_spawner_device{}
    @editable var BossSpawner_QuickMan : guard_spawner_device = guard_spawner_device{}
    @editable var BossSpawner_FlashMan : guard_spawner_device = guard_spawner_device{}
    @editable var BossSpawner_HeatMan : guard_spawner_device = guard_spawner_device{}
    @editable var BossSpawner_BubbleMan : guard_spawner_device = guard_spawner_device{}

    # ========================================
    # BOSS HEALTH BARS (8)
    # ========================================
    @editable var HealthBar_CutMan : billboard_device = billboard_device{}
    @editable var HealthBar_IceMan : billboard_device = billboard_device{}
    @editable var HealthBar_FireMan : billboard_device = billboard_device{}
    @editable var HealthBar_ElecMan : billboard_device = billboard_device{}
    @editable var HealthBar_QuickMan : billboard_device = billboard_device{}
    @editable var HealthBar_FlashMan : billboard_device = billboard_device{}
    @editable var HealthBar_HeatMan : billboard_device = billboard_device{}
    @editable var HealthBar_BubbleMan : billboard_device = billboard_device{}

    # ========================================
    # PLAYER DEVICES
    # ========================================
    @editable var PlayerSpawner : player_spawner_device = player_spawner_device{}
    @editable var WeaponDisplayUI : hud_message_device = hud_message_device{}
    @editable var EnergyBarUI : hud_message_device = hud_message_device{}
    @editable var ChargeIndicatorUI : hud_message_device = hud_message_device{}
    @editable var BossNameUI : hud_message_device = hud_message_device{}

    # ========================================
    # INPUT DEVICES
    # ========================================
    @editable var FireTrigger : input_trigger_device = input_trigger_device{}
    @editable var NextWeaponTrigger : input_trigger_device = input_trigger_device{}
    @editable var PrevWeaponTrigger : input_trigger_device = input_trigger_device{}

    # ========================================
    # AUDIO DEVICES
    # ========================================
    @editable var Music_Hub : audio_player_device = audio_player_device{}
    @editable var Music_Boss : audio_player_device = audio_player_device{}
    @editable var Music_Victory : audio_player_device = audio_player_device{}
    @editable var SFX_PortalEnter : audio_player_device = audio_player_device{}
    @editable var SFX_BossSpawn : audio_player_device = audio_player_device{}
    @editable var SFX_BossDeath : audio_player_device = audio_player_device{}
    @editable var SFX_WeaponGet : audio_player_device = audio_player_device{}
    @editable var SFX_PlayerHit : audio_player_device = audio_player_device{}
    @editable var SFX_BossHit : audio_player_device = audio_player_device{}
    @editable var SFX_WeaknessHit : audio_player_device = audio_player_device{}
    @editable var SFX_Fire : audio_player_device = audio_player_device{}
    @editable var SFX_Charge : audio_player_device = audio_player_device{}
    @editable var SFX_WeaponSwitch : audio_player_device = audio_player_device{}

    # ========================================
    # VFX DEVICES
    # ========================================
    @editable var VFX_Projectile : vfx_spawner_device = vfx_spawner_device{}
    @editable var VFX_Impact : vfx_spawner_device = vfx_spawner_device{}
    @editable var VFX_WeaknessImpact : vfx_spawner_device = vfx_spawner_device{}
    @editable var VFX_BossSpawn : vfx_spawner_device = vfx_spawner_device{}
    @editable var VFX_BossDeath : vfx_spawner_device = vfx_spawner_device{}
    @editable var VFX_WeaponGet : vfx_spawner_device = vfx_spawner_device{}
    @editable var VFX_Charge_Level1 : vfx_spawner_device = vfx_spawner_device{}
    @editable var VFX_Charge_Level2 : vfx_spawner_device = vfx_spawner_device{}
    @editable var VFX_Charge_Level3 : vfx_spawner_device = vfx_spawner_device{}

    # ========================================
    # COMPLETION INDICATORS (8)
    # ========================================
    @editable var CompleteIndicator_CutMan : billboard_device = billboard_device{}
    @editable var CompleteIndicator_IceMan : billboard_device = billboard_device{}
    @editable var CompleteIndicator_FireMan : billboard_device = billboard_device{}
    @editable var CompleteIndicator_ElecMan : billboard_device = billboard_device{}
    @editable var CompleteIndicator_QuickMan : billboard_device = billboard_device{}
    @editable var CompleteIndicator_FlashMan : billboard_device = billboard_device{}
    @editable var CompleteIndicator_HeatMan : billboard_device = billboard_device{}
    @editable var CompleteIndicator_BubbleMan : billboard_device = billboard_device{}

    # Portal entry event handlers
    PortalEnteredEvent : event(boss_type, agent) = event(boss_type, agent){}

    # Configuration state
    var IsConfigured : logic = false

    # Initialize and configure all devices
    OnBegin<override>()<suspends> : void =
        Print("=== DEVICE CONFIGURATOR ===")
        Print("Auto-configuring all game devices...")

        ConfigurePortals()
        ConfigureBossRooms()
        ConfigurePlayerDevices()
        ConfigureAudio()
        ConfigureVFX()

        set IsConfigured = true
        Print("Device configuration complete!")

    # Configure all portal devices
    ConfigurePortals() : void =
        Print("Configuring portals...")

        # Link portal teleporters
        ConfigurePortalPair(boss_type.CutMan, PortalEntry_CutMan, PortalExit_CutMan, PortalVFX_CutMan)
        ConfigurePortalPair(boss_type.IceMan, PortalEntry_IceMan, PortalExit_IceMan, PortalVFX_IceMan)
        ConfigurePortalPair(boss_type.FireMan, PortalEntry_FireMan, PortalExit_FireMan, PortalVFX_FireMan)
        ConfigurePortalPair(boss_type.ElecMan, PortalEntry_ElecMan, PortalExit_ElecMan, PortalVFX_ElecMan)
        ConfigurePortalPair(boss_type.QuickMan, PortalEntry_QuickMan, PortalExit_QuickMan, PortalVFX_QuickMan)
        ConfigurePortalPair(boss_type.FlashMan, PortalEntry_FlashMan, PortalExit_FlashMan, PortalVFX_FlashMan)
        ConfigurePortalPair(boss_type.HeatMan, PortalEntry_HeatMan, PortalExit_HeatMan, PortalVFX_HeatMan)
        ConfigurePortalPair(boss_type.BubbleMan, PortalEntry_BubbleMan, PortalExit_BubbleMan, PortalVFX_BubbleMan)

        Print("  8 portal pairs configured")

    # Configure a single portal pair
    ConfigurePortalPair(
        BossType : boss_type,
        Entry : teleporter_device,
        Exit : teleporter_device,
        VFX : vfx_spawner_device
    ) : void =
        # Subscribe to teleport events
        Entry.TeleportedEvent.Subscribe(MakePortalHandler(BossType))

        # Enable portal VFX
        VFX.Enable()

        Config := GetBossConfig(BossType)
        Print("    {Config.DisplayName} portal ready")

    # Create a handler for portal entry
    MakePortalHandler(BossType : boss_type) : tuple(agent) -> void =
        return (Player : agent) => OnPortalEntered(BossType, Player)

    # Handle portal entry
    OnPortalEntered(BossType : boss_type, Player : agent) : void =
        Config := GetBossConfig(BossType)
        Print("Player entered {Config.DisplayName}'s portal!")
        SFX_PortalEnter.Play()
        PortalEnteredEvent.Signal(BossType, Player)

    # Configure boss room devices
    ConfigureBossRooms() : void =
        Print("Configuring boss rooms...")

        # Initially disable all spawners
        BossSpawner_CutMan.Disable()
        BossSpawner_IceMan.Disable()
        BossSpawner_FireMan.Disable()
        BossSpawner_ElecMan.Disable()
        BossSpawner_QuickMan.Disable()
        BossSpawner_FlashMan.Disable()
        BossSpawner_HeatMan.Disable()
        BossSpawner_BubbleMan.Disable()

        # Hide all health bars initially
        HealthBar_CutMan.Hide()
        HealthBar_IceMan.Hide()
        HealthBar_FireMan.Hide()
        HealthBar_ElecMan.Hide()
        HealthBar_QuickMan.Hide()
        HealthBar_FlashMan.Hide()
        HealthBar_HeatMan.Hide()
        HealthBar_BubbleMan.Hide()

        # Hide completion indicators
        CompleteIndicator_CutMan.Hide()
        CompleteIndicator_IceMan.Hide()
        CompleteIndicator_FireMan.Hide()
        CompleteIndicator_ElecMan.Hide()
        CompleteIndicator_QuickMan.Hide()
        CompleteIndicator_FlashMan.Hide()
        CompleteIndicator_HeatMan.Hide()
        CompleteIndicator_BubbleMan.Hide()

        Print("  8 boss rooms configured")

    # Configure player devices
    ConfigurePlayerDevices() : void =
        Print("Configuring player devices...")

        # Subscribe to input triggers
        FireTrigger.PressedEvent.Subscribe(OnFirePressed)
        FireTrigger.ReleasedEvent.Subscribe(OnFireReleased)
        NextWeaponTrigger.PressedEvent.Subscribe(OnNextWeaponPressed)
        PrevWeaponTrigger.PressedEvent.Subscribe(OnPrevWeaponPressed)

        Print("  Input triggers configured")

    # Configure audio devices
    ConfigureAudio() : void =
        Print("Configuring audio...")
        # Audio devices are pre-configured in editor
        # Just ensure they're in correct initial state
        Music_Boss.Stop()
        Music_Victory.Stop()
        Print("  Audio configured")

    # Configure VFX devices
    ConfigureVFX() : void =
        Print("Configuring VFX...")
        # Disable charge VFX initially
        VFX_Charge_Level1.Disable()
        VFX_Charge_Level2.Disable()
        VFX_Charge_Level3.Disable()
        Print("  VFX configured")

    # Input handlers
    var CurrentlyCharging : [agent]logic = map{}

    OnFirePressed(Player : agent) : void =
        if (set CurrentlyCharging[Player] = true) {}
        SFX_Charge.Play()
        Print("Fire pressed - charging...")

    OnFireReleased(Player : agent) : void =
        if (set CurrentlyCharging[Player] = false) {}
        SFX_Fire.Play()
        Print("Fire released!")

    OnNextWeaponPressed(Player : agent) : void =
        SFX_WeaponSwitch.Play()
        Print("Next weapon (R)")

    OnPrevWeaponPressed(Player : agent) : void =
        SFX_WeaponSwitch.Play()
        Print("Previous weapon (L)")

    # ========================================
    # PUBLIC API FOR OTHER SYSTEMS
    # ========================================

    # Spawn a specific boss
    SpawnBoss(BossType : boss_type) : void =
        case(BossType):
            boss_type.CutMan =>
                BossSpawner_CutMan.Enable()
                HealthBar_CutMan.Show()
            boss_type.IceMan =>
                BossSpawner_IceMan.Enable()
                HealthBar_IceMan.Show()
            boss_type.FireMan =>
                BossSpawner_FireMan.Enable()
                HealthBar_FireMan.Show()
            boss_type.ElecMan =>
                BossSpawner_ElecMan.Enable()
                HealthBar_ElecMan.Show()
            boss_type.QuickMan =>
                BossSpawner_QuickMan.Enable()
                HealthBar_QuickMan.Show()
            boss_type.FlashMan =>
                BossSpawner_FlashMan.Enable()
                HealthBar_FlashMan.Show()
            boss_type.HeatMan =>
                BossSpawner_HeatMan.Enable()
                HealthBar_HeatMan.Show()
            boss_type.BubbleMan =>
                BossSpawner_BubbleMan.Enable()
                HealthBar_BubbleMan.Show()
            _ => {}

        SFX_BossSpawn.Play()
        VFX_BossSpawn.Activate()
        Music_Hub.Stop()
        Music_Boss.Play()

        Config := GetBossConfig(BossType)
        Print("Boss spawned: {Config.DisplayName}")

    # Despawn a boss
    DespawnBoss(BossType : boss_type) : void =
        case(BossType):
            boss_type.CutMan =>
                BossSpawner_CutMan.Disable()
                HealthBar_CutMan.Hide()
            boss_type.IceMan =>
                BossSpawner_IceMan.Disable()
                HealthBar_IceMan.Hide()
            boss_type.FireMan =>
                BossSpawner_FireMan.Disable()
                HealthBar_FireMan.Hide()
            boss_type.ElecMan =>
                BossSpawner_ElecMan.Disable()
                HealthBar_ElecMan.Hide()
            boss_type.QuickMan =>
                BossSpawner_QuickMan.Disable()
                HealthBar_QuickMan.Hide()
            boss_type.FlashMan =>
                BossSpawner_FlashMan.Disable()
                HealthBar_FlashMan.Hide()
            boss_type.HeatMan =>
                BossSpawner_HeatMan.Disable()
                HealthBar_HeatMan.Hide()
            boss_type.BubbleMan =>
                BossSpawner_BubbleMan.Disable()
                HealthBar_BubbleMan.Hide()
            _ => {}

    # Mark boss as defeated
    MarkBossDefeated(BossType : boss_type) : void =
        DespawnBoss(BossType)

        case(BossType):
            boss_type.CutMan => CompleteIndicator_CutMan.Show()
            boss_type.IceMan => CompleteIndicator_IceMan.Show()
            boss_type.FireMan => CompleteIndicator_FireMan.Show()
            boss_type.ElecMan => CompleteIndicator_ElecMan.Show()
            boss_type.QuickMan => CompleteIndicator_QuickMan.Show()
            boss_type.FlashMan => CompleteIndicator_FlashMan.Show()
            boss_type.HeatMan => CompleteIndicator_HeatMan.Show()
            boss_type.BubbleMan => CompleteIndicator_BubbleMan.Show()
            _ => {}

        SFX_BossDeath.Play()
        VFX_BossDeath.Activate()
        Music_Boss.Stop()

    # Play weapon acquired effects
    PlayWeaponGetEffects() : void =
        SFX_WeaponGet.Play()
        VFX_WeaponGet.Activate()

    # Start hub music
    StartHubMusic() : void =
        Music_Boss.Stop()
        Music_Victory.Stop()
        Music_Hub.Play()

    # Play victory sequence
    PlayVictory() : void =
        Music_Hub.Stop()
        Music_Boss.Stop()
        Music_Victory.Play()

    # Update charge VFX
    UpdateChargeVFX(Level : int) : void =
        VFX_Charge_Level1.Disable()
        VFX_Charge_Level2.Disable()
        VFX_Charge_Level3.Disable()

        case(Level):
            1 => VFX_Charge_Level1.Enable()
            2 => VFX_Charge_Level2.Enable()
            3 => VFX_Charge_Level3.Enable()
            _ => {}

    # Show HUD message
    ShowBossName(BossType : boss_type) : void =
        Config := GetBossConfig(BossType)
        BossNameUI.Show()
        Print("BOSS: {Config.DisplayName}")

    # Play hit effects
    PlayHitEffect(IsWeakness : logic) : void =
        if (IsWeakness):
            SFX_WeaknessHit.Play()
            VFX_WeaknessImpact.Activate()
        else:
            SFX_BossHit.Play()
            VFX_Impact.Activate()
