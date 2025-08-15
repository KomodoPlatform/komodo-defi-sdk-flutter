import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Request to generate a Lightning invoice
class GenerateInvoiceRequest
    extends BaseRequest<GenerateInvoiceResponse, GeneralErrorResponse> {
  GenerateInvoiceRequest({
    required String rpcPass,
    required this.coin,
    required this.description,
    this.amountMsat,
    this.expiry,
  }) : super(
         method: 'lightning::payments::generate_invoice',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  /// Coin ticker for the Lightning-enabled asset (e.g. 'BTC')
  final String coin;

  /// Human-readable description to embed in the invoice
  final String description;

  /// Payment amount in millisatoshis; if null, invoice is amount-less
  final int? amountMsat;

  /// Expiry time in seconds; implementation default is used when null
  final int? expiry;

  @override
  Map<String, dynamic> toJson() => super.toJson().deepMerge({
    'params': {
      'coin': coin,
      'description': description,
      if (amountMsat != null) 'amount_in_msat': amountMsat,
      if (expiry != null) 'expiry': expiry,
    },
  });

  @override
  GenerateInvoiceResponse parse(Map<String, dynamic> json) =>
      GenerateInvoiceResponse.parse(json);
}

/// Response from generating a Lightning invoice
class GenerateInvoiceResponse extends BaseResponse {
  GenerateInvoiceResponse({
    required super.mmrpc,
    required this.invoice,
    required this.paymentHash,
    this.expiry,
  });

  factory GenerateInvoiceResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');

    return GenerateInvoiceResponse(
      mmrpc: json.value<String>('mmrpc'),
      invoice: result.value<String>('invoice'),
      paymentHash: result.value<String>('payment_hash'),
      expiry: result.valueOrNull<int?>('expiry'),
    );
  }

  /// Encoded BOLT 11 invoice string
  final String invoice;

  /// Payment hash associated with the invoice
  final String paymentHash;

  /// Expiry time in seconds, if provided by the node
  final int? expiry;

  @override
  Map<String, dynamic> toJson() => {
    'mmrpc': mmrpc,
    'result': {
      'invoice': invoice,
      'payment_hash': paymentHash,
      if (expiry != null) 'expiry': expiry,
    },
  };
}
