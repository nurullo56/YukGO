import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/widgets/app_bottom_nav.dart';

class ShipperChatScreen extends StatefulWidget {
  const ShipperChatScreen({super.key});

  @override
  State<ShipperChatScreen> createState() => _ShipperChatScreenState();
}

class _ShipperChatScreenState extends State<ShipperChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Chat History
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildAIMessage("Assalomu alaykum! Men sizga yukingizni joylashtirishda yordam beraman. Nima yubormoqchisiz va qayerga?", "9:41 AM"),
                _buildUserMessage("Toshkentdan Samarqandga 50 ta quti mebel yubormoqchiman. Ertaga ertalabga mashina kerak.", "9:42 AM"),
                _buildAIAnalysis("Ma'lumotlarni tahlil qilyapman..."),
              ],
            ),
          ),

          // Input Section
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // TUZATILDI: pb: 16 -> bottom: 16 ga o'zgartirildi
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(bottom: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Yukchi AI', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                  Row(
                    children: [
                      // TUZATILDI: Colors.emerald -> Colors.green (yoki maxsus hex kod) qilindi
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('AI ANALYSIS ACTIVE', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Color(0xFFEAF2FF), shape: BoxShape.circle),
            child: const Icon(Icons.history, color: AppTheme.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.smart_toy_outlined, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: GoogleFonts.inter(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(time, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(text, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(time, style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            // TUZATILDI: Tashqaridagi const olib tashlandi, chunki ichki qismlar dinamik yoki noto'g'ri joylashgandi
            decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.person, color: AppTheme.primary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysis(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: GoogleFonts.inter(fontSize: 14, fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildChip(Icons.location_on, "Samarqand"),
                  const SizedBox(width: 8),
                  _buildChip(Icons.local_shipping, "Katta yuk"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    // TUZATILDI: py: 6 -> vertical: 6 ga o'zgartirildi
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.primary.withOpacity(0.1))),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: context.cardColor, border: Border(top: BorderSide(color: context.borderColor))),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionChip("Toshkent", true),
                const SizedBox(width: 12),
                _buildActionChip("Yengil", false),
                const SizedBox(width: 12),
                _buildActionChip("Katta", false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: context.inputColor, borderRadius: BorderRadius.circular(16)),
                  child: const TextField(
                    decoration: InputDecoration(hintText: "Yuk tafsilotlarini yozing...", border: InputBorder.none, suffixIcon: Icon(Icons.attach_file)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10)]),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, bool isActive) {
    // TUZATILDI: py: 8 -> vertical: 8 ga o'zgartirildi
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: isActive ? const Color(0xFFEAF2FF) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12), border: isActive ? Border.all(color: AppTheme.primary.withOpacity(0.1)) : null),
      child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: isActive ? AppTheme.primary : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
    );
  }

}