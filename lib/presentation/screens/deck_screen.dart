import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/controllers/triage_controller.dart';
import '../../domain/models/triage_item.dart';
import '../widgets/album_selection_sheet.dart';
import '../widgets/m3_expressive_loading.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/triage_card.dart';
import 'favorites_screen.dart';
import 'photo_detail_dialog.dart';
import 'review_screen.dart';
import 'settings_screen.dart';

/// Tela principal de triagem em tela cheia com baralho de cards dinâmico (M3 Expressive),
/// transição física contínua entre cards, animação expressiva de Desfazer (Undo),
/// seletores de álbum e limite de fotos, e indicadores laterais responsivos.
class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key});

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  final GlobalKey<TriageCardState> _topCardKey = GlobalKey<TriageCardState>();
  double _dragProgress = 0.0;
  Offset? _undoEntranceOffset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.watch<TriageController>();
    final strings = AppStrings.of(context);

    // Progresso relativo do arrasto para animação contínua da pilha de cards
    final absP = _dragProgress.abs().clamp(0.0, 1.0);
    final nextCardScale = 0.93 + (0.07 * absP);
    final nextCardTranslateY = 18.0 * (1.0 - absP);
    final nextCardOpacity = (0.65 + (0.35 * absP)).clamp(0.0, 1.0);

    // Resposta visual dinâmica dos indicadores laterais
    final redIntensity = (-_dragProgress).clamp(0.0, 1.0);
    final greenIntensity = _dragProgress.clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 96,
        titleSpacing: 16,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Linha 1: Título "Swipe" destacado e maior
            const Text(
              'Swipe',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            // Linha 2: Seletor de pastas/álbuns alinhado à esquerda
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => AlbumSelectionSheet.show(context, controller),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B1E28)
                      : const Color(0xFFE8EBF2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2E3545)
                        : const Color(0xFFD6DBE7),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_rounded,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 5),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 190),
                      child: Text(
                        controller.selectedAlbum?.localizedName(strings) ?? strings.allPhotos,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Botão de Lixeira com contador badge
          IconButton(
            tooltip: strings.reviewTrash,
            icon: Badge(
              isLabelVisible: controller.softDeleteCount > 0,
              label: Text(
                '${controller.softDeleteCount}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              backgroundColor: M3ExpressiveTheme.oneUiCoral,
              child: const Icon(Icons.delete_outline_rounded),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReviewScreen(),
                ),
              );
            },
          ),
          // Botão de Configurações
          IconButton(
            tooltip: strings.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: controller.isLoading
            ? const Center(
                child: M3ExpressiveLoadingIndicator(size: 58),
              )
            : controller.hasMoreCards
                ? Column(
                    children: [
                      // Viewport central do baralho de cards com física contínua e indicadores
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Card N+1 (Próximo card - sobe e expande suavemente em tempo real durante o arraste)
                            if (controller.nextItem != null)
                              Transform.scale(
                                scale: nextCardScale,
                                child: Transform.translate(
                                  offset: Offset(0, nextCardTranslateY),
                                  child: Opacity(
                                    opacity: nextCardOpacity,
                                    child: TriageCard(
                                      item: controller.nextItem!,
                                      cachedBytes: controller.cache.getCachedBytes(
                                        controller.nextItem!.id,
                                      ),
                                      isTopCard: false,
                                      isFitMode: controller.isFitMode,
                                      onSwipeRight: () {},
                                      onSwipeLeft: () {},
                                      onTapDetail: () {},
                                    ),
                                  ),
                                ),
                              ),

                            // Card N (Card ativo no topo com animação de entrada ao Desfazer)
                            if (controller.currentItem != null)
                              TriageCard(
                                key: _topCardKey,
                                item: controller.currentItem!,
                                cachedBytes: controller.cache.getCachedBytes(
                                  controller.currentItem!.id,
                                ),
                                isTopCard: true,
                                isFitMode: controller.isFitMode,
                                onToggleFitMode: controller.toggleFitMode,
                                enterFromOffset: _undoEntranceOffset,
                                onDragProgress: (progress) {
                                  if (mounted) {
                                    setState(() {
                                      _dragProgress = progress;
                                    });
                                  }
                                },
                                onSwipeRight: () {
                                  setState(() {
                                    _dragProgress = 0.0;
                                    _undoEntranceOffset = null;
                                  });
                                  controller.swipeRight();
                                },
                                onSwipeLeft: () {
                                  setState(() {
                                    _dragProgress = 0.0;
                                    _undoEntranceOffset = null;
                                  });
                                  controller.swipeLeft();
                                },
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

                            // Indicador lateral esquerdo: Borda Vermelha (Excluir) - Reage ao gesto
                            Positioned(
                              left: 0,
                              top: 24,
                              bottom: 24,
                              child: IgnorePointer(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  width: 4.0 + (6.0 * redIntensity),
                                  decoration: BoxDecoration(
                                    color: M3ExpressiveTheme.oneUiCoral.withValues(
                                      alpha: 0.5 + (0.5 * redIntensity),
                                    ),
                                    borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(6),
                                    ),
                                    boxShadow: redIntensity > 0.1
                                        ? [
                                            BoxShadow(
                                              color: M3ExpressiveTheme.oneUiCoral.withValues(alpha: 0.35 * redIntensity),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            // Indicador lateral direito: Borda Verde (Manter) - Reage ao gesto
                            Positioned(
                              right: 0,
                              top: 24,
                              bottom: 24,
                              child: IgnorePointer(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  width: 4.0 + (6.0 * greenIntensity),
                                  decoration: BoxDecoration(
                                    color: M3ExpressiveTheme.oneUiMint.withValues(
                                      alpha: 0.5 + (0.5 * greenIntensity),
                                    ),
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(6),
                                    ),
                                    boxShadow: greenIntensity > 0.1
                                        ? [
                                            BoxShadow(
                                              color: M3ExpressiveTheme.oneUiMint.withValues(alpha: 0.35 * greenIntensity),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Rodapé com os botões de ação: Excluir, Desfazer, Manter, Favorito
                      QuickActionsBar(
                        canUndo: controller.canUndo,
                        favoritesCount: controller.favoritesCount,
                        onUndo: () {
                          HapticFeedback.lightImpact();
                          final last = controller.lastAction;
                          final screenWidth = MediaQuery.of(context).size.width;
                          Offset? undoOffset;
                          if (last != null) {
                            switch (last.type) {
                              case TriageActionType.softDelete:
                                undoOffset = Offset(-screenWidth - 100, 0);
                                break;
                              case TriageActionType.keep:
                                undoOffset = Offset(screenWidth + 100, 0);
                                break;
                              case TriageActionType.moveToAlbum:
                                undoOffset = const Offset(0, -600);
                                break;
                            }
                          }

                          setState(() {
                            _undoEntranceOffset = undoOffset;
                            _dragProgress = 0.0;
                          });

                          controller.undo();

                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(milliseconds: 1200),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                bottom: 100, // Elevado para não cobrir a barra inferior
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              content: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.undo_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    strings.undoRestored,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        onSwipeLeft: () {
                          HapticFeedback.mediumImpact();
                          if (_topCardKey.currentState != null) {
                            _topCardKey.currentState!.animateSwipeLeft();
                          } else {
                            controller.swipeLeft();
                          }
                        },
                        onSwipeRight: () {
                          HapticFeedback.lightImpact();
                          if (_topCardKey.currentState != null) {
                            _topCardKey.currentState!.animateSwipeRight();
                          } else {
                            controller.swipeRight();
                          }
                        },
                        onFavorite: () {
                          if (controller.currentItem != null) {
                            HapticFeedback.lightImpact();
                            if (_topCardKey.currentState != null) {
                              _topCardKey.currentState!.animateFavorite(() {
                                setState(() {
                                  _dragProgress = 0.0;
                                  _undoEntranceOffset = null;
                                });
                                controller.favoriteCurrentPhoto();
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(milliseconds: 1200),
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.only(
                                      left: 24,
                                      right: 24,
                                      bottom: 100, // Elevado para não cobrir a barra inferior
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    content: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.favorite_rounded, color: M3ExpressiveTheme.oneUiRose, size: 20),
                                        const SizedBox(width: 10),
                                        Text(
                                          strings.addedToFavorites,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            } else {
                              controller.favoriteCurrentPhoto();
                            }
                          } else {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FavoritesScreen(),
                              ),
                            );
                          }
                        },
                        onOpenFavorites: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const FavoritesScreen(),
                            ),
                          );
                        },
                      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isAllCaughtUp = controller.items.isEmpty && controller.persistentKeptCount > 0;

    if (isAllCaughtUp) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                size: 64,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              strings.allPhotosTriagedTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.allPhotosTriagedDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // Badge com total de fotos mantidas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.totalKeptCount(controller.persistentKeptCount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          strings.hideKeptPhotosDesc,
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Botões de Ação
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(260, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                ),
              ),
              onPressed: () => AlbumSelectionSheet.show(context, controller),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(strings.changeAlbumBtn),
            ),
            const SizedBox(height: 10),
            if (controller.favoritesCount > 0) ...[
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(260, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FavoritesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.favorite_rounded, color: Colors.pinkAccent),
                label: Text(strings.viewFavorites),
              ),
              const SizedBox(height: 10),
            ],
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(260, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                ),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(strings.resetKeptHistory),
                    content: Text(strings.resetKeptHistoryConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(strings.cancelBtn),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(strings.confirmBtn),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await controller.clearKeptHistory();
                }
              },
              icon: const Icon(Icons.restore_rounded),
              label: Text(strings.resetKeptHistory),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt_rounded,
              size: 64,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 24),

          // Painel de Métricas da Sessão (M3 Breakdown Cards)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    strings.sessionStats,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: strings.keptPhotos,
                        value: '${controller.keptCount}',
                        icon: Icons.check_circle_rounded,
                        bgColor: M3ExpressiveTheme.oneUiMint.withValues(alpha: isDark ? 0.2 : 0.12),
                        textColor: isDark ? const Color(0xFF5CE6A1) : const Color(0xFF1B6B40),
                        iconColor: isDark ? const Color(0xFF5CE6A1) : M3ExpressiveTheme.oneUiMint,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: strings.deletedPhotos,
                        value: '${controller.softDeleteCount}',
                        icon: Icons.delete_outline_rounded,
                        bgColor: M3ExpressiveTheme.oneUiCoral.withValues(alpha: isDark ? 0.2 : 0.12),
                        textColor: isDark ? const Color(0xFFFF8585) : const Color(0xFFC92A2A),
                        iconColor: isDark ? const Color(0xFFFF8585) : M3ExpressiveTheme.oneUiCoral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: strings.favoritedPhotos,
                        value: '${controller.favoritesCount}',
                        icon: Icons.favorite_rounded,
                        bgColor: M3ExpressiveTheme.oneUiRose.withValues(alpha: isDark ? 0.2 : 0.12),
                        textColor: isDark ? const Color(0xFFFF6699) : const Color(0xFFC2185B),
                        iconColor: isDark ? const Color(0xFFFF6699) : M3ExpressiveTheme.oneUiRose,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: strings.storageFreed,
                        value: controller.formattedReclaimableStorage,
                        icon: Icons.sd_storage_rounded,
                        bgColor: M3ExpressiveTheme.oneUiBlue.withValues(alpha: isDark ? 0.2 : 0.12),
                        textColor: isDark ? const Color(0xFF70B1FF) : M3ExpressiveTheme.oneUiBlue,
                        iconColor: isDark ? const Color(0xFF70B1FF) : M3ExpressiveTheme.oneUiBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Botões de Ação
          if (controller.softDeleteCount > 0) ...[
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(260, 52),
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
            const SizedBox(height: 10),
          ],
          if (controller.favoritesCount > 0) ...[
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(260, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FavoritesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.favorite_rounded, color: Colors.pinkAccent),
              label: Text(strings.viewFavorites),
            ),
            const SizedBox(height: 10),
          ],
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(260, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
              ),
            ),
            onPressed: () {
              setState(() {
                _dragProgress = 0.0;
                _undoEntranceOffset = null;
              });
              controller.initialize();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(strings.restartTriageBtn),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            style: TextButton.styleFrom(
              minimumSize: const Size(260, 46),
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
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}