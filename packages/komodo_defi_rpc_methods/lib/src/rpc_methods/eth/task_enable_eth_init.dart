import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

class TaskEnableEthInit
    extends BaseRequest<NewTaskResponse, GeneralErrorResponse> {
  TaskEnableEthInit({required this.ticker, required this.params, super.rpcPass})
    : super(method: 'task::enable_eth::init', mmrpc: '2.0');

  final String ticker;

  @override
  // ignore: overridden_fields
  final EthWithTokensActivationParams params;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'userpass': rpcPass,
    'mmrpc': mmrpc,
    'method': method,
    'params': {'ticker': ticker, ...params.toRpcParams()},
  };

  @override
  NewTaskResponse parseResponse(String responseBody) {
    final json = jsonFromString(responseBody);
    if (GeneralErrorResponse.isErrorResponse(json)) {
      throw GeneralErrorResponse.parse(json);
    }
    return NewTaskResponse.parse(json);
  }

  @override
  NewTaskResponse parse(Map<String, dynamic> json) =>
      NewTaskResponse.parse(json);
}
