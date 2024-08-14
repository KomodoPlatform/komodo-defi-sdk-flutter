// Abstract ApiClient

import 'dart:async';

import 'package:komodo_defi_types/komodo_defi_types.dart';

abstract class ApiClient {
  FutureOr<JsonMap> sendRequest(JsonMap request);

  FutureOr<void> stop();
  FutureOr<bool> isInitialized();
}

class ApiClientMock implements ApiClient {
  @override
  Future<JsonMap> sendRequest(JsonMap request) async {
    return <String, dynamic>{};
  }

  @override
  Future<void> stop() async {}

  @override
  bool isInitialized() {
    return true;
  }
}
