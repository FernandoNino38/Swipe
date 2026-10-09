package com.antigravity.phototriage.photo_triage

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.PhotoLibrary
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.antigravity.phototriage.photo_triage.ui.screens.DeckScreen
import com.antigravity.phototriage.photo_triage.ui.screens.FavoritesScreen
import com.antigravity.phototriage.photo_triage.ui.screens.ReviewScreen
import com.antigravity.phototriage.photo_triage.ui.screens.SettingsScreen
import com.antigravity.phototriage.photo_triage.ui.theme.ElectricBlue
import com.antigravity.phototriage.photo_triage.ui.theme.FloatingToolbarCornerRadius
import com.antigravity.phototriage.photo_triage.ui.theme.SwipeTheme
import com.antigravity.phototriage.photo_triage.ui.viewmodel.TriageViewModel

class MainActivity : ComponentActivity() {

    private val viewModel: TriageViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val imageLoader = coil.ImageLoader.Builder(this)
            .memoryCachePolicy(coil.request.CachePolicy.ENABLED)
            .memoryCache {
                coil.memory.MemoryCache.Builder(this)
                    .maxSizePercent(0.25)
                    .strongReferencesEnabled(true)
                    .build()
            }
            .diskCachePolicy(coil.request.CachePolicy.DISABLED)
            .crossfade(true)
            .build()
        coil.Coil.setImageLoader(imageLoader)

        setContent {
            val uiState by viewModel.uiState.collectAsState()

            SwipeTheme(themeMode = uiState.themeMode) {
                var hasPermission by remember { mutableStateOf(checkMediaPermission()) }

                val permissionLauncher = rememberLauncherForActivityResult(
                    contract = ActivityResultContracts.RequestMultiplePermissions()
                ) { permissions ->
                    hasPermission = permissions.values.any { it }
                    if (hasPermission) {
                        viewModel.loadInitialData()
                    }
                }

                // M3 Expressive: Animated content transition between permission and main app
                AnimatedContent(
                    targetState = hasPermission,
                    transitionSpec = {
                        (fadeIn(animationSpec = spring(stiffness = Spring.StiffnessMediumLow)) +
                                scaleIn(initialScale = 0.92f, animationSpec = spring(
                                    dampingRatio = Spring.DampingRatioMediumBouncy,
                                    stiffness = Spring.StiffnessMediumLow
                                ))).togetherWith(
                            fadeOut(animationSpec = spring(stiffness = Spring.StiffnessMedium))
                        )
                    },
                    label = "permission_content"
                ) { granted ->
                    if (!granted) {
                        PermissionRequestScreen(
                            onRequestPermission = {
                                val permissionsToRequest = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                                    arrayOf(
                                        Manifest.permission.READ_MEDIA_IMAGES,
                                        Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED
                                    )
                                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                    arrayOf(Manifest.permission.READ_MEDIA_IMAGES)
                                } else {
                                    arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
                                }
                                permissionLauncher.launch(permissionsToRequest)
                            }
                        )
                    } else {
                        val navController = rememberNavController()

                        NavHost(
                            navController = navController,
                            startDestination = "deck",
                            enterTransition = { androidx.compose.animation.slideInHorizontally(spring(stiffness = Spring.StiffnessMediumLow)) { it / 4 } + fadeIn() },
                            exitTransition = { androidx.compose.animation.slideOutHorizontally(spring(stiffness = Spring.StiffnessMediumLow)) { -it / 6 } + fadeOut() },
                            popEnterTransition = { androidx.compose.animation.slideInHorizontally(spring(stiffness = Spring.StiffnessMediumLow)) { -it / 6 } + fadeIn() },
                            popExitTransition = { androidx.compose.animation.slideOutHorizontally(spring(stiffness = Spring.StiffnessMediumLow)) { it / 4 } + fadeOut() }
                        ) {
                            composable("deck") {
                                DeckScreen(
                                    viewModel = viewModel,
                                    onNavigateToTrash = { navController.navigate("review") },
                                    onNavigateToSettings = { navController.navigate("settings") },
                                    onNavigateToFavorites = { navController.navigate("favorites") },
                                    onNavigateToKept = { navController.navigate("kept") }
                                )
                            }
                            composable("review") {
                                ReviewScreen(
                                    viewModel = viewModel,
                                    onBack = { navController.popBackStack() }
                                )
                            }
                            composable("favorites") {
                                FavoritesScreen(
                                    viewModel = viewModel,
                                    onBack = { navController.popBackStack() }
                                )
                            }
                            composable("kept") {
                                com.antigravity.phototriage.photo_triage.ui.screens.KeptPhotosScreen(
                                    viewModel = viewModel,
                                    onBack = { navController.popBackStack() }
                                )
                            }
                            composable("settings") {
                                SettingsScreen(
                                    viewModel = viewModel,
                                    onBack = { navController.popBackStack() }
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private fun checkMediaPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_MEDIA_IMAGES) == PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED) == PackageManager.PERMISSION_GRANTED
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_MEDIA_IMAGES) == PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        }
    }
}

/**
 * Material 3 Expressive Permission Request Screen
 *
 * Features:
 * - Hero-sized gradient icon container with spring-based breathing animation
 * - Expressive typography with emphasized styles
 * - Pill-shaped CTA button with colored shadow
 * - Warm descriptive copy with M3 tonal hierarchy
 */
@Composable
fun PermissionRequestScreen(onRequestPermission: () -> Unit) {
    // M3 Expressive: Gentle breathing animation for the hero icon
    val breathingScale by animateFloatAsState(
        targetValue = 1f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessLow
        ),
        label = "icon_breathing"
    )

