import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/src/protocols/erc20/erc20_protocol.dart';
import 'package:komodo_defi_types/src/protocols/utxo/utxo_protocol.dart';

/// Comprehensive test data factory for migration testing.
///
/// This class provides factory methods for creating various test data objects
/// used throughout the migration testing suite. All methods create realistic
/// test data that can be used in unit tests, integration tests, and widget tests.
///
/// Usage:
/// ```dart
/// final testData = TestData();
/// final request = testData.createMigrationRequest();
/// final preview = testData.createMigrationPreview();
/// final progress = testData.createMigrationProgress();
/// ```
class TestData {
  /// Default source wallet ID for testing
  static final WalletId defaultSourceWallet = WalletId(
    name: 'test_source_wallet',
    authOptions: AuthOptions(
      derivationMethod: DerivationMethod.hdWallet,
    ),
  );

  /// Default target wallet ID for testing
  static final WalletId defaultTargetWallet = WalletId(
    name: 'test_target_wallet',
    authOptions: AuthOptions(
      derivationMethod: DerivationMethod.hdWallet,
    ),
  );

  /// Default asset IDs for testing
  static final List<AssetId> defaultAssetIds = [
    AssetId(
      id: 'BTC',
      name: 'Bitcoin',
      symbol: AssetSymbol(assetConfigId: 'BTC'),
      chainId: AssetChainId(chainId: 0),
      derivationPath: null,
      subClass: CoinSubClass.utxo,
    ),
    AssetId(
      id: 'LTC',
      name: 'Litecoin',
      symbol: AssetSymbol(assetConfigId: 'LTC'),
      chainId: AssetChainId(chainId: 2),
      derivationPath: null,
      subClass: CoinSubClass.utxo,
    ),
    AssetId(
      id: 'KMD',
      name: 'Komodo',
      symbol: AssetSymbol(assetConfigId: 'KMD'),
      chainId: AssetChainId(chainId: 141),
      derivationPath: null,
      subClass: CoinSubClass.utxo,
    ),
  ];

  /// Creates a migration request with customizable parameters
  ///
  /// This is the primary entry point for creating test migration requests.
  /// All parameters are optional and will use sensible defaults if not provided.
  MigrationRequest createMigrationRequest({
    WalletId? sourceWalletId,
    WalletId? targetWalletId,
    List<AssetId>? selectedAssets,
    bool activateCoinsOnly = false,
    Map<AssetId, WithdrawalFeeLevel>? feePreferences,
  }) {
    return MigrationRequest(
      sourceWalletId: sourceWalletId ?? defaultSourceWallet,
      targetWalletId: targetWalletId ?? defaultTargetWallet,
      selectedAssets: selectedAssets ?? defaultAssetIds.take(3).toList(),
      activateCoinsOnly: activateCoinsOnly,
      feePreferences: feePreferences ?? _createDefaultFeePreferences(),
    );
  }

  /// Creates an asset migration preview with realistic test data
  ///
  /// Represents what a single asset's migration would look like,
  /// including balance, fees, and net amount calculations.
  AssetMigrationPreview createAssetPreview({
    AssetId? assetId,
    String? sourceAddress,
    String? targetAddress,
    Decimal? estimatedFee,
    MigrationAssetStatus? status,
    String? errorMessage,
  }) {
    final id = assetId ?? AssetId(
      id: 'BTC',
      name: 'Bitcoin',
      symbol: AssetSymbol(assetConfigId: 'BTC'),
      chainId: AssetChainId(chainId: 0),
      derivationPath: null,
      subClass: CoinSubClass.utxo,
    );
    final fee = estimatedFee ?? Decimal.fromInt(1);

    return AssetMigrationPreview(
      assetId: id,
      sourceAddress: sourceAddress ?? 'source_address_${id.id}',
      targetAddress: targetAddress ?? 'target_address_${id.id}',
      balance: Decimal.fromInt(100),
      estimatedFee: fee,
      netAmount: Decimal.fromInt(100) - fee,
      status: status ?? MigrationAssetStatus.ready,
      errorMessage: errorMessage,
    );
  }

  /// Creates a migration summary with calculated totals
  ///
  /// Provides overview statistics for a migration operation,
  /// including total assets, balances, fees, and estimated duration.
  MigrationSummary createMigrationSummary({
    int? totalAssets,
    Decimal? totalFee,
  }) {
    final assets = totalAssets ?? 3;
    final fee = totalFee ?? Decimal.fromInt(assets);

    return MigrationSummary(
      totalAssets: assets,
      readyAssets: assets,
      failedAssets: 0,
      totalEstimatedFees: fee,
    );
  }

