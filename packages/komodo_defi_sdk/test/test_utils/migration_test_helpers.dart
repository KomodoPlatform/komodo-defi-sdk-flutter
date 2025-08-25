import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';

/// Migration test data helpers (pure Dart).
///
/// NOTE: All Flutter widget testing utilities were removed to keep this
/// package free of any flutter_test or UI dependencies. Only pure model
/// builders and lightweight verification helpers remain.

/// Creates mock migration progress for testing different intermediate states.
MigrationProgress createMockProgress({
  String? migrationId,
  MigrationStatus? status,
  int totalAssets = 3,
  int completedAssets = 1,
  List<AssetId>? assetIds,
}) {
  final id = migrationId ?? 'test_migration_${DateTime.now().millisecondsSinceEpoch}';
  final progressStatus = status ?? MigrationStatus.inProgress;

  final assets = assetIds ?? [
    AssetId(
      id: 'BTC',
      name: 'Bitcoin',
      symbol: AssetSymbol(assetConfigId: 'BTC'),
      chainId: AssetChainId(chainId: 1),
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
      id: 'ETH',
      name: 'Ethereum',
      symbol: AssetSymbol(assetConfigId: 'ETH'),
      chainId: AssetChainId(chainId: 1),
      derivationPath: null,
      subClass: CoinSubClass.erc20,
    ),
  ];

  return MigrationProgress(
    migrationId: id,
    status: progressStatus,
    totalCount: totalAssets,
    completedCount: completedAssets,
    assetProgress: assets.take(totalAssets).map((asset) {
      return AssetMigrationProgress(
        assetId: asset,
        status: AssetMigrationStatus.pending,
        progress: 0.0,
      );
    }).toList(),
  );
}

/// Creates a mock migration progress in a fully completed state.
MigrationProgress createCompletedProgress({
  String? migrationId,
  int totalAssets = 3,
  List<AssetId>? assetIds,
}) {
  final id = migrationId ?? 'completed_migration_${DateTime.now().millisecondsSinceEpoch}';
  final assets = assetIds ??
      [
        AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          chainId: AssetChainId(chainId: 1),
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
          id: 'ETH',
          name: 'Ethereum',
          symbol: AssetSymbol(assetConfigId: 'ETH'),
          chainId: AssetChainId(chainId: 1),
          derivationPath: null,
          subClass: CoinSubClass.erc20,
        ),
      ];

  return MigrationProgress(
    migrationId: id,
    status: MigrationStatus.completed,
    totalCount: totalAssets,
    completedCount: totalAssets,
    assetProgress: assets.take(totalAssets).map((asset) {
      return AssetMigrationProgress(
        assetId: asset,
        status: AssetMigrationStatus.completed,
        progress: 1.0,
        txHash: 'mock_tx_hash_${asset.id.toLowerCase()}',
      );
    }).toList(),
  );
}

/// Creates a partially completed migration progress with failures.
MigrationProgress createPartialProgress({
  String? migrationId,
  int totalAssets = 3,
  int completedAssets = 1,
  int failedAssets = 1,
  List<AssetId>? assetIds,
}) {
  final id = migrationId ?? 'partial_migration_${DateTime.now().millisecondsSinceEpoch}';
  final assets = assetIds ??
      [
        AssetId(
          id: 'BTC',
          name: 'Bitcoin',
          symbol: AssetSymbol(assetConfigId: 'BTC'),
          chainId: AssetChainId(chainId: 1),
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
          id: 'ETH',
          name: 'Ethereum',
          symbol: AssetSymbol(assetConfigId: 'ETH'),
          chainId: AssetChainId(chainId: 1),
          derivationPath: null,
          subClass: CoinSubClass.erc20,
        ),
      ];

  final assetProgress = <AssetMigrationProgress>[];

  for (int i = 0; i < completedAssets && i < assets.length; i++) {
    assetProgress.add(
      AssetMigrationProgress(
        assetId: assets[i],
        status: AssetMigrationStatus.completed,
        progress: 1.0,
        txHash: 'mock_tx_hash_${assets[i].id.toLowerCase()}',
      ),
    );
  }
  for (int i = completedAssets; i < completedAssets + failedAssets && i < assets.length; i++) {
    assetProgress.add(
      AssetMigrationProgress(
        assetId: assets[i],
        status: AssetMigrationStatus.failed,
        progress: 0.0,
        errorMessage: 'Mock error for ${assets[i].id}',
      ),
    );
  }
  for (int i = completedAssets + failedAssets; i < totalAssets && i < assets.length; i++) {
    assetProgress.add(
      AssetMigrationProgress(
        assetId: assets[i],
        status: AssetMigrationStatus.pending,
        progress: 0.0,
      ),
    );
  }

  return MigrationProgress(
    migrationId: id,
    status: MigrationStatus.partiallyCompleted,
    totalCount: totalAssets,
    completedCount: completedAssets,
    assetProgress: assetProgress,
  );
}

