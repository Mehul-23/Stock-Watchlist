import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/watchlist_repository.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

/// Manages the watchlist state in response to [WatchlistEvent]s.
///
/// Responsibilities:
/// - Loading stock data from [WatchlistRepository].
/// - Reordering stocks when the user drags a tile to a new position.
/// - Removing a stock from the watchlist.
final class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistRepository repository;

  WatchlistBloc({required this.repository}) : super(const WatchlistInitial()) {
    on<LoadWatchlist>(_onLoadWatchlist);
    on<ReorderStock>(_onReorderStock);
    on<RemoveStock>(_onRemoveStock);
    on<SearchWatchlist>(_onSearchWatchlist);
  }

  Future<void> _onLoadWatchlist(
    LoadWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoading());
    try {
      final stocks = await repository.loadWatchlist();
      emit(WatchlistLoaded(stocks: stocks));
    } catch (e) {
      emit(WatchlistError(message: e.toString()));
    }
  }

  Future<void> _onReorderStock(
    ReorderStock event,
    Emitter<WatchlistState> emit,
  ) async {
    if (state is! WatchlistLoaded) return;

    final currentState = state as WatchlistLoaded;
    final stocks = List.of(currentState.stocks);

    // Flutter's ReorderableListView passes `newIndex` calculated before the
    // item is removed from `oldIndex`. When moving downward the index is
    // therefore one too high -- subtract 1 to normalise.
    final normalised =
        event.newIndex > event.oldIndex ? event.newIndex - 1 : event.newIndex;

    final stock = stocks.removeAt(event.oldIndex);
    stocks.insert(normalised, stock);

    emit(currentState.copyWith(stocks: stocks));
    await repository.saveOrder(stocks.map((s) => s.id).toList());
  }

  Future<void> _onRemoveStock(
    RemoveStock event,
    Emitter<WatchlistState> emit,
  ) async {
    if (state is! WatchlistLoaded) return;

    final currentState = state as WatchlistLoaded;
    final updated =
        currentState.stocks.where((s) => s.id != event.stockId).toList();

    emit(currentState.copyWith(stocks: updated));
    await repository.saveOrder(updated.map((s) => s.id).toList());
  }

  void _onSearchWatchlist(
    SearchWatchlist event,
    Emitter<WatchlistState> emit,
  ) {
    if (state is! WatchlistLoaded) return;
    emit((state as WatchlistLoaded).copyWith(searchQuery: event.query));
  }
}
