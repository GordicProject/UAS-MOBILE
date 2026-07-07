import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/validators.dart';
import '../../core/theme/app_theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.resetPassword(_emailCtrl.text.trim());
    if (!mounted) return;
    if (success) {
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('EMAIL TIDAK DITEMUKAN',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: AppTheme.paper, letterSpacing: 1.5)),
          backgroundColor: AppTheme.acidRed,
          behavior: SnackBarBehavior.floating,
          shape: AppTheme.brutalShape,
        ),
      );
    }
  }

  Widget _labelChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppTheme.adaptiveText(context), borderRadius: BorderRadius.circular(2)),
        child: Text(text, style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.adaptiveBackground(context),
      appBar: AppBar(
        backgroundColor: AppTheme.adaptiveBackground(context),
        foregroundColor: AppTheme.adaptiveText(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('RESET PASSWORD', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.adaptiveSurface(context),
                      border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [BoxShadow(color: AppTheme.adaptiveText(context), offset: const Offset(6, 6), blurRadius: 0)],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: AppTheme.acidLime,
                            border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.check_rounded, color: AppTheme.adaptiveText(context), size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text('EMAIL RESET TERKIRIM!',
                            style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: 0.5),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(
                          'Instruksi reset password telah dikirim ke ${_emailCtrl.text}',
                          style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppTheme.adaptiveTextSecondary(context), fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.ink,
                        side: BorderSide(color: AppTheme.adaptiveText(context), width: 3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('KEMBALI KE LOGIN',
                          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
                    ),
                  ),
                ],
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Header brutal
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.acidLime,
                        border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [BoxShadow(color: AppTheme.adaptiveText(context), offset: const Offset(6, 6), blurRadius: 0)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: AppTheme.adaptiveText(context), borderRadius: BorderRadius.circular(4)),
                            child: Icon(Icons.lock_reset_rounded, color: AppTheme.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('LUPA PASSWORD?',
                                    style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: -0.5)),
                                Text('Kami akan kirim instruksi reset via email',
                                    style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppTheme.adaptiveText(context), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    _labelChip('EMAIL'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.spaceGrotesk(color: AppTheme.adaptiveText(context), fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.adaptiveText(context)),
                        hintText: 'nama@email.com',
                        hintStyle: GoogleFonts.spaceGrotesk(color: AppTheme.adaptiveTextSecondary(context), fontWeight: FontWeight.w600),
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 28),

                    Consumer<AuthProvider>(
                      builder: (_, auth, __) => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _sendReset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.acidLime,
                            foregroundColor: AppTheme.isDark(context) ? AppTheme.textPrimaryDark : AppTheme.ink,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            side: BorderSide(color: AppTheme.adaptiveText(context), width: 3),
                          ),
                          child: auth.isLoading
                              ? SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.adaptiveText(context)))
                              : Text('KIRIM LINK RESET →',
                                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}