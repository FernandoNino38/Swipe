import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/controllers/triage_controller.dart';
import '../../domain/models/triage_item.dart';
import 'photo_detail_dialog.dart';

/// Grade de Confirmação Final (PRD Seção 4)
/// Exibe todas as fotos marcadas para exclusão (Soft-Delete) em formato de grade.
/// Permite ampliar imagens, desmarcar arquivos e acionar o Hard-Delete definitivo.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = context.watch<TriageController>();
    final queue = controller.softDeleteQueue;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.reviewTrashTitle),
        centerTitle: true,
      ),
      body: queue.isEmpty
          ? _buildEmptyState(context, colorScheme, strings)
          : Column(
              children: [
                // Banner Resumo de Espaço Recuperável M3
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(M3ExpressiveTheme.sheetBorderRadius),
                    border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_sweep_rounded,
                          color: colorScheme.onError,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.photosForDeletion(queue.length),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              strings.willFreeStorage(controller.formattedReclaimableStorage),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onErrorContainer.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Grade de fotos marcadas (Soft-Delete)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final item = queue[index];
                      return _buildGridCard(context, item, controller, colorScheme);
                    },
                  ),
                ),

                // Barra inferior com botão de exclusão definitiva (Hard Delete)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                        ),
                      ),
                      onPressed: () => _confirmHardDelete(context, controller, strings),
                      icon: const Icon(Icons.delete_forever_rounded),
                      label: Text(
                        strings.permanentlyDeleteBtn(controller.formattedReclaimableStorage),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    AppStrings strings,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 72,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              strings.emptyTrashTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              strings.emptyTrashDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    TriageItem item,
    TriageController controller,
    ColorScheme colorScheme,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagem com toque para zoom detalhado
          GestureDetector(
            onTap: () => PhotoDetailDialog.show(context, item: item),
            child: _buildItemThumbnail(item),
          ),

          // Gradiente inferior para legibilidade do tamanho
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 36,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Tamanho do arquivo na base
          Positioned(
            left: 6,
            bottom: 4,
            child: Text(
              item.formattedSize,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Botão Restaurar (Desmarcar exclusão)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => controller.restoreFromSoftDelete(item),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.undo_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemThumbnail(TriageItem item) {
    if (item.assetEntity != null) {
      return AssetEntityImage(
        item.assetEntity!,
        isOriginal: false,
        thumbnailSize: const ThumbnailSize(300, 300),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: Colors.grey.shade800,
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    }
    if (item.mockImageUrl != null) {
      return Image.network(
        item.mockImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: Colors.grey.shade800,
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    }
    return Container(
      color: Colors.grey.shade800,
      child: const Icon(Icons.image, color: Colors.white54),
    );
  }

  Future<void> _confirmHardDelete(
    BuildContext context,
    TriageController controller,
    AppStrings strings,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.confirmDeleteTitle),
        content: Text(
          strings.confirmDeleteMessage(
            controller.softDeleteCount,
            controller.formattedReclaimableStorage,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(strings.yesDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.executeHardDelete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? strings.deleteSuccess : strings.deleteFailed,
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}
