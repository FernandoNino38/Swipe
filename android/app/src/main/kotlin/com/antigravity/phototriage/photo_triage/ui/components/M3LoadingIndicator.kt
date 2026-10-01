package com.antigravity.phototriage.photo_triage.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.antigravity.phototriage.photo_triage.ui.theme.M3Motion

/**
 * Official Material 3 Loading Indicator
 * Conforms to https://m3.material.io/components/loading-indicator/overview:
 * - Deterministic/Indeterminate circular track with container
 * - Emphasized motion with expanding & contracting arc
 * - Expressive pulsing container with rotating arcs
 */
@Composable
fun M3ExpressiveLoadingIndicator(
    modifier: Modifier = Modifier,
    size: Dp = 56.dp,
    color: Color = MaterialTheme.colorScheme.primary,
    trackColor: Color = MaterialTheme.colorScheme.surfaceVariant,
    message: String? = null
) {
    val transition = rememberInfiniteTransition(label = "m3_loading_indicator")

    // Rotation angle across standard M3 cycle (1332 ms per cycle)
    val rotation by transition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1332, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "rotation"
    )

    // Arc start angle animation
    val startAngle by transition.animateFloat(
        initialValue = 0f,
        targetValue = 720f,
        animationSpec = infiniteRepeatable(
            animation = keyframes {
                durationMillis = 2664
                0f at 0 using M3Motion.Emphasized
                360f at 1332 using M3Motion.Emphasized
                720f at 2664
            },
            repeatMode = RepeatMode.Restart
        ),
        label = "start_angle"
    )

    // Arc sweep angle expanding and collapsing
    val sweepAngle by transition.animateFloat(
        initialValue = 15f,
        targetValue = 15f,
        animationSpec = infiniteRepeatable(
            animation = keyframes {
                durationMillis = 2664
                15f at 0 using M3Motion.Emphasized
                280f at 1332 using M3Motion.Emphasized
                15f at 2664
            },
            repeatMode = RepeatMode.Restart
        ),
        label = "sweep_angle"
    )

    // Expressive center dot breathing
    val pulseAlpha by transition.animateFloat(
        initialValue = 0.4f,
        targetValue = 0.9f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 666, easing = M3Motion.EmphasizedDecelerate),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulse_alpha"
    )

    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Canvas(modifier = Modifier.size(size)) {
            val strokeWidth = (size * 0.12f).toPx()
            val diameter = size.toPx() - strokeWidth
            val topLeft = Offset(strokeWidth / 2f, strokeWidth / 2f)
            val arcSize = androidx.compose.ui.geometry.Size(diameter, diameter)

            // Background circular track
            drawArc(
                color = trackColor.copy(alpha = 0.35f),
                startAngle = 0f,
                sweepAngle = 360f,
                useCenter = false,
                topLeft = topLeft,
                size = arcSize,
                style = Stroke(width = strokeWidth, cap = StrokeCap.Round)
            )

            // Dynamic Emphasized sweeping arc
            rotate(rotation) {
                drawArc(
                    color = color,
                    startAngle = startAngle,
                    sweepAngle = sweepAngle,
                    useCenter = false,
                    topLeft = topLeft,
                    size = arcSize,
                    style = Stroke(width = strokeWidth, cap = StrokeCap.Round)
                )
            }

            // Material 3 Expressive inner tonal nucleus
            drawCircle(
                color = color.copy(alpha = pulseAlpha),
                radius = strokeWidth * 0.9f,
                center = center
            )
        }

        if (message != null) {
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = message,
                style = MaterialTheme.typography.bodyMedium.copy(
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            )
        }
    }
}
