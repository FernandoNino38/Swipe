package com.antigravity.phototriage.photo_triage.data.repository

import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.core.content.FileProvider
import com.antigravity.phototriage.photo_triage.domain.model.GalleryAlbum
import com.antigravity.phototriage.photo_triage.domain.model.PhotoSortOrder
import com.antigravity.phototriage.photo_triage.domain.model.TriageItem
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

class MediaRepository(private val context: Context) {

    suspend fun fetchAlbums(): List<GalleryAlbum> = withContext(Dispatchers.IO) {
        val albumsMap = mutableMapOf<String, Pair<String, Int>>()
        var totalPhotos = 0

        val projection = arrayOf(
            MediaStore.Images.Media.BUCKET_ID,
            MediaStore.Images.Media.BUCKET_DISPLAY_NAME
        )

        try {
            val cursor = context.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                null,
                null,
                null
            )

            cursor?.use {
                val bucketIdCol = it.getColumnIndex(MediaStore.Images.Media.BUCKET_ID)
                val bucketNameCol = it.getColumnIndex(MediaStore.Images.Media.BUCKET_DISPLAY_NAME)

                while (it.moveToNext()) {
                    totalPhotos++
                    val bucketId = it.getString(bucketIdCol) ?: "unknown"
                    val bucketName = it.getString(bucketNameCol) ?: "Camera"
                    val current = albumsMap[bucketId]
                    albumsMap[bucketId] = bucketName to ((current?.second ?: 0) + 1)
                }
            }
        } catch (_: Exception) {}

        val result = mutableListOf<GalleryAlbum>()
        result.add(
            GalleryAlbum(
                id = "all",
                name = "All Photos",
                assetCount = totalPhotos,
                isAll = true
            )
        )

        albumsMap.forEach { (id, pair) ->
            result.add(
                GalleryAlbum(
                    id = id,
                    name = pair.first,
                    assetCount = pair.second,
                    isAll = false
                )
            )
        }

