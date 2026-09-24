import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';

/// Barra de ações de rodapé com os 3 controles primários:
/// - Excluir / Delete (Esquerda, vermelho, com animação de toque)
/// - Desfazer / Undo (Centro, pill, com animação de toque)
/// - Manter / Keep (Direita, verde, com animação de toque)
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
    final strings = AppStrings.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botão Excluir (Soft-Delete) - Destaque Vermelho com animação tátil
          _AnimatedActionButton(
            onTap: onSwipeLeft,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton.filledTonal(
                iconSize: 32,
                padding: const EdgeInsets.all(18),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDAD6),
                  foregroundColor: const Color(0xFFBA1A1A),
                  shape: const CircleBorder(),
                  elevation: 0,
                ),
                icon: const Icon(Icons.close_rounded),
                tooltip: strings.deleteTooltip,
                onPressed: null, // Ação gerenciada por _AnimatedActionButton
              ),
            ),
          ),

          // Botão Desfazer (Undo) M3 Expressivo - Centro com animação tátil
          _AnimatedActionButton(
            onTap: canUndo ? onUndo : null,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                boxShadow: canUndo
                    ? [
                        BoxShadow(
                          color: colorScheme.secondary.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                  ),
                  backgroundColor: canUndo
                      ? colorScheme.secondaryContainer
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                ),
                onPressed: null, // Ação gerenciada por _AnimatedActionButton
                icon: Icon(
                  Icons.undo_rounded,
                  size: 22,
                  color: canUndo
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                ),
                label: Text(
                  strings.undo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: canUndo
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),

          // Botão Manter - Destaque Verde com animação tátil
          _AnimatedActionButton(
            onTap: onSwipeRight,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton.filledTonal(
                iconSize: 32,
                padding: const EdgeInsets.all(18),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFC8E6C9),
                  foregroundColor: const Color(0xFF1B5E20),
                  shape: const CircleBorder(),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_rounded),
                tooltip: strings.keepTooltip,
                onPressed: null, // Ação gerenciada por _AnimatedActionButton
              ),
            ),
          ),
        ],
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
