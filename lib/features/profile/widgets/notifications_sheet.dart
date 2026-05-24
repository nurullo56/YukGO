import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/notification_service.dart';

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  bool _appEnabled = UserSession.notifications.value;
  bool _permissionGranted = false;
  Map<String, bool> _cats = {'orders': true, 'promo': true, 'system': true};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final granted = await NotificationService.hasPermission();
    final cats = await NotificationService.getCategories();
    if (!mounted) return;
    setState(() {
      _permissionGranted = granted;
      _cats = cats;
    });
  }

  Future<void> _toggleMain(bool value) async {
    if (value && !_permissionGranted) {
      final granted = await NotificationService.requestPermission();
      if (!mounted) return;
      setState(() => _permissionGranted = granted);
      if (!granted) {
        _showSettingsHint();
        return;
      }
    }
    await NotificationService.setEnabled(value);
    UserSession.notifications.value = value;
    if (mounted) setState(() => _appEnabled = value);
  }

  Future<void> _toggleCat(String key, bool value) async {
    await NotificationService.setCategory(key, value);
    if (mounted) setState(() => _cats[key] = value);
  }

  void _showSettingsHint() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Sozlamalardan ruxsat bering",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      action: SnackBarAction(label: "Sozlamalar", onPressed: openAppSettings),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = UserSession.darkMode.value;
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
          )),
          const SizedBox(height: 20),

          Text("Bildirishnomalar",
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: context.textPrimary)),
          Text("Qaysi bildirishnomalarni olishni sozlang",
              style: GoogleFonts.inter(fontSize: 13, color: context.textMuted)),
          const SizedBox(height: 20),

          // Ruxsat yo'q banner
          if (!_permissionGranted)
            GestureDetector(
              onTap: () => _toggleMain(true),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    "Bildirishnomalar uchun ruxsat berilmagan. Ruxsat berish uchun bosing.",
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.w600),
                  )),
                ]),
              ),
            ),

          // Asosiy toggle
          _card(isDark, child: Row(children: [
            _iconBox(Icons.notifications, AppTheme.primary),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Barcha bildirishnomalar",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: context.textPrimary)),
              Text("Yoqing yoki o'chiring",
                  style: GoogleFonts.inter(fontSize: 12, color: context.textMuted)),
            ])),
            Switch(value: _appEnabled, onChanged: _toggleMain, activeColor: AppTheme.primary),
          ])),

          // Kategoriyalar
          if (_appEnabled && _permissionGranted) ...[
            const SizedBox(height: 16),
            Text("Kategoriyalar",
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: context.textMuted)),
            const SizedBox(height: 8),
            _card(isDark, child: Column(children: [
              _catTile('orders', Icons.local_shipping_outlined,
                  "Buyurtmalar", "Yangi buyurtma va o'zgarishlar", Colors.green),
              Divider(height: 16, color: Colors.grey.shade200),
              _catTile('promo', Icons.campaign_outlined,
                  "Aksiyalar", "Chegirmalar va maxsus takliflar", Colors.orange),
              Divider(height: 16, color: Colors.grey.shade200),
              _catTile('system', Icons.info_outline,
                  "Tizim", "Hisob va xavfsizlik xabarlari", Colors.blue),
            ])),
          ],
        ],
      ),
    );
  }

  Widget _catTile(String key, IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: context.textPrimary, fontSize: 14)),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: context.textMuted)),
        ])),
        Switch(value: _cats[key] ?? true, onChanged: (v) => _toggleCat(key, v), activeColor: AppTheme.primary),
      ]),
    );
  }

  Widget _card(bool isDark, {required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1A2035) : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(20),
      border: isDark ? Border.all(color: Colors.grey.shade800) : null,
    ),
    child: child,
  );

  Widget _iconBox(IconData icon, Color color) => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
    child: Icon(icon, color: color),
  );
}
