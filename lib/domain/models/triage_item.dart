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
    if (fileSizeBytes <= 0) {
      return (Intl.defaultLocale?.startsWith('en') ?? false) ? 'Unknown size' : 'Tamanho desc.';
    }
    final mb = fileSizeBytes / (1024 * 1024);
    if (mb < 1.0) {
      final kb = fileSizeBytes / 1024;
      return '${kb.toStringAsFixed(0)} KB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  /// Data legível conforme a língua do sistema ou selecionada
  String get formattedDate {
    final loc = Intl.defaultLocale ?? 'pt_BR';
    try {
      return DateFormat.yMMMd(loc).format(createDateTime);
    } catch (_) {
      return DateFormat('d MMM, yyyy').format(createDateTime);
    }
  }

  /// Hora legível (ex: "14:45")
  String get formattedTime {
    return DateFormat('HH:mm').format(createDateTime);
  }

  /// Resolução e megapixels calculados
  String get formattedResolution {
    if (width <= 0 || height <= 0) {
      return (Intl.defaultLocale?.startsWith('en') ?? false) ? 'Unknown res.' : 'Resolução desc.';
    }
    final mp = (width * height) / 1000000;
    return '$width × $height (${mp.toStringAsFixed(1)} MP)';
  }

  /// Proporção geométrica da imagem (largura / altura)
  double get aspectRatio {
    if (width <= 0 || height <= 0) return 1.0;
    return width / height;
  }

  /// Indica se a imagem é horizontal (Landscape)
  bool get isLandscape => width > height;

  /// Indica se a imagem é vertical (Portrait)
  bool get isPortrait => height > width;

  /// Indica se a imagem é quadrada (~1:1)
  bool get isSquare =>
      width > 0 && height > 0 && (width - height).abs() / width < 0.05;

  /// Rótulo formatado da proporção da imagem (ex: "4:3", "16:9", "1:1", "Panorama")
  String get ratioLabel {
    if (width <= 0 || height <= 0) return '';
    final ratio = width / height;
    if (ratio > 2.2) return 'Panorama';
    if ((ratio - 16 / 9).abs() < 0.08) return '16:9';
    if ((ratio - 4 / 3).abs() < 0.08) return '4:3';
    if ((ratio - 3 / 2).abs() < 0.08) return '3:2';
    if ((ratio - 1.0).abs() < 0.06) return '1:1';
    if ((ratio - 9 / 16).abs() < 0.08) return '9:16';
    if ((ratio - 3 / 4).abs() < 0.08) return '3:4';
    if ((ratio - 2 / 3).abs() < 0.08) return '2:3';
    if (ratio < 0.45) return 'Vertical';
    return '$width:$height';
  }

  /// Retorna o caminho absoluto do arquivo no dispositivo (se disponível)
  Future<String?> getFilePath() async {
    if (assetEntity != null) {
      final file = await assetEntity!.file;
      return file?.path;
    }
    return mockImageUrl;
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
