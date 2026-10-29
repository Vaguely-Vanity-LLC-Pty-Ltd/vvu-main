// This is a basic Flutter widget test.
//
// To perform an interaction with a widget test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vvu_unified/main.dart';

void main() {
  testWidgets('App boots smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VvuUnifiedRoofApp());

    // The estate mark 'V' and the roof title should appear.
    expect(find.text('VVU UNIFIED ROOF'), findsWidgets);
  });
}
