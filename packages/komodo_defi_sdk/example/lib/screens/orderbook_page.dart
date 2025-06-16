import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/swap/swap_bloc.dart';
import 'package:kdf_sdk_example/widgets/swaps/asset_dropdown.dart';
import 'package:kdf_sdk_example/widgets/swaps/best_orders_table.dart';
import 'package:kdf_sdk_example/widgets/swaps/orderbook_table.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

class OrderbookPage extends StatelessWidget {
  const OrderbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SwapBloc(context.read<KomodoDefiSdk>()),
      child: const _OrderbookView(),
    );
  }
}

class _OrderbookView extends StatelessWidget {
  const _OrderbookView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DEX / Orderbook')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth * 0.03;
          final verticalPadding = constraints.maxHeight * 0.03;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Row(
                      children: [
                        Expanded(child: SellAssetDropdown()),
                        SizedBox(width: 16),
                        Expanded(child: BuyAssetDropdown()),
                      ],
                    ),
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
                    child: Column(
                      children: [
                        Expanded(child: BestOrdersTable()),
                        SizedBox(height: 16),
                        Expanded(child: OrderbookTable()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SellAssetDropdown extends StatelessWidget {
  const SellAssetDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapBloc, SwapState>(
      buildWhen: (p, c) => p.sellAsset != c.sellAsset,
      builder: (context, state) {
        return AssetDropdown(
          selectedAsset: state.sellAsset,
          hintText: 'Sell Asset',
          onChanged: (asset) {
            context.read<SwapBloc>().add(SellAssetSelected(asset));
          },
        );
      },
    );
  }
}

class BuyAssetDropdown extends StatelessWidget {
  const BuyAssetDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapBloc, SwapState>(
      buildWhen: (p, c) => p.buyAsset != c.buyAsset,
      builder: (context, state) {
        return AssetDropdown(
          selectedAsset: state.buyAsset,
          hintText: 'Buy Asset',
          onChanged: (asset) {
            context.read<SwapBloc>().add(BuyAssetSelected(asset));
          },
        );
      },
    );
  }
}
