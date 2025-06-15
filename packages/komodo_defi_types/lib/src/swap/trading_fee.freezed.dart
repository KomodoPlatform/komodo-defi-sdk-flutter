// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trading_fee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TradingFee {
  String get coin;
  @DecimalConverter()
  Decimal get amount;

  /// Create a copy of TradingFee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TradingFeeCopyWith<TradingFee> get copyWith =>
      _$TradingFeeCopyWithImpl<TradingFee>(this as TradingFee, _$identity);

  /// Serializes this TradingFee to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TradingFee &&
            (identical(other.coin, coin) || other.coin == coin) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, coin, amount);

  @override
  String toString() {
    return 'TradingFee(coin: $coin, amount: $amount)';
  }
}

/// @nodoc
abstract mixin class $TradingFeeCopyWith<$Res> {
  factory $TradingFeeCopyWith(
          TradingFee value, $Res Function(TradingFee) _then) =
      _$TradingFeeCopyWithImpl;
  @useResult
  $Res call({String coin, @DecimalConverter() Decimal amount});
}

/// @nodoc
class _$TradingFeeCopyWithImpl<$Res> implements $TradingFeeCopyWith<$Res> {
  _$TradingFeeCopyWithImpl(this._self, this._then);

  final TradingFee _self;
  final $Res Function(TradingFee) _then;

  /// Create a copy of TradingFee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coin = null,
    Object? amount = null,
  }) {
    return _then(_self.copyWith(
      coin: null == coin
          ? _self.coin
          : coin // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as Decimal,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _TradingFee extends TradingFee {
  const _TradingFee(
      {required this.coin, @DecimalConverter() required this.amount})
      : super._();
  factory _TradingFee.fromJson(Map<String, dynamic> json) =>
      _$TradingFeeFromJson(json);

  @override
  final String coin;
  @override
  @DecimalConverter()
  final Decimal amount;

  /// Create a copy of TradingFee
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TradingFeeCopyWith<_TradingFee> get copyWith =>
      __$TradingFeeCopyWithImpl<_TradingFee>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TradingFeeToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TradingFee &&
            (identical(other.coin, coin) || other.coin == coin) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, coin, amount);

  @override
  String toString() {
    return 'TradingFee(coin: $coin, amount: $amount)';
  }
}

/// @nodoc
abstract mixin class _$TradingFeeCopyWith<$Res>
    implements $TradingFeeCopyWith<$Res> {
  factory _$TradingFeeCopyWith(
          _TradingFee value, $Res Function(_TradingFee) _then) =
      __$TradingFeeCopyWithImpl;
  @override
  @useResult
  $Res call({String coin, @DecimalConverter() Decimal amount});
}

/// @nodoc
class __$TradingFeeCopyWithImpl<$Res> implements _$TradingFeeCopyWith<$Res> {
  __$TradingFeeCopyWithImpl(this._self, this._then);

  final _TradingFee _self;
  final $Res Function(_TradingFee) _then;

  /// Create a copy of TradingFee
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? coin = null,
    Object? amount = null,
  }) {
    return _then(_TradingFee(
      coin: null == coin
          ? _self.coin
          : coin // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as Decimal,
    ));
  }
}

// dart format on
