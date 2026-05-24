import 'package:flutter/foundation.dart';

class UserSession {
  static String role = 'yukchi'; // 'yukchi' or 'furachi'
  static bool get isYukchi => role == 'yukchi';
  static bool get isFurachi => role == 'furachi';

  // Global dark mode
  static final ValueNotifier<bool> darkMode = ValueNotifier(false);

  // Global til — 'uz' | 'ru' | 'en'
  static final ValueNotifier<String> language = ValueNotifier('uz');

  // Bildirishnomalar
  static final ValueNotifier<bool> notifications = ValueNotifier(true);

  // Auth holati
  static bool isLoggedIn = false;
  static int userId = 0;

  // Foydalanuvchi ma'lumotlari
  static String email = '';
  static String firstName = '';
  static String lastName = '';
  static String phone = '';
  static String get fullName => '$firstName $lastName'.trim();

  // Furachi ma'lumotlari
  static String truckType = '';
  static String capacity = '';
  static String fromCity = '';
  static List<String> toRoutes = [];

  // Yukchi ma'lumotlari
  static String cargoType = '';
}
