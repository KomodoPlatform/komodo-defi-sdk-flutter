import 'dart:async';

import 'package:example/screens/asset_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _komodoDefiSdk.initialize();
  runApp(
    MaterialApp(
      scaffoldMessengerKey: _scaffoldKey,
      navigatorKey: _navigatorKey,
      home: const Scaffold(body: KomodoApp()),
    ),
  );
}

final KomodoDefiSdk _komodoDefiSdk = KomodoDefiSdk(
  config: const KomodoDefiSdkConfig(
    defaultAssets: {'KMD', 'BTC', 'ETH'},
  ),
);

class KomodoApp extends StatefulWidget {
  const KomodoApp({super.key});

  @override
  _KomodoAppState createState() => _KomodoAppState();
}

class _KomodoAppState extends State<KomodoApp> {
  KdfUser? _currentUser;
  String _statusMessage = 'Not signed in';
  String? _mnemonic;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<KdfUser> _knownUsers = [];
  final List<Asset> _preActivatedAssets = [];
  StreamSubscription<List<Asset>>? _activeAssetsSub;
  StreamSubscription<KdfUser?>? sub;

  // New properties for search functionality
  final TextEditingController _searchController = TextEditingController();
  List<Asset> _filteredAssets = [];
  late List<Asset> _allAssets;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      sub = _komodoDefiSdk.auth.authStateChanges.listen(updateUser);
      await _fetchKnownUsers();
      await updateUser();

      // Initialize the search functionality
      _allAssets = _komodoDefiSdk.assets.available.values.toList();

      _searchController.addListener(_filterAssets);

