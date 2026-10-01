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
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.antigravity.phototriage.photo_triage.ui.screens.DeckScreen
import com.antigravity.phototriage.photo_triage.ui.screens.FavoritesScreen
import com.antigravity.phototriage.photo_triage.ui.screens.ReviewScreen
import com.antigravity.phototriage.photo_triage.ui.screens.SettingsScreen
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

                if (!hasPermission) {
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
                        startDestination = "deck"
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

@Composable
fun PermissionRequestScreen(onRequestPermission: () -> Unit) {
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
                Text(
                    text = "Permission Required",
                    style = MaterialTheme.typography.headlineSmall.copy(
                        fontWeight = androidx.compose.ui.text.font.FontWeight.Bold
                    )
                )
                Spacer(modifier = Modifier.height(10.dp))
                Text(
                    text = "Swipe needs photo access to help you triage and organize your gallery.",
                    style = MaterialTheme.typography.bodyMedium.copy(
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    ),
                    textAlign = androidx.compose.ui.text.style.TextAlign.Center
                )
                Spacer(modifier = Modifier.height(24.dp))
                Button(onClick = onRequestPermission) {
                    Text("Grant Permission")
                }
            }
        }
    }
}
