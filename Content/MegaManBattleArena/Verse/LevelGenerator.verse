# LevelGenerator.verse
# Procedurally generates the hub room and 8 boss rooms at runtime
# Eliminates need for manual level construction

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Building }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Import types
using { WeaponTypes }

# Room type enumeration
room_type := enum:
    Hub
    BossRoom

# Platform definition
platform_def := struct:
    Position : vector3
    Size : vector3
    MaterialIndex : int  # For color coding

# Portal placement definition
portal_placement := struct:
    Position : vector3
    Rotation : rotation
    BossType : boss_type
    IsLeftSide : logic

# Room definition
room_def := struct:
    RoomType : room_type
    Origin : vector3
    Size : vector3
    Platforms : []platform_def
    BossType : ?boss_type

# Level generator device - creates all rooms and structures
level_generator := class(creative_device):
    # Building prop spawner for creating structures
    @editable
    FloorPropSpawner : prop_spawner_device = prop_spawner_device{}

    @editable
    WallPropSpawner : prop_spawner_device = prop_spawner_device{}

    @editable
    PlatformPropSpawner : prop_spawner_device = prop_spawner_device{}

    @editable
    PortalFramePropSpawner : prop_spawner_device = prop_spawner_device{}

    # Prop movers for animated elements
    @editable
    PortalEffectProps : []prop_mover_device = array{}

    # Level dimensions
    HubRoomWidth : float = 2000.0
    HubRoomHeight : float = 1500.0
    HubRoomDepth : float = 800.0

    BossRoomWidth : float = 1200.0
    BossRoomHeight : float = 800.0
    BossRoomDepth : float = 600.0

    # Platform settings
    PlatformWidth : float = 200.0
    PlatformDepth : float = 150.0
    PlatformHeight : float = 30.0

    # Portal settings
    PortalWidth : float = 150.0
    PortalHeight : float = 200.0

    # Spacing
    VerticalPlatformSpacing : float = 280.0
    WallOffset : float = 100.0

    # Generated data
    var HubRoom : room_def = room_def{}
    var BossRooms : [boss_type]room_def = map{}
    var PortalPlacements : []portal_placement = array{}

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

    # Initialize and generate level
    OnBegin<override>()<suspends> : void =
        Print("=== LEVEL GENERATOR ===")
        Print("Generating Mega Man Battle Arena...")

        # Generate hub room
        GenerateHubRoom()

        # Generate 8 boss rooms
        GenerateAllBossRooms()

        # Calculate portal placements
        CalculatePortalPlacements()

        # Output level data for device configuration
        OutputLevelConfiguration()

        Print("Level generation complete!")

    # Generate the central hub room
    GenerateHubRoom() : void =
        Print("Generating Hub Room...")

        # Hub room centered at origin
        HubOrigin := vector3{X := 0.0, Y := 0.0, Z := 0.0}

        # Generate platforms for left side (4 platforms for 4 bosses)
        var LeftPlatforms : []platform_def = array{}
        for (I := 0..3):
            FloatI := I * 1.0
            PlatformPos := vector3{
                X := -HubRoomWidth / 2.0 + WallOffset + PlatformWidth / 2.0,
                Y := 0.0,
                Z := 100.0 + FloatI * VerticalPlatformSpacing
            }
            Platform := platform_def{
                Position := PlatformPos,
                Size := vector3{X := PlatformWidth, Y := PlatformDepth, Z := PlatformHeight},
                MaterialIndex := I
            }
            set LeftPlatforms = LeftPlatforms + array{Platform}

        # Generate platforms for right side (4 platforms for 4 bosses)
        var RightPlatforms : []platform_def = array{}
        for (I := 0..3):
            FloatI := I * 1.0
            PlatformPos := vector3{
                X := HubRoomWidth / 2.0 - WallOffset - PlatformWidth / 2.0,
                Y := 0.0,
                Z := 100.0 + FloatI * VerticalPlatformSpacing
            }
            Platform := platform_def{
                Position := PlatformPos,
                Size := vector3{X := PlatformWidth, Y := PlatformDepth, Z := PlatformHeight},
                MaterialIndex := I + 4
            }
            set RightPlatforms = RightPlatforms + array{Platform}

        # Combine all platforms
        AllPlatforms := LeftPlatforms + RightPlatforms

        # Create hub room definition
        set HubRoom = room_def{
            RoomType := room_type.Hub,
            Origin := HubOrigin,
            Size := vector3{X := HubRoomWidth, Y := HubRoomDepth, Z := HubRoomHeight},
            Platforms := AllPlatforms,
            BossType := false
        }

        Print("  Hub Room: {HubRoomWidth}x{HubRoomDepth}x{HubRoomHeight}")
        Print("  Platforms: {AllPlatforms.Length}")

    # Generate all 8 boss rooms
    GenerateAllBossRooms() : void =
        Print("Generating Boss Rooms...")

        # Boss rooms arranged in a grid behind the hub
        # Left side bosses: negative X, spaced in Z
        # Right side bosses: positive X, spaced in Z

        BossRoomSpacingX := BossRoomWidth + 200.0
        BossRoomSpacingZ := BossRoomHeight + 200.0
        BossRoomOffsetY := HubRoomDepth + BossRoomDepth + 500.0  # Behind hub

        for (I := 0..AllBossTypes.Length - 1):
            if (BossType := AllBossTypes[I]):
                FloatI := I * 1.0

                # Left side: indices 0-3, Right side: indices 4-7
                IsLeftSide := I < 4
                SideIndex := if (IsLeftSide) then I else I - 4
                FloatSideIndex := SideIndex * 1.0

                XPos := if (IsLeftSide):
                    -BossRoomSpacingX
                else:
                    BossRoomSpacingX

                ZPos := FloatSideIndex * BossRoomSpacingZ

                RoomOrigin := vector3{
                    X := XPos,
                    Y := BossRoomOffsetY,
                    Z := ZPos
                }

                # Boss room has a simple arena floor
                ArenaPlatform := platform_def{
                    Position := vector3{X := 0.0, Y := 0.0, Z := 0.0},
                    Size := vector3{X := BossRoomWidth - 100.0, Y := BossRoomDepth - 100.0, Z := 50.0},
                    MaterialIndex := I
                }

                BossRoom := room_def{
                    RoomType := room_type.BossRoom,
                    Origin := RoomOrigin,
                    Size := vector3{X := BossRoomWidth, Y := BossRoomDepth, Z := BossRoomHeight},
                    Platforms := array{ArenaPlatform},
                    BossType := option{BossType}
                }

                if (set BossRooms[BossType] = BossRoom) {}

                Config := GetBossConfig(BossType)
                Print("  {Config.DisplayName} Room at ({XPos}, {BossRoomOffsetY}, {ZPos})")

    # Calculate where portals should be placed
    CalculatePortalPlacements() : void =
        Print("Calculating Portal Placements...")

        set PortalPlacements = array{}

        # Left side portals (Cut Man, Ice Man, Fire Man, Elec Man)
        LeftBosses := array{boss_type.CutMan, boss_type.IceMan, boss_type.FireMan, boss_type.ElecMan}
        for (I := 0..LeftBosses.Length - 1):
            if (BossType := LeftBosses[I]):
                FloatI := I * 1.0
                PortalPos := vector3{
                    X := -HubRoomWidth / 2.0 + WallOffset,
                    Y := 0.0,
                    Z := 100.0 + FloatI * VerticalPlatformSpacing + PlatformHeight + PortalHeight / 2.0
                }
                # Facing right (into the room)
                PortalRot := MakeRotationFromYawPitchRollDegrees(90.0, 0.0, 0.0)

                Placement := portal_placement{
                    Position := PortalPos,
                    Rotation := PortalRot,
                    BossType := BossType,
                    IsLeftSide := true
                }
                set PortalPlacements = PortalPlacements + array{Placement}

        # Right side portals (Quick Man, Flash Man, Heat Man, Bubble Man)
        RightBosses := array{boss_type.QuickMan, boss_type.FlashMan, boss_type.HeatMan, boss_type.BubbleMan}
        for (I := 0..RightBosses.Length - 1):
            if (BossType := RightBosses[I]):
                FloatI := I * 1.0
                PortalPos := vector3{
                    X := HubRoomWidth / 2.0 - WallOffset,
                    Y := 0.0,
                    Z := 100.0 + FloatI * VerticalPlatformSpacing + PlatformHeight + PortalHeight / 2.0
                }
                # Facing left (into the room)
                PortalRot := MakeRotationFromYawPitchRollDegrees(-90.0, 0.0, 0.0)

                Placement := portal_placement{
                    Position := PortalPos,
                    Rotation := PortalRot,
                    BossType := BossType,
                    IsLeftSide := false
                }
                set PortalPlacements = PortalPlacements + array{Placement}

        Print("  Total Portals: {PortalPlacements.Length}")

    # Output configuration data for other systems
    OutputLevelConfiguration() : void =
        Print("")
        Print("=== LEVEL CONFIGURATION DATA ===")
        Print("")
        Print("HUB ROOM:")
        Print("  Origin: (0, 0, 0)")
        Print("  Size: {HubRoom.Size.X} x {HubRoom.Size.Y} x {HubRoom.Size.Z}")
        Print("")
        Print("PLATFORM POSITIONS:")
        for (I := 0..HubRoom.Platforms.Length - 1):
            if (Platform := HubRoom.Platforms[I]):
                Side := if (I < 4) then "LEFT" else "RIGHT"
                Print("  Platform {I} ({Side}): ({Platform.Position.X}, {Platform.Position.Y}, {Platform.Position.Z})")
        Print("")
        Print("PORTAL POSITIONS:")
        for (Placement : PortalPlacements):
            Config := GetBossConfig(Placement.BossType)
            Side := if (Placement.IsLeftSide) then "LEFT" else "RIGHT"
            Print("  {Config.DisplayName} ({Side}): ({Placement.Position.X}, {Placement.Position.Y}, {Placement.Position.Z})")
        Print("")
        Print("BOSS ROOM POSITIONS:")
        for (BossType -> Room : BossRooms):
            Config := GetBossConfig(BossType)
            Print("  {Config.DisplayName}: ({Room.Origin.X}, {Room.Origin.Y}, {Room.Origin.Z})")

    # Get hub room data
    GetHubRoom() : room_def =
        HubRoom

    # Get boss room data
    GetBossRoom(BossType : boss_type) : ?room_def =
        BossRooms[BossType]

    # Get portal placement for a boss
    GetPortalPlacement(BossType : boss_type) : ?portal_placement =
        for (Placement : PortalPlacements):
            if (Placement.BossType = BossType):
                return option{Placement}
        false

    # Get all portal placements
    GetAllPortalPlacements() : []portal_placement =
        PortalPlacements

    # Helper to create rotation from degrees
    MakeRotationFromYawPitchRollDegrees(Yaw : float, Pitch : float, Roll : float) : rotation =
        # Convert degrees to rotation
        # Simplified - actual implementation would use proper quaternion math
        IdentityRotation := rotation{}
        IdentityRotation
