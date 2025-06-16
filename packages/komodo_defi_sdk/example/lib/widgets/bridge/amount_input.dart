import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/bridge/bridge_bloc.dart';

class AmountInput extends StatefulWidget {
  const AmountInput({super.key});

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BridgeBloc, BridgeState>(
      listenWhen: (previous, current) => previous.sellAmount != current.sellAmount,
      listener: (context, state) {
        final amount = state.sellAmount?.toString() ?? '';
        if (_controller.text != amount) {
          _controller.text = amount;
        }
      },
      child: BlocBuilder<BridgeBloc, BridgeState>(
        buildWhen: (previous, current) =>
            previous.sellAsset != current.sellAsset ||
            previous.maxSellAmount != current.maxSellAmount ||
            previous.error != current.error,
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount to Send',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixText: state.sellAsset?.id.name,
                        errorText: state.error?.contains('amount') == true ? state.error : null,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      onChanged: (value) {
                        context.read<BridgeBloc>().add(
                              BridgeSellAmountChanged(value),
                            );
                      },
                      enabled: state.sellAsset != null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 32,
                        child: OutlinedButton(
                          onPressed: state.maxSellAmount != null
                              ? () {
                                  context.read<BridgeBloc>().add(
                                        const BridgeAmountButtonClicked(0.5),
                                      );
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('50%'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 60,
                        height: 32,
                        child: OutlinedButton(
                          onPressed: state.maxSellAmount != null
                              ? () {
                                  context.read<BridgeBloc>().add(
                                        const BridgeAmountButtonClicked(1),
                                      );
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          child: const Text('MAX'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (state.maxSellAmount != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Available: ${state.maxSellAmount} ${state.sellAsset?.id.name ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              if (state.buyAmount != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'You will receive: ${state.buyAmount} ${state.bestOrder?.coin ?? ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
