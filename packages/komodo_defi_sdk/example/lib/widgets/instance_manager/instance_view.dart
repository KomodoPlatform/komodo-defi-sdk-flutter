import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            ? 'HD mode requires a valid BIP39 seed phrase. The imported encrypted seed is not compatible.'
            : 'Registration failed: ${e.message}',
      );
    }
  }

  void _onSelectKnownUser(KdfUser user) {
    setState(() {
      widget.state.walletNameController.text = user.walletId.name;
      widget.state.passwordController.text = '';
      widget.state.isHdMode =
          user.authOptions.derivationMethod == DerivationMethod.hdWallet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InstanceStatus(instance: widget.instance),
        const SizedBox(height: 16),
        Text(widget.statusMessage),
        if (widget.currentUser != null) ...[
          Text(
            'Wallet Mode: ${widget.currentUser!.authOptions.derivationMethod == DerivationMethod.hdWallet ? 'HD' : 'Legacy'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 16),
        if (widget.currentUser == null)
          Expanded(
            child: SingleChildScrollView(
              // Wrap the auth form in a Form widget using the key
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: _buildAuthForm(),
              ),
            ),
          )
        else
          Expanded(child: _buildLoggedInView()),
      ],
    );
  }

  Widget _buildLoggedInView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilledButton.tonalIcon(
              onPressed: _signOut,
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
            authOptions: widget.currentUser!.authOptions,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.state.knownUsers.isNotEmpty) ...[
          Text(
            'Saved Wallets:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                widget.state.knownUsers.map((user) {
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
          controller: widget.state.walletNameController,
          decoration: const InputDecoration(labelText: 'Wallet Name'),
          validator: _validator,
        ),
        TextFormField(
          controller: widget.state.passwordController,
          validator: _validator,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(
                widget.state.obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  widget.state.obscurePassword = !widget.state.obscurePassword;
                });
              },
            ),
          ),
          obscureText: widget.state.obscurePassword,
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
          value: widget.state.isHdMode,
          onChanged: (value) {
            setState(() => widget.state.isHdMode = value);
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
