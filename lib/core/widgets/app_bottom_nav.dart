import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/widgets/add_cargo_sheet.dart';
import 'package:yukgo_flutter/core/widgets/add_announcement_sheet.dart';

class AppBottomNav extends StatelessWidget {
  /// 0=Asosiy, 1=Buyurtmalar, 3=Haydovchilar/Chat, 4=Profil
  /// -1 = hech biri faol emas
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    final isYukchi = UserSession.isYukchi;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(
            context, isYukchi ? '/ai-chat' : '/furachi-home');
      case 1:
        Navigator.pushReplacementNamed(context, '/order-tracking');
      case 3:
        Navigator.pushReplacementNamed(
            context, isYukchi ? '/driver-list' : '/shipper-chat');
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  void _onPlus(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserSession.isYukchi
          ? const AddCargoSheet()
          : const AddAnnouncementSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isYukchi = UserSession.isYukchi;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(context, 0, Icons.home_rounded, 'Asosiy'),
          _item(context, 1, Icons.assignment_outlined, 'Buyurtmalar'),

          // Markaziy + tugma
          GestureDetector(
            onTap: () => _onPlus(context),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),

          _item(
            context,
            3,
            isYukchi
                ? Icons.local_shipping_outlined
                : Icons.chat_bubble_outline_rounded,
            isYukchi ? 'Haydovchilar' : 'Chat',
          ),
          _item(context, 4, Icons.person_outline_rounded, 'Profil'),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, int index, IconData icon, String label) {
    final bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => _navigate(context, index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 24, color: isActive ? AppTheme.primary : Colors.grey),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppTheme.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
