import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

/// Shared AppBar for all screens — no duplication, consistent styling
PreferredSizeWidget buildAppBar({
  required String title,
  String? subtitle,
  List<Widget>? actions,
  bool centerTitle = false,
  PreferredSizeWidget? bottom,
  Widget? leading,
  bool automaticallyImplyLeading = true,
  double expandedHeight = 0,
  Color backgroundColor = AppColors.charcoal,
}) {
  if (expandedHeight > 0) {
    // For screens needing SliverAppBar, return a simple AppBar
    // (SliverAppBar must be built directly in the screen)
  }
  return AppBar(
    backgroundColor: backgroundColor,
    foregroundColor: AppColors.textPrimary,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    automaticallyImplyLeading: automaticallyImplyLeading,
    leading: leading,
    centerTitle: centerTitle,
    title: subtitle != null
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
          ])
        : Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    actions: actions,
    bottom: bottom ?? PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: AppColors.border),
    ),
  );
}

/// Reusable status badge (Live/Demo)
Widget buildStatusBadge(bool online) => Container(
  margin: const EdgeInsets.only(right: 12),
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    color: online ? AppColors.catHepato.withOpacity(0.12) : AppColors.gold.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: online ? AppColors.catHepato.withOpacity(0.3) : AppColors.gold.withOpacity(0.3))),
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 5, height: 5,
      decoration: BoxDecoration(shape: BoxShape.circle, color: online ? AppColors.catHepato : AppColors.gold)),
    const SizedBox(width: 4),
    Text(online ? 'Live' : 'Demo',
      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: online ? AppColors.catHepato : AppColors.gold)),
  ]));

/// Reusable section header with gold underline
Widget buildSectionHeader(String title, {String? trailing, EdgeInsets padding = const EdgeInsets.fromLTRB(0, 20, 0, 12)}) =>
  Padding(padding: padding, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      Container(width: 28, height: 2, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(gradient: AppColors.goldAccent)),
    ]),
    if (trailing != null) ...[
      const Spacer(),
      Text(trailing, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
    ],
  ]));

/// Reusable gold CTA button
Widget buildGoldButton({required String label, required VoidCallback onTap, bool loading = false, IconData? icon}) =>
  GestureDetector(onTap: loading ? null : onTap,
    child: Container(
      height: 50, width: double.infinity,
      decoration: BoxDecoration(
        gradient: loading ? null : const LinearGradient(colors: [AppColors.goldDim, AppColors.gold, AppColors.goldLight]),
        color: loading ? AppColors.elevated : null,
        borderRadius: BorderRadius.circular(10),
        boxShadow: loading ? [] : [BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 5))]),
      child: Center(child: loading
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.gold))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 16, color: AppColors.obsidian), const SizedBox(width: 8)],
            Text(label, style: GoogleFonts.inter(color: AppColors.obsidian, fontWeight: FontWeight.w800, fontSize: 15)),
          ]))));

/// Reusable empty state
Widget buildEmptyState({required String title, String? subtitle, IconData icon = Icons.search_off_rounded}) =>
  Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.inkBlack, border: Border.all(color: AppColors.border)),
      child: Icon(icon, size: 36, color: AppColors.textMuted)),
    const SizedBox(height: 14),
    Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
    if (subtitle != null) ...[
      const SizedBox(height: 6),
      Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
    ],
  ]));

/// Reusable loading indicator
Widget buildLoader() => const Center(child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2));
