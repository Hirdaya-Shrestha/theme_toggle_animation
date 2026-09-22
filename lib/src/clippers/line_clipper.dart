import 'package:flutter/material.dart';

import '../theme_animation_type.dart';

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class const LineClipper({
  required final double progress,
  required final LineAnimationDirection direction,
  final Offset? widgetOffset,
}) extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    switch (direction) {
      case LineAnimationDirection.ltr:
        final x = size.width * progress;
        path.addRect(Rect.fromLTWH(0, 0, x, size.height));
      case LineAnimationDirection.rtl:
        final x = size.width * (1 - progress);
        path.addRect(Rect.fromLTWH(x, 0, size.width - x, size.height));
      case LineAnimationDirection.ttb:
        final y = size.height * progress;
        path.addRect(Rect.fromLTWH(0, 0, size.width, y));
      case LineAnimationDirection.btt:
        final y = size.height * (1 - progress);
        path.addRect(Rect.fromLTWH(0, y, size.width, size.height - y));
      case LineAnimationDirection.fromWidgetHorizontal:
        final wx = widgetOffset?.dx ?? size.width / 2;
        final halfW = size.width * progress;
        path.addRect(Rect.fromLTWH(wx - halfW, 0, halfW * 2, size.height));
      case LineAnimationDirection.fromWidgetVertical:
        final wy = widgetOffset?.dy ?? size.height / 2;
        final halfH = size.height * progress;
        path.addRect(Rect.fromLTWH(0, wy - halfH, size.width, halfH * 2));
      case LineAnimationDirection.ftl:
        _addCornerDiagonal(path, size, progress, corner: _Corner.topLeft);
      case LineAnimationDirection.ftr:
        _addCornerDiagonal(path, size, progress, corner: _Corner.topRight);
      case LineAnimationDirection.fbl:
        _addCornerDiagonal(path, size, progress, corner: _Corner.bottomLeft);
      case LineAnimationDirection.fbr:
        _addCornerDiagonal(path, size, progress, corner: _Corner.bottomRight);
    }

    return path;
  }

  void _addCornerDiagonal(
    Path path,
    Size size,
    double progress, {
    required _Corner corner,
  }) {
    final maxDist = size.width + size.height;
    final dist = maxDist * progress;

    switch (corner) {
      case _Corner.topLeft:
        path.moveTo(0, 0);
        path.lineTo(dist, 0);
        path.lineTo(0, dist);
        path.close();
      case _Corner.topRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width - dist, 0);
        path.lineTo(size.width, dist);
        path.close();
      case _Corner.bottomLeft:
        path.moveTo(0, size.height);
        path.lineTo(dist, size.height);
        path.lineTo(0, size.height - dist);
        path.close();
      case _Corner.bottomRight:
        path.moveTo(size.width, size.height);
        path.lineTo(size.width - dist, size.height);
        path.lineTo(size.width, size.height - dist);
        path.close();
    }
  }

  @override
  bool shouldReclip(LineClipper oldClipper) => true;
}
