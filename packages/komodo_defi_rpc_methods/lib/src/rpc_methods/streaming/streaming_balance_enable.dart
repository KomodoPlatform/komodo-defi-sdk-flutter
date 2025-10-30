import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

import 'streaming_common.dart';

/// stream::balance::enable
class StreamBalanceEnableRequest extends BaseRequest<
    StreamEnableResponse<BalanceEvent>, GeneralErrorResponse> {
  StreamBalanceEnableRequest({
    required String rpcPass,
    required this.coin,
    this.clientId,
    this.config,
  }) : super(
         method: 'stream::balance::enable',
         rpcPass: rpcPass,
         mmrpc: RpcVersion.v2_0,
       );

  final String coin;
  final int? clientId;
  final StreamConfig? config;

  @override
  JsonMap toJson() => super.toJson().deepMerge({
    'params': {
      'coin': coin,
      if (clientId != null) 'client_id': clientId,
      if (config != null) 'config': config!.toRpcParams(),
    },
  });

  @override
  StreamEnableResponse<BalanceEvent> parse(JsonMap json) =>
      StreamEnableResponse<BalanceEvent>.parse(json);
}


