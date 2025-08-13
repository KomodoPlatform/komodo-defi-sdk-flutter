import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to pay a Lightning invoice
class PayInvoiceRequest
    extends BaseRequest<PayInvoiceResponse, GeneralErrorResponse> {
  PayInvoiceRequest({
    required String rpcPass,
    required this.coin,
    required this.invoice,
    this.maxFeeMsat,
  }) : super(
         method: 'lightning::pay_invoice',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  /// Coin ticker for the Lightning-enabled asset (e.g. 'BTC')
  final String coin;

  /// BOLT 11 invoice string to be paid
  final String invoice;

  /// Optional fee limit in millisatoshis
  final int? maxFeeMsat;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {
      'coin': coin,
      'invoice': invoice,
      if (maxFeeMsat != null) 'max_fee_msat': maxFeeMsat,
    },
  });

  @override
  PayInvoiceResponse parse(Map<String, dynamic> json) =>
      PayInvoiceResponse.parse(json);
}

/// Response from paying a Lightning invoice
class PayInvoiceResponse extends BaseResponse {
  PayInvoiceResponse({
    required super.mmrpc,
    required this.preimage,
    required this.feePaidMsat,
    this.routeHops,
  });

  factory PayInvoiceResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return PayInvoiceResponse(
      mmrpc: json.value<String>('mmrpc'),
      preimage: result.value<String>('preimage'),
      feePaidMsat: result.value<int>('fee_paid_msat'),
      routeHops:
          result
              .valueOrNull<List<dynamic>?>('route_hops')
              ?.map((e) => e as String)
              .toList(),
    );
  }

  /// Payment preimage proving successful payment
  final String preimage;

  /// Total fee paid in millisatoshis
  final int feePaidMsat;

  /// Route hop pubkeys, if available
  final List<String>? routeHops;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'preimage': preimage,
      'fee_paid_msat': feePaidMsat,
      if (routeHops != null) 'route_hops': routeHops,
    },
  };
}
