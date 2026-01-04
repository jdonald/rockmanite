# VisualAssets.verse
# Defines all visual assets, colors, projectile visuals, and UI elements
# Centralizes all visual configuration for easy customization

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Import types
using { WeaponTypes }

# Color definition with RGB values
color_rgb := struct:
    R : float  # 0-255
    G : float  # 0-255
    B : float  # 0-255

# Projectile visual definition
projectile_visual := struct:
    WeaponType : weapon_type
    PrimaryColor : color_rgb
    SecondaryColor : color_rgb
    TrailColor : color_rgb
    Size : float          # Scale multiplier
    TrailLength : float   # Trail effect length
    GlowIntensity : float # Emission strength
    ShapeType : int       # 0=sphere, 1=blade, 2=bolt, 3=flame, 4=boomerang, 5=bomb, 6=clock

# Boss visual definition
boss_visual := struct:
    BossType : boss_type
    PrimaryColor : color_rgb
    SecondaryColor : color_rgb
    AccentColor : color_rgb
    EyeColor : color_rgb
    HealthBarColor : color_rgb

# Portal visual definition
portal_visual := struct:
    BossType : boss_type
    FrameColor : color_rgb
    VortexColor : color_rgb
    GlowColor : color_rgb
    HologramColor : color_rgb

# UI element definition
ui_element := struct:
    Name : string
    BackgroundColor : color_rgb
    TextColor : color_rgb
    AccentColor : color_rgb

# ========================================
# COLOR PALETTE
# ========================================

# Mega Man Blue (default)
MegaManBlue := color_rgb{R := 0.0, G := 112.0, B := 255.0}
MegaManDarkBlue := color_rgb{R := 0.0, G := 80.0, B := 180.0}
MegaManLightBlue := color_rgb{R := 100.0, G := 180.0, B := 255.0}

# Cut Man - White/Silver
CutManWhite := color_rgb{R := 240.0, G := 240.0, B := 245.0}
CutManGray := color_rgb{R := 180.0, G := 180.0, B := 190.0}
CutManRed := color_rgb{R := 200.0, G := 50.0, B := 50.0}

# Ice Man - Ice Blue
IceManBlue := color_rgb{R := 150.0, G := 220.0, B := 255.0}
IceManWhite := color_rgb{R := 230.0, G := 245.0, B := 255.0}
IceManDark := color_rgb{R := 80.0, G := 150.0, B := 200.0}

# Fire Man - Orange/Red
FireManOrange := color_rgb{R := 255.0, G := 100.0, B := 0.0}
FireManRed := color_rgb{R := 255.0, G := 50.0, B := 0.0}
FireManYellow := color_rgb{R := 255.0, G := 200.0, B := 50.0}

# Elec Man - Yellow/Black
ElecManYellow := color_rgb{R := 255.0, G := 255.0, B := 0.0}
ElecManBlack := color_rgb{R := 30.0, G := 30.0, B := 40.0}
ElecManWhite := color_rgb{R := 255.0, G := 255.0, B := 220.0}

# Quick Man - Red
QuickManRed := color_rgb{R := 255.0, G := 50.0, B := 50.0}
QuickManDarkRed := color_rgb{R := 180.0, G := 30.0, B := 30.0}
QuickManYellow := color_rgb{R := 255.0, G := 220.0, B := 100.0}

# Flash Man - Purple/Blue
FlashManPurple := color_rgb{R := 150.0, G := 80.0, B := 200.0}
FlashManBlue := color_rgb{R := 100.0, G := 100.0, B := 255.0}
FlashManGold := color_rgb{R := 255.0, G := 200.0, B := 50.0}

# Heat Man - Dark Orange
HeatManOrange := color_rgb{R := 255.0, G := 150.0, B := 0.0}
HeatManRed := color_rgb{R := 200.0, G := 50.0, B := 0.0}
HeatManYellow := color_rgb{R := 255.0, G := 255.0, B := 100.0}

# Bubble Man - Green
BubbleManGreen := color_rgb{R := 50.0, G := 200.0, B := 100.0}
BubbleManBlue := color_rgb{R := 100.0, G := 180.0, B := 255.0}
BubbleManWhite := color_rgb{R := 220.0, G := 255.0, B := 240.0}

# UI Colors
UIBlack := color_rgb{R := 20.0, G := 20.0, B := 30.0}
UIWhite := color_rgb{R := 255.0, G := 255.0, B := 255.0}
UIGold := color_rgb{R := 255.0, G := 200.0, B := 50.0}
UIRed := color_rgb{R := 255.0, G := 80.0, B := 80.0}
UIGreen := color_rgb{R := 80.0, G := 255.0, B := 120.0}

