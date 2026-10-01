package com.antigravity.phototriage.photo_triage.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
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
import kotlin.math.absoluteValue

/**
 * Material 3 Multi-Browse Carousel conforming to https://m3.material.io/components/carousel/overview.
 * Displays items with dynamic scale and peek effect, allows viewing photo info, and provides
 * a "Show on Gallery" action button.
 */
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
    val pagerState = rememberPagerState(
        initialPage = safeInitial,
        pageCount = { items.size }
    )
    var showDetailSheet by remember { mutableStateOf(false) }
    val currentItem = items.getOrNull(pagerState.currentPage)

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
                .background(Color.Black)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .systemBarsPadding()
            ) {
                // Top App Bar Controls
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    IconButton(
                        onClick = onDismiss,
                        colors = IconButtonDefaults.iconButtonColors(
                            containerColor = Color.White.copy(alpha = 0.2f),
                            contentColor = Color.White
                        )
                    ) {
                        Icon(Icons.Rounded.Close, contentDescription = "Close")
                    }

                    // Indicator Pill
                    Surface(
                        shape = CircleShape,
                        color = Color.White.copy(alpha = 0.2f)
                    ) {
                        Text(
                            text = "${pagerState.currentPage + 1} / ${items.size}",
                            color = Color.White,
                            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
                            modifier = Modifier.padding(horizontal = 14.dp, vertical = 6.dp)
                        )
                    }

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        // Remove button if action provided
                        if (onRemoveItem != null && currentItem != null) {
                            IconButton(
                                onClick = {
                                    onRemoveItem(currentItem)
                                    if (items.size <= 1) {
                                        onDismiss()
                                    }
                                },
                                colors = IconButtonDefaults.iconButtonColors(
                                    containerColor = Color.White.copy(alpha = 0.2f),
                                    contentColor = Color.White
                                )
                            ) {
                                Icon(
                                    Icons.Rounded.DeleteOutline,
                                    contentDescription = removeActionLabel ?: "Remove"
                                )
                            }
                            Spacer(modifier = Modifier.width(8.dp))
                        }

                        // Info Button
                        IconButton(
                            onClick = { showDetailSheet = true },
                            colors = IconButtonDefaults.iconButtonColors(
                                containerColor = Color.White.copy(alpha = 0.2f),
                                contentColor = Color.White
                            )
                        ) {
                            Icon(Icons.Rounded.Info, contentDescription = "Photo Details")
                        }
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                // Material 3 Carousel Multi-browse with edge peek and scale
                HorizontalPager(
                    state = pagerState,
                    contentPadding = PaddingValues(horizontal = 40.dp),
                    pageSpacing = 16.dp,
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f)
                ) { page ->
                    val pageOffset = ((pagerState.currentPage - page) + pagerState.currentPageOffsetFraction).absoluteValue

                    // M3 motion calculation for peek items: scale between 0.86 and 1.0, alpha between 0.6 and 1.0
                    val scale = lerp(
                        start = 0.86f,
                        stop = 1f,
                        fraction = 1f - pageOffset.coerceIn(0f, 1f)
                    )
                    val alpha = lerp(
                        start = 0.55f,
                        stop = 1f,
                        fraction = 1f - pageOffset.coerceIn(0f, 1f)
                    )

                    val item = items[page]

                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .graphicsLayer {
                                scaleX = scale
                                scaleY = scale
                                this.alpha = alpha
                            }
                            .clip(RoundedCornerShape(28.dp))
                            .background(Color.DarkGray),
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
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Bottom Action Bar: "Show on Gallery"
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
                        shape = RoundedCornerShape(com.antigravity.phototriage.photo_triage.ui.theme.PillCornerRadius),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = MaterialTheme.colorScheme.primary,
                            contentColor = MaterialTheme.colorScheme.onPrimary
                        ),
                        elevation = ButtonDefaults.buttonElevation(defaultElevation = 6.dp, pressedElevation = 1.dp),
                        modifier = Modifier
                            .fillMaxWidth(0.9f)
                            .height(56.dp)
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

    // Detail Info Modal Bottom Sheet / Dialog
    if (showDetailSheet && currentItem != null) {
        PhotoDetailModalDialog(
            item = currentItem,
            onDismiss = { showDetailSheet = false },
            onOpenInFiles = { path -> onOpenInGallery(path) }
        )
    }
}
