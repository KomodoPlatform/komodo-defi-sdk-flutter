import 'dart:convert';

import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';

/// Base class for all API requests
///
/// Parameters:
/// - [T] - The response type
/// - [E] - The error response type
abstract class BaseRequest<T extends BaseResponse,
    E extends GeneralErrorResponse> {
  BaseRequest({
    required this.rpcPass,
    required this.client,
    required this.method,
    this.mmrpc = '2.0',
  });

  final String rpcPass;
  final String mmrpc;
  final String method;
  final ApiClient client;

  /// Convert request to JSON as per the API specification:
  /// https://komodoplatform.com/en/docs/komodo-defi-framework/api/
  Map<String, dynamic> toJson();

  Future<T> send() async {
    final response = await client.sendRequest(toJson());
    return parseResponse(jsonEncode(response));
  }

  T parseResponse(String responseBody);
}

mixin RequestHandlingMixin<T extends BaseResponse,
    E extends GeneralErrorResponse> on BaseRequest<T, E> {
  @override
  Future<T> send() async {
    final response = await client.sendRequest(toJson());
    return parseResponse(jsonEncode(response));
  }

// Parse response from JSON
  @override
  T parseResponse(String responseBody) {
    final json = decodeJson(responseBody);

    if (GeneralErrorResponse.isErrorResponse(json)) {
      throw GeneralErrorResponse.fromJson(json);
    }

    return fromJson(json);
  }

  T fromJson(Map<String, dynamic> json);
}
