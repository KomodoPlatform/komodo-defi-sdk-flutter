import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class ValidateAddressRequest
    extends BaseRequest<ValidateAddressResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  ValidateAddressRequest({
    required this.coin,
    required this.address,
    required String rpcPass,
  }) : super(method: 'validateaddress', rpcPass: rpcPass, mmrpc: null);

  final String coin;
  final String address;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({
      'coin': coin,
      'address': address,
    });
  }

  @override
  ValidateAddressResponse parse(Map<String, dynamic> json) {
    return ValidateAddressResponse.parse(json);
  }
}

class ValidateAddressResponse extends BaseResponse {
  ValidateAddressResponse({
    required super.mmrpc,
    required this.isValid,
    this.reason,
  });

  factory ValidateAddressResponse.parse(Map<String, dynamic> json) {
    return ValidateAddressResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      isValid: json.value<bool>('is_valid'),
      reason: json.valueOrNull<String>('reason'),
    );
  }

  final bool isValid;
  final String? reason;

  @override
  Map<String, dynamic> toJson() {
    return {
      'mmrpc': mmrpc,
      'is_valid': isValid,
      if (reason != null) 'reason': reason,
    };
  }
}
