package com.antigravity.phototriage.photo_triage.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Shapes
import androidx.compose.ui.unit.dp

/**
 * Material 3 Expressive Geometry and Shape Tokens
 * Based on https://m3.material.io/styles/shape/overview & https://developer.android.com/
 *
 * M3 Expressive adds generous rounding, squircle-like high curvature,
 * and asymmetric/organic expressive shapes to establish an emotional, engaging feel.
 */
val M3ExpressiveShapes = Shapes(
    extraSmall = RoundedCornerShape(8.dp),
    small = RoundedCornerShape(14.dp),
    medium = RoundedCornerShape(20.dp),
    large = RoundedCornerShape(28.dp),
    extraLarge = RoundedCornerShape(36.dp)
)

// Specific Expressive Component Radii
val CardCornerRadius = 32.dp
val PillCornerRadius = 28.dp
val ChipCornerRadius = 18.dp
val ButtonCornerRadius = 24.dp
val SheetCornerRadius = 36.dp
val DialogCornerRadius = 32.dp
val LargeContainerCornerRadius = 32.dp
val MiniCornerRadius = 12.dp
