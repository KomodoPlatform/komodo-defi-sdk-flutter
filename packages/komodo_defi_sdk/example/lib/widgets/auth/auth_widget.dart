// lib/widgets/auth/auth_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kdf_sdk_example/widgets/auth/seed_dialog.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AuthWidget extends StatefulWidget {
  const AuthWidget({
    required this.sdk,
    required this.knownUsers,
    required this.onUserChanged,
    super.key,
  });

  final KomodoDefiSdk sdk;
  final List<KdfUser> knownUsers;
  final ValueChanged<KdfUser?> onUserChanged;

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  final _walletNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isHdMode = true;
  bool _obscurePassword = true;
  String? _error;
  String? _mnemonic;

  @override
  void dispose() {
    _walletNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    try {
      setState(() => _error = null);

      final user = await widget.sdk.auth.signIn(
        walletName: _walletNameController.text,
        password: _passwordController.text,
        options: AuthOptions(
          derivationMethod:
              _isHdMode ? DerivationMethod.hdWallet : DerivationMethod.iguana,
        ),
      );

      widget.onUserChanged(user);
    } on AuthException catch (e) {
      setState(() => _error = 'Auth Error: ${e.message}');
    } catch (e) {
      setState(() => _error = 'Unexpected error: $e');
    }
  }

  Future<void> _handleRegistration(String input, bool isEncrypted) async {
    Mnemonic? mnemonic;

    if (input.isNotEmpty) {
      if (isEncrypted) {
        final parsedMnemonic = EncryptedMnemonicData.tryParse(
          tryParseJson(input) ?? {},
        );
        if (parsedMnemonic != null) {
          mnemonic = Mnemonic.encrypted(parsedMnemonic);
        } else {
          setState(() => _error = 'Invalid encrypted mnemonic data.');
          return;
        }
      } else {
        mnemonic = Mnemonic.plaintext(input);
      }
    }

    try {
      final user = await widget.sdk.auth.register(
        walletName: _walletNameController.text,
        password: _passwordController.text,
        options: AuthOptions(
          derivationMethod:
              _isHdMode ? DerivationMethod.hdWallet : DerivationMethod.iguana,
        ),
        mnemonic: mnemonic,
      );

      widget.onUserChanged(user);
    } on AuthException catch (e) {
      setState(() {
        _error =
            e.type == AuthExceptionType.invalidWalletPassword
                ? 'HD mode requires a valid BIP39 seed phrase. The imported encrypted seed is not compatible.'
                : 'Registration failed: ${e.message}';
      });
    }
  }

  void _onSelectKnownUser(KdfUser user) {
    setState(() {
      _walletNameController.text = user.walletId.name;
      _passwordController.text = '';
      _isHdMode =
          user.authOptions.derivationMethod == DerivationMethod.hdWallet;
    });
  }

  Future<void> _showSeedDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => SeedDialog(
            isHdMode: _isHdMode,
            onRegister: _handleRegistration,
            sdk: widget.sdk,
            walletName: _walletNameController.text,
            password: _passwordController.text,
          ),
    );

    if (result != true) return;

    setState(() {
      _walletNameController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        if (widget.knownUsers.isNotEmpty) ...[
          Text(
            'Saved Wallets:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                widget.knownUsers.map((user) {
                  return ActionChip(
                    key: Key(user.walletId.compoundId),
                    onPressed: () => _onSelectKnownUser(user),
                    label: Text(user.walletId.name),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        TextFormField(
          controller: _walletNameController,
          decoration: const InputDecoration(labelText: 'Wallet Name'),
          validator: _validator,
        ),
        TextFormField(
          controller: _passwordController,
          validator: _validator,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
          obscureText: _obscurePassword,
        ),
        SwitchListTile(
          title: const Row(
            children: [
              Text('HD Wallet Mode'),
              SizedBox(width: 8),
              Tooltip(
                message:
                    'HD wallets require a valid BIP39 seed phrase.\n'
                    'NB! Your addresses and balances will be different '
                    'in HD mode.',
                child: Icon(Icons.info, size: 16),
              ),
            ],
          ),
          subtitle: const Text('Enable HD multi-address mode'),
          value: _isHdMode,
          onChanged: (value) {
            setState(() => _isHdMode = value);
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilledButton.tonal(
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
            FilledButton(
              onPressed: _showSeedDialog,
              child: const Text('Register'),
            ),
          ],
        ),
      ],
    );
  }

  String? _validator(String? value) {
    if (value?.isEmpty ?? true) {
      return 'This field is required';
    }
    return null;
  }
}
