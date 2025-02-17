// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/screens/asset_page.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/instance_view.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_drawer.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create instance manager
  final instanceManager = KdfInstanceManager();

  // Create default SDK instance with config
  final defaultSdk = KomodoDefiSdk(config: _config);
  await defaultSdk.initialize();

  // Register default instance
  await instanceManager.registerInstance('Local Instance', _config, defaultSdk);

  runApp(
    MultiRepositoryProvider(
      providers: [RepositoryProvider<KomodoDefiSdk>.value(value: defaultSdk)],
      child: KdfInstanceManagerProvider(
        notifier: instanceManager,
        child: MaterialApp(
          scaffoldMessengerKey: _scaffoldKey,
          navigatorKey: _navigatorKey,
          theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
          home: const KomodoApp(),
        ),
      ),
    ),
  );
}

// Default SDK configuration
const KomodoDefiSdkConfig _config = KomodoDefiSdkConfig();

class KomodoApp extends StatefulWidget {
  const KomodoApp({super.key});

  @override
  State<KomodoApp> createState() => _KomodoAppState();
}

class _KomodoAppState extends State<KomodoApp> {
  // Instance-specific state management
  final Map<String, InstanceState> InstanceStates = {};
  final Map<String, KdfUser?> _currentUsers = {};
  final Map<String, String> _statusMessages = {};
  int _selectedInstanceIndex = 0;

  // Form controllers and state
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  List<Asset> _filteredAssets = [];
  Map<AssetId, Asset>? _allAssets;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterAssets);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeInstances();
      _initialized = true;
    }
  }

  Future<void> _initializeInstances() async {
    final manager = KdfInstanceManagerProvider.of(context);

    // Initialize state for each instance
    for (final instance in manager.instances.values) {
      await _initializeInstance(instance);
    }
  }

  Future<void> _initializeInstance(KdfInstanceState instance) async {
    final state = _getOrCreateInstanceState(instance.name);

    // Initialize assets
    _allAssets = instance.sdk.assets.available;
    _filterAssets();

    // Initialize auth state
    final user = await instance.sdk.auth.currentUser;
    _updateInstanceUser(instance.name, user);

    // Setup auth state listener
    instance.sdk.auth.authStateChanges.listen((user) {
      _updateInstanceUser(instance.name, user);
    });

    // Load known users
    await _fetchKnownUsers(instance);
  }

  void _updateInstanceUser(String instanceName, KdfUser? user) {
    setState(() {
      _currentUsers[instanceName] = user;
      _statusMessages[instanceName] =
          user != null
              ? 'Current wallet: ${user.walletId.name}'
              : 'Not signed in';
    });
  }

  Future<void> _fetchKnownUsers(KdfInstanceState instance) async {
    try {
      await instance.sdk.ensureInitialized();
      final users = await instance.sdk.auth.getUsers();
      final state = _getOrCreateInstanceState(instance.name);
      state.knownUsers = users;
      setState(() {});
    } catch (e) {
      print('Error fetching known users: $e');
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

  InstanceState _getOrCreateInstanceState(String instanceName) {
    return InstanceStates.putIfAbsent(instanceName, InstanceState.new);
  }

  @override
  Widget build(BuildContext context) {
    final manager = KdfInstanceManagerProvider.of(context);
    final instances = manager.instances.values.toList();

    return Scaffold(
      drawer: const KdfInstanceDrawer(),
      appBar: AppBar(
        title: Text(
          instances.isEmpty
              ? 'KDF Demo'
              : 'KDF Demo - ${instances[_selectedInstanceIndex].name}',
        ),
        actions: [
          if (instances.isNotEmpty) ...[
            Badge(
              backgroundColor:
                  instances[_selectedInstanceIndex].isConnected
                      ? Colors.green
                      : Colors.red,
              child: const Icon(Icons.cloud),
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
      body:
          instances.isEmpty
              ? const Center(child: Text('No KDF instances configured'))
              : IndexedStack(
                index: _selectedInstanceIndex,
                children: [
                  for (final instance in instances)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: InstanceView(
                          instance: instance,
                          state: _getOrCreateInstanceState(instance.name),
                          currentUser: _currentUsers[instance.name],
                          statusMessage:
                              _statusMessages[instance.name] ??
                              'Not initialized',
                          onUserChanged:
                              (user) =>
                                  _updateInstanceUser(instance.name, user),
                          searchController: _searchController,
                          filteredAssets: _filteredAssets,
                          onNavigateToAsset:
                              (asset) => _onNavigateToAsset(instance, asset),
                        ),
                      ),
                    ),
                ],
              ),
      bottomNavigationBar: _buildInstanceNavigator(instances),
    );
  }

  Widget _buildInstanceNavigator(List<KdfInstanceState> instances) {
    if (instances.length <= 1) return const SizedBox.shrink();

    return NavigationBar(
      selectedIndex: _selectedInstanceIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedInstanceIndex = index);
      },
      destinations: [
        for (final instance in instances)
          NavigationDestination(
            icon: Badge(
              backgroundColor: instance.isConnected ? Colors.green : Colors.red,
              child: const Icon(Icons.cloud),
            ),
            label: instance.name,
          ),
      ],
    );
  }

  void _onNavigateToAsset(KdfInstanceState instance, Asset asset) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (context) => AssetPage(asset)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final state in InstanceStates.values) {
      state.dispose();
    }
    InstanceStates.clear();
    super.dispose();
  }
}

