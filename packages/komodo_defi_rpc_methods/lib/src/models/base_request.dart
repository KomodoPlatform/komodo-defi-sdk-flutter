import 'dart:convert';
import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:meta/meta.dart';

extension BaseRequestApiClientExtension on ApiClient {
  Future<T> post<T extends BaseResponse, E extends GeneralErrorResponse>(
    BaseRequest<T, E> request,
  ) async {
    final response = await executeRpc(request.toJson());

    return request.parseResponse(jsonEncode(response));
  }
}

/// Base class for all API requests
///
/// Parameters:
/// - [T] - The response type
/// - [E] - The error response type
abstract class BaseRequest<T extends BaseResponse,
    E extends GeneralErrorResponse> {
  BaseRequest({
    // required this.client,
    required this.method,
    this.rpcPass,
    this.mmrpc = '2.0',
    this.params,
  });

  /// RPC password used to authenticate the client. If null, the client's set
  /// password will be used. This is set using the `setRpcPass` method in the
  /// [ApiClient] class.
  final String? rpcPass;
  final String? mmrpc;
  final String method;
  final KdfRequestParams? params;

  /// Convert request to JSON as per the API specification:
  /// https://komodoplatform.com/en/docs/komodo-defi-framework/api/
  @mustCallSuper
  Map<String, dynamic> toJson() {
    return {
      'method': method,
      if (mmrpc?.isNotEmpty ?? false) 'mmrpc': mmrpc,
      if (rpcPass?.isNotEmpty ?? false) 'rpc_pass': rpcPass,
      if (params != null) 'params': params!.toJson().ensureJson(),
    };
  }

  Future<T> send(ApiClient client) async {
    final response = await client.executeRpc(toJson());
    return parseResponse(jsonEncode(response));
  }

  T parseResponse(String responseBody);
}

mixin RequestHandlingMixin<T extends BaseResponse,
    E extends GeneralErrorResponse> on BaseRequest<T, E> {
  // @override
  // Future<T> send() async {
  //   final response = await client.sendRequest(toJson());
  //   return parseResponse(jsonEncode(response));
  // }

// Parse response from JSON
  @override
  T parseResponse(String responseBody) {
    final json = jsonFromString(responseBody);

    // TODO!
    final maybeErrorResponse = tryParseErrorResponse(json);
    if (maybeErrorResponse != null) {
      throw maybeErrorResponse;
    }

    return parse(json);
  }

  @mustCallSuper
  GeneralErrorResponse? tryParseErrorResponse(JsonMap json) {
    if (GeneralErrorResponse.isErrorResponse(json)) {
      return GeneralErrorResponse.parse(json);
    }
    return null;
  }

  T parse(Map<String, dynamic> json);
}
