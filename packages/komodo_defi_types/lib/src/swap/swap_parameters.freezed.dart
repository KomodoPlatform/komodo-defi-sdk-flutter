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
  @AssetIdConverter()
  AssetId get base;
  @AssetIdConverter()
  AssetId get rel;
  @DecimalConverter()
  Decimal get price;
  @DecimalConverter()
  Decimal get volume;
  @JsonKey(name: 'swap_method')
  String get swapMethod;
  @JsonKey(name: 'min_volume')
  @DecimalConverter()
  Decimal? get minVolume;
  @JsonKey(name: 'base_confs')
  int? get baseConfs;
  @JsonKey(name: 'base_nota')
  bool? get baseNota;
  @JsonKey(name: 'rel_confs')
  int? get relConfs;
  @JsonKey(name: 'rel_nota')
  bool? get relNota;
  @JsonKey(name: 'save_in_history')
  bool get saveInHistory;

  /// Create a copy of SwapParameters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SwapParametersCopyWith<SwapParameters> get copyWith =>
      _$SwapParametersCopyWithImpl<SwapParameters>(
          this as SwapParameters, _$identity);

  /// Serializes this SwapParameters to a JSON map.
  Map<String, dynamic> toJson();

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

  @JsonKey(includeFromJson: false, includeToJson: false)
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
      {@AssetIdConverter() AssetId base,
      @AssetIdConverter() AssetId rel,
      @DecimalConverter() Decimal price,
      @DecimalConverter() Decimal volume,
      @JsonKey(name: 'swap_method') String swapMethod,
      @JsonKey(name: 'min_volume') @DecimalConverter() Decimal? minVolume,
      @JsonKey(name: 'base_confs') int? baseConfs,
      @JsonKey(name: 'base_nota') bool? baseNota,
      @JsonKey(name: 'rel_confs') int? relConfs,
      @JsonKey(name: 'rel_nota') bool? relNota,
      @JsonKey(name: 'save_in_history') bool saveInHistory});
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
@JsonSerializable()
class _SwapParameters extends SwapParameters {
  const _SwapParameters(
      {@AssetIdConverter() required this.base,
      @AssetIdConverter() required this.rel,
      @DecimalConverter() required this.price,
      @DecimalConverter() required this.volume,
      @JsonKey(name: 'swap_method') this.swapMethod = 'setprice',
      @JsonKey(name: 'min_volume') @DecimalConverter() this.minVolume,
      @JsonKey(name: 'base_confs') this.baseConfs,
      @JsonKey(name: 'base_nota') this.baseNota,
      @JsonKey(name: 'rel_confs') this.relConfs,
      @JsonKey(name: 'rel_nota') this.relNota,
      @JsonKey(name: 'save_in_history') this.saveInHistory = true})
      : super._();
  factory _SwapParameters.fromJson(Map<String, dynamic> json) =>
      _$SwapParametersFromJson(json);

  @override
  @AssetIdConverter()
  final AssetId base;
  @override
  @AssetIdConverter()
  final AssetId rel;
  @override
  @DecimalConverter()
  final Decimal price;
  @override
  @DecimalConverter()
  final Decimal volume;
  @override
  @JsonKey(name: 'swap_method')
  final String swapMethod;
  @override
  @JsonKey(name: 'min_volume')
  @DecimalConverter()
  final Decimal? minVolume;
  @override
  @JsonKey(name: 'base_confs')
  final int? baseConfs;
  @override
  @JsonKey(name: 'base_nota')
  final bool? baseNota;
  @override
  @JsonKey(name: 'rel_confs')
  final int? relConfs;
  @override
  @JsonKey(name: 'rel_nota')
  final bool? relNota;
  @override
  @JsonKey(name: 'save_in_history')
  final bool saveInHistory;

  /// Create a copy of SwapParameters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SwapParametersCopyWith<_SwapParameters> get copyWith =>
      __$SwapParametersCopyWithImpl<_SwapParameters>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SwapParametersToJson(
      this,
    );
  }

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

  @JsonKey(includeFromJson: false, includeToJson: false)
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
      {@AssetIdConverter() AssetId base,
      @AssetIdConverter() AssetId rel,
      @DecimalConverter() Decimal price,
      @DecimalConverter() Decimal volume,
      @JsonKey(name: 'swap_method') String swapMethod,
      @JsonKey(name: 'min_volume') @DecimalConverter() Decimal? minVolume,
      @JsonKey(name: 'base_confs') int? baseConfs,
      @JsonKey(name: 'base_nota') bool? baseNota,
      @JsonKey(name: 'rel_confs') int? relConfs,
      @JsonKey(name: 'rel_nota') bool? relNota,
      @JsonKey(name: 'save_in_history') bool saveInHistory});
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
