import 'dart:async';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'dart:math';
import '../models/mouse_event.dart';

class MouseTrackingService {
  Timer? _moveTimer;
  Timer? _clickTimer;
  int? _lastX;
  int? _lastY;
  bool _isClicked = false;
  
  Function(MouseEvent)? onMouseMove;
  Function(MouseEvent)? onMouseClick;
  
  void startTracking({
    required Function(MouseEvent) onMouseMove,
    required Function(MouseEvent) onMouseClick,
  }) {
    this.onMouseMove = onMouseMove;
    this.onMouseClick = onMouseClick;
    
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final pt = calloc<POINT>();
      GetCursorPos(pt);
      final x = pt.ref.x;
      final y = pt.ref.y;
      calloc.free(pt);
      
      // Only log movement if the mouse position has actually changed
      if (_lastX != null && _lastY != null) {
        if (x != _lastX || y != _lastY) {
          onMouseMove(MouseEvent(DateTime.now(), x, y, 'move'));
        }
      } else {
        // First time initialization - record the initial position
        onMouseMove(MouseEvent(DateTime.now(), x, y, 'move'));
      }
      _lastX = x;
      _lastY = y;
    });
    
    _clickTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      bool isButtonPressed = (GetAsyncKeyState(VK_LBUTTON) & 0x8000) != 0;
      
      if (isButtonPressed && !_isClicked) {
        // Button was just pressed, record the click
        final pt = calloc<POINT>();
        GetCursorPos(pt);
        final x = pt.ref.x;
        final y = pt.ref.y;
        calloc.free(pt);
        onMouseClick(MouseEvent(DateTime.now(), x, y, 'click'));
        _isClicked = true;
      } else if (!isButtonPressed && _isClicked) {
        // Button was released
        _isClicked = false;
      }
    });
  }
  
  double calculateDistance(int newX, int newY, int? lastX, int? lastY) {
    if (lastX == null || lastY == null) return 0.0;
    final dx = (newX - lastX).abs();
    final dy = (newY - lastY).abs();
    return sqrt((dx * dx + dy * dy).toDouble());
  }
  
  void stopTracking() {
    _moveTimer?.cancel();
    _clickTimer?.cancel();
  }
  
  void dispose() {
    stopTracking();
  }
}