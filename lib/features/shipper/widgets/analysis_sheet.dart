import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';

class ShipperAnalysisSheet extends StatelessWidget {
  const ShipperAnalysisSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle (Tepa chizig'i)
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ma'lumotlar tayyor!", 
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("AI barcha detallarni tahlil qildi", 
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Route
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("YO'NALISH", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text("Toshkent", style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 16, color: AppTheme.primary),
                                  const SizedBox(width: 8),
                                  const Text("Farg'ona", style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(12)),
                            child: const Text("340 km", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const Divider(height: 32, color: Color(0xFFF1F5F9)),

                      // Specs Grid
                      Row(
                        children: [
                          _buildSpecItem(Icons.fitness_center, "OG'IRLIK", "500 kg"),
                          const Spacer(),
                          _buildSpecItem(Icons.access_time_filled, "VAQT", "5-6 soat"),
                        ],
                      ),
                      const Divider(height: 32, color: Color(0xFFF1F5F9)),

                      // Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Taxminiy narx", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: "1,200,000 ", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black)),
                                    const TextSpan(text: "so'm", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primary.withOpacity(0.2))),
                            child: const Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ✅ TUZATILDI: platforma tekshiruvi olib tashlandi
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),  // ✅ To'g'ri
                    ),
                    elevation: 8,
                    shadowColor: AppTheme.primary.withOpacity(0.4),
                  ),
                  child: const Text("Haydovchi topish",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),  // ✅ To'g'ri
                    ),
                  ),
                  child: const Text("O'zgartirish kiritish", 
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.grey, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}