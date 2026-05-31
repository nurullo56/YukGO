import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/features/auth/screens/role_selection_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _code => _ctrls.map((c) => c.text).join();

  void _onChanged(int i, String val) {
    if (val.length == 6) {
      for (int j = 0; j < 6 && j < val.length; j++) {
        _ctrls[j].text = val[j];
      }
      _nodes[5].requestFocus();
      setState(() {});
      return;
    }
    if (val.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
    setState(() {});
  }

  void _onKey(int i, RawKeyEvent e) {
    if (e is RawKeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[i].text.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
  }

  void _verify() async {
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _loading = false);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const RoleSelectionScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: context.inputColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_back, color: context.textPrimary, size: 20),
                ),
              ),
              const SizedBox(height: 32),
              Text("Kodni kiriting", style: GoogleFonts.inter(
                fontSize: 26, fontWeight: FontWeight.w800, color: context.textPrimary,
              )),
              const SizedBox(height: 8),
              Text(
                "${widget.email} manziliga 6 raqamli kod yuborildi",
                style: GoogleFonts.inter(fontSize: 14, color: context.textMuted, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Demo: istalgan raqam kiriting yoki bo'sh qoldiring",
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _OtpBox(
                  ctrl: _ctrls[i], node: _nodes[i],
                  onChanged: (v) => _onChanged(i, v),
                  onKey: (e) => _onKey(i, e),
                  hasValue: _ctrls[i].text.isNotEmpty,
                )),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: GoogleFonts.inter(fontSize: 13, color: Colors.red.shade400)),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                      : Text("Tasdiqlash", style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode node;
  final ValueChanged<String> onChanged;
  final ValueChanged<RawKeyEvent> onKey;
  final bool hasValue;

  const _OtpBox({
    required this.ctrl, required this.node,
    required this.onChanged, required this.onKey, required this.hasValue,
  });

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: onKey,
      child: SizedBox(
        width: 46, height: 56,
        child: TextField(
          controller: ctrl, focusNode: node,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: context.textPrimary),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: hasValue ? AppTheme.primary.withValues(alpha: 0.1) : context.inputColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: hasValue ? const BorderSide(color: AppTheme.primary, width: 1.5) : BorderSide.none),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
