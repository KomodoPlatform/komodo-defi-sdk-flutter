import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'auth_options.freezed.dart';
part 'auth_options.g.dart';

@freezed
class AuthOptions with _$AuthOptions {
  const factory AuthOptions({
    @JsonKey(
      name: 'derivation_method',
      fromJson: DerivationMethod.parse,
      toJson: _derivationMethodToJson,
    )
    required DerivationMethod derivationMethod,
    @JsonKey(name: 'allow_weak_password') @Default(false) bool allowWeakPassword,
    @JsonKey(
      name: 'priv_key_policy',
      fromJson: _policyFromJson,
      toJson: _policyToJson,
    )
    @Default(PrivateKeyPolicy.contextPrivKey)
    PrivateKeyPolicy privKeyPolicy,
  }) = _AuthOptions;

  factory AuthOptions.fromJson(JsonMap json) => _$AuthOptionsFromJson(json);
}

String _derivationMethodToJson(DerivationMethod method) => method.toString();

PrivateKeyPolicy _policyFromJson(String? value) =>
    value == 'Trezor' ? PrivateKeyPolicy.trezor : PrivateKeyPolicy.contextPrivKey;

String _policyToJson(PrivateKeyPolicy policy) => policy.id;