      _refreshUsersTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _fetchKnownUsers(),
      );
    });
  }

  // Filtering logic based on search input
  void _filterAssets() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredAssets = _allAssets.where((asset) {
        final assetName = asset.id.name.toLowerCase();
        final assetTicker = asset.id.id.toLowerCase();
        return assetName.contains(query) || assetTicker.contains(query);
      }).toList();

      // Sort to place KMD, BTC, ETH at the top
      _filteredAssets.sort((a, b) {
        const priorityAssets = <String>['KMD', 'BTC', 'ETH'];
        final aPriority = priorityAssets.contains(a.id.id) ? 0 : 1;
        final bPriority = priorityAssets.contains(b.id.id) ? 0 : 1;

        if (aPriority == bPriority) {
          return a.id.name.compareTo(b.id.name);
        }

        return aPriority.compareTo(bPriority);
      });
    });
  }

  Future<void> updateUser([KdfUser? user]) async {
    final userOrRefresh = user ?? await _komodoDefiSdk.auth.currentUser;
    setState(() {
      _currentUser = userOrRefresh;
      _statusMessage = _currentUser != null
          ? 'Current wallet: ${_currentUser!.walletId.name}'
          : 'Not signed in';
    });
  }

  void _onSelectKnownUser(KdfUser user) {
    setState(() {
      _walletNameController.text = user.walletId.name;
      _passwordController.text = '';
      _isHdMode =
          user.authOptions.derivationMethod == DerivationMethod.hdWallet;
    });
  }

  late Timer? _refreshUsersTimer;

  Future<void> _fetchKnownUsers() async {
    try {
      final users = await _komodoDefiSdk.auth.getUsers();
      setState(() {
        _knownUsers = users;
      });
    } catch (e) {
      print('Error fetching known users: $e');
    }
  }

  Future<void> _signIn(String walletName, String password) async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    try {
      final user = await _komodoDefiSdk.auth.signIn(
        walletName: walletName,
        password: password,
        options: AuthOptions(
          derivationMethod:
              _isHdMode ? DerivationMethod.hdWallet : DerivationMethod.iguana,
        ),
      );
      setState(() {
        _currentUser = user;
        _statusMessage = 'Signed in as ${_currentUser?.walletId.name}';
      });
    } on AuthException catch (e) {
      setState(() {
        _statusMessage = 'Auth Error: (${e.type}) ${e.message}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  Future<void> _register(
    String walletName,
    String password, {
    required bool isHd,
    Mnemonic? mnemonic,
  }) async {
    final user = await _komodoDefiSdk.auth.register(
      walletName: walletName,
      password: password,
      options: AuthOptions(
        derivationMethod:
            isHd ? DerivationMethod.hdWallet : DerivationMethod.iguana,
      ),
      mnemonic: mnemonic,
    );

    setState(() {
      _currentUser = user;
      _statusMessage = 'Registered and signed in as ${user.walletId.name}';
    });
  }

  Future<void> _signOut() async {
    try {
      await _komodoDefiSdk.auth.signOut();
      setState(() {
        _currentUser = null;
        _statusMessage = 'Signed out';
        _mnemonic = null;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error signing out: $e';
      });
    }
  }

  Future<void> _getMnemonic({required bool encrypted}) async {
    try {
      final mnemonic = encrypted
          ? await _komodoDefiSdk.auth.getMnemonicEncrypted()
          : await _komodoDefiSdk.auth.getMnemonicPlainText(_password);

      setState(() {
        _mnemonic = mnemonic.toJson().toJsonString();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error fetching mnemonic: $e';
      });
    }
  }

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_statusMessage),
            if (_currentUser != null) ...[
              Text(
                'Wallet Mode: ${_currentUser!.authOptions.derivationMethod == DerivationMethod.hdWallet ? 'HD' : 'Legacy'}',
                style:
                    Theme.of(_scaffoldKey.currentContext!).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            if (_currentUser == null) ...[
              _buildKnownUsersList(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _walletNameController,
                decoration: const InputDecoration(labelText: 'Wallet Name'),
                validator: notEmptyValidator,
              ),
              TextFormField(
                controller: _passwordController,
                validator: notEmptyValidator,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
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
                          'HD wallets require a valid BIP39 seed phrase. \n'
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
                    onPressed: () => _signIn(_walletName, _password),
                    child: const Text('Sign In'),
                  ),
                  FilledButton(
                    onPressed: () => _showSeedDialog(context),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ] else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _signOut,
                    label: const Text('Sign Out'),
                    icon: const Icon(Icons.logout),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => _getMnemonic(encrypted: false),
                        child: const Text('Get Plaintext Mnemonic'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _getMnemonic(encrypted: true),
                        child: const Text('Get Encrypted Mnemonic'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_mnemonic != null) ...[
                    Card(
                      child: ListTile(
                        subtitle: Text('Mnemonic: $_mnemonic'),
                        leading: const Icon(Icons.copy),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _mnemonic = null),
                        ),
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _mnemonic!));

                          _scaffoldKey.currentState?.showSnackBar(
                            const SnackBar(
                              content: Text('Mnemonic copied to clipboard'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ListView(
                  //   shrinkWrap: true,
                  //   children: _komodoDefiSdk.assets.all
                  //       .map((asset) => ListTile(
                  //             title: Text(asset.id.symbol),
                  //             subtitle: Text(asset.id.name),
                  //           ))
                  //       .toList(),
                  // ),
                ],
              ),

            // SizedBox(height: 16),

            if (_currentUser != null) ...[
              // Text('Active Assets (${activeAssets.length}):'),
              // SizedBox(height: 4),
              // if (activeAssets.isEmpty) const Text('No active assets'),
              // Text('${activeAssets.map((a) => a.id.id).join(', ')}'),
              const SizedBox(height: 16),

              // Show list of all coins
              Text('Coins List (${_komodoDefiSdk.assets.available.length})'),
              Flexible(
                child: Material(
                  child: ListView.builder(
                    itemCount: _komodoDefiSdk.assets.available.length,
                    itemBuilder: (context, index) {
                      final asset = _komodoDefiSdk.assets.available.values
                          .elementAt(index);
                      final id = asset.id;
                      final isSupported = asset.isSupported(
                        isHdWallet: _currentUser?.isHd ?? false,
                      );
                      return ListTile(
                        key: Key(id.id),
                        title: Text(id.id),
                        subtitle: Text(id.name),
                        tileColor:
                            index.isEven ? Colors.grey[200] : Colors.grey[100],
                        enabled: isSupported,
                        leading: CircleAvatar(
                          foregroundImage: NetworkImage(
                            // https://komodoplatform.github.io/coins/icons/kmd.png
                            'https://komodoplatform.github.io/coins/icons/${id.symbol.configSymbol.toLowerCase()}.png',
                          ),
                          // child: Text(id.id.substring(0, 2)),
                          // backgroundColor: Colors.transparent,
                          backgroundColor: Colors.white70,
                        ),
                        trailing: _AssetItemTrailing(
                          asset: asset,
                          isSupported: isSupported,
                        ),
                        onTap: () => _onNavigateToAsset(asset),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onNavigateToAsset(Asset asset) {
    // _navigatorKey.currentState? .pushNamed('/asset', arguments: asset);
    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (context) => AssetPage(asset),
      ),
    );
  }

  // TODO: Refactor/clean-up example project

  // bool isMnemonicEncrypted = false;
  bool allowCustomSeed = false;

  Future<void> _showSeedDialog(BuildContext context) async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    final mnemonicController = TextEditingController();
    var isMnemonicEncrypted = false;
    var allowCustomSeed = false;
    String? errorMessage;
    bool? isBip39;

    final didProvideImport = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    // We'll verify BIP39 status after decryption
                    isBip39 = null;
                  });
                }
                return;
              }

              // Only validate plaintext mnemonics
              final failedReason =
                  _komodoDefiSdk.mnemonicValidator.validateMnemonic(
                mnemonicController.text,
                isHd: _isHdMode,
                allowCustomSeed: allowCustomSeed && !_isHdMode,
              );

              setState(() {
                switch (failedReason) {
                  case MnemonicFailedReason.empty:
                    errorMessage = 'Mnemonic cannot be empty';
                    isBip39 = null;
                  case MnemonicFailedReason.customNotSupportedForHd:
                    errorMessage =
                        'HD wallets require a valid BIP39 seed phrase';
                    isBip39 = false;
                  case MnemonicFailedReason.customNotAllowed:
                    errorMessage =
                        'Custom seeds are not allowed. Enable custom seeds or use a valid BIP39 seed phrase';
                    isBip39 = false;
                  case MnemonicFailedReason.invalidLength:
                    errorMessage =
                        'Invalid seed length. Must be 12 or 24 words';
                    isBip39 = false;
                  case null:
                    errorMessage = null;
                    isBip39 = _komodoDefiSdk.mnemonicValidator.validateBip39(
                      mnemonicController.text,
                    );
                }
              });
            }

            // Allow submission if:
            // 1. No error message AND
            // 2. Either:
            //    a. Input is empty (generate new seed) OR
            //    b. Using encrypted seed (validate after decrypt) OR
            //    c. Using plaintext seed that passes BIP39 check in HD mode
            final canSubmit = errorMessage == null &&
                (mnemonicController.text.isEmpty ||
                    isMnemonicEncrypted ||
                    !_isHdMode ||
                    isBip39 == true);

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
                  if (_isHdMode && !isMnemonicEncrypted) ...[
                    const Text(
                      'HD wallets require a valid BIP39 seed phrase.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_isHdMode && isMnemonicEncrypted) ...[
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
                  if (!_isHdMode && !isMnemonicEncrypted) ...[
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
              actions: <Widget>[
                TextButton(
                  onPressed: () => _navigatorKey.currentState?.pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: canSubmit
                      ? () => _handleRegistration(
                            context,
                            mnemonicController.text,
                            isMnemonicEncrypted,
                          )
                      : null,
                  child: const Text('Register'),
                ),
              ],
            );
          },
        );
      },
    );

    if (didProvideImport != true) return;
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

    _navigatorKey.currentState?.pop(true);

    try {
      await _register(
        _walletName,
        _password,
        mnemonic: mnemonic,
        isHd: _isHdMode,
      );
    } on AuthException catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            e.type == AuthExceptionType.invalidWalletPassword
                ? 'HD mode requires a valid BIP39 seed phrase. The imported encrypted seed is not compatible.'
                : 'Registration failed: ${e.message}',
          ),
          backgroundColor:
              Theme.of(_scaffoldKey.currentContext!).colorScheme.error,
        ),
      );
    }
  }

  void _validateMnemonic(
    String input,
    StateSetter setState, {
    required void Function(String?) setError,
  }) {
    if (input.isEmpty) {
      setError(null);
      return;
    }

    final failedReason = _komodoDefiSdk.mnemonicValidator.validateMnemonic(
      input,
      isHd: _isHdMode,
      allowCustomSeed: !_isHdMode && allowCustomSeed,
    );

    switch (failedReason) {
      case MnemonicFailedReason.empty:
        setError('Mnemonic cannot be empty');
      case MnemonicFailedReason.customNotSupportedForHd:
        setError('HD wallets require a valid BIP39 seed phrase');
      case MnemonicFailedReason.customNotAllowed:
        setError(
          'Custom seeds are not allowed. Enable custom seeds or use a valid BIP39 seed phrase',
        );
      case MnemonicFailedReason.invalidLength:
        setError('Invalid seed length. Must be 12 or 24 words');
      case null:
        setError(null);
    }
  }

  String get _walletName => _walletNameController.text;
  String get _password => _passwordController.text;

  Widget _buildKnownUsersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved Wallets:',
          style: Theme.of(_scaffoldKey.currentContext!).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _knownUsers.map((user) {
            return ActionChip(
              key: Key(user.walletId.compoundId),
              onPressed: () => _onSelectKnownUser(user),
              label: Text(user.walletId.name),
            );
            return ElevatedButton(
              onPressed: () => _onSelectKnownUser(user),
              child: Text(user.walletId.name),
            );
          }).toList(),
        ),
      ],
    );
  }

  String? notEmptyValidator(String? input, {String? fieldName}) {
    if (input == null || input.isEmpty) {
      return 'Please enter a ${fieldName ?? 'value'}.';
    }
    return null;
  }

  String? validateEncryptedMnemonic(String? input, {bool isEncrypted = false}) {
    if (input == null || input.isEmpty) {
      return 'Mnemonic cannot be empty';
    }

    if (isEncrypted) {
      final maybeJson = tryParseJson(input);
      if (maybeJson == null) {
        return 'Invalid JSON format. Please ensure it is correctly formatted.';
      }

      final parsedMnemonic = EncryptedMnemonicData.tryParse(maybeJson);

      if (parsedMnemonic == null) {
        return 'Invalid encrypted mnemonic format. Please ensure it is correctly formatted.\nExample: ${EncryptedMnemonicData.encryptedDataExample}';
      }
    }

    return null;
  }

  final TextEditingController _walletNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isHdMode = true;

  @override
  void dispose() {
    _searchController.dispose();
    _refreshUsersTimer?.cancel();
    sub?.cancel();
    _activeAssetsSub?.cancel();
    super.dispose();
  }
}

class _AssetItemTrailing extends StatelessWidget {
  const _AssetItemTrailing({
    required this.asset,
    required this.isSupported,
  });

  final bool isSupported;

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    return isSupported
        ? const Icon(Icons.arrow_forward_ios)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (unsupportedMessage != null) ...[
                Text(unsupportedMessage ?? ''),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.lock),
            ],
          );
  }

  // TODO: Change to an enum and move to the SDK.
  String? get unsupportedMessage {
    if (isSupported) return null;

    if (!asset.protocol.toJson().containsKey('derivation_path')) {
      return 'Missing derivation path';
    }
    return null;
  }
}
