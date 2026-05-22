import 'package:dio/dio.dart';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiClient {
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  // ✅ Platformaga qarab URL tanlash
  static String get _baseUrl {
    // Web uchun
    if (kIsWeb) {
      return 'http://192.168.1.6:8000';  // ✅ SIZNING IP
    }
    
    // Mobile uchun
    if (Platform.isAndroid) {
      return 'http://192.168.1.6:8000';  // ✅ SIZNING IP
    }
    
    if (Platform.isIOS) {
      return 'http://192.168.1.6:8000';  // ✅ SIZNING IP
    }
    
    // Default (xatolik bo'lsa)
    return 'http://192.168.1.6:8000';
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Log interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        log("🚀 REQUEST[${options.method}] => PATH: ${options.path}");
        log("📍 BASE_URL: ${options.baseUrl}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log("✅ RESPONSE[${response.statusCode}] => DATA: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        log("❌ ERROR[${e.response?.statusCode}] => MESSAGE: ${e.message}");
        log("📍 URL: ${e.requestOptions.uri}");
        return handler.next(e);
      },
    ));
  }

  /// Telefon raqamni tekshirish (Bot yuborgan token orqali)
  Future<Map<String, dynamic>?> verifyPhone({
    required String token,
    required int telegramId,
    required String phone,
    String? firstName,
    String? lastName,
    String? username,
  }) async {
    const String path = "/api/v1/auth/verify";

    final Map<String, dynamic> payload = {
      "token": token,
      "telegram_id": telegramId,
      "phone": phone,
      "first_name": firstName,
      "last_name": lastName,
      "username": username,
    };

    try {
      final response = await _dio.post(path, data: payload);
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      log("Dio xatolik: ${e.response?.data ?? e.message}");
      return null;
    } catch (e) {
      log("Kutilmagan xatolik: $e");
      return null;
    }
  }
  
  /// API URL ni o'zgartirish uchun (development vaqtida)
  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
    log("🔄 Base URL o'zgartirildi: $newUrl");
  }
}