import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_sdk/src/migrations/utils/migration_utils.dart';
//
// Note: This test suite intentionally covers only pure Dart migration utility logic.
// Avoid adding any Flutter or widget-specific imports here to keep the SDK tests framework-agnostic.

// Top-level main entry point wrapping all MigrationUtils tests
void main() {
  // Mock objects used throughout tests
  late WalletId mockWalletId1;
  late WalletId mockWalletId2;
  late WalletId mockEmptyWalletId;
  late WalletId mockSameWalletId;
  late AssetId mockAssetId1;
  late AssetId mockAssetId2;
  late AssetId mockAssetId3;

  setUpAll(() {
    mockWalletId1 = WalletId(
      name: 'wallet1',
      authOptions: const AuthOptions(
        derivationMethod: DerivationMethod.hdWallet,
      ),
    );

    mockWalletId2 = WalletId(
      name: 'wallet2',
      authOptions: const AuthOptions(
        derivationMethod: DerivationMethod.hdWallet,
      ),
    );

    mockEmptyWalletId = WalletId(
      name: '',
      authOptions: const AuthOptions(
        derivationMethod: DerivationMethod.hdWallet,
      ),
    );

    mockSameWalletId = WalletId(
      name: 'same_wallet',
      authOptions: const AuthOptions(
        derivationMethod: DerivationMethod.hdWallet,
      ),
    );

    mockAssetId1 = AssetId(
      id: 'BTC',
      name: 'Bitcoin',
      symbol: AssetSymbol(assetConfigId: 'BTC'),
      chainId: AssetChainId(chainId: 1),
      derivationPath: null,
      subClass: CoinSubClass.utxo,
    );

    mockAssetId2 = AssetId(
      id: 'ETH',
      name: 'Ethereum',
      symbol: AssetSymbol(assetConfigId: 'ETH'),
      chainId: AssetChainId(chainId: 1),
      derivationPath: null,
      subClass: CoinSubClass.erc20,
    );

    mockAssetId3 = AssetId(
      id: 'LTC',
      name: 'Litecoin',
      symbol: AssetSymbol(assetConfigId: 'LTC'),
      chainId: AssetChainId(chainId: 1),
      derivationPath: null,
      subClass: CoinSubClass.utxo,
    );
  });

  group('MigrationUtils Tests', () {
    group('ID Generation', () {
      test('should generate unique migration IDs', () {
        // Act
        final id1 = MigrationUtils.generateMigrationId();
        final id2 = MigrationUtils.generateMigrationId();

        // Assert
        expect(id1, isNotEmpty);
        expect(id2, isNotEmpty);
        expect(id1, isNot(equals(id2)));
        expect(id1, startsWith('migration_'));
        expect(id2, startsWith('migration_'));
      });

      test('should generate unique preview IDs', () {
        // Act
        final id1 = MigrationUtils.generatePreviewId();
        final id2 = MigrationUtils.generatePreviewId();

        // Assert
        expect(id1, isNotEmpty);
        expect(id2, isNotEmpty);
        expect(id1, isNot(equals(id2)));
        expect(id1, startsWith('preview_'));
        expect(id2, startsWith('preview_'));
      });

      test('should generate IDs with consistent format', () {
        // Act
        final migrationId = MigrationUtils.generateMigrationId();
        final previewId = MigrationUtils.generatePreviewId();

        // Assert
        final migrationParts = migrationId.split('_');
        final previewParts = previewId.split('_');

        expect(migrationParts, hasLength(3));
        expect(previewParts, hasLength(3));
        expect(migrationParts[0], equals('migration'));
        expect(previewParts[0], equals('preview'));
        expect(int.tryParse(migrationParts[1]), isNotNull); // timestamp
        expect(int.tryParse(previewParts[1]), isNotNull); // timestamp
        expect(int.tryParse(migrationParts[2]), isNotNull); // random
        expect(int.tryParse(previewParts[2]), isNotNull); // random
      });
    });

    group('Asset Migration Validation', () {
      test('should return true for valid migration conditions', () {
        // Arrange
        final balance = Decimal.parse('1.0');
        final fee = Decimal.parse('0.001');

        // Act
        final canMigrate = MigrationUtils.canMigrateAsset(
          balance: balance,
          estimatedFee: fee,
        );

        // Assert
        expect(canMigrate, isTrue);
      });

      test('should return false for zero balance', () {
        // Arrange
        final balance = Decimal.zero;
        final fee = Decimal.parse('0.001');

        // Act
        final canMigrate = MigrationUtils.canMigrateAsset(
          balance: balance,
          estimatedFee: fee,
        );

        // Assert
        expect(canMigrate, isFalse);
      });

      test('should return false when fee exceeds balance', () {
        // Arrange
        final balance = Decimal.parse('0.001');
        final fee = Decimal.parse('0.01');

        // Act
        final canMigrate = MigrationUtils.canMigrateAsset(
          balance: balance,
          estimatedFee: fee,
        );

        // Assert
        expect(canMigrate, isFalse);
      });

      test('should return false when fee equals balance', () {
        // Arrange
        final balance = Decimal.parse('0.001');
        final fee = Decimal.parse('0.001');

        // Act
        final canMigrate = MigrationUtils.canMigrateAsset(
          balance: balance,
          estimatedFee: fee,
        );

        // Assert
        expect(canMigrate, isFalse);
      });

      test('should respect minimum amount requirement', () {
        // Arrange
        final balance = Decimal.parse('1.0');
        final fee = Decimal.parse('0.001');
        final minimumAmount = Decimal.parse('0.5');

        // Act
        final canMigrateWithMinimum = MigrationUtils.canMigrateAsset(
          balance: balance,
          estimatedFee: fee,
          minimumAmount: minimumAmount,
        );

        final canMigrateWithHighMinimum = MigrationUtils.canMigrateAsset(
          balance: balance,
          estimatedFee: fee,
          minimumAmount: Decimal.parse('1.5'),
        );

        // Assert
        expect(canMigrateWithMinimum, isTrue);
        expect(canMigrateWithHighMinimum, isFalse);
      });
    });

    group('Net Amount Calculation', () {
      test('should calculate correct net amount', () {
        // Arrange
        final balance = Decimal.parse('1.0');
        final fee = Decimal.parse('0.001');

        // Act
        final netAmount = MigrationUtils.calculateNetAmount(balance, fee);

        // Assert
        expect(netAmount, equals(Decimal.parse('0.999')));
      });

      test('should return zero for negative net amount', () {
        // Arrange
        final balance = Decimal.parse('0.001');
        final fee = Decimal.parse('0.01');

        // Act
        final netAmount = MigrationUtils.calculateNetAmount(balance, fee);

        // Assert
        expect(netAmount, equals(Decimal.zero));
      });

      test('should handle exact fee equals balance case', () {
        // Arrange
        final balance = Decimal.parse('0.001');
        final fee = Decimal.parse('0.001');

        // Act
        final netAmount = MigrationUtils.calculateNetAmount(balance, fee);

        // Assert
        expect(netAmount, equals(Decimal.zero));
      });
    });

    group('Error Mapping', () {
      test('should map insufficient balance error', () {
        // Arrange
        const error = 'Insufficient balance to complete transaction';

        // Act
        final mappedError = MigrationUtils.mapWithdrawalErrorToMigrationError(error);

        // Assert
        expect(mappedError, equals(MigrationErrorType.insufficientBalance));
      });

      test('should map insufficient fee error', () {
        // Arrange
        const error = 'Insufficient fee for network';

        // Act
        final mappedError = MigrationUtils.mapWithdrawalErrorToMigrationError(error);

        // Assert
        expect(mappedError, equals(MigrationErrorType.insufficientFee));
      });

      test('should map network error', () {
        // Arrange
        const error = 'Network connection failed';

        // Act
        final mappedError = MigrationUtils.mapWithdrawalErrorToMigrationError(error);

        // Assert
        expect(mappedError, equals(MigrationErrorType.networkError));
      });

      test('should map broadcast error', () {
        // Arrange
        const error = 'Failed to broadcast transaction';

        // Act
        final mappedError = MigrationUtils.mapWithdrawalErrorToMigrationError(error);

        // Assert
        expect(mappedError, equals(MigrationErrorType.txBroadcastFailed));
      });

      test('should map wallet locked error', () {
        // Arrange
        const error = 'Wallet is locked';

        // Act
        final mappedError = MigrationUtils.mapWithdrawalErrorToMigrationError(error);

        // Assert
        expect(mappedError, equals(MigrationErrorType.walletLocked));
      });

      test('should map timeout exception', () {
        // Arrange
        final error = TimeoutException('Operation timed out', Duration(seconds: 30));

        // Act
        final mappedError = MigrationUtils.mapWithdrawalErrorToMigrationError(error);

        // Assert
        expect(mappedError, equals(MigrationErrorType.networkError));
      });

      test('should default to tx creation failed for unknown errors', () {
        // Arrange
        const error = 'Unknown error occurred';

        // Act
        final mappedError = MigrationUtils.mapWithdrawalErrorToMigrationError(error);

        // Assert
        expect(mappedError, equals(MigrationErrorType.txCreationFailed));
      });

      test('should handle case insensitive error mapping', () {
        // Arrange
        const error = 'INSUFFICIENT BALANCE FOR TRANSACTION';

        // Act
        final mappedError = MigrationUtils.mapWithdrawalErrorToMigrationError(error);

        // Assert
        expect(mappedError, equals(MigrationErrorType.insufficientBalance));
      });
    });

    group('Migration Request Validation', () {
      test('should validate correct migration request', () {
        // Arrange
        final request = MigrationRequest(
          sourceWalletId: mockWalletId1,
          targetWalletId: mockWalletId2,
          selectedAssets: [mockAssetId1, mockAssetId2],
          activateCoinsOnly: false,
          feePreferences: {},
        );

        // Act
        final errors = MigrationUtils.validateMigrationRequest(request);

        // Assert
        expect(errors, isEmpty);
      });

      test('should reject empty source wallet ID', () {
        // Arrange
        final request = MigrationRequest(
          sourceWalletId: mockEmptyWalletId,
          targetWalletId: mockWalletId2,
          selectedAssets: [mockAssetId1],
          activateCoinsOnly: false,
          feePreferences: {},
        );

        // Act
        final errors = MigrationUtils.validateMigrationRequest(request);

        // Assert
        expect(errors, contains('Source wallet ID cannot be empty'));
      });

      test('should reject empty target wallet ID', () {
        // Arrange
        final request = MigrationRequest(
          sourceWalletId: mockWalletId1,
          targetWalletId: mockEmptyWalletId,
          selectedAssets: [mockAssetId1],
          activateCoinsOnly: false,
          feePreferences: {},
        );

        // Act
        final errors = MigrationUtils.validateMigrationRequest(request);

        // Assert
        expect(errors, contains('Target wallet ID cannot be empty'));
      });

      test('should reject same source and target wallets', () {
        // Arrange
        final request = MigrationRequest(
          sourceWalletId: mockSameWalletId,
          targetWalletId: mockSameWalletId,
          selectedAssets: [mockAssetId1],
          activateCoinsOnly: false,
          feePreferences: {},
        );

        // Act
        final errors = MigrationUtils.validateMigrationRequest(request);

        // Assert
        expect(errors, contains('Source and target wallets must be different'));
      });

      test('should reject empty asset selection', () {
        // Arrange
        final request = MigrationRequest(
          sourceWalletId: mockWalletId1,
          targetWalletId: mockWalletId2,
          selectedAssets: [],
          activateCoinsOnly: false,
          feePreferences: {},
        );

        // Act
        final errors = MigrationUtils.validateMigrationRequest(request);

        // Assert
        expect(errors, contains('At least one asset must be selected for migration'));
      });

      test('should reject duplicate assets', () {
        // Arrange
        final request = MigrationRequest(
          sourceWalletId: mockWalletId1,
          targetWalletId: mockWalletId2,
          selectedAssets: [mockAssetId1, mockAssetId1],
          activateCoinsOnly: false,
          feePreferences: {},
        );

        // Act
        final errors = MigrationUtils.validateMigrationRequest(request);

        // Assert
        expect(errors, contains('Duplicate assets found in selection'));
      });

      test('should return multiple errors for invalid request', () {
        // Arrange
        final request = MigrationRequest(
          sourceWalletId: mockEmptyWalletId,
          targetWalletId: mockEmptyWalletId,
          selectedAssets: [],
          activateCoinsOnly: false,
          feePreferences: {},
        );

        // Act
        final errors = MigrationUtils.validateMigrationRequest(request);

        // Assert
        expect(errors, hasLength(greaterThan(1)));
        expect(errors, contains('Source wallet ID cannot be empty'));
        expect(errors, contains('Target wallet ID cannot be empty'));
        expect(errors, contains('At least one asset must be selected for migration'));
      });
    });

    group('Fee and Amount Calculations', () {
      test('should calculate total fees correctly', () {
        // Arrange
        final assetPreviews = [
          AssetMigrationPreview(
            assetId: mockAssetId1,
            sourceAddress: 'btc_source',
            targetAddress: 'btc_target',
            balance: Decimal.parse('1.0'),
            estimatedFee: Decimal.parse('0.001'),
            netAmount: Decimal.parse('0.999'),
            status: MigrationAssetStatus.ready,
          ),
          AssetMigrationPreview(
            assetId: mockAssetId2,
            sourceAddress: 'eth_source',
            targetAddress: 'eth_target',
            balance: Decimal.parse('10.0'),
            estimatedFee: Decimal.parse('0.005'),
            netAmount: Decimal.parse('9.995'),
            status: MigrationAssetStatus.ready,
          ),
        ];

        // Act
        final totalFees = MigrationUtils.calculateTotalFees(assetPreviews);

        // Assert
        expect(totalFees, equals(Decimal.parse('0.006')));
      });

      test('should calculate total net amount correctly', () {
        // Arrange
        final assetPreviews = [
          AssetMigrationPreview(
            assetId: mockAssetId1,
            sourceAddress: 'btc_source',
            targetAddress: 'btc_target',
            balance: Decimal.parse('1.0'),
            estimatedFee: Decimal.parse('0.001'),
            netAmount: Decimal.parse('0.999'),
            status: MigrationAssetStatus.ready,
          ),
          AssetMigrationPreview(
            assetId: mockAssetId2,
            sourceAddress: 'eth_source',
            targetAddress: 'eth_target',
            balance: Decimal.parse('10.0'),
            estimatedFee: Decimal.parse('0.005'),
            netAmount: Decimal.parse('9.995'),
            status: MigrationAssetStatus.ready,
          ),
        ];

        // Act
        final totalNetAmount = MigrationUtils.calculateTotalNetAmount(assetPreviews);

        // Assert
        expect(totalNetAmount, equals(Decimal.parse('10.994')));
      });

      test('should filter migratable assets correctly', () {
        // Arrange
        final assetPreviews = [
          AssetMigrationPreview(
            assetId: mockAssetId1,
            sourceAddress: 'btc_source',
            targetAddress: 'btc_target',
            balance: Decimal.parse('1.0'),
            estimatedFee: Decimal.parse('0.001'),
            netAmount: Decimal.parse('0.999'),
            status: MigrationAssetStatus.ready,
          ),
          AssetMigrationPreview(
            assetId: mockAssetId2,
            sourceAddress: 'eth_source',
            targetAddress: 'eth_target',
            balance: Decimal.zero,
            estimatedFee: Decimal.parse('0.005'),
            netAmount: Decimal.zero,
            status: MigrationAssetStatus.insufficientBalance,
          ),
          AssetMigrationPreview(
            assetId: mockAssetId3,
            sourceAddress: 'ltc_source',
            targetAddress: 'ltc_target',
            balance: Decimal.parse('0.5'),
            estimatedFee: Decimal.parse('0.001'),
            netAmount: Decimal.parse('0.499'),
            status: MigrationAssetStatus.ready,
          ),
        ];

        // Act
        final migratableAssets = MigrationUtils.filterMigratableAssets(assetPreviews);

        // Assert
        expect(migratableAssets, hasLength(2));
        expect(migratableAssets.map((a) => a.assetId), containsAll([mockAssetId1, mockAssetId3]));
      });
    });

    group('Migration Duration Estimation', () {
      test('should estimate reasonable duration for small asset count', () {
        // Act
        final duration = MigrationUtils.estimateMigrationDuration(5);

        // Assert
        expect(duration.inMinutes, greaterThan(0));
        expect(duration.inHours, lessThan(24));
      });

      test('should scale duration with asset count', () {
        // Act
        final smallDuration = MigrationUtils.estimateMigrationDuration(5);
        final largeDuration = MigrationUtils.estimateMigrationDuration(20);

        // Assert
        expect(largeDuration, greaterThan(smallDuration));
      });

      test('should use custom confirmation time when provided', () {
        // Arrange
        const customConfirmationTime = Duration(minutes: 5);

        // Act
        final duration = MigrationUtils.estimateMigrationDuration(
          10,
          averageConfirmationTime: customConfirmationTime,
        );

        // Assert
        expect(duration.inMinutes, greaterThan(customConfirmationTime.inMinutes));
      });
    });

    group('Address Validation', () {
      test('should accept valid length addresses', () {
        // Arrange
        const validAddress = 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';

        // Act
        final isValid = MigrationUtils.validateAddress(validAddress);

        // Assert
        expect(isValid, isTrue);
      });

      test('should reject empty addresses', () {
        // Act
        final isValid = MigrationUtils.validateAddress('');

        // Assert
        expect(isValid, isFalse);
      });

      test('should reject too short addresses', () {
        // Arrange
        const tooShort = 'abc123';

        // Act
        final isValid = MigrationUtils.validateAddress(tooShort);

        // Assert
        expect(isValid, isFalse);
      });

      test('should reject too long addresses', () {
        // Arrange
        final tooLong = 'a' * 100;

        // Act
        final isValid = MigrationUtils.validateAddress(tooLong);

        // Assert
        expect(isValid, isFalse);
      });

      test('should validate expected prefix when provided', () {
        // Arrange
        const addressWithPrefix = 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';
        const addressWithoutPrefix = '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2';

        // Act
        final validWithPrefix = MigrationUtils.validateAddress(addressWithPrefix, expectedPrefix: 'bc1');
        final invalidWithPrefix = MigrationUtils.validateAddress(addressWithoutPrefix, expectedPrefix: 'bc1');

        // Assert
        expect(validWithPrefix, isTrue);
        expect(invalidWithPrefix, isFalse);
      });

      test('should reject addresses with invalid characters', () {
        // Arrange
        const invalidAddress = 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh!';

        // Act
        final isValid = MigrationUtils.validateAddress(invalidAddress);

        // Assert
        expect(isValid, isFalse);
      });
    });

    group('Error Message Creation', () {
      test('should create activation failed message', () {
        // Act
        final message = MigrationUtils.createErrorMessage(
          MigrationErrorType.activationFailed,
          assetId: 'BTC',
        );

        // Assert
        expect(message, contains('Failed to activate asset for BTC'));
        expect(message, contains('Please ensure the asset is supported'));
      });

      test('should create insufficient balance message', () {
        // Act
        final message = MigrationUtils.createErrorMessage(
          MigrationErrorType.insufficientBalance,
          assetId: 'ETH',
        );

        // Assert
        expect(message, contains('Insufficient balance for ETH'));
        expect(message, contains('not enough to cover the transaction fees'));
      });

      test('should create network error message', () {
        // Act
        final message = MigrationUtils.createErrorMessage(
          MigrationErrorType.networkError,
          additionalContext: 'Connection timeout',
        );

        // Assert
        expect(message, contains('Network error'));
        expect(message, contains('Connection timeout'));
        expect(message, contains('check your internet connection'));
      });

      test('should create message without asset ID', () {
        // Act
        final message = MigrationUtils.createErrorMessage(
          MigrationErrorType.walletLocked,
        );

        // Assert
        expect(message, contains('Wallet is locked'));
        expect(message, contains('unlock your wallet'));
        expect(message, isNot(contains(' for ')));
      });

      test('should include additional context when provided', () {
        // Act
        final message = MigrationUtils.createErrorMessage(
          MigrationErrorType.txCreationFailed,
          assetId: 'BTC',
          additionalContext: 'Invalid output script',
        );

        // Assert
        expect(message, contains('Failed to create transaction for BTC'));
        expect(message, contains('(Invalid output script)'));
      });
    });
  });
}
