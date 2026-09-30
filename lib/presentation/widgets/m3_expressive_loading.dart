import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Indicador de carregamento expressivo no estilo Material 3 Expressive.
/// Apresenta formas geométricas orgânicas (círculo, quadrado arredondado,
/// triângulo arredondado/trevo e pétala) que se transformam continuamente,
/// com transição fluida de cores e pulsação elástica.
class M3ExpressiveLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;

  const M3ExpressiveLoadingIndicator({
    super.key,
    this.size = 54,
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
      duration: const Duration(milliseconds: 2400),
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
                  painter: _M3ExpressiveShapePainter(
                    progress: _controller.value,
                    primaryColor: primaryColor,
                    secondaryColor: colorScheme.tertiary,
                    highlightColor: colorScheme.secondary,
                  ),
                );
              },
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
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

class _M3ExpressiveShapePainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final Color highlightColor;

  _M3ExpressiveShapePainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.42;

    // Rotação suave contínua com pequenas acelerações e desacelerações
    final rotation = progress * 2 * math.pi;

    // Ciclo de 4 fases que morpham o número de pétalas / cantos (círculo -> quadrado -> trevo -> flor)
    // t varia de 0 a 1 em cada quarto de ciclo
    final phase = progress * 4.0;
    final currentPhaseIndex = phase.floor() % 4;
    final t = phase - phase.floor();
    final smoothT = Curves.easeInOutCubic.transform(t);

    // Número de vértices/pétalas entre fases
    final shapeCorners = [4.0, 3.0, 5.0, 4.0];
    final fromCorner = shapeCorners[currentPhaseIndex];
    final toCorner = shapeCorners[(currentPhaseIndex + 1) % 4];
    final activeCorners = fromCorner + (toCorner - fromCorner) * smoothT;

    // Pulsação de escala
    final pulseScale = 0.88 + 0.12 * math.sin(progress * 4 * math.pi);
    final currentRadius = maxRadius * pulseScale;

    // Interpolação de cores expressiva
    final colors = [
      primaryColor,
      highlightColor,
      secondaryColor,
      primaryColor,
    ];
    final c1 = colors[currentPhaseIndex];
    final c2 = colors[(currentPhaseIndex + 1) % 4];
    final activeColor = Color.lerp(c1, c2, smoothT) ?? primaryColor;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final path = Path();
    const steps = 120;
    for (int i = 0; i <= steps; i++) {
      final angle = (i / steps) * 2 * math.pi;
      // Curva superelipse/estrela suave com cantos arredondados
      final cornerWave = math.cos(activeCorners * angle);
      final r = currentRadius * (0.82 + 0.18 * cornerWave);
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Sombra suave expressiva
    final shadowPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, shadowPaint);

    // Preenchimento principal
    final fillPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Borda clara interna expressiva
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, strokePaint);

    // Pequeno centro flutuante
    final innerCenterPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final innerRadius = maxRadius * 0.22 * (0.8 + 0.2 * math.sin(progress * 6 * math.pi));
    canvas.drawCircle(Offset.zero, innerRadius, innerCenterPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _M3ExpressiveShapePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor;
  }
}
