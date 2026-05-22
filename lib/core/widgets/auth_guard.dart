import 'package:flutter/material.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/features/auth/screens/email_login_screen.dart';

/// Har qanday ekran oldiga qo'yiladi — login bo'lmasa loginга redirect
class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  void initState() {
    super.initState();
    if (!UserSession.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
          (_) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!UserSession.isLoggedIn) return const SizedBox.shrink();
    return widget.child;
  }
}
