package com.antigravity.phototriage.photo_triage.domain.model

import android.net.Uri
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class TriageItem(
    val id: String,
    val title: String,
    val contentUri: Uri,
    val filePath: String?,
    val createTimestampMs: Long,
    val fileSizeBytes: Long,
    val width: Int,
    val height: Int,
    val isFavorite: Boolean = false
) {
    val formattedSize: String
        get() {
            if (fileSizeBytes <= 0) return "Unknown size"
            val mb = fileSizeBytes / (1024.0 * 1024.0)
            return if (mb < 1.0) {
                val kb = fileSizeBytes / 1024.0
                String.format(Locale.getDefault(), "%.0f KB", kb)
            } else {
                String.format(Locale.getDefault(), "%.1f MB", mb)
            }
        }

    val formattedDate: String
        get() {
            val sdf = SimpleDateFormat("d MMM, yyyy", Locale.getDefault())
            return sdf.format(Date(createTimestampMs))
        }

    val formattedTime: String
        get() {
            val sdf = SimpleDateFormat("HH:mm", Locale.getDefault())
            return sdf.format(Date(createTimestampMs))
        }

    val formattedResolution: String
        get() {
            if (width <= 0 || height <= 0) return "Unknown res."
            val mp = (width.toDouble() * height.toDouble()) / 1_000_000.0
            return String.format(Locale.getDefault(), "%d × %d (%.1f MP)", width, height, mp)
        }

    val ratioLabel: String
        get() {
            if (width <= 0 || height <= 0) return ""
            val ratio = width.toDouble() / height.toDouble()
            return when {
                ratio > 2.2 -> "Panorama"
                Math.abs(ratio - 16.0 / 9.0) < 0.08 -> "16:9"
                Math.abs(ratio - 4.0 / 3.0) < 0.08 -> "4:3"
                Math.abs(ratio - 3.0 / 2.0) < 0.08 -> "3:2"
                Math.abs(ratio - 1.0) < 0.06 -> "1:1"
                Math.abs(ratio - 9.0 / 16.0) < 0.08 -> "9:16"
                Math.abs(ratio - 3.0 / 4.0) < 0.08 -> "3:4"
                Math.abs(ratio - 2.0 / 3.0) < 0.08 -> "2:3"
                ratio < 0.45 -> "Vertical"
                else -> "$width:$height"
            }
        }
}

data class GalleryAlbum(
    val id: String,
    val name: String,
    val assetCount: Int,
    val isAll: Boolean = false
)

enum class PhotoSortOrder {
    NEWEST, LARGEST, OLDEST
}

enum class TriageActionType {
    SOFT_DELETE, KEEP, FAVORITE
}

data class TriageAction(
    val item: TriageItem,
    val type: TriageActionType
)
