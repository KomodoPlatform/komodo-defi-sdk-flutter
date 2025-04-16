import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Constants for fee calculations
const _gweiInEth = 1000000000; // 10^9

extension FeeInfoFormatting on FeeInfo {
  /// Format a number with given precision and remove trailing zeros
  static String _formatNumber(Decimal number, {int precision = 8}) {
    if (precision < 0) throw ArgumentError('Precision must be non-negative');
    return number.toStringAsFixed(precision).replaceAll(RegExp(r'\.?0+$'), '');
  }

  /// Returns a formatted string of the total fee with the coin symbol
  /// e.g. "0.001 ETH"
  String formatTotal({int precision = 8}) {
    final total = totalFee;
    return '${_formatNumber(total, precision: precision)} $coin';
  }

  /// Returns a human-readable description of the fee
  String get description {
    return maybeMap(
      ethGas:
          (fee) =>
              'Gas: ${fee.gas} @ ${_formatNumber(fee.gasPrice * Decimal.fromInt(_gweiInEth), precision: 2)} Gwei',
      orElse: formatTotal,
    );
  }

  /// Returns true if the fee seems unusually high
  bool get isHighFee {
    return maybeMap(
      ethGas:
          (fee) =>
              fee.gasPrice * Decimal.fromInt(_gweiInEth) > Decimal.fromInt(100),
      utxoFixed: (fee) => fee.amount > Decimal.fromInt(50000),
      utxoPerKbyte: (fee) => fee.amount > Decimal.fromInt(50000),
      orElse: () => false,
    );
  }
}

/// Dedicated formatting extension for *only* the ethGas variant
extension EthGasFormatting on FeeInfoEthGas {
  /// Get the gas price in Gwei units
  Decimal get priceInGwei => gasPrice * Decimal.fromInt(_gweiInEth);

  /// Format gas price in Gwei with appropriate precision
  String formatGasPrice({int precision = 2}) {
    return FeeInfoFormatting._formatNumber(priceInGwei, precision: precision);
  }

  /// Estimate transaction time based on gas price
  String get estimatedTime {
    final gwei = priceInGwei;
    if (gwei > Decimal.fromInt(100)) return '< 15 seconds';
    if (gwei > Decimal.fromInt(50)) return '< 30 seconds';
    if (gwei > Decimal.fromInt(20)) return '< 2 minutes';
    return '> 5 minutes';
  }

  /// Detailed fee breakdown
  String get detailedBreakdown {
    return 'Gas Limit: $gas units\n'
        'Gas Price: ${formatGasPrice()} Gwei\n'
        'Total: ${formatTotal()}';
  }
}
