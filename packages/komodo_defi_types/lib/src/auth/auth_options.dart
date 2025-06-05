import 'package:equatable/equatable.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

class AuthOptions extends Equatable {
  const AuthOptions({
    required this.derivationMethod,
    this.allowWeakPassword = false,
    this.privKeyPolicy = PrivateKeyPolicy.contextPrivKey,
  });

  factory AuthOptions.fromJson(JsonMap json) {
    return AuthOptions(
      derivationMethod:
          DerivationMethod.parse(json.value<String>('derivation_method')),
      allowWeakPassword: json.valueOrNull<bool>('allow_weak_password') ?? false,
      privKeyPolicy: json.valueOrNull<String>('priv_key_policy') == 'Trezor'
          ? PrivateKeyPolicy.trezor
          : PrivateKeyPolicy.contextPrivKey,
    );
  }

  final DerivationMethod derivationMethod;
  final bool allowWeakPassword;
  final PrivateKeyPolicy privKeyPolicy;

  JsonMap toJson() {
    return {
      'derivation_method': derivationMethod.toString(),
      'allow_weak_password': allowWeakPassword,
      'priv_key_policy': privKeyPolicy.id,
    };
  }

  @override
  List<Object?> get props =>
      [derivationMethod, allowWeakPassword, privKeyPolicy];
}
