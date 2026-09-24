import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../core/cache/sliding_window_cache.dart';
import '../../core/services/media_service.dart';
import '../models/album_item.dart';
import '../models/gallery_album.dart';
import '../models/triage_item.dart';

/// Controlador central da sessão de triagem, gerenciando o ciclo de vida dos cards,
/// a fila de Soft-Delete transitória, o histórico LIFO para Undo e a integração
/// de memória com a SlidingWindowCache.
class TriageController extends ChangeNotifier {
  final SlidingWindowCache _cache = SlidingWindowCache();

  List<TriageItem> _items = [];
  int _currentIndex = 0;

  List<GalleryAlbum> _availableAlbums = [];
  GalleryAlbum? _selectedAlbum;

  // Fila de revisão (Soft Delete) - nunca altera os arquivos físicos até a confirmação final
  final List<TriageItem> _softDeleteQueue = [];
  final List<TriageItem> _keptItems = [];
  final Map<String, List<TriageItem>> _albumAssignments = {};

  // Pilha LIFO de ações para suporte ilimitado a Desfazer (Undo)
  final List<TriageAction> _undoStack = [];

  bool _isLoading = true;
  String? _errorMessage;
  MediaPermissionStatus _permissionStatus = MediaPermissionStatus.denied;

  // Suporte a seleção dinâmica de idioma (null = padrão do sistema)
  Locale? _customLocale;

  // ColorScheme extraído dinamicamente da foto ativa (M3 Contextual Dynamic Color)
  ColorScheme? _contextualColorScheme;

  // Limite configurável de fotos por sessão (0 = sem limite / todas as fotos)
  int _batchLimit = 100;
  static const List<int> availableBatchLimits = [30, 60, 100, 200, 500, 0];

  // Getters públicos
  List<TriageItem> get items => _items;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MediaPermissionStatus get permissionStatus => _permissionStatus;
  ColorScheme? get contextualColorScheme => _contextualColorScheme;
  SlidingWindowCache get cache => _cache;
  List<GalleryAlbum> get availableAlbums => List.unmodifiable(_availableAlbums);
  GalleryAlbum? get selectedAlbum => _selectedAlbum;
  Locale? get customLocale => _customLocale;
  int get batchLimit => _batchLimit;
  TriageAction? get lastAction => _undoStack.isNotEmpty ? _undoStack.last : null;

  void toggleLocale() {
    if (_customLocale?.languageCode == 'en') {
      _customLocale = const Locale('pt', 'BR');
    } else {
      _customLocale = const Locale('en', 'US');
    }
    notifyListeners();
  }

  void setLocale(Locale? locale) {
    _customLocale = locale;
    notifyListeners();
  }

