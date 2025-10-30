import 'package:komodo_defi_framework/komodo_defi_framework.dart';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

import 'streaming_common.dart';

/// stream::shutdown_signal::enable
///
/// Enables a stream that broadcasts OS shutdown signals (like SIGINT, SIGTERM)
/// before the KDF gracefully shuts down.
///
/// Note: This feature is not supported on Windows and doesn't run on Web.
class StreamShutdownSignalEnableRequest extends BaseRequest<
    StreamEnableResponse<ShutdownSignalEvent>, GeneralErrorResponse> {
  StreamShutdownSignalEnableRequest({required String rpcPass, this.clientId})
    : super(
        method: 'stream::shutdown_signal::enable',
        rpcPass: rpcPass,
        mmrpc: RpcVersion.v2_0,
      );

  final int? clientId;

  @override
  JsonMap toJson() => super.toJson().deepMerge({
    'params': {if (clientId != null) 'client_id': clientId},
  });

  @override
  StreamEnableResponse<ShutdownSignalEvent> parse(JsonMap json) =>
      StreamEnableResponse<ShutdownSignalEvent>.parse(json);
}
