import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

extension FeeInfoFormatting on FeeInfo {
  /// Returns a formatted string of the total fee with the coin symbol
  /// e.g. "0.001 ETH"
  String formatTotal({int precision = 8}) {
    if (precision < 0) throw ArgumentError('Precision must be non-negative');

    // If your union has a `totalFee` getter, you can just do:
    final total = totalFee;
    final formatted = total
        .toStringAsFixed(precision)
        .replaceAll(RegExp(r'\.?0+$'), ''); // Trim trailing zeros
    return '$formatted $coin';
  }

  /// Returns a human-readable description of the fee
  String get description {
    // In your old code, if ETH had special logic, replicate it here:
    return maybeMap(
      ethGas: (fee) =>
          'Gas: ${fee.gas} @ ${_formatGweiPrice(fee.gasPrice)} Gwei',
      orElse: formatTotal,
    );
  }

  /// Returns true if the fee seems unusually high
  bool get isHighFee {
    return maybeMap(
      ethGas: (fee) =>
          fee.gasPrice > Decimal.fromInt(100), // e.g. > 100 Gwei => "high"
      utxoFixed: (fee) =>
          fee.amount > Decimal.fromInt(50000), // e.g. > 50k sats
      utxoPerKbyte: (fee) => fee.amount > Decimal.fromInt(50000),
      // For qrc20Gas / cosmosGas, we can return false or define a threshold
      orElse: () => false,
    );
  }
}

/// Dedicated formatting extension for *only* the ethGas variant
extension EthGasFormatting on FeeInfoEthGas {
  /// Format gas price in Gwei with appropriate precision
  String formatGasPrice({int precision = 2}) {
    // If your `gasPrice` is actually in ETH, convert:
    // gwei = ethPrice * 10^9
    final priceInGwei = gasPrice * Decimal.fromInt(1000000000);
    return _formatGweiPrice(priceInGwei, precision: precision);
  }

  /// Estimate transaction time based on gas price
  String get estimatedTime {
    // interpret gasPrice in ETH -> convert to Gwei:
    final gwei = gasPrice * Decimal.fromInt(1000000000);
    if (gwei > Decimal.fromInt(100)) return '< 15 seconds';
    if (gwei > Decimal.fromInt(50)) return '< 30 seconds';
    if (gwei > Decimal.fromInt(20)) return '< 2 minutes';
    return '> 5 minutes';
  }

  /// Detailed fee breakdown
  String get detailedBreakdown {
    final gasCost = _formatGweiPrice(gasPrice * Decimal.fromInt(1000000000));
    return 'Gas Limit: $gas units\n'
        'Gas Price: $gasCost Gwei\n'
        'Total: ${formatTotal()}';
  }
}

/// Helper function for Gwei
String _formatGweiPrice(Decimal gweiPrice, {int precision = 2}) {
  if (precision < 0) throw ArgumentError('Precision must be non-negative');

  return gweiPrice.toStringAsFixed(precision).replaceAll(RegExp(r'\.?0+$'), '');
}