abstract class InstanceData {
  // Base interface for instance-specific data
}

class InstanceState extends InstanceData {
  final walletNameController = TextEditingController();
  final passwordController = TextEditingController();
  List<KdfUser> knownUsers = [];
  bool isHdMode = true;
  bool obscurePassword = true;

  void dispose() {
    walletNameController.dispose();
    passwordController.dispose();
  }
}

// class _KomodoAppState extends State<KomodoApp> {
//   KdfUser? _currentUser;
//   String _statusMessage = 'Not signed in';
//   String? _mnemonic;

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   List<KdfUser> _knownUsers = [];
//   final List<Asset> _preActivatedAssets = [];
//   StreamSubscription<List<Asset>>? _activeAssetsSub;
//   StreamSubscription<KdfUser?>? sub;
//   Timer? _refreshUsersTimer;

//   // Properties for search functionality
//   final TextEditingController _searchController = TextEditingController();
//   List<Asset> _filteredAssets = [];
//   Map<AssetId, Asset>? _allAssets;

//   bool _initialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_filterAssets);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_initialized) {
//       _initializeKdf();
//       _initialized = true;
//     }
//   }

//   Future<void> _initializeKdf() async {
//     final manager = KdfInstanceManagerProvider.of(context);
//     final instance = manager.activeInstance;
//     if (instance == null) return;

//     final sdk = instance.sdk;
//     _allAssets = sdk.assets.available;
//     _filterAssets();

//     sub = sdk.auth.authStateChanges.listen(updateUser);
//     await _fetchKnownUsers();
//     await updateUser();

//     _refreshUsersTimer?.cancel();
//     _refreshUsersTimer = Timer.periodic(
//       const Duration(seconds: 10),
//       (_) => _fetchKnownUsers(),
//     );
//   }

//   void _filterAssets() {
//     final query = _searchController.text.toLowerCase();
//     final assets = _allAssets;
//     if (assets == null) return;

//     setState(() {
//       _filteredAssets = assets.values.where((v) {
//         final asset = v.id.name;
//         final id = v.id.id;

//         return asset.toLowerCase().contains(query) ||
//             id.toLowerCase().contains(query);
//       }).toList();
//     });
//   }

//   Future<void> updateUser([KdfUser? user]) async {
//     final manager = KdfInstanceManagerProvider.of(context);
//     final instance = manager.activeInstance;
//     if (instance == null) return;

//     final sdk = instance.sdk;

//     final userOrRefresh = user ?? await sdk.auth.currentUser;
//     if (userOrRefresh == null && _currentUser != null) {
//       await _navigatorKey.currentState
//           ?.pushNamedAndRemoveUntil('/', (_) => false);
//       _mnemonic = null;
//     }
//     setState(() {
//       _currentUser = userOrRefresh;
//       _statusMessage = _currentUser != null
//           ? 'Current wallet: ${_currentUser!.walletId.name}'
//           : 'Not signed in';
//     });
//   }

