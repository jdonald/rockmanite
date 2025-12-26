# PortalSystem.verse
# Portal system for the 8 boss room teleporters
# Layout: 4 portals on left side, 4 on right side of main room

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Import types
using { WeaponTypes }

# Portal status
portal_status := enum:
    Available       # Boss not yet defeated, can enter
    Active          # Player currently fighting this boss
    Completed       # Boss defeated, portal shows checkmark
    Locked          # Temporarily locked

# Portal data
portal_data := struct<transacts>:
    var BossType : boss_type
    var Status : portal_status
    var Position : vector3
    var EntryCount : int  # How many times boss has been battled

# Individual portal device
boss_portal_device := class(creative_device):
    # Teleporter for entering the portal
    @editable
    PortalTeleporter : teleporter_device = teleporter_device{}

    # Exit teleporter (in boss room, returns to main room)
    @editable
    ExitTeleporter : teleporter_device = teleporter_device{}

    # Visual representation of the boss
    @editable
    BossHologram : prop_mover_device = prop_mover_device{}

    # Portal frame VFX
    @editable
    PortalVFX : vfx_spawner_device = vfx_spawner_device{}

    # Completed indicator (shows when boss defeated)
    @editable
    CompletedIndicator : billboard_device = billboard_device{}

    # Sound effects
    @editable
    PortalEnterSFX : audio_player_device = audio_player_device{}

    @editable
    PortalExitSFX : audio_player_device = audio_player_device{}

    # Boss type for this portal (0-7)
    @editable
    BossTypeIndex : int = 0

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

    # Portal data
    var Data : portal_data = portal_data{}

    # Event when player enters portal
    PortalEnteredEvent : event(boss_type, agent) = event(boss_type, agent){}

    # Event when player exits portal
    PortalExitedEvent : event(boss_type, agent) = event(boss_type, agent){}

    # Initialize
    OnBegin<override>()<suspends> : void =
        # Initialize portal data
        if (BossType := AllBossTypes[BossTypeIndex]):
            set Data = portal_data{
                BossType := BossType,
                Status := portal_status.Available,
                Position := vector3{X := 0.0, Y := 0.0, Z := 0.0},
                EntryCount := 0
            }

            # Subscribe to teleporter events
            PortalTeleporter.TeleportedEvent.Subscribe(OnPlayerEnterPortal)
            ExitTeleporter.TeleportedEvent.Subscribe(OnPlayerExitPortal)

            # Initialize visuals
            UpdatePortalVisuals()

            Print("Portal initialized for boss: {GetBossConfig(BossType).DisplayName}")

    # Player enters the portal
    OnPlayerEnterPortal(Player : agent) : void =
        if (Data.Status = portal_status.Locked):
            Print("Portal is locked!")
            return

        # Increment entry count
        var MutableData := Data
        set MutableData.EntryCount = Data.EntryCount + 1
        set MutableData.Status = portal_status.Active
        set Data = MutableData

        # Play effects
        PortalEnterSFX.Play()

        # Signal portal entered
        PortalEnteredEvent.Signal(Data.BossType, Player)

        Print("Player entered portal to fight {GetBossConfig(Data.BossType).DisplayName}!")

    # Player exits the portal (teleports back to main room)
    OnPlayerExitPortal(Player : agent) : void =
        # Play effects
        PortalExitSFX.Play()

        # If boss still active, set back to available
        if (Data.Status = portal_status.Active):
            var MutableData := Data
            set MutableData.Status = portal_status.Available
            set Data = MutableData

        # Signal portal exited
        PortalExitedEvent.Signal(Data.BossType, Player)

        Print("Player exited portal")

    # Mark boss as defeated
    MarkCompleted() : void =
        var MutableData := Data
        set MutableData.Status = portal_status.Completed
        set Data = MutableData

        UpdatePortalVisuals()
        Print("{GetBossConfig(Data.BossType).DisplayName} portal marked as completed!")

    # Reset portal (for replay)
    ResetPortal() : void =
        var MutableData := Data
        set MutableData.Status = portal_status.Available
        set Data = MutableData

        UpdatePortalVisuals()

    # Lock portal temporarily
    LockPortal() : void =
        var MutableData := Data
        set MutableData.Status = portal_status.Locked
        set Data = MutableData

        UpdatePortalVisuals()

    # Unlock portal
    UnlockPortal() : void =
        if (Data.Status = portal_status.Locked):
            var MutableData := Data
            set MutableData.Status = portal_status.Available
            set Data = MutableData

            UpdatePortalVisuals()

    # Update portal visual state
    UpdatePortalVisuals() : void =
        case(Data.Status):
            portal_status.Available =>
                PortalVFX.Enable()
                BossHologram.Enable()
                CompletedIndicator.Hide()
            portal_status.Active =>
                PortalVFX.Enable()
                BossHologram.Enable()
                CompletedIndicator.Hide()
            portal_status.Completed =>
                # Still show portal but with completed indicator
                PortalVFX.Enable()
                BossHologram.Enable()
                CompletedIndicator.Show()
            portal_status.Locked =>
                PortalVFX.Disable()
                BossHologram.Disable()
                CompletedIndicator.Hide()
            _ =>
                {}

    # Get portal status
    GetStatus() : portal_status =
        Data.Status

    # Get boss type
    GetBossType() : boss_type =
        Data.BossType

    # Get entry count
    GetEntryCount() : int =
        Data.EntryCount


