import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';
import 'package:yukgo_flutter/features/auth/widgets/step_indicator.dart';
import 'package:yukgo_flutter/features/auth/widgets/select_chip.dart';
import 'package:yukgo_flutter/features/yukchi/screens/yukchi_home_screen.dart';
import 'package:yukgo_flutter/core/services/location_service.dart';
import 'package:yukgo_flutter/core/services/notification_service.dart';

class YukchiSetupScreen extends StatefulWidget {
  const YukchiSetupScreen({super.key});

  @override
  State<YukchiSetupScreen> createState() => _YukchiSetupScreenState();
}

class _YukchiSetupScreenState extends State<YukchiSetupScreen> {
  String _cargoType = '';
  String _fromCity = '';
  final Set<String> _toRoutes = {};
  String _frequency = '';
  bool _loading = false;
  bool _detectingCity = true;

  @override
  void initState() {
    super.initState();
    _autoDetectCity();
  }

  Future<void> _autoDetectCity() async {
    final city = await LocationService.detectNearestCity();
    // Bildirishnoma ruxsatini ham so'rash
    await NotificationService.requestPermission();
    if (!mounted) return;
    setState(() {
      if (city != null) _fromCity = city;
      _detectingCity = false;
    });
  }

  static const _cargoTypes = [
    'Mebel', 'Oziq-ovqat', 'Qurilish materiallari',
    'Elektronika', 'Kiyim-kechak', 'Qishloq mahsulotlari',
    'Kimyo', 'Boshqa',
  ];
  static const _frequencies = [
    'Bir martalik', 'Haftada 1-2', 'Haftada 3+', 'Har kuni',
  ];
  static const _cities = [
    'Toshkent', 'Samarqand', 'Buxoro', 'Namangan', 'Andijon',
    'Farg\'ona', 'Qarshi', 'Nukus', 'Urganch', 'Termiz',
    'Jizzax', 'Sirdaryo', 'Navoiy', 'Guliston',
  ];

  Future<void> _finish() async {
    if (_cargoType.isEmpty || _fromCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Yuk turi va shaharni tanlang",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    UserSession.cargoType = _cargoType;
    UserSession.fromCity = _fromCity;
    UserSession.toRoutes = _toRoutes.toList();
    setState(() => _loading = true);
    try {
      await ApiService.setupProfile({
        'role': 'yukchi',
        'first_name': UserSession.firstName,
        'last_name': UserSession.lastName,
        'phone': UserSession.phone,
        'from_city': _fromCity,
        'to_routes': _toRoutes.toList(),
        'cargo_type': _cargoType,
      });
    } catch (_) {}
    UserSession.isLoggedIn = true;
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const YukchiHomeScreen()),
      (_) => false,
    );
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
                    const SizedBox(height: 24),
                    StepIndicator(current: 5, total: 5),
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

                    Row(children: [
                      const Text(“📦”, style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(“Yuk ma'lumotlari”, style: GoogleFonts.inter(
                          fontSize: 22, fontWeight: FontWeight.w800, color: context.textPrimary,
                        )),
                        Text(“Bir marta to'ldiring — keyingi buyurtmalarda tez bo'ladi”,
                          style: GoogleFonts.inter(fontSize: 12, color: context.textMuted, height: 1.4)),
                      ])),
                    ]),
                    const SizedBox(height: 32),

                    // Cargo type
                    _sectionTitle("Asosiy yuk turi"),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: _cargoTypes.map((t) =>
                      SelectChip(label: t, isSelected: _cargoType == t,
                        onTap: () => setState(() => _cargoType = t)),
                    ).toList()),
                    const SizedBox(height: 24),

                    // From city
                    Row(children: [
                      Expanded(child: _sectionTitle("Asosiy yuklash shahri")),
                      if (_detectingCity)
                        Row(children: [
                          SizedBox(width: 12, height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
                          const SizedBox(width: 6),
                          Text("Joylashuv...", style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primary)),
                        ])
                      else if (_fromCity.isNotEmpty)
                        Row(children: [
                          const Icon(Icons.my_location, size: 14, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Text("Avtomatik", style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primary)),
                        ]),
                    ]),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: _cities.map((c) =>
                      SelectChip(label: c, isSelected: _fromCity == c,
                        onTap: () => setState(() => _fromCity = c)),
                    ).toList()),
                    const SizedBox(height: 24),

                    // To cities
                    _sectionTitle("Qayerlarga yuborganmiz? (bir nechta)"),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: _cities.map((c) =>
                      SelectChip(
                        label: c, isSelected: _toRoutes.contains(c), multiSelect: true,
                        onTap: () => setState(() {
                          if (_toRoutes.contains(c)) _toRoutes.remove(c);
                          else _toRoutes.add(c);
                        }),
                      ),
                    ).toList()),
                    const SizedBox(height: 24),

                    // Frequency
                    _sectionTitle("Yuk yuborish chastotasi"),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: _frequencies.map((f) =>
                      SelectChip(label: f, isSelected: _frequency == f,
                        onTap: () => setState(() => _frequency = f)),
                    ).toList()),
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
                  onPressed: _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text("Ro'yxatdan o'tish вњ“", style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary,
  ));
}

