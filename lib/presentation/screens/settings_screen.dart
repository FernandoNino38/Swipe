import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/controllers/triage_controller.dart';

/// Tela de Configurações redesenhada no padrão Material 3 Expressive:
/// - Superfícies tonais adaptativas (surfaceContainerLow e surfaceContainerHigh)
/// - Contêineres de cartões sem bordas duras com raio amplo (28dp)
/// - Seletores segmentados expressivos para Tema, Idioma e Ajuste de Imagem
/// - Switches com ícones visuais expressivos
/// - Seção Sobre compacta com versão e link para o GitHub
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.watch<TriageController>();
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.settings,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // SEÇÃO 1: APARÊNCIA (Segmented Button Group Expressivo)
          _buildSectionHeader(context, strings.appearance, Icons.palette_outlined),
          const SizedBox(height: 10),
          _buildTonalCard(
            context,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.themeMode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getThemeDescription(controller.themeMode, isDark, strings),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text(strings.themeSystem),
                          icon: const Icon(Icons.brightness_auto_rounded),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text(strings.themeLight),
                          icon: const Icon(Icons.light_mode_rounded),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text(strings.themeDark),
                          icon: const Icon(Icons.dark_mode_rounded),
                        ),
                      ],
                      selected: {controller.themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        HapticFeedback.selectionClick();
                        controller.setThemeMode(newSelection.first);
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: colorScheme.primary,
                        selectedForegroundColor: colorScheme.onPrimary,
                        backgroundColor: isDark
                            ? colorScheme.surfaceContainerHighest
                            : colorScheme.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // SEÇÃO 2: IDIOMA (Segmented Button Group Expressivo)
          _buildSectionHeader(context, strings.language, Icons.language_rounded),
          const SizedBox(height: 10),
          _buildTonalCard(
            context,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.language,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.isEnglish ? strings.languageSubtitleEn : strings.languageSubtitlePt,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment<String>(
                          value: 'pt',
                          label: Text(strings.portuguese),
                          icon: const Icon(Icons.translate_rounded),
                        ),
                        ButtonSegment<String>(
                          value: 'en',
                          label: Text(strings.english),
                          icon: const Icon(Icons.g_translate_rounded),
                        ),
                      ],
                      selected: {strings.isEnglish ? 'en' : 'pt'},
                      onSelectionChanged: (Set<String> newSelection) {
                        final val = newSelection.first;
                        if ((val == 'en' && !strings.isEnglish) || (val == 'pt' && strings.isEnglish)) {
                          HapticFeedback.selectionClick();
                          controller.toggleLocale();
                        }
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: colorScheme.primary,
                        selectedForegroundColor: colorScheme.onPrimary,
                        backgroundColor: isDark
                            ? colorScheme.surfaceContainerHighest
                            : colorScheme.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // SEÇÃO 3: PREFERÊNCIAS DE TRIAGEM
          _buildSectionHeader(context, strings.triagePreferences, Icons.tune_rounded),
          const SizedBox(height: 10),
          _buildTonalCard(
            context,
            child: Column(
              children: [
                // Limite de Lote por Sessão (Batch Limit)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.photo_library_outlined, size: 22, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.batchLimit,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  strings.batchLimitPrompt,
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: TriageController.availableBatchLimits.map((limit) {
                            final isSelected = controller.batchLimit == limit;
                            final label = limit == 0 ? strings.allPhotosOption : '$limit';
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(label),
                                selected: isSelected,
                                onSelected: (_) {
                                  HapticFeedback.selectionClick();
                                  controller.setBatchLimit(limit);
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.chipBorderRadius),
                                ),
                                showCheckmark: true,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, indent: 16, endIndent: 16),

                // Modo de Exibição das Fotos (Smart Fit vs Fill Screen)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.aspect_ratio_rounded, size: 22, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.imageDisplayMode,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  strings.imageDisplayModeDesc,
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<bool>(
                          segments: [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text(strings.fitMode.split('(').first.trim()),
                              icon: const Icon(Icons.fit_screen_rounded),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text(strings.fillMode.split('(').first.trim()),
                              icon: const Icon(Icons.crop_free_rounded),
                            ),
                          ],
                          selected: {controller.isFitMode},
                          onSelectionChanged: (Set<bool> newSelection) {
                            HapticFeedback.selectionClick();
                            controller.setFitMode(newSelection.first);
                          },
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: colorScheme.primary,
                            selectedForegroundColor: colorScheme.onPrimary,
                            backgroundColor: isDark
                                ? colorScheme.surfaceContainerHighest
                                : colorScheme.surfaceContainerHigh,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, indent: 16, endIndent: 16),

                // Memória de Fotos Mantidas (Ocultar já mantidas)
                SwitchListTile(
                  secondary: Icon(Icons.history_rounded, color: colorScheme.primary),
                  title: Text(
                    strings.hideKeptPhotos,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Text(
                    strings.hideKeptPhotosDesc,
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  value: controller.hideKeptPhotos,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    controller.toggleHideKeptPhotos();
                  },
                ),

                // Botão de Limpar Histórico de Fotos Mantidas
                if (controller.persistentKeptCount > 0) ...[
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.delete_sweep_rounded, color: M3ExpressiveTheme.oneUiCoral),
                    title: Text(
                      strings.resetKeptHistory,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: M3ExpressiveTheme.oneUiCoral,
                      ),
                    ),
                    subtitle: Text(
                      strings.totalKeptCount(controller.persistentKeptCount),
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(strings.resetKeptHistory),
                          content: Text(strings.resetKeptHistoryConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(strings.cancel),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: M3ExpressiveTheme.oneUiCoral,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(strings.confirm),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        HapticFeedback.mediumImpact();
                        await controller.clearKeptHistory();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(strings.keptHistoryCleared),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SEÇÃO 4: SOBRE (M3 Expressive Minimalist Card)
          _buildTonalCard(
            context,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 64,
                      height: 64,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Swipe',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${strings.appVersion} 0.14.0',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _launchUrl('https://github.com/FernandoNino38/Swipe'),
                      icon: const Icon(Icons.code_rounded, size: 18),
                      label: Text(
                        strings.viewOnGitHub,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  String _getThemeDescription(ThemeMode mode, bool isDark, AppStrings strings) {
    switch (mode) {
      case ThemeMode.system:
        return strings.themeSystemDesc(isDark);
      case ThemeMode.light:
        return strings.themeLightDesc;
      case ThemeMode.dark:
        return strings.themeDarkDesc;
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTonalCard(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainer
            : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(M3ExpressiveTheme.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(M3ExpressiveTheme.cardBorderRadius),
        child: child,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
