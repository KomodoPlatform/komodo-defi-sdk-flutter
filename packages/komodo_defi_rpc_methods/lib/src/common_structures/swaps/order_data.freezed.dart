// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderData {

 String get coin; AddressData get address; NumericFormatsValue get price; String get pubkey; String get uuid;@JsonKey(name: 'is_mine') bool get isMine;@JsonKey(name: 'base_max_volume') NumericFormatsValue get baseMaxVolume;@JsonKey(name: 'base_min_volume') NumericFormatsValue get baseMinVolume;@JsonKey(name: 'rel_max_volume') NumericFormatsValue get relMaxVolume;@JsonKey(name: 'rel_min_volume') NumericFormatsValue get relMinVolume;@JsonKey(name: 'conf_settings') OrderConfigurationSettings? get confSettings;
/// Create a copy of OrderData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderDataCopyWith<OrderData> get copyWith => _$OrderDataCopyWithImpl<OrderData>(this as OrderData, _$identity);

  /// Serializes this OrderData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderData&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.address, address) || other.address == address)&&(identical(other.price, price) || other.price == price)&&(identical(other.pubkey, pubkey) || other.pubkey == pubkey)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.isMine, isMine) || other.isMine == isMine)&&(identical(other.baseMaxVolume, baseMaxVolume) || other.baseMaxVolume == baseMaxVolume)&&(identical(other.baseMinVolume, baseMinVolume) || other.baseMinVolume == baseMinVolume)&&(identical(other.relMaxVolume, relMaxVolume) || other.relMaxVolume == relMaxVolume)&&(identical(other.relMinVolume, relMinVolume) || other.relMinVolume == relMinVolume)&&(identical(other.confSettings, confSettings) || other.confSettings == confSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coin,address,price,pubkey,uuid,isMine,baseMaxVolume,baseMinVolume,relMaxVolume,relMinVolume,confSettings);

@override
String toString() {
  return 'OrderData(coin: $coin, address: $address, price: $price, pubkey: $pubkey, uuid: $uuid, isMine: $isMine, baseMaxVolume: $baseMaxVolume, baseMinVolume: $baseMinVolume, relMaxVolume: $relMaxVolume, relMinVolume: $relMinVolume, confSettings: $confSettings)';
}


}

