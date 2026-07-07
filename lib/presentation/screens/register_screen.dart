import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/validators.dart';
import '../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('REGISTRASI BERHASIL!', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: 1.5)),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: AppTheme.brutalShape,
        ),
      );
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'REGISTRASI GAGAL', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: 1.5)),
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
        title: Text('DAFTAR AKUN', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header brutal
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [BoxShadow(color: AppTheme.adaptiveText(context), offset: Offset(6, 6), blurRadius: 0)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: AppTheme.adaptiveText(context), borderRadius: BorderRadius.circular(4)),
                      child: Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AKUN BARU', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: -0.5)),
                          Text('Bergabung ke sistem helpdesk', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppTheme.adaptiveText(context), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Name field
              _labelChip('NAMA LENGKAP'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                style: GoogleFonts.spaceGrotesk(color: AppTheme.adaptiveText(context), fontWeight: FontWeight.w700),
                decoration: InputDecoration(prefixIcon: Icon(Icons.person_outlined, color: AppTheme.adaptiveText(context))),
                validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 18),

              // Email
              _labelChip('EMAIL'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.spaceGrotesk(color: AppTheme.adaptiveText(context), fontWeight: FontWeight.w700),
                decoration: InputDecoration(prefixIcon: Icon(Icons.email_outlined, color: AppTheme.adaptiveText(context)), hintText: 'nama@email.com'),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 18),

              // Password
              _labelChip('PASSWORD'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                style: GoogleFonts.spaceGrotesk(color: AppTheme.adaptiveText(context), fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outlined, color: AppTheme.adaptiveText(context)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.adaptiveText(context)),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 18),

              // Confirm Password
              _labelChip('KONFIRMASI PASSWORD'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordCtrl,
                obscureText: true,
                style: GoogleFonts.spaceGrotesk(color: AppTheme.adaptiveText(context), fontWeight: FontWeight.w700),
                decoration: InputDecoration(prefixIcon: Icon(Icons.lock_outline, color: AppTheme.adaptiveText(context))),
                validator: (v) => v != _passwordCtrl.text ? 'Password tidak cocok' : null,
              ),
              const SizedBox(height: 28),

              Consumer<AuthProvider>(
                builder: (_, auth, __) => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.acidLime,
                      foregroundColor: AppTheme.isDark(context) ? AppTheme.textPrimaryDark : AppTheme.ink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      side: BorderSide(color: AppTheme.adaptiveText(context), width: 3),
                    ),
                    child: auth.isLoading
                        ? SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.adaptiveText(context)))
                        : Text('DAFTAR SEKARANG →',
                            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text.rich(
                      TextSpan(
                        text: 'SUDAH PUNYA AKUN? ',
                        style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppTheme.adaptiveText(context), fontWeight: FontWeight.w700, letterSpacing: 1.2),
                        children: [
                          TextSpan(
                            text: 'LOGIN',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: AppTheme.adaptiveText(context),
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.underline,
                              decorationThickness: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
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