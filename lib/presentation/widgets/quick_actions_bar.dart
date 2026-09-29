import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';

/// Barra de ações inferior completa e unificada:
/// 1. Lixeira (Acesso à tela de revisão/descartes com badge)
/// 2. Deletar / Excluir (Soft-Delete do card atual com swipe para a esquerda)
/// 3. Desfazer / Undo (Reversão elástica da última ação)
/// 4. Manter (Keep do card atual com swipe para a direita)
/// 5. Favorito (Favorita a foto atual com badge e toque longo para ver galeria de favoritos)
class QuickActionsBar extends StatelessWidget {
  final bool canUndo;
  final int trashCount;
  final int favoritesCount;
  final VoidCallback onUndo;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onOpenTrash;
  final VoidCallback onFavorite;
  final VoidCallback onOpenFavorites;

  const QuickActionsBar({
    super.key,
    required this.canUndo,
    required this.trashCount,
    required this.favoritesCount,
    required this.onUndo,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onOpenTrash,
    required this.onFavorite,
    required this.onOpenFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 8),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141720).withValues(alpha: 0.86)
                    : Colors.white.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(38),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. BOTÃO LIXEIRA (Com Badge)
                  _AnimatedActionButton(
                    tooltip: strings.reviewTrash,
                    onTap: onOpenTrash,
                    child: Badge(
                      isLabelVisible: trashCount > 0,
                      label: Text(
                        '$trashCount',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                      backgroundColor: M3ExpressiveTheme.oneUiCoral,
                      offset: const Offset(-2, 2),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF24181B)
                              : const Color(0xFFFDE8E8),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF452227)
                                : const Color(0xFFF8C8C8),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 22,
                          color: isDark
                              ? const Color(0xFFFF8585)
                              : M3ExpressiveTheme.oneUiCoral,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 2. BOTÃO EXCLUIR (Card Swipe Left)
                  _AnimatedActionButton(
                    tooltip: strings.deleteTooltip,
                    onTap: onSwipeLeft,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF381518)
                            : const Color(0xFFFFE8E8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF5A2227)
                              : const Color(0xFFFFD0D0),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: M3ExpressiveTheme.oneUiCoral.withValues(alpha: isDark ? 0.25 : 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 26,
                        color: isDark
                            ? const Color(0xFFFF8585)
                            : M3ExpressiveTheme.oneUiCoral,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 3. BOTÃO DESFAZER (Undo Central)
                  _AnimatedActionButton(
                    tooltip: strings.undo,
                    onTap: canUndo ? onUndo : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: canUndo
                            ? (isDark
                                ? const Color(0xFF102A4A)
                                : const Color(0xFFE5F1FF))
                            : (isDark
                                ? const Color(0xFF1D212B)
                                : const Color(0xFFEFF1F6)),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: canUndo
                              ? (isDark
                                  ? const Color(0xFF1E4B82)
                                  : const Color(0xFFCCE4FF))
                              : Colors.transparent,
                          width: 1.0,
                        ),
                        boxShadow: canUndo
                            ? [
                                BoxShadow(
                                  color: M3ExpressiveTheme.oneUiBlue.withValues(alpha: isDark ? 0.25 : 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.undo_rounded,
                        size: 22,
                        color: canUndo
                            ? (isDark
                                ? const Color(0xFF70B1FF)
                                : M3ExpressiveTheme.oneUiBlue)
                            : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 4. BOTÃO MANTER (Card Swipe Right)
                  _AnimatedActionButton(
                    tooltip: strings.keepTooltip,
                    onTap: onSwipeRight,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF102E21)
                            : const Color(0xFFE7F9F0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1B4E38)
                              : const Color(0xFFC4F2DB),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: M3ExpressiveTheme.oneUiMint.withValues(alpha: isDark ? 0.25 : 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 26,
                        color: isDark
                            ? const Color(0xFF5CE6A1)
                            : M3ExpressiveTheme.oneUiMint,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 5. BOTÃO FAVORITO (Com Toque Longo para Ver e Badge)
                  _AnimatedActionButton(
                    tooltip: strings.favoriteTooltip,
                    onTap: onFavorite,
                    onLongPress: onOpenFavorites,
                    child: Badge(
                      isLabelVisible: favoritesCount > 0,
                      label: Text(
                        '$favoritesCount',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                      backgroundColor: M3ExpressiveTheme.oneUiRose,
                      offset: const Offset(-2, 2),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2E1520)
                              : const Color(0xFFFFEBF2),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF501E30)
                                : const Color(0xFFFFCCD9),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 22,
                          color: isDark
                              ? const Color(0xFFFF6699)
                              : M3ExpressiveTheme.oneUiRose,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final Widget child;
  final String? tooltip;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _AnimatedActionButton({
    required this.child,
    this.tooltip,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
      onLongPress: widget.onLongPress != null
          ? () {
              _controller.reverse();
              widget.onLongPress!();
            }
          : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: content,
      );
    }
    return content;
  }
}
