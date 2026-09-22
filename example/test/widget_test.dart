import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theme_toggle_animation_example/main.dart';

void main() {
  testWidgets('App renders with toggle button', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.text('Theme Toggle Animation'), findsOneWidget);
  });

  testWidgets('Tap toggle flips theme', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pump();

    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });
}
