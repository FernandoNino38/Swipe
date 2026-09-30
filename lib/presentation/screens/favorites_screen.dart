import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/controllers/triage_controller.dart';
import '../../domain/models/triage_item.dart';
import 'photo_detail_dialog.dart';

/// Tela dedicada para exibição e gerenciamento de Fotos Favoritas.
/// Permite visualizar a grade de fotos favoritadas,
/// inspecionar metadados em tela cheia e remover fotos dos favoritos.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.watch<TriageController>();
    final favorites = controller.favoriteItems;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.favoritesTitle),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? _buildEmptyState(context, colorScheme, strings, isDark)
          : Column(
              children: [
                // Banner Resumo de Favoritos
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2E121E)
                        : const Color(0xFFFFEEF3),
                    borderRadius: BorderRadius.circular(M3ExpressiveTheme.cardBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: M3ExpressiveTheme.oneUiRose.withValues(alpha: isDark ? 0.2 : 0.08),
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
                          color: M3ExpressiveTheme.oneUiRose,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.albumPhotos(favorites.length),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFFFF85AA)
                                    : const Color(0xFFB80044),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              strings.noFavoritesDesc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? const Color(0xFFDCA4BA)
                                    : const Color(0xFF9C2053),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Grade de fotos favoritas
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
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final item = favorites[index];
                      return _buildGridCard(context, item, controller, colorScheme, strings, isDark);
                    },
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2E121E) : const Color(0xFFFFEEF3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline_rounded,
                size: 64,
                color: M3ExpressiveTheme.oneUiRose,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              strings.noFavoritesTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              strings.noFavoritesDesc,
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
    AppStrings strings,
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

            // Botão Desfavoritar (Remover dos favoritos)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.removeFromFavorites(item);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 900),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      content: Text(strings.favoriteRemoved),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: M3ExpressiveTheme.oneUiRose,
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
      child: const Icon(Icons.image_not_supported, color: Colors.white54),
    );
  }
}
