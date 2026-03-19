import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/watchlist_repository.dart';
import 'features/watchlist/bloc/watchlist_bloc.dart';
import 'features/watchlist/bloc/watchlist_event.dart';
import 'features/watchlist/screens/watchlist_screen.dart';

/// Root widget. Provides the theme and wires the [WatchlistBloc] at the top
/// of the widget tree so all descendant widgets can access it.
class WatchlistApp extends StatelessWidget {
  const WatchlistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '021Trade',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: BlocProvider(
        create: (_) => WatchlistBloc(repository: WatchlistRepository())
          ..add(const LoadWatchlist()),
        child: const WatchlistScreen(),
      ),
    );
  }
}
