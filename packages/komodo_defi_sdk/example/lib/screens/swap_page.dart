import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/swap_execution/swap_execution_bloc.dart';
import 'package:kdf_sdk_example/widgets/swaps/asset_dropdown.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SwapPage extends StatelessWidget {
  const SwapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SwapExecutionBloc(context.read<KomodoDefiSdk>()),
      child: const _SwapView(),
    );
  }
}

class _SwapView extends StatelessWidget {
  const _SwapView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DEX / Swap')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth * 0.03;
          final verticalPadding = constraints.maxHeight * 0.03;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Asset selection section
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Assets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: SellAssetDropdown()),
                            SizedBox(width: 16),
                            Expanded(child: BuyAssetDropdown()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Trade parameters section
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trade Parameters',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: VolumeInput()),
                            SizedBox(width: 16),
                            Expanded(child: PriceInput()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error display
                  BlocBuilder<SwapExecutionBloc, SwapExecutionState>(
                    buildWhen: (p, c) => p.error != c.error,
                    builder: (context, state) {
                      if (state.error == null) return const SizedBox.shrink();
                      return Container(
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
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Preview and swap buttons
                  const ActionButtons(),
                  const SizedBox(height: 16),

                  // Swap preview section
                  const Expanded(child: SwapPreviewSection()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SellAssetDropdown extends StatelessWidget {
  const SellAssetDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapExecutionBloc, SwapExecutionState>(
      buildWhen: (p, c) => p.sellAsset != c.sellAsset,
      builder: (context, state) {
        return AssetDropdown(
          selectedAsset: state.sellAsset,
          hintText: 'Sell Asset',
          onChanged: (asset) {
            context.read<SwapExecutionBloc>().add(SellAssetSelected(asset));
          },
        );
      },
    );
  }
}

class BuyAssetDropdown extends StatelessWidget {
  const BuyAssetDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapExecutionBloc, SwapExecutionState>(
      buildWhen: (p, c) => p.buyAsset != c.buyAsset,
      builder: (context, state) {
        return AssetDropdown(
          selectedAsset: state.buyAsset,
          hintText: 'Buy Asset',
          onChanged: (asset) {
            context.read<SwapExecutionBloc>().add(BuyAssetSelected(asset));
          },
        );
      },
    );
  }
}

class VolumeInput extends StatefulWidget {
  const VolumeInput({super.key});

  @override
  State<VolumeInput> createState() => _VolumeInputState();
}

class _VolumeInputState extends State<VolumeInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapExecutionBloc, SwapExecutionState>(
      buildWhen: (p, c) => p.sellAsset != c.sellAsset,
      builder: (context, state) {
        return TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Volume',
            hintText:
                state.sellAsset != null
                    ? 'Amount of ${state.sellAsset!.id.id}'
                    : 'Select sell asset first',
            border: const OutlineInputBorder(),
            suffixText: state.sellAsset?.id.id,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          onChanged: (value) {
            if (value.isNotEmpty) {
              try {
                final volume = Decimal.parse(value);
                context.read<SwapExecutionBloc>().add(VolumeChanged(volume));
              } catch (e) {
                // Invalid decimal format
              }
            }
          },
        );
      },
    );
  }
}

class PriceInput extends StatefulWidget {
  const PriceInput({super.key});

  @override
  State<PriceInput> createState() => _PriceInputState();
}

class _PriceInputState extends State<PriceInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapExecutionBloc, SwapExecutionState>(
      buildWhen:
          (p, c) => p.buyAsset != c.buyAsset || p.sellAsset != c.sellAsset,
      builder: (context, state) {
        final buyAsset = state.buyAsset?.id.id;
        final sellAsset = state.sellAsset?.id.id;

        return TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Price',
            hintText:
                buyAsset != null && sellAsset != null
                    ? 'Price per $sellAsset in $buyAsset'
                    : 'Select both assets first',
            border: const OutlineInputBorder(),
            suffixText:
                buyAsset != null && sellAsset != null
                    ? '$buyAsset/$sellAsset'
                    : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          onChanged: (value) {
            if (value.isNotEmpty) {
              try {
                final price = Decimal.parse(value);
                context.read<SwapExecutionBloc>().add(PriceChanged(price));
              } catch (e) {
                // Invalid decimal format
              }
            }
          },
        );
      },
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapExecutionBloc, SwapExecutionState>(
      builder: (context, state) {
        if (state.hasActiveSwap) {
          return Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<SwapExecutionBloc>().add(
                      const SwapCancelRequested(),
                    );
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Swap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<SwapExecutionBloc>().add(const ResetSwap());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    state.canPreview
                        ? () {
                          context.read<SwapExecutionBloc>().add(
                            const PreviewSwapRequested(),
                          );
                        }
                        : null,
                icon:
                    state.isLoadingPreview
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.preview),
                label: const Text('Preview Swap'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    state.canSwap
                        ? () {
                          context.read<SwapExecutionBloc>().add(
                            const SwapRequested(),
                          );
                        }
                        : null,
                icon:
                    state.isSwapping
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.swap_horiz),
                label: const Text('Execute Swap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SwapPreviewSection extends StatelessWidget {
  const SwapPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwapExecutionBloc, SwapExecutionState>(
      builder: (context, state) {
        if (state.swapProgress != null) {
          return SwapProgressWidget(progress: state.swapProgress!);
        }

        if (state.swapPreview != null) {
          return SwapPreviewWidget(preview: state.swapPreview!);
        }

        return const Center(
          child: Text(
            'Select assets and enter trade parameters to preview swap',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      },
    );
  }
}

class SwapPreviewWidget extends StatelessWidget {
  const SwapPreviewWidget({required this.preview, super.key});

  final SwapPreview preview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Swap Preview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFeeRow('Base Coin Fee', preview.baseCoinFee),
          _buildFeeRow('Rel Coin Fee', preview.relCoinFee),
          if (preview.takerFee != null)
            _buildFeeRow('Taker Fee', preview.takerFee!),
          if (preview.feeToSendTakerFee != null)
            _buildFeeRow('Fee to Send Taker Fee', preview.feeToSendTakerFee!),
          const Divider(),
          _buildFeeRow('Volume', TradingFee(coin: '', amount: preview.volume)),
          const SizedBox(height: 16),
          const Text(
            'Total Fees:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...preview.totalFees.map((fee) => _buildFeeRow('', fee)),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, TradingFee fee) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.isNotEmpty ? '$label:' : '• ${fee.coin}:'),
          Text('${fee.amount} ${fee.coin}'),
        ],
      ),
    );
  }
}

class SwapProgressWidget extends StatelessWidget {
  const SwapProgressWidget({required this.progress, super.key});

  final SwapProgress progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Swap Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildStatusChip(context, progress.status),
            ],
          ),
          const SizedBox(height: 16),
          if (progress.uuid != null)
            Text(
              'UUID: ${progress.uuid}',
              style: const TextStyle(fontSize: 12),
            ),
          const SizedBox(height: 8),
          Text(progress.message, style: const TextStyle(fontSize: 14)),
          if (progress.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error: ${progress.errorMessage}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ],
          if (progress.swapResult != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Swap Result:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // Add swap result details here based on SwapResult structure
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, SwapStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case SwapStatus.initializing:
      case SwapStatus.searchingForOrders:
      case SwapStatus.placingMakerOrder:
      case SwapStatus.placingTakerOrder:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.hourglass_empty;
        break;
      case SwapStatus.inProgress:
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        icon = Icons.sync;
        break;
      case SwapStatus.complete:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case SwapStatus.error:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.error;
        break;
    }

    return Chip(
      avatar: Icon(icon, color: textColor, size: 16),
      label: Text(
        status.toString().split('.').last.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 12),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
