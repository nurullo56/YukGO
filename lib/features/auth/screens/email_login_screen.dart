import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/telegram_auth_service.dart';
import 'package:yukgo_flutter/features/auth/widgets/step_indicator.dart';
import 'package:yukgo_flutter/features/auth/screens/otp_screen.dart';
import 'package:yukgo_flutter/features/auth/screens/telegram_otp_screen.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.-]+@[\w.-]+\.[a-z]{2,}$').hasMatch(email.trim());
  }

  void _continue() async {
    final email = _emailCtrl.text.trim();
    if (!_isValidEmail(email)) {
      setState(() => _error = "To'g'ri Gmail manzilini kiriting");
      return;
    }
    setState(() { _loading = true; _error = null; });
    // Simulate sending OTP
    await Future.delayed(const Duration(milliseconds: 1200));
    UserSession.email = email;
    setState(() => _loading = false);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => OtpScreen(email: email),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              StepIndicator(current: 1, total: 5),
              const SizedBox(height: 36),

              // Logo
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Text('YukGo', style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.w800, color: context.textPrimary,
                  )),
                ],
              ),
              const SizedBox(height: 40),

              Text("Xush kelibsiz!", style: GoogleFonts.inter(
                fontSize: 28, fontWeight: FontWeight.w800, color: context.textPrimary,
              )),
              const SizedBox(height: 8),
              Text("Gmail manzilingizni kiriting,\ntasdiqlash kodi yuboramiz", style: GoogleFonts.inter(
                fontSize: 15, color: context.textMuted, height: 1.5,
              )),
              const SizedBox(height: 40),

              Text("Gmail manzil", style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: context.textMuted,
              )),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.inter(fontSize: 15, color: context.textPrimary),
                onChanged: (_) => setState(() => _error = null),
                decoration: InputDecoration(
                  hintText: 'example@gmail.com',
                  hintStyle: GoogleFonts.inter(color: context.textMuted),
                  prefixIcon: Icon(Icons.email_outlined, color: context.textMuted),
                  filled: true,
                  fillColor: context.inputColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  errorText: _error,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 12),

              // Demo hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Demo: istalgan Gmail kiriting, kod avtomatik tasdiqlanadi",
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Telegram tugmasi
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const TelegramOtpScreen(token: ''),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF229ED9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.telegram, size: 24),
                  label: Text("Telegram orqali kirish", style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),

              // Ajratuvchi
              Row(children: [
                Expanded(child: Divider(color: context.borderColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text("yoki", style: GoogleFonts.inter(
                    fontSize: 13, color: context.textMuted)),
                ),
                Expanded(child: Divider(color: context.borderColor)),
              ]),
              const SizedBox(height: 12),

              // Gmail tugmasi
              SizedBox(
                width: double.infinity, height: 56,
                child: OutlinedButton(
                  onPressed: _loading ? null : _continue,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.borderColor, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    foregroundColor: context.textPrimary,
                  ),
                  child: _loading
                      ? SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.primary, strokeWidth: 2.5))
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.email_outlined, color: context.textPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text("Gmail orqali kirish", style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                        ]),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
