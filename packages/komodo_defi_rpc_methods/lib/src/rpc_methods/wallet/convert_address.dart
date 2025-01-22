import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class ConvertAddressRequest
    extends BaseRequest<ConvertAddressResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  ConvertAddressRequest({
    required String rpcPass,
    required this.fromAddress,
    required this.coinSubClass,
    this.isBchNetwork = false,
  }) : super(method: 'convertaddress', rpcPass: rpcPass, mmrpc: null);

  final String fromAddress;
  final CoinSubClass coinSubClass;
  final bool isBchNetwork;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'from': fromAddress,
      'coin': coinSubClass,
      'to_address_format': AddressFormat.fromCoinSubClass(
        coinSubClass,
        isBchNetwork: isBchNetwork,
      ).toJson(),
    });
  }

  @override
  ConvertAddressResponse parse(Map<String, dynamic> json) {
    return ConvertAddressResponse.parse(json);
  }
}

class ConvertAddressResponse extends BaseResponse {
  ConvertAddressResponse({
    required super.mmrpc,
    required this.address,
  });

  factory ConvertAddressResponse.parse(Map<String, dynamic> json) {
    return ConvertAddressResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      address: json.value<String>('address'),
    );
  }

  final String address;

  @override
  Map<String, dynamic> toJson() {
    return {
      'mmrpc': mmrpc,
      'address': address,
    };
  }
}