        result
    }

    suspend fun loadPhotos(
        albumId: String? = null,
        limit: Int = 100,
        sortOrder: PhotoSortOrder = PhotoSortOrder.NEWEST,
        excludedIds: Set<String> = emptySet()
    ): List<TriageItem> = withContext(Dispatchers.IO) {
        val items = mutableListOf<TriageItem>()

        val projection = arrayOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.DISPLAY_NAME,
            MediaStore.Images.Media.DATE_TAKEN,
            MediaStore.Images.Media.DATE_MODIFIED,
            MediaStore.Images.Media.SIZE,
            MediaStore.Images.Media.WIDTH,
            MediaStore.Images.Media.HEIGHT,
            MediaStore.Images.Media.DATA
        )

        val selectionList = mutableListOf<String>()
        val selectionArgs = mutableListOf<String>()

        if (!albumId.isNullOrEmpty() && albumId != "all") {
            selectionList.add("${MediaStore.Images.Media.BUCKET_ID} = ?")
            selectionArgs.add(albumId)
        }

        val selection = if (selectionList.isEmpty()) null else selectionList.joinToString(" AND ")

        val sortClause = when (sortOrder) {
            PhotoSortOrder.NEWEST -> "${MediaStore.Images.Media.DATE_TAKEN} DESC, ${MediaStore.Images.Media.DATE_MODIFIED} DESC"
            PhotoSortOrder.OLDEST -> "${MediaStore.Images.Media.DATE_TAKEN} ASC, ${MediaStore.Images.Media.DATE_MODIFIED} ASC"
            PhotoSortOrder.LARGEST -> "${MediaStore.Images.Media.SIZE} DESC"
        }

        try {
            val cursor = context.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                if (selectionArgs.isEmpty()) null else selectionArgs.toTypedArray(),
                sortClause
            )

            cursor?.use {
                val idCol = it.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
                val nameCol = it.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)
                val dateTakenCol = it.getColumnIndex(MediaStore.Images.Media.DATE_TAKEN)
                val dateModCol = it.getColumnIndex(MediaStore.Images.Media.DATE_MODIFIED)
                val sizeCol = it.getColumnIndexOrThrow(MediaStore.Images.Media.SIZE)
                val widthCol = it.getColumnIndex(MediaStore.Images.Media.WIDTH)
                val heightCol = it.getColumnIndex(MediaStore.Images.Media.HEIGHT)
                val dataCol = it.getColumnIndex(MediaStore.Images.Media.DATA)

                while (it.moveToNext()) {
                    val idLong = it.getLong(idCol)
                    val idStr = idLong.toString()

                    if (excludedIds.contains(idStr)) continue

                    val name = it.getString(nameCol) ?: "IMG_$idStr.jpg"
                    var timestamp = if (dateTakenCol >= 0) it.getLong(dateTakenCol) else 0L
                    if (timestamp <= 0L && dateModCol >= 0) {
                        timestamp = it.getLong(dateModCol) * 1000L
                    }
                    if (timestamp <= 0L) {
                        timestamp = System.currentTimeMillis()
                    }

                    val size = it.getLong(sizeCol)
                    val width = if (widthCol >= 0) it.getInt(widthCol) else 1080
                    val height = if (heightCol >= 0) it.getInt(heightCol) else 1920
                    val path = if (dataCol >= 0) it.getString(dataCol) else null

                    val contentUri = ContentUris.withAppendedId(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                        idLong
                    )

                    items.add(
                        TriageItem(
                            id = idStr,
                            title = name,
                            contentUri = contentUri,
                            filePath = path,
                            createTimestampMs = timestamp,
                            fileSizeBytes = size,
                            width = width,
                            height = height
                        )
                    )

                    if (limit > 0 && items.size >= limit) {
                        break
                    }
                }
            }
        } catch (_: Exception) {}

        items
    }

    suspend fun loadPhotosByIds(ids: Set<String>): List<TriageItem> = withContext(Dispatchers.IO) {
        if (ids.isEmpty()) return@withContext emptyList()
        val items = mutableListOf<TriageItem>()
        val projection = arrayOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.DISPLAY_NAME,
            MediaStore.Images.Media.DATE_TAKEN,
            MediaStore.Images.Media.DATE_MODIFIED,
            MediaStore.Images.Media.SIZE,
            MediaStore.Images.Media.WIDTH,
            MediaStore.Images.Media.HEIGHT,
            MediaStore.Images.Media.DATA
        )

        try {
            val placeholders = ids.joinToString(",") { "?" }
            val cursor = context.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                "${MediaStore.Images.Media._ID} IN ($placeholders)",
                ids.toTypedArray(),
                "${MediaStore.Images.Media.DATE_TAKEN} DESC"
            )

            cursor?.use {
                val idCol = it.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
                val nameCol = it.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)
                val dateTakenCol = it.getColumnIndex(MediaStore.Images.Media.DATE_TAKEN)
                val dateModCol = it.getColumnIndex(MediaStore.Images.Media.DATE_MODIFIED)
                val sizeCol = it.getColumnIndexOrThrow(MediaStore.Images.Media.SIZE)
                val widthCol = it.getColumnIndex(MediaStore.Images.Media.WIDTH)
                val heightCol = it.getColumnIndex(MediaStore.Images.Media.HEIGHT)
                val dataCol = it.getColumnIndex(MediaStore.Images.Media.DATA)

                while (it.moveToNext()) {
                    val idLong = it.getLong(idCol)
                    val idStr = idLong.toString()
                    val name = it.getString(nameCol) ?: "IMG_$idStr.jpg"
                    var timestamp = if (dateTakenCol >= 0) it.getLong(dateTakenCol) else 0L
                    if (timestamp <= 0L && dateModCol >= 0) {
                        timestamp = it.getLong(dateModCol) * 1000L
                    }
                    val size = it.getLong(sizeCol)
                    val width = if (widthCol >= 0) it.getInt(widthCol) else 1080
                    val height = if (heightCol >= 0) it.getInt(heightCol) else 1920
                    val path = if (dataCol >= 0) it.getString(dataCol) else null

                    val contentUri = ContentUris.withAppendedId(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                        idLong
                    )

                    items.add(
                        TriageItem(
                            id = idStr,
                            title = name,
                            contentUri = contentUri,
                            filePath = path,
                            createTimestampMs = timestamp,
                            fileSizeBytes = size,
                            width = width,
                            height = height
                        )
                    )
                }
            }
        } catch (_: Exception) {}

        items
    }

    suspend fun syncFavoriteWithSystem(item: TriageItem, isFavorite: Boolean): Boolean = withContext(Dispatchers.IO) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val idLong = item.id.toLongOrNull() ?: return@withContext false
                val uri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, idLong)
                val values = ContentValues().apply {
                    put(MediaStore.MediaColumns.IS_FAVORITE, if (isFavorite) 1 else 0)
                }
                val updated = context.contentResolver.update(uri, values, null, null)
                return@withContext updated > 0
            } catch (_: Exception) {
                return@withContext false
            }
        }
        false
    }

    suspend fun deleteMediaBatch(uris: List<Uri>): android.content.IntentSender? = withContext(Dispatchers.IO) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            return@withContext MediaStore.createDeleteRequest(context.contentResolver, uris).intentSender
        }
        
        // Fallback genérico para Android 10 e anteriores
        for (uri in uris) {
            try {
                context.contentResolver.delete(uri, null, null)
            } catch (e: Exception) {
                // Em Q (10) isso pode lançar RecoverableSecurityException
            }
        }
        null
    }

    fun openInFileManager(filePath: String): Boolean {
        return try {
            val file = File(filePath)
            if (!file.exists()) return false

            val uri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileprovider",
                file
            )

            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "image/*")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(Intent.createChooser(intent, "Show on Gallery").apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            })
            true
        } catch (_: Exception) {
            false
        }
    }
}
