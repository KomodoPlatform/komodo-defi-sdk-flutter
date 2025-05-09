import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/src/utils/formatters/fee_info_formatters.dart';

/// A widget for displaying FeeInfo details in a consistent format.
///
/// This widget handles all fee types (ETH gas, QRC20 gas, Cosmos gas, UTXO)
/// and displays their relevant details in a clear, formatted way.
class FeeInfoDisplay extends StatelessWidget {
  const FeeInfoDisplay({
    required this.feeInfo,
    this.showDetailedBreakdown = true,
    super.key,
  });

  /// The fee information to display
  final FeeInfo feeInfo;

  /// Whether to show the detailed fee breakdown
  /// If false, only shows the total fee
  final bool showDetailedBreakdown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDetailedBreakdown) ...[
          Text('Fee Details:', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),

          // Show different details based on fee type
          ...switch (feeInfo) {
            final FeeInfoEthGas fee => [
              Text('Gas:', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '${fee.gas} units',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text('Gas Price:', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '${fee.formatGasPrice()} Gwei',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (fee.isHighFee)
                Text(
                  'Warning: High gas price',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              Text(
                'Estimated Time: ${fee.estimatedTime}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            final FeeInfoQrc20Gas fee => [
              Text('Gas Limit:', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '${fee.gasLimit}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text('Gas Price:', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                fee.formatTotal(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],

            final FeeInfoCosmosGas fee => [
              Text('Gas Limit:', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '${fee.gasLimit}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text('Gas Price:', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                fee.formatTotal(precision: 2),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],

            final FeeInfoUtxoFixed fee => [
              Text('Fixed Fee:', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                fee.formatTotal(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],

            final FeeInfoUtxoPerKbyte fee => [
              Text(
                'Fee per KB:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                fee.formatTotal(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          },

          const SizedBox(height: 4),
        ],

        // Always show total fee
        Text(
          'Total Fee: ${feeInfo.formatTotal()}',
          style: Theme.of(context).textTheme.titleSmall,
        ),

        // Show warning for high fees
        if (feeInfo.isHighFee)
          Text(
            'Warning: This fee seems unusually high',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
      ],
    );
  }
}
