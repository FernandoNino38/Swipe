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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.antigravity.phototriage.photo_triage.ui.theme.ButtonCornerRadius
import com.antigravity.phototriage.photo_triage.ui.theme.CoralRed
import com.antigravity.phototriage.photo_triage.ui.theme.EmeraldMint
import com.antigravity.phototriage.photo_triage.ui.theme.RosePink
import com.antigravity.phototriage.photo_triage.ui.theme.SheetCornerRadius

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

    Surface(
        modifier = modifier
            .fillMaxWidth()
            .shadow(20.dp, RoundedCornerShape(topStart = SheetCornerRadius, topEnd = SheetCornerRadius)),
        color = colorScheme.surfaceContainer.copy(alpha = 0.96f),
        shape = RoundedCornerShape(topStart = SheetCornerRadius, topEnd = SheetCornerRadius)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .navigationBarsPadding()
                .padding(horizontal = 20.dp, vertical = 20.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Delete (Coral / Red)
            ExpressiveActionButton(
                icon = Icons.Rounded.DeleteOutline,
                iconColor = CoralRed,
                containerColor = CoralRed.copy(alpha = 0.16f),
                onClick = onDelete,
                size = 62.dp
            )

            // Undo (Primary / Tonal)
            ExpressiveActionButton(
                icon = Icons.AutoMirrored.Rounded.Undo,
                iconColor = if (canUndo) colorScheme.primary else colorScheme.onSurfaceVariant.copy(alpha = 0.38f),
                containerColor = if (canUndo) colorScheme.primaryContainer else colorScheme.surfaceContainerHigh,
                enabled = canUndo,
                onClick = onUndo,
                size = 54.dp
            )

            // Keep (Emerald / Green & Long-Click to view kept photos)
            ExpressiveActionButton(
                icon = Icons.Rounded.Check,
                iconColor = EmeraldMint,
                containerColor = EmeraldMint.copy(alpha = 0.16f),
                onClick = onKeep,
                onLongClick = onKeepLongClick,
                size = 62.dp
            )

            // Favorite (Rose / Pink with badge & Long-Click to open Favorites)
            Box(contentAlignment = Alignment.TopEnd) {
                ExpressiveActionButton(
                    icon = Icons.Rounded.Favorite,
                    iconColor = RosePink,
                    containerColor = RosePink.copy(alpha = 0.16f),
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

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun ExpressiveActionButton(
    icon: ImageVector,
    iconColor: Color,
    containerColor: Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    onLongClick: (() -> Unit)? = null,
    size: androidx.compose.ui.unit.Dp = 56.dp,
    enabled: Boolean = true
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val haptics = LocalHapticFeedback.current

    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.88f else 1.0f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium
        ),
        label = "button_scale"
    )

    Box(
        modifier = modifier
            .scale(scale)
            .size(size)
            .clip(RoundedCornerShape(ButtonCornerRadius))
            .background(containerColor)
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
            modifier = Modifier.size(26.dp)
        )
    }
}
