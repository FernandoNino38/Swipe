package com.antigravity.phototriage.photo_triage.data.preferences

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.antigravity.phototriage.photo_triage.domain.model.PhotoSortOrder
import com.antigravity.phototriage.photo_triage.ui.theme.AppThemeMode
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore by preferencesDataStore(name = "swipe_settings")

class UserPreferences(private val context: Context) {

    private val KEY_KEPT_IDS = stringSetPreferencesKey("kept_photo_ids")
    private val KEY_FAV_IDS = stringSetPreferencesKey("fav_photo_ids")
    private val KEY_DELETED_IDS = stringSetPreferencesKey("deleted_photo_ids")
    private val KEY_HIDE_KEPT = booleanPreferencesKey("hide_kept_photos")
    private val KEY_BATCH_LIMIT = intPreferencesKey("batch_limit")
    private val KEY_SORT_ORDER = stringPreferencesKey("sort_order")
    private val KEY_FIT_MODE = booleanPreferencesKey("is_fit_mode")
    private val KEY_THEME_MODE = stringPreferencesKey("theme_mode")
    private val KEY_LANGUAGE = stringPreferencesKey("app_language")
    private val KEY_SEEN_FAV_GUIDE = booleanPreferencesKey("seen_fav_guide")

    val keptPhotoIds: Flow<Set<String>> = context.dataStore.data.map {
        it[KEY_KEPT_IDS] ?: emptySet()
    }

    val favoritePhotoIds: Flow<Set<String>> = context.dataStore.data.map {
        it[KEY_FAV_IDS] ?: emptySet()
    }

    val deletedPhotoIds: Flow<Set<String>> = context.dataStore.data.map {
        it[KEY_DELETED_IDS] ?: emptySet()
    }

    val hideKeptPhotos: Flow<Boolean> = context.dataStore.data.map {
        it[KEY_HIDE_KEPT] ?: true
    }

    val batchLimit: Flow<Int> = context.dataStore.data.map {
        it[KEY_BATCH_LIMIT] ?: 100
    }

    val sortOrder: Flow<PhotoSortOrder> = context.dataStore.data.map {
        val name = it[KEY_SORT_ORDER] ?: PhotoSortOrder.NEWEST.name
        try { PhotoSortOrder.valueOf(name) } catch (_: Exception) { PhotoSortOrder.NEWEST }
    }

    val isFitMode: Flow<Boolean> = context.dataStore.data.map {
        it[KEY_FIT_MODE] ?: true
    }

    val themeMode: Flow<AppThemeMode> = context.dataStore.data.map {
        val name = it[KEY_THEME_MODE] ?: AppThemeMode.SYSTEM.name
        try { AppThemeMode.valueOf(name) } catch (_: Exception) { AppThemeMode.SYSTEM }
    }

    val appLanguage: Flow<String> = context.dataStore.data.map {
        it[KEY_LANGUAGE] ?: "system"
    }

    val seenFavoriteGuide: Flow<Boolean> = context.dataStore.data.map {
        it[KEY_SEEN_FAV_GUIDE] ?: false
    }

    suspend fun markKept(id: String) {
        context.dataStore.edit {
            val current = it[KEY_KEPT_IDS] ?: emptySet()
            it[KEY_KEPT_IDS] = current + id
        }
    }

    suspend fun unmarkKept(id: String) {
        context.dataStore.edit {
            val current = it[KEY_KEPT_IDS] ?: emptySet()
            it[KEY_KEPT_IDS] = current - id
        }
    }

    suspend fun markFavorite(id: String) {
        context.dataStore.edit {
            val current = it[KEY_FAV_IDS] ?: emptySet()
            it[KEY_FAV_IDS] = current + id
        }
    }

    suspend fun unmarkFavorite(id: String) {
        context.dataStore.edit {
            val current = it[KEY_FAV_IDS] ?: emptySet()
            it[KEY_FAV_IDS] = current - id
        }
    }

    suspend fun markDeleted(id: String) {
        context.dataStore.edit {
            val current = it[KEY_DELETED_IDS] ?: emptySet()
            it[KEY_DELETED_IDS] = current + id
        }
    }

    suspend fun markDeletedBatch(ids: Collection<String>) {
        context.dataStore.edit {
            val current = it[KEY_DELETED_IDS] ?: emptySet()
            it[KEY_DELETED_IDS] = current + ids
        }
    }

    suspend fun unmarkDeleted(id: String) {
        context.dataStore.edit {
            val current = it[KEY_DELETED_IDS] ?: emptySet()
            it[KEY_DELETED_IDS] = current - id
        }
    }

    suspend fun clearKeptHistory() {
        context.dataStore.edit {
            it[KEY_KEPT_IDS] = emptySet()
        }
    }

    suspend fun setHideKeptPhotos(hide: Boolean) {
        context.dataStore.edit { it[KEY_HIDE_KEPT] = hide }
    }

    suspend fun setBatchLimit(limit: Int) {
        context.dataStore.edit { it[KEY_BATCH_LIMIT] = limit }
    }

    suspend fun setSortOrder(order: PhotoSortOrder) {
        context.dataStore.edit { it[KEY_SORT_ORDER] = order.name }
    }

    suspend fun setFitMode(isFit: Boolean) {
        context.dataStore.edit { it[KEY_FIT_MODE] = isFit }
    }

    suspend fun setThemeMode(mode: AppThemeMode) {
        context.dataStore.edit { it[KEY_THEME_MODE] = mode.name }
    }

    suspend fun setAppLanguage(lang: String) {
        context.dataStore.edit { it[KEY_LANGUAGE] = lang }
    }

    suspend fun setSeenFavoriteGuide(seen: Boolean) {
        context.dataStore.edit { it[KEY_SEEN_FAV_GUIDE] = seen }
    }
}
