import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mouse_event.dart';
import '../models/tracking_data.dart';
import '../services/persistence_service.dart';
import '../services/firebase_service.dart';
import '../services/export_service.dart';
import '../services/mouse_tracking_service.dart';

class TrackingViewModel extends ChangeNotifier {
  final PersistenceService _persistenceService = PersistenceService();
  final FirebaseService _firebaseService = FirebaseService();
  final ExportService _exportService = ExportService();
  final MouseTrackingService _mouseTrackingService = MouseTrackingService();
  
  Timer? _clockTimer;
  
  TrackingData _trackingData = TrackingData(
    events: [],
    clickCount: 0,
    distance: 0.0,
    currentTime: DateTime.now().toString().substring(0, 19),
  );
  
  int? _lastX;
  int? _lastY;
  
  TrackingData get trackingData => _trackingData;
  User? get user => _firebaseService.user;
  bool get isSigningIn => _firebaseService.isSigningIn;
  
  Future<void> initialize() async {
    await _loadPersistentData();
    _startMouseTracking();
    _startClock();
    await _checkAuth();
  }
  
  Future<void> _loadPersistentData() async {
    final clickCount = await _persistenceService.getClickCount();
    final distance = await _persistenceService.getDistance();
    _trackingData = _trackingData.copyWith(
      clickCount: clickCount,
      distance: distance,
    );
    notifyListeners();
  }
  
  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _trackingData = _trackingData.copyWith(
        currentTime: DateTime.now().toString().substring(0, 19),
      );
      notifyListeners();
    });
  }
  
  void _startMouseTracking() {
    _mouseTrackingService.startTracking(
      onMouseMove: _handleMouseMove,
      onMouseClick: _handleMouseClick,
    );
  }
  
  void _handleMouseMove(MouseEvent event) {
    final distance = _mouseTrackingService.calculateDistance(
      event.x, event.y, _lastX, _lastY,
    );
    
    final newDistance = _trackingData.distance + distance;
    _persistenceService.saveDataIfNeeded(_trackingData.clickCount, newDistance);
    
    final newEvents = List<MouseEvent>.from(_trackingData.events)..add(event);
    _trackingData = _trackingData.copyWith(
      events: newEvents,
      distance: newDistance,
    );
    
    _lastX = event.x;
    _lastY = event.y;
    notifyListeners();
  }
  
  void _handleMouseClick(MouseEvent event) {
    final newClickCount = _trackingData.clickCount + 1;
    _persistenceService.saveClickCountImmediately(newClickCount, _trackingData.distance);
    
    final newEvents = List<MouseEvent>.from(_trackingData.events)..add(event);
    _trackingData = _trackingData.copyWith(
      events: newEvents,
      clickCount: newClickCount,
    );
    notifyListeners();
  }
  
  Future<void> _checkAuth() async {
    try {
      await _firebaseService.signInAnonymously();
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }
  
  Future<String?> uploadEventsToFirestore() async {
    try {
      await _firebaseService.uploadEventsToFirestore(_trackingData.events);
      return 'Events uploaded to Firestore!';
    } catch (e) {
      return 'Error uploading events: $e';
    }
  }
  
  Future<String?> exportToExcel() async {
    try {
      final filePath = await _exportService.exportToExcel(_trackingData.events);
      return 'Exported to $filePath';
    } catch (e) {
      return 'Error exporting: $e';
    }
  }
  
  @override
  void dispose() {
    // Save persistent data one final time when disposing
    _persistenceService.saveData(_trackingData.clickCount, _trackingData.distance);
    _mouseTrackingService.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }
}