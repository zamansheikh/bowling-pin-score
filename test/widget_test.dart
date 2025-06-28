// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:bowlingpinscore/main.dart';

void main() {
  testWidgets('Bowling app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the bowling demo page loads
    expect(find.text('🎳 Visual Bowling Pin Interface'), findsOneWidget);

    // Verify that the demo content is displayed
    expect(find.text('🎳 VISUAL BOWLING INTERFACE'), findsOneWidget);
    expect(
      find.text('Interactive pin scoring without any number input!'),
      findsOneWidget,
    );

    // Verify that pins counter is displayed
    expect(find.text('Pins Down: 0/10'), findsOneWidget);

    // Verify that control buttons are present
    expect(find.text('Reset All Pins'), findsOneWidget);
    expect(find.text('Strike!'), findsOneWidget);

    // Verify that features section is displayed
    expect(find.text('✨ FEATURES'), findsOneWidget);
  });
}