//   void _onSelectKnownUser(KdfUser user) {
//     setState(() {
//       _walletNameController.text = user.walletId.name;
//       _passwordController.text = '';
//       _isHdMode =
//           user.authOptions.derivationMethod == DerivationMethod.hdWallet;
//     });
//   }

//   Future<void> _fetchKnownUsers() async {
//     final manager = KdfInstanceManagerProvider.of(context);
//     final instance = manager.activeInstance;
//     if (instance == null) return;

//     try {
//       final users = await instance.sdk.auth.getUsers();
//       setState(() {
//         _knownUsers = users;
//       });
//     } catch (e) {
//       print('Error fetching known users: $e');
//     }
//   }

//   Future<void> _signIn(String walletName, String password) async {
//     if (_formKey.currentState?.validate() == false) {
//       return;
//     }

//     final manager = KdfInstanceManagerProvider.of(context);
//     final instance = manager.activeInstance;
//     if (instance == null) return;

//     try {
//       final user = await instance.sdk.auth.signIn(
//         walletName: walletName,
//         password: password,
//         options: AuthOptions(
//           derivationMethod:
//               _isHdMode ? DerivationMethod.hdWallet : DerivationMethod.iguana,
//         ),
//       );
//       setState(() {
//         _currentUser = user;
//         _statusMessage = 'Signed in as ${_currentUser?.walletId.name}';
//       });
//     } on AuthException catch (e) {
//       setState(() {
//         _scaffoldKey.currentState?.showSnackBar(
//           SnackBar(
//             content: Text('Auth Error: (${e.type}) ${e.message}'),
//           ),
//         );
//         _statusMessage = 'Auth Error: (${e.type}) ${e.message}';
//       });
//     } catch (e) {
//       setState(() {
//         _scaffoldKey.currentState?.showSnackBar(
//           SnackBar(
//             content: Text('An unexpected error occurred: $e'),
//           ),
//         );
//         _statusMessage = 'An unexpected error occurred: $e';
//       });
//     }
//   }

//   Future<void> _register(
//     String walletName,
//     String password, {
//     required bool isHd,
//     Mnemonic? mnemonic,
//   }) async {
//     final manager = KdfInstanceManagerProvider.of(context);
//     final instance = manager.activeInstance;
//     if (instance == null) return;

//     final user = await instance.sdk.auth.register(
//       walletName: walletName,
//       password: password,
//       options: AuthOptions(
//         derivationMethod:
//             isHd ? DerivationMethod.hdWallet : DerivationMethod.iguana,
//       ),
//       mnemonic: mnemonic,
//     );

//     setState(() {
//       _currentUser = user;
//       _statusMessage = 'Registered and signed in as ${user.walletId.name}';
//     });
//   }

//   Future<void> _signOut() async {
//     final manager = KdfInstanceManagerProvider.of(context);
//     final instance = manager.activeInstance;
//     if (instance == null) return;

//     try {
//       await instance.sdk.auth.signOut();
//     } on AuthException catch (e) {
//       if (e.type != AuthExceptionType.unauthorized) {
//         rethrow;
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Error signing out: $e';
//       });
//     }

//     setState(() {
//       _currentUser = null;
//       _statusMessage = 'Signed out';
//       _mnemonic = null;
//     });
//   }

//   Future<void> _getMnemonic({required bool encrypted}) async {
//     final manager = KdfInstanceManagerProvider.of(context);
//     final instance = manager.activeInstance;
//     if (instance == null) return;

//     try {
//       final mnemonic = encrypted
//           ? await instance.sdk.auth.getMnemonicEncrypted()
//           : await instance.sdk.auth.getMnemonicPlainText(_password);

//       setState(() {
//         _mnemonic = mnemonic.toJson().toJsonString();
//       });
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Error fetching mnemonic: $e';
//       });
//     }
//   }

