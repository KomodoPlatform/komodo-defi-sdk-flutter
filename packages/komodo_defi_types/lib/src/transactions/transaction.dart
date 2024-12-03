import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Domain model for a transaction, decoupled from the API representation
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.internalId,
    required this.assetId,
    required this.balanceChanges,
    required this.timestamp,
    required this.confirmations,
    required this.blockHeight,
    required this.from,
    required this.to,
    required this.txHash,
    this.fee,
    this.memo,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json.value<String>('id'),
        internalId: json.value<String>('internal_id'),
        assetId: AssetId.parse(
          json.value<JsonMap>('asset_id'),
          knownIds: null,
        ),
        balanceChanges: BalanceChanges.fromJson(json),
        timestamp: DateTime.parse(json.value<String>('timestamp')),
        confirmations: json.value<int>('confirmations'),
        blockHeight: json.value<int>('block_height'),
        from: List<String>.from(json.value('from')),
        to: List<String>.from(json.value('to')),
        txHash: json.valueOrNull<String>('tx_hash'),
        fee: json.containsKey('fee')
            ? FeeInfo.fromJson(json.value('fee'))
            : null,
        memo: json.valueOrNull<String>('memo'),
      );

  final String id;
  final String internalId;
  final AssetId assetId;
  final BalanceChanges balanceChanges;
  final DateTime timestamp;
  final int confirmations;
  final int blockHeight;
  final List<String> from;
  final List<String> to;
  final String? txHash;
  final FeeInfo? fee;
  final String? memo;

  /// Convenience getter for the net balance change
  Decimal get amount => balanceChanges.netChange;

  /// Convenience getter for whether transaction is incoming
  bool get isIncoming => balanceChanges.isIncoming;

  @override
  List<Object?> get props => [
        id,
        internalId,
        assetId,
        balanceChanges,
        timestamp,
        confirmations,
        blockHeight,
        from,
        to,
        txHash,
        fee,
        memo,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'internal_id': internalId,
        'asset_id': assetId.toJson(),
        ...balanceChanges.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'confirmations': confirmations,
        'block_height': blockHeight,
        'from': from,
        'to': to,
        if (txHash != null) 'tx_hash': txHash,
        if (fee != null) 'fee': fee!.toJson(),
        if (memo != null) 'memo': memo,
      };
}

extension TransactionInfoExtension on TransactionInfo {
  Transaction asTransaction(AssetId assetId) => Transaction(
        id: txHash,
        internalId: internalId,
        assetId: assetId,
        balanceChanges: BalanceChanges(
          netChange: Decimal.parse(myBalanceChange),
          receivedByMe: receivedByMe != null
              ? Decimal.parse(receivedByMe!)
              : Decimal.zero,
          spentByMe:
              spentByMe != null ? Decimal.parse(spentByMe!) : Decimal.zero,
          totalAmount: Decimal.parse(
            // For historical transactions that don't have spent/received,
            // use the absolute value of the balance change
            receivedByMe ?? spentByMe ?? myBalanceChange.replaceAll('-', ''),
          ),
        ),
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
        confirmations: confirmations,
        blockHeight: blockHeight,
        from: from,
        to: to,
        txHash: txHash,
        fee: feeDetails,
        memo: memo,
      );
}
