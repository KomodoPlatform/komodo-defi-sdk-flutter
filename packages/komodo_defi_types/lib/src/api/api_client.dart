// Abstract ApiClient

import 'dart:async';

import 'package:komodo_defi_types/komodo_defi_types.dart';

// ignore: one_member_abstracts
abstract class ApiClient {
  FutureOr<JsonMap> executeRpc(JsonMap request);
  // String get rpcPass;

  // FutureOr<void> stop();
  // FutureOr<bool> isInitialized();
}

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