  /// Altera o limite de fotos da sessão e recarrega os itens
  Future<void> setBatchLimit(int limit) async {
    if (_batchLimit == limit) return;
    _batchLimit = limit;
    _isLoading = true;
    notifyListeners();

    try {
      _items = await MediaService.loadLocalPhotos(
        album: _selectedAlbum,
        limit: _batchLimit,
      );
      _currentIndex = 0;
      _softDeleteQueue.clear();
      _keptItems.clear();
      _albumAssignments.clear();
      _undoStack.clear();

      await _refreshSlidingWindow();
      _extractColorSchemeFromCurrentItem();
    } catch (e) {
      _errorMessage = 'Falha ao recarregar fotos com novo limite: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  TriageItem? get currentItem =>
      (_currentIndex >= 0 && _currentIndex < _items.length)
          ? _items[_currentIndex]
          : null;

  TriageItem? get nextItem =>
      (_currentIndex + 1 < _items.length) ? _items[_currentIndex + 1] : null;

  bool get hasMoreCards => _currentIndex < _items.length;
  bool get canUndo => _undoStack.isNotEmpty;

  List<TriageItem> get softDeleteQueue => List.unmodifiable(_softDeleteQueue);
  int get softDeleteCount => _softDeleteQueue.length;
  int get keptCount => _keptItems.length;
  int get favoritesCount => _albumAssignments['favorites']?.length ?? 0;
  int get totalCards => _items.length;

  /// Total de bytes em fila de exclusão para liberação de armazenamento
  int get totalReclaimableBytes =>
      _softDeleteQueue.fold(0, (sum, item) => sum + item.fileSizeBytes);

  /// String formatada para exibição no cabeçalho e na grade de confirmação
  String get formattedReclaimableStorage {
    if (totalReclaimableBytes <= 0) return '0 MB';
    final mb = totalReclaimableBytes / (1024 * 1024);
    if (mb >= 1024.0) {
      final gb = mb / 1024.0;
      return '${gb.toStringAsFixed(2)} GB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Progresso percentual da galeria
  double get progressPercentage {
    if (_items.isEmpty) return 0.0;
    return (_currentIndex / _items.length).clamp(0.0, 1.0);
  }

  /// Inicializa a leitura de permissões e carrega os metadados iniciais
  Future<void> initialize({BuildContext? context}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _permissionStatus = await MediaService.requestPermissions();
      _availableAlbums = await MediaService.fetchAlbums();
      _selectedAlbum = _availableAlbums.isNotEmpty ? _availableAlbums.first : null;
      _items = await MediaService.loadLocalPhotos(
        album: _selectedAlbum,
        limit: _batchLimit,
      );

      _currentIndex = 0;
      _softDeleteQueue.clear();
      _keptItems.clear();
      _albumAssignments.clear();
      _undoStack.clear();

      await _refreshSlidingWindow();
      _extractColorSchemeFromCurrentItem();
    } catch (e) {
      _errorMessage = 'Falha ao inicializar galeria: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Altera o álbum/pasta ativo para triagem
  Future<void> selectAlbum(GalleryAlbum album) async {
    if (_selectedAlbum == album) return;

    _selectedAlbum = album;
    _isLoading = true;
    notifyListeners();

    try {
      _items = await MediaService.loadLocalPhotos(
        album: album,
        limit: _batchLimit,
      );
      _currentIndex = 0;
      _softDeleteQueue.clear();
      _keptItems.clear();
      _albumAssignments.clear();
      _undoStack.clear();

      await _refreshSlidingWindow();
      _extractColorSchemeFromCurrentItem();
    } catch (e) {
      _errorMessage = 'Erro ao alternar para o álbum ${album.name}: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deslizar para a Direita (Manter): Ação positiva
  Future<void> swipeRight() async {
    final item = currentItem;
    if (item == null) return;

    _keptItems.add(item);
    _undoStack.add(
      TriageAction(item: item, type: TriageActionType.keep),
    );

    _advanceDeck();
  }

  /// Deslizar para a Esquerda (Excluir): Ação negativa (Soft-Delete)
  Future<void> swipeLeft() async {
    final item = currentItem;
    if (item == null) return;

    // Registra na fila transitória sem tocar no disco
    _softDeleteQueue.add(item);
    _undoStack.add(
      TriageAction(item: item, type: TriageActionType.softDelete),
    );

    _advanceDeck();
  }

  /// Ação Rápida de Pasta/Álbum
  Future<void> moveToAlbum(AlbumItem album) async {
    final item = currentItem;
    if (item == null) return;

    _albumAssignments.putIfAbsent(album.id, () => []).add(item);
    _undoStack.add(
      TriageAction(
        item: item,
        type: TriageActionType.moveToAlbum,
        targetAlbum: album,
      ),
    );

    _advanceDeck();
  }

  /// Adiciona a foto ativa aos Favoritos e avança o baralho
  Future<void> favoriteCurrentPhoto() async {
    final item = currentItem;
    if (item == null) return;

    final favAlbum = AlbumItem.defaultAlbums.firstWhere(
      (a) => a.id == 'favorites',
      orElse: () => const AlbumItem(
        id: 'favorites',
        name: 'Favoritos',
        icon: Icons.favorite_rounded,
      ),
    );

    await moveToAlbum(favAlbum);
  }

  /// Ação de Rodapé: Desfazer (Undo)
  /// Reverte imediatamente o último gesto, devolvendo o card ao topo do baralho
  Future<void> undo() async {
    if (!canUndo) return;

    final lastAction = _undoStack.removeLast();
    _currentIndex = (_currentIndex - 1).clamp(0, _items.length);

    switch (lastAction.type) {
      case TriageActionType.keep:
        _keptItems.remove(lastAction.item);
        break;
      case TriageActionType.softDelete:
        _softDeleteQueue.remove(lastAction.item);
        break;
      case TriageActionType.moveToAlbum:
        if (lastAction.targetAlbum != null) {
          _albumAssignments[lastAction.targetAlbum!.id]?.remove(lastAction.item);
        }
        break;
    }

    await _refreshSlidingWindow();
    _extractColorSchemeFromCurrentItem();
    notifyListeners();
  }

  /// Restaura um item diretamente da Grade de Confirmação (remove da lixeira)
  void restoreFromSoftDelete(TriageItem item) {
    _softDeleteQueue.remove(item);
    // Também remove correspondências da pilha de undo se aplicável
    _undoStack.removeWhere((a) => a.item.id == item.id && a.type == TriageActionType.softDelete);
    notifyListeners();
  }

  /// Executa a exclusão definitiva em lote (Hard Delete)
  /// Solicita autorização de exclusão ao Sistema Operacional
  Future<bool> executeHardDelete() async {
    if (_softDeleteQueue.isEmpty) return false;

    final assetIdsToDelete = _softDeleteQueue
        .where((item) => item.assetEntity != null)
        .map((item) => item.id)
        .toList();

    bool success = true;
    if (assetIdsToDelete.isNotEmpty) {
      success = await MediaService.executeBatchHardDelete(assetIdsToDelete);
    }

    if (success) {
      // Remove definitivamente os itens da lista da sessão
      final deletedIds = _softDeleteQueue.map((e) => e.id).toSet();
      _items.removeWhere((e) => deletedIds.contains(e.id));
      _softDeleteQueue.clear();

      // Ajusta o índice se extrapolou
      if (_currentIndex >= _items.length) {
        _currentIndex = (_items.length - 1).clamp(0, _items.length);
      }

      await _refreshSlidingWindow();
      notifyListeners();
      return true;
    }

    return false;
  }

  void _advanceDeck() {
    _currentIndex++;
    _refreshSlidingWindow();
    _extractColorSchemeFromCurrentItem();
    notifyListeners();
  }

  Future<void> _refreshSlidingWindow() async {
    // Alvo de resolução otimizado para o viewport do aparelho (~1080x1920)
    await _cache.updateWindow(
      items: _items,
      currentIndex: _currentIndex,
      targetSize: const ThumbnailSize(1080, 1920),
    );
  }

  /// Extração dinâmica de cores do card ativo para compor o tema M3 Expressive
  Future<void> _extractColorSchemeFromCurrentItem() async {
    final item = currentItem;
    if (item == null) {
      _contextualColorScheme = null;
      notifyListeners();
      return;
    }

    try {
      ImageProvider? provider;
      final cachedBytes = _cache.getCachedBytes(item.id);
      if (cachedBytes != null) {
        provider = MemoryImage(cachedBytes);
      } else if (item.mockImageUrl != null) {
        provider = NetworkImage(item.mockImageUrl!);
      }

      if (provider != null) {
        final extractedScheme = await ColorScheme.fromImageProvider(
          provider: provider,
          brightness: Brightness.light,
        );
        _contextualColorScheme = extractedScheme;
        notifyListeners();
      }
    } catch (_) {
      // Caso ocorra falha na extração, mantém o tema do sistema
    }
  }

  @override
  void dispose() {
    _cache.clear();
    super.dispose();
  }
}
