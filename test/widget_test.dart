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
    expect(find.textContaining('Mouse movements tracked'), findsOneWidget);
    expect(find.textContaining('Mouse clicks'), findsOneWidget);
    expect(find.textContaining('Distance moved'), findsOneWidget);
    expect(find.textContaining('Tracking is running in the background.'), findsOneWidget);
  });
}
