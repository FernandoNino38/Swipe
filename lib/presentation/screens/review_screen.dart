import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/controllers/triage_controller.dart';
import '../../domain/models/triage_item.dart';
import 'photo_detail_dialog.dart';

/// Grade de Confirmação Final
/// Exibe todas as fotos marcadas para exclusão (Soft-Delete) em formato de grade.
/// Permite ampliar imagens, desmarcar arquivos e acionar o Hard-Delete definitivo.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.watch<TriageController>();
    final queue = controller.softDeleteQueue;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.reviewTrashTitle),
        centerTitle: true,
      ),
      body: queue.isEmpty
          ? _buildEmptyState(context, colorScheme, strings, isDark)
          : Column(
              children: [
                // Banner Resumo de Espaço Recuperável
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF321316)
                        : const Color(0xFFFFECEE),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF5A1E24)
                          : const Color(0xFFFFD0D6),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: M3ExpressiveTheme.oneUiCoral.withValues(alpha: isDark ? 0.2 : 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: M3ExpressiveTheme.oneUiCoral,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_sweep_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.photosForDeletion(queue.length),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFFFF8585)
                                    : const Color(0xFFB81020),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              strings.willFreeStorage(controller.formattedReclaimableStorage),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? const Color(0xFFDCA4A8)
                                    : const Color(0xFF901B27),
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
                    physics: const BouncingScrollPhysics(),
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
                      return _buildGridCard(context, item, controller, colorScheme, isDark);
                    },
                  ),
                ),

                // Barra inferior com botão de exclusão definitiva (Hard Delete)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: M3ExpressiveTheme.oneUiCoral,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _confirmHardDelete(context, controller, strings),
                      icon: const Icon(Icons.delete_forever_rounded, size: 22),
                      label: Text(
                        strings.permanentlyDeleteBtn(controller.formattedReclaimableStorage),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
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
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF102E21) : const Color(0xFFE7F9F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: M3ExpressiveTheme.oneUiMint,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              strings.emptyTrashTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              strings.emptyTrashDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
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
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF282E3D) : const Color(0xFFE5E8F0),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
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
              height: 38,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Tamanho do arquivo na base e proporção
            Positioned(
              left: 8,
              bottom: 6,
              child: Text(
                item.ratioLabel.isNotEmpty
                    ? '${item.formattedSize} • ${item.ratioLabel}'
                    : item.formattedSize,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Botão Restaurar (Desmarcar exclusão)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => controller.restoreFromSoftDelete(item),
                child: Container(
                  padding: const EdgeInsets.all(6),
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
          color: Colors.grey.shade900,
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    }
    if (item.mockImageUrl != null) {
      return Image.network(
        item.mockImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: Colors.grey.shade900,
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    }
    return Container(
      color: Colors.grey.shade900,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        title: Text(
          strings.confirmDeleteTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
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
              backgroundColor: M3ExpressiveTheme.oneUiCoral,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
