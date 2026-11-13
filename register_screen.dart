import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../config/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _instCtrl  = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  bool _obscure    = true;
  String _role     = 'public';

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _instCtrl.dispose(); _passCtrl.dispose(); _pass2Ctrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().register(
      email: _emailCtrl.text.trim(), password: _passCtrl.text,
      fullName: _nameCtrl.text.trim(), institution: _instCtrl.text.trim().isEmpty ? null : _instCtrl.text.trim());
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Account created! Sign in.', style: GoogleFonts.inter()),
        backgroundColor: AppColors.success));
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(backgroundColor: AppColors.charcoal, surfaceTintColor: Colors.transparent,
        title: Text('Create Account', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Join NHODP', style: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Container(width: 40, height: 2, decoration: BoxDecoration(gradient: AppColors.goldAccent)).animate(delay: 200.ms).scaleX(begin: 0),
          const SizedBox(height: 6),
          Text('Access Egypt\'s health data ecosystem', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(height: 28),
          _field(_nameCtrl, 'Full Name *', Icons.person_outlined),
          const SizedBox(height: 14),
          _field(_emailCtrl, 'Email Address *', Icons.email_outlined, type: TextInputType.emailAddress,
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null),
          const SizedBox(height: 14),
          _field(_instCtrl, 'Institution / Organization', Icons.business_outlined),
          const SizedBox(height: 16),
          Text('Account Role', style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 10),
          Row(children: ['public', 'researcher'].map((r) => Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _role = r),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _role == r ? AppColors.gold.withOpacity(0.12) : AppColors.elevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _role == r ? AppColors.gold : AppColors.border, width: _role == r ? 1.5 : 1)),
                child: Column(children: [
                  Icon(_role == r ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: _role == r ? AppColors.gold : AppColors.textMuted, size: 18),
                  const SizedBox(height: 5),
                  Text(r[0].toUpperCase() + r.substring(1), style: GoogleFonts.inter(
                    color: _role == r ? AppColors.gold : AppColors.textMuted,
                    fontWeight: FontWeight.w700, fontSize: 13)),
                ])),
            )))).toList()),
          const SizedBox(height: 14),
          _field(_passCtrl, 'Password *', Icons.lock_outlined, obscure: _obscure,
            suffix: IconButton(icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: AppColors.textMuted),
              onPressed: () => setState(() => _obscure = !_obscure)),
            validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null),
          const SizedBox(height: 14),
          _field(_pass2Ctrl, 'Confirm Password *', Icons.lock_outlined, obscure: _obscure,
            validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null),
          const SizedBox(height: 24),
          Consumer<AuthProvider>(builder: (_, auth, __) {
            if (auth.error != null) return Container(
              margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.4))),
              child: Text(auth.error!, style: GoogleFonts.inter(color: AppColors.error, fontSize: 13)));
            return const SizedBox();
          }),
          Consumer<AuthProvider>(builder: (_, auth, __) => SizedBox(width: double.infinity,
            child: GestureDetector(onTap: auth.isLoading ? null : _submit,
              child: Container(height: 54,
                decoration: BoxDecoration(
                  gradient: !auth.isLoading ? const LinearGradient(colors: [AppColors.goldDim, AppColors.gold, AppColors.goldLight]) : null,
                  color: auth.isLoading ? AppColors.elevated : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !auth.isLoading ? [BoxShadow(color: AppColors.gold.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))] : []),
                child: Center(child: auth.isLoading
                  ? const CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.obsidian)
                  : Text('Create Account', style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800, fontSize: 16))))))),
          const SizedBox(height: 18),
          Center(child: GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            child: RichText(text: TextSpan(children: [
              TextSpan(text: 'Already have an account? ', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
              TextSpan(text: 'Sign In', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 14)),
            ])))),
        ])),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool obscure = false, Widget? suffix, TextInputType? type, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl, obscureText: obscure, keyboardType: type,
      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18), suffixIcon: suffix),
      validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null,
    );
  }
}
