import 'package:decimal/decimal.dart';

/// Formats an asset amount with the specified decimal places and optional symbol.
///
/// [amount] - The amount to format
/// [decimals] - Number of decimal places to display
/// [symbol] - Optional symbol to append to the formatted amount
String formatAssetAmount(Decimal amount, int decimals, {String? symbol}) {
  final formatted = amount.toStringAsFixed(decimals);
  // Remove trailing zeros after decimal point
  final trimmed = formatted
      .replaceAll(RegExp(r'0*$'), '')
      .replaceAll(RegExp(r'\.$'), '');

  if (symbol != null) {
    return '$trimmed $symbol';
  }
  return trimmed;
}
