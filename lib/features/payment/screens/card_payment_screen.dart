import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'payment_success_screen.dart';

class CardPaymentScreen extends StatefulWidget {
  final String paymentType; // 'visa' | 'mastercard'
  final String amount;
  const CardPaymentScreen({super.key, required this.paymentType, this.amount = '0'});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _cardCtrl   = TextEditingController();
  final _nameCtrl   = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl    = TextEditingController();
  final _cvvNode    = FocusNode();
  bool _showBack = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _cvvNode.addListener(() => setState(() => _showBack = _cvvNode.hasFocus));
  }

  @override
  void dispose() {
    _cardCtrl.dispose(); _nameCtrl.dispose();
    _expiryCtrl.dispose(); _cvvCtrl.dispose(); _cvvNode.dispose();
    super.dispose();
  }

  String get _displayCard {
    final raw = _cardCtrl.text.replaceAll(' ', '');
    final padded = raw.padRight(16, '•');
    return '${padded.substring(0,4)} ${padded.substring(4,8)} ${padded.substring(8,12)} ${padded.substring(12,16)}';
  }

  bool get _isVisa => widget.paymentType == 'visa';

  void _pay() async {
    if (_cardCtrl.text.replaceAll(' ', '').length < 16 ||
        _expiryCtrl.text.length < 5 || _cvvCtrl.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Barcha maydonlarni to'ldiring",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => PaymentSuccessScreen(
        method: _isVisa ? 'Visa' : 'Mastercard',
        amount: widget.amount,
        last4: _cardCtrl.text.replaceAll(' ', '').substring(12),
      ),
    ));
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
        title: Text(_isVisa ? 'Visa karta' : 'Mastercard',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: context.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Karta vizual
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _showBack ? _CardBack(cvv: _cvvCtrl.text, isVisa: _isVisa) : _CardFront(
                number: _displayCard,
                name: _nameCtrl.text.isEmpty ? 'ISM FAMILIYA' : _nameCtrl.text.toUpperCase(),
                expiry: _expiryCtrl.text.isEmpty ? 'MM/YY' : _expiryCtrl.text,
                isVisa: _isVisa,
              ),
            ),
            const SizedBox(height: 32),

            // Karta raqami
            _field(
              label: 'Karta raqami',
              ctrl: _cardCtrl,
              hint: '0000 0000 0000 0000',
              keyboard: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CardNumberFormatter(),
              ],
              maxLength: 19,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Ism
            _field(
              label: 'Karta egasining ismi',
              ctrl: _nameCtrl,
              hint: 'JOHN DOE',
              keyboard: TextInputType.name,
              formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
              maxLength: 26,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: _field(
                label: 'Muddat',
                ctrl: _expiryCtrl,
                hint: 'MM/YY',
                keyboard: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly, _ExpiryFormatter()],
                maxLength: 5,
                onChanged: (_) => setState(() {}),
              )),
              const SizedBox(width: 16),
              Expanded(child: _field(
                label: 'CVV',
                ctrl: _cvvCtrl,
                hint: '•••',
                keyboard: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 3,
                obscure: true,
                focusNode: _cvvNode,
                onChanged: (_) => setState(() {}),
              )),
            ]),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isVisa ? const Color(0xFF1A1F71) : const Color(0xFFEB001B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                    : Text("To'lash", style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text("256-bit SSL himoyasi", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    required TextInputType keyboard,
    List<TextInputFormatter>? formatters,
    int? maxLength,
    bool obscure = false,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, color: context.textMuted)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        focusNode: focusNode,
        keyboardType: keyboard,
        obscureText: obscure,
        maxLength: maxLength,
        inputFormatters: formatters,
        textCapitalization: textCapitalization,
        onChanged: onChanged,
        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: context.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: context.textMuted),
          counterText: '',
          filled: true,
          fillColor: context.inputColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: _isVisa ? const Color(0xFF1A1F71) : const Color(0xFFEB001B), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ]);
  }
}

// --- Karta old tomoni ---
class _CardFront extends StatelessWidget {
  final String number, name, expiry;
  final bool isVisa;
  const _CardFront({required this.number, required this.name, required this.expiry, required this.isVisa});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isVisa
              ? [const Color(0xFF1A1F71), const Color(0xFF3B3FBF)]
              : [const Color(0xFF1A1A1A), const Color(0xFF444444)],
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(width: 40, height: 28,
                decoration: BoxDecoration(color: Colors.amber.shade300, borderRadius: BorderRadius.circular(4))),
              Image.asset(
                isVisa ? 'assets/images/visa_logo.png' : 'assets/images/mastercard_logo.png',
                height: 32, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(
                  isVisa ? 'VISA' : 'MC',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ),
            ]),
            const Spacer(),
            Text(number, style: GoogleFonts.robotoMono(
                fontSize: 18, color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('KARTA EGASI', style: GoogleFonts.inter(fontSize: 9, color: Colors.white54)),
                Text(name, style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('MUDDAT', style: GoogleFonts.inter(fontSize: 9, color: Colors.white54)),
                Text(expiry, style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ],
        ),
      ),
    );
  }
}

// --- Karta orqa tomoni (CVV) ---
class _CardBack extends StatelessWidget {
  final String cvv;
  final bool isVisa;
  const _CardBack({required this.cvv, required this.isVisa});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isVisa
              ? [const Color(0xFF1A1F71), const Color(0xFF3B3FBF)]
              : [const Color(0xFF1A1A1A), const Color(0xFF444444)],
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 30),
          Container(height: 40, color: Colors.black),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              Expanded(child: Container(
                height: 36, color: Colors.grey.shade300,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(cvv.isEmpty ? '•••' : cvv,
                    style: GoogleFonts.robotoMono(fontSize: 18, fontWeight: FontWeight.w700)),
              )),
              const SizedBox(width: 12),
              Text('CVV', style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
            ]),
          ),
        ],
      ),
    );
  }
}

// --- Formatters ---
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final str = buf.toString();
    return TextEditingValue(text: str, selection: TextSelection.collapsed(offset: str.length));
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll('/', '');
    if (digits.length <= 2) return next.copyWith(text: digits);
    final str = '${digits.substring(0, 2)}/${digits.substring(2, digits.length.clamp(0, 4))}';
    return TextEditingValue(text: str, selection: TextSelection.collapsed(offset: str.length));
  }
}
