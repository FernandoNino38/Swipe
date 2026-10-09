package com.antigravity.phototriage.photo_triage.ui.theme

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring

/**
 * Material 3 Expressive Motion Tokens
 *
 * These tokens complement the MotionScheme.expressive() set in the theme.
 * MotionScheme automatically provides spring-based spatial animations
 * to all M3 components. These tokens are for custom animations that
 * need specific motion characteristics.
 *
 * References:
 * https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration
 * https://m3.material.io/styles/motion/transitions/transition-patterns
 */
object M3Motion {
    // Easing curves for tween-based animations (used where springs don't fit)
    val Emphasized = CubicBezierEasing(0.2f, 0.0f, 0.0f, 1.0f)
    val EmphasizedDecelerate = CubicBezierEasing(0.05f, 0.7f, 0.1f, 1.0f)
    val EmphasizedAccelerate = CubicBezierEasing(0.3f, 0.0f, 0.8f, 0.15f)

    // Standard curves for utility transitions
    val Standard = CubicBezierEasing(0.2f, 0.0f, 0.0f, 1.0f)
    val StandardDecelerate = CubicBezierEasing(0.0f, 0.0f, 0.2f, 1.0f)
    val StandardAccelerate = CubicBezierEasing(0.3f, 0.0f, 1.0f, 1.0f)

    // Duration tokens (milliseconds) – M3 Expressive uses longer durations for emphasis
    const val DurationShort1 = 50
    const val DurationShort2 = 100
    const val DurationShort3 = 150
    const val DurationShort4 = 200

    const val DurationMedium1 = 250
    const val DurationMedium2 = 300
    const val DurationMedium3 = 350
    const val DurationMedium4 = 400

    const val DurationLong1 = 450
    const val DurationLong2 = 500
    const val DurationLong3 = 550
    const val DurationLong4 = 600

    const val DurationExtraLong1 = 700
    const val DurationExtraLong2 = 800
    const val DurationExtraLong3 = 900
    const val DurationExtraLong4 = 1000

    // ── M3 Expressive Spring Specifications ──
    // Bouncy spring for hero interactions (card swipes, FAB morphs, button presses)
    val ExpressiveBouncySpring = spring<Float>(
        dampingRatio = Spring.DampingRatioMediumBouncy,
        stiffness = Spring.StiffnessMedium
    )

    // Smooth spring for transitions (navigation, expansion, collapse)
    val ExpressiveSmoothSpring = spring<Float>(
        dampingRatio = Spring.DampingRatioNoBouncy,
        stiffness = Spring.StiffnessMediumLow
    )

    // Snappy spring for micro-interactions (press feedback, scale animations)
    val ExpressiveSnappySpring = spring<Float>(
        dampingRatio = Spring.DampingRatioLowBouncy,
        stiffness = Spring.StiffnessHigh
    )

    // Gentle spring for subtle ambient motions (breathing, pulse)
    val ExpressiveGentleSpring = spring<Float>(
        dampingRatio = Spring.DampingRatioNoBouncy,
        stiffness = Spring.StiffnessLow
    )

    // Playful spring for expressive moments (favorite, celebration)
    val ExpressivePlayfulSpring = spring<Float>(
        dampingRatio = 0.45f, // Medium-low bouncy
        stiffness = 350f     // Between Medium and MediumLow
    )
}
