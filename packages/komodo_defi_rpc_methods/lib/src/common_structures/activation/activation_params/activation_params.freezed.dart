// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activation_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
PrivateKeyPolicy _$PrivateKeyPolicyFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'ContextPrivKey':
          return _ContextPrivKey.fromJson(
            json
          );
                case 'Trezor':
          return _Trezor.fromJson(
            json
          );
                case 'Metamask':
          return _Metamask.fromJson(
            json
          );
                case 'WalletConnect':
          return _WalletConnect.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'PrivateKeyPolicy',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$PrivateKeyPolicy {



  /// Serializes this PrivateKeyPolicy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrivateKeyPolicy);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrivateKeyPolicy()';
}


}

/// @nodoc
class $PrivateKeyPolicyCopyWith<$Res>  {
$PrivateKeyPolicyCopyWith(PrivateKeyPolicy _, $Res Function(PrivateKeyPolicy) __);
}


/// @nodoc
@JsonSerializable()

class _ContextPrivKey extends PrivateKeyPolicy {
  const _ContextPrivKey({final  String? $type}): $type = $type ?? 'ContextPrivKey',super._();
  factory _ContextPrivKey.fromJson(Map<String, dynamic> json) => _$ContextPrivKeyFromJson(json);



@JsonKey(name: 'type')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$ContextPrivKeyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContextPrivKey);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrivateKeyPolicy.contextPrivKey()';
}


}




/// @nodoc
@JsonSerializable()

class _Trezor extends PrivateKeyPolicy {
  const _Trezor({final  String? $type}): $type = $type ?? 'Trezor',super._();
  factory _Trezor.fromJson(Map<String, dynamic> json) => _$TrezorFromJson(json);



@JsonKey(name: 'type')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$TrezorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trezor);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrivateKeyPolicy.trezor()';
}


}




/// @nodoc
@JsonSerializable()

class _Metamask extends PrivateKeyPolicy {
  const _Metamask({final  String? $type}): $type = $type ?? 'Metamask',super._();
  factory _Metamask.fromJson(Map<String, dynamic> json) => _$MetamaskFromJson(json);



@JsonKey(name: 'type')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$MetamaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Metamask);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrivateKeyPolicy.metamask()';
}


}




/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _WalletConnect extends PrivateKeyPolicy {
  const _WalletConnect(this.sessionTopic, {final  String? $type}): $type = $type ?? 'WalletConnect',super._();
  factory _WalletConnect.fromJson(Map<String, dynamic> json) => _$WalletConnectFromJson(json);

 final  String sessionTopic;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of PrivateKeyPolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletConnectCopyWith<_WalletConnect> get copyWith => __$WalletConnectCopyWithImpl<_WalletConnect>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletConnectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletConnect&&(identical(other.sessionTopic, sessionTopic) || other.sessionTopic == sessionTopic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionTopic);

@override
String toString() {
  return 'PrivateKeyPolicy.walletConnect(sessionTopic: $sessionTopic)';
}


}

/// @nodoc
abstract mixin class _$WalletConnectCopyWith<$Res> implements $PrivateKeyPolicyCopyWith<$Res> {
  factory _$WalletConnectCopyWith(_WalletConnect value, $Res Function(_WalletConnect) _then) = __$WalletConnectCopyWithImpl;
@useResult
$Res call({
 String sessionTopic
});




}
/// @nodoc
class __$WalletConnectCopyWithImpl<$Res>
    implements _$WalletConnectCopyWith<$Res> {
  __$WalletConnectCopyWithImpl(this._self, this._then);

  final _WalletConnect _self;
  final $Res Function(_WalletConnect) _then;

/// Create a copy of PrivateKeyPolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sessionTopic = null,}) {
  return _then(_WalletConnect(
null == sessionTopic ? _self.sessionTopic : sessionTopic // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
