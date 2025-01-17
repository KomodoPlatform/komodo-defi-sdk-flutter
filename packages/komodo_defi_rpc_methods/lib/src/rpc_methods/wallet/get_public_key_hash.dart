import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class GetPublicKeyHashRequest
    extends BaseRequest<GetPublicKeyHashResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  GetPublicKeyHashRequest({required super.rpcPass})
      : super(method: 'get_public_key_hash', mmrpc: '2.0');

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'params': <JsonMap>{},
      };

  @override
  GetPublicKeyHashResponse parse(Map<String, dynamic> json) =>
      GetPublicKeyHashResponse.parse(json);
}

class GetPublicKeyHashResponse extends BaseResponse {
  GetPublicKeyHashResponse({
    required super.mmrpc,
    required this.publicKeyHash,
  });

  factory GetPublicKeyHashResponse.parse(Map<String, dynamic> json) {
    return GetPublicKeyHashResponse(
      mmrpc: json.value<String>('mmrpc'),
      publicKeyHash: json.value<String>('result', 'public_key_hash'),
    );
  }

  final String publicKeyHash;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': {
          'public_key_hash': publicKeyHash,
        },
      };
}
