import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/stock.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';

/// Edit-watchlist screen matching the 021Trade reference UI.
///
/// Features:
/// - Editable watchlist name field at the top.
/// - [ReorderableListView] with `≡` drag handles on the left.
/// - Trash-bin delete icons on the right.
/// - "Edit other watchlists" secondary action button.
/// - "Save Watchlist" fixed bottom bar.
class EditWatchlistScreen extends StatefulWidget {
  const EditWatchlistScreen({super.key});

  @override
  State<EditWatchlistScreen> createState() => _EditWatchlistScreenState();
}

class _EditWatchlistScreenState extends State<EditWatchlistScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Watchlist 1');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.editBg,
      appBar: _buildAppBar(context),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state is! WatchlistLoaded) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 2,
              ),
            );
          }
          return _EditBody(
            stocks: state.stocks,
            nameController: _nameController,
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 48,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textPrimary, size: 22),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: const Text(
        'Edit Watchlist 1',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ─── Edit Body ────────────────────────────────────────────────────────────────

class _EditBody extends StatelessWidget {
  final List<Stock> stocks;
  final TextEditingController nameController;

  const _EditBody({required this.stocks, required this.nameController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Watchlist name field ────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          decoration: BoxDecoration(
            color: AppColors.editCard,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.editDivider, width: 0.8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  style: AppTextStyles.stockSymbol,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        // ── Reorderable stock list ──────────────────────────────────────────
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: EdgeInsets.zero,
            proxyDecorator: _proxyDecorator,
            onReorder: (oldIndex, newIndex) {
              context.read<WatchlistBloc>().add(
                    ReorderStock(oldIndex: oldIndex, newIndex: newIndex),
                  );
            },
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return _EditStockTile(
                key: ValueKey(stock.id),
                stock: stock,
                index: index,
                onDelete: () => _confirmDelete(context, stock.id, stock.symbol),
              );
            },
          ),
        ),

        // ── "Edit other watchlists" button ──────────────────────────────────
        _EditOtherButton(),

        // ── Save bar ────────────────────────────────────────────────────────
        _SaveBar(onSave: () => Navigator.of(context).pop()),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String stockId,
    String symbol,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Remove Stock',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove $symbol from your watchlist?',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.loss,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Remove',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<WatchlistBloc>().add(RemoveStock(stockId: stockId));
    }
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(animation.value);
        return Material(
          color: Colors.white,
          elevation: t * 8,
          shadowColor: Colors.black26,
          child: child,
        );
      },
      child: child,
    );
  }
}

// ─── Single tile in the Edit list ─────────────────────────────────────────────

class _EditStockTile extends StatelessWidget {
  final Stock stock;
  final int index;
  final VoidCallback onDelete;

  const _EditStockTile({
    super.key,
    required this.stock,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.editCard,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Drag handle ───────────────────────────────────────────
                ReorderableDragStartListener(
                  index: index,
                  child: Container(
                    width: 48,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.drag_handle_rounded,
                      size: 22,
                      color: AppColors.editDragHandle,
                    ),
                  ),
                ),

                // ── Symbol ────────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(stock.symbol, style: AppTextStyles.editSymbol),
                  ),
                ),

                // ── Delete button ─────────────────────────────────────────
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onDelete,
                    child: Container(
                      width: 52,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 22,
                        color: AppColors.editDeleteIcon,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 0,
            thickness: 0.8,
            color: AppColors.editDivider,
            indent: 48,
          ),
        ],
      ),
    );
  }
}

// ─── Edit other watchlists ────────────────────────────────────────────────────

class _EditOtherButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.editCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.editDivider, width: 0.8),
      ),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Edit other watchlists',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ─── Save Watchlist Bar ───────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final VoidCallback onSave;

  const _SaveBar({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.8),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: FilledButton(
        onPressed: onSave,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Save Watchlist',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
