import 'package:flutter/material.dart';

class CustomMaskClipper({
  required final double progress,
  final Offset? widgetOffset,
  final Path Function(Size size, Offset offset, double progress)? clipper,
}) extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    if (clipper != null) {
      final offset = widgetOffset ?? Offset(size.width / 2, size.height / 2);
      return clipper!(size, offset, progress);
    }

    // Default: expanding circle from center
    final offset = widgetOffset ?? Offset(size.width / 2, size.height / 2);
    final radius = (size.width + size.height) * 0.6 * progress;
    return Path()..addOval(Rect.fromCircle(center: offset, radius: radius));
  }

  @override
  bool shouldReclip(CustomMaskClipper oldClipper) => true;
}
