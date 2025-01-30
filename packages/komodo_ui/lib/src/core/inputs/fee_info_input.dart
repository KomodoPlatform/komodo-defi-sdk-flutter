import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

typedef FeeInfoChanged = void Function(FeeInfo? fee);

class FeeInfoInput extends StatelessWidget {
  const FeeInfoInput({
    required this.asset,
    required this.selectedFee,
    required this.isCustomFee,
    required this.onFeeSelected,
    super.key,
  });

  final Asset asset;
  final FeeInfo? selectedFee;
  final bool isCustomFee;
  final FeeInfoChanged onFeeSelected;

  @override
  Widget build(BuildContext context) {
    final protocol = asset.protocol;

    // A typical approach: check the protocol, show relevant fee UI
    if (protocol is Erc20Protocol) {
      return _buildErc20GasInputs(context);
    } else if (protocol is UtxoProtocol) {
      return _buildUtxoFeeSelection(context, protocol);
    } else {
      // No custom fee input for other protocols
      return const SizedBox.shrink();
    }
  }

  /// Builds the gas price/limit fields for Erc20-based assets (e.g. ETH).
  Widget _buildErc20GasInputs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gas Settings'),
        const SizedBox(height: 8),
        Row(
          children: [
            // 1) Gas Price (in Gwei)
            Expanded(
              child: TextFormField(
                enabled: isCustomFee,
                decoration: const InputDecoration(
                  labelText: 'Gas Price (Gwei)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final gweiInput = Decimal.tryParse(value);
                  if (gweiInput != null) {
                    final ethPrice = gweiInput / Decimal.fromInt(1000000000);

                    // Get the old gas limit from the current fee (if ethGas)
                    final oldGasLimit = selectedFee?.maybeMap(
                      ethGas: (eth) => eth.gas,
                      orElse: () => 21000,
                    );

                    // Fire callback with the new fee
                    onFeeSelected(
                      FeeInfo.ethGas(
                        coin: asset.id.id,
                        gasPrice: ethPrice.toDecimal(),
                        gas: oldGasLimit ?? 21000,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 16),

            // 2) Gas Limit
            Expanded(
              child: TextFormField(
                enabled: isCustomFee,
                decoration: const InputDecoration(
                  labelText: 'Gas Limit',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final gasLimit = int.tryParse(value);
                  if (gasLimit != null) {
                    // Get the old gasPrice from the current fee (if ethGas)
                    final oldGasPrice = selectedFee?.maybeMap(
                      ethGas: (eth) => eth.gasPrice,
                      orElse: () => Decimal.parse('0.000000003'), // default
                    );

                    onFeeSelected(
                      FeeInfo.ethGas(
                        coin: asset.id.id,
                        gasPrice: oldGasPrice ?? Decimal.parse('0.000000003'),
                        gas: gasLimit,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a segmented control for selecting a standard/fast/urgent UTXO fee.
  Widget _buildUtxoFeeSelection(BuildContext context, UtxoProtocol protocol) {
    final defaultFee = protocol.txFee ?? 10000;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transaction Fee'),
        const SizedBox(height: 8),
        SegmentedButton<Decimal>(
          segments: [
            ButtonSegment(
              value: Decimal.parse(defaultFee.toString()),
              label: Text('Standard ($defaultFee)'),
            ),
            ButtonSegment(
              value: Decimal.parse((defaultFee * 2).toString()),
              label: Text('Fast (${defaultFee * 2})'),
            ),
            ButtonSegment(
              value: Decimal.parse((defaultFee * 5).toString()),
              label: Text('Urgent (${defaultFee * 5})'),
            ),
          ],
          // Reflect whichever UTXO fee is currently selected
          selected: {
            if (selectedFee != null)
              selectedFee!.maybeMap(
                utxoFixed: (f) => f.amount,
                utxoPerKbyte: (p) => p.amount,
                orElse: () => Decimal.zero,
              )
            else
              Decimal.parse(defaultFee.toString()),
          },
          onSelectionChanged: !isCustomFee
              ? null
              : (newValues) {
                  if (newValues.isEmpty) return;
                  final chosenFee = newValues.first;
                  // Return a new UTXO fixed fee
                  onFeeSelected(
                    FeeInfo.utxoFixed(
                      coin: asset.id.id,
                      amount: chosenFee,
                    ),
                  );
                },
        ),
      ],
    );
  }
}
