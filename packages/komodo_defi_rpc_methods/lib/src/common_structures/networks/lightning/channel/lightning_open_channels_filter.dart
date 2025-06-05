class LightningOpenChannelsFilter {
  LightningOpenChannelsFilter({
    this.isOutbound,
    this.counterpartyNodeId,
    this.fromFundingValueSats,
    this.toFundingValueSats,
  });
  final bool? isOutbound;
  final String? counterpartyNodeId;
  final int? fromFundingValueSats;
  final int? toFundingValueSats;

  Map<String, dynamic> toJson() => {
    if (isOutbound != null) 'is_outbound': isOutbound,
    if (counterpartyNodeId != null) 'counterparty_node_id': counterpartyNodeId,
    if (fromFundingValueSats != null)
      'from_funding_value_sats': fromFundingValueSats,
    if (toFundingValueSats != null) 'to_funding_value_sats': toFundingValueSats,
  };
}
