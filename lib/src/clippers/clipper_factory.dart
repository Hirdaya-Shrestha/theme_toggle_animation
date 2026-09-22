import 'package:flutter/material.dart';

import '../theme_animation_type.dart';
import 'circle_clipper.dart';
import 'custom_mask_clipper.dart';
import 'line_clipper.dart';

/// Builds the appropriate clipper for the given animation type.
CustomClipper<Path> buildClipper({
  required ThemeAnimationType type,
  required double progress,
  CircleAnimationDirection? circleDirection,
  LineAnimationDirection? lineDirection,
  Offset? widgetOffset,
  Path Function(Size, Offset, double)? customClipper,
}) {
  return switch (type) {
    ThemeAnimationType.circle => CircleClipper(
        progress: progress,
        direction: circleDirection ?? CircleAnimationDirection.ftl,
        widgetOffset: widgetOffset,
      ),
    ThemeAnimationType.line => LineClipper(
        progress: progress,
        direction: lineDirection ?? LineAnimationDirection.ltr,
        widgetOffset: widgetOffset,
      ),
    ThemeAnimationType.customMask => CustomMaskClipper(
        progress: progress,
        widgetOffset: widgetOffset,
        clipper: customClipper,
      ),
  };
}
