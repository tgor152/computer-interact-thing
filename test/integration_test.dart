import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:computer_interact_thing/models/mouse_event.dart';
import 'package:computer_interact_thing/services/persistence_service.dart';

void main() {
  group('MVVM Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('PersistenceService integration with real data flow', () async {
      // Arrange
      final service = PersistenceService();
      
      // Simulate initial load
      var clickCount = await service.getClickCount();
      var distance = await service.getDistance();
      expect(clickCount, 0);
      expect(distance, 0.0);
      
      // Simulate some activity
      await service.saveData(5, 100.5);
      
      // Verify data persistence
      clickCount = await service.getClickCount();
      distance = await service.getDistance();
      expect(clickCount, 5);
      expect(distance, 100.5);
    });

    test('MouseEvent data flow is consistent', () {
      // Simulate mouse tracking flow
      final events = <MouseEvent>[];
      
      // Add some movement events
      events.add(MouseEvent(DateTime.now(), 0, 0, 'move'));
      events.add(MouseEvent(DateTime.now(), 10, 10, 'move'));
      events.add(MouseEvent(DateTime.now(), 10, 10, 'click'));
      
      expect(events.length, 3);
      expect(events.where((e) => e.type == 'move').length, 2);
      expect(events.where((e) => e.type == 'click').length, 1);
    });
  });
}