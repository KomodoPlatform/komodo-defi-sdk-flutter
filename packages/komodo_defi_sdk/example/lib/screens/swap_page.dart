import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/swap_cubit.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SwapPage extends StatelessWidget {
  const SwapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SwapCubit(context.read<KomodoDefiSdk>()),
      child: const _SwapView(),
    );
  }
}

class _SwapView extends StatelessWidget {
  const _SwapView();

  List<Asset> _assets(BuildContext context) {
    final cubit = context.read<SwapCubit>();
    return cubit.assets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DEX / Swap')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildSellDropdown(context)),
                const SizedBox(width: 16),
                Expanded(child: _buildBuyDropdown(context)),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<SwapCubit, SwapState>(
              builder: (context, state) {
                if (state.error != null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildBestOrdersTable(context)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildOrderbookTable(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellDropdown(BuildContext context) {
    final cubit = context.read<SwapCubit>();
    return BlocBuilder<SwapCubit, SwapState>(
      buildWhen:
          (p, c) =>
              p.sellAsset != c.sellAsset ||
              p.loadingBestOrders != c.loadingBestOrders,
      builder: (context, state) {
        return DropdownButton<Asset>(
          isExpanded: true,
          value: state.sellAsset,
          hint: const Text('Sell Asset'),
          onChanged: cubit.setSellAsset,
          items:
              _assets(context)
                  .map((a) => DropdownMenuItem(value: a, child: Text(a.id.id)))
                  .toList(),
        );
      },
    );
  }

  Widget _buildBuyDropdown(BuildContext context) {
    final cubit = context.read<SwapCubit>();
    return BlocBuilder<SwapCubit, SwapState>(
      buildWhen:
          (p, c) =>
              p.buyAsset != c.buyAsset ||
              p.loadingOrderbook != c.loadingOrderbook,
      builder: (context, state) {
        return DropdownButton<Asset>(
          isExpanded: true,
          value: state.buyAsset,
          hint: const Text('Buy Asset'),
          onChanged: cubit.setBuyAsset,
          items:
              _assets(context)
                  .map((a) => DropdownMenuItem(value: a, child: Text(a.id.id)))
                  .toList(),
        );
      },
    );
  }

  Widget _buildBestOrdersTable(BuildContext context) {
    return BlocBuilder<SwapCubit, SwapState>(
      buildWhen:
          (p, c) =>
              p.bestOrders != c.bestOrders ||
              p.loadingBestOrders != c.loadingBestOrders,
      builder: (context, state) {
        if (state.loadingBestOrders) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = state.bestOrders;
        if (data == null) {
          return const Center(child: Text('Select sell asset'));
        }
        final rows = <DataRow>[];
        data.orders.forEach((pair, orders) {
          for (final order in orders) {
            rows.add(
              DataRow(
                cells: [
                  DataCell(Text(pair)),
                  DataCell(Text(order.price.decimal ?? '')),
                  DataCell(Text(order.baseMaxVolume.decimal ?? '')),
                ],
              ),
            );
          }
        });
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Pair')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Vol')),
            ],
            rows: rows,
          ),
        );
      },
    );
  }

  Widget _buildOrderbookTable(BuildContext context) {
    return BlocBuilder<SwapCubit, SwapState>(
      buildWhen:
          (p, c) =>
              p.orderbook != c.orderbook ||
              p.loadingOrderbook != c.loadingOrderbook,
      builder: (context, state) {
        if (state.loadingOrderbook) {
          return const Center(child: CircularProgressIndicator());
        }
        final book = state.orderbook;
        if (book == null) {
          return const Center(child: Text('Select assets'));
        }
        final rows = <DataRow>[];
        for (final ask in book.asks) {
          rows.add(
            DataRow(
              cells: [
                const DataCell(Text('Ask')),
                DataCell(Text(ask.price.decimal ?? '')),
                DataCell(Text(ask.baseMaxVolume.decimal ?? '')),
              ],
            ),
          );
        }
        for (final bid in book.bids) {
          rows.add(
            DataRow(
              cells: [
                const DataCell(Text('Bid')),
                DataCell(Text(bid.price.decimal ?? '')),
                DataCell(Text(bid.baseMaxVolume.decimal ?? '')),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Vol')),
            ],
            rows: rows,
          ),
        );
      },
    );
  }
}
