import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';
import 'package:yukgo_flutter/core/services/token_storage.dart';
import 'package:yukgo_flutter/core/services/telegram_auth_service.dart';
import 'package:yukgo_flutter/features/auth/screens/role_selection_screen.dart';
import 'package:yukgo_flutter/features/yukchi/screens/yukchi_home_screen.dart';
import 'package:yukgo_flutter/features/furachi/screens/furachi_home_screen.dart';

class TelegramOtpScreen extends StatefulWidget {
  final String token;
  const TelegramOtpScreen({super.key, required this.token});

  @override
  State<TelegramOtpScreen> createState() => _TelegramOtpScreenState();
}

class _TelegramOtpScreenState extends State<TelegramOtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _code => _ctrls.map((c) => c.text).join();

  void _onChanged(int i, String val) {
    if (val.length == 6) {
      for (int j = 0; j < 6 && j < val.length; j++) {
        _ctrls[j].text = val[j];
      }
      _nodes[5].requestFocus();
      setState(() {});
      return;
    }
    if (val.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
    setState(() {});
  }

  void _onKey(int i, RawKeyEvent e) {
    if (e is RawKeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[i].text.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
  }

  void _verify() async {
    if (_code.length < 6) {
      setState(() => _error = "6 raqamli kodni to'liq kiriting");
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      final data = await ApiService.verifyCode(_code);
      final token = data['auth_token'] as String;
      await TokenStorage.saveToken(token);

      final userData = await ApiService.getMe();
      UserSession.isLoggedIn = true;
      UserSession.role = userData['role'] ?? 'yukchi';
      UserSession.firstName = userData['first_name'] ?? '';
      UserSession.lastName = userData['last_name'] ?? '';
      UserSession.phone = userData['phone'] ?? '';
      final isComplete = userData['is_profile_complete'] ?? false;

      if (!mounted) return;
      if (!isComplete) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          (_) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => UserSession.isYukchi
                ? const YukchiHomeScreen()
                : const FurachiHomeScreen(),
          ),
          (_) => false,
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Kod noto'g'ri yoki muddati o'tgan";
      });
    }
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
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: context.inputColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_back, color: context.textPrimary, size: 20),
                ),
              ),
              const SizedBox(height: 32),

              // Telegram icon
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF229ED9).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.telegram, color: Color(0xFF229ED9), size: 36),
              ),
              const SizedBox(height: 20),

              Text("Telegram kodi \u{1F511}", style: GoogleFonts.inter(
                fontSize: 26, fontWeight: FontWeight.w800, color: context.textPrimary,
              )),
              const SizedBox(height: 8),
              Text(
                "Telegram botdan kelgan 6 raqamli kodni kiriting",
                style: GoogleFonts.inter(fontSize: 14, color: context.textMuted, height: 1.5),
              ),
              const SizedBox(height: 8),

              // Hint box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF229ED9).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF229ED9).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF229ED9), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Bot da \u{00AB}\u{1F4F1} Telefon raqamni yuborish\u{00BB} tugmasini bosing \u{2192} kod keladi",
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF229ED9)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _OtpBox(
                  ctrl: _ctrls[i],
                  node: _nodes[i],
                  onChanged: (v) => _onChanged(i, v),
                  onKey: (e) => _onKey(i, e),
                  hasValue: _ctrls[i].text.isNotEmpty,
                  accentColor: const Color(0xFF229ED9),
                )),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.red.shade400,
                )),
              ],

              const SizedBox(height: 24),

              // Qayta ochish
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await TelegramAuthService.openTelegramBot();
                  },
                  child: Text(
                    "Telegram botni qayta ochish",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF229ED9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF229ED9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text("Tasdiqlash", style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w700)),
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

class _OtpBox extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode node;
  final ValueChanged<String> onChanged;
  final ValueChanged<RawKeyEvent> onKey;
  final bool hasValue;
  final Color accentColor;

  const _OtpBox({
    required this.ctrl,
    required this.node,
    required this.onChanged,
    required this.onKey,
    required this.hasValue,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: node,
      onKey: onKey,
      child: SizedBox(
        width: 46, height: 56,
        child: TextField(
          controller: ctrl,
          focusNode: node,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.inter(
            fontSize: 22, fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: hasValue
                ? accentColor.withValues(alpha: 0.1)
                : context.inputColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: hasValue
                  ? BorderSide(color: accentColor, width: 1.5)
                  : BorderSide.none,
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

