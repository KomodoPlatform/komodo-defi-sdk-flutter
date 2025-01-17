import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Legacy send raw transaction request
class SendRawTransactionLegacyRequest
    extends BaseRequest<SendRawTransactionResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  SendRawTransactionLegacyRequest({
    required super.rpcPass,
    required this.coin,
    required this.txHex,
  }) : super(
          method: 'send_raw_transaction',
          mmrpc: null,
        );

  final String coin;
  final String txHex;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'coin': coin,
        'tx_hex': txHex,
      };

  @override
  SendRawTransactionResponse parse(Map<String, dynamic> json) =>
      SendRawTransactionResponse.parse(json);
}

class SendRawTransactionResponse extends BaseResponse {
  SendRawTransactionResponse({
    required super.mmrpc,
    required this.txHash,
  });

  factory SendRawTransactionResponse.parse(Map<String, dynamic> json) {
    return SendRawTransactionResponse(
      mmrpc: json.value<String>('mmrpc'),
      txHash: json.value<String>('result', 'tx_hash'),
    );
  }

  final String txHash;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': {
          'tx_hash': txHash,
        },
      };
}
