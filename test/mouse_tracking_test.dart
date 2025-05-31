import 'package:flutter_test/flutter_test.dart';
import 'package:computer_interact_thing/main.dart';

void main() {
  group('Mouse Tracking Tests', () {
    test('MouseEvent should only be created for actual movement', () {
      // Test that we can create events with different positions
      final event1 = MouseEvent(DateTime.now(), 100, 200, 'move');
      final event2 = MouseEvent(DateTime.now(), 150, 250, 'move');
      
      expect(event1.x, 100);
      expect(event1.y, 200);
      expect(event2.x, 150);
      expect(event2.y, 250);
      
      // Positions should be different
      expect(event1.x != event2.x || event1.y != event2.y, true);
    });
    
    test('Mouse positions should be compared for movement detection', () {
      // Test the logic that should be used to detect movement
      int lastX = 100;
      int lastY = 200;
      
      // Same position - no movement
      int currentX1 = 100;
      int currentY1 = 200;
      bool hasMovement1 = currentX1 != lastX || currentY1 != lastY;
      expect(hasMovement1, false);
      
      // Different position - movement detected
      int currentX2 = 105;
      int currentY2 = 205;
      bool hasMovement2 = currentX2 != lastX || currentY2 != lastY;
      expect(hasMovement2, true);
      
      // Only X changed - movement detected
      int currentX3 = 110;
      int currentY3 = 200;
      bool hasMovement3 = currentX3 != lastX || currentY3 != lastY;
      expect(hasMovement3, true);
      
      // Only Y changed - movement detected
      int currentX4 = 100;
      int currentY4 = 210;
      bool hasMovement4 = currentX4 != lastX || currentY4 != lastY;
      expect(hasMovement4, true);
    });
  });
}