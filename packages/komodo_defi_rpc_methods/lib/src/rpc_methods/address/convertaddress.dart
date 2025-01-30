import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class ConvertAddressRequest
    extends BaseRequest<ConvertAddressResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  ConvertAddressRequest({
    required super.rpcPass,
    required this.coin,
    required this.fromAddress,
    required this.toAddressFormat,
  }) : super(
          method: 'convertaddress',
          mmrpc: '2.0',
        );

  final String coin;
  final String fromAddress;
  final AddressFormat toAddressFormat;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'params': {
          'coin': coin,
          'from': fromAddress,
          'to_address_format': toAddressFormat.toJson(),
        },
      };

  @override
  ConvertAddressResponse parse(Map<String, dynamic> json) =>
      ConvertAddressResponse.parse(json);
}

class ConvertAddressResponse extends BaseResponse {
  ConvertAddressResponse({
    required super.mmrpc,
    required this.address,
  });

  factory ConvertAddressResponse.parse(Map<String, dynamic> json) {
    return ConvertAddressResponse(
      mmrpc: json.value<String>('mmrpc'),
      address: json.value<String>('result', 'address'),
    );
  }

  final String address;

  @override
  Map<String, dynamic> toJson() => {
        'mmrpc': mmrpc,
        'result': {
          'address': address,
        },
      };
}
