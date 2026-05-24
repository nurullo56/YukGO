import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/services/token_storage.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/notification_service.dart';
import 'package:yukgo_flutter/core/services/fcm_service.dart';
import 'package:yukgo_flutter/features/onboarding/screens/onboarding_screen.dart';
import 'package:yukgo_flutter/features/yukchi/screens/yukchi_home_screen.dart';
import 'package:yukgo_flutter/features/furachi/screens/furachi_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final notifEnabled = await NotificationService.isEnabled();
    UserSession.notifications.value = notifEnabled;

    // FCM ni fon da ishga tushirish (UI ni bloklamaslik uchun)
    FcmService.init().catchError((_) {});

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Saqlangan token bormi?
    final hasToken = await TokenStorage.hasToken();
    if (hasToken) {
      try {
        // Backend dan user ma'lumotlarini olish
        final userData = await ApiService.getMe();
        UserSession.isLoggedIn = true;
        UserSession.userId = userData['id'] ?? 0;
        UserSession.role = userData['role'] ?? 'yukchi';
        UserSession.firstName = userData['first_name'] ?? '';
        UserSession.lastName = userData['last_name'] ?? '';
        final isComplete = userData['is_profile_complete'] ?? false;

        // Local storage dan qo'shimcha ma'lumotlarni yuklash
        final local = await TokenStorage.getUserProfile();
        if (UserSession.firstName.isEmpty) UserSession.firstName = local['firstName'] ?? '';
        if (UserSession.lastName.isEmpty) UserSession.lastName = local['lastName'] ?? '';
        UserSession.phone = (userData['phone'] as String?) ?? local['phone'] ?? '';
        UserSession.fromCity = (userData['from_city'] as String?) ?? local['fromCity'] ?? '';
        UserSession.truckType = (userData['truck_type'] as String?) ?? local['truckType'] ?? '';
        UserSession.capacity = (userData['capacity'] as String?) ?? local['capacity'] ?? '';
        UserSession.cargoType = (userData['cargo_type'] as String?) ?? local['cargoType'] ?? '';

        if (!mounted) return;
        if (!isComplete) {
          // Profil to'ldirilmagan в†’ role selection
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
          return;
        }

        // To'liq login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => UserSession.isYukchi
                ? const YukchiHomeScreen()
                : const FurachiHomeScreen(),
          ),
        );
        return;
      } catch (_) {
        // Token eskirgan yoki xato в†’ tozalash
        await TokenStorage.clear();
      }
    }

    // Token yo'q в†’ onboarding
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, const Color(0xFF1a60d4)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_shipping,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'YukGo',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yukingizni tez va oson yetkazamiz',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
