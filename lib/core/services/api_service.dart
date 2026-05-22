import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:yukgo_flutter/core/services/token_storage.dart';

class ApiService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api/v1';
    return 'http://192.168.1.4:8000/api/v1'; // WiFi IP - real Android device
  }

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: kIsWeb ? 'http://localhost:8000/api/v1' : 'http://192.168.1.4:8000/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  static Future<String?> _getToken() => TokenStorage.getToken();

  static Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ─── Auth ────────────────────────────────────────────────────────────────

  /// Flutter → backend: token va bot link olish
  static Future<Map<String, dynamic>> initAuth(String deviceId) async {
    final resp = await _dio.post('/auth/init', data: {'device_id': deviceId});
    return resp.data as Map<String, dynamic>;
  }

  /// Token bilan profil olish
  static Future<Map<String, dynamic>> getMe() async {
    final resp = await _dio.get('/auth/me', options: await _authOptions());
    return resp.data as Map<String, dynamic>;
  }

  /// Profil to'ldirish
  static Future<Map<String, dynamic>> setupProfile(Map<String, dynamic> data) async {
    final resp = await _dio.patch('/auth/profile',
        data: data, options: await _authOptions());
    return resp.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> verifyCode(String code) async {
    final resp = await _dio.post('/auth/verify-code', data: {'code': code});
    return resp.data as Map<String, dynamic>;
  }

  // ─── Orders ──────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getOrders() async {
    final resp = await _dio.get('/orders', options: await _authOptions());
    return resp.data as List<dynamic>;
  }

  static Future<List<dynamic>> getMyOrders() async {
    final resp = await _dio.get('/orders/my', options: await _authOptions());
    return resp.data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    final resp = await _dio.post('/orders',
        data: data, options: await _authOptions());
    return resp.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> acceptOrder(int orderId) async {
    final resp = await _dio.patch('/orders/$orderId/accept',
        options: await _authOptions());
    return resp.data as Map<String, dynamic>;
  }
}
