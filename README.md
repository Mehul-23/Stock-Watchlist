# 021Trade â€“ Watchlist Assignment

A Flutter application replicating the stock watchlist experience of **021Trade**, built with the **BLoC architecture pattern**. Supports drag-to-reorder, live search, a dedicated edit screen, and a delete-confirmation dialog.

---

## Features

| Feature | Detail |
|---|---|
| **Watchlist screen** | Market ticker bar, search bar, watchlist tab strip, flat stock list |
| **Live search** | Filters stocks by symbol or name on every keystroke; shows a "no results" state |
| **Edit Watchlist screen** | Separate screen with editable watchlist name, drag handles, and delete icons |
| **Drag-to-reorder** | `â‰¡` handle triggers `ReorderableDragStartListener`; order persisted in BLoC |
| **Delete with confirmation** | Tapping the trash icon shows an `AlertDialog`; stock removed only on confirm |
| **Light theme** | Matches the 021Trade reference UI â€” white background, coloured price ticks |
| **BLoC state management** | Full event â†’ state cycle with `sealed` classes and `Equatable` |
| **Loading / error / empty states** | Spinner on load, retry on error, friendly empty & no-results views |
| **Bottom navigation bar** | Watchlist, Orders, GTT+, Portfolio, Funds, Profile tabs |

---

## Project Structure

```
lib/
â”œâ”€â”€ main.dart                              # Entry point â€“ calls runApp
â”œâ”€â”€ app.dart                               # MaterialApp + BlocProvider wiring
â”‚
â”œâ”€â”€ core/
â”‚   â””â”€â”€ theme/
â”‚       â”œâ”€â”€ app_colors.dart                # Centralised colour palette (light theme)
â”‚       â”œâ”€â”€ app_text_styles.dart           # All TextStyle constants
â”‚       â””â”€â”€ app_theme.dart                 # ThemeData factory (light theme)
â”‚
â”œâ”€â”€ data/
â”‚   â”œâ”€â”€ models/
â”‚   â”‚   â””â”€â”€ stock.dart                     # Immutable Stock value object (Equatable)
â”‚   â””â”€â”€ repositories/
â”‚       â””â”€â”€ watchlist_repository.dart      # 10 NSE stocks, async loadWatchlist()
â”‚
â””â”€â”€ features/
    â””â”€â”€ watchlist/
        â”œâ”€â”€ bloc/
        â”‚   â”œâ”€â”€ watchlist_event.dart       # LoadWatchlist | ReorderStock | RemoveStock | SearchWatchlist
        â”‚   â”œâ”€â”€ watchlist_state.dart       # Initial | Loading | Loaded (+ filteredStocks) | Error
        â”‚   â””â”€â”€ watchlist_bloc.dart        # All business logic handlers
        â”œâ”€â”€ screens/
        â”‚   â”œâ”€â”€ watchlist_screen.dart      # Main screen: ticker bar, search, tabs, stock list, bottom nav
        â”‚   â””â”€â”€ edit_watchlist_screen.dart # Edit screen: name field, reorderable list, delete dialog, save bar
        â””â”€â”€ widgets/
            â””â”€â”€ stock_row.dart             # Flat stock row: symbol/exchange left, price/change right
```

---

## Screens

### Watchlist Screen
- **Market ticker bar** â€” SENSEX and NIFTY BANK with live-style price/change display
- **Search bar** â€” real `TextField` that dispatches `SearchWatchlist` on every keystroke; shows an Ã— clear button when text is present
- **Tab strip** â€” scrollable tabs (Watchlist 1, Watchlist 5, Watchlist 6) with a blue underline indicator
- **Sort by / Edit row** â€” sort placeholder button on the left; **Edit** button on the right navigates to `EditWatchlistScreen`
- **Stock list** â€” `ListView` of `StockRow` tiles separated by hairline dividers
- **Bottom nav bar** â€” six tabs matching the 021Trade reference

### Edit Watchlist Screen
- **AppBar** â€” back arrow + "Edit Watchlist 1" title
- **Name field** â€” editable `TextField` pre-filled with the watchlist name + pencil icon
- **Reorderable list** â€” `ReorderableListView` with `buildDefaultDragHandles: false`; each row has a `â‰¡` drag handle and a ðŸ—‘ delete icon
- **Delete confirmation dialog** â€” `AlertDialog` asking "Are you sure you want to remove SYMBOL?" with **Cancel** and red **Remove** buttons
- **"Edit other watchlists"** â€” secondary action button
- **Save Watchlist** â€” fixed bottom bar; tapping pops the screen

