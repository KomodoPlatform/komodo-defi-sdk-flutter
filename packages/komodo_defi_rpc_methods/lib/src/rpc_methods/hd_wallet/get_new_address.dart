import 'package:komodo_defi_rpc_methods/src/common_structures/general/new_address_info.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Get a new address for the specified coin
///
/// Example:
/// ```dart
/// void main() async {
///   final request = GetNewAddressRequest(
///     rpcPass: 'rpcPass',
///     coin: 'KMD',
///   );
///
///   try {
///     final response = await request.send();
///
///     print(response.newAddress.address);
///   } on GeneralErrorResponse catch (e) {
///     print("Error fetching new address: ${e.error}");
///   }
/// }
/// ```
class GetNewAddressRequest
    extends BaseRequest<GetNewAddressResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  GetNewAddressRequest({
    required super.rpcPass,
    required this.coin,
    this.accountId,
    this.chain,
    this.gapLimit,
  }) : super(method: 'get_new_address');

  final String coin;
  final int? accountId;
  final String? chain;
  final int? gapLimit;

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'userpass': rpcPass,
      'method': method,
      'mmrpc': mmrpc,
      'params': {
        'coin': coin,
        if (accountId != null) 'account_id': accountId,
        if (chain != null) 'chain': chain,
        if (gapLimit != null) 'gap_limit': gapLimit,
      },
    };
  }

  @override
  GetNewAddressResponse parse(Map<String, dynamic> json) =>
      GetNewAddressResponse.parse(json);
}

class GetNewAddressResponse extends BaseResponse {
  GetNewAddressResponse({required super.mmrpc, required this.newAddress});

  @override
  factory GetNewAddressResponse.parse(Map<String, dynamic> json) {
    return GetNewAddressResponse(
      mmrpc: json.valueOrNull<String>('mmrpc'),
      newAddress: NewAddressInfo.fromJson(
        json.value<Map<String, dynamic>>('result', 'new_address'),
      ),
    );
  }

  final NewAddressInfo newAddress;

  @override
  Map<String, dynamic> toJson() {
    return {
      'mmrpc': mmrpc,
      'result': {'new_address': newAddress.toJson()},
    };
  }
}
