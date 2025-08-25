import 'dart:async';
import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_sdk/src/withdrawals/withdrawal_manager.dart';

/// Utility functions for migration operations.
///
/// This class provides helper methods for common migration tasks including
/// ID generation, validation, error mapping, and financial calculations.
class MigrationUtils {
  /// Private constructor to prevent instantiation.
  MigrationUtils._();

  /// Generates a unique migration ID.
  ///
  /// Creates a migration ID using timestamp and random components for uniqueness.
  /// Format: "migration_[timestamp]_[random]"
  static String generateMigrationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(99999).toString().padLeft(5, '0');
    return 'migration_${timestamp}_$random';
  }

  /// Generates a unique preview ID.
  ///
  /// Creates a preview ID using timestamp and random components for uniqueness.
  /// Format: "preview_[timestamp]_[random]"
  static String generatePreviewId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(99999).toString().padLeft(5, '0');
    return 'preview_${timestamp}_$random';
  }

  /// Checks if an asset can be migrated.
  ///
  /// An asset can be migrated if:
  /// - It has a positive balance
  /// - The estimated fee is less than the balance
  /// - The net amount after fees would be positive
  static bool canMigrateAsset({
    required Decimal balance,
    required Decimal estimatedFee,
    Decimal? minimumAmount,
  }) {
    if (balance <= Decimal.zero) return false;
    if (estimatedFee >= balance) return false;

    final netAmount = balance - estimatedFee;
    if (netAmount <= Decimal.zero) return false;

    if (minimumAmount != null && netAmount < minimumAmount) return false;

    return true;
  }

  /// Calculates the net amount after deducting fees.
  ///
  /// Returns the amount that will actually be transferred to the target address
  /// after transaction fees are deducted from the balance.
  static Decimal calculateNetAmount(Decimal balance, Decimal fee) {
    final netAmount = balance - fee;
    return netAmount > Decimal.zero ? netAmount : Decimal.zero;
  }

  /// Maps withdrawal errors to migration-specific error types.
  ///
  /// Converts generic withdrawal errors into migration error types
  /// that are more meaningful in the context of migrations.
  static MigrationErrorType mapWithdrawalErrorToMigrationError(Object error) {
    // Handle string error messages
    if (error is String) {
      final errorLower = error.toLowerCase();

      if (errorLower.contains('insufficient') && errorLower.contains('balance')) {
        return MigrationErrorType.insufficientBalance;
      }
      if (errorLower.contains('insufficient') && errorLower.contains('fee')) {
        return MigrationErrorType.insufficientFee;
      }
      if (errorLower.contains('network') || errorLower.contains('connection')) {
        return MigrationErrorType.networkError;
      }
      if (errorLower.contains('timeout')) {
        return MigrationErrorType.networkError;
      }
      if (errorLower.contains('broadcast')) {
        return MigrationErrorType.txBroadcastFailed;
      }
      if (errorLower.contains('locked') || errorLower.contains('auth')) {
        return MigrationErrorType.walletLocked;
      }

      return MigrationErrorType.txCreationFailed;
    }

    // Handle specific exception types
    if (error is TimeoutException) {
      return MigrationErrorType.networkError;
    }

    // Handle withdrawal-specific errors (if we have access to them)
    // This would need to be expanded based on actual withdrawal error types
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('insufficient balance')) {
      return MigrationErrorType.insufficientBalance;
    }
    if (errorString.contains('insufficient fee') || errorString.contains('insufficient gas')) {
      return MigrationErrorType.insufficientFee;
    }
    if (errorString.contains('network') || errorString.contains('connection')) {
      return MigrationErrorType.networkError;
    }
    if (errorString.contains('broadcast')) {
      return MigrationErrorType.txBroadcastFailed;
    }
    if (errorString.contains('activation')) {
      return MigrationErrorType.activationFailed;
    }

    // Default to transaction creation failure for unknown errors
    return MigrationErrorType.txCreationFailed;
  }

  /// Validates a migration request for basic requirements.
  ///
  /// Checks that the migration request has valid source/target wallets,
  /// selected assets, and other required fields.
  ///
  /// Returns a list of validation errors, or an empty list if valid.
  static List<String> validateMigrationRequest(MigrationRequest request) {
    final errors = <String>[];

    // Check source wallet
    if (request.sourceWalletId.name.isEmpty) {
      errors.add('Source wallet ID cannot be empty');
    }

    // Check target wallet
    if (request.targetWalletId.name.isEmpty) {
      errors.add('Target wallet ID cannot be empty');
    }

    // Check that source and target are different
    if (request.sourceWalletId == request.targetWalletId) {
      errors.add('Source and target wallets must be different');
    }

    // Check selected assets
    if (request.selectedAssets.isEmpty) {
      errors.add('At least one asset must be selected for migration');
    }

    // Check for duplicate assets
    final assetIds = request.selectedAssets.map((a) => a.id).toList();
    final uniqueAssetIds = assetIds.toSet();
    if (assetIds.length != uniqueAssetIds.length) {
      errors.add('Duplicate assets found in selection');
    }

    return errors;
  }

  /// Calculates the total estimated fees for a list of asset previews.
  ///
  /// Sums up all the individual asset fees to provide a total fee estimate
  /// for the entire migration operation.
  static Decimal calculateTotalFees(List<AssetMigrationPreview> assetPreviews) {
    return assetPreviews.fold(
      Decimal.zero,
      (total, preview) => total + preview.estimatedFee,
    );
  }

  /// Calculates the total net amount for a list of asset previews.
  ///
  /// Sums up all the individual asset net amounts to provide the total
  /// amount that will be transferred after fees.
  static Decimal calculateTotalNetAmount(List<AssetMigrationPreview> assetPreviews) {
    return assetPreviews.fold(
      Decimal.zero,
      (total, preview) => total + preview.netAmount,
    );
  }

  /// Filters asset previews to only include those that can be migrated.
  ///
  /// Returns only asset previews that have sufficient balance for fees
  /// and meet other migration requirements.
  static List<AssetMigrationPreview> filterMigratableAssets(
    List<AssetMigrationPreview> assetPreviews,
  ) {
    return assetPreviews
        .where((preview) => preview.status == MigrationAssetStatus.ready)
        .where((preview) => canMigrateAsset(
              balance: preview.balance,
              estimatedFee: preview.estimatedFee,
            ))
        .toList();
  }

  /// Creates a summary of migration costs and outcomes.
  ///
  /// Analyzes the asset previews to provide a comprehensive summary
  /// of what the migration will accomplish and cost.
  static MigrationSummary createMigrationSummary(
    List<AssetMigrationPreview> assetPreviews,
  ) {
    final migratableAssets = filterMigratableAssets(assetPreviews);
    final totalAssets = assetPreviews.length;
    final migratableCount = migratableAssets.length;
    final totalFees = calculateTotalFees(migratableAssets);
    final totalNetAmount = calculateTotalNetAmount(migratableAssets);

    // Count assets by status
    final statusCounts = <MigrationAssetStatus, int>{};
    for (final preview in assetPreviews) {
      statusCounts[preview.status] = (statusCounts[preview.status] ?? 0) + 1;
    }

    return MigrationSummary(
      totalAssets: totalAssets,
      readyAssets: migratableCount,
      failedAssets: totalAssets - migratableCount,
      totalEstimatedFees: totalFees,
    );
  }

  /// Estimates the total time for migration based on asset count and network conditions.
  ///
  /// Provides a rough estimate of how long the migration might take based on
  /// the number of assets and typical blockchain confirmation times.
  static Duration estimateMigrationDuration(int assetCount, {
    Duration? averageConfirmationTime,
  }) {
    // Use default confirmation time if not provided (2 minutes per asset average)
    final confirmationTime = averageConfirmationTime ?? const Duration(minutes: 2);

    // Account for batch processing - not all assets process simultaneously
    final batchProcessingTime = Duration(
      milliseconds: (assetCount * confirmationTime.inMilliseconds * 0.7).round(),
    );

    // Add base overhead for activation and setup
    const baseOverhead = Duration(minutes: 1);

    return baseOverhead + batchProcessingTime;
  }

  /// Validates that asset addresses are properly formatted.
  ///
  /// Performs basic validation on source and target addresses to ensure
  /// they appear to be valid cryptocurrency addresses.
  static bool validateAddress(String address, {String? expectedPrefix}) {
    if (address.isEmpty) return false;

    // Basic length check (most crypto addresses are between 25-62 characters)
    if (address.length < 25 || address.length > 62) return false;

    // Check for expected prefix if provided
    if (expectedPrefix != null && !address.startsWith(expectedPrefix)) {
      return false;
    }

    // Basic character set validation (alphanumeric, no spaces)
    final addressRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!addressRegex.hasMatch(address)) return false;

    return true;
  }

  /// Creates a standardized error message for migration failures.
  ///
  /// Generates user-friendly error messages based on the error type
  /// and provides guidance on possible resolutions.
  static String createErrorMessage(MigrationErrorType errorType, {
    String? assetId,
    String? additionalContext,
  }) {
    final assetText = assetId != null ? ' for $assetId' : '';
    final contextText = additionalContext != null ? ' ($additionalContext)' : '';

    switch (errorType) {
      case MigrationErrorType.activationFailed:
        return 'Failed to activate asset$assetText. Please ensure the asset is supported and try again$contextText.';

      case MigrationErrorType.insufficientBalance:
        return 'Insufficient balance$assetText. The available balance is not enough to cover the transaction fees$contextText.';

      case MigrationErrorType.insufficientFee:
        return 'Insufficient fee$assetText. The network fee is higher than expected$contextText.';

      case MigrationErrorType.txCreationFailed:
        return 'Failed to create transaction$assetText. Please check your wallet status and try again$contextText.';

      case MigrationErrorType.txBroadcastFailed:
        return 'Failed to broadcast transaction$assetText. Please check your network connection and try again$contextText.';

      case MigrationErrorType.walletLocked:
        return 'Wallet is locked$assetText. Please unlock your wallet and try again$contextText.';

      case MigrationErrorType.invalidWallet:
        return 'Invalid wallet configuration$assetText. Please check your wallet settings$contextText.';

      case MigrationErrorType.networkError:
        return 'Network error$assetText. Please check your internet connection and try again$contextText.';

      case MigrationErrorType.cancelled:
        return 'Migration was cancelled$assetText$contextText.';

      case MigrationErrorType.unknown:
        return 'An unexpected error occurred$assetText. Please try again later$contextText.';
    }
  }
}
