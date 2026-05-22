import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverHeader(context),
              SliverToBoxAdapter(
                child: _buildProfileBody(context),
              ),
            ],
          ),
          _buildStickyButton(),
        ],
      ),
    );
  }

  // Tep qismidagi rasm va gradient
  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              "https://yukchi.uz/api/image-search?query=truck+driver+portrait&w=600&h=800&seed=88",
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    const Color(0xFFF7FAFF).withOpacity(0.8),
                    const Color(0xFFF7FAFF),
                  ],
                ),
              ),
            ),
            // Header Actions
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _headerCircleBtn(Icons.chevron_left, () => Navigator.pop(context)),
                  _headerCircleBtn(Icons.share_outlined, () {}),
                ],
              ),
            ),
            // Driver Info on Image
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text("356 ta yuk yetkazilgan", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Jasur Karimov", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black)),
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 16),
                      SizedBox(width: 4),
                      Text("Toshkent, O'zbekiston", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCircleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.3))),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  // Profil asosiy qismi
  Widget _buildProfileBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          Row(
            children: [
              _statItem(context, Icons.star, "4.9", "Reyting", color: Colors.amber),
              const SizedBox(width: 12),
              _statItem(context, null, "6 yil", "Tajriba"),
              const SizedBox(width: 12),
              _statItem(context, Icons.local_shipping, "GAZelle", "3 tonna", color: AppTheme.primary),
            ],
          ),
          const SizedBox(height: 32),
          Text("Haydovchi haqida", style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 8),
          const Text(
            "Professional haydovchiman, yuklarni o'z vaqtida va butun holda yetkazish kafolatlanadi. Avtomobilim sanitar qoidalarga to'liq javob beradi.",
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sharhlar (42)", style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 18)),
              const Text("Barchasi", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _reviewCard(context, "Xurshid B.", "Kecha, 18:45", "Juda mas'uliyatli haydovchi. Rahmat!", 5),
          _reviewCard(context, "Malika Olimova", "3 kun avval", "Muomala zo'r, mashina toza.", 4),
          const SizedBox(height: 120), // Button uchun joy
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, IconData? icon, String val, String label, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: context.borderColor)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) Icon(icon, color: color, size: 16),
                if (icon != null) const SizedBox(width: 4),
                Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _reviewCard(BuildContext context, String name, String date, String comment, int stars) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: context.borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(children: List.generate(5, (i) => Icon(Icons.star, size: 12, color: i < stars ? Colors.amber : Colors.grey[300]))),
            ],
          ),
          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 8),
          Text(comment, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildStickyButton() {
    return Positioned(
      bottom: 24, left: 24, right: 24,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Tanlash va davom etish", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}