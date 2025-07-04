import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AuthOptions extends Equatable {
  const AuthOptions({
    required this.derivationMethod,
    this.allowWeakPassword = false,
  });

  factory AuthOptions.fromJson(JsonMap json) {
    return AuthOptions(
      derivationMethod:
          DerivationMethod.parse(json.value<String>('derivation_method')),
      allowWeakPassword: json.valueOrNull<bool>('allow_weak_password') ?? false,
    );
  }

  final DerivationMethod derivationMethod;
  final bool allowWeakPassword;

  JsonMap toJson() {
    return {
      'derivation_method': derivationMethod.toString(),
      'allow_weak_password': allowWeakPassword,
    };
  }

  @override
  List<Object?> get props => [derivationMethod, allowWeakPassword];
}
