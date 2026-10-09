package com.antigravity.phototriage.photo_triage.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.antigravity.phototriage.photo_triage.ui.theme.M3Motion
import com.antigravity.phototriage.photo_triage.ui.theme.ProgressContainerCornerRadius

/**
 * Material 3 Expressive Loading Indicator
 *
 * Uses the official M3 Expressive LoadingIndicator (morphing polygon)
 * and LinearWavyProgressIndicator components from material3:1.5.0-alpha29.
 * Wrapped in an expressive breathing container for an engaging loading experience.
 *
 * References:
 * https://m3.material.io/components/loading-indicator/overview
 * https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#LoadingIndicator
 */

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun M3ExpressiveLoadingIndicator(
    modifier: Modifier = Modifier,
    size: Dp = 56.dp,
    color: Color = MaterialTheme.colorScheme.primary,
    trackColor: Color = MaterialTheme.colorScheme.surfaceVariant,
    message: String? = null
) {
    val transition = rememberInfiniteTransition(label = "m3_expressive_loading")

    // Breathing scale animation for the container – expressive pulsing effect
    val breathingScale by transition.animateFloat(
        initialValue = 0.92f,
        targetValue = 1.08f,
        animationSpec = infiniteRepeatable(
            animation = tween(
                durationMillis = 1200,
                easing = M3Motion.EmphasizedDecelerate
            ),
            repeatMode = RepeatMode.Reverse
        ),
        label = "breathing_scale"
    )

    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Expressive tonal container wrapping the M3 LoadingIndicator
        Surface(
            shape = RoundedCornerShape(ProgressContainerCornerRadius),
            color = MaterialTheme.colorScheme.surfaceContainerHigh,
            tonalElevation = 4.dp,
            modifier = Modifier
                .scale(breathingScale)
                .size(size + 32.dp)
        ) {
            Box(contentAlignment = Alignment.Center) {
                // Official M3 Expressive LoadingIndicator – morphing polygon animation
                LoadingIndicator(
                    modifier = Modifier.size(size),
                    color = color,
                )
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // M3 Expressive LinearWavyProgressIndicator – stylized wave-based loading bar
        LinearWavyProgressIndicator(
            modifier = Modifier
                .width(size * 2.5f)
                .height(6.dp),
            color = color,
            trackColor = trackColor.copy(alpha = 0.25f),
        )

        if (message != null) {
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = message,
                style = MaterialTheme.typography.bodyMedium.copy(
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    letterSpacing = 0.1.sp
                )
            )
        }
    }
}
