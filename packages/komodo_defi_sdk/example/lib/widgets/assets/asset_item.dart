import 'package:flutter/material.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_ui/komodo_ui.dart';

class AssetItemWidget extends StatelessWidget {
  const AssetItemWidget({
    required this.asset,
    required this.authOptions,
    super.key,
    this.onTap,
  });

  final Asset asset;
  final AuthOptions authOptions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabledReasons = asset.getUnavailableReasons(authOptions);
    final isCompatible = disabledReasons == null;
    final disabledReason = disabledReasons?.map((r) => r.message).join(', ');

    return ListTile(
      key: Key(asset.id.id),
      title: Text(asset.id.id),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(asset.id.name),
          if (disabledReason != null)
            Text(
              disabledReason,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
        ],
      ),
      tileColor: isCompatible ? null : Colors.grey[200],
      leading: AssetIcon(asset.id, size: 32),
      trailing: _AssetItemTrailing(asset: asset, isEnabled: isCompatible),
      // ignore: avoid_redundant_argument_values
      enabled: isCompatible,
      onTap: isCompatible ? onTap : null,
    );
  }
}

class _AssetItemTrailing extends StatelessWidget {
  const _AssetItemTrailing({required this.asset, required this.isEnabled});

  final Asset asset;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isEnabled) ...[
          const Icon(Icons.lock, color: Colors.grey),
          const SizedBox(width: 8),
        ],
        if (asset.supportsMultipleAddresses && isEnabled) ...[
          const Tooltip(
            message: 'Supports multiple addresses',
            child: Icon(Icons.account_balance_wallet),
          ),
          const SizedBox(width: 8),
        ],
        if (asset.requiresHdWallet) ...[
          const Tooltip(message: 'Requires HD wallet', child: Icon(Icons.key)),
          const SizedBox(width: 8),
        ],
        CircleAvatar(
          radius: 12,
          foregroundImage: NetworkImage(
            'https://komodoplatform.github.io/coins/icons/${asset.id.subClass.ticker.toLowerCase()}.png',
          ),
          backgroundColor: Colors.white70,
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_ios),
      ],
    );
  }
}
