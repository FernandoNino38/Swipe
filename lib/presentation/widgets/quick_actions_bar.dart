import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';

/// Barra de ações de rodapé com design de Cápsula Flutuante One UI 9 (Now Island / Floating Pill):
/// - Contêiner flutuante com efeito vidro fosco (BackdropFilter blur) e bordas squircle
/// - Excluir / Delete (Esquerda, botão squircle com acento Coral Red)
/// - Desfazer / Undo (Centro, pill com acento Samsung Blue)
/// - Manter / Keep (Direita, botão squircle com acento Emerald Mint)
class QuickActionsBar extends StatelessWidget {
  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const QuickActionsBar({
    super.key,
    required this.canUndo,
    required this.onUndo,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161922).withValues(alpha: 0.82)
                    : Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.7),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botão Excluir (Soft-Delete) - Squircle One UI Coral Red
                  _AnimatedActionButton(
                    onTap: onSwipeLeft,
                    child: Container(
                      width: 54,
                      height: 54,
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
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        iconSize: 26,
                        color: isDark
                            ? const Color(0xFFFF8585)
                            : M3ExpressiveTheme.oneUiCoral,
                        icon: const Icon(Icons.close_rounded),
                        tooltip: strings.deleteTooltip,
                        onPressed: null, // Ação gerenciada por _AnimatedActionButton
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Botão Desfazer (Undo) - One UI Pill Button
                  _AnimatedActionButton(
                    onTap: canUndo ? onUndo : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: canUndo
                            ? (isDark
                                ? const Color(0xFF102A4A)
                                : const Color(0xFFE5F1FF))
                            : (isDark
                                ? const Color(0xFF1D212B)
                                : const Color(0xFFEFF1F6)),
                        borderRadius: BorderRadius.circular(26),
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
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.undo_rounded,
                            size: 20,
                            color: canUndo
                                ? (isDark
                                    ? const Color(0xFF70B1FF)
                                    : M3ExpressiveTheme.oneUiBlue)
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            strings.undo,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: -0.1,
                              color: canUndo
                                  ? (isDark
                                      ? const Color(0xFF70B1FF)
                                      : M3ExpressiveTheme.oneUiBlue)
                                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Botão Manter - Squircle One UI Emerald Mint
                  _AnimatedActionButton(
                    onTap: onSwipeRight,
                    child: Container(
                      width: 54,
                      height: 54,
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
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        iconSize: 26,
                        color: isDark
                            ? const Color(0xFF5CE6A1)
                            : M3ExpressiveTheme.oneUiMint,
                        icon: const Icon(Icons.check_rounded),
                        tooltip: strings.keepTooltip,
                        onPressed: null, // Ação gerenciada por _AnimatedActionButton
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
  final VoidCallback? onTap;

  const _AnimatedActionButton({required this.child, this.onTap});

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
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 140),
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
