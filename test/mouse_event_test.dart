import 'package:flutter_test/flutter_test.dart';
import 'package:computer_interact_thing/main.dart';

void main() {
  test('MouseEvent stores data correctly', () {
    final now = DateTime.now();
    final event = MouseEvent(now, 100, 200, 'move');
    expect(event.timestamp, now);
    expect(event.x, 100);
    expect(event.y, 200);
    expect(event.type, 'move');
  });
}
