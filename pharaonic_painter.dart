import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Subtle pharaonic geometric patterns — clean, not kitsch
class PharaonicBgPainter extends CustomPainter {
  final double opacity;
  const PharaonicBgPainter({this.opacity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final thin   = Paint()..color = AppColors.gold.withOpacity(0.025 * opacity)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    final medium = Paint()..color = AppColors.gold.withOpacity(0.04 * opacity)..strokeWidth = 0.8..style = PaintingStyle.stroke;

    // Fine diagonal grid (inspired by pyramid geometry — 52° angle)
    const angle = 52.0 * math.pi / 180;
    final step  = 56.0;
    for (double x = -size.height * 2; x < size.width + size.height; x += step) {
      final dx = size.height / math.tan(angle);
      canvas.drawLine(Offset(x, 0), Offset(x + dx, size.height), thin);
    }

    // Horizontal accent lines (papyrus scroll lines)
    for (double y = 0; y < size.height; y += 120) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), medium);
    }

    // Corner lotus ornaments (geometric only)
    _drawLotusCorner(canvas, Offset(0, 0), 40, medium, flip: false);
    _drawLotusCorner(canvas, Offset(size.width, 0), 40, medium, flip: true);
  }

  void _drawLotusCorner(Canvas canvas, Offset origin, double size, Paint p, {required bool flip}) {
    final sx = flip ? -1.0 : 1.0;
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(sx, 1);
    // Simple geometric lotus — two arcs
    canvas.drawArc(Rect.fromLTWH(0, 0, size * 0.6, size * 0.6), math.pi, math.pi / 2, false, p);
    canvas.drawArc(Rect.fromLTWH(size * 0.2, size * 0.1, size * 0.4, size * 0.4), math.pi + math.pi / 4, math.pi / 2, false, p);
    canvas.restore();
  }

  @override bool shouldRepaint(PharaonicBgPainter old) => old.opacity != opacity;
}

/// Art-deco tick ring (used in dashboard header)
class GoldTickRingPainter extends CustomPainter {
  final int ticks; final double innerRatio;
  const GoldTickRingPainter({this.ticks = 48, this.innerRatio = 0.88});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;
    final pRing  = Paint()..color = AppColors.gold.withOpacity(0.2)..strokeWidth = 0.8..style = PaintingStyle.stroke;
    final pTick  = Paint()..color = AppColors.gold.withOpacity(0.5)..strokeWidth = 1.2..style = PaintingStyle.stroke;
    final pBig   = Paint()..color = AppColors.gold.withOpacity(0.7)..strokeWidth = 2.0..style = PaintingStyle.stroke;

    canvas.drawCircle(c, r, pRing);
    canvas.drawCircle(c, r * innerRatio, pRing..color = AppColors.gold.withOpacity(0.08));

    for (int i = 0; i < ticks; i++) {
      final angle  = (i / ticks) * 2 * math.pi - math.pi / 2;
      final isMajor = i % (ticks ~/ 12) == 0;
      final inner  = r * (isMajor ? 0.80 : 0.89);
      final outer  = r;
      final p1 = Offset(c.dx + inner * math.cos(angle), c.dy + inner * math.sin(angle));
      final p2 = Offset(c.dx + outer * math.cos(angle), c.dy + outer * math.sin(angle));
      canvas.drawLine(p1, p2, isMajor ? pBig : pTick);
    }
  }
  @override bool shouldRepaint(_) => false;
}

/// Gradient gold shimmer line
class GoldRulePainter extends CustomPainter {
  final double progress;
  const GoldRulePainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, AppColors.goldBright, AppColors.gold, Colors.transparent],
        stops: [0, (progress * 0.4).clamp(0.0, 0.6), (progress * 0.4 + 0.3).clamp(0.3, 1.0), 1],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = size.height
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }
  @override bool shouldRepaint(GoldRulePainter old) => old.progress != progress;
}

/// Route transition wrapper — elegant fade+slide
class PharaonicRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  PharaonicRoute({required this.child})
    : super(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => child,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.03, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child));
        });
}
