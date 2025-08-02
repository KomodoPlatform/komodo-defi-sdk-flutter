import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/src/utils/formatters/asset_formatting.dart';

/// An input widget for entering staking amounts with validation.
///
/// Provides amount input with max button, balance display, and validation.
class StakeAmountInput extends StatefulWidget {
  StakeAmountInput({
    required this.asset,
    required this.availableBalance,
    required this.onAmountChanged,
    this.initialAmount,
    Decimal? minAmount,
    this.label = 'Amount to Stake',
    this.showBalance = true,
    this.reserveForFees = true,
    super.key,
  }) : minAmount = minAmount ?? Decimal.one;

  final Asset asset;
  final Decimal availableBalance;
  final ValueChanged<Decimal?> onAmountChanged;
  final Decimal? initialAmount;
  final Decimal minAmount;
  final String label;
  final bool showBalance;
  final bool reserveForFees;

  @override
  State<StakeAmountInput> createState() => _StakeAmountInputState();
}

class _StakeAmountInputState extends State<StakeAmountInput> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialAmount?.toString() ?? '',
    );
    _controller.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onAmountChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() => _errorText = null);
      widget.onAmountChanged(null);
      return;
    }

    try {
      final amount = Decimal.parse(text);

      if (amount.compareTo(Decimal.zero) <= 0) {
        setState(() => _errorText = 'Amount must be greater than zero');
        widget.onAmountChanged(null);
        return;
      }

      if (amount.compareTo(widget.minAmount) < 0) {
        setState(
          () =>
              _errorText =
                  'Minimum amount is ${formatAssetAmount(widget.minAmount, 8)}',
        );
        widget.onAmountChanged(null);
        return;
      }

      final maxAmount = _getMaxAmount();
      if (amount.compareTo(maxAmount) > 0) {
        setState(() => _errorText = 'Insufficient balance');
        widget.onAmountChanged(null);
        return;
      }

      setState(() => _errorText = null);
      widget.onAmountChanged(amount);
    } catch (e) {
      setState(() => _errorText = 'Invalid amount');
      widget.onAmountChanged(null);
    }
  }

  Decimal _getMaxAmount() {
    if (!widget.reserveForFees) {
      return widget.availableBalance;
    }

    // Reserve 5% for fees or 0.1 of the asset, whichever is larger
    final percentReserve = widget.availableBalance * Decimal.parse('0.05');
    final fixedReserve = Decimal.parse('0.1');
    final reserve =
        percentReserve.compareTo(fixedReserve) > 0
            ? percentReserve
            : fixedReserve;

    final maxAmount = widget.availableBalance - reserve;
    return maxAmount.compareTo(Decimal.zero) > 0 ? maxAmount : Decimal.zero;
  }

  void _setMaxAmount() {
    final maxAmount = _getMaxAmount();
    _controller.text = maxAmount.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxAmount = _getMaxAmount();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            labelText: widget.label,
            errorText: _errorText,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.asset.id.symbol.common.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      widget.asset.id.symbol.common,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                TextButton(
                  onPressed:
                      maxAmount.compareTo(Decimal.zero) > 0
                          ? _setMaxAmount
                          : null,
                  child: const Text('MAX'),
                ),
              ],
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        if (widget.showBalance) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                formatAssetAmount(
                  widget.availableBalance,
                  widget.asset.id.chainId.decimals ?? 8,
                  symbol: widget.asset.id.id,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (widget.reserveForFees &&
              maxAmount.compareTo(widget.availableBalance) < 0) ...[
            const SizedBox(height: 4),
            Text(
              'Max stakeable: ${formatAssetAmount(maxAmount, 8, symbol: widget.asset.id.symbol.common)} (reserving for fees)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
