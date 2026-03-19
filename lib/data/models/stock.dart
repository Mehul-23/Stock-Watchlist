import 'package:equatable/equatable.dart';

/// Immutable value object representing a single stock entry in the watchlist.
final class Stock extends Equatable {
  final String id;
  final String symbol;
  final String name;
  final String exchange;

  /// Current trading price in INR (₹).
  final double currentPrice;

  /// Absolute price change from the previous closing price.
  final double priceChange;

  /// Percentage change from the previous closing price.
  final double percentChange;

  /// Today's traded volume (number of shares).
  final double volume;

  /// Market capitalisation in crores (₹).
  final double marketCap;

  /// 52-week high price.
  final double high52w;

  /// 52-week low price.
  final double low52w;

  const Stock({
    required this.id,
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.currentPrice,
    required this.priceChange,
    required this.percentChange,
    required this.volume,
    required this.marketCap,
    required this.high52w,
    required this.low52w,
  });

  /// Returns `true` when the stock has gained value since previous close.
  bool get isPositive => priceChange >= 0;

  Stock copyWith({
    String? id,
    String? symbol,
    String? name,
    String? exchange,
    double? currentPrice,
    double? priceChange,
    double? percentChange,
    double? volume,
    double? marketCap,
    double? high52w,
    double? low52w,
  }) {
    return Stock(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      exchange: exchange ?? this.exchange,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange: priceChange ?? this.priceChange,
      percentChange: percentChange ?? this.percentChange,
      volume: volume ?? this.volume,
      marketCap: marketCap ?? this.marketCap,
      high52w: high52w ?? this.high52w,
      low52w: low52w ?? this.low52w,
    );
  }

  @override
  List<Object?> get props => [
        id,
        symbol,
        name,
        exchange,
        currentPrice,
        priceChange,
        percentChange,
        volume,
        marketCap,
        high52w,
        low52w,
      ];
}
