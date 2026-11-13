import 'package:flutter/material.dart';

/// NHODP Design System v4 — Pharaonic Gold × Obsidian × Sand
/// Inspired by: Ancient Egyptian architecture, Bloomberg Terminal, WHO dashboards
class AppColors {
  // ── PRIMARY GOLD SYSTEM (24-karat palette) ───────────────────
  static const Color gold        = Color(0xFFCFA84C);   // Primary gold
  static const Color goldLight   = Color(0xFFE4C06E);   // Highlight gold
  static const Color goldBright  = Color(0xFFF2D488);   // Max brightness
  static const Color goldDim     = Color(0xFF8B6914);   // Pressed / shadow
  static const Color goldDeep    = Color(0xFF5C430A);   // Very deep gold
  static const Color goldSurface = Color(0xFF1C1808);   // Gold-tinted surface

  // ── PHARAONIC SAND SYSTEM (ancient papyrus tones) ────────────
  static const Color sand        = Color(0xFFD4A96A);   // Egyptian sand
  static const Color sandLight   = Color(0xFFE8C99A);   // Pale papyrus
  static const Color sandDeep    = Color(0xFF8B6340);   // Dark sand

  // ── OBSIDIAN BLACKS (structured depth) ───────────────────────
  static const Color obsidian    = Color(0xFF080809);   // Page background
  static const Color charcoal    = Color(0xFF0F0F12);   // AppBar / nav bg
  static const Color inkBlack    = Color(0xFF161618);   // Card background
  static const Color darkSurface = Color(0xFF1E1E22);   // Elevated cards
  static const Color elevated    = Color(0xFF252528);   // Input fill
  static const Color border      = Color(0xFF2A2A30);   // Dividers
  static const Color subtle      = Color(0xFF353540);   // Hover state

  // ── TEXT SYSTEM ──────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0EDE6); // #F0EDE6 — warm white
  static const Color textSecondary = Color(0xFF9A9290); // Muted warm gray
  static const Color textMuted     = Color(0xFF5C5650); // Captions
  static const Color textGold      = Color(0xFFCFA84C); // Gold text

  // ── STATUS COLORS ────────────────────────────────────────────
  static const Color success      = Color(0xFF1A6B45);
  static const Color successLight = Color(0xFF2EA057);
  static const Color warning      = Color(0xFFCFA84C);
  static const Color error        = Color(0xFFC0392B);
  static const Color errorLight   = Color(0xFFE84040);
  static const Color info         = Color(0xFF1A5C7A);
  static const Color egyptRed     = Color(0xFFBC1928);

  // ── CATEGORY COLORS (data visualization palette) ─────────────
  static const Color catOncology        = Color(0xFFD4495A);
  static const Color catInfectious      = Color(0xFF4A90D9);
  static const Color catEndocrine       = Color(0xFF2ECC71);
  static const Color catCardio          = Color(0xFFE74C3C);
  static const Color catHepato          = Color(0xFF1ABC9C);
  static const Color catMaternal        = Color(0xFFAB59B8);
  static const Color catMental          = Color(0xFF26C6DA);
  static const Color catPediatrics      = Color(0xFF5C88DA);
  static const Color catNutrition       = Color(0xFFE8A73A);
  static const Color catInfrastructure  = Color(0xFF78909C);
  static const Color catNeonatology     = Color(0xFFEC407A);

  // ── GOVERNORATE HEALTH INDEX COLORS ──────────────────────────
  static const Color govExcellent  = Color(0xFF00BFA5); // 75+
  static const Color govGood       = Color(0xFF43A047); // 65-74
  static const Color govModerate   = Color(0xFFF9A825); // 55-64
  static const Color govPoor       = Color(0xFFE64A19); // <55

  // ── CONST GRADIENTS ──────────────────────────────────────────
  static const LinearGradient goldAccent = LinearGradient(
    colors: [Color(0xFF8B6914), Color(0xFFCFA84C), Color(0xFFE4C06E)],
    begin: Alignment.centerLeft, end: Alignment.centerRight,
  );
  static const LinearGradient goldVertical = LinearGradient(
    colors: [Color(0xFFE4C06E), Color(0xFFCFA84C), Color(0xFF8B6914)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );
  static const LinearGradient pharaohGradient = LinearGradient(
    colors: [Color(0xFF0C0908), Color(0xFF14100A), Color(0xFF0C0908)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A1E), Color(0xFF161618)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF080809), Color(0xFF0F0C06)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );

  // ── ALIASES (backward compat) ─────────────────────────────────
  static const Color primary     = gold;
  static const Color secondary   = goldLight;
  static const Color surface     = inkBlack;
  static const Color ink         = obsidian;
  static const Color divider     = border;
  static const Color borderLight = border;
  static const Color navBg       = charcoal;
  static const Color navBorder   = border;
  static const Color navActive   = elevated;
  static const Color midGray     = textSecondary;
  static const Color softGray    = textMuted;
  static const Color paleGray    = textMuted;
  static const Color darkGray    = textSecondary;
  static const Color cardDark    = inkBlack;
  static const Color egyptGold   = gold;
  static const Color egyptBlack  = obsidian;
  static const LinearGradient goldGradient        = goldAccent;
  static const LinearGradient goldCardGradient    = goldAccent;
  static const LinearGradient goldSimpleGradient  = goldAccent;
  static const Color goldSimple  = gold;

  // ── PHARAONIC PATTERN HELPERS ────────────────────────────────
  static const Color hieroglyphLine = Color(0xFF2A2418);  // Subtle pattern lines
  static const Color lotusGold      = Color(0xFFCFA84C);  // Lotus petal accent
  static const Color scarabBlue     = Color(0xFF1A4A6B);  // Egyptian blue (lapis)
}
