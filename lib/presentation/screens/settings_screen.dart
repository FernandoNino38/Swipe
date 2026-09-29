import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/controllers/triage_controller.dart';

/// Tela de Configurações centralizada do aplicativo Swipe:
/// - Aparência (Modo Claro / Escuro / Sistema)
/// - Idioma (Português / Inglês)
/// - Preferências de Triagem (Limite de fotos por lote e memória persistente)
/// - Créditos de IA (Antigravity - Google DeepMind & Fernando Nino)
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
            fontWeight: FontWeight.w700,
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
          // SEÇÃO 1: APARÊNCIA
          _buildSectionHeader(context, strings.appearance, Icons.palette_outlined),
          const SizedBox(height: 8),
          _buildCard(
            context,
            child: Column(
              children: [
                _buildRadioTile<ThemeMode>(
                  context,
                  title: strings.themeSystem,
                  subtitle: isDark ? 'Modo escuro ativo pelo sistema' : 'Modo claro ativo pelo sistema',
                  icon: Icons.brightness_auto_rounded,
                  value: ThemeMode.system,
                  groupValue: controller.themeMode,
                  onChanged: (mode) {
                    if (mode != null) {
                      HapticFeedback.selectionClick();
                      controller.setThemeMode(mode);
                    }
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildRadioTile<ThemeMode>(
                  context,
                  title: strings.themeLight,
                  subtitle: 'Tema com superfícies limpas e claras',
                  icon: Icons.light_mode_rounded,
                  value: ThemeMode.light,
                  groupValue: controller.themeMode,
                  onChanged: (mode) {
                    if (mode != null) {
                      HapticFeedback.selectionClick();
                      controller.setThemeMode(mode);
                    }
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildRadioTile<ThemeMode>(
                  context,
                  title: strings.themeDark,
                  subtitle: 'Tema escuro AMOLED profundo com economia de bateria',
                  icon: Icons.dark_mode_rounded,
                  value: ThemeMode.dark,
                  groupValue: controller.themeMode,
                  onChanged: (mode) {
                    if (mode != null) {
                      HapticFeedback.selectionClick();
                      controller.setThemeMode(mode);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // SEÇÃO 2: IDIOMA
          _buildSectionHeader(context, strings.language, Icons.language_rounded),
          const SizedBox(height: 8),
          _buildCard(
            context,
            child: Column(
              children: [
                _buildRadioTile<String>(
                  context,
                  title: strings.portuguese,
                  subtitle: 'Português',
                  icon: Icons.translate_rounded,
                  value: 'pt',
                  groupValue: strings.isEnglish ? 'en' : 'pt',
                  onChanged: (lang) {
                    if (lang != null && strings.isEnglish) {
                      HapticFeedback.selectionClick();
                      controller.toggleLocale();
                    }
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildRadioTile<String>(
                  context,
                  title: strings.english,
                  subtitle: 'English',
                  icon: Icons.g_translate_rounded,
                  value: 'en',
                  groupValue: strings.isEnglish ? 'en' : 'pt',
                  onChanged: (lang) {
                    if (lang != null && !strings.isEnglish) {
                      HapticFeedback.selectionClick();
                      controller.toggleLocale();
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // SEÇÃO 3: PREFERÊNCIAS DE TRIAGEM
          _buildSectionHeader(context, strings.triagePreferences, Icons.tune_rounded),
          const SizedBox(height: 8),
          _buildCard(
            context,
            child: Column(
              children: [
                // Limite de Lote
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.photo_library_outlined, size: 22, color: colorScheme.primary),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.batchLimit,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [20, 40, 60, 100, 0].map((limit) {
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
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Memória de Fotos Mantidas
                SwitchListTile.adaptive(
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

                if (controller.persistentKeptCount > 0) ...[
                  const Divider(height: 1, indent: 56),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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

          const SizedBox(height: 24),

          // SEÇÃO 4: SOBRE & CRÉDITOS DE IA
          _buildSectionHeader(context, strings.aboutApp, Icons.info_outline_rounded),
          const SizedBox(height: 8),
          _buildCard(
            context,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 52,
                          height: 52,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.photo_library_rounded, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Swipe',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${strings.appVersion} 0.11.1',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1F2432)
                          : const Color(0xFFF0F4FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2E3548) : const Color(0xFFDCE3F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.smart_toy_rounded, color: Color(0xFF4285F4), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                strings.aiCreditsTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          strings.aiCreditsSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.code_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        'github.com/FernandoNino38/Swipe',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161922) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF262A36) : const Color(0xFFE5E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: child,
      ),
    );
  }

  Widget _buildRadioTile<T>(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                  width: isSelected ? 6.5 : 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
