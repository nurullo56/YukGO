import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const _keyEnabled = 'notifications_enabled';
  static const _keyOrders = 'notif_orders';
  static const _keyPromo = 'notif_promo';
  static const _keySystem = 'notif_system';

  static Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> hasPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  static Future<void> openSettings() => openAppSettings();

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? true;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, value);
  }

  static Future<Map<String, bool>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'orders': prefs.getBool(_keyOrders) ?? true,
      'promo':  prefs.getBool(_keyPromo) ?? true,
      'system': prefs.getBool(_keySystem) ?? true,
    };
  }

  static Future<void> setCategory(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final prefKey = key == 'orders' ? _keyOrders : key == 'promo' ? _keyPromo : _keySystem;
    await prefs.setBool(prefKey, value);
  }
}
