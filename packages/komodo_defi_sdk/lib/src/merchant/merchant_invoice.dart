import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:komodo_cex_market_data/komodo_cex_market_data.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

import 'invoice_status.dart';

/// Immutable data describing a merchant invoice at creation time.
class MerchantInvoice extends Equatable {
  const MerchantInvoice({
    required this.id,
    required this.asset,
    required this.address,
    required this.coinAmount,
    required this.fiatAmount,
    required this.fiat,
    required this.createdAt,
    required this.paymentUri,
    required this.minConfirmations,
    this.expiresAt,
    this.status = const InvoiceStatus.pending(),
    this.matchedTxIds = const <String>{},
  });

  final String id;
  final Asset asset;
  final String address;
  final Decimal coinAmount;
  final Decimal fiatAmount;
  final QuoteCurrency fiat;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String paymentUri;
  final int minConfirmations;
  final InvoiceStatus status;
  final Set<String> matchedTxIds;

  MerchantInvoice copyWith({
    String? id,
    Asset? asset,
    String? address,
    Decimal? coinAmount,
    Decimal? fiatAmount,
    QuoteCurrency? fiat,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? paymentUri,
    int? minConfirmations,
    InvoiceStatus? status,
    Set<String>? matchedTxIds,
  }) {
    return MerchantInvoice(
      id: id ?? this.id,
      asset: asset ?? this.asset,
      address: address ?? this.address,
      coinAmount: coinAmount ?? this.coinAmount,
      fiatAmount: fiatAmount ?? this.fiatAmount,
      fiat: fiat ?? this.fiat,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      paymentUri: paymentUri ?? this.paymentUri,
      minConfirmations: minConfirmations ?? this.minConfirmations,
      status: status ?? this.status,
      matchedTxIds: matchedTxIds ?? this.matchedTxIds,
    );
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  List<Object?> get props => [
    id,
    asset,
    address,
    coinAmount,
    fiatAmount,
    fiat,
    createdAt,
    expiresAt,
    paymentUri,
    minConfirmations,
    status,
    matchedTxIds,
  ];
}

