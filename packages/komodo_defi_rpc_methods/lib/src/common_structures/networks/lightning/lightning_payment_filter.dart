class LightningPaymentFilter {
  LightningPaymentFilter({
    this.status,
    this.paymentType,
    this.fromAmountMsat,
    this.toAmountMsat,
    this.fromTimestamp,
    this.toTimestamp,
  });
  final String? status;
  final String? paymentType;
  final int? fromAmountMsat;
  final int? toAmountMsat;
  final int? fromTimestamp;
  final int? toTimestamp;

  Map<String, dynamic> toJson() => {
        if (status != null) 'status': status,
        if (paymentType != null) 'payment_type': paymentType,
        if (fromAmountMsat != null) 'from_amount_msat': fromAmountMsat,
        if (toAmountMsat != null) 'to_amount_msat': toAmountMsat,
        if (fromTimestamp != null) 'from_timestamp': fromTimestamp,
        if (toTimestamp != null) 'to_timestamp': toTimestamp,
      };
}
