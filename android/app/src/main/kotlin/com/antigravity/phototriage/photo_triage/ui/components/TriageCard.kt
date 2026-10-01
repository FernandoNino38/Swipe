package com.antigravity.phototriage.photo_triage.ui.components

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import com.antigravity.phototriage.photo_triage.ui.theme.M3Motion
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.CropFree
import androidx.compose.material.icons.rounded.DeleteOutline
import androidx.compose.material.icons.rounded.Favorite
import androidx.compose.material.icons.rounded.FitScreen
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.antigravity.phototriage.photo_triage.domain.model.TriageItem
import com.antigravity.phototriage.photo_triage.ui.theme.CardCornerRadius
import com.antigravity.phototriage.photo_triage.ui.theme.CoralRed
import com.antigravity.phototriage.photo_triage.ui.theme.EmeraldMint
import com.antigravity.phototriage.photo_triage.ui.theme.PillCornerRadius
import com.antigravity.phototriage.photo_triage.ui.theme.RosePink
import kotlinx.coroutines.launch
import kotlin.math.roundToInt

@Composable
fun TriageCard(
    item: TriageItem,
    isTopCard: Boolean,
    isFitMode: Boolean,
    lang: String = "en",
    animateTrigger: String? = null, // "LEFT", "RIGHT", "FAVORITE"
    onSwipeRight: () -> Unit,
    onSwipeLeft: () -> Unit,
    onFavorite: () -> Unit = {},
    onTapDetail: () -> Unit,
    onToggleFitMode: () -> Unit,
    modifier: Modifier = Modifier
) {
    val coroutineScope = rememberCoroutineScope()
    val offsetX = remember { Animatable(0f) }
    val offsetY = remember { Animatable(0f) }
    val cardScale = remember { Animatable(1f) }

    val cardAlpha = remember { Animatable(1f) }

    val swipeThreshold = 260f
    val currentDx = offsetX.value
    // Smooth dynamic rotation with soft angle limit
    val rotationAngle = (currentDx / 15f).coerceIn(-20f, 20f)

    // Left swipe = negative Dx = Delete action
    val deleteIntensity = ((-currentDx) / swipeThreshold).coerceIn(0f, 1f)
    // Right swipe = positive Dx = Keep action
    val keepIntensity = (currentDx / swipeThreshold).coerceIn(0f, 1f)

    // Programmatic trigger from buttons with smooth Material 3 Expressive exit
    LaunchedEffect(animateTrigger) {
        when (animateTrigger) {
            "LEFT" -> {
                coroutineScope.launch {
                    cardScale.animateTo(
                        targetValue = 0.88f,
                        animationSpec = tween(durationMillis = 260, easing = M3Motion.EmphasizedAccelerate)
                    )
                }
                coroutineScope.launch {
                    cardAlpha.animateTo(
                        targetValue = 0f,
                        animationSpec = tween(durationMillis = 240, easing = M3Motion.EmphasizedAccelerate)
                    )
                }
                offsetX.animateTo(
                    targetValue = -1400f,
                    animationSpec = tween(durationMillis = 280, easing = M3Motion.EmphasizedAccelerate)
                )
                onSwipeLeft()
                cardAlpha.snapTo(1f)
                cardScale.snapTo(1f)
                offsetX.snapTo(0f)
                offsetY.snapTo(0f)
            }
            "RIGHT" -> {
                coroutineScope.launch {
                    cardScale.animateTo(
                        targetValue = 0.88f,
                        animationSpec = tween(durationMillis = 260, easing = M3Motion.EmphasizedAccelerate)
                    )
                }
                coroutineScope.launch {
                    cardAlpha.animateTo(
                        targetValue = 0f,
                        animationSpec = tween(durationMillis = 240, easing = M3Motion.EmphasizedAccelerate)
                    )
                }
                offsetX.animateTo(
                    targetValue = 1400f,
                    animationSpec = tween(durationMillis = 280, easing = M3Motion.EmphasizedAccelerate)
                )
                onSwipeRight()
                cardAlpha.snapTo(1f)
                cardScale.snapTo(1f)
                offsetX.snapTo(0f)
                offsetY.snapTo(0f)
            }
            "FAVORITE" -> {
                // Expressive gentle pop then smooth sweep to right
                cardScale.animateTo(
                    targetValue = 1.05f,
                    animationSpec = spring(
                        dampingRatio = Spring.DampingRatioMediumBouncy,
                        stiffness = Spring.StiffnessMediumLow
                    )
                )
                coroutineScope.launch {
                    cardAlpha.animateTo(
                        targetValue = 0f,
                        animationSpec = tween(durationMillis = 240, easing = M3Motion.EmphasizedAccelerate)
                    )
                }
                offsetX.animateTo(
                    targetValue = 1400f,
                    animationSpec = tween(durationMillis = 280, easing = M3Motion.EmphasizedAccelerate)
                )
                onFavorite()
                cardScale.snapTo(1f)
                cardAlpha.snapTo(1f)
                offsetX.snapTo(0f)
                offsetY.snapTo(0f)
            }
        }
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .padding(horizontal = 12.dp, vertical = 8.dp)
            .scale(cardScale.value)
            .offset { IntOffset(offsetX.value.roundToInt(), offsetY.value.roundToInt()) }
            .graphicsLayer {
                rotationZ = rotationAngle
                alpha = cardAlpha.value
            }
            .pointerInput(isTopCard) {
                if (!isTopCard) return@pointerInput
                detectDragGestures(
                    onDragEnd = {
                        val dx = offsetX.value
                        if (dx > swipeThreshold) {
                            coroutineScope.launch {
                                coroutineScope.launch {
                                    cardAlpha.animateTo(0f, tween(200, easing = M3Motion.EmphasizedAccelerate))
                                }
                                offsetX.animateTo(
                                    targetValue = 1400f,
                                    animationSpec = tween(durationMillis = 250, easing = M3Motion.EmphasizedAccelerate)
                                )
                                onSwipeRight()
                                cardAlpha.snapTo(1f)
                                offsetX.snapTo(0f)
                                offsetY.snapTo(0f)
                            }
                        } else if (dx < -swipeThreshold) {
                            coroutineScope.launch {
                                coroutineScope.launch {
                                    cardAlpha.animateTo(0f, tween(200, easing = M3Motion.EmphasizedAccelerate))
                                }
                                offsetX.animateTo(
                                    targetValue = -1400f,
                                    animationSpec = tween(durationMillis = 250, easing = M3Motion.EmphasizedAccelerate)
                                )
                                onSwipeLeft()
                                cardAlpha.snapTo(1f)
                                offsetX.snapTo(0f)
                                offsetY.snapTo(0f)
                            }
                        } else {
                            // Expressive elastic bounce back to center
                            coroutineScope.launch {
                                cardScale.animateTo(
                                    targetValue = 1f,
                                    animationSpec = spring(
                                        dampingRatio = Spring.DampingRatioMediumBouncy,
                                        stiffness = Spring.StiffnessMediumLow
                                    )
                                )
                            }
                            coroutineScope.launch {
                                offsetX.animateTo(
                                    0f,
                                    animationSpec = spring(
                                        dampingRatio = Spring.DampingRatioMediumBouncy,
                                        stiffness = Spring.StiffnessMediumLow
                                    )
                                )
                            }
                            coroutineScope.launch {
                                offsetY.animateTo(
                                    0f,
                                    animationSpec = spring(
                                        dampingRatio = Spring.DampingRatioMediumBouncy,
                                        stiffness = Spring.StiffnessMediumLow
                                    )
                                )
                            }
                        }
                    },
                    onDrag = { change, dragAmount ->
                        change.consume()
                        coroutineScope.launch {
                            offsetX.snapTo(offsetX.value + dragAmount.x)
                            offsetY.snapTo(offsetY.value + dragAmount.y)
                        }
                    }
                )
            }
            .pointerInput(isTopCard) {
                if (!isTopCard) return@pointerInput
                detectTapGestures(
                    onTap = { onTapDetail() },
                    onDoubleTap = { onToggleFitMode() }
                )
            }
    ) {
        // Main Card Surface
        Card(
            shape = RoundedCornerShape(CardCornerRadius),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp),
            modifier = Modifier.fillMaxSize(),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainer)
        ) {
            Box(modifier = Modifier.fillMaxSize()) {
                if (isFitMode) {
                    // Smart Fit: Blurred Ambient Backdrop + Centered Aspect Fit Image
                    AsyncImage(
                        model = ImageRequest.Builder(LocalContext.current)
                            .data(item.contentUri)
                            .crossfade(true)
                            .build(),
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .fillMaxSize()
                            .scale(1.2f)
                            .blur(32.dp)
                    )
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(Color.Black.copy(alpha = 0.35f))
                    )
                    AsyncImage(
                        model = ImageRequest.Builder(LocalContext.current)
                            .data(item.contentUri)
                            .crossfade(true)
                            .build(),
                        contentDescription = item.title,
                        contentScale = ContentScale.Fit,
                        modifier = Modifier.fillMaxSize()
                    )
                } else {
                    // Fill Mode: Crop to Card
                    AsyncImage(
                        model = ImageRequest.Builder(LocalContext.current)
                            .data(item.contentUri)
                            .crossfade(true)
                            .build(),
                        contentDescription = item.title,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxSize()
                    )
                }

                // Efeito de Borda Esquerda (Vermelha / Excluir) que surge ao deslizar para esquerda
                if (isTopCard && deleteIntensity > 0.05f) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(
                                Brush.horizontalGradient(
                                    colors = listOf(
                                        Color.Transparent,
                                        CoralRed.copy(alpha = 0.15f * deleteIntensity),
                                        CoralRed.copy(alpha = 0.55f * deleteIntensity)
                                    )
                                )
                            )
                    )
                }

                // Efeito de Borda Direita (Verde / Manter) que surge ao deslizar para direita
                if (isTopCard && keepIntensity > 0.05f) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(
                                Brush.horizontalGradient(
                                    colors = listOf(
                                        EmeraldMint.copy(alpha = 0.55f * keepIntensity),
                                        EmeraldMint.copy(alpha = 0.15f * keepIntensity),
                                        Color.Transparent
                                    )
                                )
                            )
                    )
                }

                // Favorite Indicator Badge (Top-Left)
                if (isTopCard && item.isFavorite) {
                    Surface(
                        shape = RoundedCornerShape(PillCornerRadius),
                        color = Color.Black.copy(alpha = 0.55f),
                        modifier = Modifier
                            .align(Alignment.TopStart)
                            .padding(14.dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Rounded.Favorite,
                                contentDescription = "Favorite",
                                tint = RosePink,
                                modifier = Modifier.size(16.dp)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = "Fav",
                                color = Color.White,
                                fontSize = 11.sp,
                                fontWeight = androidx.compose.ui.text.font.FontWeight.Bold
                            )
                        }
                    }
                }

                // Fit / Fill Toggle Pill (Top-Right)
                if (isTopCard) {
                    Surface(
                        shape = RoundedCornerShape(PillCornerRadius),
                        color = Color.Black.copy(alpha = 0.55f),
                        modifier = Modifier
                            .align(Alignment.TopEnd)
                            .padding(14.dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
                        ) {
                            Icon(
                                imageVector = if (isFitMode) Icons.Rounded.FitScreen else Icons.Rounded.CropFree,
                                contentDescription = null,
                                tint = Color.White,
                                modifier = Modifier.size(16.dp)
                            )
                            if (item.ratioLabel.isNotEmpty()) {
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = item.ratioLabel,
                                    color = Color.White,
                                    fontSize = 11.sp,
                                    fontWeight = androidx.compose.ui.text.font.FontWeight.Bold
                                )
                            }
                        }
                    }
                }

                // Swipe Decision Stamp: DISCARD (Left Swipe -> Badge on Right)
                if (isTopCard && deleteIntensity > 0.05f) {
                    val discardText = if (lang == "pt") "EXCLUIR" else "DISCARD"
                    Surface(
                        shape = RoundedCornerShape(PillCornerRadius),
                        color = CoralRed,
                        modifier = Modifier
                            .align(Alignment.TopEnd)
                            .padding(top = 40.dp, end = 24.dp)
                            .rotate(14f)
                            .scale(0.85f + (0.25f * deleteIntensity))
                            .shadow(16.dp, RoundedCornerShape(PillCornerRadius))
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(horizontal = 18.dp, vertical = 10.dp)
                        ) {
                            Icon(Icons.Rounded.DeleteOutline, contentDescription = null, tint = Color.White)
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = discardText,
                                color = Color.White,
                                fontWeight = androidx.compose.ui.text.font.FontWeight.Black,
                                fontSize = 16.sp
                            )
                        }
                    }
                }

                // Swipe Decision Stamp: KEEP (Right Swipe -> Badge on Left)
                if (isTopCard && keepIntensity > 0.05f) {
                    val keepText = if (lang == "pt") "MANTER" else "KEEP"
                    Surface(
                        shape = RoundedCornerShape(PillCornerRadius),
                        color = EmeraldMint,
                        modifier = Modifier
                            .align(Alignment.TopStart)
                            .padding(top = 40.dp, start = 24.dp)
                            .rotate(-14f)
                            .scale(0.85f + (0.25f * keepIntensity))
                            .shadow(16.dp, RoundedCornerShape(PillCornerRadius))
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(horizontal = 18.dp, vertical = 10.dp)
                        ) {
                            Icon(Icons.Rounded.Check, contentDescription = null, tint = Color.White)
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = keepText,
                                color = Color.White,
                                fontWeight = androidx.compose.ui.text.font.FontWeight.Black,
                                fontSize = 16.sp
                            )
                        }
                    }
                }
            }
        }
    }
}
