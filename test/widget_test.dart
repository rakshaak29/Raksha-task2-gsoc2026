import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquidgalaxy_t2/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LiquidGalaxyApp());

    // Verify that the title shows up
    expect(find.text('Liquid Galaxy Control'), findsOneWidget);
  });
}
