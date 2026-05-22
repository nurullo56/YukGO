import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/widgets/app_bottom_nav.dart';
import 'package:yukgo_flutter/core/widgets/auth_guard.dart';

class FurachiHomeScreen extends StatelessWidget {
  const FurachiHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: AuthGuard(child: Column(
        children: [
          _buildHeader(context),
          _buildFilters(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: 5,
              itemBuilder: (context, index) => _CargoCard(index: index),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      color: context.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mavjud yuklar',
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '12 ta yuk sizni kutmoqda',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.notifications_outlined, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.inputColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Shahar yoki yo'nalish qidiring...",
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final filters = ['Barchasi', 'Yaqin', 'Katta yuk', 'Kichik yuk', 'Shoshilinch'];
    return Container(
      color: context.cardColor,
      padding: const EdgeInsets.only(left: 24, bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.asMap().entries.map((e) {
            final isActive = e.key == 0;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : context.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: isActive ? null : Border.all(color: Colors.grey.shade200),
                boxShadow: isActive
                    ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Text(
                e.value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CargoCard extends StatelessWidget {
  final int index;
  const _CargoCard({required this.index});

  static const _data = [
    {'from': 'Toshkent', 'to': 'Samarqand', 'type': 'Mebel', 'weight': '450 kg', 'price': '250 000', 'urgent': true},
    {'from': 'Namangan', 'to': 'Toshkent', 'type': 'Oziq-ovqat', 'weight': '800 kg', 'price': '180 000', 'urgent': false},
    {'from': 'Buxoro', 'to': 'Qarshi', 'type': 'Qurilish', 'weight': '2 tonna', 'price': '400 000', 'urgent': false},
    {'from': 'Toshkent', 'to': 'Andijon', 'type': 'Elektronika', 'weight': '120 kg', 'price': '350 000', 'urgent': true},
    {'from': 'Samarqand', 'to': 'Navoiy', 'type': 'Boshqa', 'weight': '300 kg', 'price': '150 000', 'urgent': false},
  ];

  @override
  Widget build(BuildContext context) {
    final d = _data[index % _data.length];
    final isUrgent = d['urgent'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isUrgent ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1.5) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(d['type']! as String, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                        if (isUrgent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Shoshilinch', style: GoogleFonts.inter(fontSize: 10, color: Colors.orange.shade700, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(d['from']! as String, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Icon(Icons.location_on, size: 12, color: Colors.red),
                        const SizedBox(width: 2),
                        Text(d['to']! as String, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${d['price']!} so\'m',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primary),
                  ),
                  Text(d['weight']! as String, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          Divider(height: 20, color: context.divColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Bugun, 14:30', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                ],
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/order-detail'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Olish', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
