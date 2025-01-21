import 'package:komodo_defi_types/komodo_defi_types.dart';

class TokensRequest {
  TokensRequest({
    required this.ticker,
    this.requiredConfirmations = 3,
  });

  factory TokensRequest.fromJson(JsonMap json) {
    return TokensRequest(
      ticker: json.value<String>('ticker'),
      requiredConfirmations:
          json.valueOrNull<int>('required_confirmations') ?? 3,
    );
  }

  final String ticker;
  final int requiredConfirmations;

  Map<String, dynamic> toJson() => {
        'ticker': ticker,
        'required_confirmations': requiredConfirmations,
      };
}
