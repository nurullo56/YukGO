import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/features/payment/screens/card_payment_screen.dart';
import 'package:yukgo_flutter/features/payment/screens/app_payment_screen.dart';

class PaymentMethodsSheet extends StatefulWidget {
  const PaymentMethodsSheet({super.key});

  @override
  State<PaymentMethodsSheet> createState() => _PaymentMethodsSheetState();
}

class _PaymentMethodsSheetState extends State<PaymentMethodsSheet> {
  String? _selected;

  static const _methods = [
    (id: 'payme',   name: 'Payme',      desc: "O'zbekiston to'lov tizimi",  asset: 'assets/images/payme_logo.png',   fb: 'P', color: Color(0xFF00C2C2)),
    (id: 'click',   name: 'Click',      desc: "Tez va qulay to'lov",         asset: 'assets/images/click_logo.png',   fb: 'C', color: Color(0xFF1A6BFF)),
    (id: 'uzum',    name: 'Uzum Bank',  desc: 'Raqamli bank xizmatlari',     asset: 'assets/images/uzum_logo.png',    fb: 'U', color: Color(0xFF6E30F0)),
    (id: 'humo',    name: 'Humo',       desc: "Milliy to'lov tizimi",        asset: 'assets/images/humo_logo.png',    fb: 'H', color: Color(0xFF2C4770)),
    (id: 'uzcard',  name: 'UzCard',     desc: "Milliy bank kartasi",         asset: 'assets/images/uzcard_logo.png',  fb: 'Z', color: Color(0xFF0057A8)),
    (id: 'visa',       name: 'Visa',       desc: "Xalqaro to'lov tizimi",    asset: 'assets/images/visa_logo.png',       fb: 'V', color: Color(0xFF1A1F71)),
    (id: 'mastercard', name: 'Mastercard', desc: "Xalqaro to'lov tizimi",    asset: 'assets/images/mastercard_logo.png', fb: 'M', color: Color(0xFFEB001B)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header — qotib turadi
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                )),
                const SizedBox(height: 20),
                Text("To'lov usullari", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: context.textPrimary)),
                Text("To'lov tizimini tanlang", style: GoogleFonts.inter(fontSize: 13, color: context.textMuted)),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Scroll bo'ladigan ro'yxat — max balandlik ekranning 55%
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: _methods.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PaymentCard(
                    isSelected: _selected == m.id,
                    onTap: () => setState(() => _selected = m.id),
                    logo: _Logo(asset: m.asset, fallback: m.fb, color: m.color),
                    name: m.name,
                    desc: m.desc,
                    color: m.color,
                  ),
                )).toList(),
              ),
            ),
          ),

          // Ulash tugmasi — doim pastda
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _selected == null ? null : () {
                  final m = _methods.firstWhere((x) => x.id == _selected);
                  Navigator.pop(context);
                  if (m.id == 'visa' || m.id == 'mastercard') {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => CardPaymentScreen(paymentType: m.id),
                    ));
                  } else {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AppPaymentScreen(
                        methodId: m.id,
                        methodName: m.name,
                        asset: m.asset,
                        color: m.color,
                      ),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  disabledBackgroundColor: context.inputColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text("Ulash", style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: _selected == null ? context.textMuted : Colors.white,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget logo;
  final String name;
  final String desc;
  final Color color;

  const _PaymentCard({
    required this.isSelected,
    required this.onTap,
    required this.logo,
    required this.name,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : context.inputColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: logo),
            ),
            const SizedBox(width: 14),
            // Info
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
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Check
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade400,
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

class _Logo extends StatelessWidget {
  final String asset;
  final String fallback;
  final Color color;
  const _Logo({required this.asset, required this.fallback, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        asset,
        width: 32, height: 32,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          width: 32, height: 32,
          color: color,
          child: Center(child: Text(fallback, style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16,
          ))),
        ),
      ),
    );
  }
}
