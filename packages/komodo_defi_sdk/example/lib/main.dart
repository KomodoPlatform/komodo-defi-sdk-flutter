// lib/main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdf_sdk_example/screens/asset_page.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/instance_view.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_drawer.dart';
import 'package:kdf_sdk_example/widgets/instance_manager/kdf_instance_state.dart';
import 'package:kdf_sdk_example/screens/dapp_browser_page.dart';
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
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
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
  final Map<String, InstanceState> _instanceStates = {};
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
    _getOrCreateInstanceState(instance.name);

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
    } catch (e, s) {
      print('Error fetching known users: $e');
      debugPrintStack(stackTrace: s);
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
    return _instanceStates.putIfAbsent(instanceName, InstanceState.new);
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
          IconButton(
            icon: const Icon(Icons.web),
            onPressed: () => _openBrowser(instances[_selectedInstanceIndex]),
          ),
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

  void _openBrowser(KdfInstanceState instance) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => DappBrowserPage(sdk: instance.sdk),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final state in _instanceStates.values) {
      state.dispose();
    }
    _instanceStates.clear();
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
