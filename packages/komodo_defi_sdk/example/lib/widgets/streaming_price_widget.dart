import 'package:flutter/material.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:provider/provider.dart';

/// Example widget showing real-time price updates
class StreamingPriceWidget extends StatelessWidget {
  const StreamingPriceWidget({
    super.key,
    required this.assetId,
    this.fiatCurrency = 'usdt',
  });

  final AssetId assetId;
  final String fiatCurrency;

  @override
  Widget build(BuildContext context) {
    final sdk = context.read<KomodoDefiSdk>();

    return StreamBuilder<MarketData>(
      stream: sdk.marketData.watchMarketData(
        assetId,
        fiatCurrency: fiatCurrency,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final marketData = snapshot.data;
        if (marketData == null) {
          return const Text('No data available');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${marketData.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (marketData.priceChange24h != null)
              Row(
                children: [
                  Icon(
                    marketData.priceChange24h!.isNegative
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color:
                        marketData.priceChange24h!.isNegative
                            ? Colors.red
                            : Colors.green,
                    size: 16,
                  ),
                  Text(
                    '${marketData.priceChange24h!.abs().toStringAsFixed(2)}%',
                    style: TextStyle(
                      color:
                          marketData.priceChange24h!.isNegative
                              ? Colors.red
                              : Colors.green,
                    ),
                  ),
                ],
              ),
            if (marketData.lastUpdated != null)
              Text(
                'Updated: ${_formatTime(marketData.lastUpdated!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
