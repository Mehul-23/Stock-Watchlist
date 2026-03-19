import 'package:equatable/equatable.dart';

/// Base class for all events dispatched to [WatchlistBloc].
sealed class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers initial data load from the repository.
final class LoadWatchlist extends WatchlistEvent {
  const LoadWatchlist();
}

/// Moves a stock tile from [oldIndex] to [newIndex].
///
/// The indices correspond to the list as rendered by [ReorderableListView].
/// The bloc handles the off-by-one correction internally.
final class ReorderStock extends WatchlistEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderStock({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

/// Removes the stock identified by [stockId] from the watchlist.
final class RemoveStock extends WatchlistEvent {
  final String stockId;

  const RemoveStock({required this.stockId});

  @override
  List<Object?> get props => [stockId];
}

/// Filters the visible stock list by [query].
/// An empty query clears the filter and shows all stocks.
final class SearchWatchlist extends WatchlistEvent {
  final String query;

  const SearchWatchlist({required this.query});

  @override
  List<Object?> get props => [query];
}
