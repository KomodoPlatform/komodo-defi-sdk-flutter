import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kdf_sdk_example/main.dart';
import 'package:kdf_sdk_example/screens/swap_page.dart';
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
    required this.currentUser,
    required this.statusMessage,
    required this.onUserChanged,
    required this.searchController,
    required this.filteredAssets,
    required this.onNavigateToAsset,
    super.key,
  });

  final KdfInstanceState instance;
  final InstanceState state;
  final KdfUser? currentUser;
  final String statusMessage;
  final ValueChanged<KdfUser?> onUserChanged;
  final TextEditingController searchController;
  final List<Asset> filteredAssets;
  final void Function(Asset) onNavigateToAsset;

  @override
  State<InstanceView> createState() => _InstanceViewState();
}

class _InstanceViewState extends State<InstanceView> {
  final _formKey = GlobalKey<FormState>();
  String? _mnemonic;
  Timer? _refreshUsersTimer;
  int _selectedMenuIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshUsersTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchKnownUsers(),
    );
  }

  @override
  void dispose() {
    _refreshUsersTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchKnownUsers() async {
    try {
      final users = await widget.instance.sdk.auth.getUsers();
      if (mounted) {
        setState(() {
          widget.state.knownUsers = users;
        });
      }
    } catch (e) {
      debugPrint('Error fetching known users: $e');
    }
  }

  Future<void> _signIn() async {
    try {
      final user = await widget.instance.sdk.auth.signIn(
        walletName: widget.state.walletNameController.text,
        password: widget.state.passwordController.text,
        options: AuthOptions(
          derivationMethod:
              widget.state.isHdMode
                  ? DerivationMethod.hdWallet
                  : DerivationMethod.iguana,
        ),
      );
      widget.onUserChanged(user);
    } on AuthException catch (e) {
      _showError('Auth Error: ${e.message}');
    } catch (e) {
      _showError('Unexpected error: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await widget.instance.sdk.auth.signOut();
      widget.onUserChanged(null);
      setState(() => _mnemonic = null);
    } catch (e) {
      _showError('Error signing out: $e');
    }
  }

  Future<void> _getMnemonic({required bool encrypted}) async {
    try {
      final mnemonic =
          encrypted
              ? await widget.instance.sdk.auth.getMnemonicEncrypted()
              : await widget.instance.sdk.auth.getMnemonicPlainText(
                widget.state.passwordController.text,
              );

      setState(() {
        _mnemonic = mnemonic.toJson().toJsonString();
      });
    } catch (e) {
      _showError('Error fetching mnemonic: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _showSeedDialog() async {
    if (!_formKey.currentState!.validate()) return; // Add form validation

    await showDialog<void>(
      context: context,
      builder:
          (context) => SeedDialog(
            isHdMode: widget.state.isHdMode,
            sdk: widget.instance.sdk,
            walletName: widget.state.walletNameController.text,
            password: widget.state.passwordController.text,
            onRegister: _handleRegistration,
          ),
    );
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
        }
      } else {
        mnemonic = Mnemonic.plaintext(input);
      }
    }

    try {
      final user = await widget.instance.sdk.auth.register(
        walletName: widget.state.walletNameController.text,
        password: widget.state.passwordController.text,
        options: AuthOptions(
          derivationMethod:
              widget.state.isHdMode
                  ? DerivationMethod.hdWallet
                  : DerivationMethod.iguana,
        ),
        mnemonic: mnemonic,
      );

      widget.onUserChanged(user);
    } on AuthException catch (e) {
      _showError(
        e.type == AuthExceptionType.incorrectPassword
            ? 'HD mode requires a valid BIP39 seed phrase. '
                'The imported encrypted seed is not compatible.'
            : 'Registration failed: ${e.message}',
      );
    }
  }

  void _onSelectKnownUser(KdfUser user) {
    setState(() {
      widget.state.walletNameController.text = user.walletId.name;
      widget.state.passwordController.text = '';
      widget.state.isHdMode = user.isHd;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(widget.statusMessage)),
            const SizedBox(width: 16),
            if (widget.currentUser != null) ...[
              Text(
                '${widget.currentUser!.walletId.name} • '
                '${widget.currentUser!.isHd ? 'HD' : 'Legacy'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
            ],
            InstanceStatus(instance: widget.instance),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.currentUser == null)
          Expanded(
            child: SingleChildScrollView(
              // Wrap the auth form in a Form widget using the key
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: AuthForm(
                  state: widget.state,
                  onSignIn: _signIn,
                  onShowSeedDialog: _showSeedDialog,
                  onSelectKnownUser: _onSelectKnownUser,
                  onPasswordVisibilityToggle: () {
                    setState(() {
                      widget.state.obscurePassword =
                          !widget.state.obscurePassword;
                    });
                  },
                  onHdModeToggle: (bool value) {
                    setState(() => widget.state.isHdMode = value);
                  },
                  validator: _validator,
                ),
              ),
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
                  (int index) => setState(() => _selectedMenuIndex = index),
              onMnemonicTap: () {
                Clipboard.setData(ClipboardData(text: _mnemonic!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mnemonic copied to clipboard')),
                );
              },
              filteredAssets: widget.filteredAssets,
              searchController: widget.searchController,
              onNavigateToAsset: widget.onNavigateToAsset,
              authOptions: widget.currentUser!.authOptions,
            ),
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

class AuthForm extends StatelessWidget {
  const AuthForm({
    required this.state,
    required this.onSignIn,
    required this.onShowSeedDialog,
    required this.onSelectKnownUser,
    required this.onPasswordVisibilityToggle,
    required this.onHdModeToggle,
    required this.validator,
    super.key,
  });

  final InstanceState state;
  final VoidCallback onSignIn;
  final VoidCallback onShowSeedDialog;
  final void Function(KdfUser) onSelectKnownUser;
  final VoidCallback onPasswordVisibilityToggle;
  final ValueChanged<bool> onHdModeToggle;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.knownUsers.isNotEmpty) ...[
          Text(
            'Saved Wallets:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                state.knownUsers.map((user) {
                  return ActionChip(
                    key: Key(user.walletId.compoundId),
                    onPressed: () => onSelectKnownUser(user),
                    label: Text(user.walletId.name),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        TextFormField(
          controller: state.walletNameController,
          decoration: const InputDecoration(labelText: 'Wallet Name'),
          validator: validator,
        ),
        TextFormField(
          controller: state.passwordController,
          validator: validator,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(
                state.obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: onPasswordVisibilityToggle,
            ),
          ),
          obscureText: state.obscurePassword,
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
          value: state.isHdMode,
          onChanged: onHdModeToggle,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilledButton.tonal(
              onPressed: onSignIn,
              child: const Text('Sign In'),
            ),
            FilledButton(
              onPressed: onShowSeedDialog,
              child: const Text('Register'),
            ),
          ],
        ),
      ],
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
          return DesktopLayout(
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
            // Top button row - always visible
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

            // Main content area with responsive layout
            Expanded(
              child: MobileLayout(
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

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({
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
        // Left sidebar menu - full height
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
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Main content area
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top button row
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

              // Content area
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

class MobileLayout extends StatelessWidget {
  const MobileLayout({
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
        // Main content area
        Expanded(
          child: SelectedContent(
            selectedMenuIndex: selectedMenuIndex,
            filteredAssets: filteredAssets,
            searchController: searchController,
            onNavigateToAsset: onNavigateToAsset,
            authOptions: authOptions,
          ),
        ),

        // Bottom navigation
        Card(
          margin: EdgeInsets.zero,
          child: BottomNavigationBar(
            currentIndex: selectedMenuIndex,
            onTap: onMenuChanged,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz),
                label: 'SwapPage',
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
      default:
        return const SizedBox.shrink();
    }
  }
}
