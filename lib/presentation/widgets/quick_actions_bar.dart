import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';

/// Barra de ações de rodapé com os 3 controles primários:
/// - Excluir / Delete (Esquerda, vermelho)
/// - Desfazer / Undo (Centro, pill)
/// - Manter / Keep (Direita, verde)
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
          // Botão Excluir (Soft-Delete) - Destaque Vermelho
          IconButton.filledTonal(
            iconSize: 32,
            padding: const EdgeInsets.all(18),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFFDAD6),
              foregroundColor: const Color(0xFFBA1A1A),
              shape: const CircleBorder(),
              elevation: 2,
            ),
            icon: const Icon(Icons.close_rounded),
            tooltip: strings.deleteTooltip,
            onPressed: onSwipeLeft,
          ),

          // Botão Desfazer (Undo) M3 Expressivo - Centro
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
              ),
              backgroundColor: canUndo
                  ? colorScheme.secondaryContainer
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            onPressed: canUndo ? onUndo : null,
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

          // Botão Manter - Destaque Verde
          IconButton.filledTonal(
            iconSize: 32,
            padding: const EdgeInsets.all(18),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFC8E6C9),
              foregroundColor: const Color(0xFF1B5E20),
              shape: const CircleBorder(),
              elevation: 2,
            ),
            icon: const Icon(Icons.check_rounded),
            tooltip: strings.keepTooltip,
            onPressed: onSwipeRight,
          ),
        ],
      ),
    );
  }
}
