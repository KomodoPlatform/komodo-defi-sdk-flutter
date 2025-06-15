// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swap_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SwapResult {
  String get uuid;
  String get base;
  String get rel;
  @DecimalConverter()
  Decimal get price;
  @DecimalConverter()
  Decimal get volume;
  String get orderType;
  String? get txHash;
  int? get createdAt;

  /// Create a copy of SwapResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SwapResultCopyWith<SwapResult> get copyWith =>
      _$SwapResultCopyWithImpl<SwapResult>(this as SwapResult, _$identity);

  /// Serializes this SwapResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SwapResult &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.base, base) || other.base == base) &&
            (identical(other.rel, rel) || other.rel == rel) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.orderType, orderType) ||
                other.orderType == orderType) &&
            (identical(other.txHash, txHash) || other.txHash == txHash) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uuid, base, rel, price, volume,
      orderType, txHash, createdAt);

  @override
  String toString() {
    return 'SwapResult(uuid: $uuid, base: $base, rel: $rel, price: $price, volume: $volume, orderType: $orderType, txHash: $txHash, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $SwapResultCopyWith<$Res> {
  factory $SwapResultCopyWith(
          SwapResult value, $Res Function(SwapResult) _then) =
      _$SwapResultCopyWithImpl;
  @useResult
  $Res call(
      {String uuid,
      String base,
      String rel,
      @DecimalConverter() Decimal price,
      @DecimalConverter() Decimal volume,
      String orderType,
      String? txHash,
      int? createdAt});
}

/// @nodoc
class _$SwapResultCopyWithImpl<$Res> implements $SwapResultCopyWith<$Res> {
  _$SwapResultCopyWithImpl(this._self, this._then);

  final SwapResult _self;
  final $Res Function(SwapResult) _then;

  /// Create a copy of SwapResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? base = null,
    Object? rel = null,
    Object? price = null,
    Object? volume = null,
    Object? orderType = null,
    Object? txHash = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      base: null == base
          ? _self.base
          : base // ignore: cast_nullable_to_non_nullable
              as String,
      rel: null == rel
          ? _self.rel
          : rel // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as Decimal,
      volume: null == volume
          ? _self.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as Decimal,
      orderType: null == orderType
          ? _self.orderType
          : orderType // ignore: cast_nullable_to_non_nullable
              as String,
      txHash: freezed == txHash
          ? _self.txHash
          : txHash // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SwapResult extends SwapResult {
  const _SwapResult(
      {required this.uuid,
      required this.base,
      required this.rel,
      @DecimalConverter() required this.price,
      @DecimalConverter() required this.volume,
      required this.orderType,
      this.txHash,
      this.createdAt})
      : super._();
  factory _SwapResult.fromJson(Map<String, dynamic> json) =>
      _$SwapResultFromJson(json);

  @override
  final String uuid;
  @override
  final String base;
  @override
  final String rel;
  @override
  @DecimalConverter()
  final Decimal price;
  @override
  @DecimalConverter()
  final Decimal volume;
  @override
  final String orderType;
  @override
  final String? txHash;
  @override
  final int? createdAt;

  /// Create a copy of SwapResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SwapResultCopyWith<_SwapResult> get copyWith =>
      __$SwapResultCopyWithImpl<_SwapResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SwapResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SwapResult &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.base, base) || other.base == base) &&
            (identical(other.rel, rel) || other.rel == rel) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.orderType, orderType) ||
                other.orderType == orderType) &&
            (identical(other.txHash, txHash) || other.txHash == txHash) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uuid, base, rel, price, volume,
      orderType, txHash, createdAt);

  @override
  String toString() {
    return 'SwapResult(uuid: $uuid, base: $base, rel: $rel, price: $price, volume: $volume, orderType: $orderType, txHash: $txHash, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$SwapResultCopyWith<$Res>
    implements $SwapResultCopyWith<$Res> {
  factory _$SwapResultCopyWith(
          _SwapResult value, $Res Function(_SwapResult) _then) =
      __$SwapResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String uuid,
      String base,
      String rel,
      @DecimalConverter() Decimal price,
      @DecimalConverter() Decimal volume,
      String orderType,
      String? txHash,
      int? createdAt});
}

/// @nodoc
class __$SwapResultCopyWithImpl<$Res> implements _$SwapResultCopyWith<$Res> {
  __$SwapResultCopyWithImpl(this._self, this._then);

  final _SwapResult _self;
  final $Res Function(_SwapResult) _then;

  /// Create a copy of SwapResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? uuid = null,
    Object? base = null,
    Object? rel = null,
    Object? price = null,
    Object? volume = null,
    Object? orderType = null,
    Object? txHash = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_SwapResult(
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      base: null == base
          ? _self.base
          : base // ignore: cast_nullable_to_non_nullable
              as String,
      rel: null == rel
          ? _self.rel
          : rel // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as Decimal,
      volume: null == volume
          ? _self.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as Decimal,
      orderType: null == orderType
          ? _self.orderType
          : orderType // ignore: cast_nullable_to_non_nullable
              as String,
      txHash: freezed == txHash
          ? _self.txHash
          : txHash // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
