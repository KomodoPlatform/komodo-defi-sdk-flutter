import 'package:flutter/material.dart';
import 'package:kdf_sdk_example/widgets/common/security_warning_dialog.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AssetActionsWidget extends StatelessWidget {
  const AssetActionsWidget({
    required this.asset,
    required this.pubkeys,
    required this.currentUser,
    required this.isSigningMessage,
    required this.isExportingPrivateKey,
    required this.onSend,
    required this.onReceive,
    required this.onSignMessage,
    required this.onExportPrivateKey,
    super.key,
  });

  final Asset asset;
  final AssetPubkeys? pubkeys;
  final KdfUser? currentUser;
  final bool isSigningMessage;
  final bool isExportingPrivateKey;
  final VoidCallback? onSend;
  final VoidCallback onReceive;
  final VoidCallback onSignMessage;
  final VoidCallback onExportPrivateKey;

  @override
  Widget build(BuildContext context) {
    final isHdWallet =
        currentUser?.authOptions.derivationMethod == DerivationMethod.hdWallet;
    final hasAddresses = pubkeys != null && pubkeys!.keys.isNotEmpty;
    final supportsSigning = asset.supportsMessageSigning;

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
        Tooltip(
          message:
              supportsSigning
                  ? !hasAddresses
                      ? 'No addresses available to sign with'
                      : isHdWallet
                      ? 'Will sign with the first address'
                      : 'Sign a message with this address'
                  : 'Message signing not supported for this asset',
          child: FilledButton.tonalIcon(
            onPressed:
                isSigningMessage || !hasAddresses || !supportsSigning
                    ? null
                    : onSignMessage,
            icon: const Icon(Icons.edit_document),
            label:
                isSigningMessage
                    ? const Text('Signing...')
                    : const Text('Sign'),
          ),
        ),
        FilledButton.tonalIcon(
          onPressed:
              isExportingPrivateKey
                  ? null
                  : () async {
                    final confirmed = await SecurityWarningDialog.show(
                      context,
                      'Export private key for ${asset.id.id}?',
                    );
                    if (confirmed) {
                      onExportPrivateKey();
                    }
                  },
          icon:
              isExportingPrivateKey
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.vpn_key),
          label: Text(isExportingPrivateKey ? 'Exporting...' : 'Export Key'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red.shade800,
          ),
        ),
      ],
    );
  }
}
