// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activation_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContextPrivKey _$ContextPrivKeyFromJson(Map<String, dynamic> json) =>
    _ContextPrivKey($type: json['type'] as String?);

Map<String, dynamic> _$ContextPrivKeyToJson(_ContextPrivKey instance) =>
    <String, dynamic>{'type': instance.$type};

_Trezor _$TrezorFromJson(Map<String, dynamic> json) =>
    _Trezor($type: json['type'] as String?);

Map<String, dynamic> _$TrezorToJson(_Trezor instance) => <String, dynamic>{
      'type': instance.$type,
    };

_Metamask _$MetamaskFromJson(Map<String, dynamic> json) =>
    _Metamask($type: json['type'] as String?);

Map<String, dynamic> _$MetamaskToJson(_Metamask instance) => <String, dynamic>{
      'type': instance.$type,
    };

_WalletConnect _$WalletConnectFromJson(Map<String, dynamic> json) =>
    _WalletConnect(
      json['session_topic'] as String,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$WalletConnectToJson(_WalletConnect instance) =>
    <String, dynamic>{
      'session_topic': instance.sessionTopic,
      'type': instance.$type,
    };
