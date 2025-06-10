import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:computer_interact_thing/models/mouse_event.dart';
import 'package:computer_interact_thing/models/tracking_data.dart';
import 'package:computer_interact_thing/services/persistence_service.dart';

void main() {
  group('MVVM Structure Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('MouseEvent model works correctly', () {
      final now = DateTime.now();
      final event = MouseEvent(now, 100, 200, 'move');
      expect(event.timestamp, now);
      expect(event.x, 100);
      expect(event.y, 200);
      expect(event.type, 'move');
    });

    test('TrackingData model works correctly', () {
      final events = [MouseEvent(DateTime.now(), 10, 20, 'move')];
      final data = TrackingData(
        events: events,
        clickCount: 5,
        distance: 100.5,
        currentTime: '2024-01-01 12:00:00',
      );
      
      expect(data.events.length, 1);
      expect(data.clickCount, 5);
      expect(data.distance, 100.5);
      expect(data.currentTime, '2024-01-01 12:00:00');
      
      // Test copyWith
      final updated = data.copyWith(clickCount: 10);
      expect(updated.clickCount, 10);
      expect(updated.distance, 100.5); // Should remain unchanged
    });

    test('PersistenceService saves and loads data correctly', () async {
      SharedPreferences.setMockInitialValues({
        'lifetime_click_count': 42,
        'lifetime_distance': 123.5,
      });
      
      final service = PersistenceService();
      final clickCount = await service.getClickCount();
      final distance = await service.getDistance();
      
      expect(clickCount, 42);
      expect(distance, 123.5);
    });
  });
}