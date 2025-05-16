import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class ConvertUtxoAddressRequest
    extends BaseRequest<ConvertUtxoAddressResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  ConvertUtxoAddressRequest({
    required super.rpcPass,
    required this.coin,
    required this.address,
    required this.toCoin,
  }) : super(method: 'convert_utxo_address', mmrpc: '2.0');

  final String coin;
  final String address;
  final String toCoin;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'coin': coin, 'address': address, 'to_coin': toCoin},
  };

  @override
  ConvertUtxoAddressResponse parse(Map<String, dynamic> json) =>
      ConvertUtxoAddressResponse.parse(json);
}

class ConvertUtxoAddressResponse extends BaseResponse {
  ConvertUtxoAddressResponse({required super.mmrpc, required this.result});

  factory ConvertUtxoAddressResponse.parse(Map<String, dynamic> json) {
    return ConvertUtxoAddressResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: json.value<String>('result'),
    );
  }

  final String result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result};
}
