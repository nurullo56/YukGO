import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';
import 'package:yukgo_flutter/core/widgets/app_bottom_nav.dart';
import 'package:yukgo_flutter/core/widgets/auth_guard.dart';

class FurachiHomeScreen extends StatefulWidget {
  const FurachiHomeScreen({super.key});

  @override
  State<FurachiHomeScreen> createState() => _FurachiHomeScreenState();
}

class _FurachiHomeScreenState extends State<FurachiHomeScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedFilter = 'Barchasi';

  static const _filters = ['Barchasi', 'Yaqin', 'Katta yuk', 'Shoshilinch'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getOrders();
      setState(() {
        _orders = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Yuklar ro\'yxatini yuklashda xato'; _loading = false; });
    }
  }

  Future<void> _acceptOrder(int orderId) async {
    try {
      await ApiService.acceptOrder(orderId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Buyurtma qabul qilindi!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF29CC78),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Xato yuz berdi', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _orders.where((o) {
      if (_searchQuery.isEmpty) return true;
      final from = (o['from_city'] ?? '').toString().toLowerCase();
      final to = (o['to_city'] ?? '').toString().toLowerCase();
      final type = (o['cargo_type'] ?? '').toString().toLowerCase();
      return from.contains(_searchQuery.toLowerCase()) ||
          to.contains(_searchQuery.toLowerCase()) ||
          type.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: AuthGuard(child: Column(children: [
        _buildHeader(context),
        _buildFilters(context),
        Expanded(child: _buildBody(context)),
      ])),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(_error!, style: GoogleFonts.inter(color: context.textMuted)),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: _loadOrders, child: const Text('Qayta urinish')),
    ]));
    if (_filtered.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inventory_2_outlined, size: 64, color: context.textMuted),
      const SizedBox(height: 16),
      Text('Yuk topilmadi', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: context.textPrimary)),
      const SizedBox(height: 8),
      Text('Hozircha ochiq buyurtma yo\'q', style: GoogleFonts.inter(fontSize: 14, color: context.textMuted)),
    ]));
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => _CargoCard(data: _filtered[i], onAccept: () => _acceptOrder(_filtered[i]['id'])),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 56, left: 24, right: 24, bottom: 16),
      color: context.cardColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Salom, ${UserSession.firstName.isEmpty ? "Furachi" : UserSession.firstName}! 👋',
                style: GoogleFonts.inter(fontSize: 13, color: context.textMuted)),
            Text('Mavjud yuklar', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: context.textPrimary)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF29CC78), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('${_orders.length} yuk', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
            ]),
          ),
        ]),
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
                hintText: "Shahar yoki yuk turini qidiring...",
                hintStyle: GoogleFonts.inter(fontSize: 14, color: context.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      color: context.cardColor,
      padding: const EdgeInsets.only(left: 20, bottom: 14, top: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: _filters.map((f) {
          final isActive = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isActive ? null : Border.all(color: context.borderColor),
                boxShadow: isActive ? [BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))] : null,
              ),
              child: Text(f, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? Colors.white : context.textMuted)),
            ),
          );
        }).toList()),
      ),
    );
  }
}

class _CargoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onAccept;
  const _CargoCard({required this.data, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final from = data['from_city'] ?? '';
    final to = data['to_city'] ?? '';
    final type = data['cargo_type'] ?? '';
    final weight = data['weight_kg'] ?? '';
    final price = data['price'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(type, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: context.textPrimary)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.circle, size: 8, color: AppTheme.primary),
              const SizedBox(width: 4),
              Text(from, style: GoogleFonts.inter(fontSize: 13, color: context.textMuted)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 12, color: context.textMuted),
              const SizedBox(width: 4),
              const Icon(Icons.location_on, size: 12, color: Colors.red),
              const SizedBox(width: 2),
              Text(to, style: GoogleFonts.inter(fontSize: 13, color: context.textMuted)),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (price.isNotEmpty) Text('$price so\'m', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primary)),
            if (weight.isNotEmpty) Text(weight, style: GoogleFonts.inter(fontSize: 12, color: context.textMuted)),
          ]),
        ]),
        Divider(height: 20, color: context.divColor),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Icon(Icons.access_time, size: 14, color: context.textMuted),
            const SizedBox(width: 4),
            Text('Yangi', style: GoogleFonts.inter(fontSize: 12, color: context.textMuted)),
          ]),
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Olish', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ]),
      ]),
    );
  }
}
