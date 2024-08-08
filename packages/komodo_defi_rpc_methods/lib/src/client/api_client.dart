// Abstract ApiClient
import 'package:komodo_defi_framework/src/extensions/map_extension.dart';

abstract class ApiClient {
  Future<JsonMap> sendRequest(JsonMap request);
  Future<void> initialize(String passphrase);
  Future<void> stop();
  bool isInitialized();
}
