import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:mocktail/mocktail.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_sdk/src/activation/activation_manager.dart';
import 'package:komodo_defi_sdk/src/assets/asset_lookup.dart';
import 'package:komodo_defi_sdk/src/balances/balance_manager.dart';
import 'package:komodo_defi_sdk/src/fees/fee_manager.dart';
import 'package:komodo_defi_sdk/src/withdrawals/withdrawal_manager.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

// Mock classes using mocktail
class MockActivationManager extends Mock implements ActivationManager {}
class MockAssetProvider extends Mock implements IAssetProvider {}
class MockBalanceManager extends Mock implements IBalanceManager {}
class MockFeeManager extends Mock implements FeeManager {}
class MockWithdrawalManager extends Mock implements WithdrawalManager {}
class MockKomodoDefiRpc extends Mock implements ApiClient {}

/// Collection of mock services for testing migration functionality
class MockServices {
  late final MockActivationManager activationManager;
  late final MockAssetProvider assetProvider;
  late final MockBalanceManager balanceManager;
  late final MockFeeManager feeManager;
  late final MockWithdrawalManager withdrawalManager;
  late final MockKomodoDefiRpc client;

  // Internal state for mock behaviors
  bool _shouldFail = false;
  Map<AssetId, Asset> _mockAssets = {};
  Map<AssetId, bool> _activationResults = {};
  Map<AssetId, Decimal> _mockBalances = {};
  Map<AssetId, Decimal> _mockFees = {};
  Map<AssetId, String> _mockTxHashes = {};
  Map<String, dynamic> _mockResponses = {};
  Duration _operationDelay = Duration.zero;

  MockServices() {
    activationManager = MockActivationManager();
    assetProvider = MockAssetProvider();
    balanceManager = MockBalanceManager();
    feeManager = MockFeeManager();
    withdrawalManager = MockWithdrawalManager();
    client = MockKomodoDefiRpc();

    _setupDefaultBehaviors();
  }

  void _setupDefaultBehaviors() {
    // Setup asset provider behaviors
    when(() => assetProvider.available).thenAnswer((_) {
      if (_shouldFail) throw Exception('Mock asset provider failure');
      final assets = _mockAssets.isEmpty ? _createDefaultAssets() : _mockAssets.values.toList();
      return {for (final asset in assets) asset.id: asset};
    });

    when(() => assetProvider.getActivatedAssets()).thenAnswer((_) async {
      if (_shouldFail) throw Exception('Mock asset provider failure');
      if (_operationDelay > Duration.zero) await Future.delayed(_operationDelay);
      final assets = _mockAssets.isEmpty ? _createDefaultAssets() : _mockAssets.values.toList();
      return assets;
    });

    when(() => assetProvider.getEnabledCoins()).thenAnswer((_) async {
      if (_shouldFail) throw Exception('Mock asset provider failure');
      final assets = await assetProvider.getActivatedAssets();
      return assets.map((asset) => asset.id.id).toSet();
    });

    when(() => assetProvider.childAssetsOf(any())).thenReturn(<Asset>{});
    when(() => assetProvider.findAssetsByConfigId(any())).thenReturn(<Asset>{});

    when(() => assetProvider.fromId(any())).thenAnswer((invocation) {
      final id = invocation.positionalArguments[0] as AssetId;
      final available = assetProvider.available;
      return available[id];
    });

    // Setup activation manager behaviors (updated to stream-based API)
        when(() => activationManager.activateAsset(any())).thenAnswer((invocation) {
          if (_shouldFail) {
            return Stream<ActivationProgress>.error(Exception('Mock activation failure'));
          }
          final asset = invocation.positionalArguments[0] as Asset;
          final success = _activationResults[asset.id] ?? true;
          if (success) {
            return Stream.value(ActivationProgress.success());
          } else {
            return Stream.value(
              ActivationProgress.error(message: 'Mock activation failure'),
            );
          }
        });
    // Removed obsolete batchActivate mock (method no longer exists on ActivationManager)

    // Setup balance manager behaviors
    when(() => balanceManager.getBalance(any())).thenAnswer((invocation) async {
      if (_shouldFail) throw Exception('Mock balance manager failure');
      if (_operationDelay > Duration.zero) await Future.delayed(_operationDelay);

      final assetId = invocation.positionalArguments[0] as AssetId;
      final balance = _mockBalances[assetId] ?? Decimal.fromInt(100);
      return BalanceInfo(
        total: balance,
        spendable: balance,
        unspendable: Decimal.zero,
      );
    });

    // Removed unsupported IBalanceManager method mocks (getBalances, refreshBalance, watchBalances)
    when(() => balanceManager.watchBalance(any(),
        activateIfNeeded: any(named: 'activateIfNeeded'))).thenAnswer((invocation) {
      if (_shouldFail) return Stream.error(Exception('Mock balance manager failure'));
      final assetId = invocation.positionalArguments[0] as AssetId;
      final balance = _mockBalances[assetId] ?? Decimal.fromInt(100);
      return Stream.value(BalanceInfo(
        total: balance,
        spendable: balance,
        unspendable: Decimal.zero,
      ));
    });

    when(() => balanceManager.dispose()).thenAnswer((_) async {});
    when(() => balanceManager.lastKnown(any())).thenReturn(null);
    when(() => balanceManager.precacheBalance(any())).thenAnswer((_) async {});

    // Setup fee manager behaviors
    // Removed feeManager.estimateWithdrawalFee mock (not required for current tests)

    // (WithdrawalManager withdraw stream no longer needed for current tests; original mock removed because signature changed)
    // If needed later, add a stream-based mock here.

    // Setup RPC client behaviors
    when(() => client.call<dynamic>(any(), any())).thenAnswer((invocation) async {
      if (_shouldFail) throw Exception('Mock RPC failure');

      final method = invocation.positionalArguments[0] as String;
      return _mockResponses[method] ?? <String, dynamic>{};
    });

    when(() => client.stream<dynamic>(any(), any())).thenAnswer((invocation) {
      if (_shouldFail) return Stream.error(Exception('Mock RPC failure'));

      final method = invocation.positionalArguments[0] as String;
      return Stream.value(_mockResponses[method] ?? <String, dynamic>{});
    });

    when(() => client.executeRpc(any())).thenAnswer((_) async {
      if (_shouldFail) throw Exception('Mock RPC failure');
      return {'result': 'mock_response'};
    });

    when(() => client.dispose()).thenReturn(null);
    when(() => client.isDisposed).thenReturn(false);
  }

