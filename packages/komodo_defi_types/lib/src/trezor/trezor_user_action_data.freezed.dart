// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trezor_user_action_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrezorUserActionData {

 TrezorUserActionType get actionType;@SensitiveStringConverter() SensitiveString? get pin;@SensitiveStringConverter() SensitiveString? get passphrase;
/// Create a copy of TrezorUserActionData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrezorUserActionDataCopyWith<TrezorUserActionData> get copyWith => _$TrezorUserActionDataCopyWithImpl<TrezorUserActionData>(this as TrezorUserActionData, _$identity);

  /// Serializes this TrezorUserActionData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrezorUserActionData&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.pin, pin) || other.pin == pin)&&(identical(other.passphrase, passphrase) || other.passphrase == passphrase));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,actionType,pin,passphrase);



}

/// @nodoc
abstract mixin class $TrezorUserActionDataCopyWith<$Res>  {
  factory $TrezorUserActionDataCopyWith(TrezorUserActionData value, $Res Function(TrezorUserActionData) _then) = _$TrezorUserActionDataCopyWithImpl;
@useResult
$Res call({
 TrezorUserActionType actionType,@SensitiveStringConverter() SensitiveString? pin,@SensitiveStringConverter() SensitiveString? passphrase
});




}
/// @nodoc
class _$TrezorUserActionDataCopyWithImpl<$Res>
    implements $TrezorUserActionDataCopyWith<$Res> {
  _$TrezorUserActionDataCopyWithImpl(this._self, this._then);

  final TrezorUserActionData _self;
  final $Res Function(TrezorUserActionData) _then;

/// Create a copy of TrezorUserActionData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actionType = null,Object? pin = freezed,Object? passphrase = freezed,}) {
  return _then(_self.copyWith(
actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as TrezorUserActionType,pin: freezed == pin ? _self.pin : pin // ignore: cast_nullable_to_non_nullable
as SensitiveString?,passphrase: freezed == passphrase ? _self.passphrase : passphrase // ignore: cast_nullable_to_non_nullable
as SensitiveString?,
  ));
}

}


/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _TrezorUserActionData extends TrezorUserActionData {
  const _TrezorUserActionData({required this.actionType, @SensitiveStringConverter() this.pin, @SensitiveStringConverter() this.passphrase}): super._();
  factory _TrezorUserActionData.fromJson(Map<String, dynamic> json) => _$TrezorUserActionDataFromJson(json);

@override final  TrezorUserActionType actionType;
@override@SensitiveStringConverter() final  SensitiveString? pin;
@override@SensitiveStringConverter() final  SensitiveString? passphrase;

/// Create a copy of TrezorUserActionData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrezorUserActionDataCopyWith<_TrezorUserActionData> get copyWith => __$TrezorUserActionDataCopyWithImpl<_TrezorUserActionData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrezorUserActionDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrezorUserActionData&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.pin, pin) || other.pin == pin)&&(identical(other.passphrase, passphrase) || other.passphrase == passphrase));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,actionType,pin,passphrase);



}

/// @nodoc
abstract mixin class _$TrezorUserActionDataCopyWith<$Res> implements $TrezorUserActionDataCopyWith<$Res> {
  factory _$TrezorUserActionDataCopyWith(_TrezorUserActionData value, $Res Function(_TrezorUserActionData) _then) = __$TrezorUserActionDataCopyWithImpl;
@override @useResult
$Res call({
 TrezorUserActionType actionType,@SensitiveStringConverter() SensitiveString? pin,@SensitiveStringConverter() SensitiveString? passphrase
});




}
/// @nodoc
class __$TrezorUserActionDataCopyWithImpl<$Res>
    implements _$TrezorUserActionDataCopyWith<$Res> {
  __$TrezorUserActionDataCopyWithImpl(this._self, this._then);

  final _TrezorUserActionData _self;
  final $Res Function(_TrezorUserActionData) _then;

/// Create a copy of TrezorUserActionData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actionType = null,Object? pin = freezed,Object? passphrase = freezed,}) {
  return _then(_TrezorUserActionData(
actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as TrezorUserActionType,pin: freezed == pin ? _self.pin : pin // ignore: cast_nullable_to_non_nullable
as SensitiveString?,passphrase: freezed == passphrase ? _self.passphrase : passphrase // ignore: cast_nullable_to_non_nullable
as SensitiveString?,
  ));
}


}

// dart format on
