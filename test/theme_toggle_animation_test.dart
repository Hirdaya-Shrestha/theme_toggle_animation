import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theme_toggle_animation/theme_toggle_animation.dart';

void main() {
  group('Enums', () {
    test('ThemeAnimationType has all animation types', () {
      expect(ThemeAnimationType.values.length, 3);
      expect(ThemeAnimationType.values, contains(ThemeAnimationType.circle));
      expect(ThemeAnimationType.values, contains(ThemeAnimationType.line));
      expect(
        ThemeAnimationType.values,
        contains(ThemeAnimationType.customMask),
      );
    });

    test('CircleAnimationDirection has all directions', () {
      expect(CircleAnimationDirection.values.length, 5);
      expect(
        CircleAnimationDirection.values,
        contains(CircleAnimationDirection.ftl),
      );
      expect(
        CircleAnimationDirection.values,
        contains(CircleAnimationDirection.ftr),
      );
      expect(
        CircleAnimationDirection.values,
        contains(CircleAnimationDirection.fbl),
      );
      expect(
        CircleAnimationDirection.values,
        contains(CircleAnimationDirection.fbr),
      );
      expect(
        CircleAnimationDirection.values,
        contains(CircleAnimationDirection.fromWidget),
      );
    });

    test('LineAnimationDirection has all directions', () {
      expect(LineAnimationDirection.values.length, 10);
      expect(
        LineAnimationDirection.values,
        contains(LineAnimationDirection.ltr),
      );
      expect(
        LineAnimationDirection.values,
        contains(LineAnimationDirection.rtl),
      );
      expect(
        LineAnimationDirection.values,
        contains(LineAnimationDirection.ttb),
      );
      expect(
        LineAnimationDirection.values,
        contains(LineAnimationDirection.btt),
      );
      expect(
        LineAnimationDirection.values,
        contains(LineAnimationDirection.fromWidgetHorizontal),
      );
      expect(
        LineAnimationDirection.values,
        contains(LineAnimationDirection.fromWidgetVertical),
      );
      expect(
        LineAnimationDirection.values,
        contains(LineAnimationDirection.ftl),
      );
      expect(
        LineAnimationDirection.values,
        contains(LineAnimationDirection.ftr),
      );
      expect(
        LineAnimationDirection.values,
        contains(LineAnimationDirection.fbl),
      );
      expect(
        LineAnimationDirection.values,
        contains(LineAnimationDirection.fbr),
      );
    });
  });

  group('ThemeToggleAnimation', () {
    const buttonKey = Key('toggle_button');
    const duration = Duration(milliseconds: 500);

    Widget buildHost({
      Key? key,
      bool enabled = true,
      ThemeAnimationType type = ThemeAnimationType.circle,
      CircleAnimationDirection circleDirection = CircleAnimationDirection.ftl,
      LineAnimationDirection lineDirection = LineAnimationDirection.ltr,
      double blurAmount = 0,
      Path Function(Size, Offset, double)? clipper,
      void Function()? onToggle,
      void Function()? onAnimationStart,
      void Function()? onAnimationEnd,
    }) {
      return _Host(
        key: key,
        enabled: enabled,
        type: type,
        circleDirection: circleDirection,
        lineDirection: lineDirection,
        blurAmount: blurAmount,
        clipper: clipper,
        onToggle: onToggle,
        onAnimationStart: onAnimationStart,
        onAnimationEnd: onAnimationEnd,
      );
    }

    Future<void> pumpHost(
      WidgetTester tester, {
      bool enabled = true,
      ThemeAnimationType type = ThemeAnimationType.circle,
      CircleAnimationDirection circleDirection = CircleAnimationDirection.ftl,
      LineAnimationDirection lineDirection = LineAnimationDirection.ltr,
      double blurAmount = 0,
      Path Function(Size, Offset, double)? clipper,
      void Function()? onToggle,
      void Function()? onAnimationStart,
      void Function()? onAnimationEnd,
    }) async {
      await tester.pumpWidget(
        buildHost(
          enabled: enabled,
          type: type,
          circleDirection: circleDirection,
          lineDirection: lineDirection,
          blurAmount: blurAmount,
          clipper: clipper,
          onToggle: onToggle,
          onAnimationStart: onAnimationStart,
          onAnimationEnd: onAnimationEnd,
        ),
      );
      await tester.pump();
    }

    Future<void> tapToggle(WidgetTester tester) async {
      await tester.ensureVisible(find.byKey(buttonKey));
      await tester.tap(find.byKey(buttonKey));
      // Resolve endOfFrame + capture, then kick off the animation.
      await tester.pump();
      await tester.pump();
    }

    Future<void> finishAnimation(WidgetTester tester) async {
      await tester.pump(duration + const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    }

    testWidgets('renders builder content with the provided theme', (
      tester,
    ) async {
      await pumpHost(tester);

      expect(find.byKey(buttonKey), findsOneWidget);
      final ctx = tester.element(find.byKey(buttonKey));
      expect(Theme.of(ctx).brightness, Brightness.light);

      await tester.tap(find.byKey(buttonKey));
      await finishAnimation(tester);

      final ctxAfter = tester.element(find.byKey(buttonKey));
      expect(Theme.of(ctxAfter).brightness, Brightness.dark);
    });

    testWidgets('tapping invokes onToggle', (tester) async {
      var toggled = 0;
      await pumpHost(tester, onToggle: () => toggled++);

      await tester.tap(find.byKey(buttonKey));
      await finishAnimation(tester);

      expect(toggled, 1);
    });

    testWidgets('fires lifecycle callbacks in correct order', (tester) async {
      final log = <String>[];
      await pumpHost(
        tester,
        onToggle: () => log.add('toggle'),
        onAnimationStart: () => log.add('start'),
        onAnimationEnd: () => log.add('end'),
      );

      await tapToggle(tester);

      expect(log, ['toggle', 'start']);
      expect(
        find.byType(ClipPath),
        findsWidgets,
        reason: 'animated layer should be clipped mid-animation',
      );

      await finishAnimation(tester);

      expect(log, ['toggle', 'start', 'end']);
    });

    testWidgets('renders screenshot layer and clip during animation', (
      tester,
    ) async {
      await pumpHost(tester);

      expect(find.byType(RawImage), findsNothing);

      await tapToggle(tester);

      expect(
        find.byType(RawImage),
        findsOneWidget,
        reason: 'screenshot of the old theme should be on screen',
      );
      expect(find.byType(ClipPath), findsWidgets);

      await finishAnimation(tester);

      expect(
        find.byType(RawImage),
        findsNothing,
        reason: 'screenshot cleared after animation',
      );
      expect(find.byType(ClipPath), findsNothing);
    });

    testWidgets('does not animate when enabled is false', (tester) async {
      var toggled = 0;
      var started = 0;
      var ended = 0;
      await pumpHost(
        tester,
        enabled: false,
        onToggle: () => toggled++,
        onAnimationStart: () => started++,
        onAnimationEnd: () => ended++,
      );

      await tester.tap(find.byKey(buttonKey));
      await tester.pump();
      await tester.pump(duration + const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(toggled, 1);
      expect(started, 0);
      expect(ended, 0);
      expect(find.byType(RawImage), findsNothing);
      expect(find.byType(ClipPath), findsNothing);
    });

    testWidgets('line animation type creates and completes cleanly', (
      tester,
    ) async {
      await pumpHost(
        tester,
        type: ThemeAnimationType.line,
        lineDirection: LineAnimationDirection.fromWidgetHorizontal,
      );

      await tapToggle(tester);
      expect(find.byType(ClipPath), findsWidgets);

      await finishAnimation(tester);
      expect(find.byType(RawImage), findsNothing);
    });

    testWidgets('customMask type uses provided custom clipper', (tester) async {
      Path customClipper(Size size, Offset offset, double progress) {
        final r = size.shortestSide * 0.5 * progress;
        return Path()..addOval(Rect.fromCircle(center: offset, radius: r));
      }

      await pumpHost(
        tester,
        type: ThemeAnimationType.customMask,
        clipper: customClipper,
      );

      await tapToggle(tester);
      expect(find.byType(ClipPath), findsWidgets);

      await finishAnimation(tester);
      expect(find.byType(RawImage), findsNothing);
    });

    testWidgets('customMask fallback clipper works without image or clipper', (
      tester,
    ) async {
      await pumpHost(tester, type: ThemeAnimationType.customMask);

      await tapToggle(tester);
      expect(find.byType(ClipPath), findsWidgets);

      await finishAnimation(tester);
      expect(find.byType(RawImage), findsNothing);
    });

    testWidgets('blurAmount adds blur overlay for circle', (tester) async {
      final log = <String>[];
      await pumpHost(tester, blurAmount: 8, onToggle: () => log.add('toggle'));

      await tapToggle(tester);

      expect(find.byType(CustomPaint), findsWidgets);
      await finishAnimation(tester);
    });

    testWidgets('does nothing when tapped twice quickly', (tester) async {
      var toggled = 0;
      await pumpHost(tester, onToggle: () => toggled++);

      await tester.tap(find.byKey(buttonKey));
      await tester.pump();
      await tester.tap(find.byKey(buttonKey));
      await tester.pump();
      await finishAnimation(tester);

      expect(toggled, 1);
    });
  });
}

class _Host extends StatefulWidget {
  const _Host({
    super.key,
    required this.enabled,
    required this.type,
    required this.circleDirection,
    required this.lineDirection,
    this.blurAmount = 0,
    this.clipper,
    this.onToggle,
    this.onAnimationStart,
    this.onAnimationEnd,
  });

  final bool enabled;
  final ThemeAnimationType type;
  final CircleAnimationDirection circleDirection;
  final LineAnimationDirection lineDirection;
  final double blurAmount;
  final Path Function(Size, Offset, double)? clipper;
  final VoidCallback? onToggle;
  final VoidCallback? onAnimationStart;
  final VoidCallback? onAnimationEnd;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: ThemeToggleAnimation(
          currentTheme: _isDark ? ThemeData.dark() : ThemeData.light(),
          animationType: widget.type,
          circleDirection: widget.circleDirection,
          lineDirection: widget.lineDirection,
          clipper: widget.clipper,
          blurAmount: widget.blurAmount,
          enabled: widget.enabled,
          duration: const Duration(milliseconds: 500),
          onToggle: () {
            setState(() => _isDark = !_isDark);
            widget.onToggle?.call();
          },
          onAnimationStart: widget.onAnimationStart,
          onAnimationEnd: widget.onAnimationEnd,
          builder: (context, toggle) => Center(
            child: ElevatedButton(
              key: const Key('toggle_button'),
              onPressed: toggle,
              child: const Text('Toggle Theme'),
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
