import 'package:flutter/material.dart';

/// Centralized color palette for the 021Trade watchlist app.
abstract final class AppColors {
  // ── Light theme backgrounds ───────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color surfaceVariant = Color(0xFFEEEEEE);
  static const Color card = Color(0xFFFFFFFF);

  // ── Dark theme / Edit screen backgrounds ─────────────────────────────────
  static const Color darkBackground = Color(0xFF0B0E11);
  static const Color darkSurface = Color(0xFF141720);
  static const Color darkSurfaceVariant = Color(0xFF1E2229);

  // ── Text (light theme) ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFFAAAAAA);

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF387ED1);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color gain = Color(0xFF1DB954);
  static const Color loss = Color(0xFFE84040);
  static const Color gainBg = Color(0x1A1DB954);
  static const Color lossBg = Color(0x1AE84040);

  // ── Structural ───────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFEEEEEE);
  static const Color dragHandle = Color(0xFFBBBBBB);
  static const Color strokeSubtle = Color(0xFFE8E8E8);

  // ── Market ticker bar ────────────────────────────────────────────────────
  static const Color tickerBg = Color(0xFFF7F7F7);
  static const Color tickerBorder = Color(0xFFE0E0E0);

  // ── Tab bar ──────────────────────────────────────────────────────────────
  static const Color tabActive = Color(0xFF387ED1);
  static const Color tabInactive = Color(0xFF888888);
  static const Color tabIndicator = Color(0xFF387ED1);

  // ── Bottom nav ───────────────────────────────────────────────────────────
  static const Color bottomNavBg = Color(0xFFFFFFFF);
  static const Color bottomNavSelected = Color(0xFF387ED1);
  static const Color bottomNavUnselected = Color(0xFF888888);

  // ── Edit screen (light) ──────────────────────────────────────────────────
  static const Color editBg = Color(0xFFF5F5F5);
  static const Color editCard = Color(0xFFFFFFFF);
  static const Color editDivider = Color(0xFFE8E8E8);
  static const Color editDragHandle = Color(0xFF9E9E9E);
  static const Color editDeleteIcon = Color(0xFF212121);
}
