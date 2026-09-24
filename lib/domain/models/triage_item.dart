import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'album_item.dart';

/// Representa um arquivo de mídia em avaliação na sessão de triagem
class TriageItem {
  final String id;
  final String title;
  final DateTime createDateTime;
  final int fileSizeBytes;
  final int width;
  final int height;
  final AssetEntity? assetEntity;
  final String? mockImageUrl;

  const TriageItem({
    required this.id,
    required this.title,
    required this.createDateTime,
    required this.fileSizeBytes,
    required this.width,
    required this.height,
    this.assetEntity,
    this.mockImageUrl,
  });

  /// Tamanho formatado amigável (ex: "4.8 MB")
  String get formattedSize {
    if (fileSizeBytes <= 0) return 'Tamanho desc.';
    final mb = fileSizeBytes / (1024 * 1024);
    if (mb < 1.0) {
      final kb = fileSizeBytes / 1024;
      return '${kb.toStringAsFixed(0)} KB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Data legível (ex: "24 de Set, 2026")
  String get formattedDate {
    return DateFormat('d MMM, yyyy', 'pt_BR').format(createDateTime);
  }

  /// Hora legível (ex: "14:45")
  String get formattedTime {
    return DateFormat('HH:mm').format(createDateTime);
  }

  /// Resolução e megapixels calculados
  String get formattedResolution {
    if (width <= 0 || height <= 0) return 'Resolução desc.';
    final mp = (width * height) / 1000000;
    return '$width × $height (${mp.toStringAsFixed(1)} MP)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TriageItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Tipos de ação tomadas no baralho de cards
enum TriageActionType {
  keep,
  softDelete,
  moveToAlbum,
}

/// Registro histórico para a pilha de Desfazer (Undo)
class TriageAction {
  final TriageItem item;
  final TriageActionType type;
  final AlbumItem? targetAlbum;
  final DateTime timestamp;

  TriageAction({
    required this.item,
    required this.type,
    this.targetAlbum,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
