import 'package:flutter/material.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/token_storage.dart';
import 'package:yukgo_flutter/core/widgets/app_bottom_nav.dart';
import 'package:yukgo_flutter/features/profile/widgets/payment_methods_sheet.dart';
import 'package:yukgo_flutter/features/profile/widgets/language_sheet.dart';
import 'package:yukgo_flutter/features/profile/widgets/notifications_sheet.dart';
import 'package:yukgo_flutter/features/profile/screens/edit_profile_screen.dart';
import 'package:yukgo_flutter/features/onboarding/screens/onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool get isDarkMode => UserSession.darkMode.value;

  Color get bgColor => isDarkMode ? const Color(0xFF0A0E1A) : AppTheme.background;
  Color get cardColor => isDarkMode ? const Color(0xFF151B2E) : Colors.white;
  Color get textPrimary => isDarkMode ? Colors.white : Colors.black;
  Color get textSecondary => isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
  Color get iconColor => AppTheme.primary;

  @override
  void initState() {
    super.initState();
    UserSession.darkMode.addListener(_onThemeChange);
    UserSession.notifications.addListener(_onNotifChange);
  }

  @override
  void dispose() {
    UserSession.darkMode.removeListener(_onThemeChange);
    UserSession.notifications.removeListener(_onNotifChange);
    super.dispose();
  }

  void _onThemeChange() => setState(() {});
  void _onNotifChange() => setState(() {});

  void _startVerification(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.verified_user_outlined, color: AppTheme.primary),
          const SizedBox(width: 10),
          const Text('Verifikatsiya'),
        ]),
        content: const Text(
          "Hisobingizni verifikatsiyadan o'tkazish uchun shaxsingizni tasdiqlovchi hujjat (Passport/ID) rasmini yuklashingiz kerak.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Hujjat yuklash tizimi tez orada ishga tushadi!"),
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Boshlash'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chiqish'),
        content: const Text('Hisobdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Chiqish', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await TokenStorage.clear();
    UserSession.isLoggedIn = false;
    UserSession.userId = 0;
    UserSession.role = 'yukchi';
    UserSession.firstName = '';
    UserSession.lastName = '';
    UserSession.phone = '';
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDarkMode ? const Color(0xFF1A1F3A) : AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode 
                        ? [const Color(0xFF1A1F3A), const Color(0xFF0A0E27)]
                        : [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      child: Icon(Icons.person, size: 50, color: iconColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${UserSession.firstName} ${UserSession.lastName}'.trim().isEmpty
                          ? 'Foydalanuvchi'
                          : '${UserSession.firstName} ${UserSession.lastName}'.trim(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      UserSession.phone.isEmpty ? '+998 -- --- -- --' : UserSession.phone,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        UserSession.isYukchi ? 'Yukchi' : 'Furachi',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Settings List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SettingsSection(
                    title: 'Akkaunt',
                    isDarkMode: isDarkMode,
                    cardColor: cardColor,
                    textSecondary: textSecondary,
                    iconColor: iconColor,
                    textPrimary: textPrimary,
                    items: [
                      _SettingsItem(Icons.person_outline, 'Shaxsiy ma\'lumotlar', () async {
                          await Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ));
                          if (mounted) setState(() {});
                        },
                          iconColor: iconColor, textColor: textPrimary),
                      _SettingsItem(Icons.verified_user_outlined, 'Verifikatsiya', () => _startVerification(context),
                          iconColor: iconColor, textColor: textPrimary),
                      _SettingsItem(Icons.credit_card, 'To\'lov usullari', () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const PaymentMethodsSheet(),
                          );
                        },
                          iconColor: iconColor, textColor: textPrimary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sozlamalar section - inline build to avoid wrapper issues
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 12),
                        child: Text('Sozlamalar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textSecondary)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: isDarkMode ? Border.all(color: Colors.grey.shade800) : null,
                        ),
                        child: Column(
                          children: [
                            // Bildirishnomalar — custom Row (ListTile ishlatilmaydi)
                            InkWell(
                              onTap: () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const NotificationsSheet(),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Icon(Icons.notifications_outlined, color: iconColor, size: 24),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text('Bildirishnomalar',
                                          style: TextStyle(color: textPrimary, fontSize: 16)),
                                    ),
                                    Switch(
                                      value: UserSession.notifications.value,
                                      onChanged: (v) {
                                        UserSession.notifications.value = v;
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => const NotificationsSheet(),
                                        );
                                      },
                                      activeColor: AppTheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Til
                            ValueListenableBuilder<String>(
                              valueListenable: UserSession.language,
                              builder: (context, lang, _) {
                                final flags = {'uz': 'UZ', 'ru': 'RU', 'en': 'EN'};
                                return _SettingsItem(
                                  Icons.language,
                                  'Til  ${flags[lang]}',
                                  () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => const LanguageSheet(),
                                  ),
                                  iconColor: iconColor,
                                  textColor: textPrimary,
                                );
                              },
                            ),
                            // Tungi rejim
                            SwitchListTile(
                              secondary: Icon(
                                isDarkMode ? Icons.light_mode : Icons.dark_mode_outlined,
                                color: isDarkMode ? Colors.amber : iconColor,
                              ),
                              title: Text('Tungi rejim', style: TextStyle(color: textPrimary)),
                              value: isDarkMode,
                              onChanged: (v) => UserSession.darkMode.value = v,
                              activeColor: AppTheme.primary,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: 'Yordam',
                    isDarkMode: isDarkMode,
                    cardColor: cardColor,
                    textSecondary: textSecondary,
                    iconColor: iconColor,
                    textPrimary: textPrimary,
                    items: [
                      _SettingsItem(Icons.help_outline, 'Yordam markazi', () {}, 
                          iconColor: iconColor, textColor: textPrimary),
                      _SettingsItem(Icons.description_outlined, 'Foydalanish shartlari', () {}, 
                          iconColor: iconColor, textColor: textPrimary),
                      _SettingsItem(Icons.privacy_tip_outlined, 'Maxfiylik', () {}, 
                          iconColor: iconColor, textColor: textPrimary),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Chiqish', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade200),
                      backgroundColor: isDarkMode ? Colors.red.withOpacity(0.1) : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Versiya 1.0.0',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final bool isDarkMode;
  final Color cardColor;
  final Color textSecondary;
  final Color iconColor;
  final Color textPrimary;

  const _SettingsSection({
    required this.title,
    required this.items,
    required this.isDarkMode,
    required this.cardColor,
    required this.textSecondary,
    required this.iconColor,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isDarkMode 
                ? Border.all(color: Colors.grey.shade800, width: 1)
                : null,
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;
  final Widget? trailing;

  const _SettingsItem(
    this.icon,
    this.title,
    this.onTap, {
    required this.iconColor,
    required this.textColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}