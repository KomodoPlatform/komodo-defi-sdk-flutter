import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Raw API response for a withdrawal operation
class WithdrawResult {
  WithdrawResult({
    required this.txHex,
    required this.txHash,
    required this.from,
    required this.to,
    required this.balanceChanges,
    required this.blockHeight,
    required this.timestamp,
    required this.fee,
    required this.coin,
    this.internalId,
    this.kmdRewards,
    this.memo,
  });

  factory WithdrawResult.fromJson(Map<String, dynamic> json) {
    return WithdrawResult(
      txHex: json.value<String>('tx_hex'),
      txHash: json.value<String>('tx_hash'),
      from: List<String>.from(json.value('from')),
      to: List<String>.from(json.value('to')),
      balanceChanges: BalanceChanges.fromJson(json),
      blockHeight: json.value<int>('block_height'),
      timestamp: json.value<int>('timestamp'),
      fee: FeeInfo.fromJson(json.value<JsonMap>('fee_details')),
      coin: json.value<String>('coin'),
      internalId: json.valueOrNull<String>('internal_id'),
      kmdRewards: json.containsKey('kmd_rewards')
          ? KmdRewards.fromJson(json.value<JsonMap>('kmd_rewards'))
          : null,
      memo: json.valueOrNull<String>('memo'),
    );
  }

  final String txHex;
  final String txHash;
  final List<String> from;
  final List<String> to;
  final BalanceChanges balanceChanges;
  final int blockHeight;
  final int timestamp;
  final FeeInfo fee;
  final String coin;
  final String? internalId;
  final KmdRewards? kmdRewards;
  final String? memo;

  Map<String, dynamic> toJson() => {
        'tx_hex': txHex,
        'tx_hash': txHash,
        'from': from,
        'to': to,
        ...balanceChanges.toJson(),
        'block_height': blockHeight,
        'timestamp': timestamp,
        'fee_details': fee.toJson(),
        'coin': coin,
        if (internalId != null) 'internal_id': internalId,
        if (kmdRewards != null) 'kmd_rewards': kmdRewards!.toJson(),
        if (memo != null) 'memo': memo,
      };
}

/// Domain model for a successful withdrawal operation
class WithdrawalResult extends Equatable {
  const WithdrawalResult({
    required this.txHash,
    required this.balanceChanges,
    required this.coin,
    required this.toAddress,
    required this.fee,
    this.kmdRewardsEligible = false,
  });

  /// Create a domain model from API response
  factory WithdrawalResult.fromWithdrawResult(WithdrawResult result) {
    return WithdrawalResult(
      txHash: result.txHash,
      balanceChanges: result.balanceChanges,
      coin: result.coin,
      toAddress: result.to.first,
      fee: result.fee,
      kmdRewardsEligible: result.kmdRewards != null &&
          Decimal.parse(result.kmdRewards!.amount) > Decimal.zero,
    );
  }

  final String txHash;
  final BalanceChanges balanceChanges;
  final String coin;
  final String toAddress;
  final FeeInfo fee;
  final bool kmdRewardsEligible;

  /// Convenience getter for the withdrawal amount (abs of net change)
  Decimal get amount => balanceChanges.netChange.abs();

  @override
  List<Object?> get props => [
        txHash,
        balanceChanges,
        coin,
        toAddress,
        fee,
        kmdRewardsEligible,
      ];
}

/// Progress tracking for withdrawal operations
class WithdrawalProgress extends Equatable {
  const WithdrawalProgress({
    required this.status,
    required this.message,
    this.withdrawalResult,
    this.errorCode,
    this.errorMessage,
    this.taskId,
  });

  final WithdrawalStatus status;
  final String message;
  final WithdrawalResult? withdrawalResult;
  final WithdrawalErrorCode? errorCode;
  final String? errorMessage;
  final String? taskId;

  @override
  List<Object?> get props => [
        status,
        message,
        withdrawalResult,
        errorCode,
        errorMessage,
        taskId,
      ];
}

/// Parameters for initiating a withdrawal
class WithdrawParameters extends Equatable {
  const WithdrawParameters({
    required this.asset,
    required this.toAddress,
    required this.amount,
    this.fee,
    this.from,
    this.memo,
    this.ibcTransfer,
    this.isMax,
  }) : assert(
          amount != null || (isMax ?? false),
          'Amount must be non-null when not using max',
        );

  final String asset;
  final String toAddress;
  final Decimal? amount;
  final FeeInfo? fee;
  final WithdrawalSource? from;
  final String? memo;
  final bool? ibcTransfer;
  final bool? isMax;

  Map<String, dynamic> toJson() => {
        'coin': asset,
        'to': toAddress,
        if (fee != null) 'fee': fee!.toJson(),
        if (amount != null) 'amount': amount.toString(),
        if (isMax != null) 'max': isMax,
        if (from != null) 'from': from!.toJson(),
        if (memo != null) 'memo': memo,
        if (ibcTransfer != null) 'ibc_transfer': ibcTransfer,
      };

  @override
  List<Object?> get props => [
        asset,
        toAddress,
        amount,
        fee,
        from,
        memo,
        ibcTransfer,
        isMax,
      ];
}

/// Preview of a withdrawal operation, using same structure as API response
typedef WithdrawalPreview = WithdrawResult;

/// Specifies the source of funds for a withdrawal
class WithdrawalSource extends Equatable {
  const WithdrawalSource._({
    required this.type,
    required this.params,
  });

  factory WithdrawalSource.hdWallet({
    required int accountId,
    required String chain,
    required int addressId,
  }) =>
      WithdrawalSource._(
        type: WithdrawalSourceType.hdWallet,
        params: {
          'account_id': accountId,
          'chain': chain,
          'address_id': addressId,
        },
      );

  final WithdrawalSourceType type;
  final Map<String, dynamic> params;

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        ...params,
      };

  @override
  List<Object?> get props => [type, params];
}

class KmdRewards {
  KmdRewards({
    required this.amount,
    required this.claimedByMe,
  });

  factory KmdRewards.fromJson(Map<String, dynamic> json) {
    return KmdRewards(
      amount: json.value<String>('amount'),
      claimedByMe: json.value<bool>('claimed_by_me'),
    );
  }

  final String amount;
  final bool claimedByMe;

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'claimed_by_me': claimedByMe,
      };
}