# ========================================
# PROJECTILE VISUALS
# ========================================

GetProjectileVisual(Type : weapon_type) : projectile_visual =
    case(Type):
        weapon_type.MegaBuster =>
            projectile_visual{
                WeaponType := Type,
                PrimaryColor := MegaManBlue,
                SecondaryColor := MegaManLightBlue,
                TrailColor := MegaManLightBlue,
                Size := 1.0,
                TrailLength := 0.5,
                GlowIntensity := 1.0,
                ShapeType := 0  # Sphere
            }

        weapon_type.RollingCutter =>
            projectile_visual{
                WeaponType := Type,
                PrimaryColor := CutManWhite,
                SecondaryColor := CutManGray,
                TrailColor := CutManWhite,
                Size := 1.2,
                TrailLength := 0.8,
                GlowIntensity := 0.8,
                ShapeType := 1  # Blade
            }

        weapon_type.IceSlasher =>
            projectile_visual{
                WeaponType := Type,
                PrimaryColor := IceManBlue,
                SecondaryColor := IceManWhite,
                TrailColor := IceManWhite,
                Size := 1.0,
                TrailLength := 1.0,
                GlowIntensity := 1.2,
                ShapeType := 1  # Blade (crystal shard)
            }

        weapon_type.FireStorm =>
            projectile_visual{
                WeaponType := Type,
                PrimaryColor := FireManOrange,
                SecondaryColor := FireManYellow,
                TrailColor := FireManRed,
                Size := 1.3,
                TrailLength := 1.5,
                GlowIntensity := 2.0,
                ShapeType := 3  # Flame
            }

        weapon_type.ThunderBeam =>
            projectile_visual{
                WeaponType := Type,
                PrimaryColor := ElecManYellow,
                SecondaryColor := ElecManWhite,
                TrailColor := ElecManYellow,
                Size := 0.8,
                TrailLength := 2.0,
                GlowIntensity := 2.5,
                ShapeType := 2  # Bolt
            }

        weapon_type.QuickBoomerang =>
            projectile_visual{
                WeaponType := Type,
                PrimaryColor := QuickManRed,
                SecondaryColor := QuickManYellow,
                TrailColor := QuickManRed,
                Size := 0.9,
                TrailLength := 0.6,
                GlowIntensity := 1.0,
                ShapeType := 4  # Boomerang
            }

        weapon_type.AtomicFire =>
            projectile_visual{
                WeaponType := Type,
                PrimaryColor := HeatManOrange,
                SecondaryColor := HeatManYellow,
                TrailColor := HeatManRed,
                Size := 1.8,
                TrailLength := 2.0,
                GlowIntensity := 3.0,
                ShapeType := 3  # Flame (large fireball)
            }

        weapon_type.CrashBomber =>
            projectile_visual{
                WeaponType := Type,
                PrimaryColor := HeatManRed,
                SecondaryColor := HeatManOrange,
                TrailColor := UIBlack,
                Size := 1.4,
                TrailLength := 0.3,
                GlowIntensity := 0.5,
                ShapeType := 5  # Bomb
            }

        weapon_type.TimeStopper =>
            projectile_visual{
                WeaponType := Type,
                PrimaryColor := FlashManPurple,
                SecondaryColor := FlashManGold,
                TrailColor := FlashManBlue,
                Size := 1.1,
                TrailLength := 0.4,
                GlowIntensity := 1.5,
                ShapeType := 6  # Clock
            }

        _ =>
            projectile_visual{
                WeaponType := weapon_type.MegaBuster,
                PrimaryColor := MegaManBlue,
                SecondaryColor := MegaManLightBlue,
                TrailColor := MegaManLightBlue,
                Size := 1.0,
                TrailLength := 0.5,
                GlowIntensity := 1.0,
                ShapeType := 0
            }

# ========================================
# BOSS VISUALS
# ========================================

