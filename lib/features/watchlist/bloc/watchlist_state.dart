import 'package:equatable/equatable.dart';

import '../../../data/models/stock.dart';

/// Base class for all states emitted by [WatchlistBloc].
sealed class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any event has been processed.
final class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();
}

/// Emitted while the watchlist data is being fetched.
final class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

/// Emitted when data has been successfully loaded or the order has changed.
final class WatchlistLoaded extends WatchlistState {
  /// The full, unfiltered list of stocks (source of truth).
  final List<Stock> stocks;

  /// Current search query. Empty string means no filter.
  final String searchQuery;

  const WatchlistLoaded({
    required this.stocks,
    this.searchQuery = '',
  });

  /// Returns stocks that match [searchQuery] (symbol or name, case-insensitive).
  /// Returns all stocks when the query is empty.
  List<Stock> get filteredStocks {
    if (searchQuery.isEmpty) return stocks;
    final q = searchQuery.toLowerCase();
    return stocks
        .where((s) =>
            s.symbol.toLowerCase().contains(q) ||
            s.name.toLowerCase().contains(q))
        .toList();
  }

  WatchlistLoaded copyWith({List<Stock>? stocks, String? searchQuery}) =>
      WatchlistLoaded(
        stocks: stocks ?? this.stocks,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props => [stocks, searchQuery];
}

/// Emitted when an error occurs during data loading.
final class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError({required this.message});

  @override
  List<Object?> get props => [message];
}
