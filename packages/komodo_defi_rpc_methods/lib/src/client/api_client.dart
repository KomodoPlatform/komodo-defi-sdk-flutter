// Abstract ApiClient
import 'package:komodo_defi_framework/src/extensions/map_extension.dart';

abstract class ApiClient {
  Future<JsonMap> sendRequest(JsonMap request);
  Future<void> initialize(String passphrase);
  Future<void> stop();
  bool isInitialized();
}

class ApiClientMock implements ApiClient {
  @override
  Future<JsonMap> sendRequest(JsonMap request) async {
    return <String, dynamic>{};
  }

  @override
  Future<void> initialize(String passphrase) async {}

  @override
  Future<void> stop() async {}

  @override
  bool isInitialized() {
    return true;
  }
}
