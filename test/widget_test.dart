import 'package:flutter_test/flutter_test.dart';
import 'package:watchlist_app/app.dart';

void main() {
  testWidgets('WatchlistApp renders without crashing', (tester) async {
    await tester.pumpWidget(const WatchlistApp());
    // Loading state should be present initially.
    expect(find.text('Loading watchlist…'), findsOneWidget);
  });
}
