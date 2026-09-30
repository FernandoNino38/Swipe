import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';

/// Barra de ações inferior inspirada no Floating Toolbar & Action Bar do Material 3 Expressive:
/// - Base tonal sem bordas artificiais, utilizando elevação tonal e superfícies responsivas.
/// - 4 ações táteis com feedback de bouncing por molas (Curves.easeInOutCubicEmphasized / Curves.easeOutBack).
/// - Contêineres tonais e semânticos (ErrorContainer para lixeira, SurfaceContainer para desfazer, Primary/Mint para manter, Rose para favorito).
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
            ? colorScheme.surfaceContainer.withValues(alpha: 0.92)
            : colorScheme.surfaceContainerLowest.withValues(alpha: 0.94),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 1. AÇÃO EXCLUIR (Lixeira em container tonal com cor de erro)
                _M3ExpressiveActionButton(
                  tooltip: strings.deleteTooltip,
                  onTap: onSwipeLeft,
                  width: 60,
                  height: 56,
                  borderRadius: 22,
                  backgroundColor: isDark
                      ? const Color(0xFF381518)
                      : const Color(0xFFFFE8E8),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 26,
                    color: isDark
                        ? const Color(0xFFFF8585)
                        : M3ExpressiveTheme.oneUiCoral,
                  ),
                ),

                // 2. AÇÃO DESFAZER (Container tonal com suporte a histórico)
                _M3ExpressiveActionButton(
                  tooltip: strings.undo,
                  onTap: canUndo ? onUndo : null,
                  width: 56,
                  height: 56,
                  borderRadius: 22,
                  backgroundColor: canUndo
                      ? (isDark ? colorScheme.primaryContainer : const Color(0xFFE5F1FF))
                      : (isDark ? colorScheme.surfaceContainerHigh : colorScheme.surfaceContainerHighest),
                  child: Icon(
                    Icons.undo_rounded,
                    size: 24,
                    color: canUndo
                        ? (isDark ? colorScheme.onPrimaryContainer : M3ExpressiveTheme.oneUiBlue)
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
                  ),
                ),

                // 3. AÇÃO MANTER (Checkmark em container tonal esmeralda)
                _M3ExpressiveActionButton(
                  tooltip: strings.keepTooltip,
                  onTap: onSwipeRight,
                  width: 60,
                  height: 56,
                  borderRadius: 22,
                  backgroundColor: isDark
                      ? const Color(0xFF102E21)
                      : const Color(0xFFE7F9F0),
                  child: Icon(
                    Icons.check_rounded,
                    size: 28,
                    color: isDark
                        ? const Color(0xFF5CE6A1)
                        : M3ExpressiveTheme.oneUiMint,
                  ),
                ),

                // 4. AÇÃO FAVORITO (Coração em container tonal rose com badge)
                _M3ExpressiveActionButton(
                  tooltip: strings.favoriteTooltip,
                  onTap: onFavorite,
                  onLongPress: onOpenFavorites,
                  width: 56,
                  height: 56,
                  borderRadius: 22,
                  backgroundColor: isDark
                      ? const Color(0xFF2E1520)
                      : const Color(0xFFFFEBF2),
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

/// Botão de ação M3 Expressive com feedback háptico e animação de compressão por mola
class _M3ExpressiveActionButton extends StatefulWidget {
  final Widget child;
  final String? tooltip;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;

  const _M3ExpressiveActionButton({
    required this.child,
    this.tooltip,
    this.onTap,
    this.onLongPress,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
  });

  @override
  State<_M3ExpressiveActionButton> createState() => _M3ExpressiveActionButtonState();
}

class _M3ExpressiveActionButtonState extends State<_M3ExpressiveActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shapeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 260),
    );

    // Compressão e retorno elástico com overshoot expressivo
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );

    // Morphing sutil de raio no toque (Expressive shape morph)
    _shapeAnimation = Tween<double>(begin: widget.borderRadius, end: widget.borderRadius + 6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(_shapeAnimation.value),
              ),
              child: Center(child: widget.child),
            ),
          );
        },
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
