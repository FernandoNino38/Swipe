import 'dart:typed_data';
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
          // Visualizador com suporte nativo a pinch-to-zoom
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: Hero(
                tag: 'photo_${item.id}',
                child: _buildImage(),
              ),
            ),
          ),

          // Painel inferior com metadados expandidos
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24, width: 0.8),
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
                    '${strings.dimensions}: ${item.formattedResolution}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (cachedBytes != null) {
      return Image.memory(
        cachedBytes!,
        fit: BoxFit.contain,
      );
    }
    if (item.assetEntity != null) {
      return AssetEntityImage(
        item.assetEntity!,
        isOriginal: true,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }
    if (item.mockImageUrl != null) {
      return Image.network(
        item.mockImageUrl!,
        fit: BoxFit.contain,
      );
    }
    return const Icon(Icons.broken_image, size: 72, color: Colors.white38);
  }
}
