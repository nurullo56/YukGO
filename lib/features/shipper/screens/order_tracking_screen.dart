import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/widgets/app_bottom_nav.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMapSection(),
                  _buildTrackingDetails(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header (Faol buyurtma va ID)
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      color: context.cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: context.inputColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.chevron_left, color: context.textPrimary),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Faol buyurtma", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text("#YK-88219", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(12)),
            child: const Text("Yo'lda", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // Xarita qismi (Imitatsiya)
  Widget _buildMapSection() {
    return Container(
      height: 320,
      width: double.infinity,
      color: Colors.grey[300],
      child: Stack(
        children: [
          // Xarita rasmi (Placeholder)
          Image.network(
            "https://yukchi.app/api/image-search?query=city-map-navigation&w=800&h=600&seed=42",
            fit: BoxFit.cover, 
            width: double.infinity, 
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Xarita yuklanmoqda...", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
          // Haydovchi belgisi
          const Positioned(
            top: 120, left: 140,
            child: Icon(Icons.local_shipping, color: AppTheme.primary, size: 40),
          ),
          // Manzil pin
          const Positioned(
            top: 200, right: 100,
            child: Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        ],
      ),
    );
  }

  // Haydovchi kartasi va Timeline
  Widget _buildTrackingDetails(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  // Haydovchi info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              "https://i.pravatar.cc/150?u=driver1",
                              width: 56, 
                              height: 56,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.person, color: AppTheme.primary),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Jasur Karimov", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                              const Text("GAZelle Next • 01 A 777 AA", style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.phone, color: Colors.white),
                      ),
                    ],
                  ),
                  Divider(height: 40, color: context.divColor),
                  // Vertical Timeline
                  _buildTimelineItem("Buyurtma qabul qilindi", "10:20 • Toshkent", true, true),
                  _buildTimelineItem("Yuk olingan", "11:45 • Ombor №4", true, true),
                  _buildTimelineItem("Yetkazilmoqda", "Hozirgi joy: Sirdaryo", false, true, isActive: true),
                  _buildTimelineItem("Yetkazildi", "Kutilmoqda: Samarqand", false, false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: context.cardColor,
                foregroundColor: context.textPrimary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), 
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                elevation: 0,
              ),
              child: const Text("Tafsilotlarni ko'rish", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, bool isDone, bool hasLine, {bool isActive = false}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: isDone ? AppTheme.primary : (isActive ? Colors.white : Colors.grey[200]),
                  shape: BoxShape.circle,
                  border: isActive ? Border.all(color: AppTheme.primary, width: 2) : null,
                ),
                child: isDone 
                  ? const Icon(Icons.check, size: 14, color: Colors.white) 
                  : (isActive 
                      ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle))) 
                      : null),
              ),
              if (hasLine) 
                Expanded(
                  child: Container(
                    width: 2, 
                    color: isDone ? AppTheme.primary : Colors.grey[200],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: isActive ? AppTheme.primary : Colors.black, 
                    fontSize: 14,
                  ),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

}