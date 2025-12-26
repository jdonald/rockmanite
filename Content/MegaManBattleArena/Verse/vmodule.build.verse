# vmodule.build.verse
# Build configuration for Mega Man Battle Arena

using { /Verse.org/BuildConfig }

mega_man_battle_arena_vmodule := vmodule:
    # Module dependencies
    Dependencies := array:
        module{name := "/Fortnite.com/Devices"}
        module{name := "/Fortnite.com/Characters"}
        module{name := "/Fortnite.com/Game"}
        module{name := "/Fortnite.com/AI"}
        module{name := "/Fortnite.com/UI"}
        module{name := "/Fortnite.com/Playspaces"}
        module{name := "/Verse.org/Simulation"}
        module{name := "/Verse.org/Random"}
        module{name := "/UnrealEngine.com/Temporary/SpatialMath"}
        module{name := "/UnrealEngine.com/Temporary/UI"}
