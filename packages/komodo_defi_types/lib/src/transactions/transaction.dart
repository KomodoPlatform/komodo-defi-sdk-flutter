import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Domain model for a transaction, decoupled from the API representation
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.internalId,
    required this.assetId,
    required this.amount,
    required this.timestamp,
    required this.confirmations,
    required this.blockHeight,
    required this.from,
    required this.to,
    required this.txHash,
    required this.fee,
    required this.memo,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json.value<String>('id'),
        internalId: json.value<String>('internal_id'),
        assetId: AssetId.parse(
          json.value<JsonMap>('asset_id'),
          knownIds: null,
        ),
        amount: Decimal.parse(json.value<String>('my_balance_change')),
        timestamp: DateTime.parse(json.value<String>('timestamp')),
        confirmations: json.value<int>('confirmations'),
        blockHeight: json.value<int>('block_height'),
        from: List<String>.from(json.value('from')),
        to: List<String>.from(json.value('to')),
        txHash: json.valueOrNull<String>('tx_hash'),
        fee: json.valueOrNull<String>('fee') != null
            ? Decimal.parse(json.value<String>('fee'))
            : null,
        memo: json.valueOrNull<String>('memo'),
      );

  final String id;
  final String internalId;
  final AssetId assetId;
  final Decimal amount;
  final DateTime timestamp;
  final int confirmations;
  final int blockHeight;
  final List<String> from;
  final List<String> to;

  // Null for cases such as SIA coin. TODO: Consider if there is a better way
  // represent this property usin
  final String? txHash;
  final Decimal? fee;
  final String? memo;

  bool get isIncoming => amount > Decimal.zero;

  @override
  List<Object?> get props => [
        id,
        internalId,
        assetId,
        amount,
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
        'my_balance_change': amount.toString(),
        'timestamp': timestamp.toIso8601String(),
        'confirmations': confirmations,
        'block_height': blockHeight,
        'from': from,
        'to': to,
        'tx_hash': txHash,
        'memo': memo,
        'fee': fee.toString(),
      };
}
