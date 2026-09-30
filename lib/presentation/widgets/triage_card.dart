import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/m3_expressive_theme.dart';
import '../../domain/models/triage_item.dart';
import 'm3_expressive_loading.dart';

typedef DragProgressCallback = void Function(double progress);

/// Card interativo de triagem com física de arrasto, rotação angular proporcional,
/// badges táteis de decisão, transição fluida para o próximo card e retorno elástico (M3 Expressive Motion).
class TriageCard extends StatefulWidget {
  final TriageItem item;
  final Uint8List? cachedBytes;
  final bool isTopCard;
  final bool isFitMode;
  final VoidCallback? onToggleFitMode;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeLeft;
  final VoidCallback onTapDetail;
  final DragProgressCallback? onDragProgress;
  final Offset? enterFromOffset;

  const TriageCard({
    super.key,
    required this.item,
    this.cachedBytes,
    required this.isTopCard,
    this.isFitMode = true,
    this.onToggleFitMode,
    required this.onSwipeRight,
    required this.onSwipeLeft,
    required this.onTapDetail,
    this.onDragProgress,
    this.enterFromOffset,
  });

  @override
  State<TriageCard> createState() => TriageCardState();
}

class TriageCardState extends State<TriageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0.0;
  double _cardOpacity = 1.0;
  bool _isExiting = false;
  bool _hasTriggeredHaptic = false;

  static const double swipeThreshold = 120.0;
  static const double velocityThreshold = 650.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    if (widget.enterFromOffset != null) {
      _dragOffset = widget.enterFromOffset!;
      _dragAngle = (widget.enterFromOffset!.dx.sign * -0.22);
      _cardOpacity = 0.5;

      _offsetAnimation = Tween<Offset>(
        begin: widget.enterFromOffset!,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: M3ExpressiveTheme.motionSpring,
        ),
      );

      _rotationAnimation = Tween<double>(
        begin: _dragAngle,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: M3ExpressiveTheme.motionEmphasizedDecelerate,
        ),
      );

      _opacityAnimation = Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: M3ExpressiveTheme.motionEmphasizedDecelerate,
        ),
      );

      _animController.forward(from: 0.0);
    } else {
      _offsetAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_animController);
      _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_animController);
      _opacityAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_animController);
    }

    _animController.addListener(() {
      setState(() {
        _dragOffset = _offsetAnimation.value;
        _dragAngle = _rotationAnimation.value;
        _cardOpacity = _opacityAnimation.value;
      });
      final progress = (_dragOffset.dx / swipeThreshold).clamp(-1.0, 1.0);
      widget.onDragProgress?.call(progress);
    });
  }

  @override
  void didUpdateWidget(TriageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.id != oldWidget.item.id) {
      _animController.stop();
      _isExiting = false;
      _hasTriggeredHaptic = false;
      if (widget.enterFromOffset != null) {
        _dragOffset = widget.enterFromOffset!;
        _dragAngle = (widget.enterFromOffset!.dx.sign * -0.22);
        _cardOpacity = 0.5;

        _offsetAnimation = Tween<Offset>(
          begin: widget.enterFromOffset!,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animController,
            curve: M3ExpressiveTheme.motionSpring,
          ),
        );

        _rotationAnimation = Tween<double>(
          begin: _dragAngle,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _animController,
            curve: M3ExpressiveTheme.motionEmphasizedDecelerate,
          ),
        );

        _opacityAnimation = Tween<double>(
          begin: 0.5,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _animController,
            curve: M3ExpressiveTheme.motionEmphasizedDecelerate,
          ),
        );

        _animController.duration = const Duration(milliseconds: 340);
        _animController.forward(from: 0.0);
      } else {
        _dragOffset = Offset.zero;
        _dragAngle = 0.0;
        _cardOpacity = 1.0;
      }
    }
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
      // Rotação proporcional contínua ao deslocamento horizontal
      _dragAngle = (_dragOffset.dx / 320.0).clamp(-0.25, 0.25);
    });

    final isPastThreshold = _dragOffset.dx.abs() >= swipeThreshold;
    if (isPastThreshold && !_hasTriggeredHaptic) {
      _hasTriggeredHaptic = true;
      HapticFeedback.selectionClick();
    } else if (!isPastThreshold && _hasTriggeredHaptic) {
      _hasTriggeredHaptic = false;
    }

    final progress = (_dragOffset.dx / swipeThreshold).clamp(-1.0, 1.0);
    widget.onDragProgress?.call(progress);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isTopCard || _isExiting) return;

    final dx = _dragOffset.dx;
    final vx = details.velocity.pixelsPerSecond.dx;

    if (dx > swipeThreshold || vx > velocityThreshold) {
      _flingCard(1.0, velocityX: vx); // Fuga para a direita (Manter)
    } else if (dx < -swipeThreshold || vx < -velocityThreshold) {
      _flingCard(-1.0, velocityX: vx); // Fuga para a esquerda (Excluir)
    } else {
      _snapBack(); // Retorno elástico à posição central
    }
  }

  /// Dispara a animação programática de descarte para a esquerda (Excluir)
  void animateSwipeLeft() {
    if (_isExiting) return;
    _flingCard(-1.0);
  }

  /// Dispara a animação programática de descarte para a direita (Manter)
  void animateSwipeRight() {
    if (_isExiting) return;
    _flingCard(1.0);
  }

  /// Dispara a animação programática de favoritar (voa em direção ao topo)
  void animateFavorite(VoidCallback onComplete) {
    if (_isExiting) return;
    _isExiting = true;

    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: const Offset(0, -650),
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: _dragAngle,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeIn,
      ),
    );

    _animController.duration = const Duration(milliseconds: 300);
    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        widget.onDragProgress?.call(1.0);
        onComplete();
      }
    });
  }

  void _flingCard(double direction, {double velocityX = 0}) {
    if (_isExiting) return;
    _isExiting = true;
    _hasTriggeredHaptic = false;
    HapticFeedback.lightImpact();

    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = direction * (screenWidth + 220);
    final targetY = _dragOffset.dy + (_dragOffset.dy == 0 ? 30.0 : _dragOffset.dy.sign * 60.0);
    final targetOffset = Offset(targetX, targetY);
    final targetAngle = direction * 0.38;

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
        curve: Curves.easeOutCubic,
      ),
    );

    // Fade sutil nos últimos 40% da trajetória de saída para evitar cortes abruptos
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.1),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInQuad,
      ),
    );

    // Duração responsiva à velocidade do arremesso do usuário
    final durationMs = (velocityX.abs() > 1500) ? 220 : 300;
    _animController.duration = Duration(milliseconds: durationMs);

    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        widget.onDragProgress?.call(direction);
        if (direction > 0) {
          widget.onSwipeRight();
        } else {
          widget.onSwipeLeft();
        }
      }
    });
  }

  void _snapBack() {
    _hasTriggeredHaptic = false;
    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: M3ExpressiveTheme.motionSpring, // Retorno elástico de mola M3 Expressive
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

    _opacityAnimation = Tween<double>(
      begin: _cardOpacity,
      end: 1.0,
    ).animate(_animController);

    _animController.duration = const Duration(milliseconds: 320);
    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        widget.onDragProgress?.call(0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    // Cálculo da intensidade do swipe para os selos de animação
    final swipeP = (_dragOffset.dx / swipeThreshold).clamp(-1.5, 1.5);
    final deleteIntensity = (-swipeP).clamp(0.0, 1.0);
    final keepIntensity = swipeP.clamp(0.0, 1.0);

    return GestureDetector(
      onPanUpdate: widget.isTopCard ? _onPanUpdate : null,
      onPanEnd: widget.isTopCard ? _onPanEnd : null,
      onTap: widget.onTapDetail,
      onDoubleTap: (widget.isTopCard && widget.onToggleFitMode != null)
          ? () {
              HapticFeedback.lightImpact();
              widget.onToggleFitMode!();
            }
          : null,
      child: Opacity(
        opacity: _cardOpacity.clamp(0.0, 1.0),
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
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(M3ExpressiveTheme.cardBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(M3ExpressiveTheme.cardBorderRadius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Imagem da Foto (Smart Fit com ambient blur ou Fill)
                        _buildImageContent(),

                        // Selo dinâmico de ação ao deslizar para a ESQUERDA (EXCLUIR / DISCARD)
                        if (widget.isTopCard && deleteIntensity > 0.02)
                          Positioned(
                            top: 36,
                            right: 24,
                            child: Transform.rotate(
                              angle: 0.18,
                              child: Opacity(
                                opacity: deleteIntensity,
                                child: Transform.scale(
                                  scale: 0.85 + (0.25 * deleteIntensity),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: M3ExpressiveTheme.oneUiCoral,
                                      borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                                      boxShadow: [
                                        BoxShadow(
                                          color: M3ExpressiveTheme.oneUiCoral.withValues(alpha: 0.40),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                                        const SizedBox(width: 8),
                                        Text(
                                          strings.delete,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Selo dinâmico de ação ao deslizar para a DIREITA (MANTER / KEEP)
                        if (widget.isTopCard && keepIntensity > 0.02)
                          Positioned(
                            top: 36,
                            left: 24,
                            child: Transform.rotate(
                              angle: -0.18,
                              child: Opacity(
                                opacity: keepIntensity,
                                child: Transform.scale(
                                  scale: 0.85 + (0.25 * keepIntensity),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: M3ExpressiveTheme.oneUiMint,
                                      borderRadius: BorderRadius.circular(M3ExpressiveTheme.pillBorderRadius),
                                      boxShadow: [
                                        BoxShadow(
                                          color: M3ExpressiveTheme.oneUiMint.withValues(alpha: 0.40),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_rounded, color: Colors.white, size: 24),
                                        const SizedBox(width: 8),
                                        Text(
                                          strings.keep,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Botão superior de alternar proporção (Ajustar / Preencher) com indicador de proporção
                        if (widget.isTopCard && widget.onToggleFitMode != null)
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  widget.onToggleFitMode!();
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.24),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        widget.isFitMode
                                            ? Icons.fit_screen_rounded
                                            : Icons.crop_free_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      if (widget.item.ratioLabel.isNotEmpty) ...[
                                        const SizedBox(width: 5),
                                        Text(
                                          widget.item.ratioLabel,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
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
      ),
    );
  }

  Widget _buildImageContent() {
    if (!widget.isFitMode) {
      // Modo Preencher (Fill/Cover): imagem expande até cobrir o card por completo
      return _buildRawImage(fit: BoxFit.cover);
    }

    // Modo Ajustar (Smart Fit): imagem com proporção 100% visível sem cortes (BoxFit.contain),
    // emoldurada por uma aura ambiente desfocada (Ambient Blur Backdrop) com base nas cores da própria foto.
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Fundo ambiente com desfoque gaussiano suave
        ClipRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Transform.scale(
              scale: 1.18, // Ligeira ampliação para evitar bordas transparentes do filtro
              child: _buildRawImage(fit: BoxFit.cover),
            ),
          ),
        ),

        // 2. Película escura sutil sobre o fundo para profundidade e contraste
        Container(
          color: Colors.black.withValues(alpha: 0.38),
        ),

        // 3. Foto principal em alta definição centralizada com proporção 100% preservada
        Center(
          child: _buildRawImage(fit: BoxFit.contain),
        ),
      ],
    );
  }

  Widget _buildRawImage({required BoxFit fit}) {
    if (widget.cachedBytes != null) {
      return Image.memory(
        widget.cachedBytes!,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
      );
    }

    if (widget.item.assetEntity != null) {
      return AssetEntityImage(
        widget.item.assetEntity!,
        isOriginal: false,
        thumbnailSize: const ThumbnailSize(1440, 1920),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: M3ExpressiveLoadingIndicator(size: 44),
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
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: M3ExpressiveLoadingIndicator(size: 44),
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
