// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:computer_interact_thing/main.dart';

void main() {
  testWidgets('Mouse tracking UI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Check for the presence of the main tracking text
    expect(find.textContaining('MOVEMENTS TRACKED'), findsOneWidget);
    expect(find.textContaining('CLICK INTERACTIONS'), findsOneWidget);
    expect(find.textContaining('DISTANCE MOVED'), findsOneWidget);
    expect(find.textContaining('SYSTEM STATUS'), findsOneWidget);
    expect(find.textContaining('TRACKING SYSTEM OPERATIONAL'), findsOneWidget);
  });
}
