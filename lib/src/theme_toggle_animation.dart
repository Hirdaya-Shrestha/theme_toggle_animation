import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'clippers/clipper_factory.dart';
import 'theme_animation_type.dart';

/// A widget that wraps your UI and provides animated theme transitions.
///
/// Wraps a [RepaintBoundary] to capture the old theme as a screenshot,
/// then animates the reveal of the new theme using various clip effects.
///
/// ```dart
/// ThemeToggleAnimation(
///   currentTheme: _isDark ? darkTheme : lightTheme,
///   animationType: ThemeAnimationType.circle,
///   circleDirection: CircleAnimationDirection.ftl,
///   onToggle: () => setState(() => _isDark = !_isDark),
///   builder: (context, toggle) => GestureDetector(
///     onTap: toggle,
///     child: Icon(Icons.brightness_6),
///   ),
///   child: MyApp(),
/// )
/// ```
class const ThemeToggleAnimation({
  super.key,

  /// The current theme data.
  required final ThemeData currentTheme,

  /// Builder that provides the toggle callback.
  ///
  /// [toggle] switches the theme and plays the animation.
  required final Widget Function(BuildContext context, VoidCallback toggle)
  builder,

  /// The child widget tree rendered with the current theme.
  required final Widget child,

  /// Animation effect to use.
  final ThemeAnimationType animationType = ThemeAnimationType.circle,

  /// Animation duration.
  final Duration duration = const Duration(milliseconds: 750),

  /// Animation curve.
  final Curve curve = Curves.easeInOut,

  /// Direction for circle animations (only used with [ThemeAnimationType.circle]).
  final CircleAnimationDirection circleDirection = CircleAnimationDirection.ftl,

  /// Direction for line animations (only used with [ThemeAnimationType.line]).
  final LineAnimationDirection lineDirection = LineAnimationDirection.ltr,

  /// Blur intensity applied to animation edges (only for circle and line types).
  ///
  /// Set to 0 for no blur. Ignored for [ThemeAnimationType.customMask].
  final double blurAmount = 0.0,

  /// Custom clip path provider (only used with [ThemeAnimationType.customMask]).
  ///
  /// Receives the widget size, tap offset, and animation progress (0..1).
  final Path Function(Size size, Offset offset, double progress)? clipper,

  /// Called when the user taps the toggle button, after the old theme is
  /// captured. Use this to flip your theme state (e.g. `setState(() => isDark = !isDark)`).
  final VoidCallback? onToggle,

  /// Called when the animation starts.
  final VoidCallback? onAnimationStart,

  /// Called when the animation completes.
  final VoidCallback? onAnimationEnd,

  /// Whether the toggle animation is enabled.
  ///
  /// When false, [onToggle] is still called but no animation plays.
  final bool enabled = true,

  /// Image provider for custom mask animation (only used with [ThemeAnimationType.customMask]).
  ///
  /// The image is used as a CSS-style mask: opaque pixels reveal the new theme.
  /// The GIF appears at [customMaskSize], plays for 80% of the duration,
  /// then expands to fill the screen.
  final ImageProvider? customMaskImage,

  /// Position of the GIF mask on screen (only for [ThemeAnimationType.customMask]).
  ///
  /// The [Offset] is the top-left corner where the GIF is placed.
  /// If null, defaults to center of the screen.
  final Offset? customMaskOffset,

  /// Size of the GIF mask during the play phase (only for [ThemeAnimationType.customMask]).
  ///
  /// The GIF scales from 0 to this size in the first 10% of the animation,
  /// stays at this size for 80% (plays the GIF), then expands to fill the screen.
  /// If null, defaults to 200x200 logical pixels.
  final Size? customMaskSize,
}) extends StatefulWidget {
  @override
  State<ThemeToggleAnimation> createState() => _ThemeToggleAnimationState();
}

