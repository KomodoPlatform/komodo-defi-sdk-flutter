// TODO: Split the classes into separate files

import 'package:decimal/decimal.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class WithdrawResult {
  WithdrawResult({
    required this.txHex,
    required this.txHash,
    required this.from,
    required this.to,
    required this.totalAmount,
    required this.spentByMe,
    required this.receivedByMe,
    required this.myBalanceChange,
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
      totalAmount: json.value<String>('total_amount'),
      spentByMe: json.value<String>('spent_by_me'),
      receivedByMe: json.value<String>('received_by_me'),
      myBalanceChange: json.value<String>('my_balance_change'),
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
  final String totalAmount;
  final String spentByMe;
  final String receivedByMe;
  final String myBalanceChange;
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
        'total_amount': totalAmount,
        'spent_by_me': spentByMe,
        'received_by_me': receivedByMe,
        'my_balance_change': myBalanceChange,
        'block_height': blockHeight,
        'timestamp': timestamp,
        'fee_details': fee.toJson(),
        'coin': coin,
        if (internalId != null) 'internal_id': internalId,
        if (kmdRewards != null) 'kmd_rewards': kmdRewards!.toJson(),
        if (memo != null) 'memo': memo,
      };
}

class WithdrawalProgress {
  WithdrawalProgress({
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
}

class WithdrawalResult {
  WithdrawalResult({
    required this.txHash,
    required this.amount,
    required this.coin,
    required this.toAddress,
    required this.fee,
    this.kmdRewardsEligible = false,
  });
  final String txHash;
  final Decimal amount;
  final String coin;
  final String toAddress;
  final FeeInfo fee;
  final bool kmdRewardsEligible;
}

typedef WithdrawalPreview = WithdrawResult;

// class FeeDetails {
//   FeeDetails({
//     required this.type,
//     required this.amount,
//     this.coin,
//   });

//   factory FeeDetails.fromJson(Map<String, dynamic> json) {
//     return FeeDetails(
//       type: json.value<String>('type'),
//       amount: json.value<String>('amount'),
//       coin: json.valueOrNull<String>('coin'),
//     );
//   }

//   final String type;
//   final String amount;
//   final String? coin;

//   Map<String, dynamic> toJson() => {
//         'type': type,
//         'amount': amount,
//         if (coin != null) 'coin': coin,
//       };
// }

class WithdrawParameters {
  WithdrawParameters({
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
}

class WithdrawalSource {
  WithdrawalSource._({
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
}

// class WithdrawFeeDetails {
//   WithdrawFeeDetails({
//     required this.type,
//     required this.amount,
//     this.coin,
//     this.gas,
//     this.gasPrice,
//     this.totalFee,
//   });

//   factory WithdrawFeeDetails.fromJson(Map<String, dynamic> json) {
//     return WithdrawFeeDetails(
//       type: json.value<String>('type'),
//       amount: json.value<String>('amount'),
//       coin: json.valueOrNull<String>('coin'),
//       gas: json.valueOrNull<int>('gas'),
//       gasPrice: json.valueOrNull<String>('gas_price'),
//       totalFee: json.valueOrNull<String>('total_fee'),
//     );
//   }

//   final String type;
//   final String amount;
//   final String? coin;
//   final int? gas;
//   final String? gasPrice;
//   final String? totalFee;

//   Map<String, dynamic> toJson() => {
//         'type': type,
//         'amount': amount,
//         if (coin != null) 'coin': coin,
//         if (gas != null) 'gas': gas,
//         if (gasPrice != null) 'gas_price': gasPrice,
//         if (totalFee != null) 'total_fee': totalFee,
//       };
// }

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
