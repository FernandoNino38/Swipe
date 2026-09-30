import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';

/// Barra de navegação e ações inferior redesenhada no padrão Material 3 Expressive:
/// - Ocupa a largura total da base da tela (não é mais uma pílula flutuante isolada).
/// - 4 ações principais: Excluir (lixeira destacada), Desfazer (com histórico), Manter (sucesso) e Favorito (com badge).
/// - Todas as interações possuem curvas de bouncing expressivas (Curves.easeOutBack / Curves.easeInOutCubic).
class QuickActionsBar extends StatelessWidget {
  final bool canUndo;
  final int favoritesCount;
  final VoidCallback onUndo;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onFavorite;
  final VoidCallback onOpenFavorites;

  const QuickActionsBar({
    super.key,
    required this.canUndo,
    required this.favoritesCount,
    required this.onUndo,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onFavorite,
    required this.onOpenFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF11141C).withValues(alpha: 0.94)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. BOTÃO EXCLUIR (Ícone de Lixeira com tema Coral)
                _M3ExpressiveButton(
                  tooltip: strings.deleteTooltip,
                  onTap: onSwipeLeft,
                  width: 58,
                  height: 54,
                  backgroundColor: isDark
                      ? const Color(0xFF381518)
                      : const Color(0xFFFFE8E8),
                  borderColor: isDark
                      ? const Color(0xFF5A2227)
                      : const Color(0xFFFFD0D0),
                  shadowColor: M3ExpressiveTheme.oneUiCoral.withValues(
                    alpha: isDark ? 0.30 : 0.18,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 26,
                    color: isDark
                        ? const Color(0xFFFF8585)
                        : M3ExpressiveTheme.oneUiCoral,
                  ),
                ),

                // 2. BOTÃO DESFAZER (Central com feedback tátil)
                _M3ExpressiveButton(
                  tooltip: strings.undo,
                  onTap: canUndo ? onUndo : null,
                  width: 54,
                  height: 54,
                  backgroundColor: canUndo
                      ? (isDark
                          ? const Color(0xFF102A4A)
                          : const Color(0xFFE5F1FF))
                      : (isDark
                          ? const Color(0xFF181B24)
                          : const Color(0xFFEFF1F6)),
                  borderColor: canUndo
                      ? (isDark
                          ? const Color(0xFF1E4B82)
                          : const Color(0xFFCCE4FF))
                      : Colors.transparent,
                  shadowColor: canUndo
                      ? M3ExpressiveTheme.oneUiBlue.withValues(
                          alpha: isDark ? 0.28 : 0.16,
                        )
                      : null,
                  child: Icon(
                    Icons.undo_rounded,
                    size: 24,
                    color: canUndo
                        ? (isDark
                            ? const Color(0xFF70B1FF)
                            : M3ExpressiveTheme.oneUiBlue)
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                  ),
                ),

                // 3. BOTÃO MANTER (Ícone de Checkmark com tema Emerald Mint)
                _M3ExpressiveButton(
                  tooltip: strings.keepTooltip,
                  onTap: onSwipeRight,
                  width: 58,
                  height: 54,
                  backgroundColor: isDark
                      ? const Color(0xFF102E21)
                      : const Color(0xFFE7F9F0),
                  borderColor: isDark
                      ? const Color(0xFF1B4E38)
                      : const Color(0xFFC4F2DB),
                  shadowColor: M3ExpressiveTheme.oneUiMint.withValues(
                    alpha: isDark ? 0.30 : 0.18,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 28,
                    color: isDark
                        ? const Color(0xFF5CE6A1)
                        : M3ExpressiveTheme.oneUiMint,
                  ),
                ),

                // 4. BOTÃO FAVORITO (Com Badge e Toque Longo)
                _M3ExpressiveButton(
                  tooltip: strings.favoriteTooltip,
                  onTap: onFavorite,
                  onLongPress: onOpenFavorites,
                  width: 54,
                  height: 54,
                  backgroundColor: isDark
                      ? const Color(0xFF2E1520)
                      : const Color(0xFFFFEBF2),
                  borderColor: isDark
                      ? const Color(0xFF501E30)
                      : const Color(0xFFFFCCD9),
                  shadowColor: M3ExpressiveTheme.oneUiRose.withValues(
                    alpha: isDark ? 0.28 : 0.16,
                  ),
                  child: Badge(
                    isLabelVisible: favoritesCount > 0,
                    label: Text(
                      '$favoritesCount',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                    backgroundColor: M3ExpressiveTheme.oneUiRose,
                    offset: const Offset(-2, 2),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 24,
                      color: isDark
                          ? const Color(0xFFFF6699)
                          : M3ExpressiveTheme.oneUiRose,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão com animação elástica e física de bouncing no padrão Material 3 Expressive
class _M3ExpressiveButton extends StatefulWidget {
  final Widget child;
  final String? tooltip;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final Color? shadowColor;

  const _M3ExpressiveButton({
    required this.child,
    this.tooltip,
    this.onTap,
    this.onLongPress,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.borderColor,
    this.shadowColor,
  });

  @override
  State<_M3ExpressiveButton> createState() => _M3ExpressiveButtonState();
}

class _M3ExpressiveButtonState extends State<_M3ExpressiveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 240),
    );
    // Curva M3 Expressive com retorno elástico de mola (easeOutBack)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.86).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
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
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.borderColor,
              width: 1.0,
            ),
            boxShadow: widget.shadowColor != null
                ? [
                    BoxShadow(
                      color: widget.shadowColor!,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(child: widget.child),
        ),
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
