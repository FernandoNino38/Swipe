import 'package:flutter/material.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/models/album_item.dart';

/// Barra de ações rápidas no rodapé da visualização principal:
/// - Atalhos de pastas rápidas (Chips expressivos com rolagem horizontal)
/// - Botões de ação direta (Excluir, Desfazer / Undo, Manter)
class QuickActionsBar extends StatelessWidget {
  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final ValueChanged<AlbumItem> onSelectAlbum;

  const QuickActionsBar({
    super.key,
    required this.canUndo,
    required this.onUndo,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSelectAlbum,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Linha 1: Pastas Rápidas (Chips M3 Expressive)
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: AlbumItem.defaultAlbums.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final album = AlbumItem.defaultAlbums[index];
              return ActionChip(
                avatar: Icon(
                  album.icon,
                  size: 18,
                  color: album.accentColor ?? colorScheme.primary,
                ),
                label: Text(album.name),
                onPressed: () => onSelectAlbum(album),
                backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.75),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.chipBorderRadius),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Linha 2: Controles Primários (Excluir, Desfazer, Manter)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botão Excluir (Soft-Delete)
              IconButton.filledTonal(
                iconSize: 28,
                padding: const EdgeInsets.all(16),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Descartar / Excluir',
                onPressed: onSwipeLeft,
              ),

              // Botão Desfazer (Undo) M3 Expressivo
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
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
                  color: canUndo ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                label: Text(
                  'Desfazer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: canUndo ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),

              // Botão Manter
              IconButton.filledTonal(
                iconSize: 28,
                padding: const EdgeInsets.all(16),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.check_rounded),
                tooltip: 'Manter Foto',
                onPressed: onSwipeRight,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
