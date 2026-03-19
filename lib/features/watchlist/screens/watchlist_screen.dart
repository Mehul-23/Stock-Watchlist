import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/stock.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';
import '../widgets/stock_row.dart';
import 'edit_watchlist_screen.dart';

/// Main watchlist screen – matches the 021Trade reference UI.
/// Layout: market ticker bar → search bar → watchlist tabs → stock list.
class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<String> _tabs = [
    'Watchlist 1',
    'Watchlist 5',
    'Watchlist 6',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const _MarketTickerBar(),
          const _Searchbar(),
          _WatchlistTabBar(controller: _tabController, tabs: _tabs),
          const Divider(height: 0, thickness: 0.8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((t) {
                if (t == 'Watchlist 1') return const _WatchlistTabBody();
                return _EmptyTabBody(label: t);
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: const Text(
              '021',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Trade',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.person_outline_rounded,
              color: AppColors.textSecondary, size: 22),
        ),
      ],
    );
  }
}

// ─── Market Ticker Bar ────────────────────────────────────────────────────────

class _MarketTickerBar extends StatelessWidget {
  const _MarketTickerBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.tickerBg,
      child: Row(
        children: [
          Expanded(
            child: _TickerItem(
              name: 'SENSEX 18TH SEP 8…',
              exchange: 'BSE',
              price: 1225.55,
              change: 144.50,
              pct: 13.3,
            ),
          ),
          Container(width: 0.8, height: 48, color: AppColors.tickerBorder),
          Expanded(
            child: _TickerItem(
              name: 'NIFTY BANK',
              exchange: '',
              price: 54172.85,
              change: -14.05,
              pct: -0.03,
            ),
          ),
          Container(
            width: 32,
            height: 48,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.tickerBorder, width: 0.8),
              ),
            ),
            child: const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TickerItem extends StatelessWidget {
  final String name;
  final String exchange;
  final double price;
  final double change;
  final double pct;

  const _TickerItem({
    required this.name,
    required this.exchange,
    required this.price,
    required this.change,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    final isPos = change >= 0;
    final color = isPos ? AppColors.gain : AppColors.loss;
    final sign = isPos ? '+' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(name, style: AppTextStyles.tickerIndex),
              if (exchange.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  exchange,
                  style: AppTextStyles.tickerIndex.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 1),
          Wrap(
            children: [
              Text(price.toStringAsFixed(2),
                  style: AppTextStyles.tickerValue),
              const SizedBox(width: 4),
              Text(
                '$sign${change.toStringAsFixed(2)} ($sign${pct.toStringAsFixed(2)}%)',
                style: AppTextStyles.tickerChange.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _Searchbar extends StatefulWidget {
  const _Searchbar();

  @override
  State<_Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<_Searchbar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    context.read<WatchlistBloc>().add(SearchWatchlist(query: query.trim()));
    setState(() {}); // refresh clear button visibility
  }

  void _onClear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;
    return Container(
      height: 40,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.strokeSubtle, width: 0.8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search_rounded,
              size: 17, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search for instruments',
                hintStyle: AppTextStyles.hint,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
            ),
          ),
          if (hasText)
            GestureDetector(
              onTap: _onClear,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.close_rounded,
                    size: 16, color: AppColors.textTertiary),
              ),
            )
          else
            const SizedBox(width: 10),
        ],
      ),
    );
  }
}

// ─── Tab Bar ──────────────────────────────────────────────────────────────────

class _WatchlistTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const _WatchlistTabBar({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelStyle: AppTextStyles.tabActive,
        unselectedLabelStyle: AppTextStyles.tabInactive,
        labelColor: AppColors.tabActive,
        unselectedLabelColor: AppColors.tabInactive,
        indicatorColor: AppColors.tabIndicator,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: tabs.map((t) => Tab(text: t, height: 38)).toList(),
      ),
    );
  }
}

// ─── Tab Body ─────────────────────────────────────────────────────────────────

class _WatchlistTabBody extends StatelessWidget {
  const _WatchlistTabBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) => switch (state) {
        WatchlistInitial() || WatchlistLoading() => const _LoadingView(),
        WatchlistLoaded(:final filteredStocks, :final searchQuery) =>
          _StockListView(stocks: filteredStocks, query: searchQuery),
        WatchlistError(:final message) => _ErrorView(
            message: message,
            onRetry: () =>
                context.read<WatchlistBloc>().add(const LoadWatchlist()),
          ),
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        strokeWidth: 2,
      ),
    );
  }
}

class _StockListView extends StatelessWidget {
  final List<Stock> stocks;
  final String query;

  const _StockListView({required this.stocks, this.query = ''});

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty && query.isNotEmpty) {
      return _NoResultsView(query: query);
    }
    if (stocks.isEmpty) return const _EmptyListView();

    return Column(
      children: [
        // Filter / edit row
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
          child: Row(
            children: [
              // Sort by button
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sort_rounded,
                    size: 13, color: AppColors.textSecondary),
                label: const Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  side: const BorderSide(
                      color: AppColors.strokeSubtle, width: 0.8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  final bloc = context.read<WatchlistBloc>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: const EditWatchlistScreen(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined,
                    size: 14, color: AppColors.primary),
                label: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 0, thickness: 0.8),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: stocks.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 0, thickness: 0.8),
            itemBuilder: (context, index) =>
                StockRow(stock: stocks[index]),
          ),
        ),
      ],
    );
  }
}

class _EmptyListView extends StatelessWidget {
  const _EmptyListView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded,
              size: 56, color: AppColors.textTertiary),
          SizedBox(height: 12),
          Text('Watchlist is empty', style: AppTextStyles.sectionTitle),
          SizedBox(height: 6),
          Text('Add stocks to start tracking them here.',
              style: AppTextStyles.hint),
        ],
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  final String query;

  const _NoResultsView({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 56, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          const Text('No results found', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 6),
          Text(
            'No instruments match "$query"',
            style: AppTextStyles.hint,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyTabBody extends StatelessWidget {
  final String label;

  const _EmptyTabBody({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$label is empty', style: AppTextStyles.bodyMedium),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.loss),
            const SizedBox(height: 12),
            const Text('Something went wrong',
                style: AppTextStyles.sectionTitle),
            const SizedBox(height: 6),
            Text(message,
                style: AppTextStyles.hint, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bottomNavBg,
        border:
            Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _NavItem(
                icon: Icons.bookmark_outlined,
                label: 'Watchlist',
                selected: true,
              ),
              _NavItem(icon: Icons.receipt_long_outlined, label: 'Orders'),
              _NavItem(icon: Icons.bolt_outlined, label: 'GTT+'),
              _NavItem(
                  icon: Icons.pie_chart_outline_rounded, label: 'Portfolio'),
              _NavItem(
                  icon: Icons.account_balance_wallet_outlined, label: 'Funds'),
              _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem(
      {required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.bottomNavSelected
        : AppColors.bottomNavUnselected;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }
}
