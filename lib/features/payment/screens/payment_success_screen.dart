import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String method;
  final String amount;
  final String? last4;

  const PaymentSuccessScreen({
    super.key,
    required this.method,
    required this.amount,
    this.last4,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),

              // Animatsiyali check
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200, width: 3),
                  ),
                  child: Icon(Icons.check_rounded, size: 64, color: Colors.green.shade500),
                ),
              ),
              const SizedBox(height: 32),

              FadeTransition(
                opacity: _fade,
                child: Column(children: [
                  Text("To'lov muvaffaqiyatli!",
                      style: GoogleFonts.inter(
                          fontSize: 24, fontWeight: FontWeight.w800, color: context.textPrimary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text("${widget.method} orqali to'lov amalga oshirildi",
                      style: GoogleFonts.inter(fontSize: 14, color: context.textMuted),
                      textAlign: TextAlign.center),
                ]),
              ),
              const SizedBox(height: 40),

              // Chek kartochkasi
              FadeTransition(
                opacity: _fade,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(children: [
                    _row("To'lov tizimi", widget.method),
                    if (widget.amount != '0') ...[
                      const Divider(height: 24),
                      _row("Miqdor", "${widget.amount} so'm", bold: true),
                    ],
                    if (widget.last4 != null) ...[
                      const Divider(height: 24),
                      _row("Karta", "**** **** **** ${widget.last4}"),
                    ],
                    const Divider(height: 24),
                    _row("Holat", "Muvaffaqiyatli", color: Colors.green),
                    const Divider(height: 24),
                    _row("Sana", _formatDate()),
                  ]),
                ),
              ),

              const Spacer(),

              // Bosh sahifaga qaytish
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text("Bosh sahifaga",
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Orqaga",
                    style: GoogleFonts.inter(fontSize: 14, color: context.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: context.textMuted)),
        Text(value, style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          color: color ?? context.textPrimary,
        )),
      ],
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2,'0')}.${now.month.toString().padLeft(2,'0')}.${now.year} '
        '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';
  }
}