  /// Creates a list of asset migration progress objects
  ///
  /// Used for tracking individual asset progress during migration execution.
  /// Can create progress for different stages of the migration process.
  List<AssetMigrationProgress> createAssetProgressList({
    List<AssetId>? assetIds,
    AssetMigrationStatus? status,
    bool includeCompletedAssets = false,
    bool includeFailedAssets = false,
  }) {
    final assets = assetIds ?? defaultAssetIds.take(3).toList();

    return assets.asMap().entries.map((entry) {
      final index = entry.key;
      final assetId = entry.value;

      AssetMigrationStatus assetStatus;
      String? txHash;
      String? errorMessage;

      if (includeFailedAssets && index == assets.length - 1) {
        assetStatus = AssetMigrationStatus.failed;
        errorMessage = 'Test failure for asset ${assetId.id}';
      } else if (includeCompletedAssets || status == AssetMigrationStatus.completed) {
        assetStatus = AssetMigrationStatus.completed;
        txHash = 'tx_hash_${assetId.id}';
      } else {
        assetStatus = status ?? AssetMigrationStatus.pending;
      }

      return AssetMigrationProgress(
        assetId: assetId,
        status: assetStatus,
        progress: assetStatus == AssetMigrationStatus.completed ? 1.0 : 0.0,
        txHash: txHash,
        errorMessage: errorMessage,
      );
    }).toList();
  }

  /// Creates a complete migration preview for testing
  ///
  /// This is a comprehensive preview object that includes all the data
  /// needed to test preview generation and display functionality.
  MigrationOperationPreview createMockPreview({
    String? previewId,
    WalletId? sourceWallet,
    WalletId? targetWallet,
    List<AssetId>? assetIds,
    bool includeProblematicAssets = false,
  }) {
    final id = previewId ?? 'preview_${DateTime.now().millisecondsSinceEpoch}';
    final source = sourceWallet ?? defaultSourceWallet;
    final target = targetWallet ?? defaultTargetWallet;
    final assets = assetIds ?? defaultAssetIds.take(3).toList();

    final assetPreviews = assets.map((assetId) {
      return createAssetPreview(
        assetId: assetId,
        estimatedFee: Decimal.fromInt(1),
      );
    }).toList();

    return MigrationOperationPreview(
      previewId: id,
      sourceWallet: source,
      targetWallet: target,
      assets: assetPreviews,
      summary: createMigrationSummary(
        totalAssets: assets.length,
        totalFee: assetPreviews.fold<Decimal>(
          Decimal.zero,
          (sum, preview) => sum + preview.estimatedFee,
        ),
      ),
      createdAt: DateTime.now(),
    );
  }

