import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';

class TaskEnableUtxoInit
    extends BaseRequest<NewTaskResponse, GeneralErrorResponse> {
  TaskEnableUtxoInit({
    required this.ticker,
    required this.params,
    super.rpcPass,
  }) : super(method: 'task::enable_utxo::init', mmrpc: '2.0');

  final String ticker;

  @override
  // ignore: overridden_fields
  final UtxoActivationParams params;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {'ticker': ticker, 'activation_params': params.toRpcParams()},
  };

  @override
  NewTaskResponse parse(Map<String, dynamic> json) {
    return NewTaskResponse.parse(json);
  }
}
