import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../domain/models/gallery_album.dart';
import '../../domain/models/triage_item.dart';

/// Resultado da verificação de permissões do sistema
enum MediaPermissionStatus {
  granted,
  limited, // Acesso parcial (ex: Android 14+ / iOS 14+)
  denied,
  restricted,
}

/// Critério de ordenação de fotos para triagem
enum PhotoSortOrder {
  newest,
  largest,
  oldest,
}

/// Serviço responsável pelo acesso offline-first à galeria de fotos local
/// via MediaStore (Android) e PhotoKit (iOS), sem nenhuma requisição de rede.
class MediaService {
  static const int defaultPageSize = 60;

  /// Solicita e verifica as permissões mais recentes do sistema
  static Future<MediaPermissionStatus> requestPermissions() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          androidPermission: AndroidPermission(
            type: RequestType.image,
            mediaLocation: true,
          ),
        ),
      );

      if (ps.isAuth) {
        return MediaPermissionStatus.granted;
      } else if (ps.hasAccess) {
        return MediaPermissionStatus.limited;
      } else {
        return MediaPermissionStatus.denied;
      }
    } catch (e) {
      debugPrint('Erro ao solicitar permissões de mídia: $e');
      return MediaPermissionStatus.denied;
    }
  }

  /// Lista todos os álbuns/pastas disponíveis na galeria do dispositivo
  static Future<List<GalleryAlbum>> fetchAlbums() async {
    try {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: false,
      );

      if (paths.isEmpty) {
        return _getDemoAlbums();
      }

      final List<GalleryAlbum> albums = [];
      for (final path in paths) {
        final count = await path.assetCountAsync;
        if (count > 0) {
          albums.add(
            GalleryAlbum(
              id: path.id,
              name: path.isAll ? 'Todas as Fotos' : path.name,
              assetCount: count,
              pathEntity: path,
            ),
          );
        }
      }

      if (albums.isEmpty) {
        return _getDemoAlbums();
      }

      return albums;
    } catch (e) {
      debugPrint('Erro ao listar álbuns reais: $e. Retornando álbuns de demonstração.');
      return _getDemoAlbums();
    }
  }

  /// Carrega uma página de fotos leves de um álbum específico
  /// (metadados apenas, sem decodificar bitmaps brutos).
  /// [limit] define a quantidade máxima de fotos a verificar (0 = sem limite / todas as fotos).
  /// [excludedIds] conjunto de IDs de fotos já triadas/mantidas para serem ignoradas.
  static Future<List<TriageItem>> loadLocalPhotos({
    GalleryAlbum? album,
    int page = 0,
    int limit = 100,
    PhotoSortOrder sortOrder = PhotoSortOrder.newest,
    Set<String>? excludedIds,
  }) async {
    try {
      AssetPathEntity? targetPath = album?.pathEntity;
      if (targetPath == null) {
        final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
          type: RequestType.image,
          onlyAll: true,
        );
        if (paths.isNotEmpty) {
          targetPath = paths.first;
        }
      }

      if (targetPath == null) {
        return _getDemoFallbackItems(
          albumId: album?.id,
          limit: limit,
          sortOrder: sortOrder,
          excludedIds: excludedIds,
        );
      }

      final int totalAssets = await targetPath.assetCountAsync;
      if (totalAssets == 0) {
        return _getDemoFallbackItems(
          albumId: album?.id,
          limit: limit,
          sortOrder: sortOrder,
          excludedIds: excludedIds,
        );
      }

      final int targetCount = (limit <= 0 || limit > totalAssets) ? totalAssets : limit;
      final List<TriageItem> items = [];

      // Carrega fotos iterativamente em páginas para filtrar as já triadas
      const int chunkSize = 80;
      int currentStart = 0;

      while (currentStart < totalAssets && (limit <= 0 || items.length < targetCount)) {
        final int currentEnd = (currentStart + chunkSize > totalAssets)
            ? totalAssets
            : currentStart + chunkSize;

        final List<AssetEntity> batch = await targetPath.getAssetListRange(
          start: currentStart,
          end: currentEnd,
        );

        if (batch.isEmpty) break;

        for (final entity in batch) {
          if (excludedIds != null && excludedIds.contains(entity.id)) {
            continue;
          }

          final file = await entity.file;
          final fileLength = file != null ? await file.length() : 0;

          items.add(
            TriageItem(
              id: entity.id,
              title: entity.title ?? 'IMG_${entity.createDateTime.millisecondsSinceEpoch}',
              createDateTime: entity.createDateTime,
              fileSizeBytes: fileLength,
              width: entity.width,
              height: entity.height,
              assetEntity: entity,
            ),
          );

          if (limit > 0 && items.length >= targetCount) {
            break;
          }
        }

        currentStart = currentEnd;
      }

      // Aplica a ordenação inteligente
      if (sortOrder == PhotoSortOrder.largest) {
        items.sort((a, b) => b.fileSizeBytes.compareTo(a.fileSizeBytes));
      } else if (sortOrder == PhotoSortOrder.oldest) {
        items.sort((a, b) => a.createDateTime.compareTo(b.createDateTime));
      } else {
        items.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
      }

      return items;
    } catch (e) {
      debugPrint('Falha ao ler fotos reais: $e. Ativando itens de demonstração.');
      return _getDemoFallbackItems(
        albumId: album?.id,
        limit: limit,
        sortOrder: sortOrder,
        excludedIds: excludedIds,
      );
    }
  }

  /// Executa o Hard Delete (exclusão física definitiva) em lote
  static Future<bool> executeBatchHardDelete(List<String> assetIds) async {
    try {
      final List<String> resultIds = await PhotoManager.editor.deleteWithIds(assetIds);
      debugPrint('Excluídos definitivamente pelo SO: ${resultIds.length} arquivos.');
      return resultIds.isNotEmpty;
    } catch (e) {
      debugPrint('Erro ao executar hard delete nativo: $e');
      return false;
    }
  }

  /// Lista padrão de álbuns para testes ou ambiente de demonstração
  static List<GalleryAlbum> _getDemoAlbums() {
    return const [
      GalleryAlbum(
        id: 'all',
        name: 'Todas as Fotos',
        assetCount: 6,
      ),
      GalleryAlbum(
        id: 'camera',
        name: 'Câmera',
        assetCount: 3,
      ),
      GalleryAlbum(
        id: 'screenshots',
        name: 'Capturas de Tela',
        assetCount: 1,
      ),
      GalleryAlbum(
        id: 'travel',
        name: 'Viagens',
        assetCount: 2,
      ),
    ];
  }

  /// Dados de demonstração offline para testes em emuladores ou ambientes sem fotos reais
  static List<TriageItem> _getDemoFallbackItems({
    String? albumId,
    int limit = 0,
    PhotoSortOrder sortOrder = PhotoSortOrder.newest,
    Set<String>? excludedIds,
  }) {
    final now = DateTime.now();
    final allItems = [
      TriageItem(
        id: 'demo_1',
        title: 'IMG_20260924_104512.jpg',
        createDateTime: now.subtract(const Duration(hours: 3)),
        fileSizeBytes: 4823449, // 4.6 MB
        width: 4032,
        height: 3024,
        mockImageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200&q=80',
      ),
      TriageItem(
        id: 'demo_2',
        title: 'IMG_20260923_182104.jpg',
        createDateTime: now.subtract(const Duration(days: 1, hours: 2)),
        fileSizeBytes: 6186598, // 5.9 MB
        width: 4032,
        height: 3024,
        mockImageUrl: 'https://images.unsplash.com/photo-1511884642898-4c92249e20b6?w=1200&q=80',
      ),
      TriageItem(
        id: 'demo_3',
        title: 'Screenshot_20260923_1102.png',
        createDateTime: now.subtract(const Duration(days: 1, hours: 9)),
        fileSizeBytes: 2457600, // 2.3 MB
        width: 1080,
        height: 2400,
        mockImageUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=1200&q=80',
      ),
      TriageItem(
        id: 'demo_4',
        title: 'IMG_20260922_150933.jpg',
        createDateTime: now.subtract(const Duration(days: 2)),
        fileSizeBytes: 8388608, // 8.0 MB
        width: 6000,
        height: 4000,
        mockImageUrl: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=1200&q=80',
      ),
      TriageItem(
        id: 'demo_5',
        title: 'IMG_20260921_091244.jpg',
        createDateTime: now.subtract(const Duration(days: 3)),
        fileSizeBytes: 3942000, // 3.7 MB
        width: 3840,
        height: 2160,
        mockImageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=1200&q=80',
      ),
      TriageItem(
        id: 'demo_6',
        title: 'IMG_20260920_142010.jpg',
        createDateTime: now.subtract(const Duration(days: 4)),
        fileSizeBytes: 5242880, // 5.0 MB
        width: 4032,
        height: 3024,
        mockImageUrl: 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=1200&q=80',
      ),
    ];

    List<TriageItem> result;
    if (albumId == 'camera') {
      result = [allItems[0], allItems[1], allItems[3]];
    } else if (albumId == 'screenshots') {
      result = [allItems[2]];
    } else if (albumId == 'travel') {
      result = [allItems[4], allItems[5]];
    } else {
      result = allItems;
    }

    if (excludedIds != null && excludedIds.isNotEmpty) {
      result = result.where((item) => !excludedIds.contains(item.id)).toList();
    }

    if (sortOrder == PhotoSortOrder.largest) {
      result.sort((a, b) => b.fileSizeBytes.compareTo(a.fileSizeBytes));
    } else if (sortOrder == PhotoSortOrder.oldest) {
      result.sort((a, b) => a.createDateTime.compareTo(b.createDateTime));
    } else {
      result.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
    }

    if (limit > 0 && limit < result.length) {
      return result.sublist(0, limit);
    }
    return result;
  }
}
