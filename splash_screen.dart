import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../widgets/pharaonic_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lineCtrl;
  late AnimationController _ringCtrl;
  late AnimationController _shimCtrl;

  @override
  void initState() {
    super.initState();
    _lineCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..forward();
    _ringCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 30))
          ..repeat();
    _shimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/');
    });
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    _ringCtrl.dispose();
    _shimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Stack(fit: StackFit.expand, children: [
        // Pharaonic geometric background
        CustomPaint(painter: PharaonicBgPainter()),
        // Gold glow pulse
        Center(
          child: AnimatedBuilder(
            animation: _shimCtrl,
            builder: (_, __) => Container(
              width: 300 + _shimCtrl.value * 20,
              height: 300 + _shimCtrl.value * 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.gold
                      .withOpacity(0.06 + _shimCtrl.value * 0.03),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ),
        // Rotating precision ring
        Center(
          child: SizedBox(
            width: 260,
            height: 260,
            child: RotationTransition(
              turns: _ringCtrl,
              child: CustomPaint(painter: GoldTickRingPainter(ticks: 60)),
            ),
          ),
        ),
        // Inner static ring
        Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.gold.withOpacity(0.1), width: 1),
            ),
          ),
        ),
        // Main content
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Emblem
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.inkBlack,
                border: Border.all(
                    color: AppColors.gold.withOpacity(0.45), width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.gold.withOpacity(0.2),
                      blurRadius: 28,
                      spreadRadius: 4),
                ],
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.goldAccent.createShader(b),
                  child: const Icon(Icons.health_and_safety_rounded,
                      size: 46, color: Colors.white),
                ),
              ),
            )
                .animate()
                .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 1000.ms,
                    curve: Curves.elasticOut)
                .fadeIn(),
            const SizedBox(height: 32),
            // NHODP wordmark
            Text(
              'NHODP',
              style: GoogleFonts.inter(
                  fontSize: 44,
                  fontWeight: FontWeight.w200,
                  color: AppColors.textPrimary,
                  letterSpacing: 16),
            ).animate(delay: 400.ms).fadeIn(duration: 700.ms),
            const SizedBox(height: 10),
            // Animated gold rule
            AnimatedBuilder(
              animation: _lineCtrl,
              builder: (_, __) => SizedBox(
                width: 200,
                height: 1.5,
                child: CustomPaint(
                    painter: GoldRulePainter(progress: _lineCtrl.value)),
              ),
            ).animate(delay: 600.ms).fadeIn(),
            const SizedBox(height: 12),
            Text(
              'NATIONAL HEALTH OPEN DATA PORTAL',
              style: GoogleFonts.inter(
                  fontSize: 9.5,
                  color: AppColors.textMuted,
                  letterSpacing: 3.5),
            ).animate(delay: 700.ms).fadeIn(),
            const SizedBox(height: 6),
            Text(
              'وزارة الصحة والسكان — جمهورية مصر العربية',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.gold.withOpacity(0.6)),
            ).animate(delay: 900.ms).fadeIn(),
            const SizedBox(height: 52),
            _LoadingDots(ctrl: _shimCtrl),
          ]),
        ),
        // Egypt flag strip + version
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(
                  child: Container(
                      height: 2,
                      color: AppColors.egyptRed.withOpacity(0.8))),
              Expanded(
                  child: Container(
                      height: 2,
                      color: Colors.white.withOpacity(0.12))),
              Expanded(
                  child:
                      Container(height: 2, color: AppColors.charcoal)),
            ]),
            Container(
              color: AppColors.charcoal,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  'v2.0.0  ·  Ministry of Health & Population, Egypt',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      letterSpacing: 1),
                ),
              ),
            ).animate(delay: 1200.ms).fadeIn(),
          ]),
        ),
      ]),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  final AnimationController ctrl;
  const _LoadingDots({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase = (ctrl.value * math.pi * 2 + i * 1.2) % (math.pi * 2);
          final opacity = 0.3 + (math.sin(phase).abs() * 0.7);
          return Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withOpacity(opacity.clamp(0.0, 1.0)),
            ),
          );
        }),
      ),
    );
  }
}
