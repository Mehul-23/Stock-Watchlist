import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:watchlist_app/data/models/stock.dart';
import 'package:watchlist_app/data/repositories/watchlist_repository.dart';
import 'package:watchlist_app/features/watchlist/bloc/watchlist_bloc.dart';
import 'package:watchlist_app/features/watchlist/bloc/watchlist_event.dart';
import 'package:watchlist_app/features/watchlist/bloc/watchlist_state.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _stockA = Stock(
  id: '1',
  symbol: 'AAA',
  name: 'Alpha Corp',
  exchange: 'NSE',
  currentPrice: 100.0,
  priceChange: 1.0,
  percentChange: 1.0,
  volume: 1000,
  marketCap: 50000,
  high52w: 120.0,
  low52w: 80.0,
);

const _stockB = Stock(
  id: '2',
  symbol: 'BBB',
  name: 'Beta Ltd',
  exchange: 'NSE',
  currentPrice: 200.0,
  priceChange: -2.0,
  percentChange: -1.0,
  volume: 2000,
  marketCap: 100000,
  high52w: 220.0,
  low52w: 170.0,
);

const _stockC = Stock(
  id: '3',
  symbol: 'CCC',
  name: 'Gamma Inc',
  exchange: 'NSE',
  currentPrice: 300.0,
  priceChange: 5.0,
  percentChange: 1.7,
  volume: 3000,
  marketCap: 150000,
  high52w: 350.0,
  low52w: 260.0,
);

final _threeStocks = [_stockA, _stockB, _stockC];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

WatchlistBloc _buildBloc(MockWatchlistRepository repo) =>
    WatchlistBloc(repository: repo);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockWatchlistRepository repo;

  setUp(() {
    repo = MockWatchlistRepository();
    // saveOrder is called after every mutation; stub it to do nothing.
    when(() => repo.saveOrder(any())).thenAnswer((_) async {});
  });

  // -------------------------------------------------------------------------
  // LoadWatchlist
  // -------------------------------------------------------------------------

  group('LoadWatchlist', () {
    blocTest<WatchlistBloc, WatchlistState>(
      'emits [Loading, Loaded] on success',
      setUp: () {
        when(() => repo.loadWatchlist())
            .thenAnswer((_) async => List.of(_threeStocks));
      },
      build: () => _buildBloc(repo),
      act: (bloc) => bloc.add(const LoadWatchlist()),
      expect: () => [
        const WatchlistLoading(),
        WatchlistLoaded(stocks: _threeStocks),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits [Loading, Error] when repository throws',
      setUp: () {
        when(() => repo.loadWatchlist()).thenThrow(Exception('network error'));
      },
      build: () => _buildBloc(repo),
      act: (bloc) => bloc.add(const LoadWatchlist()),
      expect: () => [
        const WatchlistLoading(),
        isA<WatchlistError>(),
      ],
    );
  });

  // -------------------------------------------------------------------------
  // ReorderStock
  // -------------------------------------------------------------------------

  group('ReorderStock', () {
    blocTest<WatchlistBloc, WatchlistState>(
      'moves stock downward: A B C -> B A C (oldIndex=0, newIndex=2)',
      build: () => _buildBloc(repo),
      seed: () => WatchlistLoaded(stocks: _threeStocks),
      act: (bloc) =>
          bloc.add(const ReorderStock(oldIndex: 0, newIndex: 2)),
      expect: () => [
        WatchlistLoaded(stocks: [_stockB, _stockA, _stockC]),
      ],
      verify: (_) {
        // Persists the new order after every reorder.
        verify(() => repo.saveOrder(['2', '1', '3'])).called(1);
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'moves stock upward: A B C -> A C B (oldIndex=2, newIndex=1)',
      build: () => _buildBloc(repo),
      seed: () => WatchlistLoaded(stocks: _threeStocks),
      act: (bloc) =>
          bloc.add(const ReorderStock(oldIndex: 2, newIndex: 1)),
      expect: () => [
        WatchlistLoaded(stocks: [_stockA, _stockC, _stockB]),
      ],
      verify: (_) {
        verify(() => repo.saveOrder(['1', '3', '2'])).called(1);
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'does nothing when state is not WatchlistLoaded',
      build: () => _buildBloc(repo),
      seed: () => const WatchlistLoading(),
      act: (bloc) =>
          bloc.add(const ReorderStock(oldIndex: 0, newIndex: 1)),
      expect: () => <WatchlistState>[],
    );
  });

  // -------------------------------------------------------------------------
  // RemoveStock
  // -------------------------------------------------------------------------

  group('RemoveStock', () {
    blocTest<WatchlistBloc, WatchlistState>(
      'removes the correct stock from the list',
      build: () => _buildBloc(repo),
      seed: () => WatchlistLoaded(stocks: _threeStocks),
      act: (bloc) => bloc.add(const RemoveStock(stockId: '2')),
      expect: () => [
        WatchlistLoaded(stocks: [_stockA, _stockC]),
      ],
      verify: (_) {
        // Persists updated order without the deleted stock.
        verify(() => repo.saveOrder(['1', '3'])).called(1);
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'removing non-existent id emits no new state (list unchanged)',
      build: () => _buildBloc(repo),
      seed: () => WatchlistLoaded(stocks: _threeStocks),
      act: (bloc) => bloc.add(const RemoveStock(stockId: 'NONE')),
      // flutter_bloc skips emission when new state == current state (Equatable).
      expect: () => <WatchlistState>[],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'does nothing when state is not WatchlistLoaded',
      build: () => _buildBloc(repo),
      seed: () => const WatchlistLoading(),
      act: (bloc) => bloc.add(const RemoveStock(stockId: '1')),
      expect: () => <WatchlistState>[],
    );
  });

  // -------------------------------------------------------------------------
  // SearchWatchlist
  // -------------------------------------------------------------------------

  group('SearchWatchlist', () {
    blocTest<WatchlistBloc, WatchlistState>(
      'updates searchQuery in state',
      build: () => _buildBloc(repo),
      seed: () => WatchlistLoaded(stocks: _threeStocks),
      act: (bloc) => bloc.add(const SearchWatchlist(query: 'alpha')),
      expect: () => [
        WatchlistLoaded(stocks: _threeStocks, searchQuery: 'alpha'),
      ],
    );

    test('filteredStocks returns matching stocks by symbol', () {
      final state = WatchlistLoaded(
        stocks: _threeStocks,
        searchQuery: 'BBB',
      );
      expect(state.filteredStocks, [_stockB]);
    });

    test('filteredStocks returns matching stocks by name (case-insensitive)',
        () {
      final state = WatchlistLoaded(
        stocks: _threeStocks,
        searchQuery: 'gamma',
      );
      expect(state.filteredStocks, [_stockC]);
    });

    test('filteredStocks returns all stocks for empty query', () {
      final state = WatchlistLoaded(stocks: _threeStocks);
      expect(state.filteredStocks, _threeStocks);
    });

    test('filteredStocks returns empty list when no match', () {
      final state = WatchlistLoaded(
        stocks: _threeStocks,
        searchQuery: 'ZZZNOMATCH',
      );
      expect(state.filteredStocks, isEmpty);
    });
  });
}