/// @nodoc
abstract mixin class $OrderDataCopyWith<$Res>  {
  factory $OrderDataCopyWith(OrderData value, $Res Function(OrderData) _then) = _$OrderDataCopyWithImpl;
@useResult
$Res call({
 String coin, AddressData address, NumericFormatsValue price, String pubkey, String uuid,@JsonKey(name: 'is_mine') bool isMine,@JsonKey(name: 'base_max_volume') NumericFormatsValue baseMaxVolume,@JsonKey(name: 'base_min_volume') NumericFormatsValue baseMinVolume,@JsonKey(name: 'rel_max_volume') NumericFormatsValue relMaxVolume,@JsonKey(name: 'rel_min_volume') NumericFormatsValue relMinVolume,@JsonKey(name: 'conf_settings') OrderConfigurationSettings? confSettings
});


$AddressDataCopyWith<$Res> get address;$OrderConfigurationSettingsCopyWith<$Res>? get confSettings;

}
/// @nodoc
class _$OrderDataCopyWithImpl<$Res>
    implements $OrderDataCopyWith<$Res> {
  _$OrderDataCopyWithImpl(this._self, this._then);

  final OrderData _self;
  final $Res Function(OrderData) _then;

/// Create a copy of OrderData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coin = null,Object? address = null,Object? price = null,Object? pubkey = null,Object? uuid = null,Object? isMine = null,Object? baseMaxVolume = null,Object? baseMinVolume = null,Object? relMaxVolume = null,Object? relMinVolume = null,Object? confSettings = freezed,}) {
  return _then(_self.copyWith(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as AddressData,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as NumericFormatsValue,pubkey: null == pubkey ? _self.pubkey : pubkey // ignore: cast_nullable_to_non_nullable
as String,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,isMine: null == isMine ? _self.isMine : isMine // ignore: cast_nullable_to_non_nullable
as bool,baseMaxVolume: null == baseMaxVolume ? _self.baseMaxVolume : baseMaxVolume // ignore: cast_nullable_to_non_nullable
as NumericFormatsValue,baseMinVolume: null == baseMinVolume ? _self.baseMinVolume : baseMinVolume // ignore: cast_nullable_to_non_nullable
as NumericFormatsValue,relMaxVolume: null == relMaxVolume ? _self.relMaxVolume : relMaxVolume // ignore: cast_nullable_to_non_nullable
as NumericFormatsValue,relMinVolume: null == relMinVolume ? _self.relMinVolume : relMinVolume // ignore: cast_nullable_to_non_nullable
as NumericFormatsValue,confSettings: freezed == confSettings ? _self.confSettings : confSettings // ignore: cast_nullable_to_non_nullable
as OrderConfigurationSettings?,
  ));
}
/// Create a copy of OrderData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressDataCopyWith<$Res> get address {
  
  return $AddressDataCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}/// Create a copy of OrderData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderConfigurationSettingsCopyWith<$Res>? get confSettings {
    if (_self.confSettings == null) {
    return null;
  }

  return $OrderConfigurationSettingsCopyWith<$Res>(_self.confSettings!, (value) {
    return _then(_self.copyWith(confSettings: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _OrderData implements OrderData {
  const _OrderData({required this.coin, required this.address, required this.price, required this.pubkey, required this.uuid, @JsonKey(name: 'is_mine') required this.isMine, @JsonKey(name: 'base_max_volume') required this.baseMaxVolume, @JsonKey(name: 'base_min_volume') required this.baseMinVolume, @JsonKey(name: 'rel_max_volume') required this.relMaxVolume, @JsonKey(name: 'rel_min_volume') required this.relMinVolume, @JsonKey(name: 'conf_settings') this.confSettings});
  factory _OrderData.fromJson(Map<String, dynamic> json) => _$OrderDataFromJson(json);

@override final  String coin;
@override final  AddressData address;
@override final  NumericFormatsValue price;
@override final  String pubkey;
@override final  String uuid;
@override@JsonKey(name: 'is_mine') final  bool isMine;
@override@JsonKey(name: 'base_max_volume') final  NumericFormatsValue baseMaxVolume;
@override@JsonKey(name: 'base_min_volume') final  NumericFormatsValue baseMinVolume;
@override@JsonKey(name: 'rel_max_volume') final  NumericFormatsValue relMaxVolume;
@override@JsonKey(name: 'rel_min_volume') final  NumericFormatsValue relMinVolume;
@override@JsonKey(name: 'conf_settings') final  OrderConfigurationSettings? confSettings;

/// Create a copy of OrderData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderDataCopyWith<_OrderData> get copyWith => __$OrderDataCopyWithImpl<_OrderData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderData&&(identical(other.coin, coin) || other.coin == coin)&&(identical(other.address, address) || other.address == address)&&(identical(other.price, price) || other.price == price)&&(identical(other.pubkey, pubkey) || other.pubkey == pubkey)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.isMine, isMine) || other.isMine == isMine)&&(identical(other.baseMaxVolume, baseMaxVolume) || other.baseMaxVolume == baseMaxVolume)&&(identical(other.baseMinVolume, baseMinVolume) || other.baseMinVolume == baseMinVolume)&&(identical(other.relMaxVolume, relMaxVolume) || other.relMaxVolume == relMaxVolume)&&(identical(other.relMinVolume, relMinVolume) || other.relMinVolume == relMinVolume)&&(identical(other.confSettings, confSettings) || other.confSettings == confSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coin,address,price,pubkey,uuid,isMine,baseMaxVolume,baseMinVolume,relMaxVolume,relMinVolume,confSettings);

@override
String toString() {
  return 'OrderData(coin: $coin, address: $address, price: $price, pubkey: $pubkey, uuid: $uuid, isMine: $isMine, baseMaxVolume: $baseMaxVolume, baseMinVolume: $baseMinVolume, relMaxVolume: $relMaxVolume, relMinVolume: $relMinVolume, confSettings: $confSettings)';
}


}

/// @nodoc
abstract mixin class _$OrderDataCopyWith<$Res> implements $OrderDataCopyWith<$Res> {
  factory _$OrderDataCopyWith(_OrderData value, $Res Function(_OrderData) _then) = __$OrderDataCopyWithImpl;
@override @useResult
$Res call({
 String coin, AddressData address, NumericFormatsValue price, String pubkey, String uuid,@JsonKey(name: 'is_mine') bool isMine,@JsonKey(name: 'base_max_volume') NumericFormatsValue baseMaxVolume,@JsonKey(name: 'base_min_volume') NumericFormatsValue baseMinVolume,@JsonKey(name: 'rel_max_volume') NumericFormatsValue relMaxVolume,@JsonKey(name: 'rel_min_volume') NumericFormatsValue relMinVolume,@JsonKey(name: 'conf_settings') OrderConfigurationSettings? confSettings
});


@override $AddressDataCopyWith<$Res> get address;@override $OrderConfigurationSettingsCopyWith<$Res>? get confSettings;

}
/// @nodoc
class __$OrderDataCopyWithImpl<$Res>
    implements _$OrderDataCopyWith<$Res> {
  __$OrderDataCopyWithImpl(this._self, this._then);

  final _OrderData _self;
  final $Res Function(_OrderData) _then;

/// Create a copy of OrderData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coin = null,Object? address = null,Object? price = null,Object? pubkey = null,Object? uuid = null,Object? isMine = null,Object? baseMaxVolume = null,Object? baseMinVolume = null,Object? relMaxVolume = null,Object? relMinVolume = null,Object? confSettings = freezed,}) {
  return _then(_OrderData(
coin: null == coin ? _self.coin : coin // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as AddressData,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as NumericFormatsValue,pubkey: null == pubkey ? _self.pubkey : pubkey // ignore: cast_nullable_to_non_nullable
as String,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,isMine: null == isMine ? _self.isMine : isMine // ignore: cast_nullable_to_non_nullable
as bool,baseMaxVolume: null == baseMaxVolume ? _self.baseMaxVolume : baseMaxVolume // ignore: cast_nullable_to_non_nullable
as NumericFormatsValue,baseMinVolume: null == baseMinVolume ? _self.baseMinVolume : baseMinVolume // ignore: cast_nullable_to_non_nullable
as NumericFormatsValue,relMaxVolume: null == relMaxVolume ? _self.relMaxVolume : relMaxVolume // ignore: cast_nullable_to_non_nullable
as NumericFormatsValue,relMinVolume: null == relMinVolume ? _self.relMinVolume : relMinVolume // ignore: cast_nullable_to_non_nullable
as NumericFormatsValue,confSettings: freezed == confSettings ? _self.confSettings : confSettings // ignore: cast_nullable_to_non_nullable
as OrderConfigurationSettings?,
  ));
}

/// Create a copy of OrderData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressDataCopyWith<$Res> get address {
  
  return $AddressDataCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}/// Create a copy of OrderData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderConfigurationSettingsCopyWith<$Res>? get confSettings {
    if (_self.confSettings == null) {
    return null;
  }

  return $OrderConfigurationSettingsCopyWith<$Res>(_self.confSettings!, (value) {
    return _then(_self.copyWith(confSettings: value));
  });
}
}


/// @nodoc
mixin _$AddressData {

@JsonKey(name: 'address_data') String get addressData;
/// Create a copy of AddressData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressDataCopyWith<AddressData> get copyWith => _$AddressDataCopyWithImpl<AddressData>(this as AddressData, _$identity);

  /// Serializes this AddressData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressData&&(identical(other.addressData, addressData) || other.addressData == addressData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,addressData);

@override
String toString() {
  return 'AddressData(addressData: $addressData)';
}


}

/// @nodoc
abstract mixin class $AddressDataCopyWith<$Res>  {
  factory $AddressDataCopyWith(AddressData value, $Res Function(AddressData) _then) = _$AddressDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'address_data') String addressData
});




}
/// @nodoc
class _$AddressDataCopyWithImpl<$Res>
    implements $AddressDataCopyWith<$Res> {
  _$AddressDataCopyWithImpl(this._self, this._then);

  final AddressData _self;
  final $Res Function(AddressData) _then;

/// Create a copy of AddressData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addressData = null,}) {
  return _then(_self.copyWith(
addressData: null == addressData ? _self.addressData : addressData // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AddressData implements AddressData {
  const _AddressData({@JsonKey(name: 'address_data') required this.addressData});
  factory _AddressData.fromJson(Map<String, dynamic> json) => _$AddressDataFromJson(json);

@override@JsonKey(name: 'address_data') final  String addressData;

/// Create a copy of AddressData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressDataCopyWith<_AddressData> get copyWith => __$AddressDataCopyWithImpl<_AddressData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressData&&(identical(other.addressData, addressData) || other.addressData == addressData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,addressData);

@override
String toString() {
  return 'AddressData(addressData: $addressData)';
}


}

/// @nodoc
abstract mixin class _$AddressDataCopyWith<$Res> implements $AddressDataCopyWith<$Res> {
  factory _$AddressDataCopyWith(_AddressData value, $Res Function(_AddressData) _then) = __$AddressDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'address_data') String addressData
});




}
/// @nodoc
class __$AddressDataCopyWithImpl<$Res>
    implements _$AddressDataCopyWith<$Res> {
  __$AddressDataCopyWithImpl(this._self, this._then);

  final _AddressData _self;
  final $Res Function(_AddressData) _then;

/// Create a copy of AddressData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addressData = null,}) {
  return _then(_AddressData(
addressData: null == addressData ? _self.addressData : addressData // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OrderConfigurationSettings {

@JsonKey(name: 'base_confs') int? get baseConfirm;@JsonKey(name: 'base_nota') bool? get baseNota;@JsonKey(name: 'rel_confs') int? get relConfirm;@JsonKey(name: 'rel_nota') bool? get relNota;
/// Create a copy of OrderConfigurationSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderConfigurationSettingsCopyWith<OrderConfigurationSettings> get copyWith => _$OrderConfigurationSettingsCopyWithImpl<OrderConfigurationSettings>(this as OrderConfigurationSettings, _$identity);

  /// Serializes this OrderConfigurationSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderConfigurationSettings&&(identical(other.baseConfirm, baseConfirm) || other.baseConfirm == baseConfirm)&&(identical(other.baseNota, baseNota) || other.baseNota == baseNota)&&(identical(other.relConfirm, relConfirm) || other.relConfirm == relConfirm)&&(identical(other.relNota, relNota) || other.relNota == relNota));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,baseConfirm,baseNota,relConfirm,relNota);

@override
String toString() {
  return 'OrderConfigurationSettings(baseConfirm: $baseConfirm, baseNota: $baseNota, relConfirm: $relConfirm, relNota: $relNota)';
}


}

/// @nodoc
abstract mixin class $OrderConfigurationSettingsCopyWith<$Res>  {
  factory $OrderConfigurationSettingsCopyWith(OrderConfigurationSettings value, $Res Function(OrderConfigurationSettings) _then) = _$OrderConfigurationSettingsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'base_confs') int? baseConfirm,@JsonKey(name: 'base_nota') bool? baseNota,@JsonKey(name: 'rel_confs') int? relConfirm,@JsonKey(name: 'rel_nota') bool? relNota
});




}
/// @nodoc
class _$OrderConfigurationSettingsCopyWithImpl<$Res>
    implements $OrderConfigurationSettingsCopyWith<$Res> {
  _$OrderConfigurationSettingsCopyWithImpl(this._self, this._then);

  final OrderConfigurationSettings _self;
  final $Res Function(OrderConfigurationSettings) _then;

/// Create a copy of OrderConfigurationSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? baseConfirm = freezed,Object? baseNota = freezed,Object? relConfirm = freezed,Object? relNota = freezed,}) {
  return _then(_self.copyWith(
baseConfirm: freezed == baseConfirm ? _self.baseConfirm : baseConfirm // ignore: cast_nullable_to_non_nullable
as int?,baseNota: freezed == baseNota ? _self.baseNota : baseNota // ignore: cast_nullable_to_non_nullable
as bool?,relConfirm: freezed == relConfirm ? _self.relConfirm : relConfirm // ignore: cast_nullable_to_non_nullable
as int?,relNota: freezed == relNota ? _self.relNota : relNota // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _OrderConfigurationSettings implements OrderConfigurationSettings {
  const _OrderConfigurationSettings({@JsonKey(name: 'base_confs') this.baseConfirm, @JsonKey(name: 'base_nota') this.baseNota, @JsonKey(name: 'rel_confs') this.relConfirm, @JsonKey(name: 'rel_nota') this.relNota});
  factory _OrderConfigurationSettings.fromJson(Map<String, dynamic> json) => _$OrderConfigurationSettingsFromJson(json);

@override@JsonKey(name: 'base_confs') final  int? baseConfirm;
@override@JsonKey(name: 'base_nota') final  bool? baseNota;
@override@JsonKey(name: 'rel_confs') final  int? relConfirm;
@override@JsonKey(name: 'rel_nota') final  bool? relNota;

/// Create a copy of OrderConfigurationSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderConfigurationSettingsCopyWith<_OrderConfigurationSettings> get copyWith => __$OrderConfigurationSettingsCopyWithImpl<_OrderConfigurationSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderConfigurationSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderConfigurationSettings&&(identical(other.baseConfirm, baseConfirm) || other.baseConfirm == baseConfirm)&&(identical(other.baseNota, baseNota) || other.baseNota == baseNota)&&(identical(other.relConfirm, relConfirm) || other.relConfirm == relConfirm)&&(identical(other.relNota, relNota) || other.relNota == relNota));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,baseConfirm,baseNota,relConfirm,relNota);

@override
String toString() {
  return 'OrderConfigurationSettings(baseConfirm: $baseConfirm, baseNota: $baseNota, relConfirm: $relConfirm, relNota: $relNota)';
}


}

/// @nodoc
abstract mixin class _$OrderConfigurationSettingsCopyWith<$Res> implements $OrderConfigurationSettingsCopyWith<$Res> {
  factory _$OrderConfigurationSettingsCopyWith(_OrderConfigurationSettings value, $Res Function(_OrderConfigurationSettings) _then) = __$OrderConfigurationSettingsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'base_confs') int? baseConfirm,@JsonKey(name: 'base_nota') bool? baseNota,@JsonKey(name: 'rel_confs') int? relConfirm,@JsonKey(name: 'rel_nota') bool? relNota
});




}
/// @nodoc
class __$OrderConfigurationSettingsCopyWithImpl<$Res>
    implements _$OrderConfigurationSettingsCopyWith<$Res> {
  __$OrderConfigurationSettingsCopyWithImpl(this._self, this._then);

  final _OrderConfigurationSettings _self;
  final $Res Function(_OrderConfigurationSettings) _then;

/// Create a copy of OrderConfigurationSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? baseConfirm = freezed,Object? baseNota = freezed,Object? relConfirm = freezed,Object? relNota = freezed,}) {
  return _then(_OrderConfigurationSettings(
baseConfirm: freezed == baseConfirm ? _self.baseConfirm : baseConfirm // ignore: cast_nullable_to_non_nullable
as int?,baseNota: freezed == baseNota ? _self.baseNota : baseNota // ignore: cast_nullable_to_non_nullable
as bool?,relConfirm: freezed == relConfirm ? _self.relConfirm : relConfirm // ignore: cast_nullable_to_non_nullable
as int?,relNota: freezed == relNota ? _self.relNota : relNota // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
