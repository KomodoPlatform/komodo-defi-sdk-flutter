import 'package:equatable/equatable.dart';

/// Status for a merchant invoice.
class InvoiceStatus extends Equatable {
  const InvoiceStatus._(this._type, {this.confirmations});

  final _InvoiceStatusType _type;
  final int? confirmations;

  const InvoiceStatus.pending() : this._(_InvoiceStatusType.pending);
  const InvoiceStatus.confirming(int confirmations)
      : this._(_InvoiceStatusType.confirming, confirmations: confirmations);
  const InvoiceStatus.paid() : this._(_InvoiceStatusType.paid);
  const InvoiceStatus.underpaid() : this._(_InvoiceStatusType.underpaid);
  const InvoiceStatus.overpaid() : this._(_InvoiceStatusType.overpaid);
  const InvoiceStatus.expired() : this._(_InvoiceStatusType.expired);
  const InvoiceStatus.cancelled() : this._(_InvoiceStatusType.cancelled);

  bool get isPending => _type == _InvoiceStatusType.pending;
  bool get isConfirming => _type == _InvoiceStatusType.confirming;
  bool get isPaid => _type == _InvoiceStatusType.paid;
  bool get isUnderpaid => _type == _InvoiceStatusType.underpaid;
  bool get isOverpaid => _type == _InvoiceStatusType.overpaid;
  bool get isExpired => _type == _InvoiceStatusType.expired;
  bool get isCancelled => _type == _InvoiceStatusType.cancelled;

  @override
  List<Object?> get props => [_type, confirmations];

  @override
  String toString() {
    switch (_type) {
      case _InvoiceStatusType.pending:
        return 'pending';
      case _InvoiceStatusType.confirming:
        return 'confirming(${confirmations ?? 0})';
      case _InvoiceStatusType.paid:
        return 'paid';
      case _InvoiceStatusType.underpaid:
        return 'underpaid';
      case _InvoiceStatusType.overpaid:
        return 'overpaid';
      case _InvoiceStatusType.expired:
        return 'expired';
      case _InvoiceStatusType.cancelled:
        return 'cancelled';
    }
  }
}

enum _InvoiceStatusType {
  pending,
  confirming,
  paid,
  underpaid,
  overpaid,
  expired,
  cancelled,
}

