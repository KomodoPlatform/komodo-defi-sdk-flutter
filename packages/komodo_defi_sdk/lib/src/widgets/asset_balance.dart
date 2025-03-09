import 'package:flutter/material.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/komodo_ui.dart';
import 'package:provider/provider.dart';

/// An adapter component that connects the komodo_ui AssetBalanceText with
/// the SDK's BalanceManager
class AssetBalanceText extends StatelessWidget {
  const AssetBalanceText({
    required this.assetId,
    super.key,
    this.style,
    this.loadingWidget,
    this.errorBuilder,
    this.formatBalance,
    this.activateIfNeeded = true,
  });

  /// The ID of the asset to display the balance for
  final AssetId assetId;

  /// The text style to apply to the balance text
  final TextStyle? style;

  /// Widget to display while loading the balance
  final Widget? loadingWidget;

  /// Builder for displaying errors
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Function to format the balance (default: display the total amount)
  final String Function(BalanceInfo? balance)? formatBalance;

  /// Whether to activate the asset if it's not already activated
  final bool activateIfNeeded;

  @override
  Widget build(BuildContext context) {
    final balanceManager = context.read<KomodoDefiSdk>().balances;

    return TextStreamBuilder<BalanceInfo>(
      stream: balanceManager.watchBalance(
        assetId,
        activateIfNeeded: activateIfNeeded,
      ),
      formatData: formatBalance ?? _defaultFormatBalance,
      style:
          style ??
          Theme.of(context).textTheme.bodyMedium, // TODO! Verify correct style
      loadingWidget: loadingWidget,
      errorBuilder: errorBuilder,
    );
  }

  String _defaultFormatBalance(BalanceInfo? balance) {
    if (balance == null) {
      return '';
    }
    final symbol = assetId.symbol.common;

    final decimals = !balance.hasValue ? 0 : 4;

    final formatter = NumberFormat.decimalPatternDigits(
      decimalDigits: decimals,
    );

    return '${formatter.format(balance?.total.toDouble() ?? 0)} $symbol';
  }
}
