class TokensRequest {
  TokensRequest({
    required this.ticker,
    this.requiredConfirmations = 3,
  });
  final String ticker;
  final int requiredConfirmations;

  Map<String, dynamic> toJson() => {
        'ticker': ticker,
        'required_confirmations': requiredConfirmations,
      };
}
