import 'package:flutter/material.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:provider/provider.dart';

/// Example of using multiple streams together for an asset
class AssetDetailsWidget extends StatelessWidget {
  const AssetDetailsWidget({super.key, required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final sdk = context.read<KomodoDefiSdk>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              asset.id.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            StreamBuilder<BalanceInfo>(
              stream: sdk.balances.watchBalance(asset.id),
              builder: (context, balanceSnapshot) {
                if (balanceSnapshot.hasData) {
                  return Text(
                    'Balance: \${balanceSnapshot.data!.total.toStringAsFixed(4)} \${asset.id.symbol.common}',
                  );
                }
                return const Text('Loading balance...');
              },
            ),
            const SizedBox(height: 8),
            StreamBuilder<MarketData>(
              stream: sdk.marketData.watchMarketData(asset.id),
              builder: (context, priceSnapshot) {
                if (priceSnapshot.hasData) {
                  final marketData = priceSnapshot.data!;
                  final balance = sdk.balances.lastKnown(asset.id);

                  if (balance != null) {
                    final value = balance.total * marketData.price.toDouble();
                    return Text(
                      'Value: \$\${value.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                  }
                }
                return const Text('Loading price...');
              },
            ),
          ],
        ),
      ),
    );
  }
}
