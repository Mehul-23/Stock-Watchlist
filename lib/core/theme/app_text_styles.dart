import 'package:flutter/material.dart';

import 'app_colors.dart';

/// All text styles used across the app, defined as constants for reusability.
abstract final class AppTextStyles {
  static const TextStyle displayTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
    height: 1.2,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle stockSymbol = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle stockName = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle price = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle priceChange = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle changePill = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0,
  );

  static const TextStyle tabActive = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.tabActive,
    letterSpacing: 0,
  );

  static const TextStyle tabInactive = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.tabInactive,
    letterSpacing: 0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0,
  );

  static const TextStyle hint = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0,
  );

  static const TextStyle editSymbol = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF555555),
    letterSpacing: 0,
  );

  static const TextStyle tickerIndex = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle tickerValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle tickerChange = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