class _ThemeToggleAnimationState extends State<ThemeToggleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  ThemeData? _oldTheme;
  ui.Image? _screenshot;
  ui.Image? _resolvedMaskImage;
  final _repaintKey = GlobalKey();
  Offset? _capturedOffset;

  ImageStream? _maskImageStream;
  ImageStreamListener? _maskImageListener;
  bool _maskImageResolved = false;

  Widget? _cachedContent;

  bool get _isCircleType => widget.animationType == ThemeAnimationType.circle;
  bool get _isLineType => widget.animationType == ThemeAnimationType.line;
  bool get _isCustomMaskType =>
      widget.animationType == ThemeAnimationType.customMask;
  bool get _hasBlur => widget.blurAmount > 0 && !_isCustomMaskType;

  bool get _needsWidgetOffset {
    if (_isCircleType &&
        widget.circleDirection == CircleAnimationDirection.fromWidget) {
      return true;
    }
    if (_isLineType &&
        (widget.lineDirection == LineAnimationDirection.fromWidgetHorizontal ||
            widget.lineDirection ==
                LineAnimationDirection.fromWidgetVertical)) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    _controller.addStatusListener(_onAnimationStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_maskImageResolved) {
      _maskImageResolved = true;
      _resolveMaskImage();
    }
  }

  @override
  void didUpdateWidget(ThemeToggleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.curve != oldWidget.curve) {
      _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    }
    if (widget.customMaskImage != oldWidget.customMaskImage) {
      _maskImageResolved = false;
      _resolveMaskImage();
    }
    if (widget.currentTheme != oldWidget.currentTheme) {
      _cachedContent = null;
    }
  }

  @override
  void dispose() {
    _maskImageStream?.removeListener(_maskImageListener!);
    _maskImageStream = null;
    _maskImageListener = null;
    _controller.dispose();
    super.dispose();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onAnimationEnd?.call();
      setState(() {
        _oldTheme = null;
        _screenshot = null;
        _cachedContent = null;
      });
    }
  }

  Future<void> _toggle() async {
    if (_controller.isAnimating) return;

    _oldTheme = widget.currentTheme;

    // Wait for the current frame to finish painting so the RepaintBoundary
    // is valid for toImage().
    await WidgetsBinding.instance.endOfFrame;
    await _captureScreenshot();

    widget.onToggle?.call();

    if (mounted) {
      widget.onAnimationStart?.call();
      await _controller.forward(from: 0.0);
    }
  }

  Future<void> _resolveMaskImage() async {
    _maskImageStream?.removeListener(_maskImageListener!);
    _maskImageStream = null;
    _maskImageListener = null;

    if (widget.customMaskImage == null) {
      _resolvedMaskImage = null;
      return;
    }
    final provider = widget.customMaskImage!;
    final stream = provider.resolve(
      ImageConfiguration(
        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      ),
    );

    _maskImageListener = ImageStreamListener((info, _) {
      if (mounted) {
        setState(() => _resolvedMaskImage = info.image);
      }
    });
    _maskImageStream = stream;
    stream.addListener(_maskImageListener!);
  }

  Future<void> _captureScreenshot() async {
    final boundary =
        _repaintKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
    if (mounted) {
      setState(() => _screenshot = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAnimation = _screenshot != null && _oldTheme != null;

    return Theme(
      data: widget.currentTheme,
      child: RepaintBoundary(
        key: _repaintKey,
        child: Builder(
          builder: (innerContext) {
            if (hasAnimation) {
              return Stack(
                children: [_buildScreenshotLayer(), _buildAnimatedLayer()],
              );
            }
            return Listener(
              onPointerDown: (event) {
                _capturedOffset = event.position;
              },
              child: widget.builder(
                innerContext,
                widget.enabled ? _toggle : () => widget.onToggle?.call(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScreenshotLayer() {
    return RawImage(
      image: _screenshot,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildAnimatedLayer() {
    return AnimatedBuilder(
      listenable: _animation,
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        final progress = _animation.value;

        _cachedContent ??= Theme(
          data: widget.currentTheme,
          child: widget.builder(context, _toggle),
        );

        final content = _cachedContent!;

        if (_isCustomMaskType && widget.customMaskImage != null) {
          return _buildImageMask(content, size, progress);
        }

        final clipped = RepaintBoundary(
          child: ClipPath(
            clipper: buildClipper(
              type: widget.animationType,
              progress: progress,
              circleDirection: _isCircleType ? widget.circleDirection : null,
              lineDirection: _isLineType ? widget.lineDirection : null,
              widgetOffset: _needsWidgetOffset ? _capturedOffset : null,
              customClipper: _isCustomMaskType ? widget.clipper : null,
            ),
            child: content,
          ),
        );

        if (_hasBlur) {
          return _buildBlurOverlay(clipped, size, progress);
        }

        return clipped;
      },
    );
  }

  Widget _buildBlurOverlay(Widget child, Size size, double progress) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _BlurEdgePainter(
                animationType: widget.animationType,
                circleDirection: widget.circleDirection,
                lineDirection: widget.lineDirection,
                widgetOffset: _needsWidgetOffset ? _capturedOffset : null,
                blurAmount: widget.blurAmount,
                progress: progress,
                size: size,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageMask(Widget content, Size size, double progress) {
    if (_resolvedMaskImage == null) return content;
    if (progress <= 0) return const SizedBox.expand();

    final imgW = _resolvedMaskImage!.width.toDouble();
    final imgH = _resolvedMaskImage!.height.toDouble();

    final maskW = widget.customMaskSize?.width ?? 200.0;
    final maskH = widget.customMaskSize?.height ?? 200.0;

    final anchor =
        widget.customMaskOffset ??
        Offset((size.width - maskW) / 2, (size.height - maskH) / 2);

    double currentW;
    double currentH;
    if (progress <= 0.1) {
      final t = progress / 0.1;
      currentW = maskW * t;
      currentH = maskH * t;
    } else if (progress <= 0.9) {
      currentW = maskW;
      currentH = maskH;
    } else {
      final t = (progress - 0.9) / 0.1;
      currentW = maskW + (size.width * 2 - maskW) * t;
      currentH = maskH + (size.height * 2 - maskH) * t;
    }

    if (currentW <= 0 || currentH <= 0) return const SizedBox.expand();

    final centerX = anchor.dx + maskW / 2;
    final centerY = anchor.dy + maskH / 2;

    final sx = currentW / imgW;
    final sy = currentH / imgH;

    final tx = centerX - (imgW * sx) / 2;
    final ty = centerY - (imgH * sy) / 2;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return ImageShader(
          _resolvedMaskImage!,
          TileMode.decal,
          TileMode.decal,
          Float64List.fromList([
            sx,
            0,
            0,
            0,
            0,
            sy,
            0,
            0,
            0,
            0,
            1,
            0,
            tx,
            ty,
            0,
            1,
          ]),
        );
      },
      blendMode: BlendMode.dstIn,
      child: content,
    );
  }
}

/// A minimal animated builder widget.
class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  final Widget Function(BuildContext context, Widget? child) builder;

  @override
  Widget build(BuildContext context) => builder(context, null);
}

class _BlurEdgePainter extends CustomPainter {
  _BlurEdgePainter({
    required this.animationType,
    required this.circleDirection,
    required this.lineDirection,
    required this.widgetOffset,
    required this.blurAmount,
    required this.progress,
    required this.size,
  });

  final ThemeAnimationType animationType;
  final CircleAnimationDirection circleDirection;
  final LineAnimationDirection lineDirection;
  final Offset? widgetOffset;
  final double blurAmount;
  final double progress;
  final Size size;

  late final double _cachedMaxRadius = _computeMaxRadius();

  @override
  void paint(Canvas canvas, Size s) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = blurAmount
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurAmount * 0.4)
      ..color = Colors.white;

    if (animationType == ThemeAnimationType.circle) {
      _paintCircleRing(canvas, s, paint);
    } else {
      _paintLineEdge(canvas, s, paint);
    }
  }

  void _paintCircleRing(Canvas canvas, Size s, Paint paint) {
    final center = _circleCenter(s);
    final radius = _cachedMaxRadius * progress;

    if (radius <= 1.0) return;
    paint.strokeWidth = blurAmount;
    canvas.drawCircle(center, radius, paint);
  }

  void _paintLineEdge(Canvas canvas, Size s, Paint paint) {
    final path = Path();
    final p = progress;

    switch (lineDirection) {
      case LineAnimationDirection.ltr:
        final x = s.width * p;
        path.moveTo(x, 0);
        path.lineTo(x, s.height);
      case LineAnimationDirection.rtl:
        final x = s.width * (1 - p);
        path.moveTo(x, 0);
        path.lineTo(x, s.height);
      case LineAnimationDirection.ttb:
        final y = s.height * p;
        path.moveTo(0, y);
        path.lineTo(s.width, y);
      case LineAnimationDirection.btt:
        final y = s.height * (1 - p);
        path.moveTo(0, y);
        path.lineTo(s.width, y);
      case LineAnimationDirection.fromWidgetHorizontal:
        final wx = widgetOffset?.dx ?? s.width / 2;
        final halfW = s.width * p;
        path.moveTo(wx - halfW, 0);
        path.lineTo(wx - halfW, s.height);
        path.moveTo(wx + halfW, 0);
        path.lineTo(wx + halfW, s.height);
      case LineAnimationDirection.fromWidgetVertical:
        final wy = widgetOffset?.dy ?? s.height / 2;
        final halfH = s.height * p;
        path.moveTo(0, wy - halfH);
        path.lineTo(s.width, wy - halfH);
        path.moveTo(0, wy + halfH);
        path.lineTo(s.width, wy + halfH);
      case LineAnimationDirection.ftl:
        final dist = (s.width + s.height) * p;
        path.moveTo(dist, 0);
        path.lineTo(0, dist);
      case LineAnimationDirection.ftr:
        final dist = (s.width + s.height) * p;
        path.moveTo(s.width - dist, 0);
        path.lineTo(s.width, dist);
      case LineAnimationDirection.fbl:
        final dist = (s.width + s.height) * p;
        path.moveTo(dist, s.height);
        path.lineTo(0, s.height - dist);
      case LineAnimationDirection.fbr:
        final dist = (s.width + s.height) * p;
        path.moveTo(s.width - dist, s.height);
        path.lineTo(s.width, s.height - dist);
    }

    paint.strokeWidth = blurAmount;
    canvas.drawPath(path, paint);
  }

  Offset _circleCenter(Size s) {
    switch (circleDirection) {
      case CircleAnimationDirection.ftl:
        return Offset.zero;
      case CircleAnimationDirection.ftr:
        return Offset(s.width, 0);
      case CircleAnimationDirection.fbl:
        return Offset(0, s.height);
      case CircleAnimationDirection.fbr:
        return Offset(s.width, s.height);
      case CircleAnimationDirection.fromWidget:
        return widgetOffset ?? Offset(s.width / 2, s.height / 2);
    }
  }

  double _computeMaxRadius() {
    final center = _circleCenter(size);
    final w = max(center.dx, size.width - center.dx);
    final h = max(center.dy, size.height - center.dy);
    return sqrt(w * w + h * h);
  }

  @override
  bool shouldRepaint(_BlurEdgePainter oldDelegate) =>
      progress != oldDelegate.progress || blurAmount != oldDelegate.blurAmount;
}
