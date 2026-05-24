import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/features/auth/widgets/step_indicator.dart';
import 'package:yukgo_flutter/features/auth/screens/yukchi_setup_screen.dart';
import 'package:yukgo_flutter/features/auth/screens/furachi_setup_screen.dart';

class BasicInfoScreen extends StatefulWidget {
  final String role;
  const BasicInfoScreen({super.key, required this.role});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: UserSession.firstName);
    _lastNameCtrl = TextEditingController(text: UserSession.lastName);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    UserSession.firstName = _firstNameCtrl.text.trim();
    UserSession.lastName = _lastNameCtrl.text.trim();
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => widget.role == 'yukchi'
          ? const YukchiSetupScreen()
          : const FurachiSetupScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      StepIndicator(current: 2, total: 3),
                      const SizedBox(height: 24),
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
                      Text("Asosiy ma'lumotlar 📋", style: GoogleFonts.inter(
                        fontSize: 26, fontWeight: FontWeight.w800, color: context.textPrimary,
                      )),
                      const SizedBox(height: 8),
                      Text("Telegram'dan olingan ma'lumotlar to'ldirildi, tekshiring",
                        style: GoogleFonts.inter(fontSize: 14, color: context.textMuted, height: 1.5)),
                      const SizedBox(height: 36),

                      _label("Ism"),
                      const SizedBox(height: 8),
                      _field(
                        ctrl: _firstNameCtrl,
                        hint: 'Sardor',
                        icon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ismni kiriting' : null,
                      ),
                      const SizedBox(height: 16),

                      _label("Familya"),
                      const SizedBox(height: 8),
                      _field(
                        ctrl: _lastNameCtrl,
                        hint: 'Karimov',
                        icon: Icons.badge_outlined,
                        validator: (_) => null,
                      ),
                      const SizedBox(height: 16),

                      _label("Telefon raqam"),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: context.inputColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.phone_outlined, color: context.textMuted, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              UserSession.phone.isNotEmpty ? UserSession.phone : '+998 -- --- -- --',
                              style: GoogleFonts.inter(fontSize: 15, color: context.textPrimary),
                            ),
                            const Spacer(),
                            Icon(Icons.lock_outline, color: context.textMuted, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text("Davom etish", style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w600, color: context.textMuted,
  ));

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: ctrl,
      style: GoogleFonts.inter(fontSize: 15, color: context.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: context.textMuted),
        prefixIcon: Icon(icon, color: context.textMuted),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}
