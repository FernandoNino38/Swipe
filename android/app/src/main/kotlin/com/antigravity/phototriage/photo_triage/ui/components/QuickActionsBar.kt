package com.antigravity.phototriage.photo_triage.ui.components

import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.Undo
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.DeleteOutline
import androidx.compose.material.icons.rounded.Favorite
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.antigravity.phototriage.photo_triage.ui.theme.ButtonCornerRadius
import com.antigravity.phototriage.photo_triage.ui.theme.CoralRed
import com.antigravity.phototriage.photo_triage.ui.theme.EmeraldMint
import com.antigravity.phototriage.photo_triage.ui.theme.FloatingToolbarCornerRadius
import com.antigravity.phototriage.photo_triage.ui.theme.M3Motion
import com.antigravity.phototriage.photo_triage.ui.theme.RosePink

/**
 * Material 3 Expressive Quick Actions – HorizontalFloatingToolbar
 *
 * Uses the official M3 HorizontalFloatingToolbar component from material3:1.5.0-alpha29
 * with custom expressive action buttons inside featuring:
 * - Bouncy spring-based press feedback on each action button
 * - Expressive scale animations with haptic feedback
 * - Badge integration for favorites count
 * - Gradient accent strip along the top edge
 *
 * Reference: https://m3.material.io/components/floating-toolbar/overview
 */
@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun QuickActionsBar(
    canUndo: Boolean,
    favoritesCount: Int,
    onDelete: () -> Unit,
    onUndo: () -> Unit,
    onKeep: () -> Unit,
    onKeepLongClick: () -> Unit,
    onFavorite: () -> Unit,
    onFavoriteLongClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val colorScheme = MaterialTheme.colorScheme

    Box(
        modifier = modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .padding(horizontal = 20.dp, vertical = 14.dp),
        contentAlignment = Alignment.Center
    ) {
        // M3 Expressive: HorizontalFloatingToolbar
        HorizontalFloatingToolbar(
            expanded = true,
            modifier = Modifier
                .fillMaxWidth()
                .shadow(
                    elevation = 20.dp,
                    shape = RoundedCornerShape(FloatingToolbarCornerRadius),
                    spotColor = colorScheme.primary.copy(alpha = 0.20f),
                    ambientColor = colorScheme.primary.copy(alpha = 0.10f)
                ),
            colors = FloatingToolbarDefaults.standardFloatingToolbarColors(
                toolbarContainerColor = colorScheme.surfaceContainerHighest.copy(alpha = 0.92f)
            ),
            contentPadding = PaddingValues(0.dp),
            shape = RoundedCornerShape(FloatingToolbarCornerRadius),
            expandedShadowElevation = 0.dp,
        ) {
            // Subtle gradient accent along the top edge for expressive flair
            Box {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(2.dp)
                        .background(
                            Brush.horizontalGradient(
                                listOf(
                                    CoralRed.copy(alpha = 0.5f),
                                    colorScheme.primary.copy(alpha = 0.6f),
                                    EmeraldMint.copy(alpha = 0.5f),
                                    RosePink.copy(alpha = 0.5f)
                                )
                            )
                        )
                )

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 14.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Delete (Coral / Red)
                    ExpressiveActionButton(
                        icon = Icons.Rounded.DeleteOutline,
                        iconColor = CoralRed,
                        containerColor = CoralRed.copy(alpha = 0.14f),
                        pressedContainerColor = CoralRed.copy(alpha = 0.28f),
                        onClick = onDelete,
                        size = 62.dp
                    )

                    // Undo (Primary / Tonal)
                    ExpressiveActionButton(
                        icon = Icons.AutoMirrored.Rounded.Undo,
                        iconColor = if (canUndo) colorScheme.primary else colorScheme.onSurfaceVariant.copy(alpha = 0.38f),
                        containerColor = if (canUndo) colorScheme.primaryContainer else colorScheme.surfaceContainerHigh,
                        pressedContainerColor = if (canUndo) colorScheme.primaryContainer.copy(alpha = 0.8f) else colorScheme.surfaceContainerHigh,
                        enabled = canUndo,
                        onClick = onUndo,
                        size = 54.dp
                    )

                    // Keep (Emerald / Green & Long-Click to view kept photos)
                    ExpressiveActionButton(
                        icon = Icons.Rounded.Check,
                        iconColor = EmeraldMint,
                        containerColor = EmeraldMint.copy(alpha = 0.14f),
                        pressedContainerColor = EmeraldMint.copy(alpha = 0.28f),
                        onClick = onKeep,
                        onLongClick = onKeepLongClick,
                        size = 62.dp
                    )

                    // Favorite (Rose / Pink with badge & Long-Click to open Favorites)
                    Box(contentAlignment = Alignment.TopEnd) {
                        ExpressiveActionButton(
                            icon = Icons.Rounded.Favorite,
                            iconColor = RosePink,
                            containerColor = RosePink.copy(alpha = 0.14f),
                            pressedContainerColor = RosePink.copy(alpha = 0.28f),
                            onClick = onFavorite,
                            onLongClick = onFavoriteLongClick,
                            size = 56.dp
                        )

                        if (favoritesCount > 0) {
                            Badge(
                                containerColor = RosePink,
                                contentColor = Color.White,
                                modifier = Modifier.padding(top = 2.dp, end = 2.dp)
                            ) {
                                Text(
                                    text = "$favoritesCount",
                                    fontSize = 10.sp,
                                    fontWeight = androidx.compose.ui.text.font.FontWeight.Bold
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

/**
 * Expressive Action Button with M3 Expressive bouncy spring press feedback.
 *
 * Uses MotionScheme.expressive() spring physics (inherited from MaterialExpressiveTheme)
 * for natural overshoot when pressed and released. Includes haptic feedback for tactile response.
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun ExpressiveActionButton(
    icon: ImageVector,
    iconColor: Color,
    containerColor: Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    pressedContainerColor: Color = containerColor,
    onLongClick: (() -> Unit)? = null,
    size: androidx.compose.ui.unit.Dp = 56.dp,
    enabled: Boolean = true
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val haptics = LocalHapticFeedback.current

    // M3 Expressive: Bouncy spring scale with natural overshoot
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.85f else 1.0f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium
        ),
        label = "expressive_button_scale"
    )

    // M3 Expressive: Icon scale pops up slightly on release (overshoot)
    val iconScale by animateFloatAsState(
        targetValue = if (isPressed) 0.80f else 1.0f,
        animationSpec = spring(
            dampingRatio = 0.45f, // Playful bounce
            stiffness = 400f
        ),
        label = "expressive_icon_scale"
    )

    Box(
        modifier = modifier
            .scale(scale)
            .size(size)
            .clip(RoundedCornerShape(ButtonCornerRadius))
            .background(if (isPressed) pressedContainerColor else containerColor)
            .combinedClickable(
                interactionSource = interactionSource,
                indication = ripple(),
                enabled = enabled,
                onClick = {
                    haptics.performHapticFeedback(HapticFeedbackType.LongPress)
                    onClick()
                },
                onLongClick = if (onLongClick != null) {
                    {
                        haptics.performHapticFeedback(HapticFeedbackType.LongPress)
                        onLongClick()
                    }
                } else null
            ),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = iconColor,
            modifier = Modifier
                .size(26.dp)
                .scale(iconScale)
        )
    }
}
