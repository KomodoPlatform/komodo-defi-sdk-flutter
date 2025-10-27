import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Generic response for stream enable methods returning a streamer identifier
class StreamEnableResponse extends BaseResponse {
  StreamEnableResponse({required super.mmrpc, required this.streamerId});

  factory StreamEnableResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    return StreamEnableResponse(
      mmrpc: json.value<String>('mmrpc'),
      streamerId: result.value<String>('streamer_id'),
    );
  }

  final String streamerId;

  @override
  JsonMap toJson() => {
    'mmrpc': mmrpc,
    'result': {'streamer_id': streamerId},
  };
}

/// Generic response for stream::disable (typically returns { result: { result: "Success" } })
class StreamDisableResponse extends BaseResponse {
  StreamDisableResponse({required super.mmrpc, required this.result});

  factory StreamDisableResponse.parse(JsonMap json) {
    final result = json.value<JsonMap>('result');
    return StreamDisableResponse(
      mmrpc: json.value<String>('mmrpc'),
      result: result.value<String>('result'),
    );
  }

  final String result; // e.g. "Success"

  @override
  JsonMap toJson() => {
    'mmrpc': mmrpc,
    'result': {'result': result},
  };
}

/// Optional stream configuration shared by some stream enable methods
class StreamConfig implements RpcRequestParams {
  const StreamConfig({this.streamIntervalSeconds});

  final int? streamIntervalSeconds;

  @override
  JsonMap toRpcParams() => {
    if (streamIntervalSeconds != null)
      'stream_interval_seconds': streamIntervalSeconds,
  };
}


