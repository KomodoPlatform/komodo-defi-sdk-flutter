import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

import '../../../lib/migrations/bloc/migration_bloc.dart';
import '../../../lib/migrations/bloc/migration_event.dart';
import '../../../lib/migrations/bloc/migration_state.dart';

class MockMigrationManager extends Mock implements MigrationManager {}
class MockAssetProvider extends Mock implements IAssetProvider {}
class MockBalanceManager extends Mock implements IBalanceManager {}
class MockActivationManager extends Mock implements ActivationManager {}

// Fake classes for complex objects used in when() calls
class FakeMigrationRequest extends Fake implements MigrationRequest {}
class FakeAssetId extends Fake implements AssetId {}

void main() {
  group('MigrationBloc', () {
    late MockMigrationManager mockMigrationManager;
    late MockAssetProvider mockAssetProvider;
    late MockBalanceManager mockBalanceManager;
    late MockActivationManager mockActivationManager;
    late MigrationBloc migrationBloc;

    setUpAll(() {
      registerFallbackValue(FakeMigrationRequest());
      registerFallbackValue(FakeAssetId());
    });

    setUp(() {
      mockMigrationManager = MockMigrationManager();
      mockAssetProvider = MockAssetProvider();
      mockBalanceManager = MockBalanceManager();
      mockActivationManager = MockActivationManager();

      migrationBloc = MigrationBloc(
        migrationManager: mockMigrationManager,
        assetProvider: mockAssetProvider,
        balanceManager: mockBalanceManager,
        activationManager: mockActivationManager,
      );
    });

    tearDown(() {
      migrationBloc.close();
    });

    test('initial state is MigrationInitial', () {
      expect(migrationBloc.state, equals(const MigrationInitial()));
    });

    group('InitializeMigration', () {
      blocTest<MigrationBloc, MigrationState>(
        'emits [loading, wallet selection] when initialization succeeds',
        build: () => migrationBloc,
        act: (bloc) => bloc.add(const InitializeMigration()),
        expect: () => [
          isA<MigrationLoading>()
              .having((state) => state.message, 'message', 'Loading available wallets...'),
          isA<MigrationWalletSelection>()
              .having((state) => state.availableWallets.length, 'wallet count', 2),
        ],
        verify: (_) {
          // Verify that wallets were loaded
        },
      );
    });

    group('SetSourceWallet', () {
      const sourceWallet = WalletId(id: 'source_wallet');
      const walletSelectionState = MigrationWalletSelection(
        availableWallets: [
          WalletInfo(
            walletId: WalletId(id: 'wallet1'),
            walletName: 'Wallet 1',
            walletType: 'HD',
            isSupported: true,
          ),
        ],
      );

      blocTest<MigrationBloc, MigrationState>(
        'updates source wallet in wallet selection state',
        build: () => migrationBloc,
        seed: () => walletSelectionState,
        act: (bloc) => bloc.add(const SetSourceWallet(
          walletId: sourceWallet,
          walletName: 'Source Wallet',
          walletType: 'Iguana',
        )),
        expect: () => [
          isA<MigrationWalletSelection>()
              .having((state) => state.sourceWallet?.walletId, 'sourceWalletId', sourceWallet)
              .having((state) => state.sourceWallet?.walletName, 'sourceWalletName', 'Source Wallet')
              .having((state) => state.sourceWallet?.walletType, 'sourceWalletType', 'Iguana'),
        ],
      );

      blocTest<MigrationBloc, MigrationState>(
        'does nothing when not in wallet selection state',
        build: () => migrationBloc,
        seed: () => const MigrationInitial(),
        act: (bloc) => bloc.add(const SetSourceWallet(
          walletId: sourceWallet,
          walletName: 'Source Wallet',
          walletType: 'Iguana',
        )),
        expect: () => const <MigrationState>[],
      );
    });

    group('SetTargetWallet', () {
      const targetWallet = WalletId(id: 'target_wallet');
      const walletSelectionState = MigrationWalletSelection(
        availableWallets: [
          WalletInfo(
            walletId: WalletId(id: 'wallet1'),
            walletName: 'Wallet 1',
            walletType: 'HD',
            isSupported: true,
          ),
        ],
      );

      blocTest<MigrationBloc, MigrationState>(
        'updates target wallet in wallet selection state',
        build: () => migrationBloc,
        seed: () => walletSelectionState,
        act: (bloc) => bloc.add(const SetTargetWallet(
          walletId: targetWallet,
          walletName: 'Target Wallet',
          walletType: 'HD',
        )),
        expect: () => [
          isA<MigrationWalletSelection>()
              .having((state) => state.targetWallet?.walletId, 'targetWalletId', targetWallet)
              .having((state) => state.targetWallet?.walletName, 'targetWalletName', 'Target Wallet')
              .having((state) => state.targetWallet?.walletType, 'targetWalletType', 'HD'),
        ],
      );
    });

    group('LoadAvailableAssets', () {
      final mockAssets = [
        _createMockAsset('KMD', 'Komodo'),
        _createMockAsset('BTC', 'Bitcoin'),
        _createMockAsset('LTC', 'Litecoin'),
      ];

      const walletSelectionState = MigrationWalletSelection(
        availableWallets: [],
        sourceWallet: WalletInfo(
          walletId: WalletId(id: 'source'),
          walletName: 'Source',
          walletType: 'Iguana',
          isSupported: true,
        ),
        targetWallet: WalletInfo(
          walletId: WalletId(id: 'target'),
          walletName: 'Target',
          walletType: 'HD',
          isSupported: true,
        ),
      );

      blocTest<MigrationBloc, MigrationState>(
        'emits [loading, asset selection] when assets load successfully',
        build: () {
          when(() => mockAssetProvider.getAllAssets())
              .thenAnswer((_) async => mockAssets);

          when(() => mockBalanceManager.getBalance(any()))
              .thenAnswer((_) async => Decimal.parse('10.5'));

          when(() => mockActivationManager.isActivated(any()))
              .thenAnswer((_) async => true);

          return migrationBloc;
        },
        seed: () => walletSelectionState,
        act: (bloc) => bloc.add(const LoadAvailableAssets()),
        expect: () => [
          isA<MigrationLoading>()
              .having((state) => state.message, 'message', 'Loading available assets...'),
          isA<MigrationAssetSelection>()
              .having((state) => state.availableAssets.length, 'asset count', 3)
              .having((state) => state.selectedAssets.isEmpty, 'selected assets', true)
              .having((state) => state.sourceWallet.walletName, 'source wallet', 'Source')
              .having((state) => state.targetWallet.walletName, 'target wallet', 'Target'),
        ],
        verify: (_) {
          verify(() => mockAssetProvider.getAllAssets()).called(1);
          verify(() => mockBalanceManager.getBalance(any())).called(3);
          verify(() => mockActivationManager.isActivated(any())).called(3);
        },
      );

      blocTest<MigrationBloc, MigrationState>(
        'emits [loading, error] when assets loading fails',
        build: () {
          when(() => mockAssetProvider.getAllAssets())
              .thenThrow(Exception('Network error'));
          return migrationBloc;
        },
        seed: () => walletSelectionState,
        act: (bloc) => bloc.add(const LoadAvailableAssets()),
        expect: () => [
          isA<MigrationLoading>(),
          isA<MigrationError>()
              .having((state) => state.canRetry, 'can retry', true),
        ],
        verify: (_) {
          verify(() => mockAssetProvider.getAllAssets()).called(1);
        },
      );

      blocTest<MigrationBloc, MigrationState>(
        'does nothing when wallets are not selected',
        build: () => migrationBloc,
        seed: () => const MigrationWalletSelection(availableWallets: []),
        act: (bloc) => bloc.add(const LoadAvailableAssets()),
        expect: () => const <MigrationState>[],
      );
    });

    group('ToggleAssetFilter', () {
      final assetSelectionState = MigrationAssetSelection(
        sourceWallet: const WalletInfo(
          walletId: WalletId(id: 'source'),
          walletName: 'Source',
          walletType: 'Iguana',
          isSupported: true,
        ),
        targetWallet: const WalletInfo(
          walletId: WalletId(id: 'target'),
          walletName: 'Target',
          walletType: 'HD',
          isSupported: true,
        ),
        availableAssets: [
          AssetInfo(
            assetId: const AssetId(id: 'KMD'),
            name: 'Komodo',
            symbol: 'KMD',
            balance: Decimal.parse('10.5'),
            isActivated: true,
          ),
        ],
        selectedAssets: const <AssetId>{},
      );

      blocTest<MigrationBloc, MigrationState>(
        'toggles showActivatedOnly filter',
        build: () => migrationBloc,
        seed: () => assetSelectionState,
        act: (bloc) => bloc.add(const ToggleAssetFilter(showActivatedOnly: true)),
        expect: () => [
          isA<MigrationAssetSelection>()
              .having((state) => state.showActivatedOnly, 'showActivatedOnly', true),
        ],
      );
    });

    group('ToggleAssetSelection', () {
      const assetId = AssetId(id: 'KMD');
      final assetSelectionState = MigrationAssetSelection(
        sourceWallet: const WalletInfo(
          walletId: WalletId(id: 'source'),
          walletName: 'Source',
          walletType: 'Iguana',
          isSupported: true,
        ),
        targetWallet: const WalletInfo(
          walletId: WalletId(id: 'target'),
          walletName: 'Target',
          walletType: 'HD',
          isSupported: true,
        ),
        availableAssets: [
          AssetInfo(
            assetId: assetId,
            name: 'Komodo',
            symbol: 'KMD',
            balance: Decimal.parse('10.5'),
            isActivated: true,
          ),
        ],
        selectedAssets: const <AssetId>{},
      );

      blocTest<MigrationBloc, MigrationState>(
        'adds asset to selection when selected is true',
        build: () => migrationBloc,
        seed: () => assetSelectionState,
        act: (bloc) => bloc.add(const ToggleAssetSelection(
          assetId: assetId,
          selected: true,
        )),
        expect: () => [
          isA<MigrationAssetSelection>()
              .having((state) => state.selectedAssets.contains(assetId), 'contains KMD', true),
        ],
      );

      blocTest<MigrationBloc, MigrationState>(
        'removes asset from selection when selected is false',
        build: () => migrationBloc,
        seed: () => assetSelectionState.copyWith(
          selectedAssets: {assetId},
        ),
        act: (bloc) => bloc.add(const ToggleAssetSelection(
          assetId: assetId,
          selected: false,
        )),
        expect: () => [
          isA<MigrationAssetSelection>()
              .having((state) => state.selectedAssets.contains(assetId), 'contains KMD', false),
        ],
      );
    });

    group('SelectAllAssets', () {
      const assetId1 = AssetId(id: 'KMD');
      const assetId2 = AssetId(id: 'BTC');
      final assetSelectionState = MigrationAssetSelection(
        sourceWallet: const WalletInfo(
          walletId: WalletId(id: 'source'),
          walletName: 'Source',
          walletType: 'Iguana',
          isSupported: true,
        ),
        targetWallet: const WalletInfo(
          walletId: WalletId(id: 'target'),
          walletName: 'Target',
          walletType: 'HD',
          isSupported: true,
        ),
        availableAssets: [
          AssetInfo(
            assetId: assetId1,
            name: 'Komodo',
            symbol: 'KMD',
            balance: Decimal.parse('10.5'),
            isActivated: true,
          ),
          AssetInfo(
            assetId: assetId2,
            name: 'Bitcoin',
            symbol: 'BTC',
            balance: Decimal.parse('0.5'),
            isActivated: true,
          ),
        ],
        selectedAssets: const <AssetId>{},
      );

      blocTest<MigrationBloc, MigrationState>(
        'selects all visible assets',
        build: () => migrationBloc,
        seed: () => assetSelectionState,
        act: (bloc) => bloc.add(const SelectAllAssets()),
        expect: () => [
          isA<MigrationAssetSelection>()
              .having((state) => state.selectedAssets.length, 'selected count', 2)
              .having((state) => state.selectedAssets.contains(assetId1), 'contains KMD', true)
              .having((state) => state.selectedAssets.contains(assetId2), 'contains BTC', true),
        ],
      );
    });

    group('DeselectAllAssets', () {
      const assetId1 = AssetId(id: 'KMD');
      const assetId2 = AssetId(id: 'BTC');
      final assetSelectionState = MigrationAssetSelection(
        sourceWallet: const WalletInfo(
          walletId: WalletId(id: 'source'),
          walletName: 'Source',
          walletType: 'Iguana',
          isSupported: true,
        ),
        targetWallet: const WalletInfo(
          walletId: WalletId(id: 'target'),
          walletName: 'Target',
          walletType: 'HD',
          isSupported: true,
        ),
        availableAssets: [
          AssetInfo(
            assetId: assetId1,
            name: 'Komodo',
            symbol: 'KMD',
            balance: Decimal.parse('10.5'),
            isActivated: true,
          ),
          AssetInfo(
            assetId: assetId2,
            name: 'Bitcoin',
            symbol: 'BTC',
            balance: Decimal.parse('0.5'),
            isActivated: true,
          ),
        ],
        selectedAssets: {assetId1, assetId2},
      );

      blocTest<MigrationBloc, MigrationState>(
        'deselects all assets',
        build: () => migrationBloc,
        seed: () => assetSelectionState,
        act: (bloc) => bloc.add(const DeselectAllAssets()),
        expect: () => [
          isA<MigrationAssetSelection>()
              .having((state) => state.selectedAssets.isEmpty, 'is empty', true),
        ],
      );
    });

    group('GenerateMigrationPreview', () {
      const assetId = AssetId(id: 'KMD');
      final assetSelectionState = MigrationAssetSelection(
        sourceWallet: const WalletInfo(
          walletId: WalletId(id: 'source'),
          walletName: 'Source',
          walletType: 'Iguana',
          isSupported: true,
        ),
        targetWallet: const WalletInfo(
          walletId: WalletId(id: 'target'),
          walletName: 'Target',
          walletType: 'HD',
          isSupported: true,
        ),
        availableAssets: [
          AssetInfo(
            assetId: assetId,
            name: 'Komodo',
            symbol: 'KMD',
            balance: Decimal.parse('10.5'),
            isActivated: true,
          ),
        ],
        selectedAssets: {assetId},
      );

      final mockPreview = MigrationOperationPreview(
        previewId: 'preview-123',
        sourceWallet: const WalletId(id: 'source'),
        targetWallet: const WalletId(id: 'target'),
        assetPreviews: [
          AssetMigrationPreview(
            assetId: assetId,
            status: MigrationAssetStatus.ready,
            balance: Decimal.parse('10.5'),
            estimatedFee: Decimal.parse('0.001'),
            netAmount: Decimal.parse('10.499'),
            sourceAddress: 'source-address',
            targetAddress: 'target-address',
          ),
        ],
        summary: MigrationSummary(
          totalAssets: 1,
          readyAssets: 1,
          skippedAssets: 0,
          totalBalance: Decimal.parse('10.5'),
          totalFees: Decimal.parse('0.001'),
          netAmount: Decimal.parse('10.499'),
        ),
        createdAt: DateTime.now(),
      );

      blocTest<MigrationBloc, MigrationState>(
        'emits [loading, preview ready] when preview generation succeeds',
        build: () {
          when(() => mockMigrationManager.previewMigration(any()))
              .thenAnswer((_) async => mockPreview);
          return migrationBloc;
        },
        seed: () => assetSelectionState,
        act: (bloc) => bloc.add(const GenerateMigrationPreview()),
        expect: () => [
          isA<MigrationLoading>()
              .having((state) => state.message, 'message', 'Generating migration preview...'),
          isA<MigrationPreviewReady>()
              .having((state) => state.preview.previewId, 'previewId', 'preview-123')
              .having((state) => state.canStartMigration, 'canStartMigration', true),
        ],
        verify: (_) {
          verify(() => mockMigrationManager.previewMigration(any())).called(1);
        },
      );

      blocTest<MigrationBloc, MigrationState>(
        'emits [loading, error] when preview generation fails',
        build: () {
          when(() => mockMigrationManager.previewMigration(any()))
              .thenThrow(Exception('Preview failed'));
          return migrationBloc;
        },
        seed: () => assetSelectionState,
        act: (bloc) => bloc.add(const GenerateMigrationPreview()),
        expect: () => [
          isA<MigrationLoading>(),
          isA<MigrationError>()
              .having((state) => state.canRetry, 'can retry', true),
        ],
        verify: (_) {
          verify(() => mockMigrationManager.previewMigration(any())).called(1);
        },
      );
    });

    group('ResetMigration', () {
      blocTest<MigrationBloc, MigrationState>(
        'resets to initial state from any state',
        build: () => migrationBloc,
        seed: () => const MigrationLoading(message: 'Loading...'),
        act: (bloc) => bloc.add(const ResetMigration()),
        expect: () => [
          const MigrationInitial(),
        ],
      );
    });
  });
}

/// Helper function to create mock assets for testing
Asset _createMockAsset(String symbol, String name) {
  return Asset(
    id: AssetId(
      id: symbol,
      name: name,
      symbol: AssetSymbol(assetConfigId: symbol),
      chainId: const AssetChainId(chainId: 0),
      derivationPath: null,
      subClass: CoinSubClass.utxo,
    ),
    protocol: UtxoProtocol.fromJson({
      'type': 'UTXO',
      'coin': symbol,
      'is_testnet': false,
      'pubtype': 60,
      'p2shtype': 85,
      'wiftype': 188,
      'mm2': 1,
    }),
    isWalletOnly: false,
    signMessagePrefix: null,
  );
}
