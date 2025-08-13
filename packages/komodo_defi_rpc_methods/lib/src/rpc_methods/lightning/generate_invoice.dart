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
         method: 'lightning::generate_invoice',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String coin;
  final String description;
  final int? amountMsat;
  final int? expiry;

  @override
  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{
      'coin': coin,
      'description': description,
    };
    if (amountMsat != null) params['amount_in_msat'] = amountMsat;
    if (expiry != null) params['expiry'] = expiry;

    return super.toJson().deepMerge({'params': params});
  }

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

  final String invoice;
  final String paymentHash;
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


