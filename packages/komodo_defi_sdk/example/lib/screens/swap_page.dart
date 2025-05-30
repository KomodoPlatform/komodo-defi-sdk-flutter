import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

import '../blocs/swap_bloc.dart';
import '../widgets/buy_asset_dropdown.dart';
import '../widgets/sell_asset_dropdown.dart';
import '../widgets/best_orders_table.dart';
import '../widgets/orderbook_table.dart';

class SwapPage extends StatelessWidget {
  const SwapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SwapBloc(context.read<KomodoDefiSdk>()),
      child: const _SwapView(),
    );
  }
}

class _SwapView extends StatelessWidget {
  const _SwapView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DEX / Swap')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(child: SellAssetDropdown()),
                SizedBox(width: 16),
                Expanded(child: BuyAssetDropdown()),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<SwapBloc, SwapState>(
              buildWhen: (p, c) => p.error != c.error,
              builder: (context, state) {
                if (state.error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              },
            ),
            const Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: BestOrdersTable()),
                  SizedBox(width: 16),
                  Expanded(child: OrderbookTable()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
