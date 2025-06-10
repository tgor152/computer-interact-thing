import 'mouse_event.dart';

class TrackingData {
  final List<MouseEvent> events;
  final int clickCount;
  final double distance;
  final String currentTime;
  
  TrackingData({
    required this.events,
    required this.clickCount,
    required this.distance,
    required this.currentTime,
  });
  
  TrackingData copyWith({
    List<MouseEvent>? events,
    int? clickCount,
    double? distance,
    String? currentTime,
  }) {
    return TrackingData(
      events: events ?? this.events,
      clickCount: clickCount ?? this.clickCount,
      distance: distance ?? this.distance,
      currentTime: currentTime ?? this.currentTime,
    );
  }
}