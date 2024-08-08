import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';

class GetNewAddressRequest
    extends BaseRequest<GetNewAddressResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  GetNewAddressRequest({
    required super.rpcPass,
    required super.apiClient,
    required this.coin,
  }) : super(method: 'get_new_address');

  final String coin;

  @override
  Map<String, dynamic> toJson() {
    return {
      'userpass': rpcPass,
      'method': method,
      'mmrpc': mmrpc,
      'params': {'coin': coin},
    };
  }

  @override
  GetNewAddressResponse fromJson(Map<String, dynamic> json) =>
      GetNewAddressResponse.fromJson(json);
}

class GetNewAddressResponse extends BaseResponse {
  GetNewAddressResponse({required super.mmrpc, required this.address});

  factory GetNewAddressResponse.fromJson(Map<String, dynamic> json) {
    return GetNewAddressResponse(
      mmrpc: json.value<String>('mmrpc'),
      address: json.nestedValue<String>(['result', 'address']),
    );
  }

  final String address;

  @override
  Map<String, dynamic> toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {'address': address},
    };
  }
}
