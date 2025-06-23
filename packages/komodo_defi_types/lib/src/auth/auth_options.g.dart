// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthOptions _$AuthOptionsFromJson(Map<String, dynamic> json) => _AuthOptions(
      derivationMethod:
          DerivationMethod.parse(json['derivation_method'] as String),
      allowWeakPassword: json['allow_weak_password'] as bool? ?? false,
      privKeyPolicy: json['priv_key_policy'] == null
          ? PrivateKeyPolicy.contextPrivKey
          : _policyFromJson(json['priv_key_policy'] as String?),
    );

Map<String, dynamic> _$AuthOptionsToJson(_AuthOptions instance) =>
    <String, dynamic>{
      'derivation_method': _derivationMethodToJson(instance.derivationMethod),
      'allow_weak_password': instance.allowWeakPassword,
      'priv_key_policy': _policyToJson(instance.privKeyPolicy),
    };
