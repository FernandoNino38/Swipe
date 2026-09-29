import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/controllers/triage_controller.dart';
import '../../domain/models/triage_item.dart';
import '../widgets/album_selection_sheet.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/triage_card.dart';
import 'favorites_screen.dart';
import 'photo_detail_dialog.dart';
import 'review_screen.dart';

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
        title: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => AlbumSelectionSheet.show(context, controller),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1B1E28)
                  : const Color(0xFFE8EBF2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2E3545)
                    : const Color(0xFFD6DBE7),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        controller.selectedAlbum?.name ?? strings.appTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                  ],
                ),
                if (controller.totalCards > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          strings.photosCount(
                            (controller.currentIndex + 1).clamp(1, controller.totalCards),
                            controller.totalCards,
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (controller.batchLimit > 0) ...[
                          Text(
                            ' • ${controller.batchLimit} max',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: controller.progressPercentage,
                backgroundColor: isDark
                    ? const Color(0xFF1E222D)
                    : const Color(0xFFE2E6EF),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 4,
              ),
            ),
          ),
        ),
        actions: [
          // Alternador de Modo de Tema (Sistema / Claro / Escuro)
          IconButton(
            tooltip: '${strings.themeMode}: ${controller.themeMode == ThemeMode.system ? strings.themeSystem : controller.themeMode == ThemeMode.light ? strings.themeLight : strings.themeDark}',
            icon: Icon(
              controller.themeMode == ThemeMode.system
                  ? Icons.brightness_auto_rounded
                  : controller.themeMode == ThemeMode.light
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              controller.toggleThemeMode();
            },
          ),

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
            onPressed: () {
              HapticFeedback.selectionClick();
              controller.toggleLocale();
            },
          ),

          // Botão de Favoritos no topo com animação de contagem e toque longo para ver galeria
          GestureDetector(
            onLongPress: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FavoritesScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedScale(
                scale: controller.favoritesCount > 0 ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 200),
                child: Badge(
                  isLabelVisible: controller.favoritesCount > 0,
                  label: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Text(
                      '${controller.favoritesCount}',
                      key: ValueKey(controller.favoritesCount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  backgroundColor: M3ExpressiveTheme.oneUiRose,
                  child: IconButton.filledTonal(
                    tooltip: controller.currentItem != null
                        ? strings.favoriteTooltip
                        : strings.viewFavorites,
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF381522)
                          : const Color(0xFFFFE8F0),
                      foregroundColor: isDark
                          ? const Color(0xFFFF6699)
                          : M3ExpressiveTheme.oneUiRose,
                    ),
                    icon: const Icon(Icons.favorite_rounded),
                    onPressed: () {
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
                                duration: const Duration(milliseconds: 900),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                content: Row(
                                  children: [
                                    const Icon(Icons.favorite_rounded, color: M3ExpressiveTheme.oneUiRose, size: 20),
                                    const SizedBox(width: 8),
                                    Text(strings.addedToFavorites),
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
                  ),
                ),
              ),
            ),
          ),

          // Botão com Badge para a Grade de Revisão da Lixeira
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: AnimatedScale(
              scale: controller.softDeleteCount > 0 ? 1.0 : 0.95,
              duration: const Duration(milliseconds: 200),
              child: Badge(
                isLabelVisible: controller.softDeleteCount > 0,
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Text(
                    '${controller.softDeleteCount}',
                    key: ValueKey(controller.softDeleteCount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                backgroundColor: M3ExpressiveTheme.oneUiCoral,
                child: IconButton.filledTonal(
                  tooltip: '${strings.reviewTrash} (${controller.formattedReclaimableStorage})',
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF381518)
                        : const Color(0xFFFFE8E8),
                    foregroundColor: isDark
                        ? const Color(0xFFFF8585)
                        : M3ExpressiveTheme.oneUiCoral,
                  ),
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
          ),
        ],
      ),
      body: SafeArea(
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
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
                                key: ValueKey('card_${controller.currentItem!.id}_${controller.currentIndex}'),
                                item: controller.currentItem!,
                                cachedBytes: controller.cache.getCachedBytes(
                                  controller.currentItem!.id,
                                ),
                                isTopCard: true,
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
                            Positioned(
                              left: 8,
                              child: IgnorePointer(
                                child: AnimatedScale(
                                  scale: 1.0 + (0.12 * redIntensity),
                                  duration: const Duration(milliseconds: 120),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: (isDark ? const Color(0xFF381518) : const Color(0xFFFFE8E8)).withValues(
                                        alpha: 0.85 + (0.15 * redIntensity),
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: M3ExpressiveTheme.oneUiCoral.withValues(
                                          alpha: 0.4 + (0.5 * redIntensity),
                                        ),
                                        width: 1.5 + (0.5 * redIntensity),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: M3ExpressiveTheme.oneUiCoral.withValues(
                                            alpha: 0.15 + (0.25 * redIntensity),
                                          ),
                                          blurRadius: 8 + (8 * redIntensity),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.close_rounded,
                                          color: isDark ? const Color(0xFFFF8585) : M3ExpressiveTheme.oneUiCoral,
                                          size: 20,
                                        ),
                                        const SizedBox(height: 4),
                                        RotatedBox(
                                          quarterTurns: 3,
                                          child: Text(
                                            strings.delete,
                                            style: TextStyle(
                                              color: isDark ? const Color(0xFFFF8585) : M3ExpressiveTheme.oneUiCoral,
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
                            Positioned(
                              right: 8,
                              child: IgnorePointer(
                                child: AnimatedScale(
                                  scale: 1.0 + (0.12 * greenIntensity),
                                  duration: const Duration(milliseconds: 120),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: (isDark ? const Color(0xFF102E21) : const Color(0xFFE7F9F0)).withValues(
                                        alpha: 0.85 + (0.15 * greenIntensity),
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: M3ExpressiveTheme.oneUiMint.withValues(
                                          alpha: 0.4 + (0.5 * greenIntensity),
                                        ),
                                        width: 1.5 + (0.5 * greenIntensity),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: M3ExpressiveTheme.oneUiMint.withValues(
                                            alpha: 0.15 + (0.25 * greenIntensity),
                                          ),
                                          blurRadius: 8 + (8 * greenIntensity),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_rounded,
                                          color: isDark ? const Color(0xFF5CE6A1) : M3ExpressiveTheme.oneUiMint,
                                          size: 20,
                                        ),
                                        const SizedBox(height: 4),
                                        RotatedBox(
                                          quarterTurns: 3,
                                          child: Text(
                                            strings.keep,
                                            style: TextStyle(
                                              color: isDark ? const Color(0xFF5CE6A1) : M3ExpressiveTheme.oneUiMint,
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
                            ),
                          ],
                        ),
                      ),

                      // Rodapé com os 3 botões primários conectados à animação do card ativo e Desfazer
                      QuickActionsBar(
                        canUndo: controller.canUndo,
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
                              duration: const Duration(milliseconds: 900),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              content: Row(
                                children: [
                                  const Icon(Icons.undo_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(strings.undoRestored),
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
