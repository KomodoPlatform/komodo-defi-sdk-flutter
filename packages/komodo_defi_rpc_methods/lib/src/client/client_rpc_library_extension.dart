// lib/src/rpc_methods/base_method_namespace.dart

import 'package:komodo_defi_rpc_methods/src/internal_exports.dart';
import 'package:komodo_defi_rpc_methods/src/rpc_methods_library.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

extension ApiClientExtension on ApiClient {
  RpcMethodsLibrary get rpc => RpcMethodsLibrary(this);
}

abstract class BaseRpcMethodNamespace {
  BaseRpcMethodNamespace(this._client);

  final ApiClient? _client;

  String? get rpcPass => null;

  Future<T> execute<T extends BaseResponse>(
    BaseRequest<T, GeneralErrorResponse> request,
  ) async {
    final client = _client;
    if (client == null) {
      throw StateError(
        'ApiClient is not set. Use this method through an ApiClient instance.',
      );
    }
    return client.post(request);
  }
}
