import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/_internal_exports.dart';
import 'package:komodo_defi_sdk/src/activation/retryable_activation_manager.dart';
import 'package:komodo_defi_types/src/utils/retry_config.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import 'mock_implementations.dart';

/// Enhanced test setup class with configurable mock responses
class ActivationManagerTestSetup {
  late MockApiClient mockClient;
  late MockKomodoDefiLocalAuth mockAuth;
  late MockAssetHistoryStorage mockAssetHistory;
  late MockCustomAssetHistoryStorage mockCustomTokenHistory;
  late MockIBalanceManager mockBalanceManager;
  late MockAssetLookup mockAssetLookup;
  late ActivationManager activationManager;
  late Asset testAsset;

  /// Configure which coins should appear as "enabled" in tests
  List<EnabledCoinInfo> enabledCoinsForTest = [];

  /// Set up the test environment with optional pre-enabled coins
  void setUp({
    List<String>? preEnabledCoinTickers,
    IActivationStrategyFactory? activationStrategyFactory,
    Duration? operationTimeout,
  }) {
    // Create enabled coins list from tickers
    enabledCoinsForTest =
        (preEnabledCoinTickers ?? [])
            .map((ticker) => EnabledCoinInfo(ticker: ticker))
            .toList();

    // Initialize mocks with configurable responses
    mockClient = MockApiClient(enabledCoins: enabledCoinsForTest);
    mockAuth = MockKomodoDefiLocalAuth();
    mockAssetHistory = MockAssetHistoryStorage();
    mockCustomTokenHistory = MockCustomAssetHistoryStorage();
    mockBalanceManager = MockIBalanceManager();

    // Create test asset
    final assetId = AssetId(
      id: 'BTC',
      name: 'Bitcoin',
      symbol: AssetSymbol(assetConfigId: 'BTC'),
      chainId: AssetChainId(chainId: 1),
      derivationPath: null,
      subClass: CoinSubClass.utxo,
      parentId: null,
    );

    testAsset = Asset(
      id: assetId,
      protocol: UtxoProtocol.fromJson({
        'type': 'UTXO',
        'is_testnet': false,
        'pubtype': 60,
        'p2shtype': 85,
        'wiftype': 188,
        'txfee': 1000,
        'txversion': 4,
        'overwintered': 1,
        'electrum': [
          {'url': 'test-electrum.example.com:50001', 'protocol': 'TCP'},
        ],
      }),
      isWalletOnly: false,
      signMessagePrefix: null,
    );

    // Set up asset lookup mock
    mockAssetLookup = MockAssetLookup({assetId: testAsset});

    // Create activation manager with optional strategy factory and timeout
    activationManager = ActivationManager(
      mockClient,
      mockAuth,
      mockAssetHistory,
      mockCustomTokenHistory,
      mockAssetLookup,
      mockBalanceManager,
      activationStrategyFactory: activationStrategyFactory,
      operationTimeout: operationTimeout,
    );
  }

  /// Create a test setup with specific assets and enabled coins
  void setUpWithAssets({
    required List<Asset> assets,
    List<String>? preEnabledCoinTickers,
    IActivationStrategyFactory? activationStrategyFactory,
    Duration? operationTimeout,
  }) {
    // Create enabled coins list from tickers
    enabledCoinsForTest =
        (preEnabledCoinTickers ?? [])
            .map((ticker) => EnabledCoinInfo(ticker: ticker))
            .toList();

    // Initialize mocks with configurable responses
    mockClient = MockApiClient(enabledCoins: enabledCoinsForTest);
    mockAuth = MockKomodoDefiLocalAuth();
    mockAssetHistory = MockAssetHistoryStorage();
    mockCustomTokenHistory = MockCustomAssetHistoryStorage();
    mockBalanceManager = MockIBalanceManager();

    // Use the first asset as the test asset
    testAsset = assets.first;

    // Set up asset lookup mock with all provided assets
    final assetMap = <AssetId, Asset>{};
    for (final asset in assets) {
      assetMap[asset.id] = asset;
    }
    mockAssetLookup = MockAssetLookup(assetMap);

    // Create activation manager with optional strategy factory and timeout
    activationManager = ActivationManager(
      mockClient,
      mockAuth,
      mockAssetHistory,
      mockCustomTokenHistory,
      mockAssetLookup,
      mockBalanceManager,
      activationStrategyFactory: activationStrategyFactory,
      operationTimeout: operationTimeout,
    );
  }

  /// Update the enabled coins configuration at runtime
  void updateEnabledCoins(
    List<String> tickers, {
    IActivationStrategyFactory? activationStrategyFactory,
    Duration? operationTimeout,
  }) {
    enabledCoinsForTest =
        tickers.map((ticker) => EnabledCoinInfo(ticker: ticker)).toList();

    // Recreate the mock client with new enabled coins
    mockClient = MockApiClient(enabledCoins: enabledCoinsForTest);

    // Recreate the activation manager with the updated client
    activationManager = ActivationManager(
      mockClient,
      mockAuth,
      mockAssetHistory,
      mockCustomTokenHistory,
      mockAssetLookup,
      mockBalanceManager,
      activationStrategyFactory: activationStrategyFactory,
      operationTimeout: operationTimeout,
    );
  }

  /// Set up test environment using RetryableActivationManager
  void setUpWithRetryableManager({
    List<String>? preEnabledCoinTickers,
    IActivationStrategyFactory? activationStrategyFactory,
    Duration? operationTimeout,
    RetryConfig? retryConfig,
    RetryStrategy? retryStrategy,
  }) {
    setUp(
      preEnabledCoinTickers: preEnabledCoinTickers,
      activationStrategyFactory: activationStrategyFactory,
      operationTimeout: operationTimeout,
    );
  }

  /// Create a RetryableActivationManager for testing
  RetryableActivationManager createRetryableManager({
    IActivationStrategyFactory? activationStrategyFactory,
    RetryConfig? retryConfig,
    RetryStrategy? retryStrategy,
    Duration? operationTimeout,
  }) {
    return RetryableActivationManager(
      mockClient,
      mockAuth,
      mockAssetHistory,
      mockCustomTokenHistory,
      mockAssetLookup,
      mockBalanceManager,
      activationStrategyFactory: activationStrategyFactory,
      retryConfig: retryConfig ?? RetryConfig.testing,
      retryStrategy: retryStrategy ?? const NoRetryStrategy(),
      operationTimeout: operationTimeout ?? const Duration(milliseconds: 500),
    );
  }

  /// Helper to create common test scenarios
  void setUpScenario(TestScenario scenario) {
    switch (scenario) {
      case TestScenario.noCoinsEnabled:
        setUp(preEnabledCoinTickers: []);
      case TestScenario.btcAlreadyEnabled:
        setUp(preEnabledCoinTickers: ['BTC']);
      case TestScenario.multipleCoinsEnabled:
        setUp(preEnabledCoinTickers: ['BTC', 'ETH', 'LTC']);
    }
  }

  Future<void> tearDown() async {
    await activationManager.dispose();
  }
}

/// Common test scenarios for easy setup
enum TestScenario { noCoinsEnabled, btcAlreadyEnabled, multipleCoinsEnabled }
