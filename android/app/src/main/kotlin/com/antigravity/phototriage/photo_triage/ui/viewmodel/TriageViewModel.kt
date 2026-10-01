package com.antigravity.phototriage.photo_triage.ui.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.antigravity.phototriage.photo_triage.data.preferences.UserPreferences
import com.antigravity.phototriage.photo_triage.data.repository.MediaRepository
import com.antigravity.phototriage.photo_triage.domain.model.*
import com.antigravity.phototriage.photo_triage.ui.theme.AppThemeMode
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class TriageUiState(
    val items: List<TriageItem> = emptyList(),
    val currentIndex: Int = 0,
    val albums: List<GalleryAlbum> = emptyList(),
    val selectedAlbum: GalleryAlbum? = null,
    val softDeleteQueue: List<TriageItem> = emptyList(),
    val favoriteItems: List<TriageItem> = emptyList(),
    val keptItems: List<TriageItem> = emptyList(),
    val keptCount: Int = 0,
    val canUndo: Boolean = false,
    val isLoading: Boolean = true,
    val isFitMode: Boolean = true,
    val batchLimit: Int = 100,
    val sortOrder: PhotoSortOrder = PhotoSortOrder.NEWEST,
    val themeMode: AppThemeMode = AppThemeMode.SYSTEM,
    val hideKeptPhotos: Boolean = true,
    val persistentKeptCount: Int = 0,
    val hasSeenFavoriteGuide: Boolean = false,
    val showFavoriteGuideDialog: Boolean = false,
    val appLanguage: String = "system"
) {
    val currentItem: TriageItem?
        get() = if (currentIndex in items.indices) items[currentIndex] else null

    val nextItem: TriageItem?
        get() = if (currentIndex + 1 in items.indices) items[currentIndex + 1] else null

    val hasMoreCards: Boolean
        get() = currentIndex < items.size

    val reclaimableStorageBytes: Long
        get() = softDeleteQueue.sumOf { it.fileSizeBytes }

    val formattedReclaimableStorage: String
        get() {
            val mb = reclaimableStorageBytes / (1024.0 * 1024.0)
            return if (mb < 1.0) {
                val kb = reclaimableStorageBytes / 1024.0
                String.format(java.util.Locale.getDefault(), "%.0f KB", kb)
            } else {
                String.format(java.util.Locale.getDefault(), "%.1f MB", mb)
            }
        }
}

class TriageViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = MediaRepository(application)
    private val preferences = UserPreferences(application)

    private val _uiState = MutableStateFlow(TriageUiState())
    val uiState: StateFlow<TriageUiState> = _uiState.asStateFlow()

    private val undoStack = mutableListOf<TriageAction>()
    private var persistentKeptIds = setOf<String>()
    private var persistentDeletedIds = setOf<String>()
    private var persistentFavoriteIds = setOf<String>()

    init {
        observePreferences()
    }

    private fun observePreferences() {
        viewModelScope.launch {
            preferences.keptPhotoIds.collect { kept ->
                persistentKeptIds = kept
                _uiState.update { it.copy(persistentKeptCount = kept.size) }
            }
        }

        viewModelScope.launch {
            preferences.deletedPhotoIds.collect { deleted ->
                persistentDeletedIds = deleted
            }
        }

        viewModelScope.launch {
            preferences.favoritePhotoIds.collect { favIds ->
                persistentFavoriteIds = favIds
                loadFavoritePhotos()
            }
        }

        viewModelScope.launch {
            combine(
                preferences.hideKeptPhotos,
                preferences.batchLimit,
                preferences.sortOrder,
                preferences.isFitMode,
                preferences.themeMode
            ) { hide, limit, sort, fit, theme ->
                _uiState.update { current ->
                    current.copy(
                        hideKeptPhotos = hide,
                        batchLimit = limit,
                        sortOrder = sort,
                        isFitMode = fit,
                        themeMode = theme
                    )
                }
            }.collect()
        }

        viewModelScope.launch {
            combine(
                preferences.seenFavoriteGuide,
                preferences.appLanguage
            ) { seenGuide, lang ->
                _uiState.update { current ->
                    current.copy(
                        hasSeenFavoriteGuide = seenGuide,
                        appLanguage = lang
                    )
                }
            }.collect()
        }
    }

    fun loadInitialData() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val albums = repository.fetchAlbums()
            val selected = albums.firstOrNull { it.isAll } ?: albums.firstOrNull()
            _uiState.update { it.copy(albums = albums, selectedAlbum = selected) }
            reloadPhotos()
        }
    }

    fun selectAlbum(album: GalleryAlbum) {
        if (_uiState.value.selectedAlbum?.id == album.id) return
        _uiState.update { it.copy(selectedAlbum = album, currentIndex = 0) }
        reloadPhotos()
    }

    fun reloadPhotos() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val currentState = _uiState.value
            val excluded = (if (currentState.hideKeptPhotos) persistentKeptIds else emptySet()) + persistentDeletedIds

            val photos = repository.loadPhotos(
                albumId = currentState.selectedAlbum?.id,
                limit = currentState.batchLimit,
                sortOrder = currentState.sortOrder,
                excludedIds = excluded
            ).map { it.copy(isFavorite = persistentFavoriteIds.contains(it.id)) }

            _uiState.update {
                it.copy(
                    items = photos,
                    currentIndex = 0,
                    isLoading = false
                )
            }
        }
    }

    fun swipeRight() {
        val current = _uiState.value.currentItem ?: return
        viewModelScope.launch {
            preferences.markKept(current.id)
            undoStack.add(TriageAction(current, TriageActionType.KEEP))
            _uiState.update {
                it.copy(
                    currentIndex = it.currentIndex + 1,
                    keptCount = it.keptCount + 1,
                    canUndo = undoStack.isNotEmpty()
                )
            }
        }
    }

    fun swipeLeft() {
        val current = _uiState.value.currentItem ?: return
        undoStack.add(TriageAction(current, TriageActionType.SOFT_DELETE))
        _uiState.update {
            it.copy(
                currentIndex = it.currentIndex + 1,
                softDeleteQueue = it.softDeleteQueue + current,
                canUndo = undoStack.isNotEmpty()
            )
        }
    }

    fun favoriteCurrentPhoto() {
        val current = _uiState.value.currentItem ?: return
        viewModelScope.launch {
            val isNowFav = !current.isFavorite
            if (isNowFav) {
                preferences.markFavorite(current.id)
            } else {
                preferences.unmarkFavorite(current.id)
            }
            repository.syncFavoriteWithSystem(current, isNowFav)
            undoStack.add(TriageAction(current, TriageActionType.FAVORITE))

            val updatedCurrent = current.copy(isFavorite = isNowFav)
            val updatedFavorites = if (isNowFav) {
                _uiState.value.favoriteItems + updatedCurrent
            } else {
                _uiState.value.favoriteItems.filterNot { it.id == current.id }
            }

            val shouldShowGuide = isNowFav && !_uiState.value.hasSeenFavoriteGuide

            _uiState.update {
                it.copy(
                    currentIndex = it.currentIndex + 1,
                    favoriteItems = updatedFavorites,
                    canUndo = undoStack.isNotEmpty(),
                    showFavoriteGuideDialog = shouldShowGuide
                )
            }
        }
    }

    fun dismissFavoriteGuide() {
        setSeenFavoriteGuide()
        _uiState.update { it.copy(showFavoriteGuideDialog = false) }
    }

    fun undo() {
        if (undoStack.isEmpty()) return
        val lastAction = undoStack.removeAt(undoStack.lastIndex)
        val prevIndex = (_uiState.value.currentIndex - 1).coerceAtLeast(0)

        viewModelScope.launch {
            when (lastAction.type) {
                TriageActionType.KEEP -> {
                    preferences.unmarkKept(lastAction.item.id)
                    _uiState.update {
                        it.copy(
                            currentIndex = prevIndex,
                            keptCount = (it.keptCount - 1).coerceAtLeast(0),
                            canUndo = undoStack.isNotEmpty()
                        )
                    }
                }
                TriageActionType.SOFT_DELETE -> {
                    _uiState.update {
                        it.copy(
                            currentIndex = prevIndex,
                            softDeleteQueue = it.softDeleteQueue.filterNot { item -> item.id == lastAction.item.id },
                            canUndo = undoStack.isNotEmpty()
                        )
                    }
                }
                TriageActionType.FAVORITE -> {
                    preferences.unmarkFavorite(lastAction.item.id)
                    repository.syncFavoriteWithSystem(lastAction.item, false)
                    _uiState.update {
                        it.copy(
                            currentIndex = prevIndex,
                            favoriteItems = it.favoriteItems.filterNot { item -> item.id == lastAction.item.id },
                            canUndo = undoStack.isNotEmpty()
                        )
                    }
                }
            }
        }
    }

    fun removeFromTrash(item: TriageItem) {
        _uiState.update {
            it.copy(softDeleteQueue = it.softDeleteQueue.filterNot { queueItem -> queueItem.id == item.id })
        }
    }

    fun permanentlyDeleteTrash() {
        val queue = _uiState.value.softDeleteQueue
        viewModelScope.launch {
            preferences.markDeletedBatch(queue.map { it.id })
            repository.deletePhotos(queue)
            _uiState.update { it.copy(softDeleteQueue = emptyList()) }
            reloadPhotos()
        }
    }

    fun removeFromFavorites(item: TriageItem) {
        viewModelScope.launch {
            preferences.unmarkFavorite(item.id)
            repository.syncFavoriteWithSystem(item, false)
            _uiState.update {
                it.copy(favoriteItems = it.favoriteItems.filterNot { fav -> fav.id == item.id })
            }
        }
    }

    fun removeFromKept(item: TriageItem) {
        viewModelScope.launch {
            preferences.unmarkKept(item.id)
            _uiState.update {
                it.copy(
                    keptItems = it.keptItems.filterNot { kept -> kept.id == item.id },
                    persistentKeptCount = (it.persistentKeptCount - 1).coerceAtLeast(0)
                )
            }
        }
    }

    fun toggleFitMode() {
        val next = !_uiState.value.isFitMode
        viewModelScope.launch {
            preferences.setFitMode(next)
        }
    }

    fun setBatchLimit(limit: Int) {
        viewModelScope.launch {
            preferences.setBatchLimit(limit)
            reloadPhotos()
        }
    }

    fun setSortOrder(order: PhotoSortOrder) {
        viewModelScope.launch {
            preferences.setSortOrder(order)
            reloadPhotos()
        }
    }

    fun setThemeMode(mode: AppThemeMode) {
        viewModelScope.launch {
            preferences.setThemeMode(mode)
        }
    }

    fun toggleHideKeptPhotos() {
        val next = !_uiState.value.hideKeptPhotos
        viewModelScope.launch {
            preferences.setHideKeptPhotos(next)
            reloadPhotos()
        }
    }

    fun clearKeptHistory() {
        viewModelScope.launch {
            preferences.clearKeptHistory()
            reloadPhotos()
        }
    }

    fun setSeenFavoriteGuide() {
        viewModelScope.launch {
            preferences.setSeenFavoriteGuide(true)
        }
    }

    fun toggleLanguage() {
        val current = _uiState.value.appLanguage
        val next = if (current == "en") "pt" else "en"
        viewModelScope.launch {
            preferences.setAppLanguage(next)
        }
    }

    fun loadKeptPhotos() {
        viewModelScope.launch {
            val items = repository.loadPhotosByIds(persistentKeptIds)
            _uiState.update { it.copy(keptItems = items) }
        }
    }

    fun loadFavoritePhotos() {
        viewModelScope.launch {
            val items = repository.loadPhotosByIds(persistentFavoriteIds).map { it.copy(isFavorite = true) }
            _uiState.update { it.copy(favoriteItems = items) }
        }
    }

    fun openInFileManager(filePath: String): Boolean {
        return repository.openInFileManager(filePath)
    }
}
