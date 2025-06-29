// Abstract ApiClient

import 'dart:async';

import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

// ignore: one_member_abstracts
abstract class ApiClient {
  FutureOr<JsonMap> executeRpc(JsonMap request);
  // String get rpcPass;

  // FutureOr<void> stop();
  // FutureOr<bool> isInitialized();
}

// extension KomodoDefiRpcMethodsExtension on ApiClient {
//   KomodoDefiRpcMethods get rpc => KomodoDefiRpcMethods(this);
// }

class ApiClientMock implements ApiClient {
  @override
  Future<JsonMap> executeRpc(JsonMap request) async {
    return <String, dynamic>{};
  }

  // @override
  // String get rpcPass => '';

  // @override
  // Future<void> stop() async {}

  // @override
  // bool isInitialized() {
  //   return true;
  // }
}

extension KomodoDefiRpcMethodsExtension on ApiClient {
  KomodoDefiRpcMethods get rpc => KomodoDefiRpcMethods(this);
}
