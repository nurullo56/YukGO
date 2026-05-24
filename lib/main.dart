import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/token_storage.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';
import 'package:yukgo_flutter/features/onboarding/screens/splash_screen.dart';
import 'package:yukgo_flutter/features/onboarding/screens/onboarding_screen.dart';
import 'package:yukgo_flutter/features/auth/screens/email_login_screen.dart';
import 'package:yukgo_flutter/features/auth/screens/basic_info_screen.dart';
import 'package:yukgo_flutter/features/auth/screens/furachi_setup_screen.dart';
import 'package:yukgo_flutter/features/auth/screens/yukchi_setup_screen.dart';
import 'package:yukgo_flutter/features/auth/screens/role_selection_screen.dart';
import 'package:yukgo_flutter/features/yukchi/screens/yukchi_home_screen.dart';
import 'package:yukgo_flutter/features/profile/profile_screen.dart';
import 'package:yukgo_flutter/features/driver/screens/order_detail_screen.dart';
import 'package:yukgo_flutter/features/driver/models/order_model.dart';
import 'package:yukgo_flutter/features/shipper/screens/driver_list_screen.dart';
import 'package:yukgo_flutter/features/shipper/screens/driver_profile_screen.dart';
import 'package:yukgo_flutter/features/shipper/screens/order_tracking_screen.dart';
import 'package:yukgo_flutter/features/shipper/screens/shipper_chat_screen.dart';
import 'package:yukgo_flutter/features/furachi/screens/furachi_home_screen.dart';
import 'package:yukgo_flutter/features/chat/screens/chat_screen.dart';
import 'package:yukgo_flutter/core/services/fcm_service.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

const _protectedRoutes = {
  '/ai-chat', '/furachi-home', '/driver-list', '/driver-profile',
  '/order-tracking', '/order-detail', '/shipper-chat', '/profile', '/chat',
};

Route<dynamic> _generateRoute(RouteSettings s) {
  if (_protectedRoutes.contains(s.name) && !UserSession.isLoggedIn) {
    return MaterialPageRoute(builder: (_) => const EmailLoginScreen(), settings: s);
  }

  final builders = <String, WidgetBuilder>{
    '/splash':          (_) => const SplashScreen(),
    '/onboarding':      (_) => const OnboardingScreen(),
    '/login':           (_) => const EmailLoginScreen(),
    '/role-selection':  (_) => const RoleSelectionScreen(),
    '/basic-info':      (_) => const BasicInfoScreen(role: 'yukchi'),
    '/furachi-setup':   (_) => const FurachiSetupScreen(),
    '/yukchi-setup':    (_) => const YukchiSetupScreen(),
    '/ai-chat':         (_) => const YukchiHomeScreen(),
    '/furachi-home':    (_) => const FurachiHomeScreen(),
    '/driver-list':     (_) => const DriverListScreen(),
    '/driver-profile':  (_) => const DriverProfileScreen(),
    '/order-tracking':  (_) => const OrderTrackingScreen(),
    '/order-detail':    (_) {
      final order = s.arguments as OrderModel? ?? const OrderModel();
      return OrderDetailScreen(order: order);
    },
    '/shipper-chat':    (_) => const ShipperChatScreen(),
    '/profile':         (_) => const ProfileScreen(),
    '/chat':            (_) {
      final args = s.arguments as Map<String, String>? ?? {};
      return ChatScreen(
        roomId: args['roomId'] ?? '',
        otherName: args['otherName'] ?? 'Chat',
      );
    },
  };

  final builder = builders[s.name];
  if (builder != null) return MaterialPageRoute(builder: builder, settings: s);
  return MaterialPageRoute(builder: (_) => const SplashScreen());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const YukGoApp());
}

class YukGoApp extends StatefulWidget {
  const YukGoApp({super.key});

  @override
  State<YukGoApp> createState() => _YukGoAppState();
}

class _YukGoAppState extends State<YukGoApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.scheme == 'yukgo' && uri.path == '/auth') {
      final token = uri.queryParameters['token'];
      if (token == null || token.isEmpty) return;

      await TokenStorage.saveToken(token);

      try {
        final userData = await ApiService.getMe();
        UserSession.isLoggedIn = true;
        UserSession.userId = userData['id'] ?? 0;
        UserSession.role = userData['role'] ?? 'yukchi';
        UserSession.firstName = userData['first_name'] ?? '';
        UserSession.lastName = userData['last_name'] ?? '';
        final isComplete = userData['is_profile_complete'] ?? false;

        final nav = _navigatorKey.currentState;
        if (nav == null) return;

        if (!isComplete) {
          nav.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (_) => false,
          );
        } else {
          nav.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => UserSession.isYukchi
                  ? const YukchiHomeScreen()
                  : const FurachiHomeScreen(),
            ),
            (_) => false,
          );
        }
      } catch (_) {
        await TokenStorage.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: UserSession.darkMode,
      builder: (context, isDark, _) => MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'YukGo',
        debugShowCheckedModeBanner: false,
        theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
        home: const SplashScreen(),
        onGenerateRoute: _generateRoute,
      ),
    );
  }
}
