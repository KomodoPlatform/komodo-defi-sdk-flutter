import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to get Lightning payments history
class GetPaymentHistoryRequest
    extends BaseRequest<GetPaymentHistoryResponse, GeneralErrorResponse> {
  GetPaymentHistoryRequest({
    required String rpcPass,
    required this.coin,
    this.filter,
    this.pagination,
  }) : super(
         method: 'lightning::payments::list_payments_by_filter',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  /// Coin ticker to query payment history for
  final String coin;

  /// Optional filter to restrict returned payments
  final LightningPaymentFilter? filter;

  /// Optional pagination parameters
  final Pagination? pagination;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{'coin': coin};
    if (filter != null) params['filter'] = filter!.toJson();
    if (pagination != null) params['pagination'] = pagination!.toJson();

    return super.toJson().deepMerge({'params': params});
  }

  @override
  GetPaymentHistoryResponse parse(Map<String, dynamic> json) =>
      GetPaymentHistoryResponse.parse(json);
}

/// Response containing Lightning payments history
class GetPaymentHistoryResponse extends BaseResponse {
  GetPaymentHistoryResponse({required super.mmrpc, required this.payments});

  factory GetPaymentHistoryResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return GetPaymentHistoryResponse(
      mmrpc: json.value<String>('mmrpc'),
      payments:
          (result.valueOrNull<JsonList>('payments') ?? [])
              .map(LightningPayment.fromJson)
              .toList(),
    );
  }

  /// List of Lightning payments matching the query
  final List<LightningPayment> payments;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {'payments': payments.map((e) => e.toJson()).toList()},
  };
}