GetBossVisual(Type : boss_type) : boss_visual =
    case(Type):
        boss_type.CutMan =>
            boss_visual{
                BossType := Type,
                PrimaryColor := CutManWhite,
                SecondaryColor := CutManGray,
                AccentColor := CutManRed,
                EyeColor := UIWhite,
                HealthBarColor := CutManRed
            }

        boss_type.IceMan =>
            boss_visual{
                BossType := Type,
                PrimaryColor := IceManBlue,
                SecondaryColor := IceManWhite,
                AccentColor := IceManDark,
                EyeColor := UIWhite,
                HealthBarColor := IceManBlue
            }

        boss_type.FireMan =>
            boss_visual{
                BossType := Type,
                PrimaryColor := FireManOrange,
                SecondaryColor := FireManRed,
                AccentColor := FireManYellow,
                EyeColor := FireManYellow,
                HealthBarColor := FireManOrange
            }

        boss_type.ElecMan =>
            boss_visual{
                BossType := Type,
                PrimaryColor := ElecManYellow,
                SecondaryColor := ElecManBlack,
                AccentColor := ElecManWhite,
                EyeColor := ElecManYellow,
                HealthBarColor := ElecManYellow
            }

        boss_type.QuickMan =>
            boss_visual{
                BossType := Type,
                PrimaryColor := QuickManRed,
                SecondaryColor := QuickManDarkRed,
                AccentColor := QuickManYellow,
                EyeColor := UIWhite,
                HealthBarColor := QuickManRed
            }

        boss_type.FlashMan =>
            boss_visual{
                BossType := Type,
                PrimaryColor := FlashManPurple,
                SecondaryColor := FlashManBlue,
                AccentColor := FlashManGold,
                EyeColor := FlashManGold,
                HealthBarColor := FlashManPurple
            }

        boss_type.HeatMan =>
            boss_visual{
                BossType := Type,
                PrimaryColor := HeatManOrange,
                SecondaryColor := HeatManRed,
                AccentColor := HeatManYellow,
                EyeColor := HeatManYellow,
                HealthBarColor := HeatManOrange
            }

        boss_type.BubbleMan =>
            boss_visual{
                BossType := Type,
                PrimaryColor := BubbleManGreen,
                SecondaryColor := BubbleManBlue,
                AccentColor := BubbleManWhite,
                EyeColor := UIWhite,
                HealthBarColor := BubbleManGreen
            }

        _ =>
            boss_visual{
                BossType := boss_type.CutMan,
                PrimaryColor := CutManWhite,
                SecondaryColor := CutManGray,
                AccentColor := CutManRed,
                EyeColor := UIWhite,
                HealthBarColor := CutManRed
            }

# ========================================
# PORTAL VISUALS
# ========================================

GetPortalVisual(Type : boss_type) : portal_visual =
    BossVis := GetBossVisual(Type)
    portal_visual{
        BossType := Type,
        FrameColor := BossVis.SecondaryColor,
        VortexColor := BossVis.PrimaryColor,
        GlowColor := BossVis.AccentColor,
        HologramColor := BossVis.PrimaryColor
    }

# ========================================
# UI DEFINITIONS
# ========================================

GetHealthBarUI() : ui_element =
    ui_element{
        Name := "Health Bar",
        BackgroundColor := UIBlack,
        TextColor := UIWhite,
        AccentColor := UIRed
    }

GetWeaponUI() : ui_element =
    ui_element{
        Name := "Weapon Display",
        BackgroundColor := UIBlack,
        TextColor := UIWhite,
        AccentColor := UIGold
    }

GetEnergyBarUI() : ui_element =
    ui_element{
        Name := "Energy Bar",
        BackgroundColor := UIBlack,
        TextColor := UIWhite,
        AccentColor := UIGreen
    }

# ========================================
# PLAYER SKIN COLORS
# ========================================

GetPlayerSkinColor(Weapon : weapon_type) : color_rgb =
    Config := GetWeaponConfig(Weapon)
    color_rgb{
        R := Config.SkinColorR,
        G := Config.SkinColorG,
        B := Config.SkinColorB
    }

# ========================================
# CHARGE LEVEL COLORS
# ========================================

GetChargeColor(Level : int) : color_rgb =
    case(Level):
        0 => MegaManBlue
        1 => color_rgb{R := 100.0, G := 200.0, B := 255.0}  # Light blue
        2 => color_rgb{R := 200.0, G := 255.0, B := 100.0}  # Green-yellow
        3 => color_rgb{R := 255.0, G := 255.0, B := 255.0}  # White (full charge)
        _ => MegaManBlue

# ========================================
# HELPER FUNCTIONS
# ========================================

# Convert color_rgb to normalized 0-1 range
NormalizeColor(C : color_rgb) : vector3 =
    vector3{
        X := C.R / 255.0,
        Y := C.G / 255.0,
        Z := C.B / 255.0
    }

# Interpolate between two colors
LerpColor(A : color_rgb, B : color_rgb, T : float) : color_rgb =
    color_rgb{
        R := A.R + (B.R - A.R) * T,
        G := A.G + (B.G - A.G) * T,
        B := A.B + (B.B - A.B) * T
    }

# Get shape name for projectile
GetShapeName(ShapeType : int) : string =
    case(ShapeType):
        0 => "Sphere"
        1 => "Blade"
        2 => "Bolt"
        3 => "Flame"
        4 => "Boomerang"
        5 => "Bomb"
        6 => "Clock"
        _ => "Unknown"
