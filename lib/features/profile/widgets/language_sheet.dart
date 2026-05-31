import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';

class LanguageSheet extends StatefulWidget {
  const LanguageSheet({super.key});

  @override
  State<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  String _selected = UserSession.language.value;

  static const _languages = [
    {'code': 'uz', 'flag': 'UZ', 'name': "O'zbek", 'native': "O'zbek tili"},
    {'code': 'ru', 'flag': 'RU', 'name': 'Rus', 'native': 'Русский язык'},
    {'code': 'en', 'flag': 'EN', 'name': 'English', 'native': 'English language'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Tilni tanlang',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          Text(
            'Выберите язык / Choose language',
            style: GoogleFonts.inter(fontSize: 13, color: context.textMuted),
          ),
          const SizedBox(height: 20),

          ..._languages.map((lang) => _LangCard(
            flag: lang['flag']!,
            name: lang['name']!,
            native: lang['native']!,
            isSelected: _selected == lang['code'],
            onTap: () => setState(() => _selected = lang['code']!),
          )),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                UserSession.language.value = _selected;
                Navigator.pop(context);
                final name = _languages
                    .firstWhere((l) => l['code'] == _selected)['name']!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$name tili tanlandi',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: AppTheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Saqlash',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangCard extends StatelessWidget {
  final String flag;
  final String name;
  final String native;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangCard({
    required this.flag,
    required this.name,
    required this.native,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.08)
              : context.inputColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Til kodi (flag emoji o'rniga — encoding muammo yo'q)
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(flag, style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primary,
              )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    native,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
