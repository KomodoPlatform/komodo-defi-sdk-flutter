import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class ValidateAddressRequest
    extends BaseRequest<ValidateAddressResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  ValidateAddressRequest({
    required super.rpcPass,
    required this.coin,
    required this.address,
  }) : super(
         method: 'validateaddress',
         mmrpc: RpcVersion.legacy,
         params: ValidateAddressParams(coin: coin, address: address),
       );

  final String coin;
  final String address;

  @override
  ValidateAddressResponse parse(Map<String, dynamic> json) =>
      ValidateAddressResponse.parse(json);
}

class ValidateAddressParams implements RpcRequestParams {
  const ValidateAddressParams({required this.coin, required this.address});

  final String coin;
  final String address;

  @override
  Map<String, dynamic> toRpcParams() => {'coin': coin, 'address': address};
}

class ValidateAddressResponse extends BaseResponse {
  ValidateAddressResponse({
    required super.mmrpc,
    required this.isValid,
    this.reason,
  });

  factory ValidateAddressResponse.parse(Map<String, dynamic> json) {
    if (!json.containsKey('result')) {
      throw const FormatException('Missing required field: result');
    }

    final result = json.value<JsonMap>('result');
    if (!result.containsKey('is_valid')) {
      throw const FormatException('Missing required field: is_valid');
    }

    final response = ValidateAddressResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      isValid: result.value<bool>('is_valid'),
      reason: result.valueOrNull<String>('reason'),
    );

    assert(
      response.isValid || response.reason != null,
      'A reason must be provided if the address is not valid.',
    );

    return response;
  }

  final bool isValid;
  final String? reason;

  @override
  Map<String, dynamic> toJson() => {
    if (mmrpc != null) 'mmrpc': mmrpc,
    'result': {'is_valid': isValid, if (reason != null) 'reason': reason},
  };
}
