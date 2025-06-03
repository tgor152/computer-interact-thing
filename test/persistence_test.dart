import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Persistence Tests', () {
    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('Should save and load click count from SharedPreferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'lifetime_click_count': 42});
      final prefs = await SharedPreferences.getInstance();
      
      // Act
      final savedCount = prefs.getInt('lifetime_click_count') ?? 0;
      
      // Assert
      expect(savedCount, 42);
    });

    test('Should save and load distance from SharedPreferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'lifetime_distance': 123.45});
      final prefs = await SharedPreferences.getInstance();
      
      // Act
      final savedDistance = prefs.getDouble('lifetime_distance') ?? 0.0;
      
      // Assert
      expect(savedDistance, 123.45);
    });

    test('Should return default values when no data is saved', () async {
      // Arrange - empty preferences
      final prefs = await SharedPreferences.getInstance();
      
      // Act
      final clickCount = prefs.getInt('lifetime_click_count') ?? 0;
      final distance = prefs.getDouble('lifetime_distance') ?? 0.0;
      
      // Assert
      expect(clickCount, 0);
      expect(distance, 0.0);
    });

    test('Should be able to increment and save click count', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      int initialCount = prefs.getInt('lifetime_click_count') ?? 0;
      
      // Act
      int newCount = initialCount + 1;
      await prefs.setInt('lifetime_click_count', newCount);
      
      // Assert
      final savedCount = prefs.getInt('lifetime_click_count') ?? 0;
      expect(savedCount, 1);
    });

    test('Should be able to accumulate distance', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      double initialDistance = prefs.getDouble('lifetime_distance') ?? 0.0;
      
      // Act
      double additionalDistance = 50.5;
      double newDistance = initialDistance + additionalDistance;
      await prefs.setDouble('lifetime_distance', newDistance);
      
      // Assert
      final savedDistance = prefs.getDouble('lifetime_distance') ?? 0.0;
      expect(savedDistance, 50.5);
    });

    test('Should persist lifetime counters correctly across multiple increments', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      
      // Act - simulate multiple clicks and distance accumulation
      int totalClicks = 0;
      double totalDistance = 0.0;
      
      for (int i = 0; i < 5; i++) {
        totalClicks++;
        totalDistance += 10.0;
        await prefs.setInt('lifetime_click_count', totalClicks);
        await prefs.setDouble('lifetime_distance', totalDistance);
      }
      
      // Assert
      final finalClicks = prefs.getInt('lifetime_click_count') ?? 0;
      final finalDistance = prefs.getDouble('lifetime_distance') ?? 0.0;
      
      expect(finalClicks, 5);
      expect(finalDistance, 50.0);
    });
  });
}