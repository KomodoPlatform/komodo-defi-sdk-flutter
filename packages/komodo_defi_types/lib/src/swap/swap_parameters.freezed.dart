// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swap_parameters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SwapParameters {
  AssetId get base;
  AssetId get rel;
  Decimal get price;
  Decimal get volume;
  String get swapMethod;
  Decimal? get minVolume;
  int? get baseConfs;
  bool? get baseNota;
  int? get relConfs;
  bool? get relNota;
  bool get saveInHistory;

  /// Create a copy of SwapParameters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SwapParametersCopyWith<SwapParameters> get copyWith =>
      _$SwapParametersCopyWithImpl<SwapParameters>(
          this as SwapParameters, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SwapParameters &&
            (identical(other.base, base) || other.base == base) &&
            (identical(other.rel, rel) || other.rel == rel) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.swapMethod, swapMethod) ||
                other.swapMethod == swapMethod) &&
            (identical(other.minVolume, minVolume) ||
                other.minVolume == minVolume) &&
            (identical(other.baseConfs, baseConfs) ||
                other.baseConfs == baseConfs) &&
            (identical(other.baseNota, baseNota) ||
                other.baseNota == baseNota) &&
            (identical(other.relConfs, relConfs) ||
                other.relConfs == relConfs) &&
            (identical(other.relNota, relNota) || other.relNota == relNota) &&
            (identical(other.saveInHistory, saveInHistory) ||
                other.saveInHistory == saveInHistory));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      base,
      rel,
      price,
      volume,
      swapMethod,
      minVolume,
      baseConfs,
      baseNota,
      relConfs,
      relNota,
      saveInHistory);

  @override
  String toString() {
    return 'SwapParameters(base: $base, rel: $rel, price: $price, volume: $volume, swapMethod: $swapMethod, minVolume: $minVolume, baseConfs: $baseConfs, baseNota: $baseNota, relConfs: $relConfs, relNota: $relNota, saveInHistory: $saveInHistory)';
  }
}

/// @nodoc
abstract mixin class $SwapParametersCopyWith<$Res> {
  factory $SwapParametersCopyWith(
          SwapParameters value, $Res Function(SwapParameters) _then) =
      _$SwapParametersCopyWithImpl;
  @useResult
  $Res call(
      {AssetId base,
      AssetId rel,
      Decimal price,
      Decimal volume,
      String swapMethod,
      Decimal? minVolume,
      int? baseConfs,
      bool? baseNota,
      int? relConfs,
      bool? relNota,
      bool saveInHistory});
}

/// @nodoc
class _$SwapParametersCopyWithImpl<$Res>
    implements $SwapParametersCopyWith<$Res> {
  _$SwapParametersCopyWithImpl(this._self, this._then);

  final SwapParameters _self;
  final $Res Function(SwapParameters) _then;

  /// Create a copy of SwapParameters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base = null,
    Object? rel = null,
    Object? price = null,
    Object? volume = null,
    Object? swapMethod = null,
    Object? minVolume = freezed,
    Object? baseConfs = freezed,
    Object? baseNota = freezed,
    Object? relConfs = freezed,
    Object? relNota = freezed,
    Object? saveInHistory = null,
  }) {
    return _then(_self.copyWith(
      base: null == base
          ? _self.base
          : base // ignore: cast_nullable_to_non_nullable
              as AssetId,
      rel: null == rel
          ? _self.rel
          : rel // ignore: cast_nullable_to_non_nullable
              as AssetId,
      price: null == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as Decimal,
      volume: null == volume
          ? _self.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as Decimal,
      swapMethod: null == swapMethod
          ? _self.swapMethod
          : swapMethod // ignore: cast_nullable_to_non_nullable
              as String,
      minVolume: freezed == minVolume
          ? _self.minVolume
          : minVolume // ignore: cast_nullable_to_non_nullable
              as Decimal?,
      baseConfs: freezed == baseConfs
          ? _self.baseConfs
          : baseConfs // ignore: cast_nullable_to_non_nullable
              as int?,
      baseNota: freezed == baseNota
          ? _self.baseNota
          : baseNota // ignore: cast_nullable_to_non_nullable
              as bool?,
      relConfs: freezed == relConfs
          ? _self.relConfs
          : relConfs // ignore: cast_nullable_to_non_nullable
              as int?,
      relNota: freezed == relNota
          ? _self.relNota
          : relNota // ignore: cast_nullable_to_non_nullable
              as bool?,
      saveInHistory: null == saveInHistory
          ? _self.saveInHistory
          : saveInHistory // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _SwapParameters extends SwapParameters {
  const _SwapParameters(
      {required this.base,
      required this.rel,
      required this.price,
      required this.volume,
      this.swapMethod = 'setprice',
      this.minVolume,
      this.baseConfs,
      this.baseNota,
      this.relConfs,
      this.relNota,
      this.saveInHistory = true})
      : super._();

  @override
  final AssetId base;
  @override
  final AssetId rel;
  @override
  final Decimal price;
  @override
  final Decimal volume;
  @override
  @JsonKey()
  final String swapMethod;
  @override
  final Decimal? minVolume;
  @override
  final int? baseConfs;
  @override
  final bool? baseNota;
  @override
  final int? relConfs;
  @override
  final bool? relNota;
  @override
  @JsonKey()
  final bool saveInHistory;

  /// Create a copy of SwapParameters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SwapParametersCopyWith<_SwapParameters> get copyWith =>
      __$SwapParametersCopyWithImpl<_SwapParameters>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SwapParameters &&
            (identical(other.base, base) || other.base == base) &&
            (identical(other.rel, rel) || other.rel == rel) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.swapMethod, swapMethod) ||
                other.swapMethod == swapMethod) &&
            (identical(other.minVolume, minVolume) ||
                other.minVolume == minVolume) &&
            (identical(other.baseConfs, baseConfs) ||
                other.baseConfs == baseConfs) &&
            (identical(other.baseNota, baseNota) ||
                other.baseNota == baseNota) &&
            (identical(other.relConfs, relConfs) ||
                other.relConfs == relConfs) &&
            (identical(other.relNota, relNota) || other.relNota == relNota) &&
            (identical(other.saveInHistory, saveInHistory) ||
                other.saveInHistory == saveInHistory));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      base,
      rel,
      price,
      volume,
      swapMethod,
      minVolume,
      baseConfs,
      baseNota,
      relConfs,
      relNota,
      saveInHistory);

  @override
  String toString() {
    return 'SwapParameters(base: $base, rel: $rel, price: $price, volume: $volume, swapMethod: $swapMethod, minVolume: $minVolume, baseConfs: $baseConfs, baseNota: $baseNota, relConfs: $relConfs, relNota: $relNota, saveInHistory: $saveInHistory)';
  }
}

