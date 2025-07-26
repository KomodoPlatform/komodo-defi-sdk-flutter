import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class PrivateKeysDisplayWidget extends StatelessWidget {
  const PrivateKeysDisplayWidget({
    required this.privateKeys,
    required this.onClose,
    this.title = 'Private Keys Export',
    super.key,
  });

  final Map<AssetId, List<PrivateKey>> privateKeys;
  final VoidCallback onClose;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (privateKeys.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: const Icon(Icons.vpn_key, color: Colors.red),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${privateKeys.length} assets exported'),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
          ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: privateKeys.length,
              itemBuilder: (context, index) {
                final entry = privateKeys.entries.elementAt(index);
                final assetId = entry.key;
                final privateKeyList = entry.value;

                return ExpansionTile(
                  leading: const Icon(Icons.currency_bitcoin, size: 20),
                  title: Text(
                    assetId.id,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text('${privateKeyList.length} keys'),
                  children:
                      privateKeyList.map((privateKey) {
                        return _PrivateKeyItem(
                          privateKey: privateKey,
                          assetId: assetId,
                        );
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SingleAssetPrivateKeysDisplayWidget extends StatelessWidget {
  const SingleAssetPrivateKeysDisplayWidget({
    required this.privateKeys,
    required this.assetId,
    required this.onClose,
    super.key,
  });

  final List<PrivateKey> privateKeys;
  final AssetId assetId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    if (privateKeys.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.red.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: const Icon(Icons.vpn_key, color: Colors.red),
            title: Text(
              '${assetId.id} Private Key Export',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${privateKeys.length} keys exported'),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
          ),
          const Divider(height: 1),
          ...privateKeys.map((privateKey) {
            return _PrivateKeyItem(
              privateKey: privateKey,
              assetId: assetId,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            );
          }),
        ],
      ),
    );
  }
}

class _PrivateKeyItem extends StatelessWidget {
  const _PrivateKeyItem({
    required this.privateKey,
    required this.assetId,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
  });

  final PrivateKey privateKey;
  final AssetId assetId;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final derivationPath = privateKey.hdInfo?.derivationPath;
    final displayText =
        'Private Key: ${privateKey.privateKey}\n'
        'Public Key: ${privateKey.publicKey}'
        '${derivationPath != null ? '\nPath: $derivationPath' : ''}';

    return ListTile(
      contentPadding: padding,
      leading: Icon(
        Icons.key,
        size: padding.horizontal > 20 ? 16 : 20,
        color: Colors.red,
      ),
      title: Text(
        derivationPath ?? 'Legacy Address',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: padding.horizontal > 20 ? 12 : 14,
        ),
      ),
      subtitle: Text(
        'Public: ${privateKey.publicKey}',
        style: TextStyle(fontSize: padding.horizontal > 20 ? 10 : 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(Icons.copy, size: padding.horizontal > 20 ? 16 : 20),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: displayText));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Private key for ${assetId.id} copied to clipboard',
              ),
            ),
          );
        },
      ),
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('${assetId.id} Private Key'),
                content: SingleChildScrollView(
                  child: SelectableText(displayText),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: displayText));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Private key for ${assetId.id} copied'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                ],
              ),
        );
      },
    );
  }
}
