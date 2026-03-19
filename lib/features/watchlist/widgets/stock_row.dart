import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/stock.dart';

/// Flat stock row shown on the main watchlist screen.
/// Matches the 021Trade reference: symbol + exchange on left, price + change on right.
class StockRow extends StatelessWidget {
  final Stock stock;

  const StockRow({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final isPos = stock.isPositive;
    final priceColor = isPos ? AppColors.gain : AppColors.loss;
    final sign = isPos ? '+' : '';

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Left: symbol + exchange ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(stock.symbol, style: AppTextStyles.stockSymbol),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(stock.exchange, style: AppTextStyles.stockName),
                      const Text(' | ', style: AppTextStyles.stockName),
                      const Text('EQ', style: AppTextStyles.stockName),
                    ],
                  ),
                ],
              ),
            ),

            // ── Right: price + absolute change (pct) ───────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatPrice(stock.currentPrice),
                  style: AppTextStyles.price.copyWith(color: priceColor),
                ),
                const SizedBox(height: 2),
                Text(
                  '$sign${stock.priceChange.toStringAsFixed(2)} ($sign${stock.percentChange.toStringAsFixed(2)}%)',
                  style: AppTextStyles.priceChange.copyWith(color: priceColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatPrice(double price) {
    final fixed = price.toStringAsFixed(2);
    final dot = fixed.indexOf('.');
    final intPart = fixed.substring(0, dot);
    final decPart = fixed.substring(dot);
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i != 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '${buf.toString()}$decPart';
  }
}
