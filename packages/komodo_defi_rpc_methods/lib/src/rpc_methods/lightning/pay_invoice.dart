import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to pay a Lightning invoice
class PayInvoiceRequest
    extends BaseRequest<PayInvoiceResponse, GeneralErrorResponse> {
  PayInvoiceRequest({
    required String rpcPass,
    required this.coin,
    required this.payment,
  }) : super(
         method: 'lightning::payments::send_payment',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  /// Coin ticker for the Lightning-enabled asset (e.g. 'BTC')
  final String coin;

  /// Payment union: {type: 'invoice'|'keysend', ...}
  final LightningPayment payment;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {'coin': coin, 'payment': payment.toJson()},
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
      preimage: result.valueOrNull<String?>('preimage') ?? '',
      feePaidMsat: result.valueOrNull<int?>('fee_paid_msat') ?? 0,
      routeHops: result.valueOrNull<List<String>?>('route_hops'),
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
