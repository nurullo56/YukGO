import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // Oldingi qiymatlar — backspace aniqlash uchun
  final List<String> _prev = List.filled(6, '');

  bool _loading = false;
  String? _error;

  static const _accent = Color(0xFF229ED9);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) TelegramAuthService.openTelegramBot().catchError((_) {});
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _code => _ctrls.map((c) => c.text).join();

  void _onChanged(int i, String val) {
    // 6 ta raqam birdan yopishtirilsa (paste)
    if (val.length == 6) {
      for (int j = 0; j < 6; j++) {
        _ctrls[j].text = val[j];
        _prev[j] = val[j];
      }
      _nodes[5].requestFocus();
      setState(() {});
      if (_code.length == 6) _verify();
      return;
    }

    final prev = _prev[i];
    _prev[i] = val;

    if (val.isEmpty && prev.isEmpty && i > 0) {
      // Backspace — bo'sh katakda → oldingisiga o'tish
      _ctrls[i - 1].clear();
      _prev[i - 1] = '';
      _nodes[i - 1].requestFocus();
    } else if (val.isNotEmpty && i < 5) {
      // Raqam kiritildi → keyingisiga o'tish
      _nodes[i + 1].requestFocus();
    }
    setState(() {});
  }

  void _verify() async {
    final code = _code;
    if (code.length < 6) {
      setState(() => _error = "6 raqamli kodni to'liq kiriting");
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      final data = await ApiService.verifyCode(code);
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
        final msg = e.toString().toLowerCase();
        if (msg.contains('400') || msg.contains('not_found') || msg.contains('token')) {
          _error = "Kod noto'g'ri yoki muddati o'tgan. Botdan yangi kod oling.";
        } else if (msg.contains('connect') || msg.contains('network') || msg.contains('socket')) {
          _error = "Internet aloqa yo'q. Tekshirib qaytadan urining.";
        } else {
          _error = "Xato: $e";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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

                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.telegram, color: _accent, size: 36),
                    ),
                    const SizedBox(height: 20),

                    Row(children: [
                      Text("Telegram kodi ", style: GoogleFonts.inter(
                        fontSize: 26, fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      )),
                      Icon(Icons.vpn_key_rounded, color: context.textPrimary, size: 26),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      "Telegram botdan kelgan 6 raqamli kodni kiriting",
                      style: GoogleFonts.inter(
                        fontSize: 14, color: context.textMuted, height: 1.5),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _accent.withValues(alpha: 0.2)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.info_outline, color: _accent, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Telegramda «Telefon raqamni yuborish» tugmasini bosing",
                            style: GoogleFonts.inter(fontSize: 12, color: _accent),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 32),

                    // 6 ta OTP katak
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) => _OtpBox(
                        ctrl: _ctrls[i],
                        node: _nodes[i],
                        autofocus: i == 0,
                        onChanged: (v) => _onChanged(i, v),
                        hasValue: _ctrls[i].text.isNotEmpty,
                        accentColor: _accent,
                      )),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.red.shade400,
                      )),
                    ],

                    const SizedBox(height: 24),

                    Center(
                      child: GestureDetector(
                        onTap: () => TelegramAuthService.openTelegramBot(),
                        child: Text(
                          "Telegram botni qayta ochish",
                          style: GoogleFonts.inter(
                            fontSize: 14, color: _accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text("Tasdiqlash", style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode node;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final bool hasValue;
  final Color accentColor;

  const _OtpBox({
    required this.ctrl,
    required this.node,
    required this.autofocus,
    required this.onChanged,
    required this.hasValue,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46, height: 56,
      child: TextField(
        controller: ctrl,
        focusNode: node,
        autofocus: autofocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w700,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: hasValue
              ? accentColor.withValues(alpha: 0.1)
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
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
    );
  }
}
