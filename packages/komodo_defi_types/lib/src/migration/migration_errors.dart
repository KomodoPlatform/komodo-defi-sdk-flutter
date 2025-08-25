import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'migration_errors.freezed.dart';
part 'migration_errors.g.dart';

/// Specific error types that can occur during migration
enum MigrationErrorType {
  /// Asset activation failed
  activationFailed,
  /// Insufficient balance to cover transaction fee
  insufficientBalance,
  /// Insufficient fee for transaction
  insufficientFee,
  /// Transaction creation failed
  txCreationFailed,
  /// Transaction broadcast failed
  txBroadcastFailed,
  /// Source or target wallet is locked
  walletLocked,
  /// Invalid wallet configuration
  invalidWallet,
  /// Network connection error
  networkError,
  /// Operation was cancelled
  cancelled,
  /// Unknown error
  unknown,
}

/// Exception thrown during migration operations
class MigrationException implements Exception {
  const MigrationException(
    this.errorType,
    this.message, {
    this.assetId,
    this.originalError,
    this.stackTrace,
  });

  /// Factory constructor for activation failures
  factory MigrationException.activationFailed(
    String message, {
    AssetId? assetId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) =>
      MigrationException(
        MigrationErrorType.activationFailed,
        message,
        assetId: assetId,
        originalError: originalError,
        stackTrace: stackTrace,
      );

  /// Factory constructor for insufficient balance
  factory MigrationException.insufficientBalance(
    String message, {
    AssetId? assetId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) =>
      MigrationException(
        MigrationErrorType.insufficientBalance,
        message,
        assetId: assetId,
        originalError: originalError,
        stackTrace: stackTrace,
      );

  /// Factory constructor for transaction failures
  factory MigrationException.transactionFailed(
    String message, {
    AssetId? assetId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) =>
      MigrationException(
        MigrationErrorType.txCreationFailed,
        message,
        assetId: assetId,
        originalError: originalError,
        stackTrace: stackTrace,
      );

  /// Factory constructor for network errors
  factory MigrationException.networkError(
    String message, {
    AssetId? assetId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) =>
      MigrationException(
        MigrationErrorType.networkError,
        message,
        assetId: assetId,
        originalError: originalError,
        stackTrace: stackTrace,
      );

  /// Factory constructor for cancelled operations
  factory MigrationException.cancelled(
    String message, {
    AssetId? assetId,
    dynamic originalError,
    StackTrace? stackTrace,
  }) =>
      MigrationException(
        MigrationErrorType.cancelled,
        message,
        assetId: assetId,
        originalError: originalError,
        stackTrace: stackTrace,
      );

  final MigrationErrorType errorType;
  final String message;
  final AssetId? assetId;
  final dynamic originalError;
  final StackTrace? stackTrace;

  /// Convert to user-friendly message
  String toUserFriendlyMessage() {
    switch (errorType) {
      case MigrationErrorType.activationFailed:
        return assetId != null
            ? 'Failed to activate ${assetId!.id}. Please try again later.'
            : 'Failed to activate asset. Please try again later.';
      case MigrationErrorType.insufficientBalance:
        return assetId != null
            ? 'Insufficient balance for ${assetId!.id} to cover transaction fees.'
            : 'Insufficient balance to cover transaction fees.';
      case MigrationErrorType.insufficientFee:
        return 'Transaction fee is too low. Please increase the fee and try again.';
      case MigrationErrorType.txCreationFailed:
        return 'Failed to create transaction. Please check your connection and try again.';
      case MigrationErrorType.txBroadcastFailed:
        return 'Failed to broadcast transaction. Please check your connection and try again.';
      case MigrationErrorType.walletLocked:
        return 'Wallet is locked. Please unlock your wallet and try again.';
      case MigrationErrorType.invalidWallet:
        return 'Invalid wallet configuration. Please check your wallet settings.';
      case MigrationErrorType.networkError:
        return 'Network connection error. Please check your internet connection and try again.';
      case MigrationErrorType.cancelled:
        return 'Migration was cancelled by user.';
      case MigrationErrorType.unknown:
        return 'An unexpected error occurred. Please try again later.';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('MigrationException: $message');
    if (assetId != null) {
      buffer.write(' (Asset: $assetId)');
    }
    if (originalError != null) {
      buffer.write(' - Original error: $originalError');
    }
    return buffer.toString();
  }
}

/// Detailed error information for a specific asset migration
@freezed
abstract class AssetMigrationError with _$AssetMigrationError {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory AssetMigrationError({
    @JsonKey(fromJson: _assetIdFromJson, toJson: _assetIdToJson)
    required AssetId assetId,
    required MigrationErrorType errorType,
    required String message,
    String? userFriendlyMessage,
    String? originalError,
    DateTime? occurredAt,
  }) = _AssetMigrationError;

  factory AssetMigrationError.fromJson(JsonMap json) =>
      _$AssetMigrationErrorFromJson(json);

  factory AssetMigrationError.fromException(
    AssetId assetId,
    MigrationException exception,
  ) =>
      AssetMigrationError(
        assetId: assetId,
        errorType: exception.errorType,
        message: exception.message,
        userFriendlyMessage: exception.toUserFriendlyMessage(),
        originalError: exception.originalError?.toString(),
        occurredAt: DateTime.now(),
      );
}

/// Helper functions for AssetId JSON serialization
AssetId _assetIdFromJson(Map<String, dynamic> json) =>
    AssetId.parse(json, knownIds: null);

Map<String, dynamic> _assetIdToJson(AssetId assetId) => assetId.toJson();
