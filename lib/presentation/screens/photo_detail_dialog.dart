import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/media_service.dart';
import '../../domain/models/triage_item.dart';

/// Diálogo de visualização em alta definição com suporte a zoom gestual (Pinch to Zoom),
/// metadados detalhados, exibição do caminho do arquivo e atalho para o gerenciador de arquivos.
class PhotoDetailDialog extends StatefulWidget {
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
  State<PhotoDetailDialog> createState() => _PhotoDetailDialogState();
}

class _PhotoDetailDialogState extends State<PhotoDetailDialog> {
  String? _filePath;
  bool _isLoadingPath = true;

  @override
  void initState() {
    super.initState();
    _resolveFilePath();
  }

  Future<void> _resolveFilePath() async {
    try {
      final path = await widget.item.getFilePath();
      if (mounted) {
        setState(() {
          _filePath = path;
          _isLoadingPath = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingPath = false;
        });
      }
    }
  }

  Future<void> _openInFiles(BuildContext context, AppStrings strings) async {
    if (_filePath == null || _filePath!.isEmpty) return;

    final success = await MediaService.openFileInSystemViewer(_filePath!);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.couldNotOpenFile),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          widget.item.title,
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
                tag: 'photo_${widget.item.id}',
                child: _buildImage(fit: BoxFit.contain),
              ),
            ),
          ),

          // Painel inferior com metadados expandidos e localização do arquivo
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
                    color: Colors.black.withValues(alpha: 0.72),
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
                            widget.item.formattedSize,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 16),
                      Text(
                        '${strings.date}: ${widget.item.formattedDate} ${strings.atTime} ${widget.item.formattedTime}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${strings.dimensions}: ${widget.item.formattedResolution}${widget.item.ratioLabel.isNotEmpty ? ' (${widget.item.ratioLabel})' : ''}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),

                      // Caminho do arquivo no armazenamento local
                      if (_isLoadingPath)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                          ),
                        )
                      else if (_filePath != null && _filePath!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.folder_open_rounded, size: 16, color: Colors.white54),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _filePath!,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Botão atalho para abrir no gerenciador de arquivos
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.16),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () => _openInFiles(context, strings),
                            icon: const Icon(Icons.open_in_new_rounded, size: 18),
                            label: Text(
                              strings.showInFiles,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
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
    if (widget.cachedBytes != null) {
      return Image.memory(
        widget.cachedBytes!,
        fit: fit,
      );
    }
    if (widget.item.assetEntity != null) {
      return AssetEntityImage(
        widget.item.assetEntity!,
        isOriginal: true,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }
    if (widget.item.mockImageUrl != null) {
      return Image.network(
        widget.item.mockImageUrl!,
        fit: fit,
      );
    }
    return const Icon(Icons.broken_image, size: 72, color: Colors.white38);
  }
}
