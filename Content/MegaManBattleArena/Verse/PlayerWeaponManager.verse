# PlayerWeaponManager.verse
# Manages player weapons, acquisition, switching, and color changes

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# Import weapon types
using { WeaponTypes }

# Mega Buster charge level
charge_level := enum:
    None        # No charge, basic shot
    Level1      # Small charge
    Level2      # Medium charge
    Level3      # Full charge

# Player weapon state
player_weapon_state := struct<transacts>:
    # Currently equipped weapon
    var CurrentWeapon : weapon_type = weapon_type.MegaBuster
    # All acquired weapons (starts with just Mega Buster)
    var AcquiredWeapons : []weapon_type = array{weapon_type.MegaBuster}
    # Weapon energy levels (0-100 for each weapon type)
    var WeaponEnergy : [weapon_type]float = map{}
    # Current Mega Buster charge level
    var BusterChargeLevel : charge_level = charge_level.None
    # Charge time accumulator
    var ChargeTime : float = 0.0
    # Cooldown timer
    var CooldownRemaining : float = 0.0

# Player weapon manager device
player_weapon_manager := class(creative_device):
    # UI elements
    @editable
    WeaponDisplayUI : billboard_device = billboard_device{}

    @editable
    EnergyBarUI : billboard_device = billboard_device{}

    # Button devices for weapon switching (L/R style)
    @editable
    PrevWeaponButton : button_device = button_device{}

    @editable
    NextWeaponButton : button_device = button_device{}

    # Fire button
    @editable
    FireButton : button_device = button_device{}

    # Charge indicator VFX
    @editable
    ChargeVFX_Level1 : vfx_spawner_device = vfx_spawner_device{}

    @editable
    ChargeVFX_Level2 : vfx_spawner_device = vfx_spawner_device{}

    @editable
    ChargeVFX_Level3 : vfx_spawner_device = vfx_spawner_device{}

    # Sound effects
    @editable
    WeaponSwitchSFX : audio_player_device = audio_player_device{}

    @editable
    WeaponAcquireSFX : audio_player_device = audio_player_device{}

    @editable
    ChargingSFX : audio_player_device = audio_player_device{}

    # Color change prop (for player skin color)
    @editable
    ColorChangeProp : color_changing_tiles_device = color_changing_tiles_device{}

    # Player states map
    var PlayerStates : [agent]player_weapon_state = map{}

    # Maximum energy per weapon
    MaxEnergy : float = 100.0

    # Charge time thresholds
    ChargeTime_Level1 : float = 0.5
    ChargeTime_Level2 : float = 1.0
    ChargeTime_Level3 : float = 2.0

    # Initialize
    OnBegin<override>()<suspends> : void =
        # Subscribe to button events
        PrevWeaponButton.InteractedWithEvent.Subscribe(OnPrevWeapon)
        NextWeaponButton.InteractedWithEvent.Subscribe(OnNextWeapon)
        FireButton.InteractedWithEvent.Subscribe(OnFire)

        # Start update loop for charging and cooldowns
        loop:
            UpdateAllPlayers(0.016)
            Sleep(0.016)

    # Initialize a player's weapon state
    InitializePlayer(Player : agent) : void =
        InitialEnergy : [weapon_type]float = map{}
        # Set initial energy for Mega Buster (infinite)
        if (set InitialEnergy[weapon_type.MegaBuster] = MaxEnergy) {}

        NewState := player_weapon_state{
            CurrentWeapon := weapon_type.MegaBuster,
            AcquiredWeapons := array{weapon_type.MegaBuster},
            WeaponEnergy := InitialEnergy,
            BusterChargeLevel := charge_level.None,
            ChargeTime := 0.0,
            CooldownRemaining := 0.0
        }
        if (set PlayerStates[Player] = NewState) {}
        UpdatePlayerColor(Player, weapon_type.MegaBuster)

    # Grant a weapon to a player (called when defeating a boss)
    GrantWeapon(Player : agent, NewWeapon : weapon_type) : void =
        if (State := PlayerStates[Player]):
            # Check if already has weapon
            HasWeapon := false
            for (Weapon : State.AcquiredWeapons):
                if (Weapon = NewWeapon):
                    set HasWeapon = true

            if (HasWeapon = false):
                # Add weapon to acquired list
                var MutableState := State
                set MutableState.AcquiredWeapons = State.AcquiredWeapons + array{NewWeapon}
                # Initialize energy for new weapon
                if (set MutableState.WeaponEnergy[NewWeapon] = MaxEnergy) {}
                if (set PlayerStates[Player] = MutableState) {}

                # Play acquisition sound and effect
                WeaponAcquireSFX.Play()

                # Show weapon acquired message
                Config := GetWeaponConfig(NewWeapon)
                Print("Player acquired: {Config.DisplayName}!")

    # Switch to previous weapon in list
    OnPrevWeapon(Player : agent) : void =
        CycleWeapon(Player, -1)

    # Switch to next weapon in list
    OnNextWeapon(Player : agent) : void =
        CycleWeapon(Player, 1)

    # Cycle through weapons
    CycleWeapon(Player : agent, Direction : int) : void =
        if (State := PlayerStates[Player]):
            WeaponCount := State.AcquiredWeapons.Length
            if (WeaponCount <= 1):
                return  # Nothing to switch to

            # Find current weapon index
            CurrentIndex := 0
            for (I := 0..WeaponCount - 1):
                if (Weapon := State.AcquiredWeapons[I]):
                    if (Weapon = State.CurrentWeapon):
                        set CurrentIndex = I

            # Calculate new index
            NewIndex := (CurrentIndex + Direction + WeaponCount) mod WeaponCount

            # Update weapon
            if (NewWeapon := State.AcquiredWeapons[NewIndex]):
                var MutableState := State
                set MutableState.CurrentWeapon = NewWeapon
                set MutableState.ChargeTime = 0.0
                set MutableState.BusterChargeLevel = charge_level.None
                if (set PlayerStates[Player] = MutableState) {}

                # Play switch sound
                WeaponSwitchSFX.Play()

                # Update player color
                UpdatePlayerColor(Player, NewWeapon)

                # Update UI
                UpdateWeaponUI(Player)

    # Update player color based on equipped weapon
    UpdatePlayerColor(Player : agent, Weapon : weapon_type) : void =
        Config := GetWeaponConfig(Weapon)
        # In a full implementation, this would change the player's outfit color
        # For now, we'll use the color changing tiles as a visual indicator
        # The RGB values from Config.SkinColorR/G/B would be used here
        Print("Player color changed to: R={Config.SkinColorR} G={Config.SkinColorG} B={Config.SkinColorB}")

    # Fire current weapon
    OnFire(Player : agent) : void =
        if (State := PlayerStates[Player]):
            # Check cooldown
            if (State.CooldownRemaining > 0.0):
                return

            Config := GetWeaponConfig(State.CurrentWeapon)

            # Check energy (Mega Buster has unlimited energy)
            if (State.CurrentWeapon <> weapon_type.MegaBuster):
                if (CurrentEnergy := State.WeaponEnergy[State.CurrentWeapon]):
                    if (CurrentEnergy < Config.EnergyCost):
                        Print("Not enough energy!")
                        return

            # Fire the weapon!
            FireWeapon(Player, State)

    # Fire weapon implementation
    FireWeapon(Player : agent, State : player_weapon_state) : void =
        Config := GetWeaponConfig(State.CurrentWeapon)

        # Calculate damage based on charge level for Mega Buster
        FinalDamage := if (State.CurrentWeapon = weapon_type.MegaBuster):
            case(State.BusterChargeLevel):
                charge_level.None => Config.Damage
                charge_level.Level1 => Config.Damage * 1.5
                charge_level.Level2 => Config.Damage * 2.5
                charge_level.Level3 => Config.Damage * 4.0
                _ => Config.Damage
        else:
            Config.Damage

        # Consume energy if not Mega Buster
        var MutableState := State
        if (State.CurrentWeapon <> weapon_type.MegaBuster):
            if (CurrentEnergy := State.WeaponEnergy[State.CurrentWeapon]):
                NewEnergy := CurrentEnergy - Config.EnergyCost
                if (set MutableState.WeaponEnergy[State.CurrentWeapon] = NewEnergy) {}

        # Set cooldown
        set MutableState.CooldownRemaining = Config.CooldownTime
        # Reset charge
        set MutableState.ChargeTime = 0.0
        set MutableState.BusterChargeLevel = charge_level.None

        if (set PlayerStates[Player] = MutableState) {}

        # The actual projectile spawning would be handled by the projectile manager
        # Signal that we want to fire
        Print("FIRE! Weapon: {Config.DisplayName}, Damage: {FinalDamage}")

    # Update all players (charging, cooldowns)
    UpdateAllPlayers(DeltaTime : float) : void =
        for (Player -> State : PlayerStates):
            var MutableState := State

            # Update cooldown
            if (State.CooldownRemaining > 0.0):
                set MutableState.CooldownRemaining = State.CooldownRemaining - DeltaTime
                if (MutableState.CooldownRemaining < 0.0):
                    set MutableState.CooldownRemaining = 0.0

            # Update charging for Mega Buster
            # In a real implementation, this would check if fire button is held
            # For now, we'll just track charge time

            if (set PlayerStates[Player] = MutableState) {}

    # Start charging (called when fire button is held down)
    StartCharging(Player : agent) : void =
        if (State := PlayerStates[Player]):
            if (State.CurrentWeapon = weapon_type.MegaBuster):
                ChargingSFX.Play()

    # Update charging (called while fire button is held)
    UpdateCharging(Player : agent, DeltaTime : float) : void =
        if (State := PlayerStates[Player]):
            if (State.CurrentWeapon = weapon_type.MegaBuster):
                var MutableState := State
                set MutableState.ChargeTime = State.ChargeTime + DeltaTime

                # Determine charge level
                NewChargeLevel := if (MutableState.ChargeTime >= ChargeTime_Level3):
                    charge_level.Level3
                else if (MutableState.ChargeTime >= ChargeTime_Level2):
                    charge_level.Level2
                else if (MutableState.ChargeTime >= ChargeTime_Level1):
                    charge_level.Level1
                else:
                    charge_level.None

                # Update VFX if charge level changed
                if (NewChargeLevel <> State.BusterChargeLevel):
                    set MutableState.BusterChargeLevel = NewChargeLevel
                    UpdateChargeVFX(NewChargeLevel)

                if (set PlayerStates[Player] = MutableState) {}

    # Update charge visual effects
    UpdateChargeVFX(Level : charge_level) : void =
        # Deactivate all first
        ChargeVFX_Level1.Disable()
        ChargeVFX_Level2.Disable()
        ChargeVFX_Level3.Disable()

        # Activate appropriate level
        case(Level):
            charge_level.Level1 => ChargeVFX_Level1.Enable()
            charge_level.Level2 => ChargeVFX_Level2.Enable()
            charge_level.Level3 => ChargeVFX_Level3.Enable()
            _ => {}

    # Update weapon UI display
    UpdateWeaponUI(Player : agent) : void =
        if (State := PlayerStates[Player]):
            Config := GetWeaponConfig(State.CurrentWeapon)
            # Update billboard to show current weapon
            # In a full implementation, this would show weapon icon and energy bar
            Print("Current Weapon: {Config.DisplayName}")

    # Get player's current weapon
    GetCurrentWeapon(Player : agent) : weapon_type =
        if (State := PlayerStates[Player]):
            State.CurrentWeapon
        else:
            weapon_type.MegaBuster

    # Get player's weapon state
    GetPlayerState(Player : agent) : ?player_weapon_state =
        PlayerStates[Player]

    # Check if player has a specific weapon
    HasWeapon(Player : agent, Weapon : weapon_type) : logic =
        if (State := PlayerStates[Player]):
            for (W : State.AcquiredWeapons):
                if (W = Weapon):
                    return true
        false

    # Refill energy for a weapon
    RefillEnergy(Player : agent, Weapon : weapon_type, Amount : float) : void =
        if (State := PlayerStates[Player]):
            var MutableState := State
            if (CurrentEnergy := State.WeaponEnergy[Weapon]):
                NewEnergy := Min(CurrentEnergy + Amount, MaxEnergy)
                if (set MutableState.WeaponEnergy[Weapon] = NewEnergy) {}
                if (set PlayerStates[Player] = MutableState) {}

    # Helper function
    Min(A : float, B : float) : float =
        if (A < B) then A else B
