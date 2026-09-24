import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/controllers/triage_controller.dart';
import '../widgets/album_selection_sheet.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/triage_card.dart';
import 'photo_detail_dialog.dart';
import 'review_screen.dart';

/// Tela principal de triagem em tela cheia com baralho de cards (Tinder style),
/// indicadores laterais vermelho/verde (excluir/manter), botão de favoritos no topo,
/// seletor de álbum M3 Expressive, alternância de idioma e ações de rodapé.
class DeckScreen extends StatelessWidget {
  const DeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = context.watch<TriageController>();
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => AlbumSelectionSheet.show(context, controller),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        controller.selectedAlbum?.name ?? strings.appTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down_rounded, size: 24),
                  ],
                ),
                if (controller.totalCards > 0)
                  Text(
                    strings.photosCount(
                      (controller.currentIndex + 1).clamp(1, controller.totalCards),
                      controller.totalCards,
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: controller.progressPercentage,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 4,
          ),
        ),
        actions: [
          // Alternador de Idioma (PT / EN)
          IconButton(
            tooltip: strings.isEnglish ? 'Mudar para Português' : 'Switch to English',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                strings.isEnglish ? 'EN' : 'PT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            onPressed: () => controller.toggleLocale(),
          ),

          // Botão de Favoritos no topo (ao lado da lixeira)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Badge(
              isLabelVisible: controller.favoritesCount > 0,
              label: Text(
                '${controller.favoritesCount}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.pinkAccent,
              child: IconButton.filledTonal(
                tooltip: strings.favoriteTooltip,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFCE4EC),
                  foregroundColor: const Color(0xFFC2185B),
                ),
                icon: const Icon(Icons.favorite_rounded),
                onPressed: controller.currentItem != null
                    ? () {
                        controller.favoriteCurrentPhoto();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text(strings.addedToFavorites),
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ),

          // Botão com Badge para a Grade de Revisão da Lixeira
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: Badge(
              isLabelVisible: controller.softDeleteCount > 0,
              label: Text(
                '${controller.softDeleteCount}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: colorScheme.error,
              child: IconButton.filledTonal(
                tooltip: '${strings.reviewTrash} (${controller.formattedReclaimableStorage})',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReviewScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : controller.hasMoreCards
                ? Column(
                    children: [
                      // Viewport central do baralho de cards com indicadores laterais
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Card N+1 (Próximo card levemente recuado para profundidade 3D)
                            if (controller.nextItem != null)
                              Transform.scale(
                                scale: 0.94,
                                child: Transform.translate(
                                  offset: const Offset(0, 16),
                                  child: Opacity(
                                    opacity: 0.65,
                                    child: TriageCard(
                                      item: controller.nextItem!,
                                      cachedBytes: controller.cache.getCachedBytes(
                                        controller.nextItem!.id,
                                      ),
                                      isTopCard: false,
                                      onSwipeRight: () {},
                                      onSwipeLeft: () {},
                                      onTapDetail: () {},
                                    ),
                                  ),
                                ),
                              ),

                            // Card N (Card ativo no topo com controle total de gestos)
                            if (controller.currentItem != null)
                              TriageCard(
                                key: ValueKey(controller.currentItem!.id),
                                item: controller.currentItem!,
                                cachedBytes: controller.cache.getCachedBytes(
                                  controller.currentItem!.id,
                                ),
                                isTopCard: true,
                                onSwipeRight: controller.swipeRight,
                                onSwipeLeft: controller.swipeLeft,
                                onTapDetail: () {
                                  PhotoDetailDialog.show(
                                    context,
                                    item: controller.currentItem!,
                                    cachedBytes: controller.cache.getCachedBytes(
                                      controller.currentItem!.id,
                                    ),
                                  );
                                },
                              ),

                            // Indicador lateral esquerdo: Borda Vermelha (Excluir)
                            Positioned(
                              left: 0,
                              top: 24,
                              bottom: 24,
                              child: IgnorePointer(
                                child: Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBA1A1A).withValues(alpha: 0.7),
                                    borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 8,
                              child: IgnorePointer(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFDAD6).withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFBA1A1A).withValues(alpha: 0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.close_rounded, color: Color(0xFFBA1A1A), size: 20),
                                      const SizedBox(height: 4),
                                      RotatedBox(
                                        quarterTurns: 3,
                                        child: Text(
                                          strings.delete,
                                          style: const TextStyle(
                                            color: Color(0xFFBA1A1A),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Indicador lateral direito: Borda Verde (Manter)
                            Positioned(
                              right: 0,
                              top: 24,
                              bottom: 24,
                              child: IgnorePointer(
                                child: Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B5E20).withValues(alpha: 0.7),
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              child: IgnorePointer(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC8E6C9).withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_rounded, color: Color(0xFF1B5E20), size: 20),
                                      const SizedBox(height: 4),
                                      RotatedBox(
                                        quarterTurns: 3,
                                        child: Text(
                                          strings.keep,
                                          style: const TextStyle(
                                            color: Color(0xFF1B5E20),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Rodapé com os 3 botões primários: Excluir (Vermelho), Desfazer, Manter (Verde)
                      QuickActionsBar(
                        canUndo: controller.canUndo,
                        onUndo: controller.undo,
                        onSwipeLeft: controller.swipeLeft,
                        onSwipeRight: controller.swipeRight,
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
                : _buildSessionCompletedView(context, controller, colorScheme, strings),
      ),
    );
  }

  Widget _buildSessionCompletedView(
    BuildContext context,
    TriageController controller,
    ColorScheme colorScheme,
    AppStrings strings,
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
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 72,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              strings.sessionComplete,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.sessionSummary(
                controller.softDeleteCount,
                controller.formattedReclaimableStorage,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(240, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReviewScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.delete_sweep_rounded),
              label: Text(strings.reviewAndFreeBtn),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(240, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                ),
              ),
              onPressed: () => controller.initialize(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(strings.restartTriageBtn),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              style: TextButton.styleFrom(
                minimumSize: const Size(240, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                ),
              ),
              onPressed: () => AlbumSelectionSheet.show(context, controller),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(strings.changeAlbumBtn),
            ),
          ],
        ),
      ),
    );
  }
}