    Scaffold { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(32.dp),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // M3 Expressive: Hero gradient icon container
                Surface(
                    shape = RoundedCornerShape(32.dp),
                    color = Color.Transparent,
                    modifier = Modifier
                        .size(96.dp)
                        .scale(breathingScale)
                        .shadow(
                            elevation = 16.dp,
                            shape = RoundedCornerShape(32.dp),
                            spotColor = ElectricBlue.copy(alpha = 0.3f)
                        )
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(
                                Brush.linearGradient(
                                    listOf(
                                        MaterialTheme.colorScheme.primaryContainer,
                                        MaterialTheme.colorScheme.primary.copy(alpha = 0.3f)
                                    )
                                )
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Rounded.PhotoLibrary,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.size(44.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(28.dp))

                // M3 Expressive: Bold headline
                Text(
                    text = "Permission Required",
                    style = MaterialTheme.typography.headlineSmall.copy(
                        fontWeight = FontWeight.Black,
                        letterSpacing = (-0.5).sp
                    )
                )

                Spacer(modifier = Modifier.height(12.dp))

                // M3 Expressive: Warm descriptive body text
                Text(
                    text = "Swipe needs photo access to help you triage and organize your gallery.",
                    style = MaterialTheme.typography.bodyLarge.copy(
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        lineHeight = 24.sp
                    ),
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(horizontal = 8.dp)
                )

                Spacer(modifier = Modifier.height(32.dp))

                // M3 Expressive: Pill button with colored shadow
                Button(
                    onClick = onRequestPermission,
                    shape = RoundedCornerShape(FloatingToolbarCornerRadius),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.primary,
                        contentColor = MaterialTheme.colorScheme.onPrimary
                    ),
                    elevation = ButtonDefaults.buttonElevation(
                        defaultElevation = 8.dp,
                        pressedElevation = 2.dp
                    ),
                    modifier = Modifier
                        .fillMaxWidth(0.85f)
                        .height(56.dp)
                        .shadow(
                            elevation = 12.dp,
                            shape = RoundedCornerShape(FloatingToolbarCornerRadius),
                            spotColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.3f)
                        )
                ) {
                    Text(
                        text = "Grant Permission",
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            letterSpacing = (-0.2).sp
                        )
                    )
                }
            }
        }
    }
}
