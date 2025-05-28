import 'package:decimal/decimal.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class BuyRequest extends BaseRequest<BuySellResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  BuyRequest({
    required super.rpcPass,
    required this.base,
    required this.rel,
    required this.volume,
  }) : super(method: 'buy', mmrpc: '2.0');

  final String base;
  final String rel;
  final Decimal volume;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'params': {'base': base, 'rel': rel, 'volume': volume.toString()},
  };

  @override
  BuySellResponse parse(Map<String, dynamic> json) =>
      BuySellResponse.parse(json);
}
