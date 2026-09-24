import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../domain/models/triage_item.dart';

/// Implementa a janela deslizante (Sliding Window LRU de 3 a 4 slots)
/// em estrito cumprimento da diretriz crítica de performance do PRD:
/// - Apenas a foto ativa (N) e as próximas 2 a 3 (N+1, N+2) permanecem em RAM.
/// - O slot N-1 é preservado estritamente para o "Desfazer (Undo)".
/// - Fotos anteriores (<= N-2) têm seus bytes e caches descartados imediatamente (OOM Prevention).
class SlidingWindowCache {
  // Tamanho máximo do buffer de retenção
  static const int preloadAheadCount = 2;
  static const int retainBehindCount = 1;

  // Mapa de bytes decodificados em resolução otimizada para o viewport (largura ~1080)
  final Map<String, Uint8List> _byteCache = {};

  /// Recupera bytes decodificados em cache caso disponíveis
  Uint8List? getCachedBytes(String itemId) {
    return _byteCache[itemId];
  }

  /// Atualiza o foco da janela deslizante em torno do [currentIndex]
  Future<void> updateWindow({
    required List<TriageItem> items,
    required int currentIndex,
    required ThumbnailSize targetSize,
  }) async {
    if (items.isEmpty) return;

    final Set<String> activeWindowIds = {};

    // 1. Identifica os IDs que DEVEM estar na janela deslizante
    final startIndex = (currentIndex - retainBehindCount).clamp(0, items.length - 1);
    final endIndex = (currentIndex + preloadAheadCount).clamp(0, items.length - 1);

    for (int i = startIndex; i <= endIndex; i++) {
      activeWindowIds.add(items[i].id);
    }

    // 2. EVICÇÃO IMEDIATA: Descarta qualquer item fora da janela deslizante
    final List<String> toEvict = [];
    _byteCache.forEach((id, _) {
      if (!activeWindowIds.contains(id)) {
        toEvict.add(id);
      }
    });

    for (final id in toEvict) {
      _byteCache.remove(id);
      debugPrint('[Memory] Evicção de RAM do asset $id para prevenção de OOM.');
    }

    // 3. PRÉ-CARREGAMENTO ASSÍNCRONO dos próximos slots
    for (int i = startIndex; i <= endIndex; i++) {
      final item = items[i];
      if (!_byteCache.containsKey(item.id) && item.assetEntity != null) {
        _preloadAsset(item, targetSize);
      }
    }
  }

  Future<void> _preloadAsset(TriageItem item, ThumbnailSize targetSize) async {
    try {
      final entity = item.assetEntity;
      if (entity == null) return;

      // Carrega thumbnail otimizado proporcional ao viewport em background
      final Uint8List? bytes = await entity.thumbnailDataWithSize(
        targetSize,
        quality: 85,
      );

      if (bytes != null) {
        _byteCache[item.id] = bytes;
      }
    } catch (e) {
      debugPrint('[Memory] Falha ao pré-carregar asset ${item.id}: $e');
    }
  }

  /// Limpa totalmente a memória gráfica e o cache ao encerrar a sessão
  void clear() {
    _byteCache.clear();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
