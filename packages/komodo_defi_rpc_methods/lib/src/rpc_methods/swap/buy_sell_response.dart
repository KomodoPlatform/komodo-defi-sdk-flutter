import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class BuySellResponse extends BaseResponse {
  BuySellResponse({required super.mmrpc, required this.result});

  factory BuySellResponse.parse(Map<String, dynamic> json) => BuySellResponse(
    mmrpc: json.value<String>('mmrpc'),
    result: BuySellResult.fromJson(json.value<JsonMap>('result')),
  );

  final BuySellResult result;

  @override
  Map<String, dynamic> toJson() => {'mmrpc': mmrpc, 'result': result.toJson()};
}