  /// Creates migration progress data for different stages
  ///
  /// Can simulate progress at various stages of migration execution,
  /// including initial, in-progress, and completion states.
  MigrationProgress createMockProgress({
    String? migrationId,
    MigrationStatus? status,
    int? totalAssets,
    int? completedAssets,
    DateTime? startedAt,
    DateTime? completedAt,
    bool includeAssetProgress = true,
  }) {
    final id = migrationId ?? 'migration_${DateTime.now().millisecondsSinceEpoch}';
    final total = totalAssets ?? 3;
    final completed = completedAssets ?? 0;
    final migrationStatus = status ?? MigrationStatus.inProgress;

    List<AssetMigrationProgress> assetProgress = [];
    if (includeAssetProgress) {
      assetProgress = createAssetProgressList(
        assetIds: defaultAssetIds.take(total).toList(),
        includeCompletedAssets: completed > 0,
      );

      // Update statuses based on completed count
      for (int i = 0; i < total && i < assetProgress.length; i++) {
        if (i < completed) {
          assetProgress[i] = AssetMigrationProgress(
            assetId: assetProgress[i].assetId,
            status: AssetMigrationStatus.completed,
            progress: 1.0,
            txHash: 'tx_hash_${assetProgress[i].assetId.id}',
          );
        }
      }
    }

    return MigrationProgress(
      migrationId: id,
      status: migrationStatus,
      totalCount: total,
      completedCount: completed,
      assetProgress: assetProgress,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  /// Creates a completed migration result
  ///
  /// Represents the final result of a migration operation with
  /// success/failure statistics and individual asset results.
  MigrationResult createMockResult({
    String? migrationId,
    MigrationResultStatus? status,
    int? totalAssets,
    int? successCount,
    int? failureCount,
    DateTime? startedAt,
    DateTime? completedAt,
    List<AssetId>? assetIds,
  }) {
    final id = migrationId ?? 'migration_${DateTime.now().millisecondsSinceEpoch}';
    final total = totalAssets ?? 3;
    final successful = successCount ?? 3;
    final failed = failureCount ?? 0;
    final assets = assetIds ?? defaultAssetIds.take(total).toList();

    final assetResults = assets.asMap().entries.map((entry) {
      final index = entry.key;
      final assetId = entry.value;
      final isSuccessful = index < successful;

      return AssetMigrationResult(
        assetId: assetId,
        status: isSuccessful ? AssetMigrationStatus.completed : AssetMigrationStatus.failed,
        txHash: isSuccessful ? 'tx_hash_${assetId.id}' : null,
        errorMessage: isSuccessful ? null : 'Test failure for ${assetId.id}',
      );
    }).toList();

    return MigrationResult(
      migrationId: id,
      status: status ?? (failed > 0 ? MigrationResultStatus.partiallyCompleted : MigrationResultStatus.completed),
      totalCount: total,
      successCount: successful,
      failureCount: failed,
      startedAt: startedAt ?? DateTime.now().subtract(const Duration(minutes: 10)),
      completedAt: completedAt ?? DateTime.now(),
      assetResults: assetResults.map((result) => AssetMigrationProgress(
        assetId: result.assetId,
        status: result.status,
        txHash: result.txHash,
        errorMessage: result.errorMessage,
      )).toList(),
    );
  }

  /// Creates a list of mock wallets for testing wallet selection
  ///
  /// Provides different types of wallets (HD, Iguana, Hardware) for
  /// testing wallet selection and validation logic.
  List<WalletInfo> createMockWallets({
    int count = 5,
    bool includeAllTypes = true,
  }) {
    final wallets = <WalletInfo>[];

    for (int i = 0; i < count; i++) {
      WalletType type;
      if (includeAllTypes) {
        final types = [WalletType.hd, WalletType.iguana, WalletType.hardware];
        type = types[i % types.length];
      } else {
        type = WalletType.hd;
      }

      wallets.add(WalletInfo(
        id: WalletId(
          name: 'wallet_$i',
          authOptions: AuthOptions(
            derivationMethod: DerivationMethod.hdWallet,
          ),
        ),
        name: 'Test Wallet $i',
        type: type,
      ));
    }

    return wallets;
  }

  /// Creates a list of mock asset info objects
  ///
  /// Provides asset information including balances and activation status
  /// for testing asset selection and filtering functionality.
  List<AssetInfo> createMockAssetInfoList({
    List<AssetId>? assetIds,
    bool includeInactiveAssets = true,
    bool includeZeroBalances = false,
  }) {
    final assets = assetIds ?? defaultAssetIds;

    return assets.map((assetId) {
      final isActivated = !includeInactiveAssets ||
          (includeInactiveAssets && assetId != assets.last);
      final balance = includeZeroBalances && assetId == assets.first
          ? 0.0
          : 100.0 + assets.indexOf(assetId) * 10.0;

      return AssetInfo(
        id: assetId,
        name: _getAssetName(assetId),
        balance: balance,
        isActivated: isActivated,
      );
    }).toList();
  }

  /// Creates a list of mock assets for service testing
  List<Asset> createMockAssets({
    List<AssetId>? assetIds,
  }) {
    final assets = assetIds ?? defaultAssetIds;

    return assets.map((assetId) => createMockAsset(assetId)).toList();
  }

  /// Creates a single mock asset
  Asset createMockAsset(AssetId assetId) {
    ProtocolClass protocol;

    // Create different protocol types based on the asset's subclass
    if (assetId.subClass == CoinSubClass.erc20) {
      protocol = Erc20Protocol.fromJson({
        'type': 'ERC20',
        'coin': assetId.id,
        'nodes': [
          {
            'url': 'https://mainnet.infura.io/v3/test',
            'gui_auth': false,
          }
        ],
        'swap_contract_address': '0x24ABE4c71FC658C91313b6552cd40cD808b3Ea80',
        'fallback_swap_contract': '0x24ABE4c71FC658C91313b6552cd40cD808b3Ea80',
        'chain_id': 1,
      });
    } else {
      protocol = UtxoProtocol.fromJson({
        'type': 'UTXO',
        'coin': assetId.id,
        'is_testnet': false,
        'pubtype': 60,
        'p2shtype': 85,
        'wiftype': 188,
        'mm2': 1,
      });
    }

    return Asset(
      id: assetId,
      protocol: protocol,
      isWalletOnly: false,
      signMessagePrefix: null,
    );
  }

  /// Creates a network error for testing error scenarios
  ///
  /// Simulates various types of network-related failures that can
  /// occur during migration operations.
  MigrationException createNetworkError({
    MigrationErrorType? errorType,
    String? message,
  }) {
    return MigrationException(
      errorType ?? MigrationErrorType.networkError,
      message ?? 'Network connection failed during migration',
    );
  }

  /// Creates an insufficient balance error
  MigrationException createInsufficientBalanceError({
    AssetId? assetId,
    Decimal? requiredAmount,
    Decimal? availableAmount,
  }) {
    final asset = assetId ?? AssetId(
        id: 'BTC',
        name: 'Bitcoin',
        symbol: AssetSymbol(assetConfigId: 'BTC'),
        chainId: AssetChainId(chainId: 0),
        derivationPath: null,
        subClass: CoinSubClass.utxo,
      );
    final required = requiredAmount ?? Decimal.fromInt(100);
    final available = availableAmount ?? Decimal.fromInt(50);

    return MigrationException(
      MigrationErrorType.insufficientBalance,
      'Insufficient balance for ${asset.id}: required $required, available $available',
    );
  }

  /// Creates a wallet locked error
  MigrationException createWalletLockedError({
    WalletId? walletId,
  }) {
    final wallet = walletId ?? defaultSourceWallet;

    return MigrationException(
      MigrationErrorType.walletLocked,
      'Wallet ${wallet.name} is locked and cannot be used for migration',
    );
  }

  /// Creates large dataset for performance testing
  ///
  /// Generates a large number of assets and related data for testing
  /// performance and memory usage under load conditions.
  Map<String, dynamic> createLargeDataset({
    int assetCount = 100,
    int walletCount = 10,
  }) {
    final largeAssetList = List.generate(
      assetCount,
      (index) => AssetId(
        id: 'ASSET_${index.toString().padLeft(3, '0')}',
        name: 'Asset ${index.toString().padLeft(3, '0')}',
        symbol: AssetSymbol(assetConfigId: 'A${index.toString().padLeft(3, '0')}'),
        chainId: AssetChainId(chainId: 1),
        derivationPath: null,
        subClass: CoinSubClass.utxo,
      ),
    );

    final largeWalletList = List.generate(
      walletCount,
      (index) => WalletId(
        name: 'WALLET_${index.toString().padLeft(2, '0')}',
        authOptions: AuthOptions(
          derivationMethod: DerivationMethod.hdWallet,
        ),
      ),
    );

    return {
      'assets': createMockAssets(assetIds: largeAssetList),
      'wallets': largeWalletList.map((id) => WalletInfo(
        id: id,
        name: 'Performance Test Wallet ${id.name}',
        type: WalletType.values[largeWalletList.indexOf(id) % WalletType.values.length],
      )).toList(),
      'migration_request': createMigrationRequest(
        selectedAssets: largeAssetList.take(50).toList(),
      ),
      'migration_preview': createMockPreview(
        assetIds: largeAssetList.take(50).toList(),
      ),
    };
  }

  /// Creates edge case test scenarios
  ///
  /// Provides various edge cases and boundary conditions for
  /// comprehensive testing coverage.
  Map<String, dynamic> createEdgeCaseScenarios() {
    return {
      'empty_asset_list': createMigrationRequest(selectedAssets: []),
      'single_asset': createMigrationRequest(
        selectedAssets: [AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        )],
      ),
      'all_failed_assets': createMockProgress(
        totalAssets: 3,
        completedAssets: 0,
        status: MigrationStatus.failed,
      ),
      'partial_success': createMockProgress(
        totalAssets: 5,
        completedAssets: 3,
        status: MigrationStatus.partiallyCompleted,
      ),
      'zero_balance_assets': createMockAssetInfoList(
        includeZeroBalances: true,
      ),
      'very_large_amounts': createAssetPreview(
        estimatedFee: Decimal.parse('0.00000001'),
      ),
      'same_source_target': createMigrationRequest(
        sourceWalletId: defaultSourceWallet,
        targetWalletId: defaultSourceWallet,
      ),
    };
  }

  /// Helper method to get asset name from ID
  String _getAssetName(AssetId assetId) {
    const names = {
      'BTC': 'Bitcoin',
      'LTC': 'Litecoin',
      'KMD': 'Komodo',
      'ETH': 'Ethereum',
      'USDT': 'Tether USD',
    };

    return names[assetId.id] ?? assetId.id;
  }

  /// Helper method to create default fee preferences
  Map<AssetId, WithdrawalFeeLevel> _createDefaultFeePreferences() {
    return Map.fromEntries(
      defaultAssetIds.map((assetId) => MapEntry(assetId, WithdrawalFeeLevel.medium)),
    );
  }
}

/// Helper classes for test data

class WalletInfo {
  final WalletId id;
  final String name;
  final WalletType type;

  const WalletInfo({
    required this.id,
    required this.name,
    required this.type,
  });
}

class AssetInfo {
  final AssetId id;
  final String name;
  final double balance;
  final bool isActivated;

  const AssetInfo({
    required this.id,
    required this.name,
    required this.balance,
    required this.isActivated,
  });
}

enum WalletType { hd, iguana, hardware }

class AssetMigrationResult {
  final AssetId assetId;
  final AssetMigrationStatus status;
  final String? txHash;
  final String? errorMessage;

  const AssetMigrationResult({
    required this.assetId,
    required this.status,
    this.txHash,
    this.errorMessage,
  });
}
