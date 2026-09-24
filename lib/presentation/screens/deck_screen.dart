import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/controllers/triage_controller.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/triage_card.dart';
import 'photo_detail_dialog.dart';
import 'review_screen.dart';

/// Tela principal de triagem em tela cheia com baralho de cards (Tinder style),
/// barra de progresso linear M3, indicador dinâmico de lixeira e ações de rodapé.
class DeckScreen extends StatelessWidget {
  const DeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = context.watch<TriageController>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Triagem de Fotos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (controller.totalCards > 0)
              Text(
                '${(controller.currentIndex + 1).clamp(1, controller.totalCards)} de ${controller.totalCards} fotos',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
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
          // Botão com Badge para a Grade de Revisão da Lixeira
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Badge(
              isLabelVisible: controller.softDeleteCount > 0,
              label: Text(
                '${controller.softDeleteCount}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: colorScheme.error,
              child: IconButton.filledTonal(
                tooltip: 'Revisar Lixeira (${controller.formattedReclaimableStorage})',
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
                      // Viewport central do baralho de cards
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
                          ],
                        ),
                      ),

                      // Rodapé com Desfazer e Pastas Rápidas
                      QuickActionsBar(
                        canUndo: controller.canUndo,
                        onUndo: controller.undo,
                        onSwipeLeft: controller.swipeLeft,
                        onSwipeRight: controller.swipeRight,
                        onSelectAlbum: (album) {
                          controller.moveToAlbum(album);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text('Foto movida para o álbum "${album.name}"'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
                : _buildSessionCompletedView(context, controller, colorScheme),
      ),
    );
  }

  Widget _buildSessionCompletedView(
    BuildContext context,
    TriageController controller,
    ColorScheme colorScheme,
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
              'Sessão Concluída!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Todas as fotos foram avaliadas.\n'
              '${controller.softDeleteCount} fotos marcadas para exclusão '
              '(${controller.formattedReclaimableStorage} de espaço a liberar).',
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
              label: const Text('Revisar e Liberar Espaço'),
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
              label: const Text('Reiniciar Triagem'),
            ),
          ],
        ),
      ),
    );
  }
}
