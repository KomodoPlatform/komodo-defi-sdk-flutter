import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/auth/auth_bloc.dart';
import 'package:kdf_sdk_example/main.dart';
import 'package:kdf_sdk_example/widgets/assets/instance_assets_list.dart';
import 'package:kdf_sdk_example/widgets/auth/seed_dialog.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/instance_status.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class InstanceView extends StatefulWidget {
  const InstanceView({
    required this.instance,
    required this.state,
    required this.statusMessage,
    required this.searchController,
    required this.filteredAssets,
    required this.onNavigateToAsset,
    super.key,
  });

  final KdfInstanceState instance;
  final InstanceState state;
  final String statusMessage;
  final TextEditingController searchController;
  final List<Asset> filteredAssets;
  final void Function(Asset) onNavigateToAsset;

  @override
  State<InstanceView> createState() => _InstanceViewState();
}

class _InstanceViewState extends State<InstanceView> {
  final _formKey = GlobalKey<FormState>();
  final _walletNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isHdMode = true;
  bool _isTrezorInitializing = false;
  String? _mnemonic;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthKnownUsersFetched());
    context.read<AuthBloc>().add(const AuthInitialStateChecked());
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  Future<void> _deleteWallet(String walletName) async {
    if (walletName.isEmpty) {
      _showError('Wallet name is required');
      return;
    }
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Wallet'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter the wallet password to confirm deletion. This action cannot be undone.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await widget.instance.sdk.auth.deleteWallet(
        walletName: walletName,
        password: passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Wallet deleted')));
        context.read<AuthBloc>().add(const AuthKnownUsersFetched());
      }
      setState(() => _mnemonic = null);
    } on AuthException catch (e) {
      _showError('Delete wallet failed: ${e.message}');
    } catch (e) {
      _showError('Delete wallet failed: $e');
    }
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

  void _initializeTrezor() {
    setState(() => _isTrezorInitializing = true);
    context.read<AuthBloc>().add(
      const AuthTrezorInitAndAuthStarted(
        derivationMethod: DerivationMethod.hdWallet,
      ),
    );
  }

  Future<void> _showTrezorPinDialog(int taskId, String? message) async {
    final pinController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) {
                // Handle back button press - trigger cancel action
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(
                  AuthTrezorCancelled(taskId: taskId),
                );
              }
            },
            child: AlertDialog(
              title: const Text('Trezor PIN Required'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message ?? 'Please enter your Trezor PIN'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    decoration: const InputDecoration(
                      labelText: 'PIN',
                      border: OutlineInputBorder(),
                      helperText: 'Use the PIN pad on your Trezor device',
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<AuthBloc>().add(
                      AuthTrezorCancelled(taskId: taskId),
                    );
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final pin = pinController.text;
                    Navigator.of(context).pop(pin);
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
    );

    if (result != null && mounted) {
      context.read<AuthBloc>().add(
        AuthTrezorPinProvided(taskId: taskId, pin: result),
      );
    }
  }

  Future<void> _showTrezorPassphraseDialog(int taskId, String? message) async {
    final passphraseController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) {
                // Handle back button press - trigger cancel action
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(
                  AuthTrezorCancelled(taskId: taskId),
                );
              }
            },
            child: AlertDialog(
              title: const Text('Trezor Passphrase Required'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message ?? 'Please choose your passphrase option'),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose your passphrase configuration:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passphraseController,
                    decoration: const InputDecoration(
                      labelText: 'Hidden passphrase (optional)',
                      border: OutlineInputBorder(),
                      helperText:
                          'Enter your passphrase or leave empty for standard wallet',
                    ),
                    obscureText: true,
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<AuthBloc>().add(
                      AuthTrezorCancelled(taskId: taskId),
                    );
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    // Standard wallet with empty passphrase
                    Navigator.of(context).pop('');
                  },
                  child: const Text('Standard Wallet'),
                ),
                FilledButton(
                  onPressed: () {
                    // Hidden passphrase wallet
                    final passphrase = passphraseController.text;
                    Navigator.of(context).pop(passphrase);
                  },
                  child: const Text('Hidden Wallet'),
                ),
              ],
            ),
          ),
    );

    if (result != null && mounted) {
      context.read<AuthBloc>().add(
        AuthTrezorPassphraseProvided(taskId: taskId, passphrase: result),
      );
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.error) {
          _showError(state.errorMessage ?? 'Unknown error');
          setState(() => _isTrezorInitializing = false);
        }

        // Update form fields when user is selected
        if (state.status == AuthStatus.unauthenticated &&
            state.selectedUser != null) {
          _walletNameController.text = state.walletName;
          _passwordController.clear();
          setState(() {
            _isHdMode = state.isHdMode;
            _isTrezorInitializing = false;
          });
        }

        // Handle Trezor-specific states
        if (state.isTrezorPinRequired) {
          _showTrezorPinDialog(
            state.trezorTaskId!,
            state.trezorMessage ?? 'Enter PIN',
          );
        } else if (state.isTrezorPassphraseRequired) {
          _showTrezorPassphraseDialog(
            state.trezorTaskId!,
            state.trezorMessage ?? 'Enter Passphrase',
          );
        } else if (state.isTrezorInitializing) {
          // Keep the initializing state
        } else if (state.isTrezorAwaitingConfirmation) {
          // Show a non-blocking message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.trezorMessage ?? 'Please confirm on your Trezor device',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state.status == AuthStatus.authenticated ||
            state.status == AuthStatus.unauthenticated) {
          setState(() => _isTrezorInitializing = false);
        }
      },
      builder: (context, state) {
        final currentUser =
            state.status == AuthStatus.authenticated ? state.user : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InstanceStatus(instance: widget.instance),
            const SizedBox(height: 16),
            Text(widget.statusMessage),
            if (currentUser != null) ...[
              Text(
                currentUser.isHd ? 'HD' : 'Legacy',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            if (currentUser == null)
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: _buildAuthForm(state),
                  ),
                ),
              )
            else
              Expanded(child: _buildLoggedInView(currentUser)),
          ],
        );
      },
    );
  }

  Widget _buildLoggedInView(KdfUser currentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilledButton.tonalIcon(
              onPressed:
                  () => context.read<AuthBloc>().add(const AuthSignedOut()),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              key: const Key('sign_out_button'),
            ),
            if (_mnemonic == null) ...[
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
        const SizedBox(height: 16),
        Expanded(
          child: InstanceAssetList(
            assets: widget.filteredAssets,
            searchController: widget.searchController,
            onAssetSelected: widget.onNavigateToAsset,
            authOptions: currentUser.walletId.authOptions,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthForm(AuthState state) {
    final knownUsers = context.read<AuthBloc>().knownUsers;
    final isLoading =
        state.status == AuthStatus.loading ||
        state.status == AuthStatus.signingOut;

    return Column(
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
                        : () => _deleteWallet(_walletNameController.text),
                icon: const Icon(Icons.delete),
                label: const Text('Delete Wallet'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Trezor status message
          if (state.isTrezorInitializing) ...[
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
                        state.trezorMessage ?? 'Initializing Trezor...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (state.trezorTaskId != null)
                      TextButton(
                        onPressed:
                            () => context.read<AuthBloc>().add(
                              AuthTrezorCancelled(taskId: state.trezorTaskId!),
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
    );
  }

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}
