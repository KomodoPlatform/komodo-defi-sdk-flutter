import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/blocs/auth/auth_bloc.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/auth_form_widget.dart';
import 'package:kdf_sdk_example/main.dart';
import 'package:kdf_sdk_example/screens/bridge_page.dart';
import 'package:kdf_sdk_example/screens/orderbook_page.dart';
import 'package:kdf_sdk_example/screens/swap_history_page.dart';
import 'package:kdf_sdk_example/screens/swap_page.dart';
import 'package:kdf_sdk_example/widgets/assets/instance_assets_list.dart';
import 'package:kdf_sdk_example/widgets/auth/seed_dialog.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/instance_status.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/logged_in_view_widget.dart';
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
  final String state;
  final String statusMessage;
  final TextEditingController searchController;
  final List<Asset> filteredAssets;
  final void Function(Asset) onNavigateToAsset;

  @override
  State<InstanceView> createState() => _InstanceViewState();
}

class _InstanceViewState extends State<InstanceView> {
  String? _mnemonic;
  int _selectedMenuIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthKnownUsersFetched());
    context.read<AuthBloc>().add(const AuthInitialStateChecked());
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
    } on AuthException catch (e) {
      _showError('Delete wallet failed: ${e.message}');
    } catch (e) {
      _showError('Delete wallet failed: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _signOut() {
    context.read<AuthBloc>().add(const AuthSignedOut());
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
                    Navigator.of(context).pop('');
                  },
                  child: const Text('Standard Wallet'),
                ),
                FilledButton(
                  onPressed: () {
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.error) {
          _showError(state.errorMessage ?? 'Unknown error');
        }

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
        } else if (state.isTrezorAwaitingConfirmation) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.trezorMessage ?? 'Please confirm on your Trezor device',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
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
                  child: AuthForm(instance: widget.instance),
                ),
              )
            else
              Expanded(
                child: LoggedInView(
                  selectedMenuIndex: _selectedMenuIndex,
                  mnemonic: _mnemonic,
                  onSignOut: _signOut,
                  onGetMnemonic: _getMnemonic,
                  onCloseMnemonic: () => setState(() => _mnemonic = null),
                  onMenuChanged:
                      (index) => setState(() => _selectedMenuIndex = index),
                  onMnemonicTap: () {
                    Clipboard.setData(ClipboardData(text: _mnemonic!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mnemonic copied to clipboard'),
                      ),
                    );
                  },
                  filteredAssets: widget.filteredAssets,
                  searchController: widget.searchController,
                  onNavigateToAsset: widget.onNavigateToAsset,
                  authOptions: currentUser!.walletId.authOptions,
                ),
              ),
          ],
        );
      },
    );
  }
}

class AuthForm extends StatefulWidget {
  const AuthForm({required this.instance, super.key});

  final KdfInstanceState instance;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _walletNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isHdMode = true;

  @override
  void dispose() {
    _walletNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignedIn(
          walletName: _walletNameController.text,
          password: _passwordController.text,
          derivationMethod:
              _isHdMode ? DerivationMethod.hdWallet : DerivationMethod.iguana,
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
    } on AuthException catch (e) {
      _showError('Delete wallet failed: ${e.message}');
    } catch (e) {
      _showError('Delete wallet failed: $e');
    }
  }

  void _initializeTrezor() {
    context.read<AuthBloc>().add(
      const AuthTrezorInitAndAuthStarted(
        derivationMethod: DerivationMethod.hdWallet,
      ),
    );
  }

