# AudioManager.verse
# Centralized audio management for music and sound effects
# Handles all game audio with proper prioritization and mixing

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

# Import types
using { WeaponTypes }

# Music track enumeration
music_track := enum:
    None
    Title
    StageSelect
    Hub
    BossBattle
    BossIntro
    Victory
    GameOver
    WeaponGet

# Sound effect category
sfx_category := enum:
    UI
    Player
    Weapon
    Boss
    Environment

# Sound effect type
sfx_type := enum:
    # UI Sounds
    MenuSelect
    MenuConfirm
    MenuCancel
    Pause

    # Player Sounds
    PlayerHit
    PlayerDeath
    PlayerLand
    PlayerJump

    # Weapon Sounds
    MegaBusterShot
    MegaBusterCharge
    MegaBusterChargeShot
    RollingCutterShot
    IceSlasherShot
    FireStormShot
    ThunderBeamShot
    QuickBoomerangShot
    AtomicFireShot
    CrashBomberShot
    TimeStopperShot
    WeaponSwitch
    WeaponEmpty

    # Boss Sounds
    BossSpawn
    BossHit
    BossWeaknessHit
    BossDeath
    BossAttack
    BossJump
    BossLand

    # Environment Sounds
    PortalEnter
    PortalExit
    DoorOpen
    DoorClose
    Explosion
    Teleport

