/// Animation types for theme toggle transitions.
enum ThemeAnimationType {
  /// Expanding circle reveal.
  circle,

  /// Horizontal or vertical scanning line sweep.
  line,

  /// Reveal through a custom clip path or image mask.
  customMask,
}

/// Direction for circle animations.
enum CircleAnimationDirection {
  /// From top-left corner.
  ftl,

  /// From top-right corner.
  ftr,

  /// From bottom-left corner.
  fbl,

  /// From bottom-right corner.
  fbr,

  /// From the toggle widget's position.
  fromWidget,
}

/// Direction for line animations.
enum LineAnimationDirection {
  /// Left to right.
  ltr,

  /// Right to left.
  rtl,

  /// Top to bottom.
  ttb,

  /// Bottom to top.
  btt,

  /// From widget horizontally (left to right from widget position).
  fromWidgetHorizontal,

  /// From widget vertically (top to bottom from widget position).
  fromWidgetVertical,

  /// Diagonal from top-left to bottom-right.
  ftl,

  /// Diagonal from top-right to bottom-left.
  ftr,

  /// Diagonal from bottom-left to top-right.
  fbl,

  /// Diagonal from bottom-right to top-left.
  fbr,
}
