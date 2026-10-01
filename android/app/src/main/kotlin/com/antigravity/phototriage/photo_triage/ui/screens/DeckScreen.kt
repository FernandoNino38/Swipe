package com.antigravity.phototriage.photo_triage.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material.icons.rounded.DeleteOutline
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.KeyboardArrowDown
import androidx.compose.material.icons.rounded.OpenInNew
import androidx.compose.material.icons.rounded.PhotoLibrary
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.antigravity.phototriage.photo_triage.domain.model.GalleryAlbum
import com.antigravity.phototriage.photo_triage.domain.model.TriageItem
import com.antigravity.phototriage.photo_triage.ui.components.M3ExpressiveLoadingIndicator
import com.antigravity.phototriage.photo_triage.ui.components.QuickActionsBar
import com.antigravity.phototriage.photo_triage.ui.components.TriageCard
import com.antigravity.phototriage.photo_triage.ui.theme.ChipCornerRadius
import com.antigravity.phototriage.photo_triage.ui.theme.CoralRed
import com.antigravity.phototriage.photo_triage.ui.theme.DialogCornerRadius
import com.antigravity.phototriage.photo_triage.ui.theme.PillCornerRadius
import com.antigravity.phototriage.photo_triage.ui.viewmodel.TriageUiState
import com.antigravity.phototriage.photo_triage.ui.viewmodel.TriageViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DeckScreen(
    viewModel: TriageViewModel,
    onNavigateToTrash: () -> Unit,
    onNavigateToSettings: () -> Unit,
    onNavigateToFavorites: () -> Unit,
    onNavigateToKept: () -> Unit,
    modifier: Modifier = Modifier
) {
    val uiState by viewModel.uiState.collectAsState()
    var showAlbumSheet by remember { mutableStateOf(false) }
    var selectedDetailItem by remember { mutableStateOf<TriageItem?>(null) }
    var cardAnimateTrigger by remember { mutableStateOf<String?>(null) }
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(Unit) {
        viewModel.loadInitialData()
    }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbarHostState) },
        topBar = {
            TopAppBar(
                title = {
                    Column(modifier = Modifier.padding(start = 4.dp)) {
                        Text(
                            text = "Swipe",
                            style = MaterialTheme.typography.headlineLarge.copy(
                                fontWeight = androidx.compose.ui.text.font.FontWeight.Black,
                                fontSize = 32.sp,
                                letterSpacing = (-1.2).sp,
                                brush = androidx.compose.ui.graphics.Brush.horizontalGradient(
                                    colors = listOf(
                                        MaterialTheme.colorScheme.primary,
                                        MaterialTheme.colorScheme.tertiary
                                    )
                                )
                            )
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        // Album selection chip
                        Surface(
                            shape = RoundedCornerShape(ChipCornerRadius),
                            color = MaterialTheme.colorScheme.surfaceContainerHigh,
                            modifier = Modifier
                                .clip(RoundedCornerShape(ChipCornerRadius))
                                .clickable { showAlbumSheet = true }
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Rounded.PhotoLibrary,
                                    contentDescription = null,
                                    tint = MaterialTheme.colorScheme.primary,
                                    modifier = Modifier.size(14.dp)
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = uiState.selectedAlbum?.name ?: "All Photos",
                                    style = MaterialTheme.typography.labelMedium.copy(
                                        fontWeight = androidx.compose.ui.text.font.FontWeight.Bold,
                                        fontSize = 12.sp
                                    )
                                )
                                Spacer(modifier = Modifier.width(2.dp))
                                Icon(
                                    imageVector = Icons.Rounded.KeyboardArrowDown,
                                    contentDescription = null,
                                    modifier = Modifier.size(16.dp)
                                )
                            }
                        }
                    }
                },
                actions = {
                    // Trash Review action with Badge
                    FilledTonalIconButton(
                        onClick = onNavigateToTrash,
                        colors = IconButtonDefaults.filledTonalIconButtonColors(
                            containerColor = MaterialTheme.colorScheme.surfaceContainerHigh
                        )
                    ) {
                        BadgedBox(
                            badge = {
                                if (uiState.softDeleteQueue.isNotEmpty()) {
                                    Badge(
                                        containerColor = CoralRed,
                                        contentColor = Color.White
                                    ) {
                                        Text("${uiState.softDeleteQueue.size}", fontWeight = androidx.compose.ui.text.font.FontWeight.Bold)
                                    }
                                }
                            }
                        ) {
                            Icon(Icons.Rounded.DeleteOutline, contentDescription = "Trash Review")
                        }
                    }

                    Spacer(modifier = Modifier.width(8.dp))

                    // Settings action
                    FilledTonalIconButton(
                        onClick = onNavigateToSettings,
                        colors = IconButtonDefaults.filledTonalIconButtonColors(
                            containerColor = MaterialTheme.colorScheme.surfaceContainerHigh
                        )
                    ) {
                        Icon(Icons.Outlined.Settings, contentDescription = "Settings")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.Transparent)
            )
        },
        bottomBar = {
            QuickActionsBar(
                canUndo = uiState.canUndo,
                favoritesCount = uiState.favoriteItems.size,
                onDelete = {
                    if (cardAnimateTrigger == null && uiState.currentItem != null) {
                        cardAnimateTrigger = "LEFT"
                    }
                },
                onUndo = { viewModel.undo() },
                onKeep = {
                    if (cardAnimateTrigger == null && uiState.currentItem != null) {
                        cardAnimateTrigger = "RIGHT"
                    }
                },
                onKeepLongClick = onNavigateToKept,
                onFavorite = {
                    if (cardAnimateTrigger == null && uiState.currentItem != null) {
                        cardAnimateTrigger = "FAVORITE"
                    }
                },
                onFavoriteLongClick = onNavigateToFavorites
            )
        },
        containerColor = MaterialTheme.colorScheme.surface
    ) { innerPadding ->
        Box(
            modifier = modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentAlignment = Alignment.Center
        ) {
            when {
                uiState.isLoading -> {
                    M3ExpressiveLoadingIndicator(size = 56.dp, message = "Loading gallery photos...")
                }
                !uiState.hasMoreCards -> {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.padding(32.dp)
                    ) {
                        Text(
                            text = "All caught up!",
                            style = MaterialTheme.typography.headlineSmall.copy(
                                fontWeight = androidx.compose.ui.text.font.FontWeight.Bold
                            )
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "All photos in this album have been reviewed.",
                            style = MaterialTheme.typography.bodyMedium.copy(
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        )
                        Spacer(modifier = Modifier.height(20.dp))
                        FilledTonalButton(onClick = { viewModel.reloadPhotos() }) {
                            Text("Review Again")
                        }
                    }
                }
                else -> {
                    // Card Stack: Card N+1 underneath, Card N on top
                    Box(modifier = Modifier.fillMaxSize()) {
                        uiState.nextItem?.let { next ->
                            TriageCard(
                                item = next,
                                isTopCard = false,
                                isFitMode = uiState.isFitMode,
                                lang = uiState.appLanguage,
                                animateTrigger = null,
                                onSwipeRight = {},
                                onSwipeLeft = {},
                                onTapDetail = {},
                                onToggleFitMode = {},
                                modifier = Modifier.fillMaxSize()
                            )
                        }

                        uiState.currentItem?.let { current ->
                            TriageCard(
                                item = current,
                                isTopCard = true,
                                isFitMode = uiState.isFitMode,
                                lang = uiState.appLanguage,
                                animateTrigger = cardAnimateTrigger,
                                onSwipeRight = {
                                    cardAnimateTrigger = null
                                    viewModel.swipeRight()
                                },
                                onSwipeLeft = {
                                    cardAnimateTrigger = null
                                    viewModel.swipeLeft()
                                },
                                onFavorite = {
                                    cardAnimateTrigger = null
                                    viewModel.favoriteCurrentPhoto()
                                },
                                onTapDetail = { selectedDetailItem = current },
                                onToggleFitMode = { viewModel.toggleFitMode() },
                                modifier = Modifier.fillMaxSize()
                            )
                        }
                    }
                }
            }
        }
    }

    // Modal Bottom Sheet for Album Selection
    if (showAlbumSheet) {
        AlbumSelectionModalSheet(
            albums = uiState.albums,
            selectedAlbum = uiState.selectedAlbum,
            onSelect = {
                viewModel.selectAlbum(it)
                showAlbumSheet = false
            },
            onDismiss = { showAlbumSheet = false }
        )
    }

    // Favorite First-Time Guide Dialog
    if (uiState.showFavoriteGuideDialog) {
        AlertDialog(
            onDismissRequest = { viewModel.dismissFavoriteGuide() },
            icon = {
                Surface(
                    shape = RoundedCornerShape(14.dp),
                    color = com.antigravity.phototriage.photo_triage.ui.theme.RosePink,
                    modifier = Modifier.size(48.dp)
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(
                            imageVector = Icons.Rounded.KeyboardArrowDown,
                            contentDescription = null,
                            tint = Color.White
                        )
                    }
                }
            },
            title = {
                Text(
                    text = "Favorited!",
                    style = MaterialTheme.typography.titleLarge.copy(
                        fontWeight = androidx.compose.ui.text.font.FontWeight.Bold
                    )
                )
            },
            text = {
                Text(
                    text = "Photo marked as favorite and synced with your system gallery!\n\nTip: Press and hold the Heart button at any time to open your Favorites list.",
                    style = MaterialTheme.typography.bodyMedium
                )
            },
            confirmButton = {
                Button(onClick = { viewModel.dismissFavoriteGuide() }) {
                    Text("Got it")
                }
            }
        )
    }

    // Photo Detail Dialog
    selectedDetailItem?.let { item ->
        PhotoDetailModalDialog(
            item = item,
            onDismiss = { selectedDetailItem = null },
            onOpenInFiles = { path -> viewModel.openInFileManager(path) }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlbumSelectionModalSheet(
    albums: List<GalleryAlbum>,
    selectedAlbum: GalleryAlbum?,
    onSelect: (GalleryAlbum) -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 8.dp)
        ) {
            Text(
                text = "Select Album",
                style = MaterialTheme.typography.titleLarge.copy(
                    fontWeight = androidx.compose.ui.text.font.FontWeight.ExtraBold
                )
            )
            Spacer(modifier = Modifier.height(14.dp))
            albums.forEach { album ->
                val isSelected = album.id == selectedAlbum?.id
                Surface(
                    shape = RoundedCornerShape(16.dp),
                    color = if (isSelected) MaterialTheme.colorScheme.primaryContainer else Color.Transparent,
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(16.dp))
                        .clickable { onSelect(album) }
                        .padding(vertical = 4.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Rounded.PhotoLibrary,
                            contentDescription = null,
                            tint = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Spacer(modifier = Modifier.width(14.dp))
                        Text(
                            text = album.name,
                            style = MaterialTheme.typography.bodyLarge.copy(
                                fontWeight = if (isSelected) androidx.compose.ui.text.font.FontWeight.Bold else androidx.compose.ui.text.font.FontWeight.Normal
                            ),
                            modifier = Modifier.weight(1f)
                        )
                        Text(
                            text = "${album.assetCount}",
                            style = MaterialTheme.typography.labelMedium.copy(
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        )
                    }
                }
            }
            Spacer(modifier = Modifier.height(28.dp))
        }
    }
}

