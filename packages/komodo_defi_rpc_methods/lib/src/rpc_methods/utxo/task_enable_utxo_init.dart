import 'package:komodo_defi_rpc_methods/src/common_structures/common_structures.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class TaskEnableUtxoInit
    extends BaseRequest<NewTaskResponse, GeneralErrorResponse> {
  TaskEnableUtxoInit({
    required this.ticker,
    required this.params,
    super.rpcPass,
  }) : super(
          method: 'task::enable_utxo::init',
          mmrpc: '2.0',
        );

  final String ticker;
  final UtxoActivationParams params;

  @override
  Map<String, dynamic> toJson() => {
        'userpass': rpcPass,
        'mmrpc': mmrpc,
        'method': method,
        'params': {
          'ticker': ticker,
          'activation_params': params.toJson(),
        },
      };

  @override
  NewTaskResponse parseResponse(String responseBody) {
    final json = decodeJson(responseBody);
    if (json['error'] != null) {
      throw GeneralErrorResponse.fromJson(json);
    }
    return NewTaskResponse.fromJson(json);
  }
}
