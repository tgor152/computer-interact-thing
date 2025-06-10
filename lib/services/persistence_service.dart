import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static const String _clickCountKey = 'lifetime_click_count';
  static const String _distanceKey = 'lifetime_distance';
  static const int _saveFrequency = 10;
  
  int _updatesSinceLastSave = 0;
  
  Future<int> getClickCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_clickCountKey) ?? 0;
  }
  
  Future<double> getDistance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_distanceKey) ?? 0.0;
  }
  
  Future<void> saveData(int clickCount, double distance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_clickCountKey, clickCount);
    await prefs.setDouble(_distanceKey, distance);
  }
  
  void saveDataIfNeeded(int clickCount, double distance) {
    _updatesSinceLastSave++;
    if (_updatesSinceLastSave >= _saveFrequency) {
      _updatesSinceLastSave = 0;
      saveData(clickCount, distance);
    }
  }
  
  Future<void> saveClickCountImmediately(int clickCount, double distance) async {
    await saveData(clickCount, distance);
  }
}