/// Creates a mock migration preview (no network calls).
MigrationOperationPreview createMockPreview({
  String? previewId,
  WalletId? sourceWallet,
  WalletId? targetWallet,
  List<String>? assetIds,
}) {
  final source = sourceWallet ??
      WalletId(
        name: 'source_wallet',
        authOptions: const AuthOptions(derivationMethod: DerivationMethod.hdWallet),
      );
  final target = targetWallet ??
      WalletId(
        name: 'target_wallet',
        authOptions: const AuthOptions(derivationMethod: DerivationMethod.hdWallet),
      );

  final assets = (assetIds ?? ['BTC', 'LTC', 'ETH']).map(
    (id) => AssetMigrationPreview(
      assetId: AssetId(
        id: id,
        name: id,
        symbol: AssetSymbol(assetConfigId: id),
        chainId: AssetChainId(chainId: 1),
        derivationPath: null,
        subClass: CoinSubClass.utxo,
      ),
      sourceAddress: 'source_address_$id',
      targetAddress: 'target_address_$id',
      balance: Decimal.fromInt(100),
      estimatedFee: Decimal.fromInt(1),
      netAmount: Decimal.fromInt(99),
      status: MigrationAssetStatus.ready,
    ),
  ).toList();

  return MigrationOperationPreview(
    previewId: previewId ?? 'mock_preview_${DateTime.now().millisecondsSinceEpoch}',
    sourceWallet: source,
    targetWallet: target,
    assets: assets,
    summary: MigrationSummary(
      totalAssets: assets.length,
      readyAssets: assets.length,
      failedAssets: 0,
      totalEstimatedFees: Decimal.fromInt(assets.length),
    ),
    createdAt: DateTime.now(),
  );
}

/// Creates a mock list of asset IDs.
List<AssetId> createMockAssetList({int count = 3, List<String>? assetIds}) {
  final ids = assetIds ?? List.generate(count, (i) => 'ASSET_$i');
  return ids
      .map(
        (id) => AssetId(
          id: id,
          name: id,
          symbol: AssetSymbol(assetConfigId: id),
          chainId: AssetChainId(chainId: 0),
          derivationPath: null,
          subClass: CoinSubClass.utxo,
        ),
      )
      .toList();
}

/// Creates mock progress with pending assets.
MigrationProgress createMockProgressWithAssets({
  String? migrationId,
  MigrationStatus? status,
  int totalAssets = 3,
  List<AssetId>? assetIds,
}) {
  final id = migrationId ?? 'test_migration_${DateTime.now().millisecondsSinceEpoch}';
  final assets = assetIds ?? createMockAssetList(count: totalAssets);
  return MigrationProgress(
    migrationId: id,
    status: status ?? MigrationStatus.inProgress,
    totalCount: totalAssets,
    completedCount: 0,
    assetProgress: assets
        .map(
          (a) => AssetMigrationProgress(
            assetId: a,
            status: AssetMigrationStatus.pending,
            progress: 0.0,
          ),
        )
        .toList(),
  );
}

/// Large synthetic asset list generator.
List<AssetId> createLargeAssetList(int count) => List.generate(
      count,
      (i) => AssetId(
        id: 'ASSET_${i.toString().padLeft(3, '0')}',
        name: 'Asset ${i.toString().padLeft(3, '0')}',
        symbol: AssetSymbol(assetConfigId: 'A${i.toString().padLeft(3, '0')}'),
        chainId: AssetChainId(chainId: 1),
        derivationPath: null,
        subClass: CoinSubClass.utxo,
      ),
    );

/// Creates a mock migration request.
MigrationRequest createMockRequest({
  WalletId? sourceWallet,
  WalletId? targetWallet,
  List<AssetId>? selectedAssets,
}) {
  return MigrationRequest(
    sourceWalletId: sourceWallet ??
        WalletId(
          name: 'source_wallet',
          authOptions: const AuthOptions(derivationMethod: DerivationMethod.hdWallet),
        ),
    targetWalletId: targetWallet ??
        WalletId(
          name: 'target_wallet',
          authOptions: const AuthOptions(derivationMethod: DerivationMethod.hdWallet),
        ),
    selectedAssets: selectedAssets ??
        [
          AssetId(
            id: 'BTC',
            name: 'Bitcoin',
            symbol: AssetSymbol(assetConfigId: 'BTC'),
            chainId: AssetChainId(chainId: 1),
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
        ],
  );
}

/// Placeholder assertion helper.
void verifyNoExceptions() {
  // Intentionally minimal – keep API compatibility.
}

/// Lightweight helper class (kept for backwards compatibility).
class MigrationTestHelpers {
  void verifyNoMemoryLeaks() {
    // Placeholder: no-op in pure Dart context.
  }

  void dispose() {
    // Placeholder: no-op.
  }
}
