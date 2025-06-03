// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:computer_interact_thing/main.dart';

void main() {
  testWidgets('Mouse tracking UI smoke test', (WidgetTester tester) async {
    // Set up SharedPreferences mock to ensure clean state for UI tests
    SharedPreferences.setMockInitialValues({});
    
    await tester.pumpWidget(const MyApp());
    
    // Skip pumpAndSettle since persistent data loading is async and doesn't block UI
    await tester.pump();
    
    // Check for the presence of the main tracking text
    expect(find.textContaining('MOVEMENTS TRACKED'), findsOneWidget);
    expect(find.textContaining('CLICK INTERACTIONS'), findsOneWidget);
    expect(find.textContaining('DISTANCE MOVED'), findsOneWidget);
    expect(find.textContaining('SYSTEM STATUS'), findsOneWidget);
    expect(find.textContaining('TRACKING SYSTEM OPERATIONAL'), findsOneWidget);
  });

  testWidgets('Mouse tracking UI loads persistent data', (WidgetTester tester) async {
    // Set up SharedPreferences mock with existing data
    SharedPreferences.setMockInitialValues({
      'lifetime_click_count': 42,
      'lifetime_distance': 123.5,
    });
    
    await tester.pumpWidget(const MyApp());
    
    // Give time for persistent data loading without using pumpAndSettle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    // Check that the UI shows the persistent data
    expect(find.textContaining('42'), findsOneWidget); // Click count
    expect(find.textContaining('123.50 px'), findsOneWidget); // Distance with formatting
  });
}
