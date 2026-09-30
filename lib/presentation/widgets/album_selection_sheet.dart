import 'package:flutter/material.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/media_service.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/controllers/triage_controller.dart';

/// Modal Bottom Sheet no padrão Samsung One UI 9 (Grouped Settings Islands) para seleção de álbuns e configurações
class AlbumSelectionSheet extends StatelessWidget {
  final TriageController controller;

  const AlbumSelectionSheet({
    super.key,
    required this.controller,
  });

  static Future<void> show(BuildContext context, TriageController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(M3ExpressiveTheme.sheetBorderRadius),
        ),
      ),
      builder: (_) => AlbumSelectionSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final albums = controller.availableAlbums;
    final selected = controller.selectedAlbum;
    final strings = AppStrings.of(context);

    final cardBg = isDark ? colorScheme.surfaceContainerHigh : colorScheme.surfaceContainerLowest;
    final cardBorder = isDark ? colorScheme.outlineVariant.withValues(alpha: 0.3) : colorScheme.outlineVariant.withValues(alpha: 0.5);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 18, right: 18, bottom: 24, top: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho de Área de Visualização
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  strings.selectAlbum,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Grouped Card 1: Preferências de Sessão (Batch Limit e Ordenação)
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.cardBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Limite por Sessão (Review Limit) com Alto Contraste
                    Row(
                      children: [
                        Icon(
                          Icons.timelapse_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.batchLimit,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                strings.batchLimitPrompt,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: TriageController.availableBatchLimits.map((limit) {
                          final isSelected = controller.batchLimit == limit;
                          final label = limit == 0 ? strings.allPhotosOption : '$limit';
                          return _buildSelectableChip(
                            context: context,
                            isSelected: isSelected,
                            label: label,
                            isDark: isDark,
                            onTap: () {
                              controller.setBatchLimit(limit);
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Divider(
                        color: cardBorder,
                        height: 1,
                      ),
                    ),

                    // Ordenar Por com Alto Contraste
                    Row(
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          strings.sortBy,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSelectableChip(
                            context: context,
                            isSelected: controller.sortOrder == PhotoSortOrder.newest,
                            label: strings.sortNewest,
                            icon: Icons.schedule_rounded,
                            isDark: isDark,
                            onTap: () {
                              controller.setSortOrder(PhotoSortOrder.newest);
                            },
                          ),
                          _buildSelectableChip(
                            context: context,
                            isSelected: controller.sortOrder == PhotoSortOrder.largest,
                            label: strings.sortLargest,
                            icon: Icons.data_usage_rounded,
                            isDark: isDark,
                            onTap: () {
                              controller.setSortOrder(PhotoSortOrder.largest);
                            },
                          ),
                          _buildSelectableChip(
                            context: context,
                            isSelected: controller.sortOrder == PhotoSortOrder.oldest,
                            label: strings.sortOldest,
                            icon: Icons.history_rounded,
                            isDark: isDark,
                            onTap: () {
                              controller.setSortOrder(PhotoSortOrder.oldest);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Grouped Card 2: Histórico de Fotos Mantidas
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.cardBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        strings.hideKeptPhotos,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        strings.hideKeptPhotosDesc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      value: controller.hideKeptPhotos,
                      activeThumbColor: M3ExpressiveTheme.oneUiBlue,
                      onChanged: (_) {
                        controller.toggleHideKeptPhotos();
                      },
                    ),
                    if (controller.persistentKeptCount > 0) ...[
                      Divider(color: cardBorder, height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 16,
                                color: M3ExpressiveTheme.oneUiMint,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                strings.totalKeptCount(controller.persistentKeptCount),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              visualDensity: VisualDensity.compact,
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
                                      style: FilledButton.styleFrom(
                                        backgroundColor: M3ExpressiveTheme.oneUiCoral,
                                      ),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(strings.confirmBtn),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await controller.clearKeptHistory();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(strings.keptHistoryCleared),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(
                              strings.resetKeptHistory,
                              style: const TextStyle(
                                color: M3ExpressiveTheme.oneUiCoral,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Grouped Card 3: Lista de Álbuns
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.cardBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: albums.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            strings.noAlbumsFound,
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: albums.length,
                        separatorBuilder: (context, index) => Divider(
                          color: cardBorder,
                          height: 1,
                          indent: 64,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          final album = albums[index];
                          final isSelected = selected?.id == album.id;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primaryContainer
                                    : (isDark
                                        ? const Color(0xFF222735)
                                        : const Color(0xFFECEEF5)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                isSelected
                                    ? Icons.folder_special_rounded
                                    : Icons.folder_outlined,
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              album.localizedName(strings),
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF222735)
                                        : const Color(0xFFECEEF5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    strings.albumPhotos(album.assetCount),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: colorScheme.primary,
                                    size: 22,
                                  ),
                                ],
                              ],
                            ),
                            onTap: () {
                              controller.selectAlbum(album);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableChip({
    required BuildContext context,
    required bool isSelected,
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    bool isDark = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : (isDark ? const Color(0xFF232838) : const Color(0xFFEFF2F8)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? (isDark ? Colors.white.withValues(alpha: 0.35) : colorScheme.primary)
                    : (isDark ? const Color(0xFF38435C) : const Color(0xFFCCD4E3)),
                width: isSelected ? 1.5 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
                  )
                else if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      icon,
                      size: 16,
                      color: isDark ? const Color(0xFFB0BACD) : const Color(0xFF555F74),
                    ),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? const Color(0xFFE2E7F5) : const Color(0xFF1E2533)),
                    letterSpacing: -0.1,
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
