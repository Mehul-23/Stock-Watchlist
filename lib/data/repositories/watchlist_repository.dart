import 'package:shared_preferences/shared_preferences.dart';

import '../models/stock.dart';

/// Provides watchlist data and persists the user's ordering/deletions locally.
///
/// **Design note -- replaceable layer**
/// This class is the single point of contact between the BLoC and the data
/// source. Swapping it for a live implementation (REST polling, WebSocket
/// stream, gRPC, etc.) requires no changes to the BLoC or UI layers -- only
/// this class needs to be updated. The public API surface is intentionally
/// minimal:
///   * [loadWatchlist]  -- fetch ordered stock list (async, may throw)
///   * [saveOrder]      -- persist user-defined order / deletions
///
/// Declared as `interface class` so it can be implemented (e.g. mocked in
/// tests) but not extended with extra concrete behaviour outside this library.
///
/// **Simulated network behaviour**
/// [loadWatchlist] honours two constructor flags so the app can be demoed in
/// different conditions without changing any other code:
///   * [networkDelayMs] -- simulates REST/WebSocket latency (default 800 ms)
///   * [simulateError]  -- when true, throws an exception to exercise the
///                         BLoC error state and the UI retry flow
interface class WatchlistRepository {
  /// Simulated network latency in milliseconds.
  final int networkDelayMs;

  /// When true [loadWatchlist] throws, exercising the error state / retry UI.
  final bool simulateError;

  const WatchlistRepository({
    this.networkDelayMs = 800,
    this.simulateError = false,
  });

  static const String _orderKey = 'watchlist_order';

  static const List<Stock> _sampleStocks = [
    Stock(
      id: '1',
      symbol: 'RELIANCE',
      name: 'Reliance Industries Ltd.',
      exchange: 'NSE',
      currentPrice: 2943.55,
      priceChange: 45.30,
      percentChange: 1.56,
      volume: 8250000,
      marketCap: 1992340,
      high52w: 3217.90,
      low52w: 2220.30,
    ),
    Stock(
      id: '2',
      symbol: 'TCS',
      name: 'Tata Consultancy Services',
      exchange: 'NSE',
      currentPrice: 3512.40,
      priceChange: -28.75,
      percentChange: -0.81,
      volume: 3180000,
      marketCap: 1281200,
      high52w: 4592.25,
      low52w: 3311.00,
    ),
    Stock(
      id: '3',
      symbol: 'HDFCBANK',
      name: 'HDFC Bank Ltd.',
      exchange: 'NSE',
      currentPrice: 1723.85,
      priceChange: 12.60,
      percentChange: 0.74,
      volume: 12450000,
      marketCap: 1312540,
      high52w: 1880.00,
      low52w: 1363.50,
    ),
    Stock(
      id: '4',
      symbol: 'INFY',
      name: 'Infosys Ltd.',
      exchange: 'NSE',
      currentPrice: 1458.20,
      priceChange: -19.40,
      percentChange: -1.31,
      volume: 7820000,
      marketCap: 608970,
      high52w: 2006.45,
      low52w: 1358.35,
    ),
    Stock(
      id: '5',
      symbol: 'ICICIBANK',
      name: 'ICICI Bank Ltd.',
      exchange: 'NSE',
      currentPrice: 1265.10,
      priceChange: 23.85,
      percentChange: 1.92,
      volume: 11200000,
      marketCap: 889320,
      high52w: 1362.35,
      low52w: 970.15,
    ),
    Stock(
      id: '6',
      symbol: 'BAJFINANCE',
      name: 'Bajaj Finance Ltd.',
      exchange: 'NSE',
      currentPrice: 7285.00,
      priceChange: -112.55,
      percentChange: -1.52,
      volume: 1850000,
      marketCap: 439870,
      high52w: 8192.00,
      low52w: 6187.80,
    ),
    Stock(
      id: '7',
      symbol: 'SBIN',
      name: 'State Bank of India',
      exchange: 'NSE',
      currentPrice: 812.45,
      priceChange: 8.30,
      percentChange: 1.03,
      volume: 24600000,
      marketCap: 725410,
      high52w: 912.10,
      low52w: 680.50,
    ),
    Stock(
      id: '8',
      symbol: 'WIPRO',
      name: 'Wipro Ltd.',
      exchange: 'NSE',
      currentPrice: 462.30,
      priceChange: -5.75,
      percentChange: -1.23,
      volume: 6750000,
      marketCap: 241870,
      high52w: 571.30,
      low52w: 432.70,
    ),
    Stock(
      id: '9',
      symbol: 'ADANIENT',
      name: 'Adani Enterprises Ltd.',
      exchange: 'NSE',
      currentPrice: 2342.60,
      priceChange: 67.40,
      percentChange: 2.96,
      volume: 4120000,
      marketCap: 266810,
      high52w: 3743.90,
      low52w: 1820.75,
    ),
    Stock(
      id: '10',
      symbol: 'TATAMOTORS',
      name: 'Tata Motors Ltd.',
      exchange: 'NSE',
      currentPrice: 943.75,
      priceChange: -14.20,
      percentChange: -1.48,
      volume: 9340000,
      marketCap: 347180,
      high52w: 1179.05,
      low52w: 754.20,
    ),
  ];

  /// Loads the watchlist, restoring the user's last saved order and deletions.
  ///
  /// Simulates [networkDelayMs] of latency to mirror a real network call.
  /// Throws a [Exception] when [simulateError] is true so the BLoC error
  /// state and the UI retry button can be exercised without a live backend.
  ///
  /// **To swap in a real API:** replace the body of this method with an HTTP
  /// GET (or WebSocket subscription) call that returns `List<Stock>`. The
  /// BLoC and UI layers require zero changes.
  Future<List<Stock>> loadWatchlist() async {
    await Future.delayed(Duration(milliseconds: networkDelayMs));

    if (simulateError) {
      throw Exception(
        'Failed to load watchlist. Check your network connection and try again.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_orderKey);

    // No saved state yet -- return default order.
    if (savedIds == null) return List.of(_sampleStocks);

    // Reconstruct the list in saved order, skipping deleted stocks.
    final stockMap = {for (final s in _sampleStocks) s.id: s};
    return savedIds.map((id) => stockMap[id]).whereType<Stock>().toList();
  }

  /// Persists [stockIds] as the current watchlist order.
  ///
  /// Call this after every reorder or remove operation so the state survives
  /// app restarts.
  Future<void> saveOrder(List<String> stockIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_orderKey, stockIds);
  }
}