# Portal hub manager - manages all 8 portals
portal_hub_manager := class(creative_device):
    # All 8 boss portals (4 on left, 4 on right)
    # Left side (bottom to top): Cut Man, Ice Man, Fire Man, Elec Man
    # Right side (bottom to top): Quick Man, Flash Man, Heat Man, Bubble Man
    @editable
    PortalCutMan : boss_portal_device = boss_portal_device{}

    @editable
    PortalIceMan : boss_portal_device = boss_portal_device{}

    @editable
    PortalFireMan : boss_portal_device = boss_portal_device{}

    @editable
    PortalElecMan : boss_portal_device = boss_portal_device{}

    @editable
    PortalQuickMan : boss_portal_device = boss_portal_device{}

    @editable
    PortalFlashMan : boss_portal_device = boss_portal_device{}

    @editable
    PortalHeatMan : boss_portal_device = boss_portal_device{}

    @editable
    PortalBubbleMan : boss_portal_device = boss_portal_device{}

    # Platform devices for reaching portals
    @editable
    LeftPlatforms : []prop_mover_device = array{}

    @editable
    RightPlatforms : []prop_mover_device = array{}

    # Background music
    @editable
    HubMusic : audio_player_device = audio_player_device{}

    # Victory music (when all bosses defeated)
    @editable
    VictoryMusic : audio_player_device = audio_player_device{}

    # Tracking defeated bosses
    var DefeatedBosses : []boss_type = array{}

    # Events
    AllBossesDefeatedEvent : event() = event(){}

    # Initialize
    OnBegin<override>()<suspends> : void =
        # Subscribe to portal events
        PortalCutMan.PortalEnteredEvent.Subscribe(OnPortalEntered)
        PortalIceMan.PortalEnteredEvent.Subscribe(OnPortalEntered)
        PortalFireMan.PortalEnteredEvent.Subscribe(OnPortalEntered)
        PortalElecMan.PortalEnteredEvent.Subscribe(OnPortalEntered)
        PortalQuickMan.PortalEnteredEvent.Subscribe(OnPortalEntered)
        PortalFlashMan.PortalEnteredEvent.Subscribe(OnPortalEntered)
        PortalHeatMan.PortalEnteredEvent.Subscribe(OnPortalEntered)
        PortalBubbleMan.PortalEnteredEvent.Subscribe(OnPortalEntered)

        # Start hub music
        HubMusic.Play()

        Print("Portal Hub initialized with 8 boss portals!")

    # Handle portal entry
    OnPortalEntered(BossType : boss_type, Player : agent) : void =
        Config := GetBossConfig(BossType)
        Print("Player entering {Config.DisplayName}'s room!")
        # The game manager will handle spawning the boss

    # Mark a boss as defeated
    MarkBossDefeated(BossType : boss_type) : void =
        # Add to defeated list if not already there
        AlreadyDefeated := false
        for (Boss : DefeatedBosses):
            if (Boss = BossType):
                set AlreadyDefeated = true

        if (AlreadyDefeated = false):
            set DefeatedBosses = DefeatedBosses + array{BossType}

        # Mark appropriate portal as completed
        case(BossType):
            boss_type.CutMan => PortalCutMan.MarkCompleted()
            boss_type.IceMan => PortalIceMan.MarkCompleted()
            boss_type.FireMan => PortalFireMan.MarkCompleted()
            boss_type.ElecMan => PortalElecMan.MarkCompleted()
            boss_type.QuickMan => PortalQuickMan.MarkCompleted()
            boss_type.FlashMan => PortalFlashMan.MarkCompleted()
            boss_type.HeatMan => PortalHeatMan.MarkCompleted()
            boss_type.BubbleMan => PortalBubbleMan.MarkCompleted()
            _ => {}

        # Check if all bosses defeated
        if (DefeatedBosses.Length >= 8):
            OnAllBossesDefeated()

    # All bosses have been defeated
    OnAllBossesDefeated() : void =
        HubMusic.Stop()
        VictoryMusic.Play()
        AllBossesDefeatedEvent.Signal()
        Print("ALL BOSSES DEFEATED! Victory!")

    # Reset all portals (for new game)
    ResetAllPortals() : void =
        set DefeatedBosses = array{}

        PortalCutMan.ResetPortal()
        PortalIceMan.ResetPortal()
        PortalFireMan.ResetPortal()
        PortalElecMan.ResetPortal()
        PortalQuickMan.ResetPortal()
        PortalFlashMan.ResetPortal()
        PortalHeatMan.ResetPortal()
        PortalBubbleMan.ResetPortal()

        HubMusic.Play()

    # Get number of defeated bosses
    GetDefeatedCount() : int =
        DefeatedBosses.Length

    # Check if specific boss is defeated
    IsBossDefeated(BossType : boss_type) : logic =
        for (Boss : DefeatedBosses):
            if (Boss = BossType):
                return true
        false

    # Get portal for a boss type
    GetPortalForBoss(BossType : boss_type) : ?boss_portal_device =
        case(BossType):
            boss_type.CutMan => option{PortalCutMan}
            boss_type.IceMan => option{PortalIceMan}
            boss_type.FireMan => option{PortalFireMan}
            boss_type.ElecMan => option{PortalElecMan}
            boss_type.QuickMan => option{PortalQuickMan}
            boss_type.FlashMan => option{PortalFlashMan}
            boss_type.HeatMan => option{PortalHeatMan}
            boss_type.BubbleMan => option{PortalBubbleMan}
            _ => false