  void _onSelectKnownUser(KdfUser user) {
    context.read<AuthBloc>().add(AuthKnownUserSelected(user));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final knownUsers = context.read<AuthBloc>().knownUsers;
        final isLoading =
            state.status == AuthStatus.loading ||
            state.status == AuthStatus.signingOut;
        final isTrezorInitializing = state.isTrezorInitializing;
        final trezorMessage = state.trezorMessage;
        final trezorTaskId = state.trezorTaskId;

        if (state.status == AuthStatus.unauthenticated &&
            state.selectedUser != null) {
          _walletNameController.text = state.walletName;
          _passwordController.clear();
          _isHdMode = state.isHdMode;
        }

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
                      knownUsers
                          .map(
                            (user) => ActionChip(
                              key: Key(user.walletId.compoundId),
                              onPressed: () => _onSelectKnownUser(user),
                              label: Text(user.walletId.name),
                            ),
                          )
                          .toList(),
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
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
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
                        : (value) => setState(() => _isHdMode = value),
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
                      onPressed: _signIn,
                      child: const Text('Sign In'),
                    ),
                    FilledButton(
                      key: const Key('register_button'),
                      onPressed: _showSeedDialog,
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
                if (isTrezorInitializing) ...[
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
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
                              trezorMessage ?? 'Initializing Trezor...',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          if (trezorTaskId != null)
                            TextButton(
                              onPressed:
                                  () => context.read<AuthBloc>().add(
                                    AuthTrezorCancelled(taskId: trezorTaskId),
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
                      onPressed:
                          isTrezorInitializing ? null : _initializeTrezor,
                      icon:
                          isTrezorInitializing
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.security),
                      label: Text(
                        isTrezorInitializing ? 'Initializing...' : 'Use Trezor',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class LoggedInView extends StatelessWidget {
  const LoggedInView({
    required this.selectedMenuIndex,
    required this.mnemonic,
    required this.onSignOut,
    required this.onGetMnemonic,
    required this.onCloseMnemonic,
    required this.onMenuChanged,
    required this.onMnemonicTap,
    required this.filteredAssets,
    required this.searchController,
    required this.onNavigateToAsset,
    required this.authOptions,
    super.key,
  });

  final int selectedMenuIndex;
  final String? mnemonic;
  final VoidCallback onSignOut;
  final void Function({required bool encrypted}) onGetMnemonic;
  final VoidCallback onCloseMnemonic;
  final ValueChanged<int> onMenuChanged;
  final VoidCallback onMnemonicTap;
  final List<Asset> filteredAssets;
  final TextEditingController searchController;
  final void Function(Asset) onNavigateToAsset;
  final AuthOptions authOptions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        if (isDesktop) {
          return SideMenuLayout(
            selectedMenuIndex: selectedMenuIndex,
            onMenuChanged: onMenuChanged,
            mnemonic: mnemonic,
            onSignOut: onSignOut,
            onGetMnemonic: onGetMnemonic,
            onCloseMnemonic: onCloseMnemonic,
            onMnemonicTap: onMnemonicTap,
            filteredAssets: filteredAssets,
            searchController: searchController,
            onNavigateToAsset: onNavigateToAsset,
            authOptions: authOptions,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onSignOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
                if (mnemonic == null) ...[
                  FilledButton.tonal(
                    onPressed: () => onGetMnemonic(encrypted: false),
                    child: const Text('Get Plaintext Mnemonic'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => onGetMnemonic(encrypted: true),
                    child: const Text('Get Encrypted Mnemonic'),
                  ),
                ],
              ],
            ),
            if (mnemonic != null) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  subtitle: Text(mnemonic!),
                  leading: const Icon(Icons.copy),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onCloseMnemonic,
                  ),
                  onTap: onMnemonicTap,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: BottomNavLayout(
                selectedMenuIndex: selectedMenuIndex,
                onMenuChanged: onMenuChanged,
                filteredAssets: filteredAssets,
                searchController: searchController,
                onNavigateToAsset: onNavigateToAsset,
                authOptions: authOptions,
              ),
            ),
          ],
        );
      },
    );
  }
}

class SideMenuLayout extends StatelessWidget {
  const SideMenuLayout({
    required this.selectedMenuIndex,
    required this.onMenuChanged,
    required this.mnemonic,
    required this.onSignOut,
    required this.onGetMnemonic,
    required this.onCloseMnemonic,
    required this.onMnemonicTap,
    required this.filteredAssets,
    required this.searchController,
    required this.onNavigateToAsset,
    required this.authOptions,
    super.key,
  });

