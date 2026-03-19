# 021Trade – Watchlist Assignment

A Flutter application showcasing a stock watchlist with **drag-to-reorder** and **swipe-to-remove** functionality, built with the **BLoC architecture pattern**.

---

## Features

| Feature | Detail |
|---|---|
| Drag-to-reorder | Long-press (or drag) the `≡` handle to move stocks up or down |
| Swipe-to-remove | Swipe a tile left to dismiss and remove a stock from the list |
| BLoC state management | Full event → state cycle with sealed classes |
| Dark trading terminal UI | 021Trade-branded dark theme with green/red gain/loss indicators |
| Loading & error states | Spinner while data loads; retry button on failure |
| Empty state | Friendly empty view when all stocks are removed |

---

## Project Structure

```
lib/
├── main.dart                          # Entry point – calls runApp
├── app.dart                           # MaterialApp + BlocProvider wiring
│
├── core/
│   └── theme/
│       ├── app_colors.dart            # Centralised colour palette
│       ├── app_text_styles.dart       # All TextStyle constants
│       └── app_theme.dart             # ThemeData factory (dark theme)
│
├── data/
│   ├── models/
│   │   └── stock.dart                 # Immutable Stock value object (Equatable)
│   └── repositories/
│       └── watchlist_repository.dart  # Sample data + async loadWatchlist()
│
└── features/
    └── watchlist/
        ├── bloc/
        │   ├── watchlist_event.dart   # LoadWatchlist | ReorderStock | RemoveStock
        │   ├── watchlist_state.dart   # WatchlistInitial | Loading | Loaded | Error
        │   └── watchlist_bloc.dart    # Business logic handler
        ├── screens/
        │   └── watchlist_screen.dart  # Root screen; delegates to state sub-widgets
        └── widgets/
            ├── stock_tile.dart        # Single stock row with drag handle + change pill
            └── watchlist_header.dart  # Title, stock count, and reorder hint
```

---

## Architecture – BLoC

```
UI (WatchlistScreen)
       │  dispatches
       ▼
WatchlistBloc  ──────────── WatchlistRepository
       │  emits                   (async data source)
       ▼
WatchlistState  ──────────►  BlocBuilder rebuilds UI
```

### Events

| Event | Trigger | Payload |
|---|---|---|
| `LoadWatchlist` | App start | — |
| `ReorderStock` | Drag gesture ends | `oldIndex`, `newIndex` |
| `RemoveStock` | Swipe-dismiss | `stockId` |

### States

| State | When |
|---|---|
| `WatchlistInitial` | Before any event |
| `WatchlistLoading` | While `loadWatchlist()` is in-flight |
| `WatchlistLoaded` | Data ready; list reorder also emits this |
| `WatchlistError` | Exception thrown by repository |

All events and states extend `Equatable` to guarantee value-equality-based comparisons, preventing spurious rebuilds.

---

## Reorder Logic

Flutter's `ReorderableListView` passes a `newIndex` that accounts for the item's old position *before* removal, so when the item moves downward the index is one too high. The bloc normalises this:

```dart
final normalised =
    event.newIndex > event.oldIndex ? event.newIndex - 1 : event.newIndex;

final stock = stocks.removeAt(event.oldIndex);
stocks.insert(normalised, stock);
```

`buildDefaultDragHandles: false` is set on the list so the custom `ReorderableDragStartListener` drag-handle inside each `StockTile` is used instead of the default trailing icon.

---

## Design Decisions

- **Sealed classes** — `WatchlistEvent` and `WatchlistState` are `sealed`, enabling exhaustive `switch` expressions that the Dart type-checker enforces at compile time.
- **`final class`** — Bloc, events, states, the repository, and the model are all `final` to prevent unintended subclassing.
- **No `setState` anywhere** — All mutable state lives exclusively in `WatchlistBloc`; widgets are purely reactive.
- **Single-responsibility widgets** — `WatchlistScreen` contains no business logic; it only maps states to sub-widget classes (`_LoadingView`, `_LoadedView`, `_EmptyView`, `_ErrorView`).
- **Colour-coded avatars** — Stock initials are displayed in a circle whose colour is deterministically derived from the symbol's character codes, so the same stock always gets the same colour.
- **Custom proxy decorator** — The tile being dragged scales up by 1.5 % and gains an elevation shadow for tactile feedback without third-party animation libraries.
- **`Dismissible` + `ReorderableListView`** — Horizontal swipe (Dismissible) and vertical drag (ReorderableListView) coexist cleanly because the gesture recognisers do not conflict.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^8.1.6 | BLoC / Cubit state management |
| `equatable` | ^2.0.5 | Value-equality for events and states |

Both packages are pinned to stable, well-tested versions compatible with the project's Dart SDK constraint (`^3.11.1`).

---

## Running the App

```bash
# Clone the repository
git clone <repo-url>
cd watchlist_app

# Get packages
flutter pub get

# Run (choose a target)
flutter run                      # default device
flutter run -d windows           # Windows desktop
flutter run -d chrome            # Web
```

Minimum Flutter version: **3.22** (Dart 3.4+).

---

## Sample Data

Ten NSE-listed equities are pre-loaded:

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

