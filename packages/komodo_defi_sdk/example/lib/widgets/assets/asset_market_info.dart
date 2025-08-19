import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kdf_sdk_example/blocs/blocs.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AssetMarketInfo extends StatelessWidget {
  const AssetMarketInfo(this.asset, {super.key});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              AssetMarketInfoBloc(sdk: context.read<KomodoDefiSdk>())
                ..add(AssetMarketInfoRequested(asset)),
      child: const _AssetMarketInfoContent(),
    );
  }
}

class _AssetMarketInfoContent extends StatelessWidget {
  const _AssetMarketInfoContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssetMarketInfoBloc, AssetMarketInfoState>(
      builder: (context, state) {
        final balanceStr = _formatCurrency(state.usdBalance);
        final priceStr = _formatCurrency(state.price);
        final changeStr = _formatChange(state.change24h);
        final change = state.change24h;
        final color =
            change == null
                ? null
                : (change >= Decimal.zero ? Colors.green : Colors.red);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(balanceStr, style: Theme.of(context).textTheme.bodySmall),
            Text(priceStr, style: Theme.of(context).textTheme.bodySmall),
            Text(
              changeStr,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        );
      },
    );
  }
}

String _formatCurrency(Decimal? value) {
  if (value == null) return '--';
  final format = NumberFormat.currency(symbol: r'$');
  return format.format(value.toDouble());
}

String _formatChange(Decimal? value) {
  if (value == null) return '--';
  final format = NumberFormat('+#,##0.00%;-#,##0.00%');
  return format.format(value.toDouble() / 100);
}
