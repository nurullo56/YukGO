import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';
import 'package:yukgo_flutter/core/services/token_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _fromCityCtrl;
  late final TextEditingController _truckTypeCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _cargoTypeCtrl;

  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: UserSession.firstName);
    _lastNameCtrl = TextEditingController(text: UserSession.lastName);
    final phone = UserSession.phone.replaceAll('+998', '');
    _phoneCtrl = TextEditingController(text: phone);
    _fromCityCtrl = TextEditingController(text: UserSession.fromCity);
    _truckTypeCtrl = TextEditingController(text: UserSession.truckType);
    _capacityCtrl = TextEditingController(text: UserSession.capacity);
    _cargoTypeCtrl = TextEditingController(text: UserSession.cargoType);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _fromCityCtrl.dispose();
    _truckTypeCtrl.dispose();
    _capacityCtrl.dispose();
    _cargoTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final data = <String, dynamic>{
        'role': UserSession.role,
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'phone': '+998${_phoneCtrl.text.replaceAll(' ', '')}',
        'from_city': _fromCityCtrl.text.trim(),
      };

      if (UserSession.isFurachi) {
        data['truck_type'] = _truckTypeCtrl.text.trim();
        data['capacity'] = _capacityCtrl.text.trim();
      } else {
        data['cargo_type'] = _cargoTypeCtrl.text.trim();
      }

      await ApiService.setupProfile(data);

      UserSession.firstName = _firstNameCtrl.text.trim();
      UserSession.lastName = _lastNameCtrl.text.trim();
      UserSession.phone = '+998${_phoneCtrl.text.replaceAll(' ', '')}';
      UserSession.fromCity = _fromCityCtrl.text.trim();
      if (UserSession.isFurachi) {
        UserSession.truckType = _truckTypeCtrl.text.trim();
        UserSession.capacity = _capacityCtrl.text.trim();
      } else {
        UserSession.cargoType = _cargoTypeCtrl.text.trim();
      }

      await TokenStorage.saveUserProfile(
        firstName: UserSession.firstName,
        lastName: UserSession.lastName,
        phone: UserSession.phone,
        fromCity: UserSession.fromCity,
        truckType: UserSession.truckType,
        capacity: UserSession.capacity,
        cargoType: UserSession.cargoType,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Saqlandi!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF29CC78),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Xato yuz berdi', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Shaxsiy ma\'lumotlar',
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: context.textPrimary)),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Saqlash', style: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: Text(
                        UserSession.firstName.isEmpty ? '?' : UserSession.firstName[0].toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 38, fontWeight: FontWeight.w700, color: AppTheme.primary),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _section('Asosiy ma\'lumotlar'),
              const SizedBox(height: 12),
              _field(label: 'Ism', ctrl: _firstNameCtrl, hint: 'Sardor', icon: Icons.person_outline,
                  validator: (v) => v!.trim().isEmpty ? 'Ismni kiriting' : null),
              const SizedBox(height: 12),
              _field(label: 'Familya', ctrl: _lastNameCtrl, hint: 'Karimov', icon: Icons.badge_outlined),
              const SizedBox(height: 12),
              _phoneField(),
              const SizedBox(height: 12),
              _field(label: 'Asosiy shahar', ctrl: _fromCityCtrl, hint: 'Toshkent', icon: Icons.location_city_outlined),

              if (UserSession.isFurachi) ...[
                const SizedBox(height: 24),
                _section('Transport ma\'lumotlari'),
                const SizedBox(height: 12),
                _field(label: 'Mashina turi', ctrl: _truckTypeCtrl, hint: 'Kamaz, GAZelle...', icon: Icons.local_shipping_outlined),
                const SizedBox(height: 12),
                _field(label: 'Ko\'tarish imkoni', ctrl: _capacityCtrl, hint: '5 tonna', icon: Icons.fitness_center_outlined),
              ],

              if (UserSession.isYukchi) ...[
                const SizedBox(height: 24),
                _section('Yuk ma\'lumotlari'),
                const SizedBox(height: 12),
                _field(label: 'Asosiy yuk turi', ctrl: _cargoTypeCtrl, hint: 'Mebel, oziq-ovqat...', icon: Icons.inventory_2_outlined),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text('Saqlash', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Text(title,
      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: context.textMuted));

  Widget _phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Telefon', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: context.textMuted)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
          style: GoogleFonts.inter(fontSize: 15, color: context.textPrimary),
          decoration: InputDecoration(
            hintText: '90 123 45 67',
            hintStyle: GoogleFonts.inter(color: context.textMuted),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Text('+998', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: context.textPrimary)),
            ),
            filled: true, fillColor: context.inputColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _field({required String label, required TextEditingController ctrl, required String hint,
      required IconData icon, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: context.textMuted)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 15, color: context.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: context.textMuted),
            prefixIcon: Icon(icon, color: context.textMuted, size: 20),
            filled: true, fillColor: context.inputColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
