import 'package:komodo_defi_types/komodo_defi_types.dart';

/// Interface for batch activation implementations
abstract class BatchActivationStrategy {
  Future<void> activateGroup(
    ApiClient client,
    Asset parent,
    List<Asset> children,
  );
}
