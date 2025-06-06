import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/auth/auth.dart';
import 'package:kdf_sdk_example/main.dart';
import 'package:kdf_sdk_example/widgets/assets/instance_assets_list.dart';
import 'package:kdf_sdk_example/widgets/auth/seed_dialog.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/instance_status.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
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
  StreamSubscription<TrezorInitializationState>? _trezorSubscription;
  TrezorInitializationState? _trezorState;
  TrezorDeviceInfo? _trezorDeviceInfo;

  @override
  void initState() {
    super.initState();
    // Fetch known users on init
    context.read<AuthBloc>().add(const AuthFetchKnownUsers());
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    _passwordController.dispose();
    _trezorSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getMnemonic({required bool encrypted}) async {
    try {
      final mnemonic = encrypted
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
      builder: (context) => AlertDialog(
        title: const Text('Enter Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your wallet password to decrypt the mnemonic:'),
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
            onPressed: () => Navigator.of(context).pop(passwordController.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
      AuthRegister(
        walletName: _walletNameController.text,
        password: _passwordController.text,
        derivationMethod: _isHdMode 
            ? DerivationMethod.hdWallet 
            : DerivationMethod.iguana,
        mnemonic: mnemonic,
        privKeyPolicy: PrivateKeyPolicy.contextPrivKey,
      ),
    );
  }

  void _onSelectKnownUser(KdfUser user) {
    context.read<AuthBloc>().add(AuthSelectKnownUser(user));
  }

  Future<void> _initializeTrezor() async {
    setState(() {
      _isTrezorInitializing = true;
      _trezorState = null;
      _trezorDeviceInfo = null;
    });

    try {
      // Cancel any existing subscription
      await _trezorSubscription?.cancel();

      // Start Trezor initialization
      _trezorSubscription = widget.instance.sdk.trezor
          .initializeDevice()
          .listen(
            _handleTrezorState,
            onError: _handleTrezorError,
            onDone: () {
              if (mounted) {
                setState(() => _isTrezorInitializing = false);
              }
            },
          );
    } catch (e) {
      _showError('Failed to start Trezor initialization: $e');
      if (mounted) {
        setState(() => _isTrezorInitializing = false);
      }
    }
  }

  void _handleTrezorState(TrezorInitializationState state) {
    if (!mounted) return;

    setState(() => _trezorState = state);

    switch (state.status) {
      case TrezorInitializationStatus.pinRequired:
        _showPinDialog(state.taskId!);
      case TrezorInitializationStatus.passphraseRequired:
        _showPassphraseDialog(state.taskId!);
      case TrezorInitializationStatus.completed:
        setState(() {
          _trezorDeviceInfo = state.deviceInfo;
          _isTrezorInitializing = false;
        });
        _handleTrezorAuthAfterInit();
      case TrezorInitializationStatus.error:
        _showError('Trezor error: ${state.error}');
        setState(() => _isTrezorInitializing = false);
      case TrezorInitializationStatus.cancelled:
        setState(() => _isTrezorInitializing = false);
      case TrezorInitializationStatus.initializing:
      case TrezorInitializationStatus.waitingForDevice:
      case TrezorInitializationStatus.waitingForDeviceConfirmation:
        // For these states, just update the UI with the status message
    }
  }

  void _handleTrezorError(dynamic error) {
    if (!mounted) return;
    
    _showError('Trezor initialization failed: $error');
    setState(() => _isTrezorInitializing = false);
  }

  Future<void> _showPinDialog(int taskId) async {
    final pinController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter Trezor PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Look at your Trezor device screen and enter the PIN using the '
              'positions shown on the device (the grid layout).',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
                hintText: 'Enter PIN positions',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.instance.sdk.trezor.cancelInitialization(taskId);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(pinController.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await widget.instance.sdk.trezor.providePin(taskId, result);
      } catch (e) {
        _showError('Failed to provide PIN: $e');
      }
    }
  }

  Future<void> _showPassphraseDialog(int taskId) async {
    final passphraseController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter Trezor Passphrase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your passphrase. Leave empty to use the default wallet '
              'without passphrase.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passphraseController,
              decoration: const InputDecoration(
                labelText: 'Passphrase (optional)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.instance.sdk.trezor.cancelInitialization(taskId);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(passphraseController.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await widget.instance.sdk.trezor.providePassphrase(taskId, result);
      } catch (e) {
        _showError('Failed to provide passphrase: $e');
      }
    }
  }

  Future<void> _handleTrezorAuthAfterInit() async {
    if (_trezorDeviceInfo == null) {
      _showError('Trezor device info not available');
      return;
    }

    const trezorWalletName = 'My Trezor';
    
    // Check if "My Trezor" wallet already exists
    final knownUsers = context.read<AuthBloc>().knownUsers;
    final existingTrezorUser = knownUsers.where(
      (user) => user.walletId.name == trezorWalletName,
    ).firstOrNull;

    if (existingTrezorUser != null) {
      // Sign in with existing Trezor wallet
      context.read<AuthBloc>().add(
        AuthTrezorSignIn(
          walletName: trezorWalletName,
          derivationMethod: 
              existingTrezorUser.walletId.authOptions.derivationMethod,
        ),
      );
    } else {
      // Register new Trezor wallet
      context.read<AuthBloc>().add(
        const AuthTrezorRegister(
          walletName: trezorWalletName,
          derivationMethod: DerivationMethod.hdWallet,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          _showError(state.message);
        }
        
        // Update form fields when user is selected
        if (state is AuthUnauthenticated && state.selectedUser != null) {
          _walletNameController.text = state.walletName;
          _passwordController.clear();
          setState(() {
            _isHdMode = state.isHdMode;
          });
        }
      },
      builder: (context, state) {
        final currentUser = state is AuthAuthenticated ? state.user : null;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InstanceStatus(instance: widget.instance),
            const SizedBox(height: 16),
            Text(widget.statusMessage),
            if (currentUser != null) ...[
              Text(
                'Wallet Mode: ${currentUser.authOptions.derivationMethod == DerivationMethod.hdWallet ? 'HD' : 'Legacy'}',
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
              onPressed: () => context.read<AuthBloc>().add(const AuthSignOut()),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
            if (_mnemonic == null) ...[
              FilledButton.tonal(
                onPressed: () => _getMnemonic(encrypted: false),
                child: const Text('Get Plaintext Mnemonic'),
              ),
              FilledButton.tonal(
                onPressed: () => _getMnemonic(encrypted: true),
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
    final isLoading = state is AuthLoading || state is AuthSigningOut;
    
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
            children: knownUsers.map((user) {
              return ActionChip(
                key: Key(user.walletId.compoundId),
                onPressed: isLoading ? null : () => _onSelectKnownUser(user),
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
          enabled: !isLoading,
        ),
        TextFormField(
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
          onChanged: isLoading ? null : (value) {
            setState(() => _isHdMode = value);
          },
        ),
        const SizedBox(height: 16),
        if (_trezorState != null) ...[
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getTrezorStatusIcon(_trezorState!.status),
                        color: _getTrezorStatusColor(_trezorState!.status),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trezor Status',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _trezorState!.message ?? 'No message',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (_trezorDeviceInfo != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Device: ${_trezorDeviceInfo!.deviceName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (isLoading) ...[
          const Center(
            child: CircularProgressIndicator(),
          ),
          const SizedBox(height: 16),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.tonal(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<AuthBloc>().add(
                      AuthSignIn(
                        walletName: _walletNameController.text,
                        password: _passwordController.text,
                        derivationMethod: _isHdMode 
                            ? DerivationMethod.hdWallet 
                            : DerivationMethod.iguana,
                        privKeyPolicy: PrivateKeyPolicy.contextPrivKey,
                      ),
                    );
                  }
                },
                child: const Text('Sign In'),
              ),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _showSeedDialog();
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _isTrezorInitializing ? null : _initializeTrezor,
                icon: _isTrezorInitializing
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

  IconData _getTrezorStatusIcon(TrezorInitializationStatus status) {
    switch (status) {
      case TrezorInitializationStatus.initializing:
        return Icons.hourglass_empty;
      case TrezorInitializationStatus.waitingForDevice:
        return Icons.usb;
      case TrezorInitializationStatus.waitingForDeviceConfirmation:
        return Icons.touch_app;
      case TrezorInitializationStatus.pinRequired:
        return Icons.pin;
      case TrezorInitializationStatus.passphraseRequired:
        return Icons.key;
      case TrezorInitializationStatus.completed:
        return Icons.check_circle;
      case TrezorInitializationStatus.error:
        return Icons.error;
      case TrezorInitializationStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getTrezorStatusColor(TrezorInitializationStatus status) {
    switch (status) {
      case TrezorInitializationStatus.completed:
        return Colors.green;
      case TrezorInitializationStatus.error:
        return Colors.red;
      case TrezorInitializationStatus.cancelled:
        return Colors.orange;
      case TrezorInitializationStatus.initializing:
      case TrezorInitializationStatus.waitingForDevice:
      case TrezorInitializationStatus.waitingForDeviceConfirmation:
      case TrezorInitializationStatus.pinRequired:
      case TrezorInitializationStatus.passphraseRequired:
        return Colors.blue;
    }
  }
}