  final int selectedMenuIndex;
  final ValueChanged<int> onMenuChanged;
  final String? mnemonic;
  final VoidCallback onSignOut;
  final void Function({required bool encrypted}) onGetMnemonic;
  final VoidCallback onCloseMnemonic;
  final VoidCallback onMnemonicTap;
  final List<Asset> filteredAssets;
  final TextEditingController searchController;
  final void Function(Asset) onNavigateToAsset;
  final AuthOptions authOptions;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          child: Card(
            child: Column(
              children: [
                MenuButton(
                  index: 0,
                  icon: Icons.account_balance_wallet,
                  label: 'Wallet',
                  isSelected: selectedMenuIndex == 0,
                  onTap: onMenuChanged,
                ),
                MenuButton(
                  index: 1,
                  icon: Icons.swap_horiz,
                  label: 'Swap',
                  isSelected: selectedMenuIndex == 1,
                  onTap: onMenuChanged,
                ),
                MenuButton(
                  index: 2,
                  icon: Icons.book,
                  label: 'Orderbook',
                  isSelected: selectedMenuIndex == 2,
                  onTap: onMenuChanged,
                ),
                MenuButton(
                  index: 3,
                  icon: Icons.call_split,
                  label: 'Bridge',
                  isSelected: selectedMenuIndex == 3,
                  onTap: onMenuChanged,
                ),
                MenuButton(
                  index: 4,
                  icon: Icons.history,
                  label: 'Swap History',
                  isSelected: selectedMenuIndex == 4,
                  onTap: onMenuChanged,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onSignOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                  ),
                  if (mnemonic == null) ...[
                    FilledButton.tonal(
                      onPressed: () => onGetMnemonic(encrypted: false),
                      child: const Text('Get Plaintext Mnemonic'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => onGetMnemonic(encrypted: true),
                      child: const Text('Get Encrypted Mnemonic'),
                    ),
                  ],
                ],
              ),
              if (mnemonic != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    subtitle: Text(mnemonic!),
                    leading: const Icon(Icons.copy),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onCloseMnemonic,
                    ),
                    onTap: onMnemonicTap,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: SelectedContent(
                  selectedMenuIndex: selectedMenuIndex,
                  filteredAssets: filteredAssets,
                  searchController: searchController,
                  onNavigateToAsset: onNavigateToAsset,
                  authOptions: authOptions,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BottomNavLayout extends StatelessWidget {
  const BottomNavLayout({
    required this.selectedMenuIndex,
    required this.onMenuChanged,
    required this.filteredAssets,
    required this.searchController,
    required this.onNavigateToAsset,
    required this.authOptions,
    super.key,
  });

  final int selectedMenuIndex;
  final ValueChanged<int> onMenuChanged;
  final List<Asset> filteredAssets;
  final TextEditingController searchController;
  final void Function(Asset) onNavigateToAsset;
  final AuthOptions authOptions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SelectedContent(
            selectedMenuIndex: selectedMenuIndex,
            filteredAssets: filteredAssets,
            searchController: searchController,
            onNavigateToAsset: onNavigateToAsset,
            authOptions: authOptions,
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedMenuIndex,
            onTap: onMenuChanged,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz),
                label: 'Swap',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.call_split),
                label: 'Bridge',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MenuButton extends StatelessWidget {
  const MenuButton({
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: isSelected,
      onTap: () => onTap(index),
    );
  }
}

class SelectedContent extends StatelessWidget {
  const SelectedContent({
    required this.selectedMenuIndex,
    required this.filteredAssets,
    required this.searchController,
    required this.onNavigateToAsset,
    required this.authOptions,
    super.key,
  });

  final int selectedMenuIndex;
  final List<Asset> filteredAssets;
  final TextEditingController searchController;
  final void Function(Asset) onNavigateToAsset;
  final AuthOptions authOptions;

  @override
  Widget build(BuildContext context) {
    switch (selectedMenuIndex) {
      case 0:
        return InstanceAssetList(
          assets: filteredAssets,
          searchController: searchController,
          onAssetSelected: onNavigateToAsset,
          authOptions: authOptions,
        );
      case 1:
        return const SwapPage();
      case 2:
        return const OrderbookPage();
      case 3:
        return const BridgePage();
      case 4:
        return const SwapHistoryScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}
