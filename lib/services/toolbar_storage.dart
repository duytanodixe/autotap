import 'package:shared_preferences/shared_preferences.dart';

class ToolbarStorage {
  static const String _posXKey = 'toolbar_pos_x';
  static const String _posYKey = 'toolbar_pos_y';

  Future<(double, double)> loadPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final x = prefs.getDouble(_posXKey);
      final y = prefs.getDouble(_posYKey);
      return (x ?? 350.0, y ?? 200.0);
    } catch (e) {
      return (350.0, 200.0);
    }
  }

  Future<void> savePosition(double x, double y) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_posXKey, x);
      await prefs.setDouble(_posYKey, y);
    } catch (e) {
      // Silently fail - toolbar position is not critical
    }
  }
}
