package com.antigravity.phototriage.photo_triage.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

// M3 Expressive Signature Palette
val ElectricBlue = Color(0xFF0072DE)
val EmeraldMint = Color(0xFF2AC06D) // Manter (Positive)
val CoralRed = Color(0xFFFA5252)    // Descartar (Negative)
val RosePink = Color(0xFFFF3366)    // Favorito (Accent)
val AmberWarning = Color(0xFFFF922B)

val LightScaffold = Color(0xFFF6F8FC)
val DarkScaffold = Color(0xFF0F1218)
val DarkSurfaceContainer = Color(0xFF181C26)
val DarkSurfaceContainerHigh = Color(0xFF222838)

private val DarkColorScheme = darkColorScheme(
    primary = Color(0xFF388BFD),
    onPrimary = Color.White,
    primaryContainer = Color(0xFF0D3868),
    onPrimaryContainer = Color(0xFFD0E6FF),

    secondary = Color(0xFF4DD0E1),
    onSecondary = Color.White,
    secondaryContainer = Color(0xFF133842),
    onSecondaryContainer = Color(0xFFB2EBF2),

    tertiary = RosePink,
    onTertiary = Color.White,
    tertiaryContainer = Color(0xFF4A1024),
    onTertiaryContainer = Color(0xFFFFD0E0),

    error = Color(0xFFFF6B6B),
    errorContainer = Color(0xFF4A1515),
    onErrorContainer = Color(0xFFFFD2D2),

    surface = DarkScaffold,
    onSurface = Color(0xFFF0F3F8),
    surfaceContainerLowest = Color(0xFF060709),
    surfaceContainerLow = Color(0xFF10131A),
    surfaceContainer = DarkSurfaceContainer,
    surfaceContainerHigh = DarkSurfaceContainerHigh,
    surfaceContainerHighest = Color(0xFF2C3244),

    outline = Color(0xFF3D4455),
    outlineVariant = Color(0xFF252B37)
)

private val LightColorScheme = lightColorScheme(
    primary = ElectricBlue,
    onPrimary = Color.White,
    primaryContainer = Color(0xFFE3F0FF),
    onPrimaryContainer = Color(0xFF004085),

    secondary = Color(0xFF0288D1),
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFE1F5FE),
    onSecondaryContainer = Color(0xFF01579B),

    tertiary = RosePink,
    onTertiary = Color.White,
    tertiaryContainer = Color(0xFFFFEBF2),
    onTertiaryContainer = Color(0xFF8C002F),

    error = CoralRed,
    errorContainer = Color(0xFFFFE8E8),
    onErrorContainer = Color(0xFF8B1212),

    surface = LightScaffold,
    onSurface = Color(0xFF1C1E23),
    surfaceContainerLowest = Color.White,
    surfaceContainerLow = Color(0xFFF7F8FC),
    surfaceContainer = Color.White,
    surfaceContainerHigh = Color(0xFFECEEF5),
    surfaceContainerHighest = Color(0xFFE2E5F0),

    outline = Color(0xFFCFD5E2),
    outlineVariant = Color(0xFFE4E7F0)
)

enum class AppThemeMode {
    SYSTEM, LIGHT, DARK
}

@Composable
fun SwipeTheme(
    themeMode: AppThemeMode = AppThemeMode.SYSTEM,
    dynamicColor: Boolean = true, // Enabled dynamic colors to embrace Material You
    content: @Composable () -> Unit
) {
    val isDark = when (themeMode) {
        AppThemeMode.SYSTEM -> isSystemInDarkTheme()
        AppThemeMode.LIGHT -> false
        AppThemeMode.DARK -> true
    }

    val context = LocalContext.current
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            if (isDark) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        isDark -> DarkColorScheme
        else -> LightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = M3ExpressiveTypography,
        shapes = M3ExpressiveShapes,
        content = content
    )
}
