import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/m3_expressive_theme.dart';
import 'domain/controllers/triage_controller.dart';
import 'presentation/screens/deck_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PhotoTriageApp());
}

class PhotoTriageApp extends StatelessWidget {
  final TriageController? controller;

  const PhotoTriageApp({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => controller ?? (TriageController()..initialize()),
        ),
      ],
      child: const _PhotoTriageAppView(),
    );
  }
}

class _PhotoTriageAppView extends StatelessWidget {
  const _PhotoTriageAppView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TriageController>();

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Prioriza o Dynamic Color contextual da foto atual (se disponível),
        // caso contrário utiliza a paleta do sistema do usuário (Material You / Monet)
        final effectiveLight = controller.contextualColorScheme ?? lightDynamic;
        final effectiveDark = controller.contextualColorScheme != null
            ? ColorScheme.fromSeed(
                seedColor: controller.contextualColorScheme!.primary,
                brightness: Brightness.dark,
              )
            : darkDynamic;

        return MaterialApp(
          title: 'Swipe',
          debugShowCheckedModeBanner: false,
          theme: M3ExpressiveTheme.buildTheme(
            dynamicColorScheme: effectiveLight,
            brightness: Brightness.light,
          ),
          darkTheme: M3ExpressiveTheme.buildTheme(
            dynamicColorScheme: effectiveDark,
            brightness: Brightness.dark,
          ),
          themeMode: ThemeMode.system,
          locale: controller.customLocale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt'),
            Locale('pt', 'BR'),
            Locale('en'),
            Locale('en', 'US'),
          ],
          home: const DeckScreen(),
        );
      },
    );
  }
}