  // Configuration methods
  void setShouldFail(bool shouldFail) {
    _shouldFail = shouldFail;
  }

  void setMockAssets(List<Asset> assets) {
    _mockAssets.clear();
    for (final asset in assets) {
      _mockAssets[asset.id] = asset;
    }
  }

  void setActivationResults(Map<AssetId, bool> results) {
    _activationResults = results;
  }

  void setMockBalances(Map<AssetId, Decimal> balances) {
    _mockBalances = balances;
  }

  void setMockFees(Map<AssetId, Decimal> fees) {
    _mockFees = fees;
  }

  void setMockTxHashes(Map<AssetId, String> txHashes) {
    _mockTxHashes = txHashes;
  }

  void setMockResponse(String method, dynamic response) {
    _mockResponses[method] = response;
  }

  void setOperationDelay(Duration delay) {
    _operationDelay = delay;
  }

  List<Asset> _createDefaultAssets() {
    return [
      Asset(
        id: AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        ),
        protocol: UtxoProtocol.fromJson({
          'type': 'UTXO',
          'coin': 'BTC',
          'is_testnet': false,
          'pubtype': 60,
          'p2shtype': 85,
          'wiftype': 188,
          'mm2': 1,
        }),
        isWalletOnly: false,
        signMessagePrefix: null,
      ),
      Asset(
        id: AssetId(
          id: 'LTC',
          name: 'Litecoin',
          symbol: AssetSymbol(assetConfigId: 'LTC'),
          chainId: AssetChainId(chainId: 2),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        ),
        protocol: UtxoProtocol.fromJson({
          'type': 'UTXO',
          'coin': 'LTC',
          'is_testnet': false,
          'pubtype': 60,
          'p2shtype': 85,
          'wiftype': 188,
          'mm2': 1,
        }),
        isWalletOnly: false,
        signMessagePrefix: null,
      ),
      Asset(
        id: AssetId(
          id: 'ETH',
          name: 'Ethereum',
          symbol: AssetSymbol(assetConfigId: 'ETH'),
          chainId: AssetChainId(chainId: 1),
          derivationPath: null,
          subClass: CoinSubClass.erc20,
        ),
        protocol: EvmProtocol.fromJson({
          'type': 'EVM',
          'chain_id': 1,
          'coin': 'ETH',
          'rpc_url': 'https://mainnet.infura.io/v3/test',
        }),
        isWalletOnly: false,
        signMessagePrefix: null,
      ),
    ];
  }
}

/// Withdrawal request model for testing
class WithdrawalRequest {
  final AssetId assetId;
  final String targetAddress;
  final Decimal amount;

  WithdrawalRequest({
    required this.assetId,
    required this.targetAddress,
    required this.amount,
  });
}
