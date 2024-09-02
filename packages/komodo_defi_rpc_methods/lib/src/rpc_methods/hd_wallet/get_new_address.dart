import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Get a new address for the specified coin
///
/// Example:
/// ```dart
/// void main() async {
///   final request = GetNewAddressRequest(
///     client: ApiClientMock(), # Use a real client here
///     rpcPass: 'rpcPass',
///     coin: 'KMD',
///   );
///
///   try {
///     final response = await request.send();
///
///     print(response.address);
///   } on GeneralErrorResponse catch (e) {
///     print("Error fetching new address: ${e.error}");
///   }
/// }
/// ```
class GetNewAddressRequest
    extends BaseRequest<GetNewAddressResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  // TODO: Add the other parameters. It's not urgent since they are optional
  // in the API and we are unlikely to use them.
  // https://komodoplatform.com/en/docs/komodo-defi-framework/api/v20-dev/hd_address_management/#arguments
  GetNewAddressRequest({
    required super.rpcPass,
    // required super.client,
    required this.coin,
    this.gapLimit,
  }) : super(method: 'get_new_address');

  final String coin;
  final int? gapLimit;

  @override
  Map<String, dynamic> toJson() {
    return {
      'userpass': rpcPass,
      'method': method,
      'mmrpc': mmrpc,
      'params': {
        'coin': coin,
        if (gapLimit != null) 'gaplimit': gapLimit,
      },
    };
  }

  @override
  GetNewAddressResponse parse(Map<String, dynamic> json) =>
      GetNewAddressResponse.parse(json);
}

// TODO! Create a type-safe new-address-info response class:
// https://komodoplatform.com/en/docs/komodo-defi-framework/api/v20/#new-address-info
class GetNewAddressResponse extends BaseResponse {
  GetNewAddressResponse({required super.mmrpc, required this.address});

  @override
  factory GetNewAddressResponse.parse(Map<String, dynamic> json) {
    return GetNewAddressResponse(
      mmrpc: json.value<String>('mmrpc'),
      address: json.value<String>('result', 'address'),
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