@Composable
fun PhotoDetailModalDialog(
    item: TriageItem,
    onDismiss: () -> Unit,
    onOpenInFiles: (String) -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        icon = {
            Surface(
                shape = RoundedCornerShape(16.dp),
                color = MaterialTheme.colorScheme.primaryContainer,
                modifier = Modifier.size(52.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = Icons.Rounded.Info,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(28.dp)
                    )
                }
            }
        },
        title = {
            Text(
                text = item.title,
                style = MaterialTheme.typography.titleLarge.copy(
                    fontWeight = FontWeight.Bold,
                    fontSize = 20.sp
                ),
                maxLines = 2,
                overflow = androidx.compose.ui.text.style.TextOverflow.Ellipsis
            )
        },
        text = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Surface(
                    shape = RoundedCornerShape(16.dp),
                    color = MaterialTheme.colorScheme.surfaceContainerHigh,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(14.dp),
                        verticalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        DetailRow(label = "Date", value = "${item.formattedDate} · ${item.formattedTime}")
                        DetailRow(label = "Size", value = item.formattedSize)
                        DetailRow(label = "Resolution", value = item.formattedResolution)
                        if (item.ratioLabel.isNotEmpty()) {
                            DetailRow(label = "Aspect Ratio", value = item.ratioLabel)
                        }
                    }
                }

                if (!item.filePath.isNullOrEmpty()) {
                    Surface(
                        shape = RoundedCornerShape(12.dp),
                        color = MaterialTheme.colorScheme.surfaceContainerHighest.copy(alpha = 0.6f),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(
                            text = item.filePath,
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.8f),
                                fontSize = 11.sp
                            ),
                            modifier = Modifier.padding(10.dp)
                        )
                    }
                }
            }
        },
        confirmButton = {
            if (!item.filePath.isNullOrEmpty()) {
                Button(
                    onClick = { onOpenInFiles(item.filePath) },
                    shape = RoundedCornerShape(PillCornerRadius),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.primary
                    )
                ) {
                    Icon(Icons.Rounded.OpenInNew, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(6.dp))
                    Text("Show on Gallery", fontWeight = FontWeight.Bold)
                }
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Close", fontWeight = FontWeight.SemiBold)
            }
        },
        shape = RoundedCornerShape(DialogCornerRadius)
    )
}

@Composable
private fun DetailRow(label: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.bodyMedium.copy(
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                fontWeight = FontWeight.Medium
            )
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium.copy(
                fontWeight = FontWeight.Bold
            )
        )
    }
}
