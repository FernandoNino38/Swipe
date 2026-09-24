import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/models/triage_item.dart';
import 'metadata_pill.dart';

/// Card interativo de triagem com física de arrasto, rotação angular proporcional,
/// badges táteis de decisão e retorno elástico (M3 Expressive Motion).
class TriageCard extends StatefulWidget {
  final TriageItem item;
  final Uint8List? cachedBytes;
  final bool isTopCard;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeLeft;
  final VoidCallback onTapDetail;

  const TriageCard({
    super.key,
    required this.item,
    this.cachedBytes,
    required this.isTopCard,
    required this.onSwipeRight,
    required this.onSwipeLeft,
    required this.onTapDetail,
  });

  @override
  State<TriageCard> createState() => _TriageCardState();
}

class _TriageCardState extends State<TriageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _rotationAnimation;

  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0.0;
  bool _isExiting = false;

  static const double swipeThreshold = 130.0;
  static const double velocityThreshold = 750.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isTopCard || _isExiting) return;

    setState(() {
      _dragOffset += details.delta;
      // Rotação proporcional ao deslocamento horizontal
      _dragAngle = (_dragOffset.dx / 320.0).clamp(-0.25, 0.25);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isTopCard || _isExiting) return;

    final dx = _dragOffset.dx;
    final vx = details.velocity.pixelsPerSecond.dx;

    if (dx > swipeThreshold || vx > velocityThreshold) {
      _flingCard(1.0); // Fuga para a direita (Manter)
    } else if (dx < -swipeThreshold || vx < -velocityThreshold) {
      _flingCard(-1.0); // Fuga para a esquerda (Excluir)
    } else {
      _snapBack(); // Retorno elástico à posição central
    }
  }

  void _flingCard(double direction) {
    _isExiting = true;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset = Offset(direction * (screenWidth + 250), _dragOffset.dy * 1.2);
    final targetAngle = direction * 0.45;

    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: targetOffset,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: _dragAngle,
      end: targetAngle,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
    );

    _animController.forward().then((_) {
      if (direction > 0) {
        widget.onSwipeRight();
      } else {
        widget.onSwipeLeft();
      }
    });
  }

  void _snapBack() {
    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack, // Curva de mola elástica M3
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: _dragAngle,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.reset();
    _animController.addListener(() {
      setState(() {
        _dragOffset = _offsetAnimation.value;
        _dragAngle = _rotationAnimation.value;
      });
    });

    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double dragProgress = (_dragOffset.dx / swipeThreshold).clamp(-1.0, 1.0);

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: widget.onTapDetail,
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: _dragAngle,
          alignment: Alignment.bottomCenter,
          child: Hero(
            tag: 'photo_${widget.item.id}',
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.cardBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(M3ExpressiveTheme.cardBorderRadius),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagem da Foto
                      _buildImageContent(),

                      // Degradê de alto contraste na base para leitura dos metadados M3
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 180,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.85),
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Overlay de Metadados e Informações do Arquivo
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                MetadataPill(
                                  icon: Icons.calendar_today_rounded,
                                  label: widget.item.formattedDate,
                                ),
                                MetadataPill(
                                  icon: Icons.access_time_rounded,
                                  label: widget.item.formattedTime,
                                ),
                                MetadataPill(
                                  icon: Icons.sd_card_rounded,
                                  label: widget.item.formattedSize,
                                ),
                                MetadataPill(
                                  icon: Icons.aspect_ratio_rounded,
                                  label: widget.item.formattedResolution,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Badge Dinâmico de Decisão: "MANTER" (Direita)
                      if (dragProgress > 0)
                        Positioned(
                          top: 40,
                          left: 32,
                          child: Opacity(
                            opacity: dragProgress.abs().clamp(0.0, 1.0),
                            child: Transform.rotate(
                              angle: -0.2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: M3ExpressiveTheme.positiveActionColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppStrings.of(context).keep,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Badge Dinâmico de Decisão: "EXCLUIR" (Esquerda)
                      if (dragProgress < 0)
                        Positioned(
                          top: 40,
                          right: 32,
                          child: Opacity(
                            opacity: dragProgress.abs().clamp(0.0, 1.0),
                            child: Transform.rotate(
                              angle: 0.2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: M3ExpressiveTheme.negativeActionColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppStrings.of(context).delete,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (widget.cachedBytes != null) {
      return Image.memory(
        widget.cachedBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (widget.item.assetEntity != null) {
      return AssetEntityImage(
        widget.item.assetEntity!,
        isOriginal: false,
        thumbnailSize: const ThumbnailSize(1080, 1920),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade900,
          child: const Center(
            child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.white38),
          ),
        ),
      );
    }

    if (widget.item.mockImageUrl != null) {
      return Image.network(
        widget.item.mockImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
      );
    }

    return Container(
      color: Colors.grey.shade900,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.white38),
      ),
    );
  }
}
