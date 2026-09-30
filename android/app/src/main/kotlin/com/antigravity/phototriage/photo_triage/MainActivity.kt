package com.antigravity.phototriage.photo_triage

import android.content.ContentUris
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.antigravity.phototriage/native_actions"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setFavorite" -> {
                    val assetId = call.argument<String>("assetId")
                    val isFavorite = call.argument<Boolean>("isFavorite") ?: true
                    if (assetId == null) {
                        result.error("INVALID_ARGUMENT", "assetId is required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            val idLong = assetId.toLongOrNull()
                            if (idLong != null) {
                                val contentUri = ContentUris.withAppendedId(
                                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                                    idLong
                                )
                                val values = ContentValues().apply {
                                    put(MediaStore.MediaColumns.IS_FAVORITE, if (isFavorite) 1 else 0)
                                }
                                val updated = contentResolver.update(contentUri, values, null, null)
                                result.success(updated > 0)
                                return@setMethodCallHandler
                            }
                        }
                        result.success(false)
                    } catch (e: Exception) {
                        // On Android 11+, modifying IS_FAVORITE might throw RecoverableSecurityException if not owned
                        result.success(false)
                    }
                }
                "openInFileManager" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath == null) {
                        result.error("INVALID_ARGUMENT", "filePath is required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val file = File(filePath)
                        if (!file.exists()) {
                            result.error("FILE_NOT_FOUND", "File does not exist", null)
                            return@setMethodCallHandler
                        }

                        val parentDir = file.parentFile ?: file
                        val uri = FileProvider.getUriForFile(
                            this,
                            "${applicationContext.packageName}.fileprovider",
                            file
                        )

                        // Try Intent to view the file or directory
                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(uri, "image/*")
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }

                        startActivity(Intent.createChooser(intent, "Open in..."))
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
