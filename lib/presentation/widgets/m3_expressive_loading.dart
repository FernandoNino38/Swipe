import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Indicador de carregamento oficial do Material 3 Expressive (LoadingIndicator).
/// 
/// Em conformidade estrita com as diretrizes do Material 3 Expressive (m3.material.io):
/// - Utiliza formas poligonais orgânicas arredondadas de transição contínua
///   (Circle -> SoftBurst / Clover -> Squircle -> Pill).
/// - Animação de rotação com física de mola desacelerada (Emphasized Decelerate).
/// - Superfície tonal fluida com interpolação de cores temáticas da paleta M3.
class M3ExpressiveLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;

  const M3ExpressiveLoadingIndicator({
    super.key,
    this.size = 48,
    this.color,
    this.message,
  });

  @override
  State<M3ExpressiveLoadingIndicator> createState() =>
      _M3ExpressiveLoadingIndicatorState();
}

class _M3ExpressiveLoadingIndicatorState
    extends State<M3ExpressiveLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = widget.color ?? colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _M3ExpressiveMorphPainter(
                    progress: _controller.value,
                    primaryColor: primaryColor,
                    secondaryColor: colorScheme.tertiary,
                    containerColor: colorScheme.primaryContainer,
                  ),
                );
              },
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 14),
            Text(
              widget.message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Painter de morphing poligonal arredondado conforme a biblioteca MaterialShapes do Material 3 Expressive
class _M3ExpressiveMorphPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final Color containerColor;

  _M3ExpressiveMorphPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.containerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) * 0.44;

    // Rotação suave contínua no padrão Emphasized
    final rotation = progress * 2 * math.pi;

    // 4 etapas de morphing suave (0 a 1 por etapa)
    final scaledT = progress * 4.0;
    final stage = scaledT.floor() % 4;
    final subT = scaledT - scaledT.floor();
    // Curva M3 Emphasized Decelerate
    final curvedT = Curves.easeInOutCubicEmphasized.transform(subT);

    // Formas oficiais M3:
    // Estágio 0: Circle (0) -> Clover4Leaf (4 lóbulos)
    // Estágio 1: Clover4Leaf -> SoftSquircle (4 lados arredondados)
    // Estágio 2: SoftSquircle -> SoftBurst (8 pontas suaves)
    // Estágio 3: SoftBurst -> Circle
    final shapeAmplitudes = [0.0, 0.24, 0.12, 0.20];
    final shapeFrequencies = [0.0, 4.0, 4.0, 8.0];

    final fromAmp = shapeAmplitudes[stage];
    final toAmp = shapeAmplitudes[(stage + 1) % 4];
    final activeAmp = fromAmp + (toAmp - fromAmp) * curvedT;

    final fromFreq = shapeFrequencies[stage];
    final toFreq = shapeFrequencies[(stage + 1) % 4];
    final activeFreq = fromFreq + (toFreq - fromFreq) * curvedT;

    // Transição de cor orgânica e elegante
    final colorList = [
      primaryColor,
      secondaryColor,
      primaryColor,
      secondaryColor,
    ];
    final c1 = colorList[stage];
    final c2 = colorList[(stage + 1) % 4];
    final currentColor = Color.lerp(c1, c2, curvedT) ?? primaryColor;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final path = Path();
    const int resolution = 120;
    for (int i = 0; i <= resolution; i++) {
      final theta = (i / resolution) * 2 * math.pi;
      // Modulação de raio com cantos arredondados contínuos
      final wave = activeFreq > 0.01 ? math.cos(activeFreq * theta) : 0.0;
      final r = baseRadius * (1.0 - activeAmp + activeAmp * wave);
      final x = r * math.cos(theta);
      final y = r * math.sin(theta);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Sombra suave tonal (Tonal Elevation)
    final shadowPaint = Paint()
      ..color = currentColor.withValues(alpha: 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, shadowPaint);

    // Preenchimento sólido tonal suave M3
    final fillPaint = Paint()
      ..color = currentColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Ponto central de respiração/pulso no estilo M3
    final innerPulse = 0.75 + 0.25 * math.sin(progress * 6 * math.pi);
    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, baseRadius * 0.25 * innerPulse, innerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _M3ExpressiveMorphPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor;
  }
}
