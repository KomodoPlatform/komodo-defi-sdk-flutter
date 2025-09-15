import 'dart:async';

import 'package:komodo_defi_local_auth/komodo_defi_local_auth.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/balances/balance_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Mock general activation methods with configurable responses
class MockGeneralActivationMethods {
  MockGeneralActivationMethods({this.enabledCoins = const []});

  final List<EnabledCoinInfo> enabledCoins;

  Future<GetEnabledCoinsResponse> getEnabledCoins([String? rpcPass]) async {
    return GetEnabledCoinsResponse(mmrpc: '2.0', result: enabledCoins);
  }
}

/// Mock RPC methods container with UTXO support
class MockRpcMethods {
  MockRpcMethods({List<EnabledCoinInfo> enabledCoins = const []})
    : generalActivation = MockGeneralActivationMethods(
        enabledCoins: enabledCoins,
      ),
      utxo = MockUtxoMethods();

  final MockGeneralActivationMethods generalActivation;
  final MockUtxoMethods utxo;
}

/// Mock UTXO methods to handle activation strategy calls
class MockUtxoMethods {
  Future<MockEnableUtxoInitResponse> enableUtxoInit({
    required String ticker,
    required dynamic params,
  }) async {
    return MockEnableUtxoInitResponse(taskId: 'mock-task-$ticker');
  }

  Future<MockTaskStatusResponse> taskEnableStatus(String taskId) async {
    // Simulate immediate failure for test consistency
    return MockTaskStatusResponse(
      status: 'Error',
      result: {'error': 'Mock activation strategy always fails for testing'},
    );
  }
}

/// Mock response classes
class MockEnableUtxoInitResponse {
  MockEnableUtxoInitResponse({required this.taskId});
  final String taskId;
}

class MockTaskStatusResponse {
  MockTaskStatusResponse({required this.status, this.result});
  final String status;
  final Map<String, dynamic>? result;

  bool get isCompleted => status == 'Ok' || status == 'Error';
}

/// Configurable mock API client for testing different scenarios
class MockApiClient implements ApiClient {
  MockApiClient({List<EnabledCoinInfo> enabledCoins = const []})
    : _enabledCoins = enabledCoins;

  final List<EnabledCoinInfo> _enabledCoins;

  @override
  Future<Map<String, dynamic>> executeRpc(Map<String, dynamic> request) async {
    final method = request['method'] as String?;

    switch (method) {
      case 'get_enabled_coins':
        return {
          'mmrpc': '2.0',
          'result': {
            'coins': _enabledCoins.map((coin) => coin.toJson()).toList(),
          },
        };

      case 'task::enable_utxo::init':
        // Return a realistic task response that matches NewTaskResponse structure
        return {
          'mmrpc': '2.0',
          'result': {
            'task_id':
                DateTime.now().millisecondsSinceEpoch % 100000, // Use integer
          },
        };

      case 'task::enable_utxo::status':
        // final taskId = request['params']?['task_id'] as String? ?? '';
        return {
          'mmrpc': '2.0',
          'result': {
            'status': 'Ok',
            'details': {
              'result': {
                'ticker': 'TEST',
                'address': 'test-address',
                'balance': {'spendable': '0', 'unspendable': '0'},
              },
            },
          },
        };

      default:
        // Return a generic successful response for unknown methods
        return {'mmrpc': '2.0', 'result': <String, dynamic>{}};
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Return reasonable defaults for any other calls
    return <String, dynamic>{};
  }
}

class MockKomodoDefiLocalAuth implements KomodoDefiLocalAuth {
  @override
  Future<KdfUser?> get currentUser => Future.value(
    const KdfUser(
      walletId: WalletId(
        name: 'test-wallet',
        authOptions: AuthOptions(derivationMethod: DerivationMethod.hdWallet),
        pubkeyHash: 'test-pubkey-hash',
      ),
      isBip39Seed: false,
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockAssetHistoryStorage implements AssetHistoryStorage {
  @override
  Future<void> addAssetToWallet(WalletId walletId, String assetId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockCustomAssetHistoryStorage implements CustomAssetHistoryStorage {
  @override
  Future<void> addAssetToWallet(WalletId walletId, Asset asset) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockIBalanceManager implements IBalanceManager {
  @override
  Future<void> preCacheBalance(Asset asset) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Helper class for mocking asset lookup
class MockAssetLookup implements IAssetLookup, IAssetRefreshNotifier {
  MockAssetLookup(this._assets);
  final Map<AssetId, Asset> _assets;

  @override
  Map<AssetId, Asset> get available => _assets;

  @override
  Set<Asset> findAssetsByConfigId(String ticker) =>
      _assets.values.where((a) => a.id.id == ticker).toSet();

  @override
  Asset? fromId(AssetId id) => _assets[id];

  @override
  Set<Asset> childAssetsOf(AssetId parentId) =>
      _assets.values.where((a) => a.id.parentId == parentId).toSet();

  @override
  void notifyCustomTokensChanged() {}
}