# Audio manager device
audio_manager := class(creative_device):
    # ========================================
    # MUSIC PLAYERS
    # ========================================
    @editable var MusicPlayer_Title : audio_player_device = audio_player_device{}
    @editable var MusicPlayer_StageSelect : audio_player_device = audio_player_device{}
    @editable var MusicPlayer_Hub : audio_player_device = audio_player_device{}
    @editable var MusicPlayer_Boss : audio_player_device = audio_player_device{}
    @editable var MusicPlayer_BossIntro : audio_player_device = audio_player_device{}
    @editable var MusicPlayer_Victory : audio_player_device = audio_player_device{}
    @editable var MusicPlayer_GameOver : audio_player_device = audio_player_device{}
    @editable var MusicPlayer_WeaponGet : audio_player_device = audio_player_device{}

    # ========================================
    # SFX PLAYERS - UI
    # ========================================
    @editable var SFX_MenuSelect : audio_player_device = audio_player_device{}
    @editable var SFX_MenuConfirm : audio_player_device = audio_player_device{}
    @editable var SFX_MenuCancel : audio_player_device = audio_player_device{}
    @editable var SFX_Pause : audio_player_device = audio_player_device{}

    # ========================================
    # SFX PLAYERS - Player
    # ========================================
    @editable var SFX_PlayerHit : audio_player_device = audio_player_device{}
    @editable var SFX_PlayerDeath : audio_player_device = audio_player_device{}
    @editable var SFX_PlayerLand : audio_player_device = audio_player_device{}
    @editable var SFX_PlayerJump : audio_player_device = audio_player_device{}

    # ========================================
    # SFX PLAYERS - Weapons
    # ========================================
    @editable var SFX_MegaBusterShot : audio_player_device = audio_player_device{}
    @editable var SFX_MegaBusterCharge : audio_player_device = audio_player_device{}
    @editable var SFX_MegaBusterChargeShot : audio_player_device = audio_player_device{}
    @editable var SFX_RollingCutterShot : audio_player_device = audio_player_device{}
    @editable var SFX_IceSlasherShot : audio_player_device = audio_player_device{}
    @editable var SFX_FireStormShot : audio_player_device = audio_player_device{}
    @editable var SFX_ThunderBeamShot : audio_player_device = audio_player_device{}
    @editable var SFX_QuickBoomerangShot : audio_player_device = audio_player_device{}
    @editable var SFX_AtomicFireShot : audio_player_device = audio_player_device{}
    @editable var SFX_CrashBomberShot : audio_player_device = audio_player_device{}
    @editable var SFX_TimeStopperShot : audio_player_device = audio_player_device{}
    @editable var SFX_WeaponSwitch : audio_player_device = audio_player_device{}
    @editable var SFX_WeaponEmpty : audio_player_device = audio_player_device{}

    # ========================================
    # SFX PLAYERS - Boss
    # ========================================
    @editable var SFX_BossSpawn : audio_player_device = audio_player_device{}
    @editable var SFX_BossHit : audio_player_device = audio_player_device{}
    @editable var SFX_BossWeaknessHit : audio_player_device = audio_player_device{}
    @editable var SFX_BossDeath : audio_player_device = audio_player_device{}
    @editable var SFX_BossAttack : audio_player_device = audio_player_device{}
    @editable var SFX_BossJump : audio_player_device = audio_player_device{}
    @editable var SFX_BossLand : audio_player_device = audio_player_device{}

    # ========================================
    # SFX PLAYERS - Environment
    # ========================================
    @editable var SFX_PortalEnter : audio_player_device = audio_player_device{}
    @editable var SFX_PortalExit : audio_player_device = audio_player_device{}
    @editable var SFX_DoorOpen : audio_player_device = audio_player_device{}
    @editable var SFX_DoorClose : audio_player_device = audio_player_device{}
    @editable var SFX_Explosion : audio_player_device = audio_player_device{}
    @editable var SFX_Teleport : audio_player_device = audio_player_device{}

    # ========================================
    # STATE
    # ========================================
    var CurrentMusic : music_track = music_track.None
    var IsMusicEnabled : logic = true
    var IsSFXEnabled : logic = true
    var MusicVolume : float = 1.0
    var SFXVolume : float = 1.0

    # Initialize
    OnBegin<override>()<suspends> : void =
        Print("=== AUDIO MANAGER ===")
        Print("Initializing audio system...")

        # Stop all music initially
        StopAllMusic()

        Print("Audio system ready!")

    # ========================================
    # MUSIC CONTROL
    # ========================================

    # Play a music track
    PlayMusic(Track : music_track) : void =
        if (IsMusicEnabled = false):
            return

        # Stop current music first
        StopAllMusic()

        set CurrentMusic = Track

        case(Track):
            music_track.Title =>
                MusicPlayer_Title.Play()
                Print("Playing: Title Theme")
            music_track.StageSelect =>
                MusicPlayer_StageSelect.Play()
                Print("Playing: Stage Select")
            music_track.Hub =>
                MusicPlayer_Hub.Play()
                Print("Playing: Hub Theme")
            music_track.BossBattle =>
                MusicPlayer_Boss.Play()
                Print("Playing: Boss Battle")
            music_track.BossIntro =>
                MusicPlayer_BossIntro.Play()
                Print("Playing: Boss Intro")
            music_track.Victory =>
                MusicPlayer_Victory.Play()
                Print("Playing: Victory!")
            music_track.GameOver =>
                MusicPlayer_GameOver.Play()
                Print("Playing: Game Over")
            music_track.WeaponGet =>
                MusicPlayer_WeaponGet.Play()
                Print("Playing: Weapon Get!")
            _ =>
                set CurrentMusic = music_track.None

    # Stop all music
    StopAllMusic() : void =
        MusicPlayer_Title.Stop()
        MusicPlayer_StageSelect.Stop()
        MusicPlayer_Hub.Stop()
        MusicPlayer_Boss.Stop()
        MusicPlayer_BossIntro.Stop()
        MusicPlayer_Victory.Stop()
        MusicPlayer_GameOver.Stop()
        MusicPlayer_WeaponGet.Stop()
        set CurrentMusic = music_track.None

    # Pause current music
    PauseMusic() : void =
        case(CurrentMusic):
            music_track.Title => MusicPlayer_Title.Pause()
            music_track.StageSelect => MusicPlayer_StageSelect.Pause()
            music_track.Hub => MusicPlayer_Hub.Pause()
            music_track.BossBattle => MusicPlayer_Boss.Pause()
            music_track.BossIntro => MusicPlayer_BossIntro.Pause()
            music_track.Victory => MusicPlayer_Victory.Pause()
            music_track.GameOver => MusicPlayer_GameOver.Pause()
            music_track.WeaponGet => MusicPlayer_WeaponGet.Pause()
            _ => {}

    # Resume music
    ResumeMusic() : void =
        case(CurrentMusic):
            music_track.Title => MusicPlayer_Title.Play()
            music_track.StageSelect => MusicPlayer_StageSelect.Play()
            music_track.Hub => MusicPlayer_Hub.Play()
            music_track.BossBattle => MusicPlayer_Boss.Play()
            music_track.BossIntro => MusicPlayer_BossIntro.Play()
            music_track.Victory => MusicPlayer_Victory.Play()
            music_track.GameOver => MusicPlayer_GameOver.Play()
            music_track.WeaponGet => MusicPlayer_WeaponGet.Play()
            _ => {}

    # Toggle music on/off
    ToggleMusic() : void =
        if (IsMusicEnabled = true):
            set IsMusicEnabled = false
            StopAllMusic()
        else:
            set IsMusicEnabled = true

    # ========================================
    # SOUND EFFECTS CONTROL
    # ========================================

    # Play a sound effect
    PlaySFX(Effect : sfx_type) : void =
        if (IsSFXEnabled = false):
            return

        case(Effect):
            # UI
            sfx_type.MenuSelect => SFX_MenuSelect.Play()
            sfx_type.MenuConfirm => SFX_MenuConfirm.Play()
            sfx_type.MenuCancel => SFX_MenuCancel.Play()
            sfx_type.Pause => SFX_Pause.Play()

            # Player
            sfx_type.PlayerHit => SFX_PlayerHit.Play()
            sfx_type.PlayerDeath => SFX_PlayerDeath.Play()
            sfx_type.PlayerLand => SFX_PlayerLand.Play()
            sfx_type.PlayerJump => SFX_PlayerJump.Play()

            # Weapons
            sfx_type.MegaBusterShot => SFX_MegaBusterShot.Play()
            sfx_type.MegaBusterCharge => SFX_MegaBusterCharge.Play()
            sfx_type.MegaBusterChargeShot => SFX_MegaBusterChargeShot.Play()
            sfx_type.RollingCutterShot => SFX_RollingCutterShot.Play()
            sfx_type.IceSlasherShot => SFX_IceSlasherShot.Play()
            sfx_type.FireStormShot => SFX_FireStormShot.Play()
            sfx_type.ThunderBeamShot => SFX_ThunderBeamShot.Play()
            sfx_type.QuickBoomerangShot => SFX_QuickBoomerangShot.Play()
            sfx_type.AtomicFireShot => SFX_AtomicFireShot.Play()
            sfx_type.CrashBomberShot => SFX_CrashBomberShot.Play()
            sfx_type.TimeStopperShot => SFX_TimeStopperShot.Play()
            sfx_type.WeaponSwitch => SFX_WeaponSwitch.Play()
            sfx_type.WeaponEmpty => SFX_WeaponEmpty.Play()

            # Boss
            sfx_type.BossSpawn => SFX_BossSpawn.Play()
            sfx_type.BossHit => SFX_BossHit.Play()
            sfx_type.BossWeaknessHit => SFX_BossWeaknessHit.Play()
            sfx_type.BossDeath => SFX_BossDeath.Play()
            sfx_type.BossAttack => SFX_BossAttack.Play()
            sfx_type.BossJump => SFX_BossJump.Play()
            sfx_type.BossLand => SFX_BossLand.Play()

            # Environment
            sfx_type.PortalEnter => SFX_PortalEnter.Play()
            sfx_type.PortalExit => SFX_PortalExit.Play()
            sfx_type.DoorOpen => SFX_DoorOpen.Play()
            sfx_type.DoorClose => SFX_DoorClose.Play()
            sfx_type.Explosion => SFX_Explosion.Play()
            sfx_type.Teleport => SFX_Teleport.Play()

            _ => {}

    # Play weapon-specific shot sound
    PlayWeaponShotSFX(Weapon : weapon_type) : void =
        case(Weapon):
            weapon_type.MegaBuster => PlaySFX(sfx_type.MegaBusterShot)
            weapon_type.RollingCutter => PlaySFX(sfx_type.RollingCutterShot)
            weapon_type.IceSlasher => PlaySFX(sfx_type.IceSlasherShot)
            weapon_type.FireStorm => PlaySFX(sfx_type.FireStormShot)
            weapon_type.ThunderBeam => PlaySFX(sfx_type.ThunderBeamShot)
            weapon_type.QuickBoomerang => PlaySFX(sfx_type.QuickBoomerangShot)
            weapon_type.AtomicFire => PlaySFX(sfx_type.AtomicFireShot)
            weapon_type.CrashBomber => PlaySFX(sfx_type.CrashBomberShot)
            weapon_type.TimeStopper => PlaySFX(sfx_type.TimeStopperShot)
            _ => PlaySFX(sfx_type.MegaBusterShot)

    # Toggle SFX on/off
    ToggleSFX() : void =
        if (IsSFXEnabled = true):
            set IsSFXEnabled = false
        else:
            set IsSFXEnabled = true

    # ========================================
    # CONVENIENCE METHODS
    # ========================================

    # Boss battle sequence
    StartBossBattle(BossType : boss_type)<suspends> : void =
        # Play boss intro
        PlayMusic(music_track.BossIntro)
        PlaySFX(sfx_type.BossSpawn)

        # Wait for intro
        Sleep(2.0)

        # Start battle music
        PlayMusic(music_track.BossBattle)

    # Boss defeated sequence
    BossDefeated()<suspends> : void =
        StopAllMusic()
        PlaySFX(sfx_type.BossDeath)
        Sleep(0.5)
        PlaySFX(sfx_type.Explosion)
        Sleep(1.0)
        PlayMusic(music_track.WeaponGet)

    # Return to hub
    ReturnToHub() : void =
        StopAllMusic()
        PlaySFX(sfx_type.Teleport)
        PlayMusic(music_track.Hub)

    # Victory sequence
    VictorySequence() : void =
        StopAllMusic()
        PlayMusic(music_track.Victory)

    # Game over sequence
    GameOverSequence() : void =
        StopAllMusic()
        PlayMusic(music_track.GameOver)

    # Get current music track
    GetCurrentMusic() : music_track =
        CurrentMusic
