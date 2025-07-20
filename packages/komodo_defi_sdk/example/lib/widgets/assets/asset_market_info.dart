import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import '../../blocs/asset_market_info/asset_market_info_cubit.dart';

class AssetMarketInfo extends StatelessWidget {
  const AssetMarketInfo({super.key, required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => AssetMarketInfoCubit(
            sdk: context.read<KomodoDefiSdk>(),
            asset: asset,
          ),
      child: const _AssetMarketInfoView(),
    );
  }
}

class _AssetMarketInfoView extends StatelessWidget {
  const _AssetMarketInfoView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssetMarketInfoCubit, AssetMarketInfoState>(
      builder: (context, state) {
        final balanceStr = _formatCurrency(state.usdBalance);
        final priceStr = _formatCurrency(state.price);
        final changeStr = _formatChange(state.change24h);
        final color =
            state.change24h == null
                ? null
                : state.change24h! >= Decimal.zero
                ? Colors.green
                : Colors.red;

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
  final number = double.parse(value.toString());
  final format = NumberFormat.currency(symbol: r'$');
  return format.format(number);
}

String _formatChange(Decimal? value) {
  if (value == null) return '--';
  final percent = double.parse((value * Decimal.fromInt(100)).toString());
  final format = NumberFormat('+#,##0.00%;-#,##0.00%');
  return format.format(percent / 100);
}
