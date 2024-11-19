import 'package:komodo_defi_types/komodo_defi_types.dart';

class SyncStatusExtended {
  SyncStatusExtended({
    this.blocksLeft,
    this.transactionsLeft,
    this.code,
    this.message,
  });

  factory SyncStatusExtended.fromJson(Map<String, dynamic> json) {
    return SyncStatusExtended(
      blocksLeft: json.valueOrNull<int>('blocks_left'),
      transactionsLeft: json.valueOrNull<int>('transactions_left'),
      code: json.valueOrNull<int>('code'),
      message: json.valueOrNull<String>('message'),
    );
  }

  final int? blocksLeft;
  final int? transactionsLeft;
  final int? code;
  final String? message;

  Map<String, dynamic> toJson() {
    return {
      if (blocksLeft != null) 'blocks_left': blocksLeft,
      if (transactionsLeft != null) 'transactions_left': transactionsLeft,
      if (code != null) 'code': code,
      if (message != null) 'message': message,
    };
  }
}

enum TransactionSyncStatusEnum {
  notEnabled,
  notStarted,
  inProgress,
  error,
  finished;

  bool get isComplete => this == finished || this == error;

  static TransactionSyncStatusEnum? tryParse(String? value) {
    if (value == null) {
      return null;
    }

    switch (value) {
      case 'NotEnabled':
        return TransactionSyncStatusEnum.notEnabled;
      case 'NotStarted':
        return TransactionSyncStatusEnum.notStarted;
      case 'InProgress':
        return TransactionSyncStatusEnum.inProgress;
      case 'Error':
        return TransactionSyncStatusEnum.error;
      case 'Finished':
        return TransactionSyncStatusEnum.finished;
      default:
        throw ArgumentError.value(value, 'value', 'Invalid sync status');
    }
  }

  static TransactionSyncStatusEnum parse(String value) {
    final result = tryParse(value);
    if (result != null) {
      return result;
    }

    throw ArgumentError.value(value, 'value', 'Invalid sync status');
  }

  String get value {
    switch (this) {
      case TransactionSyncStatusEnum.notEnabled:
        return 'NotEnabled';
      case TransactionSyncStatusEnum.notStarted:
        return 'NotStarted';
      case TransactionSyncStatusEnum.inProgress:
        return 'InProgress';
      case TransactionSyncStatusEnum.error:
        return 'Error';
      case TransactionSyncStatusEnum.finished:
        return 'Finished';
    }
  }
}
