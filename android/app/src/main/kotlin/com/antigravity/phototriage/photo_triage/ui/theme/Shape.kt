package com.antigravity.phototriage.photo_triage.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Shapes
import androidx.compose.ui.unit.dp

/**
 * Material 3 Expressive Shape Tokens
 *
 * M3 Expressive uses generously rounded shapes to convey warmth,
 * approachability, and emotional engagement. Larger corner radii
 * are used throughout to create an organic, friendly feel.
 *
 * References:
 * https://m3.material.io/styles/shape/overview
 * https://developer.android.com/develop/ui/compose/designsystems/material3
 */
val M3ExpressiveShapes = Shapes(
    extraSmall = RoundedCornerShape(8.dp),
    small = RoundedCornerShape(14.dp),
    medium = RoundedCornerShape(20.dp),
    large = RoundedCornerShape(28.dp),
    extraLarge = RoundedCornerShape(36.dp)
)

// ── Expressive Component Shape Tokens ──
// Each component has its own generous radius for a cohesive expressive feel
val CardCornerRadius = 32.dp
val PillCornerRadius = 28.dp
val ChipCornerRadius = 18.dp
val ButtonCornerRadius = 24.dp
val SheetCornerRadius = 36.dp
val DialogCornerRadius = 32.dp
val LargeContainerCornerRadius = 32.dp
val MiniCornerRadius = 12.dp

// ── M3 Expressive Hero Shape Tokens ──
// Extra-large shapes for hero moments and expressive surfaces
val HeroCardCornerRadius = 36.dp
val FloatingToolbarCornerRadius = 32.dp
val CarouselItemCornerRadius = 28.dp
val EmptyStateIconCornerRadius = 28.dp
val ProgressContainerCornerRadius = 20.dp
val BadgeCornerRadius = 10.dp
val GridItemCornerRadius = 22.dp
val OverlayPillCornerRadius = 24.dp
