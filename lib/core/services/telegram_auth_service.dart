import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';
import 'package:yukgo_flutter/core/services/token_storage.dart';

class TelegramAuthService {
  static const _keyDeviceId = 'device_id';
  static String? _currentToken;
  static String? _botLink;

  static String? get currentToken => _currentToken;

  /// Doimiy device ID — bir marta yaratib SharedPreferences da saqlanadi
  static Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_keyDeviceId);
    if (id == null || id.isEmpty) {
      id = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_keyDeviceId, id);
    }
    return id;
  }

  /// Backend dan token + bot link olish
  static Future<String?> initAuth() async {
    try {
      final deviceId = await _getDeviceId();
      final data = await ApiService.initAuth(deviceId);
      _currentToken = data['token'] as String;
      _botLink = data['bot_link'] as String;
      return _botLink;
    } catch (e) {
      // Backend ishlamasa — fallback (demo)
      _currentToken = 'demo_${DateTime.now().millisecondsSinceEpoch}';
      _botLink = 'https://t.me/Logistics_login_bot?start=$_currentToken';
      return _botLink;
    }
  }

  /// Telegram botni ochish
  static Future<bool> openTelegramBot() async {
    final botLink = await initAuth();
    if (botLink == null) return false;

    // Telegram app URI
    final token = _currentToken!;
    final tgUri = Uri.parse('tg://resolve?domain=Logistics_login_bot&start=$token');
    final webUri = Uri.parse(botLink);

    try {
      if (await canLaunchUrl(tgUri)) {
        await launchUrl(tgUri, mode: LaunchMode.externalApplication);
        return true;
      }
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Deep link dan JWT tokenni saqlash
  static Future<void> handleDeepLink(Uri uri) async {
    if (uri.scheme == 'yukgo' && uri.path == '/auth') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        await TokenStorage.saveToken(token);
      }
    }
  }
}
