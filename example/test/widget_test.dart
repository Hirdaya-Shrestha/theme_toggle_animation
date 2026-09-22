import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theme_toggle_animation_example/main.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
  }

  Future<void> tapToggle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    // Let the toggle's endOfFrame wait resolve and the capture finish.
    await tester.pump();
    // Run the full animation (1600ms) plus SnackBar duration.
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
  }

  testWidgets('App renders with title and toggle button', (tester) async {
    await pumpApp(tester);

    expect(find.text('Theme Toggle Animation'), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.text('Light Mode'), findsOneWidget);
  });

  testWidgets('Animation type selector reveals direction controls', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Animation Type'), findsOneWidget);
    expect(find.text('Circle Direction'), findsOneWidget);

    await tester.tap(find.text('line'));
    await tester.pump();

    expect(find.text('Circle Direction'), findsNothing);
    expect(find.text('Line Direction'), findsOneWidget);

    await tester.tap(find.text('customMask'));
    await tester.pump();

    expect(find.text('Line Direction'), findsNothing);
    expect(find.text('Blur: 0.0'), findsNothing);
  });

  testWidgets('Blur slider updates blur preview text', (tester) async {
    await pumpApp(tester);

    expect(find.text('Blur: 0.0'), findsOneWidget);

    await tester.drag(find.byType(Slider), const Offset(150, 0));
    await tester.pump();

    expect(
      tester
          .widgetList<Text>(find.textContaining('Blur:'))
          .any((t) => t.data != 'Blur: 0.0'),
      isTrue,
    );
  });

  testWidgets('Enabled switch stays on by default and can be toggled', (
    tester,
  ) async {
    await pumpApp(tester);

    final switchTile = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Animation enabled'),
    );
    expect(switchTile.value, isTrue);

    await tester.tap(find.text('Animation enabled'));
    await tester.pump();

    final toggled = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Animation enabled'),
    );
    expect(toggled.value, isFalse);
  });

  testWidgets('Tap toggle in app bar flips theme', (tester) async {
    await pumpApp(tester);

    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.text('Light Mode'), findsOneWidget);

    await tapToggle(tester, find.byIcon(Icons.dark_mode));

    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
  });

  testWidgets('Big toggle button also flips theme', (tester) async {
    await pumpApp(tester);

    await tester.scrollUntilVisible(
      find.text('Switch to Dark'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tapToggle(tester, find.text('Switch to Dark'));

    await tester.scrollUntilVisible(
      find.text('Switch to Light'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Switch to Light'), findsOneWidget);
  });

  testWidgets('Switching animation type updates preview text', (tester) async {
    await pumpApp(tester);

    expect(find.textContaining('circle'), findsWidgets);

    await tester.tap(find.text('line'));
    await tester.pump();

    expect(find.textContaining('line'), findsWidgets);
  });
}
