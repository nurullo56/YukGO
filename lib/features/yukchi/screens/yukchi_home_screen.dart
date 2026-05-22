import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';
import 'package:yukgo_flutter/core/widgets/app_bottom_nav.dart';
import 'package:yukgo_flutter/core/widgets/auth_guard.dart';

class YukchiHomeScreen extends StatefulWidget {
  const YukchiHomeScreen({super.key});

  @override
  State<YukchiHomeScreen> createState() => _YukchiHomeScreenState();
}

class _YukchiHomeScreenState extends State<YukchiHomeScreen> {
  String _selectedCity = 'Barchasi';
  String _searchQuery = '';
  List<Map<String, dynamic>> _drivers = [];
  bool _loading = true;
  String? _error;

  static const _cities = ['Barchasi', 'Toshkent', 'Samarqand', 'Buxoro', 'Namangan', 'Andijon', "Farg'ona"];

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getDrivers();
      setState(() {
        _drivers = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Furachlarni yuklashda xato'; _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _drivers.where((d) {
      final from = (d['from_city'] ?? '') as String;
      final routes = (d['to_routes'] ?? '') as String;
      final name = '${d['first_name'] ?? ''} ${d['last_name'] ?? ''}';
      final truck = (d['truck_type'] ?? '') as String;

      final matchCity = _selectedCity == 'Barchasi' ||
          from.contains(_selectedCity) ||
          routes.contains(_selectedCity);
      final matchSearch = _searchQuery.isEmpty ||
          name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          truck.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCity && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: AuthGuard(
        child: Column(
          children: [
            _buildHeader(context),
            _buildCityFilter(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(_error!, style: GoogleFonts.inter(color: context.textMuted)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _loadDrivers, child: const Text('Qayta urinish')),
      ]),
    );
    if (_filtered.isEmpty) return _buildEmpty(context);
    return RefreshIndicator(
      onRefresh: _loadDrivers,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => _DriverCard(data: _filtered[i]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 56, left: 24, right: 24, bottom: 16),
      color: context.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Salom, ${UserSession.firstName.isEmpty ? "Yukchi" : UserSession.firstName}! 👋',
                    style: GoogleFonts.inter(fontSize: 13, color: context.textMuted)),
                Text('Furachi toping', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: context.textPrimary)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF29CC78), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('${_drivers.length} furachi', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: context.inputColor, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(Icons.search, color: context.textMuted, size: 20),
              const SizedBox(width: 8),
              Expanded(child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.inter(fontSize: 14, color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: "Furachi ismi yoki mashina turi...",
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: context.textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              )),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCityFilter(BuildContext context) {
    return Container(
      color: context.cardColor,
      padding: const EdgeInsets.only(left: 20, bottom: 14, top: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: _cities.map((city) {
          final isActive = _selectedCity == city;
          return GestureDetector(
            onTap: () => setState(() => _selectedCity = city),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isActive ? null : Border.all(color: context.borderColor),
                boxShadow: isActive ? [BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))] : null,
              ),
              child: Text(city, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? Colors.white : context.textMuted)),
            ),
          );
        }).toList()),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.local_shipping_outlined, size: 64, color: context.textMuted),
      const SizedBox(height: 16),
      Text('Furachi topilmadi', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: context.textPrimary)),
      const SizedBox(height: 8),
      Text('Hozircha furachi ro\'yxatdan o\'tmagan', style: GoogleFonts.inter(fontSize: 14, color: context.textMuted)),
    ]));
  }
}

class _DriverCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DriverCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim();
    final truck = data['truck_type'] ?? 'Noma\'lum';
    final capacity = data['capacity'] ?? '';
    final fromCity = data['from_city'] ?? '';
    final routes = data['to_routes'] ?? '';
    final phone = data['phone'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name.isEmpty ? 'Furachi' : name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: context.textPrimary)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.local_shipping_outlined, size: 14, color: context.textMuted),
                const SizedBox(width: 4),
                Text('$truck${capacity.isNotEmpty ? "  •  $capacity" : ""}',
                    style: GoogleFonts.inter(fontSize: 13, color: context.textMuted)),
              ]),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFF29CC78).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text('Tayyor', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF29CC78))),
            ),
          ]),
          if (fromCity.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: context.inputColor, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.circle, size: 8, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(fromCity, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary)),
                if (routes.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 14, color: context.textMuted),
                  const SizedBox(width: 6),
                  Expanded(child: Text(routes.replaceAll('[', '').replaceAll(']', '').replaceAll('"', ''),
                      style: GoogleFonts.inter(fontSize: 13, color: context.textMuted), overflow: TextOverflow.ellipsis)),
                ],
              ]),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.phone_outlined, size: 16),
              label: Text(phone.isNotEmpty ? phone : "Bog'lanish",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
