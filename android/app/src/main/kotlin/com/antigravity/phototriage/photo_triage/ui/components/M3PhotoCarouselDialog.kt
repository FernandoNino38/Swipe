package com.antigravity.phototriage.photo_triage.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material3.carousel.HorizontalMultiBrowseCarousel
import androidx.compose.material3.carousel.rememberCarouselState
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.DeleteOutline
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.OpenInNew
import androidx.compose.material3.*

import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.util.lerp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.antigravity.phototriage.photo_triage.domain.model.TriageItem
import com.antigravity.phototriage.photo_triage.ui.screens.PhotoDetailModalDialog
import com.antigravity.phototriage.photo_triage.ui.theme.CarouselItemCornerRadius
import com.antigravity.phototriage.photo_triage.ui.theme.FloatingToolbarCornerRadius
import com.antigravity.phototriage.photo_triage.ui.theme.OverlayPillCornerRadius
import kotlin.math.absoluteValue

/**
 * Material 3 Multi-Browse Carousel conforming to https://m3.material.io/components/carousel/overview.
 * Displays items with dynamic scale and peek effect, allows viewing photo info, and provides
 * a "Show on Gallery" action button.
 */

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun M3PhotoCarouselDialog(
    items: List<TriageItem>,
    initialIndex: Int = 0,
    removeActionLabel: String? = null,
    onRemoveItem: ((TriageItem) -> Unit)? = null,
    onDismiss: () -> Unit,
    onOpenInGallery: (String) -> Unit
) {
    if (items.isEmpty()) {
        onDismiss()
        return
    }

    val safeInitial = initialIndex.coerceIn(0, items.lastIndex)
    val carouselState = rememberCarouselState(initialItem = safeInitial) { items.size }
    var showDetailSheet by remember { mutableStateOf(false) }
    val currentPage = carouselState.currentItem
    val currentItem = items.getOrNull(currentPage)

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(
            usePlatformDefaultWidth = false,
            decorFitsSystemWindows = false
        )
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFF090A0F)) // Expressive deep OLED dark canvas
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .systemBarsPadding()
            ) {
                // Top App Bar Controls Floating Island
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 18.dp, vertical = 12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    FilledTonalIconButton(
                        onClick = onDismiss,
                        colors = IconButtonDefaults.filledTonalIconButtonColors(
                            containerColor = Color.White.copy(alpha = 0.15f),
                            contentColor = Color.White
                        ),
                        modifier = Modifier.size(44.dp)
                    ) {
                        Icon(Icons.Rounded.Close, contentDescription = "Close", modifier = Modifier.size(20.dp))
                    }

                    // Indicator Pill with Expressive typography
                    Surface(
                        shape = RoundedCornerShape(OverlayPillCornerRadius),
                        color = Color.White.copy(alpha = 0.15f),
                        shadowElevation = 4.dp
                    ) {
                        Text(
                            text = "${currentPage + 1} / ${items.size}",
                            color = Color.White,
                            style = MaterialTheme.typography.labelLarge.copy(
                                fontWeight = FontWeight.ExtraBold,
                                letterSpacing = 0.5.sp
                            ),
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                        )
                    }

                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        // Remove button if action provided
                        if (onRemoveItem != null && currentItem != null) {
                            FilledTonalIconButton(
                                onClick = {
                                    onRemoveItem(currentItem)
                                    if (items.size <= 1) {
                                        onDismiss()
                                    }
                                },
                                colors = IconButtonDefaults.filledTonalIconButtonColors(
                                    containerColor = Color.White.copy(alpha = 0.15f),
                                    contentColor = Color.White
                                ),
                                modifier = Modifier.size(44.dp)
                            ) {
                                Icon(
                                    Icons.Rounded.DeleteOutline,
                                    contentDescription = removeActionLabel ?: "Remove",
                                    modifier = Modifier.size(20.dp)
                                )
                            }
                        }

                        // Info Button
                        FilledTonalIconButton(
                            onClick = { showDetailSheet = true },
                            colors = IconButtonDefaults.filledTonalIconButtonColors(
                                containerColor = Color.White.copy(alpha = 0.15f),
                                contentColor = Color.White
                            ),
                            modifier = Modifier.size(44.dp)
                        ) {
                            Icon(Icons.Rounded.Info, contentDescription = "Photo Details", modifier = Modifier.size(20.dp))
                        }
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                // Official Material 3 Carousel (multi-browse): one large photo with peeking neighbours
                HorizontalMultiBrowseCarousel(
                    state = carouselState,
                    preferredItemWidth = (LocalConfiguration.current.screenWidthDp * 0.82f).dp,
                    itemSpacing = 12.dp,
                    contentPadding = PaddingValues(horizontal = 20.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f)
                ) { page ->
                    val item = items[page]

                    Box(
                        modifier = Modifier
                            .fillMaxHeight()
                            .maskClip(RoundedCornerShape(CarouselItemCornerRadius))
                            .background(Color(0xFF141720)),
                        contentAlignment = Alignment.Center
                    ) {
                        AsyncImage(
                            model = ImageRequest.Builder(LocalContext.current)
                                .data(item.contentUri)
                                .crossfade(true)
                                .build(),
                            contentDescription = item.title,
                            contentScale = ContentScale.Fit,
                            modifier = Modifier.fillMaxSize()
                        )

                        // Floating bottom gradient with photo metadata chip
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(64.dp)
                                .align(Alignment.BottomCenter)
                                .background(
                                    Brush.verticalGradient(
                                        listOf(Color.Transparent, Color.Black.copy(alpha = 0.7f))
                                    )
                                )
                        )

                        // Bottom-start resolution & size badges
                        Row(
                            modifier = Modifier
                                .align(Alignment.BottomStart)
                                .padding(14.dp),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Surface(
                                shape = RoundedCornerShape(8.dp),
                                color = Color.Black.copy(alpha = 0.6f)
                            ) {
                                Text(
                                    text = item.formattedSize,
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        color = Color.White,
                                        fontWeight = FontWeight.Bold
                                    ),
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                                )
                            }
                            if (item.ratioLabel.isNotEmpty()) {
                                Surface(
                                    shape = RoundedCornerShape(8.dp),
                                    color = Color.Black.copy(alpha = 0.6f)
                                ) {
                                    Text(
                                        text = item.ratioLabel,
                                        style = MaterialTheme.typography.labelSmall.copy(
                                            color = Color.White,
                                            fontWeight = FontWeight.Bold
                                        ),
                                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                                    )
                                }
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(18.dp))

                // Subtle bottom gradient accent behind the action bar
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(
                            Brush.verticalGradient(
                                listOf(
                                    Color.Transparent,
                                    MaterialTheme.colorScheme.primary.copy(alpha = 0.06f)
                                )
                            )
                        )
                ) {
                    // Bottom Action Bar: "Show on Gallery" with pill shape and expressive elevation
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 24.dp, vertical = 16.dp),
                        horizontalArrangement = Arrangement.Center
                    ) {
                        Button(
                            onClick = {
                                val path = currentItem?.filePath
                                if (!path.isNullOrEmpty()) {
                                    onOpenInGallery(path)
                                }
                            },
                            shape = RoundedCornerShape(FloatingToolbarCornerRadius),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = MaterialTheme.colorScheme.primary,
                                contentColor = MaterialTheme.colorScheme.onPrimary
                            ),
                            elevation = ButtonDefaults.buttonElevation(defaultElevation = 8.dp, pressedElevation = 2.dp),
                            modifier = Modifier
                                .fillMaxWidth(0.92f)
                                .height(58.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Rounded.OpenInNew,
                                contentDescription = null,
                                modifier = Modifier.size(22.dp)
                            )
                            Spacer(modifier = Modifier.width(10.dp))
                            Text(
                                text = "Show on Gallery",
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 16.sp
                                )
                            )
                        }
                    }
                }
            }
        }
    }

    // Detail Info Modal Bottom Sheet / Dialog
    if (showDetailSheet && currentItem != null) {
        PhotoDetailModalDialog(
            item = currentItem,
            onDismiss = { showDetailSheet = false },
            onOpenInFiles = { path -> onOpenInGallery(path) }
        )
    }
}