---

## Architecture â€“ BLoC

```
UI (WatchlistScreen / EditWatchlistScreen)
           â”‚  dispatches events
           â–¼
    WatchlistBloc  â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ WatchlistRepository
           â”‚  emits states           (async data source)
           â–¼
    WatchlistState  â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–º  BlocBuilder rebuilds UI
```

### Events

| Event | Trigger | Payload |
|---|---|---|
| `LoadWatchlist` | App start | â€” |
| `ReorderStock` | Drag ends | `oldIndex`, `newIndex` |
| `RemoveStock` | Confirm delete dialog | `stockId` |
| `SearchWatchlist` | Search field `onChanged` | `query` |

### States

| State | When |
|---|---|
| `WatchlistInitial` | Before any event |
| `WatchlistLoading` | While `loadWatchlist()` is in-flight |
| `WatchlistLoaded` | Data ready; reorder / remove / search also emit this |
| `WatchlistError` | Exception thrown by repository |

`WatchlistLoaded` stores both the **full** `stocks` list (source of truth) and the current `searchQuery`. The `filteredStocks` getter filters in memory â€” the underlying list is never mutated by a search.

---

## Key Implementation Details

### Live Search
```dart
// WatchlistLoaded state
List<Stock> get filteredStocks {
  if (searchQuery.isEmpty) return stocks;
  final q = searchQuery.toLowerCase();
  return stocks
      .where((s) =>
          s.symbol.toLowerCase().contains(q) ||
          s.name.toLowerCase().contains(q))
      .toList();
}
```

### Reorder Off-by-One Fix
Flutter's `ReorderableListView` passes a `newIndex` calculated *before* the item is removed. When dragging downward the index is one too high â€” normalised in the bloc:
```dart
final normalised =
    event.newIndex > event.oldIndex ? event.newIndex - 1 : event.newIndex;
final stock = stocks.removeAt(event.oldIndex);
stocks.insert(normalised, stock);
```

### Delete Confirmation
```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (ctx) => AlertDialog( ... ),
);
if (confirmed == true && context.mounted) {
  context.read<WatchlistBloc>().add(RemoveStock(stockId: stockId));
}
```
`context.mounted` guard prevents acting on a disposed widget after the `await`.

### Design Decisions
- **`sealed` classes** â€” exhaustive `switch` expressions enforced at compile time; no missed state.
- **`final class`** â€” Bloc, events, states, repository, and model are all `final` to prevent unintended subclassing.
- **No `setState` anywhere** â€” all mutable state lives exclusively in `WatchlistBloc`.
- **Single-responsibility widgets** â€” screens contain no business logic; they only map BLoC states to private sub-widget classes.
- **Light theme** â€” `ColorScheme.light` with a blue primary (`#387ED1`), green gain (`#1DB954`), and red loss (`#E84040`) matching the reference screenshots.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^8.1.6 | BLoC / Cubit state management |
| `equatable` | ^2.0.5 | Value-equality for events and states |

---

## Running the App

```bash
# Clone the repository
git clone https://github.com/Mehul-23/Stock-Watchlist.git
cd Stock-Watchlist

# Get packages
flutter pub get

# Run (choose a target)
flutter run                      # default connected device
flutter run -d windows           # Windows desktop
flutter run -d chrome            # Web
```

Minimum Flutter version: **3.22** (Dart 3.4+).

---

## Branches

| Branch | Purpose |
|---|---|
| `main` | Initial working implementation |
| `bug_fixes` | UI refinements, search, edit screen, delete confirmation dialog |

---

## Sample Data

Ten NSE-listed equities are pre-loaded in `WatchlistRepository`:

| Symbol | Company |
|---|---|
| RELIANCE | Reliance Industries Ltd. |
| TCS | Tata Consultancy Services |
| HDFCBANK | HDFC Bank Ltd. |
| INFY | Infosys Ltd. |
| ICICIBANK | ICICI Bank Ltd. |
| BAJFINANCE | Bajaj Finance Ltd. |
| SBIN | State Bank of India |
| WIPRO | Wipro Ltd. |
| ADANIENT | Adani Enterprises Ltd. |
| TATAMOTORS | Tata Motors Ltd. |

Prices and changes are static sample values; in a production app the repository layer would be swapped for a real-time market data API.



