/// Status of a withdrawal operation
enum WithdrawalStatus {
  inProgress,
  complete,
  error;

  @override
  String toString() {
    switch (this) {
      case WithdrawalStatus.inProgress:
        return 'in_progress';
      case WithdrawalStatus.complete:
        return 'complete';
      case WithdrawalStatus.error:
        return 'error';
    }
  }

  static WithdrawalStatus fromString(String status) {
    switch (status) {
      case 'in_progress':
        return WithdrawalStatus.inProgress;
      case 'complete':
        return WithdrawalStatus.complete;
      case 'error':
        return WithdrawalStatus.error;
      default:
        throw ArgumentError('Invalid withdrawal status: $status');
    }
  }
}

// enum WithdrawalFeeType {
//   utxoFixed,
//   erc20Gas,
//   solanaGas,
//   cosmosGas;

//   @override
//   String toString() {
//     switch (this) {
//       case WithdrawFee.utxoFixed:
//         return 'utxo_fixed';
//       case WithdrawFee.erc20Gas:
//         return 'erc20_gas';
//       case WithdrawalFeeType.solanaGas:
//         return 'solana_gas';
//       case WithdrawalFeeType.cosmosGas:
//         return 'cosmos_gas';
//     }
//   }

//   static WithdrawalFeeType parse(String type) {
//     switch (type) {
//       case 'utxo_fixed':
//         return WithdrawFee.utxoFixed;
//       case 'erc20_gas':
//         return WithdrawFee.erc20Gas;
//       case 'solana_gas':
//         return WithdrawalFeeType.solanaGas;
//       case 'cosmos_gas':
//         return WithdrawalFeeType.cosmosGas;
//       default:
//         throw ArgumentError('Invalid withdrawal fee type: $type');
//     }
//   }
// }

enum WithdrawalFeeType {
  utxo,
  tendermint,
  eth,
  qrc20;

  static WithdrawalFeeType parse(String type) {
    switch (type.toLowerCase()) {
      case 'utxo':
        return WithdrawalFeeType.utxo;
      case 'tendermint':
        return WithdrawalFeeType.tendermint;
      case 'eth':
        return WithdrawalFeeType.eth;
      case 'qrc20':
        return WithdrawalFeeType.qrc20;
      default:
        throw ArgumentError('Invalid withdrawal fee type: $type');
    }
  }

  @override
  String toString() {
    switch (this) {
      case WithdrawalFeeType.utxo:
        return 'utxo';
      case WithdrawalFeeType.tendermint:
        return 'tendermint';
      case WithdrawalFeeType.eth:
        return 'eth';
      case WithdrawalFeeType.qrc20:
        return 'qrc20';
    }
  }

  String toJson() => toString();
}

enum WithdrawalFeePriority {
  slow,
  standard,
  fast;

  @override
  String toString() {
    switch (this) {
      case WithdrawalFeePriority.slow:
        return 'slow';
      case WithdrawalFeePriority.standard:
        return 'standard';
      case WithdrawalFeePriority.fast:
        return 'fast';
    }
  }

  static WithdrawalFeePriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'slow':
        return WithdrawalFeePriority.slow;
      case 'standard':
        return WithdrawalFeePriority.standard;
      case 'fast':
        return WithdrawalFeePriority.fast;
      default:
        throw ArgumentError('Invalid withdrawal fee priority: $priority');
    }
  }

  String toJson() => toString();
}

enum WithdrawalSourceType {
  hdWallet,
  importedKey,
  smartContract,
  unspendableAddress;

  @override
  String toString() {
    switch (this) {
      case WithdrawalSourceType.hdWallet:
        return 'hd_wallet';
      case WithdrawalSourceType.importedKey:
        return 'imported_key';
      case WithdrawalSourceType.smartContract:
        return 'smart_contract';
      case WithdrawalSourceType.unspendableAddress:
        return 'unspendable_address';
    }
  }

  static WithdrawalSourceType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'hd_wallet':
        return WithdrawalSourceType.hdWallet;
      case 'imported_key':
        return WithdrawalSourceType.importedKey;
      case 'smart_contract':
        return WithdrawalSourceType.smartContract;
      case 'unspendable_address':
        return WithdrawalSourceType.unspendableAddress;
      default:
        throw ArgumentError('Invalid withdrawal source type: $type');
    }
  }
}

enum WithdrawalFeeLevel {
  low,
  medium,
  high;

  @override
  String toString() {
    switch (this) {
      case WithdrawalFeeLevel.low:
        return 'low';
      case WithdrawalFeeLevel.medium:
        return 'medium';
      case WithdrawalFeeLevel.high:
        return 'high';
    }
  }

  static WithdrawalFeeLevel fromString(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return WithdrawalFeeLevel.low;
      case 'medium':
        return WithdrawalFeeLevel.medium;
      case 'high':
        return WithdrawalFeeLevel.high;
      default:
        throw ArgumentError('Invalid fee level: $level');
    }
  }
}

enum WithdrawalErrorCode {
  insufficientFunds,
  invalidAddress,
  networkError,
  userCancelled,
  gasEstimateFailed,
  transactionFailed,
  contractError,
  unknownError;

  @override
  String toString() {
    switch (this) {
      case WithdrawalErrorCode.insufficientFunds:
        return 'insufficient_funds';
      case WithdrawalErrorCode.invalidAddress:
        return 'invalid_address';
      case WithdrawalErrorCode.networkError:
        return 'network_error';
      case WithdrawalErrorCode.userCancelled:
        return 'user_cancelled';
      case WithdrawalErrorCode.gasEstimateFailed:
        return 'gas_estimate_failed';
      case WithdrawalErrorCode.transactionFailed:
        return 'transaction_failed';
      case WithdrawalErrorCode.contractError:
        return 'contract_error';
      case WithdrawalErrorCode.unknownError:
        return 'unknown_error';
    }
  }

  static WithdrawalErrorCode fromString(String code) {
    switch (code) {
      case 'insufficient_funds':
        return WithdrawalErrorCode.insufficientFunds;
      case 'invalid_address':
        return WithdrawalErrorCode.invalidAddress;
      case 'network_error':
        return WithdrawalErrorCode.networkError;
      case 'user_cancelled':
        return WithdrawalErrorCode.userCancelled;
      case 'gas_estimate_failed':
        return WithdrawalErrorCode.gasEstimateFailed;
      case 'transaction_failed':
        return WithdrawalErrorCode.transactionFailed;
      case 'contract_error':
        return WithdrawalErrorCode.contractError;
      case 'unknown_error':
      default:
        return WithdrawalErrorCode.unknownError;
    }
  }
}
