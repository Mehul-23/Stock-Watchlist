import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchlist_app/app.dart';

void main() {
  testWidgets('WatchlistApp renders without crashing', (tester) async {
    // Provide an empty SharedPreferences store so the plugin channel is
    // satisfied in the test environment (avoids MissingPluginException).
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const WatchlistApp());

    // The root MaterialApp should always be present regardless of BLoC state.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Drain the repository's simulated network delay so no pending timers
    // remain when the test ends (avoids "timer still pending" assertion).
    await tester.pump(const Duration(seconds: 1));
  });
}
