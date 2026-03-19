# 021Trade - Watchlist Assignment

A Flutter application replicating the stock watchlist experience of **021Trade**,
built with the **BLoC architecture pattern**. Supports drag-to-reorder, live
search, a dedicated edit screen, and a delete-confirmation dialog.

---

## Features

| Feature                    | Detail                                                                     |
|----------------------------|----------------------------------------------------------------------------|
| **Watchlist screen**       | Market ticker bar, search bar, watchlist tab strip, flat stock list        |
| **Live search**            | Filters stocks by symbol or name on every keystroke; shows a no-results state |
| **Edit Watchlist screen**  | Separate screen with editable watchlist name, drag handles, and delete icons |
| **Drag-to-reorder**        | Hamburger (=) handle triggers ReorderableDragStartListener; order persisted in BLoC |
| **Delete with confirmation** | Tapping the trash icon shows an AlertDialog; stock removed only on confirm |
| **Light theme**            | Matches the 021Trade reference UI -- white background, coloured price ticks |
| **BLoC state management**  | Full event -> state cycle with sealed classes and Equatable               |
| **Loading / error / empty states** | Spinner on load, retry on error, friendly empty and no-results views |
| **Bottom navigation bar**  | Watchlist, Orders, GTT+, Portfolio, Funds, Profile tabs                    |

---

## Project Structure

```
lib/
+-- main.dart                              # Entry point - calls runApp
+-- app.dart                               # MaterialApp + BlocProvider wiring
|
+-- core/
|   +-- theme/
|       +-- app_colors.dart                # Centralised colour palette (light theme)
|       +-- app_text_styles.dart           # All TextStyle constants
|       \-- app_theme.dart                 # ThemeData factory (light theme)
|
+-- data/
|   +-- models/
|   |   \-- stock.dart                     # Immutable Stock value object (Equatable)
|   \-- repositories/
|       \-- watchlist_repository.dart      # 10 NSE stocks, async loadWatchlist()
|
\-- features/
    \-- watchlist/
        +-- bloc/
        |   +-- watchlist_event.dart       # LoadWatchlist | ReorderStock | RemoveStock | SearchWatchlist
        |   +-- watchlist_state.dart       # Initial | Loading | Loaded (+ filteredStocks) | Error
        |   \-- watchlist_bloc.dart        # All business logic handlers
        +-- screens/
        |   +-- watchlist_screen.dart      # Main screen: ticker bar, search, tabs, stock list, bottom nav
        |   \-- edit_watchlist_screen.dart # Edit screen: name field, reorderable list, delete dialog, save bar
        \-- widgets/
            \-- stock_row.dart             # Flat stock row: symbol/exchange left, price/change right
```

---

## Screens

### Watchlist Screen
- **Market ticker bar** -- SENSEX and NIFTY BANK with live-style price/change display
- **Search bar** -- real TextField that dispatches SearchWatchlist on every keystroke;
  shows an x clear button when text is present
- **Tab strip** -- scrollable tabs (Watchlist 1, Watchlist 5, Watchlist 6) with a
  blue underline indicator
- **Sort by / Edit row** -- sort placeholder button on the left; **Edit** button on
  the right navigates to EditWatchlistScreen
- **Stock list** -- ListView of StockRow tiles separated by hairline dividers
- **Bottom nav bar** -- six tabs matching the 021Trade reference

### Edit Watchlist Screen
- **AppBar** -- back arrow + "Edit Watchlist 1" title
- **Name field** -- editable TextField pre-filled with the watchlist name + pencil icon
- **Reorderable list** -- ReorderableListView with buildDefaultDragHandles: false;
  each row has a (=) drag handle and a trash delete icon
- **Delete confirmation dialog** -- AlertDialog asking "Are you sure you want to
  remove SYMBOL?" with Cancel and red Remove buttons
- **"Edit other watchlists"** -- secondary action button
- **Save Watchlist** -- fixed bottom bar; tapping pops the screen

---

## Architecture - BLoC

```
UI (WatchlistScreen / EditWatchlistScreen)
        |
        |  dispatches events
        v
   WatchlistBloc ----------- WatchlistRepository
        |                       (async data source)
        |  emits states
        v
   WatchlistState ----------> BlocBuilder rebuilds UI
```

### Events

| Event            | Trigger                      | Payload                |
|------------------|------------------------------|------------------------|
| `LoadWatchlist`  | App start                    | --                     |
| `ReorderStock`   | Drag ends                    | `oldIndex`, `newIndex` |
| `RemoveStock`    | Confirm delete dialog        | `stockId`              |
| `SearchWatchlist`| Search field onChange        | `query`                |

### States

| State              | When                                           |
|--------------------|------------------------------------------------|
| `WatchlistInitial` | Before any event                               |
| `WatchlistLoading` | While `loadWatchlist()` is in-flight           |
| `WatchlistLoaded`  | Data ready; reorder / remove / search emit this|
| `WatchlistError`   | Exception thrown by repository                 |

`WatchlistLoaded` stores both the **full** `stocks` list (source of truth) and the
current `searchQuery`. The `filteredStocks` getter filters in memory -- the
underlying list is never mutated by a search.

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

Flutter's `ReorderableListView` passes a `newIndex` calculated *before* the item
is removed. When dragging downward the index is one too high -- normalised in
the bloc:

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

---

## Design Decisions

- **`sealed` classes** -- exhaustive `switch` expressions enforced at compile
  time; no missed state.
- **`final class`** -- Bloc, events, states, repository, and model are all
  `final` to prevent unintended subclassing.
- **No `setState` anywhere** -- all mutable state lives exclusively in
  `WatchlistBloc`.
- **Single-responsibility widgets** -- screens contain no business logic; they
  only map BLoC states to private sub-widget classes.
- **Light theme** -- `ColorScheme.light` with a blue primary (#387ED1), green
  gain (#1DB954), and red loss (#E84040) matching the reference screenshots.
- **Two-screen navigation** -- WatchlistScreen and EditWatchlistScreen are kept
  separate so the edit flow can be navigated into and out of cleanly.
- **`filteredStocks` computed getter** -- search never mutates the stocks list;
  the query is stored independently, making it trivial to clear.

---

## Dependencies

| Package        | Version  | Purpose                             |
|----------------|----------|-------------------------------------|
| `flutter_bloc` | ^8.1.6   | BLoC / Cubit state management       |
| `equatable`    | ^2.0.5   | Value-equality for events and states|

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

| Branch      | Purpose                                                                  |
|-------------|--------------------------------------------------------------------------|
| `main`      | Initial working implementation                                           |
| `bug_fixes` | UI refinements, search, edit screen, delete confirmation dialog, README  |

---

## Sample Data

Ten NSE-listed equities are pre-loaded in `WatchlistRepository`:

| Symbol      | Company                      |
|-------------|------------------------------|
| RELIANCE    | Reliance Industries Ltd.     |
| TCS         | Tata Consultancy Services    |
| HDFCBANK    | HDFC Bank Ltd.               |
| INFY        | Infosys Ltd.                 |
| ICICIBANK   | ICICI Bank Ltd.              |
| BAJFINANCE  | Bajaj Finance Ltd.           |
| SBIN        | State Bank of India          |
| WIPRO       | Wipro Ltd.                   |
| ADANIENT    | Adani Enterprises Ltd.       |
| TATAMOTORS  | Tata Motors Ltd.             |

Prices and changes are static sample values; in a production app the repository
layer would be swapped for a real-time market data API.



