import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class TokenBalance {
  const TokenBalance({
    required this.ticker,
    required this.balance,
    required this.contractAddress,
  });

  factory TokenBalance.fromJson(JsonMap json) {
    return TokenBalance(
      ticker: json.value<String>('ticker'),
      balance: BalanceInfo.fromJson(json.value<JsonMap>('balance')),
      contractAddress: json.value<String>('contract_address'),
    );
  }

  final String ticker;
  final BalanceInfo balance;
  final String contractAddress;

  Map<String, dynamic> toJson() => {
    'ticker': ticker,
    'balance': balance.toJson(),
    'contract_address': contractAddress,
  };
}
