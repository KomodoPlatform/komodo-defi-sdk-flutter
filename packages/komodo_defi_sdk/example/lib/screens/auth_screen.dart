// auth_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/screens/asset_page.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/instance_view.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.user,
    required this.statusMessage,
    required this.instanceState,
    required this.onUserChanged,
    super.key,
  });

  final KdfUser? user;
  final String statusMessage;
  final KdfInstanceState instanceState;
  final ValueChanged<KdfUser?> onUserChanged;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final TextEditingController _searchController;
  List<Asset> _filteredAssets = [];
  Map<AssetId, Asset>? _allAssets;
  String? _mnemonic;
  Timer? _refreshUsersTimer;
  StreamSubscription<List<Asset>>? _activeAssetsSub;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterAssets);
    _initializeKdf();
  }

  Future<void> _initializeKdf() async {
    final sdk = widget.instanceState.sdk;
    _allAssets = sdk.assets.available;
    _filterAssets();

    await _fetchKnownUsers();

    _refreshUsersTimer?.cancel();
    _refreshUsersTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchKnownUsers(),
    );
  }

  Future<void> _fetchKnownUsers() async {
    try {
      final users = await widget.instanceState.sdk.auth.getUsers();
      setState(() {
        _state.instanceData.knownUsers = users;
      });
    } catch (e) {
      debugPrint('Error fetching known users: $e');
    }
  }

  void _filterAssets() {
    final query = _searchController.text.toLowerCase();
    final assets = _allAssets;
    if (assets == null) return;

    setState(() {
      _filteredAssets =
          assets.values.where((v) {
            final asset = v.id.name;
            final id = v.id.id;
            return asset.toLowerCase().contains(query) ||
                id.toLowerCase().contains(query);
          }).toList();
    });
  }

  Future<void> _register(
    String walletName,
    String password, {
    required bool isHd,
    Mnemonic? mnemonic,
  }) async {
    final user = await widget.instanceState.sdk.auth.register(
      walletName: walletName,
      password: password,
      options: AuthOptions(
        derivationMethod:
            isHd ? DerivationMethod.hdWallet : DerivationMethod.iguana,
      ),
      mnemonic: mnemonic,
    );

    widget.onUserChanged(user);
  }

  Future<void> _handleRegistration(
    BuildContext context,
    String input,
    bool isEncrypted,
  ) async {
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

    Navigator.of(context).pop(true);

    try {
      await _register(
        _state.instanceData.walletNameController.text,
        _state.instanceData.passwordController.text,
        mnemonic: mnemonic,
        isHd: _state.instanceData.isHdMode,
      );
    } on AuthException catch (e) {
      debugPrint('Registration failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.type == AuthExceptionType.incorrectPassword
                ? 'HD mode requires a valid BIP39 seed phrase. The imported encrypted seed is not compatible.'
                : 'Registration failed: ${e.message}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _onNavigateToAsset(BuildContext context, Asset asset) async {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (context) => RepositoryProvider.value(
              value: widget.instanceState.sdk,
              child: AssetPage(asset),
            ),
      ),
    );
  }

  KdfInstanceState get _state => widget.instanceState;

  @override
  void dispose() {
    _searchController.dispose();
    _refreshUsersTimer?.cancel();
    _activeAssetsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InstanceView(
      instance: widget.instanceState,
      state: _state.instanceData,
      currentUser: widget.user,
      statusMessage: widget.statusMessage,
      onUserChanged: widget.onUserChanged,
      searchController: _searchController,
      filteredAssets: _filteredAssets,
      onNavigateToAsset: (asset) => _onNavigateToAsset(context, asset),
    );
  }
}
