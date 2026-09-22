import 'package:flutter_test/flutter_test.dart';
import 'package:theme_toggle_animation/theme_toggle_animation.dart';

void main() {
  test('ThemeAnimationType has all animation types', () {
    expect(ThemeAnimationType.values.length, 3);
    expect(ThemeAnimationType.values, contains(ThemeAnimationType.circle));
    expect(ThemeAnimationType.values, contains(ThemeAnimationType.line));
    expect(ThemeAnimationType.values, contains(ThemeAnimationType.customMask));
  });

  test('CircleAnimationDirection has all directions', () {
    expect(CircleAnimationDirection.values.length, 5);
    expect(CircleAnimationDirection.values, contains(CircleAnimationDirection.ftl));
    expect(CircleAnimationDirection.values, contains(CircleAnimationDirection.ftr));
    expect(CircleAnimationDirection.values, contains(CircleAnimationDirection.fbl));
    expect(CircleAnimationDirection.values, contains(CircleAnimationDirection.fbr));
    expect(CircleAnimationDirection.values, contains(CircleAnimationDirection.fromWidget));
  });

  test('LineAnimationDirection has all directions', () {
    expect(LineAnimationDirection.values.length, 10);
    expect(LineAnimationDirection.values, contains(LineAnimationDirection.ltr));
    expect(LineAnimationDirection.values, contains(LineAnimationDirection.rtl));
    expect(LineAnimationDirection.values, contains(LineAnimationDirection.ttb));
    expect(LineAnimationDirection.values, contains(LineAnimationDirection.btt));
    expect(LineAnimationDirection.values, contains(LineAnimationDirection.fromWidgetHorizontal));
    expect(LineAnimationDirection.values, contains(LineAnimationDirection.fromWidgetVertical));
    expect(LineAnimationDirection.values, contains(LineAnimationDirection.ftl));
    expect(LineAnimationDirection.values, contains(LineAnimationDirection.ftr));
    expect(LineAnimationDirection.values, contains(LineAnimationDirection.fbl));
    expect(LineAnimationDirection.values, contains(LineAnimationDirection.fbr));
  });
}
