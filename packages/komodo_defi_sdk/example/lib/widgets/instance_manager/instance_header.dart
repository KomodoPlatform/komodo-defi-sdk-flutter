// instance_header.dart
import 'package:flutter/material.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class InstanceHeader extends StatelessWidget {
  const InstanceHeader({
    required this.instance,
    required this.pubkeys,
    required this.onSend,
    required this.onReceive,
    super.key,
  });

  final KdfInstanceState instance;
  final AssetPubkeys? pubkeys;
  final VoidCallback onSend;
  final VoidCallback onReceive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBalanceOverview(context),
        const SizedBox(height: 16),
        _buildActions(context),
      ],
    );
  }

  Widget _buildBalanceOverview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Total', style: Theme.of(context).textTheme.bodyMedium),
            Text(
              (pubkeys?.syncStatus == SyncStatusEnum.inProgress)
                  ? 'Loading...'
                  : (pubkeys?.balance.total.toDouble() ?? 0.0).toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            const SizedBox(width: 128, child: Divider()),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Text(
                      'Available',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      pubkeys?.balance.spendable.toDouble().toString() ?? '0.0',
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      'Locked',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      pubkeys?.balance.unspendable.toDouble().toString() ??
                          '0.0',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 8,
      children: [
        FilledButton.icon(
          onPressed: pubkeys == null ? null : onSend,
          icon: const Icon(Icons.send),
          label: const Text('Send'),
        ),
        FilledButton.tonalIcon(
          onPressed: onReceive,
          icon: const Icon(Icons.qr_code),
          label: const Text('Receive'),
        ),
      ],
    );
  }
}
