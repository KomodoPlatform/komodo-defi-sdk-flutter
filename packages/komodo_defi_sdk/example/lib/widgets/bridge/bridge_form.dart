import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/bridge/bridge_bloc.dart';
import 'package:kdf_sdk_example/widgets/bridge/amount_input.dart';
import 'package:kdf_sdk_example/widgets/bridge/source_asset_dropdown.dart';
import 'package:kdf_sdk_example/widgets/bridge/target_orders_dropdown.dart';
import 'package:kdf_sdk_example/widgets/bridge/ticker_dropdown.dart';

class BridgeForm extends StatelessWidget {
  const BridgeForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BridgeBloc, BridgeState>(
      buildWhen: (previous, current) => previous.step != current.step,
      builder: (context, state) {
        if (state.step == BridgeStep.confirm) {
          return const BridgeConfirmation();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TickerDropdown(),
                const SizedBox(height: 16),
                const SourceAssetDropdown(),
                const SizedBox(height: 16),
                const TargetOrdersDropdown(),
                const SizedBox(height: 16),
                const AmountInput(),
                const SizedBox(height: 24),
                BlocBuilder<BridgeBloc, BridgeState>(
                  buildWhen:
                      (previous, current) =>
                          previous.error != current.error ||
                          previous.inProgress != current.inProgress ||
                          previous.sellAsset != current.sellAsset ||
                          previous.bestOrder != current.bestOrder ||
                          previous.sellAmount != current.sellAmount,
                  builder: (context, state) {
                    final canSubmit =
                        state.sellAsset != null &&
                        state.bestOrder != null &&
                        state.sellAmount != null &&
                        !state.inProgress;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.error!,
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    context.read<BridgeBloc>().add(
                                      const BridgeClearErrors(),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        FilledButton(
                          onPressed:
                              canSubmit
                                  ? () {
                                    context.read<BridgeBloc>().add(
                                      const BridgeSubmitClicked(),
                                    );
                                  }
                                  : null,
                          child:
                              state.inProgress
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Review Bridge'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BridgeConfirmation extends StatelessWidget {
  const BridgeConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BridgeBloc, BridgeState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<BridgeBloc>().add(
                          const BridgeBackClicked(),
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Text(
                      'Confirm Bridge',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _ConfirmationRow(
                        label: 'From',
                        value:
                            '${state.sellAmount} ${state.sellAsset?.id.name}',
                        icon: Icons.arrow_upward,
                      ),
                      const SizedBox(height: 8),
                      _ConfirmationRow(
                        label: 'To',
                        value: '${state.buyAmount} ${state.bestOrder?.coin}',
                        icon: Icons.arrow_downward,
                      ),
                      const SizedBox(height: 8),
                      _ConfirmationRow(
                        label: 'Rate',
                        value:
                            '1 ${state.sellAsset?.id.name} = ${state.bestOrder?.price.toDecimal()} ${state.bestOrder?.coin}',
                        icon: Icons.sync_alt,
                      ),
                    ],
                  ),
                ),
                if (state.preimageData != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Transaction Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _ConfirmationRow(
                          label: 'Trading Fee',
                          value:
                              '${state.preimageData!.takerFee?.amount != null ? double.tryParse(state.preimageData!.takerFee!.amount.toString())?.toStringAsFixed(8) ?? state.preimageData!.takerFee!.amount.toString() : 'Unknown'} ${state.preimageData!.takerFee?.coin ?? ''}',
                          icon: Icons.payments,
                        ),
                        const SizedBox(height: 8),
                        _ConfirmationRow(
                          label: 'Network Fee',
                          value:
                              '${state.preimageData!.feeToSendTakerFee?.amount ?? 'Unknown'} ${state.preimageData!.feeToSendTakerFee?.coin ?? ''}',
                          icon: Icons.network_check,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (state.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            !state.inProgress
                                ? () {
                                  context.read<BridgeBloc>().add(
                                    const BridgeBackClicked(),
                                  );
                                }
                                : null,
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed:
                            !state.inProgress && state.preimageData != null
                                ? () {
                                  context.read<BridgeBloc>().add(
                                    const BridgeStartSwap(),
                                  );
                                }
                                : null,
                        child:
                            state.inProgress
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Start Bridge'),
                      ),
                    ),
                  ],
                ),
                if (state.swapUuid != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bridge Started!',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Swap UUID: ${state.swapUuid}',
                          style: TextStyle(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  const _ConfirmationRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
