import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../config/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'admin@nhodp.gov.eg');
  final _passCtrl  = TextEditingController(text: 'Admin@2026');
  final _formKey   = GlobalKey<FormState>();
  bool _obscure    = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().login(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (ok && mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Stack(children: [
        CustomPaint(painter: _BgPainter()),
        SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(onTap: () => Navigator.pop(context),
            child: Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.inkBlack, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textSecondary))),
          const SizedBox(height: 40),
          ShaderMask(shaderCallback: (b) => AppColors.goldAccent.createShader(b),
            child: const Icon(Icons.health_and_safety_rounded, size: 44, color: Colors.white))
            .animate().scale(begin: const Offset(0.6, 0.6), duration: 700.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 18),
          Text('Sign In', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary))
            .animate(delay: 100.ms).fadeIn().slideY(begin: 0.15),
          Container(width: 36, height: 2, margin: const EdgeInsets.only(top: 8, bottom: 6), decoration: BoxDecoration(gradient: AppColors.goldAccent))
            .animate(delay: 280.ms).scaleX(begin: 0),
          Text('Access your NHODP account', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted))
            .animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 28),
          // Demo hint
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.gold.withOpacity(0.2))),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 16), const SizedBox(width: 8),
              Text('Demo credentials pre-filled', style: GoogleFonts.inter(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500)),
            ])).animate(delay: 300.ms).fadeIn(),
          const SizedBox(height: 24),
          Form(key: _formKey, child: Column(children: [
            _Field(ctrl: _emailCtrl, label: 'Email address', icon: Icons.email_outlined, type: TextInputType.emailAddress,
              validator: (v) => (v==null||!v.contains('@')) ? 'Enter a valid email' : null)
              .animate(delay: 380.ms).fadeIn().slideY(begin: 0.15),
            const SizedBox(height: 14),
            _Field(ctrl: _passCtrl, label: 'Password', icon: Icons.lock_outline_rounded, obscure: _obscure,
              suffix: IconButton(icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: AppColors.textMuted),
                onPressed: () => setState(() => _obscure = !_obscure)),
              validator: (v) => (v==null||v.length<6) ? 'Minimum 6 characters' : null,
              onSubmit: (_) => _submit())
              .animate(delay: 440.ms).fadeIn().slideY(begin: 0.15),
          ])),
          Consumer<AuthProvider>(builder: (_, auth, __) {
            if (auth.error == null) return const SizedBox();
            return Container(margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.error.withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.error_outline, color: AppColors.errorLight, size: 16), const SizedBox(width: 8),
                Expanded(child: Text(auth.error!, style: GoogleFonts.inter(color: AppColors.errorLight, fontSize: 13))),
              ])).animate().fadeIn().shake();
          }),
          const SizedBox(height: 22),
          Consumer<AuthProvider>(builder: (_, auth, __) => GestureDetector(onTap: auth.isLoading ? null : _submit,
            child: Container(width: double.infinity, height: 52,
              decoration: BoxDecoration(
                gradient: auth.isLoading ? null : const LinearGradient(colors: [AppColors.goldDim, AppColors.gold, AppColors.goldLight]),
                color: auth.isLoading ? AppColors.inkBlack : null,
                borderRadius: BorderRadius.circular(10),
                boxShadow: auth.isLoading ? [] : [BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]),
              child: Center(child: auth.isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.gold))
                : Text('Sign In', style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800, fontSize: 16)))))
            .animate(delay: 500.ms).fadeIn()),
          const SizedBox(height: 20),
          Center(child: GestureDetector(onTap: () => Navigator.pushNamed(context, '/register'),
            child: RichText(text: TextSpan(children: [
              TextSpan(text: "Don't have an account? ", style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
              TextSpan(text: 'Register', style: GoogleFonts.inter(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 14)),
            ])))).animate(delay: 560.ms).fadeIn(),
        ]))),
      ]),
    );
  }
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.02)..strokeWidth = 0.5;
    for (double x = -size.height; x < size.width + size.height; x += 64)
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), p);
  }
  @override bool shouldRepaint(_) => false;
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl; final String label; final IconData icon;
  final bool obscure; final Widget? suffix; final TextInputType? type;
  final String? Function(String?)? validator; final ValueChanged<String>? onSubmit;
  const _Field({required this.ctrl, required this.label, required this.icon,
    this.obscure = false, this.suffix, this.type, this.validator, this.onSubmit});
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl, obscureText: obscure, keyboardType: type,
    style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18), suffixIcon: suffix),
    validator: validator ?? (v) => (v==null||v.trim().isEmpty) ? 'Required' : null,
    onFieldSubmitted: onSubmit);
}
