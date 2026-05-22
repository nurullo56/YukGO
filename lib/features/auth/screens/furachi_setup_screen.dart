import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';
import 'package:yukgo_flutter/features/auth/widgets/step_indicator.dart';
import 'package:yukgo_flutter/features/auth/widgets/select_chip.dart';
import 'package:yukgo_flutter/features/furachi/screens/furachi_home_screen.dart';

class FurachiSetupScreen extends StatefulWidget {
  const FurachiSetupScreen({super.key});

  @override
  State<FurachiSetupScreen> createState() => _FurachiSetupScreenState();
}

class _FurachiSetupScreenState extends State<FurachiSetupScreen> {
  String _truckType = 'GAZelle';
  String _capacity = '1.5 tonna';
  String _fromCity = '';
  final Set<String> _toRoutes = {};
  bool _loading = false;

  static const _trucks = ['GAZelle', 'Labo', 'Kamaz', 'Zil 130', 'MAN', 'Boshqa'];
  static const _capacities = ['0.5 tonna', '1 tonna', '1.5 tonna', '3 tonna', '5 tonna', '10+ tonna'];
  static const _cities = [
    'Toshkent', 'Samarqand', 'Buxoro', 'Namangan', 'Andijon',
    'Farg\'ona', 'Qarshi', 'Nukus', 'Urganch', 'Termiz',
    'Jizzax', 'Sirdaryo', 'Navoiy', 'Guliston',
  ];

  Future<void> _finish() async {
    if (_fromCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Qayerdan yo'lga chiqishingizni tanlang",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    UserSession.truckType = _truckType;
    UserSession.capacity = _capacity;
    UserSession.fromCity = _fromCity;
    UserSession.toRoutes = _toRoutes.toList();
    setState(() => _loading = true);
    try {
      await ApiService.setupProfile({
        'role': 'furachi',
        'first_name': UserSession.firstName,
        'last_name': UserSession.lastName,
        'phone': UserSession.phone,
        'truck_type': _truckType,
        'capacity': _capacity,
        'from_city': _fromCity,
        'to_routes': _toRoutes.toList(),
      });
    } catch (_) {}
    UserSession.isLoggedIn = true;
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const FurachiHomeScreen()),
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
                      Text("🚚", style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Transport ma'lumotlari", style: GoogleFonts.inter(
                          fontSize: 22, fontWeight: FontWeight.w800, color: context.textPrimary,
                        )),
                        Text("Bir marta to'ldiring — buyurtmalarda avtomatik ko'rinadi",
                          style: GoogleFonts.inter(fontSize: 12, color: context.textMuted, height: 1.4)),
                      ])),
                    ]),
                    const SizedBox(height: 32),

                    // Truck type
                    _sectionTitle("Mashina turi"),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: _trucks.map((t) =>
                      SelectChip(label: t, isSelected: _truckType == t,
                        onTap: () => setState(() => _truckType = t)),
                    ).toList()),
                    const SizedBox(height: 24),

                    // Capacity
                    _sectionTitle("Ko'tarish imkoni"),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: _capacities.map((c) =>
                      SelectChip(label: c, isSelected: _capacity == c,
                        onTap: () => setState(() => _capacity = c)),
                    ).toList()),
                    const SizedBox(height: 24),

                    // From city
                    _sectionTitle("Qayerdan (asosiy shahar)"),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: _cities.map((c) =>
                      SelectChip(label: c, isSelected: _fromCity == c,
                        onTap: () => setState(() => _fromCity = c)),
                    ).toList()),
                    const SizedBox(height: 24),

                    // To routes
                    _sectionTitle("Qayerlarga yurasiz? (bir nechta tanlang)"),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: _cities.map((c) =>
                      SelectChip(
                        label: c,
                        isSelected: _toRoutes.contains(c),
                        onTap: () => setState(() {
                          if (_toRoutes.contains(c)) { _toRoutes.remove(c); }
                          else { _toRoutes.add(c); }
                        }),
                        multiSelect: true,
                      ),
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
                      : Text("Ro'yxatdan o'tish ✓", style: GoogleFonts.inter(
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
