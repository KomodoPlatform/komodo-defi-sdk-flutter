import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AuthOptions {
  const AuthOptions({
    required this.derivationMethod,
  });

  factory AuthOptions.fromJson(JsonMap json) {
    return AuthOptions(
      derivationMethod:
          DerivationMethod.parse(json.value<String>('derivation_method')),
    );
  }

  final DerivationMethod derivationMethod;

  JsonMap toJson() {
    return {
      'derivation_method': derivationMethod.toString(),
    };
  }
}
