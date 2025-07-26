import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/auth/auth_bloc.dart';
import 'package:kdf_sdk_example/widgets/auth/seed_dialog.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AuthFormWidget extends StatefulWidget {
  const AuthFormWidget({
    required this.authState,
    required this.onDeleteWallet,
    super.key,
  });

  final AuthState authState;
  final void Function(String) onDeleteWallet;

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _walletNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isHdMode = true;
  bool _isTrezorInitializing = false;

  @override
  void initState() {
    super.initState();
    _updateFormFromState();
  }

  @override
  void didUpdateWidget(AuthFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.authState != oldWidget.authState) {
      _updateFormFromState();
    }
  }

  void _updateFormFromState() {
    final state = widget.authState;
    if (state.status == AuthStatus.unauthenticated &&
        state.selectedUser != null) {
      _walletNameController.text = state.walletName;
      _passwordController.clear();
      setState(() {
        _isHdMode = state.isHdMode;
        _isTrezorInitializing = false;
      });
    }

    if (state.status == AuthStatus.error) {
      setState(() => _isTrezorInitializing = false);
    }

    if (state.isTrezorInitializing) {
      setState(() => _isTrezorInitializing = true);
    } else if (state.status == AuthStatus.authenticated ||
        state.status == AuthStatus.unauthenticated) {
      setState(() => _isTrezorInitializing = false);
    }
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showSeedDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const SeedDialog(),
    );

    if (result != null && mounted) {
      final input = result['input'] as String;
      final isEncrypted = result['isEncrypted'] as bool;
      _handleRegistration(input, isEncrypted);
    }
  }

  void _handleRegistration(String input, bool isEncrypted) {
    Mnemonic? mnemonic;

    if (input.isNotEmpty) {
      if (isEncrypted) {
        final parsedMnemonic = EncryptedMnemonicData.tryParse(
          tryParseJson(input) ?? {},
        );
        if (parsedMnemonic != null) {
          mnemonic = Mnemonic.encrypted(parsedMnemonic);
        }
      } else {
        mnemonic = Mnemonic.plaintext(input);
      }
    }

    context.read<AuthBloc>().add(
      AuthRegistered(
        walletName: _walletNameController.text,
        password: _passwordController.text,
        derivationMethod:
            _isHdMode ? DerivationMethod.hdWallet : DerivationMethod.iguana,
        mnemonic: mnemonic,
      ),
    );
  }

  void _onSelectKnownUser(KdfUser user) {
    context.read<AuthBloc>().add(AuthKnownUserSelected(user));
  }

  void _initializeTrezor() {
    setState(() => _isTrezorInitializing = true);
    context.read<AuthBloc>().add(
      const AuthTrezorInitAndAuthStarted(
        derivationMethod: DerivationMethod.hdWallet,
      ),
    );
  }

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final knownUsers = context.read<AuthBloc>().knownUsers;
    final isLoading =
        widget.authState.status == AuthStatus.loading ||
        widget.authState.status == AuthStatus.signingOut;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (knownUsers.isNotEmpty) ...[
            Text(
              'Saved Wallets:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  knownUsers.map((user) {
                    return ActionChip(
                      key: Key(user.walletId.compoundId),
                      onPressed:
                          isLoading ? null : () => _onSelectKnownUser(user),
                      label: Text(user.walletId.name),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            key: const Key('wallet_name_field'),
            controller: _walletNameController,
            decoration: const InputDecoration(labelText: 'Wallet Name'),
            validator: _validator,
            enabled: !isLoading,
          ),
          TextFormField(
            key: const Key('password_field'),
            controller: _passwordController,
            validator: _validator,
            enabled: !isLoading,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
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
            onChanged:
                isLoading
                    ? null
                    : (value) {
                      setState(() => _isHdMode = value);
                    },
          ),
          const SizedBox(height: 16),
          if (isLoading) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      context.read<AuthBloc>().add(
                        AuthSignedIn(
                          walletName: _walletNameController.text,
                          password: _passwordController.text,
                          derivationMethod:
                              _isHdMode
                                  ? DerivationMethod.hdWallet
                                  : DerivationMethod.iguana,
                        ),
                      );
                    }
                  },
                  child: const Text('Sign In'),
                ),
                FilledButton(
                  key: const Key('register_button'),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _showSeedDialog();
                    }
                  },
                  child: const Text('Register'),
                ),
                FilledButton.tonalIcon(
                  onPressed:
                      _walletNameController.text.isEmpty
                          ? null
                          : () =>
                              widget.onDeleteWallet(_walletNameController.text),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Wallet'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.authState.isTrezorInitializing) ...[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.authState.trezorMessage ??
                              'Initializing Trezor...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      if (widget.authState.trezorTaskId != null)
                        TextButton(
                          onPressed:
                              () => context.read<AuthBloc>().add(
                                AuthTrezorCancelled(
                                  taskId: widget.authState.trezorTaskId!,
                                ),
                              ),
                          child: const Text('Cancel'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _isTrezorInitializing ? null : _initializeTrezor,
                  icon:
                      _isTrezorInitializing
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.security),
                  label: Text(
                    _isTrezorInitializing ? 'Initializing...' : 'Use Trezor',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
