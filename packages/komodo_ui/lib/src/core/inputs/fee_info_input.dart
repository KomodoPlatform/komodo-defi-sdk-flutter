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

  /// Convert Gwei -> ETH by dividing by 10^9
  static final Decimal _gweiToEth = Decimal.fromInt(1000000000);

  @override
  Widget build(BuildContext context) {
    final protocol = asset.protocol;

    // A typical approach: check the protocol, show relevant fee UI
    if (protocol is Erc20Protocol) {
      return _buildErc20GasInputs(context);
    } else if (protocol is UtxoProtocol) {
      return _buildUtxoFeeInputs(context, protocol);
    } else if (protocol is QtumProtocol) {
      return _buildQrc20GasInputs(context);
    } else if (protocol is TendermintProtocol) {
      return _buildCosmosGasInputs(context);
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
                    final ethPrice = gweiInput / _gweiToEth;

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
                decoration: const InputDecoration(labelText: 'Gas Limit'),
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

  /// Builds the gas limit/price inputs for QRC20-based assets
  Widget _buildQrc20GasInputs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gas Settings'),
        const SizedBox(height: 8),
        Row(
          children: [
            // Gas Price input
            Expanded(
              child: TextFormField(
                enabled: isCustomFee,
                decoration: const InputDecoration(labelText: 'Gas Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final gasPrice = Decimal.tryParse(value);
                  if (gasPrice != null) {
                    // Preserve gas limit if already set
                    final oldGasLimit = selectedFee?.maybeMap(
                      qrc20Gas: (qrc) => qrc.gasLimit,
                      orElse: () => 250000, // default
                    );

                    onFeeSelected(
                      FeeInfo.qrc20Gas(
                        coin: asset.id.id,
                        gasPrice: gasPrice,
                        gasLimit: oldGasLimit ?? 250000,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 16),

            // Gas Limit input
            Expanded(
              child: TextFormField(
                enabled: isCustomFee,
                decoration: const InputDecoration(labelText: 'Gas Limit'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final gasLimit = int.tryParse(value);
                  if (gasLimit != null) {
                    // Preserve gas price if already set
                    final oldGasPrice = selectedFee?.maybeMap(
                      qrc20Gas: (qrc) => qrc.gasPrice,
                      orElse: () => Decimal.parse('0.00000040'), // default
                    );

                    onFeeSelected(
                      FeeInfo.qrc20Gas(
                        coin: asset.id.id,
                        gasPrice: oldGasPrice ?? Decimal.parse('0.00000040'),
                        gasLimit: gasLimit,
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

  /// Builds gas limit/price inputs for Cosmos-based assets
  Widget _buildCosmosGasInputs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gas Settings'),
        const SizedBox(height: 8),
        Row(
          children: [
            // Gas Price input
            Expanded(
              child: TextFormField(
                enabled: isCustomFee,
                decoration: const InputDecoration(labelText: 'Gas Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final gasPrice = Decimal.tryParse(value);
                  if (gasPrice != null) {
                    // Preserve gas limit if already set
                    final oldGasLimit = selectedFee?.maybeMap(
                      cosmosGas: (cosmos) => cosmos.gasLimit,
                      orElse: () => 200000, // default
                    );

                    onFeeSelected(
                      FeeInfo.cosmosGas(
                        coin: asset.id.id,
                        gasPrice: gasPrice,
                        gasLimit: oldGasLimit ?? 200000,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 16),

            // Gas Limit input
            Expanded(
              child: TextFormField(
                enabled: isCustomFee,
                decoration: const InputDecoration(labelText: 'Gas Limit'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final gasLimit = int.tryParse(value);
                  if (gasLimit != null) {
                    // Preserve gas price if already set
                    final oldGasPrice = selectedFee?.maybeMap(
                      cosmosGas: (cosmos) => cosmos.gasPrice,
                      orElse: () => Decimal.parse('0.025'), // default
                    );

                    onFeeSelected(
                      FeeInfo.cosmosGas(
                        coin: asset.id.id,
                        gasPrice: oldGasPrice ?? Decimal.parse('0.025'),
                        gasLimit: gasLimit,
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

  /// Builds manual inputs for UTXO fee entry with a toggle button
  Widget _buildUtxoFeeInputs(BuildContext context, UtxoProtocol protocol) {
    final defaultFee = protocol.txFee ?? 10000;

    // Extract current fee amount or use default
    final currentFeeAmount =
        selectedFee?.maybeMap(
          utxoFixed: (f) => f.amount,
          utxoPerKbyte: (p) => p.amount,
          orElse: () => Decimal.parse(defaultFee.toString()),
        ) ??
        Decimal.parse(defaultFee.toString());

    // Determine if we're using fixed fee or per KB fee
    final isPerKbyteFee =
        selectedFee?.maybeMap(utxoPerKbyte: (_) => true, orElse: () => false) ??
        false;

    return TextFormField(
      enabled: isCustomFee,
      initialValue: currentFeeAmount.toString(),
      decoration: InputDecoration(
        labelText: 'Fee Amount',
        hintText: defaultFee.toString(),
        // Toggle button in prefix
        prefixIconConstraints: const BoxConstraints(
          maxWidth: 36,
          maxHeight: 36,
        ),
        prefixIcon:
            isCustomFee
                ? IconButton.filledTonal(
                  iconSize: 20,
                  tooltip:
                      isPerKbyteFee
                          ? 'Switch to fixed fee'
                          : 'Switch to fee per kilobyte',
                  icon: Icon(isPerKbyteFee ? Icons.scale : Icons.attach_money),
                  onPressed: () {
                    final amount = currentFeeAmount;
                    if (!isPerKbyteFee) {
                      // Switch to per KB fee
                      onFeeSelected(
                        FeeInfo.utxoPerKbyte(coin: asset.id.id, amount: amount),
                      );
                    } else {
                      // Switch to fixed fee
                      onFeeSelected(
                        FeeInfo.utxoFixed(coin: asset.id.id, amount: amount),
                      );
                    }
                  },
                )
                : null,
        // Show appropriate suffix based on fee type
        suffixText: isPerKbyteFee ? '${asset.id.id}/KB' : asset.id.id,
        helperText:
            isPerKbyteFee
                ? 'Fee per kilobyte of transaction size'
                : 'Total transaction fee',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {
        final amount = Decimal.tryParse(value);
        if (amount != null) {
          // Create appropriate fee type based on current selection
          if (isPerKbyteFee) {
            onFeeSelected(
              FeeInfo.utxoPerKbyte(coin: asset.id.id, amount: amount),
            );
          } else {
            onFeeSelected(FeeInfo.utxoFixed(coin: asset.id.id, amount: amount));
          }
        }
      },
    );
  }
}
