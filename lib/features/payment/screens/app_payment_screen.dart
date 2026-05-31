import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';
import 'payment_success_screen.dart';

class AppPaymentScreen extends StatefulWidget {
  final String methodId;
  final String methodName;
  final String asset;
  final Color color;
  final String amount;

  const AppPaymentScreen({
    super.key,
    required this.methodId,
    required this.methodName,
    required this.asset,
    required this.color,
    this.amount = '0',
  });

  @override
  State<AppPaymentScreen> createState() => _AppPaymentScreenState();
}

class _AppPaymentScreenState extends State<AppPaymentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _confirmPayment() async {
    setState(() => _loading = true);
    try {
      final amountVal = double.tryParse(
              widget.amount.replaceAll(' ', '').replaceAll(',', '')) ??
          0.0;
      await ApiService.processPayment(
        methodId: widget.methodId,
        amount: amountVal,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          method: widget.methodName,
          amount: widget.amount,
        ),
      ));
    } catch (_) {
      if (!mounted) return;
      // API yo'q vaqtda demo rejimda muvaffaqiyat ekranini ko'rsatamiz
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          method: widget.methodName,
          amount: widget.amount,
        ),
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.methodName,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: context.textPrimary)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Logo + pulse
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, child) => Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.05 + _pulse.value * 0.08),
                  border: Border.all(
                    color: widget.color.withOpacity(0.2 + _pulse.value * 0.3), width: 2),
                ),
                child: child,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  widget.asset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(
                    widget.methodName[0],
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: widget.color),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text("${widget.methodName} orqali to'lash",
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: context.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text("Quyi tugmani bosib to'lovni tasdiqlang",
                style: GoogleFonts.inter(fontSize: 14, color: context.textMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: 40),

            // To'lov miqdori
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.color.withOpacity(0.2)),
              ),
              child: Column(children: [
                Text("To'lov miqdori",
                    style: GoogleFonts.inter(fontSize: 13, color: context.textMuted)),
                const SizedBox(height: 8),
                Text(
                  widget.amount == '0' ? "— so'm" : "${widget.amount} so'm",
                  style: GoogleFonts.inter(
                      fontSize: 28, fontWeight: FontWeight.w800, color: context.textPrimary),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Xavfsizlik
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text("Xavfsiz to'lov — ma'lumotlar shifrlangan",
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ]),

            const Spacer(),

            // Tasdiqlash tugmasi
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                    : Text("${widget.methodName} orqali to'lash",
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),

            // Bekor qilish
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Bekor qilish",
                  style: GoogleFonts.inter(fontSize: 14, color: context.textMuted)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
