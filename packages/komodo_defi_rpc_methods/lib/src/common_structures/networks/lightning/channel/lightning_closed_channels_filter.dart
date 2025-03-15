class LightningClosedChannelsFilter {
  LightningClosedChannelsFilter({
    this.channelType,
    this.counterpartyNodeId,
    this.fromFundingValueSats,
    this.toFundingValueSats,
  });
  final String? channelType;
  final String? counterpartyNodeId;
  final int? fromFundingValueSats;
  final int? toFundingValueSats;

  Map<String, dynamic> toJson() => {
    if (channelType != null) 'channel_type': channelType,
    if (counterpartyNodeId != null) 'counterparty_node_id': counterpartyNodeId,
    if (fromFundingValueSats != null)
      'from_funding_value_sats': fromFundingValueSats,
    if (toFundingValueSats != null) 'to_funding_value_sats': toFundingValueSats,
  };
}
