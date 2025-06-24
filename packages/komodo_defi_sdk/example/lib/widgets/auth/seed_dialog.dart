// seed_dialog.dart
import 'package:flutter/material.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class SeedDialog extends StatefulWidget {
  const SeedDialog({
    required this.isHdMode,
    required this.onRegister,
    required this.sdk,
    required this.walletName,
    required this.password,
    super.key,
  });

  final bool isHdMode;
  final Future<void> Function(String input, bool isEncrypted) onRegister;
  final KomodoDefiSdk sdk;
  final String walletName;
  final String password;

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

    final failedReason = widget.sdk.mnemonicValidator.validateMnemonic(
      mnemonicController.text,
      isHd: widget.isHdMode,
      allowCustomSeed: allowCustomSeed && !widget.isHdMode,
    );

    setState(() {
      switch (failedReason) {
        case MnemonicFailedReason.empty:
          errorMessage = 'Mnemonic cannot be empty';
          isBip39 = null;
        case MnemonicFailedReason.customNotSupportedForHd:
          errorMessage = 'HD wallets require a valid BIP39 seed phrase';
          isBip39 = false;
        case MnemonicFailedReason.customNotAllowed:
          errorMessage =
              'Custom seeds are not allowed. Enable custom seeds or use a valid BIP39 seed phrase';
          isBip39 = false;
        case MnemonicFailedReason.invalidLength:
          errorMessage = 'Invalid seed length. Must be 12 or 24 words';
          isBip39 = false;
        case null:
          errorMessage = null;
          isBip39 = widget.sdk.mnemonicValidator.validateBip39(
            mnemonicController.text,
          );
      }
    });
  }

  bool get canSubmit =>
      errorMessage == null &&
      (mnemonicController.text.isEmpty ||
          isMnemonicEncrypted ||
          !widget.isHdMode ||
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
          if (widget.isHdMode && !isMnemonicEncrypted) ...[
            const Text(
              'HD wallets require a valid BIP39 seed phrase.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.isHdMode && isMnemonicEncrypted) ...[
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
          if (!widget.isHdMode && !isMnemonicEncrypted) ...[
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
          onPressed: () => Navigator.of(context).pop<bool>(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('dialog_register_button'),
          onPressed: canSubmit ? () async => _onSubmit() : null,
          child: const Text('Register'),
        ),
      ],
    );
  }

  Future<void> _onSubmit() async {
    if (!canSubmit) return;

    widget.onRegister(mnemonicController.text, isMnemonicEncrypted).ignore();

    Navigator.of(context).pop<bool>(true);
  }
}
