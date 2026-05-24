import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _keyToken = 'auth_token';
  static const _keyRole = 'user_role';
  static const _keyProfileComplete = 'profile_complete';

  // User profile keys
  static const _keyFirstName = 'user_first_name';
  static const _keyLastName = 'user_last_name';
  static const _keyPhone = 'user_phone';
  static const _keyFromCity = 'user_from_city';
  static const _keyTruckType = 'user_truck_type';
  static const _keyCapacity = 'user_capacity';
  static const _keyCargoType = 'user_cargo_type';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  static Future<void> setProfileComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyProfileComplete, value);
  }

  static Future<bool> isProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyProfileComplete) ?? false;
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> saveUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String fromCity,
    String truckType = '',
    String capacity = '',
    String cargoType = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFirstName, firstName);
    await prefs.setString(_keyLastName, lastName);
    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyFromCity, fromCity);
    await prefs.setString(_keyTruckType, truckType);
    await prefs.setString(_keyCapacity, capacity);
    await prefs.setString(_keyCargoType, cargoType);
  }

  static Future<Map<String, String>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString(_keyFirstName) ?? '',
      'lastName': prefs.getString(_keyLastName) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
      'fromCity': prefs.getString(_keyFromCity) ?? '',
      'truckType': prefs.getString(_keyTruckType) ?? '',
      'capacity': prefs.getString(_keyCapacity) ?? '',
      'cargoType': prefs.getString(_keyCargoType) ?? '',
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
