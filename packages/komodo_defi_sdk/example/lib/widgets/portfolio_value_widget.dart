import 'package:flutter/material.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:provider/provider.dart';

/// Example of combining multiple market data streams
class PortfolioValueWidget extends StatelessWidget {
  const PortfolioValueWidget({super.key, required this.assetIds});

  final List<AssetId> assetIds;

  @override
  Widget build(BuildContext context) {
    final sdk = context.read<KomodoDefiSdk>();

    final valueStreams =
        assetIds.map((assetId) {
          return StreamZip([
            sdk.balances.watchBalance(assetId),
            sdk.marketData.watchMarketData(assetId),
          ]).map((data) {
            final balance = data[0] as BalanceInfo;
            final marketData = data[1] as MarketData;
            return balance.total.toDouble() * marketData.price.toDouble();
          });
        }).toList();

    return StreamBuilder<List<double>>(
      stream: StreamZip(valueStreams),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final totalValue = snapshot.data!.fold(
          0.0,
          (sum, value) => sum + value,
        );

        return Text(
          'Portfolio Value: \$${totalValue.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}
