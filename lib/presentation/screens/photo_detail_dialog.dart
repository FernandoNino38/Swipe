import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../core/localization/app_strings.dart';
import '../../domain/models/triage_item.dart';

/// Diálogo de visualização em alta definição com suporte a zoom gestual (Pinch to Zoom)
class PhotoDetailDialog extends StatelessWidget {
  final TriageItem item;
  final Uint8List? cachedBytes;

  const PhotoDetailDialog({
    super.key,
    required this.item,
    this.cachedBytes,
  });

  static Future<void> show(
    BuildContext context, {
    required TriageItem item,
    Uint8List? cachedBytes,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (context) => PhotoDetailDialog(
        item: item,
        cachedBytes: cachedBytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          item.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fundo ambiente desfocado sutil baseado na imagem para enriquecer proporções não 16:9
          Positioned.fill(
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: Transform.scale(
                  scale: 1.2,
                  child: Opacity(
                    opacity: 0.35,
                    child: _buildImage(fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),

          // Visualizador com suporte nativo a pinch-to-zoom (BoxFit.contain)
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: Hero(
                tag: 'photo_${item.id}',
                child: _buildImage(fit: BoxFit.contain),
              ),
            ),
          ),

          // Painel inferior com metadados expandidos
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            strings.imageDetails,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item.formattedSize,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 16),
                      Text(
                        '${strings.date}: ${item.formattedDate} ${strings.atTime} ${item.formattedTime}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${strings.dimensions}: ${item.formattedResolution}${item.ratioLabel.isNotEmpty ? ' (${item.ratioLabel})' : ''}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage({BoxFit fit = BoxFit.contain}) {
    if (cachedBytes != null) {
      return Image.memory(
        cachedBytes!,
        fit: fit,
      );
    }
    if (item.assetEntity != null) {
      return AssetEntityImage(
        item.assetEntity!,
        isOriginal: true,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }
    if (item.mockImageUrl != null) {
      return Image.network(
        item.mockImageUrl!,
        fit: fit,
      );
    }
    return const Icon(Icons.broken_image, size: 72, color: Colors.white38);
  }
}
