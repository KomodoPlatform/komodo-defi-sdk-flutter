import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

part 'orderbook_depth.freezed.dart';
part 'orderbook_depth.g.dart';

/// Request to get the number of asks and bids for specified trading pairs
class OrderbookDepthRequest
    extends BaseRequest<OrderbookDepthResponse, GeneralErrorResponse>
    with RequestHandlingMixin {
  OrderbookDepthRequest({required String rpcPass, required this.pairs})
    : super(method: 'orderbook_depth', rpcPass: rpcPass, mmrpc: null);

  /// Array of trading pairs, each pair is an array of 2 strings
  final List<List<String>> pairs;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson().deepMerge({'pairs': pairs});
  }

  @override
  OrderbookDepthResponse parse(Map<String, dynamic> json) =>
      OrderbookDepthResponse.parse(json);
}

@freezed
class OrderbookDepthResponse with _$OrderbookDepthResponse implements BaseResponse {
  const factory OrderbookDepthResponse({
    String? mmrpc,
    String? id,
    required List<PairDepth> result,
  }) = _OrderbookDepthResponse;

  factory OrderbookDepthResponse.fromJson(JsonMap json) =>
      _$OrderbookDepthResponseFromJson(json);

  factory OrderbookDepthResponse.parse(Map<String, dynamic> json) =>
      _$OrderbookDepthResponseFromJson(json);
}

/// Represents the depth information for a trading pair
@freezed
class PairDepth with _$PairDepth {
  const PairDepth._();
  const factory PairDepth({required List<String> pair, required DepthInfo depth}) = _PairDepth;

  factory PairDepth.fromJson(JsonMap json) => _$PairDepthFromJson(json);

  JsonMap toJson() => _$PairDepthToJson(this);
}

/// Represents the depth information with asks and bids count
@freezed
class DepthInfo with _$DepthInfo {
  const DepthInfo._();
  const factory DepthInfo({required int asks, required int bids}) = _DepthInfo;

  factory DepthInfo.fromJson(JsonMap json) => _$DepthInfoFromJson(json);

  JsonMap toJson() => _$DepthInfoToJson(this);
}
