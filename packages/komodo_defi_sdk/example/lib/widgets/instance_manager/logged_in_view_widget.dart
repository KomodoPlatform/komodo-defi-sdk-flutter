import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/auth/auth_bloc.dart';
import 'package:kdf_sdk_example/widgets/assets/instance_assets_list.dart';
import 'package:kdf_sdk_example/widgets/common/private_keys_display_widget.dart';
import 'package:kdf_sdk_example/widgets/common/security_warning_dialog.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class LoggedInViewWidget extends StatefulWidget {
  const LoggedInViewWidget({
    required this.currentUser,
    required this.filteredAssets,
    required this.searchController,
    required this.onNavigateToAsset,
    required this.instance,
    super.key,
  });

  final KdfUser currentUser;
  final List<Asset> filteredAssets;
  final TextEditingController searchController;
  final void Function(Asset) onNavigateToAsset;
  final KdfInstanceState instance;

  @override
  State<LoggedInViewWidget> createState() => _LoggedInViewWidgetState();
}

class _LoggedInViewWidgetState extends State<LoggedInViewWidget> {
  String? _mnemonic;
  Map<AssetId, List<PrivateKey>>? _privateKeys;
  bool _isExportingPrivateKeys = false;

  Future<void> _getMnemonic({required bool encrypted}) async {
    try {
      final mnemonic =
          encrypted
              ? await widget.instance.sdk.auth.getMnemonicEncrypted()
              : await _getMnemonicWithPassword();

      if (mnemonic != null && mounted) {
        setState(() => _mnemonic = mnemonic.toJson().toJsonString());
      }
    } catch (e) {
      if (mounted) {
        _showError('Error getting mnemonic: $e');
      }
    }
  }

  Future<Mnemonic?> _getMnemonicWithPassword() async {
    final password = await _showPasswordDialog();
    if (password == null) return null;

    return widget.instance.sdk.auth.getMnemonicPlainText(password);
  }

  Future<String?> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Enter Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your wallet password to decrypt the mnemonic:',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.of(context).pop(passwordController.text),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _exportPrivateKeys() async {
    // Show security warning first
    final confirmed = await SecurityWarningDialog.show(
      context,
      'Are you sure you want to export private keys?',
    );
    if (!confirmed) return;

    setState(() => _isExportingPrivateKeys = true);

    try {
      final privateKeys = await widget.instance.sdk.security.getPrivateKeys();

      if (mounted) {
        setState(() => _privateKeys = privateKeys);
      }
    } catch (e) {
      if (mounted) {
        _showError('Error exporting private keys: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingPrivateKeys = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed:
                  () => context.read<AuthBloc>().add(const AuthSignedOut()),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              key: const Key('sign_out_button'),
            ),
            if (_mnemonic == null && _privateKeys == null) ...[
              FilledButton.tonal(
                onPressed: () => _getMnemonic(encrypted: false),
                key: const Key('get_plaintext_mnemonic_button'),
                child: const Text('Get Plaintext Mnemonic'),
              ),
              FilledButton.tonal(
                onPressed: () => _getMnemonic(encrypted: true),
                key: const Key('get_encrypted_mnemonic_button'),
                child: const Text('Get Encrypted Mnemonic'),
              ),
              FilledButton.tonalIcon(
                onPressed: _isExportingPrivateKeys ? null : _exportPrivateKeys,
                icon:
                    _isExportingPrivateKeys
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.vpn_key),
                label: Text(
                  _isExportingPrivateKeys
                      ? 'Exporting...'
                      : 'Export Private Keys',
                ),
                key: const Key('export_private_keys_button'),
              ),
            ],
          ],
        ),
        if (_mnemonic != null) ...[
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              subtitle: Text(_mnemonic!),
              leading: const Icon(Icons.copy),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _mnemonic = null),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: _mnemonic!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mnemonic copied to clipboard')),
                );
              },
            ),
          ),
        ],
        if (_privateKeys != null) ...[
          const SizedBox(height: 16),
          PrivateKeysDisplayWidget(
            privateKeys: _privateKeys!,
            onClose: () => setState(() => _privateKeys = null),
          ),
        ],
        const SizedBox(height: 16),
        Expanded(
          child: InstanceAssetList(
            assets: widget.filteredAssets,
            searchController: widget.searchController,
            onAssetSelected: widget.onNavigateToAsset,
            authOptions: widget.currentUser.walletId.authOptions,
          ),
        ),
      ],
    );
  }
}
