import 'package:equatable/equatable.dart';

import 'invoice_status.dart';

class InvoiceUpdate extends Equatable {
  const InvoiceUpdate({
    required this.invoiceId,
    required this.status,
    required this.seenAt,
    this.txId,
    this.confirmations,
  });

  final String invoiceId;
  final InvoiceStatus status;
  final DateTime seenAt;
  final String? txId;
  final int? confirmations;

  @override
  List<Object?> get props => [invoiceId, status, seenAt, txId, confirmations];
}

