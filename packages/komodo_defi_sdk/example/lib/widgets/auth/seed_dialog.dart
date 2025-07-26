// seed_dialog.dart
import 'package:flutter/material.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SeedDialog extends StatefulWidget {
  const SeedDialog({
    super.key,
  });

  @override
  State<SeedDialog> createState() => _SeedDialogState();
}

class _SeedDialogState extends State<SeedDialog> {
  final mnemonicController = TextEditingController();
  bool isMnemonicEncrypted = false;
  bool allowCustomSeed = false;
  String? errorMessage;
  bool? isBip39;

  @override
  void dispose() {
    mnemonicController.dispose();
    super.dispose();
  }

  void validateInput() {
    if (mnemonicController.text.isEmpty) {
      setState(() {
        errorMessage = null;
        isBip39 = null;
      });
      return;
    }

    if (isMnemonicEncrypted) {
      final parsedMnemonic = EncryptedMnemonicData.tryParse(
        tryParseJson(mnemonicController.text) ?? {},
      );
      if (parsedMnemonic == null) {
        setState(() {
          errorMessage = 'Invalid encrypted mnemonic format';
          isBip39 = null;
        });
      } else {
        setState(() {
          errorMessage = null;
          isBip39 = null;
        });
      }
      return;
    }

    // Basic validation for plaintext mnemonic
    final words = mnemonicController.text.trim().split(' ');
    if (words.length != 12 && words.length != 24) {
      setState(() {
        errorMessage = 'Invalid seed length. Must be 12 or 24 words';
        isBip39 = false;
      });
      return;
    }

    setState(() {
      errorMessage = null;
      isBip39 = true; // Assume valid for simplicity
    });
  }

  bool get canSubmit =>
      errorMessage == null &&
      (mnemonicController.text.isEmpty ||
          isMnemonicEncrypted ||
          isBip39 == true);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Existing Seed?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Do you have an existing seed you would like to import? '
            'Enter it below or leave empty to generate a new seed.',
          ),
          const SizedBox(height: 16),
          if (!isMnemonicEncrypted) ...[
            const Text(
              'HD wallets require a valid BIP39 seed phrase.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
          ],
          if (isMnemonicEncrypted) ...[
            const Text(
              'Note: Encrypted seeds will be verified for BIP39 compatibility after import.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
          ],
          TextFormField(
            minLines: isMnemonicEncrypted ? 3 : 1,
            maxLines: isMnemonicEncrypted ? 4 : 1,
            controller: mnemonicController,
            obscureText: !isMnemonicEncrypted,
            onChanged: (_) => validateInput(),
            decoration: InputDecoration(
              hintText: 'Enter your seed or leave empty for a new one',
              errorText: errorMessage,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Encrypted Seed?'),
            value: isMnemonicEncrypted,
            onChanged: (value) {
              setState(() {
                isMnemonicEncrypted = value;
                validateInput();
              });
            },
          ),
          if (!isMnemonicEncrypted) ...[
            SwitchListTile(
              title: const Text('Allow Custom Seed'),
              subtitle: const Text(
                'Enable to use a non-BIP39 compatible seed phrase',
              ),
              value: allowCustomSeed,
              onChanged: (value) {
                setState(() {
                  allowCustomSeed = value;
                  validateInput();
                });
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('dialog_register_button'),
          onPressed: canSubmit ? _onSubmit : null,
          child: const Text('Register'),
        ),
      ],
    );
  }

  void _onSubmit() {
    if (!canSubmit) return;

    Navigator.of(context).pop({
      'input': mnemonicController.text,
      'isEncrypted': isMnemonicEncrypted,
    });
  }
}