//   bool _obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     // Access current KDF instance
//     final manager = KdfInstanceManagerProvider.of(context);
//     final instance = manager.activeInstance;

//     if (instance == null) {
//       return const Center(
//         child: Text('No active KDF instance'),
//       );
//     }

//     return Scaffold(
//       drawer: const KdfInstanceDrawer(),
//       appBar: AppBar(
//         title: Text('KDF Demo - ${instance.name}'),
//         actions: [
//           Badge(
//             backgroundColor: instance.isConnected ? Colors.green : Colors.red,
//             child: const Icon(Icons.cloud),
//           ),
//           const SizedBox(width: 16),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(_statusMessage),
//               if (_currentUser != null) ...[
//                 Text(
//                   'Wallet Mode: ${_currentUser!.authOptions.derivationMethod == DerivationMethod.hdWallet ? 'HD' : 'Legacy'}',
//                   style: Theme.of(_scaffoldKey.currentContext!)
//                       .textTheme
//                       .bodySmall,
//                 ),
//               ],
//               const SizedBox(height: 16),
//               if (_currentUser == null) ...[
//                 _buildKnownUsersList(),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _walletNameController,
//                   decoration: const InputDecoration(labelText: 'Wallet Name'),
//                   validator: passwordValidator,
//                 ),
//                 TextFormField(
//                   controller: _passwordController,
//                   validator: passwordValidator,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                       ),
//                       onPressed: () {
//                         setState(() => _obscurePassword = !_obscurePassword);
//                       },
//                     ),
//                   ),
//                   obscureText: _obscurePassword,
//                 ),
//                 SwitchListTile(
//                   title: const Row(
//                     children: [
//                       Text('HD Wallet Mode'),
//                       SizedBox(width: 8),
//                       Tooltip(
//                         message:
//                             'HD wallets require a valid BIP39 seed phrase.\n'
//                             'NB! Your addresses and balances will be different '
//                             'in HD mode.',
//                         child: Icon(Icons.info, size: 16),
//                       ),
//                     ],
//                   ),
//                   subtitle: const Text('Enable HD multi-address mode'),
//                   value: _isHdMode,
//                   onChanged: (value) {
//                     setState(() => _isHdMode = value);
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     FilledButton.tonal(
//                       onPressed: () => _signIn(_walletName, _password),
//                       child: const Text('Sign In'),
//                     ),
//                     FilledButton(
//                       onPressed: () => _showSeedDialog(context),
//                       child: const Text('Register'),
//                     ),
//                   ],
//                 ),
//               ] else
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     FilledButton.tonalIcon(
//                       onPressed: _signOut,
//                       icon: const Icon(Icons.logout),
//                       label: const Text('Sign Out'),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () => _getMnemonic(encrypted: false),
//                           child: const Text('Get Plaintext Mnemonic'),
//                         ),
//                         const SizedBox(width: 16),
//                         ElevatedButton(
//                           onPressed: () => _getMnemonic(encrypted: true),
//                           child: const Text('Get Encrypted Mnemonic'),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     if (_mnemonic != null) ...[
//                       Card(
//                         child: ListTile(
//                           subtitle: Text('Mnemonic: $_mnemonic'),
//                           leading: const Icon(Icons.copy),
//                           trailing: IconButton(
//                             icon: const Icon(Icons.close),
//                             onPressed: () => setState(() => _mnemonic = null),
//                           ),
//                           onTap: () {
//                             Clipboard.setData(ClipboardData(text: _mnemonic!));
//                             _scaffoldKey.currentState?.showSnackBar(
//                               const SnackBar(
//                                 content: Text('Mnemonic copied to clipboard'),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                   ],
//                 ),
//               if (_currentUser != null) ...[
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Text(
//                       'Coins List (${instance.sdk.assets.available.length})',
//                     ),
//                     const Spacer(),
//                     SizedBox(
//                       height: 40,
//                       width: 200,
//                       child: TextField(
//                         controller: _searchController,
//                         onChanged: (_) => _filterAssets(),
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           labelText: 'Search',
//                           hintText: 'Search for an asset',
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Flexible(
//                   child: Material(
//                     child: ListView.builder(
//                       itemCount: _filteredAssets.length,
//                       itemBuilder: (context, index) {
//                         final asset = _filteredAssets.elementAt(index);
//                         return AssetItemWidget(
//                           asset: asset,
//                           authOptions: _currentUser!.authOptions,
//                           onTap: () => _onNavigateToAsset(asset),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _onNavigateToAsset(Asset asset) {
//     final manager = KdfInstanceManagerProvider.of(context);
//     final instance = manager.activeInstance;
//     if (instance == null) return;

//     _navigatorKey.currentState?.push(
//       MaterialPageRoute<void>(
//         builder: (context) => RepositoryProvider.value(
//           value: instance.sdk,
//           child: AssetPage(asset),
//         ),
//       ),
//     );
//   }

//   bool isCustomSeed = false;

//   Future<void> _showSeedDialog(BuildContext context) async {
//     if (_formKey.currentState?.validate() == false) {
//       return;
//     }

//     final mnemonicController = TextEditingController();
//     var isMnemonicEncrypted = false;
//     var allowCustomSeed = false;
//     String? errorMessage;
//     bool? isBip39;

//     final manager = KdfInstanceManagerProvider.of(context);
//     final instance = manager.activeInstance;
//     if (instance == null) return;

//     final didProvideImport = await showDialog<bool?>(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             void validateInput() {
//               if (mnemonicController.text.isEmpty) {
//                 setState(() {
//                   errorMessage = null;
//                   isBip39 = null;
//                 });
//                 return;
//               }

//               if (isMnemonicEncrypted) {
//                 final parsedMnemonic = EncryptedMnemonicData.tryParse(
//                   tryParseJson(mnemonicController.text) ?? {},
//                 );
//                 if (parsedMnemonic == null) {
//                   setState(() {
//                     errorMessage = 'Invalid encrypted mnemonic format';
//                     isBip39 = null;
//                   });
//                 } else {
//                   setState(() {
//                     errorMessage = null;
//                     isBip39 = null;
//                   });
//                 }
//                 return;
//               }

//               final failedReason =
//                   instance.sdk.mnemonicValidator.validateMnemonic(
//                 mnemonicController.text,
//                 isHd: _isHdMode,
//                 allowCustomSeed: allowCustomSeed && !_isHdMode,
//               );

//               setState(() {
//                 switch (failedReason) {
//                   case MnemonicFailedReason.empty:
//                     errorMessage = 'Mnemonic cannot be empty';
//                     isBip39 = null;
//                   case MnemonicFailedReason.customNotSupportedForHd:
//                     errorMessage =
//                         'HD wallets require a valid BIP39 seed phrase';
//                     isBip39 = false;
//                   case MnemonicFailedReason.customNotAllowed:
//                     errorMessage =
//                         'Custom seeds are not allowed. Enable custom seeds or use a valid BIP39 seed phrase';
//                     isBip39 = false;
//                   case MnemonicFailedReason.invalidLength:
//                     errorMessage =
//                         'Invalid seed length. Must be 12 or 24 words';
//                     isBip39 = false;
//                   case null:
//                     errorMessage = null;
//                     isBip39 = instance.sdk.mnemonicValidator.validateBip39(
//                       mnemonicController.text,
//                     );
//                 }
//               });
//             }

//             final canSubmit = errorMessage == null &&
//                 (mnemonicController.text.isEmpty ||
//                     isMnemonicEncrypted ||
//                     !_isHdMode ||
//                     isBip39 == true);

//             return AlertDialog(
//               title: const Text('Import Existing Seed?'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     'Do you have an existing seed you would like to import? '
//                     'Enter it below or leave empty to generate a new seed.',
//                   ),
//                   const SizedBox(height: 16),
//                   if (_isHdMode && !isMnemonicEncrypted) ...[
//                     const Text(
//                       'HD wallets require a valid BIP39 seed phrase.',
//                       style: TextStyle(fontStyle: FontStyle.italic),
//                     ),
//                     const SizedBox(height: 8),
//                   ],
//                   if (_isHdMode && isMnemonicEncrypted) ...[
//                     const Text(
//                       'Note: Encrypted seeds will be verified for BIP39 compatibility after import.',
//                       style: TextStyle(fontStyle: FontStyle.italic),
//                     ),
//                     const SizedBox(height: 8),
//                   ],
//                   TextFormField(
//                     minLines: isMnemonicEncrypted ? 3 : 1,
//                     maxLines: isMnemonicEncrypted ? 4 : 1,
//                     controller: mnemonicController,
//                     obscureText: !isMnemonicEncrypted,
//                     onChanged: (_) => validateInput(),
//                     decoration: InputDecoration(
//                       hintText: 'Enter your seed or leave empty for a new one',
//                       errorText: errorMessage,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   SwitchListTile(
//                     title: const Text('Encrypted Seed?'),
//                     value: isMnemonicEncrypted,
//                     onChanged: (value) {
//                       setState(() {
//                         isMnemonicEncrypted = value;
//                         validateInput();
//                       });
//                     },
//                   ),
//                   if (!_isHdMode && !isMnemonicEncrypted) ...[
//                     SwitchListTile(
//                       title: const Text('Allow Custom Seed'),
//                       subtitle: const Text(
//                         'Enable to use a non-BIP39 compatible seed phrase',
//                       ),
//                       value: allowCustomSeed,
//                       onChanged: (value) {
//                         setState(() {
//                           allowCustomSeed = value;
//                           validateInput();
//                         });
//                       },
//                     ),
//                   ],
//                 ],
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('Cancel'),
//                 ),
//                 FilledButton(
//                   onPressed: canSubmit
//                       ? () => _handleRegistration(
//                             context,
//                             mnemonicController.text,
//                             isMnemonicEncrypted,
//                           )
//                       : null,
//                   child: const Text('Register'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     if (didProvideImport != true) return;
//   }

//   Future<void> _handleRegistration(
//     BuildContext context,
//     String input,
//     bool isEncrypted,
//   ) async {
//     Mnemonic? mnemonic;

//     if (input.isNotEmpty) {
//       if (isEncrypted) {
//         final parsedMnemonic = EncryptedMnemonicData.tryParse(
//           tryParseJson(input) ?? {},
//         );
//         if (parsedMnemonic != null) {
//           mnemonic = Mnemonic.encrypted(parsedMnemonic);
//         }
//       } else {
//         mnemonic = Mnemonic.plaintext(input);
//       }
//     }

//     Navigator.of(context).pop(true);

//     try {
//       await _register(
//         _walletName,
//         _password,
//         mnemonic: mnemonic,
//         isHd: _isHdMode,
//       );
//     } on AuthException catch (e) {
//       _scaffoldKey.currentState?.showSnackBar(
//         SnackBar(
//           content: Text(
//             e.type == AuthExceptionType.invalidWalletPassword
//                 ? 'HD mode requires a valid BIP39 seed phrase. The imported encrypted seed is not compatible.'
//                 : 'Registration failed: ${e.message}',
//           ),
//           backgroundColor:
//               Theme.of(_scaffoldKey.currentContext!).colorScheme.error,
//         ),
//       );
//     }
//   }

//   Widget _buildKnownUsersList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Saved Wallets:',
//           style: Theme.of(_scaffoldKey.currentContext!).textTheme.titleMedium,
//         ),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: _knownUsers.map((user) {
//             return ActionChip(
//               key: Key(user.walletId.compoundId),
//               onPressed: () => _onSelectKnownUser(user),
//               label: Text(user.walletId.name),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   String? passwordValidator(String? input, {String? fieldName}) {
//     if (input == null || input.isEmpty) {
//       return 'Please enter a ${fieldName ?? 'value'}.';
//     }
//     return null;
//   }

//   final TextEditingController _walletNameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isHdMode = true;

//   String get _walletName => _walletNameController.text;
//   String get _password => _passwordController.text;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _walletNameController.dispose();
//     _passwordController.dispose();
//     _refreshUsersTimer?.cancel();
//     sub?.cancel();
//     _activeAssetsSub?.cancel();
//     super.dispose();
//   }
// }
