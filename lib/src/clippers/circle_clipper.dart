import 'dart:math';

import 'package:flutter/material.dart';

import '../theme_animation_type.dart';

class CircleClipper extends CustomClipper<Path> {
  CircleClipper({
    required this.progress,
    required this.direction,
    this.widgetOffset,
  });

  final double progress;
  final CircleAnimationDirection direction;
  final Offset? widgetOffset;

  @override
  Path getClip(Size size) {
    final center = _getCenter(size);
    final maxR = _maxRadius(size, center);
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: maxR * progress));
  }

  @override
  bool shouldReclip(CircleClipper oldClipper) => true;

  Offset _getCenter(Size size) {
    switch (direction) {
      case CircleAnimationDirection.ftl:
        return Offset.zero;
      case CircleAnimationDirection.ftr:
        return Offset(size.width, 0);
      case CircleAnimationDirection.fbl:
        return Offset(0, size.height);
      case CircleAnimationDirection.fbr:
        return Offset(size.width, size.height);
      case CircleAnimationDirection.fromWidget:
        return widgetOffset ?? Offset(size.width / 2, size.height / 2);
    }
  }

  static double _maxRadius(Size size, Offset center) {
    final w = max(center.dx, size.width - center.dx);
    final h = max(center.dy, size.height - center.dy);
    return sqrt(w * w + h * h);
  }
}