/// @nodoc
abstract mixin class _$SwapParametersCopyWith<$Res>
    implements $SwapParametersCopyWith<$Res> {
  factory _$SwapParametersCopyWith(
          _SwapParameters value, $Res Function(_SwapParameters) _then) =
      __$SwapParametersCopyWithImpl;
  @override
  @useResult
  $Res call(
      {AssetId base,
      AssetId rel,
      Decimal price,
      Decimal volume,
      String swapMethod,
      Decimal? minVolume,
      int? baseConfs,
      bool? baseNota,
      int? relConfs,
      bool? relNota,
      bool saveInHistory});
}

/// @nodoc
class __$SwapParametersCopyWithImpl<$Res>
    implements _$SwapParametersCopyWith<$Res> {
  __$SwapParametersCopyWithImpl(this._self, this._then);

  final _SwapParameters _self;
  final $Res Function(_SwapParameters) _then;

  /// Create a copy of SwapParameters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? base = null,
    Object? rel = null,
    Object? price = null,
    Object? volume = null,
    Object? swapMethod = null,
    Object? minVolume = freezed,
    Object? baseConfs = freezed,
    Object? baseNota = freezed,
    Object? relConfs = freezed,
    Object? relNota = freezed,
    Object? saveInHistory = null,
  }) {
    return _then(_SwapParameters(
      base: null == base
          ? _self.base
          : base // ignore: cast_nullable_to_non_nullable
              as AssetId,
      rel: null == rel
          ? _self.rel
          : rel // ignore: cast_nullable_to_non_nullable
              as AssetId,
      price: null == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as Decimal,
      volume: null == volume
          ? _self.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as Decimal,
      swapMethod: null == swapMethod
          ? _self.swapMethod
          : swapMethod // ignore: cast_nullable_to_non_nullable
              as String,
      minVolume: freezed == minVolume
          ? _self.minVolume
          : minVolume // ignore: cast_nullable_to_non_nullable
              as Decimal?,
      baseConfs: freezed == baseConfs
          ? _self.baseConfs
          : baseConfs // ignore: cast_nullable_to_non_nullable
              as int?,
      baseNota: freezed == baseNota
          ? _self.baseNota
          : baseNota // ignore: cast_nullable_to_non_nullable
              as bool?,
      relConfs: freezed == relConfs
          ? _self.relConfs
          : relConfs // ignore: cast_nullable_to_non_nullable
              as int?,
      relNota: freezed == relNota
          ? _self.relNota
          : relNota // ignore: cast_nullable_to_non_nullable
              as bool?,
      saveInHistory: null == saveInHistory
          ? _self.saveInHistory
          : saveInHistory // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
