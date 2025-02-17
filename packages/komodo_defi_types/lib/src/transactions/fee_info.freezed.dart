// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fee_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeeInfo {
  /// Which coin pays the fee
  String get coin => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String coin, Decimal amount) utxoFixed,
    required TResult Function(String coin, Decimal amount) utxoPerKbyte,
    required TResult Function(String coin, Decimal gasPrice, int gas) ethGas,
    required TResult Function(String coin, Decimal gasPrice, int gasLimit)
        qrc20Gas,
    required TResult Function(String coin, Decimal gasPrice, int gasLimit)
        cosmosGas,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String coin, Decimal amount)? utxoFixed,
    TResult? Function(String coin, Decimal amount)? utxoPerKbyte,
    TResult? Function(String coin, Decimal gasPrice, int gas)? ethGas,
    TResult? Function(String coin, Decimal gasPrice, int gasLimit)? qrc20Gas,
    TResult? Function(String coin, Decimal gasPrice, int gasLimit)? cosmosGas,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String coin, Decimal amount)? utxoFixed,
    TResult Function(String coin, Decimal amount)? utxoPerKbyte,
    TResult Function(String coin, Decimal gasPrice, int gas)? ethGas,
    TResult Function(String coin, Decimal gasPrice, int gasLimit)? qrc20Gas,
    TResult Function(String coin, Decimal gasPrice, int gasLimit)? cosmosGas,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FeeInfoUtxoFixed value) utxoFixed,
    required TResult Function(FeeInfoUtxoPerKbyte value) utxoPerKbyte,
    required TResult Function(FeeInfoEthGas value) ethGas,
    required TResult Function(FeeInfoQrc20Gas value) qrc20Gas,
    required TResult Function(FeeInfoCosmosGas value) cosmosGas,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult? Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult? Function(FeeInfoEthGas value)? ethGas,
    TResult? Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult? Function(FeeInfoCosmosGas value)? cosmosGas,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult Function(FeeInfoEthGas value)? ethGas,
    TResult Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult Function(FeeInfoCosmosGas value)? cosmosGas,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeeInfoCopyWith<FeeInfo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeeInfoCopyWith<$Res> {
  factory $FeeInfoCopyWith(FeeInfo value, $Res Function(FeeInfo) then) =
      _$FeeInfoCopyWithImpl<$Res, FeeInfo>;
  @useResult
  $Res call({String coin});
}

/// @nodoc
class _$FeeInfoCopyWithImpl<$Res, $Val extends FeeInfo>
    implements $FeeInfoCopyWith<$Res> {
  _$FeeInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coin = null,
  }) {
    return _then(_value.copyWith(
      coin: null == coin
          ? _value.coin
          : coin // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeeInfoUtxoFixedImplCopyWith<$Res>
    implements $FeeInfoCopyWith<$Res> {
  factory _$$FeeInfoUtxoFixedImplCopyWith(_$FeeInfoUtxoFixedImpl value,
          $Res Function(_$FeeInfoUtxoFixedImpl) then) =
      __$$FeeInfoUtxoFixedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String coin, Decimal amount});
}

/// @nodoc
class __$$FeeInfoUtxoFixedImplCopyWithImpl<$Res>
    extends _$FeeInfoCopyWithImpl<$Res, _$FeeInfoUtxoFixedImpl>
    implements _$$FeeInfoUtxoFixedImplCopyWith<$Res> {
  __$$FeeInfoUtxoFixedImplCopyWithImpl(_$FeeInfoUtxoFixedImpl _value,
      $Res Function(_$FeeInfoUtxoFixedImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coin = null,
    Object? amount = null,
  }) {
    return _then(_$FeeInfoUtxoFixedImpl(
      coin: null == coin
          ? _value.coin
          : coin // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as Decimal,
    ));
  }
}

/// @nodoc

class _$FeeInfoUtxoFixedImpl extends FeeInfoUtxoFixed {
  const _$FeeInfoUtxoFixedImpl({required this.coin, required this.amount})
      : super._();

  /// Which coin pays the fee
  @override
  final String coin;

  /// The fee amount in coin units
  @override
  final Decimal amount;

  @override
  String toString() {
    return 'FeeInfo.utxoFixed(coin: $coin, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeInfoUtxoFixedImpl &&
            (identical(other.coin, coin) || other.coin == coin) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, coin, amount);

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeInfoUtxoFixedImplCopyWith<_$FeeInfoUtxoFixedImpl> get copyWith =>
      __$$FeeInfoUtxoFixedImplCopyWithImpl<_$FeeInfoUtxoFixedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String coin, Decimal amount) utxoFixed,
    required TResult Function(String coin, Decimal amount) utxoPerKbyte,
    required TResult Function(String coin, Decimal gasPrice, int gas) ethGas,
    required TResult Function(String coin, Decimal gasPrice, int gasLimit)
        qrc20Gas,
    required TResult Function(String coin, Decimal gasPrice, int gasLimit)
        cosmosGas,
  }) {
    return utxoFixed(coin, amount);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String coin, Decimal amount)? utxoFixed,
    TResult? Function(String coin, Decimal amount)? utxoPerKbyte,
    TResult? Function(String coin, Decimal gasPrice, int gas)? ethGas,
    TResult? Function(String coin, Decimal gasPrice, int gasLimit)? qrc20Gas,
    TResult? Function(String coin, Decimal gasPrice, int gasLimit)? cosmosGas,
  }) {
    return utxoFixed?.call(coin, amount);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String coin, Decimal amount)? utxoFixed,
    TResult Function(String coin, Decimal amount)? utxoPerKbyte,
    TResult Function(String coin, Decimal gasPrice, int gas)? ethGas,
    TResult Function(String coin, Decimal gasPrice, int gasLimit)? qrc20Gas,
    TResult Function(String coin, Decimal gasPrice, int gasLimit)? cosmosGas,
    required TResult orElse(),
  }) {
    if (utxoFixed != null) {
      return utxoFixed(coin, amount);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FeeInfoUtxoFixed value) utxoFixed,
    required TResult Function(FeeInfoUtxoPerKbyte value) utxoPerKbyte,
    required TResult Function(FeeInfoEthGas value) ethGas,
    required TResult Function(FeeInfoQrc20Gas value) qrc20Gas,
    required TResult Function(FeeInfoCosmosGas value) cosmosGas,
  }) {
    return utxoFixed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult? Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult? Function(FeeInfoEthGas value)? ethGas,
    TResult? Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult? Function(FeeInfoCosmosGas value)? cosmosGas,
  }) {
    return utxoFixed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult Function(FeeInfoEthGas value)? ethGas,
    TResult Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult Function(FeeInfoCosmosGas value)? cosmosGas,
    required TResult orElse(),
  }) {
    if (utxoFixed != null) {
      return utxoFixed(this);
    }
    return orElse();
  }
}

abstract class FeeInfoUtxoFixed extends FeeInfo {
  const factory FeeInfoUtxoFixed(
      {required final String coin,
      required final Decimal amount}) = _$FeeInfoUtxoFixedImpl;
  const FeeInfoUtxoFixed._() : super._();

  /// Which coin pays the fee
  @override
  String get coin;

  /// The fee amount in coin units
  Decimal get amount;

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeInfoUtxoFixedImplCopyWith<_$FeeInfoUtxoFixedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FeeInfoUtxoPerKbyteImplCopyWith<$Res>
    implements $FeeInfoCopyWith<$Res> {
  factory _$$FeeInfoUtxoPerKbyteImplCopyWith(_$FeeInfoUtxoPerKbyteImpl value,
          $Res Function(_$FeeInfoUtxoPerKbyteImpl) then) =
      __$$FeeInfoUtxoPerKbyteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String coin, Decimal amount});
}

/// @nodoc
class __$$FeeInfoUtxoPerKbyteImplCopyWithImpl<$Res>
    extends _$FeeInfoCopyWithImpl<$Res, _$FeeInfoUtxoPerKbyteImpl>
    implements _$$FeeInfoUtxoPerKbyteImplCopyWith<$Res> {
  __$$FeeInfoUtxoPerKbyteImplCopyWithImpl(_$FeeInfoUtxoPerKbyteImpl _value,
      $Res Function(_$FeeInfoUtxoPerKbyteImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coin = null,
    Object? amount = null,
  }) {
    return _then(_$FeeInfoUtxoPerKbyteImpl(
      coin: null == coin
          ? _value.coin
          : coin // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as Decimal,
    ));
  }
}

/// @nodoc

class _$FeeInfoUtxoPerKbyteImpl extends FeeInfoUtxoPerKbyte {
  const _$FeeInfoUtxoPerKbyteImpl({required this.coin, required this.amount})
      : super._();

  @override
  final String coin;
  @override
  final Decimal amount;

  @override
  String toString() {
    return 'FeeInfo.utxoPerKbyte(coin: $coin, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeInfoUtxoPerKbyteImpl &&
            (identical(other.coin, coin) || other.coin == coin) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, coin, amount);

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeInfoUtxoPerKbyteImplCopyWith<_$FeeInfoUtxoPerKbyteImpl> get copyWith =>
      __$$FeeInfoUtxoPerKbyteImplCopyWithImpl<_$FeeInfoUtxoPerKbyteImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String coin, Decimal amount) utxoFixed,
    required TResult Function(String coin, Decimal amount) utxoPerKbyte,
    required TResult Function(String coin, Decimal gasPrice, int gas) ethGas,
    required TResult Function(String coin, Decimal gasPrice, int gasLimit)
        qrc20Gas,
    required TResult Function(String coin, Decimal gasPrice, int gasLimit)
        cosmosGas,
  }) {
    return utxoPerKbyte(coin, amount);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String coin, Decimal amount)? utxoFixed,
    TResult? Function(String coin, Decimal amount)? utxoPerKbyte,
    TResult? Function(String coin, Decimal gasPrice, int gas)? ethGas,
    TResult? Function(String coin, Decimal gasPrice, int gasLimit)? qrc20Gas,
    TResult? Function(String coin, Decimal gasPrice, int gasLimit)? cosmosGas,
  }) {
    return utxoPerKbyte?.call(coin, amount);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String coin, Decimal amount)? utxoFixed,
    TResult Function(String coin, Decimal amount)? utxoPerKbyte,
    TResult Function(String coin, Decimal gasPrice, int gas)? ethGas,
    TResult Function(String coin, Decimal gasPrice, int gasLimit)? qrc20Gas,
    TResult Function(String coin, Decimal gasPrice, int gasLimit)? cosmosGas,
    required TResult orElse(),
  }) {
    if (utxoPerKbyte != null) {
      return utxoPerKbyte(coin, amount);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FeeInfoUtxoFixed value) utxoFixed,
    required TResult Function(FeeInfoUtxoPerKbyte value) utxoPerKbyte,
    required TResult Function(FeeInfoEthGas value) ethGas,
    required TResult Function(FeeInfoQrc20Gas value) qrc20Gas,
    required TResult Function(FeeInfoCosmosGas value) cosmosGas,
  }) {
    return utxoPerKbyte(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult? Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult? Function(FeeInfoEthGas value)? ethGas,
    TResult? Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult? Function(FeeInfoCosmosGas value)? cosmosGas,
  }) {
    return utxoPerKbyte?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult Function(FeeInfoEthGas value)? ethGas,
    TResult Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult Function(FeeInfoCosmosGas value)? cosmosGas,
    required TResult orElse(),
  }) {
    if (utxoPerKbyte != null) {
      return utxoPerKbyte(this);
    }
    return orElse();
  }
}

abstract class FeeInfoUtxoPerKbyte extends FeeInfo {
  const factory FeeInfoUtxoPerKbyte(
      {required final String coin,
      required final Decimal amount}) = _$FeeInfoUtxoPerKbyteImpl;
  const FeeInfoUtxoPerKbyte._() : super._();

  @override
  String get coin;
  Decimal get amount;

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeInfoUtxoPerKbyteImplCopyWith<_$FeeInfoUtxoPerKbyteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FeeInfoEthGasImplCopyWith<$Res>
    implements $FeeInfoCopyWith<$Res> {
  factory _$$FeeInfoEthGasImplCopyWith(
          _$FeeInfoEthGasImpl value, $Res Function(_$FeeInfoEthGasImpl) then) =
      __$$FeeInfoEthGasImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String coin, Decimal gasPrice, int gas});
}

/// @nodoc
class __$$FeeInfoEthGasImplCopyWithImpl<$Res>
    extends _$FeeInfoCopyWithImpl<$Res, _$FeeInfoEthGasImpl>
    implements _$$FeeInfoEthGasImplCopyWith<$Res> {
  __$$FeeInfoEthGasImplCopyWithImpl(
      _$FeeInfoEthGasImpl _value, $Res Function(_$FeeInfoEthGasImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coin = null,
    Object? gasPrice = null,
    Object? gas = null,
  }) {
    return _then(_$FeeInfoEthGasImpl(
      coin: null == coin
          ? _value.coin
          : coin // ignore: cast_nullable_to_non_nullable
              as String,
      gasPrice: null == gasPrice
          ? _value.gasPrice
          : gasPrice // ignore: cast_nullable_to_non_nullable
              as Decimal,
      gas: null == gas
          ? _value.gas
          : gas // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$FeeInfoEthGasImpl extends FeeInfoEthGas {
  const _$FeeInfoEthGasImpl(
      {required this.coin, required this.gasPrice, required this.gas})
      : super._();

  @override
  final String coin;

  /// Gas price in ETH. e.g. "0.000000003" => 3 Gwei
  @override
  final Decimal gasPrice;

  /// Gas limit (number of gas units)
  @override
  final int gas;

  @override
  String toString() {
    return 'FeeInfo.ethGas(coin: $coin, gasPrice: $gasPrice, gas: $gas)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeInfoEthGasImpl &&
            (identical(other.coin, coin) || other.coin == coin) &&
            (identical(other.gasPrice, gasPrice) ||
                other.gasPrice == gasPrice) &&
            (identical(other.gas, gas) || other.gas == gas));
  }

  @override
  int get hashCode => Object.hash(runtimeType, coin, gasPrice, gas);

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeInfoEthGasImplCopyWith<_$FeeInfoEthGasImpl> get copyWith =>
      __$$FeeInfoEthGasImplCopyWithImpl<_$FeeInfoEthGasImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String coin, Decimal amount) utxoFixed,
    required TResult Function(String coin, Decimal amount) utxoPerKbyte,
    required TResult Function(String coin, Decimal gasPrice, int gas) ethGas,
    required TResult Function(String coin, Decimal gasPrice, int gasLimit)
        qrc20Gas,
    required TResult Function(String coin, Decimal gasPrice, int gasLimit)
        cosmosGas,
  }) {
    return ethGas(coin, gasPrice, gas);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String coin, Decimal amount)? utxoFixed,
    TResult? Function(String coin, Decimal amount)? utxoPerKbyte,
    TResult? Function(String coin, Decimal gasPrice, int gas)? ethGas,
    TResult? Function(String coin, Decimal gasPrice, int gasLimit)? qrc20Gas,
    TResult? Function(String coin, Decimal gasPrice, int gasLimit)? cosmosGas,
  }) {
    return ethGas?.call(coin, gasPrice, gas);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String coin, Decimal amount)? utxoFixed,
    TResult Function(String coin, Decimal amount)? utxoPerKbyte,
    TResult Function(String coin, Decimal gasPrice, int gas)? ethGas,
    TResult Function(String coin, Decimal gasPrice, int gasLimit)? qrc20Gas,
    TResult Function(String coin, Decimal gasPrice, int gasLimit)? cosmosGas,
    required TResult orElse(),
  }) {
    if (ethGas != null) {
      return ethGas(coin, gasPrice, gas);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FeeInfoUtxoFixed value) utxoFixed,
    required TResult Function(FeeInfoUtxoPerKbyte value) utxoPerKbyte,
    required TResult Function(FeeInfoEthGas value) ethGas,
    required TResult Function(FeeInfoQrc20Gas value) qrc20Gas,
    required TResult Function(FeeInfoCosmosGas value) cosmosGas,
  }) {
    return ethGas(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult? Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult? Function(FeeInfoEthGas value)? ethGas,
    TResult? Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult? Function(FeeInfoCosmosGas value)? cosmosGas,
  }) {
    return ethGas?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult Function(FeeInfoEthGas value)? ethGas,
    TResult Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult Function(FeeInfoCosmosGas value)? cosmosGas,
    required TResult orElse(),
  }) {
    if (ethGas != null) {
      return ethGas(this);
    }
    return orElse();
  }
}

abstract class FeeInfoEthGas extends FeeInfo {
  const factory FeeInfoEthGas(
      {required final String coin,
      required final Decimal gasPrice,
      required final int gas}) = _$FeeInfoEthGasImpl;
  const FeeInfoEthGas._() : super._();

  @override
  String get coin;

  /// Gas price in ETH. e.g. "0.000000003" => 3 Gwei
  Decimal get gasPrice;

  /// Gas limit (number of gas units)
  int get gas;

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeInfoEthGasImplCopyWith<_$FeeInfoEthGasImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FeeInfoQrc20GasImplCopyWith<$Res>
    implements $FeeInfoCopyWith<$Res> {
  factory _$$FeeInfoQrc20GasImplCopyWith(_$FeeInfoQrc20GasImpl value,
          $Res Function(_$FeeInfoQrc20GasImpl) then) =
      __$$FeeInfoQrc20GasImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String coin, Decimal gasPrice, int gasLimit});
}

/// @nodoc
class __$$FeeInfoQrc20GasImplCopyWithImpl<$Res>
    extends _$FeeInfoCopyWithImpl<$Res, _$FeeInfoQrc20GasImpl>
    implements _$$FeeInfoQrc20GasImplCopyWith<$Res> {
  __$$FeeInfoQrc20GasImplCopyWithImpl(
      _$FeeInfoQrc20GasImpl _value, $Res Function(_$FeeInfoQrc20GasImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coin = null,
    Object? gasPrice = null,
    Object? gasLimit = null,
  }) {
    return _then(_$FeeInfoQrc20GasImpl(
      coin: null == coin
          ? _value.coin
          : coin // ignore: cast_nullable_to_non_nullable
              as String,
      gasPrice: null == gasPrice
          ? _value.gasPrice
          : gasPrice // ignore: cast_nullable_to_non_nullable
              as Decimal,
      gasLimit: null == gasLimit
          ? _value.gasLimit
          : gasLimit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$FeeInfoQrc20GasImpl extends FeeInfoQrc20Gas {
  const _$FeeInfoQrc20GasImpl(
      {required this.coin, required this.gasPrice, required this.gasLimit})
      : super._();

  @override
  final String coin;

  /// Gas price in coin units. e.g. "0.000000004"
  @override
  final Decimal gasPrice;

  /// Gas limit
  @override
  final int gasLimit;

  @override
  String toString() {
    return 'FeeInfo.qrc20Gas(coin: $coin, gasPrice: $gasPrice, gasLimit: $gasLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeInfoQrc20GasImpl &&
            (identical(other.coin, coin) || other.coin == coin) &&
            (identical(other.gasPrice, gasPrice) ||
                other.gasPrice == gasPrice) &&
            (identical(other.gasLimit, gasLimit) ||
                other.gasLimit == gasLimit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, coin, gasPrice, gasLimit);

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeInfoQrc20GasImplCopyWith<_$FeeInfoQrc20GasImpl> get copyWith =>
      __$$FeeInfoQrc20GasImplCopyWithImpl<_$FeeInfoQrc20GasImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String coin, Decimal amount) utxoFixed,
    required TResult Function(String coin, Decimal amount) utxoPerKbyte,
    required TResult Function(String coin, Decimal gasPrice, int gas) ethGas,
    required TResult Function(String coin, Decimal gasPrice, int gasLimit)
        qrc20Gas,
    required TResult Function(String coin, Decimal gasPrice, int gasLimit)
        cosmosGas,
  }) {
    return qrc20Gas(coin, gasPrice, gasLimit);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String coin, Decimal amount)? utxoFixed,
    TResult? Function(String coin, Decimal amount)? utxoPerKbyte,
    TResult? Function(String coin, Decimal gasPrice, int gas)? ethGas,
    TResult? Function(String coin, Decimal gasPrice, int gasLimit)? qrc20Gas,
    TResult? Function(String coin, Decimal gasPrice, int gasLimit)? cosmosGas,
  }) {
    return qrc20Gas?.call(coin, gasPrice, gasLimit);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String coin, Decimal amount)? utxoFixed,
    TResult Function(String coin, Decimal amount)? utxoPerKbyte,
    TResult Function(String coin, Decimal gasPrice, int gas)? ethGas,
    TResult Function(String coin, Decimal gasPrice, int gasLimit)? qrc20Gas,
    TResult Function(String coin, Decimal gasPrice, int gasLimit)? cosmosGas,
    required TResult orElse(),
  }) {
    if (qrc20Gas != null) {
      return qrc20Gas(coin, gasPrice, gasLimit);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FeeInfoUtxoFixed value) utxoFixed,
    required TResult Function(FeeInfoUtxoPerKbyte value) utxoPerKbyte,
    required TResult Function(FeeInfoEthGas value) ethGas,
    required TResult Function(FeeInfoQrc20Gas value) qrc20Gas,
    required TResult Function(FeeInfoCosmosGas value) cosmosGas,
  }) {
    return qrc20Gas(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult? Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult? Function(FeeInfoEthGas value)? ethGas,
    TResult? Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult? Function(FeeInfoCosmosGas value)? cosmosGas,
  }) {
    return qrc20Gas?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult Function(FeeInfoEthGas value)? ethGas,
    TResult Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult Function(FeeInfoCosmosGas value)? cosmosGas,
    required TResult orElse(),
  }) {
    if (qrc20Gas != null) {
      return qrc20Gas(this);
    }
    return orElse();
  }
}

abstract class FeeInfoQrc20Gas extends FeeInfo {
  const factory FeeInfoQrc20Gas(
      {required final String coin,
      required final Decimal gasPrice,
      required final int gasLimit}) = _$FeeInfoQrc20GasImpl;
  const FeeInfoQrc20Gas._() : super._();

  @override
  String get coin;

  /// Gas price in coin units. e.g. "0.000000004"
  Decimal get gasPrice;

  /// Gas limit
  int get gasLimit;

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeInfoQrc20GasImplCopyWith<_$FeeInfoQrc20GasImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FeeInfoCosmosGasImplCopyWith<$Res>
    implements $FeeInfoCopyWith<$Res> {
  factory _$$FeeInfoCosmosGasImplCopyWith(_$FeeInfoCosmosGasImpl value,
          $Res Function(_$FeeInfoCosmosGasImpl) then) =
      __$$FeeInfoCosmosGasImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String coin, Decimal gasPrice, int gasLimit});
}

/// @nodoc
class __$$FeeInfoCosmosGasImplCopyWithImpl<$Res>
    extends _$FeeInfoCopyWithImpl<$Res, _$FeeInfoCosmosGasImpl>
    implements _$$FeeInfoCosmosGasImplCopyWith<$Res> {
  __$$FeeInfoCosmosGasImplCopyWithImpl(_$FeeInfoCosmosGasImpl _value,
      $Res Function(_$FeeInfoCosmosGasImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coin = null,
    Object? gasPrice = null,
    Object? gasLimit = null,
  }) {
    return _then(_$FeeInfoCosmosGasImpl(
      coin: null == coin
          ? _value.coin
          : coin // ignore: cast_nullable_to_non_nullable
              as String,
      gasPrice: null == gasPrice
          ? _value.gasPrice
          : gasPrice // ignore: cast_nullable_to_non_nullable
              as Decimal,
      gasLimit: null == gasLimit
          ? _value.gasLimit
          : gasLimit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$FeeInfoCosmosGasImpl extends FeeInfoCosmosGas {
  const _$FeeInfoCosmosGasImpl(
      {required this.coin, required this.gasPrice, required this.gasLimit})
      : super._();

  @override
  final String coin;

  /// Gas price in coin units. e.g. "0.05"
  @override
  final Decimal gasPrice;

  /// Gas limit
  @override
  final int gasLimit;

  @override
  String toString() {
    return 'FeeInfo.cosmosGas(coin: $coin, gasPrice: $gasPrice, gasLimit: $gasLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeeInfoCosmosGasImpl &&
            (identical(other.coin, coin) || other.coin == coin) &&
            (identical(other.gasPrice, gasPrice) ||
                other.gasPrice == gasPrice) &&
            (identical(other.gasLimit, gasLimit) ||
                other.gasLimit == gasLimit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, coin, gasPrice, gasLimit);

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeeInfoCosmosGasImplCopyWith<_$FeeInfoCosmosGasImpl> get copyWith =>
      __$$FeeInfoCosmosGasImplCopyWithImpl<_$FeeInfoCosmosGasImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String coin, Decimal amount) utxoFixed,
    required TResult Function(String coin, Decimal amount) utxoPerKbyte,
    required TResult Function(String coin, Decimal gasPrice, int gas) ethGas,
    required TResult Function(String coin, Decimal gasPrice, int gasLimit)
        qrc20Gas,
    required TResult Function(String coin, Decimal gasPrice, int gasLimit)
        cosmosGas,
  }) {
    return cosmosGas(coin, gasPrice, gasLimit);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String coin, Decimal amount)? utxoFixed,
    TResult? Function(String coin, Decimal amount)? utxoPerKbyte,
    TResult? Function(String coin, Decimal gasPrice, int gas)? ethGas,
    TResult? Function(String coin, Decimal gasPrice, int gasLimit)? qrc20Gas,
    TResult? Function(String coin, Decimal gasPrice, int gasLimit)? cosmosGas,
  }) {
    return cosmosGas?.call(coin, gasPrice, gasLimit);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String coin, Decimal amount)? utxoFixed,
    TResult Function(String coin, Decimal amount)? utxoPerKbyte,
    TResult Function(String coin, Decimal gasPrice, int gas)? ethGas,
    TResult Function(String coin, Decimal gasPrice, int gasLimit)? qrc20Gas,
    TResult Function(String coin, Decimal gasPrice, int gasLimit)? cosmosGas,
    required TResult orElse(),
  }) {
    if (cosmosGas != null) {
      return cosmosGas(coin, gasPrice, gasLimit);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FeeInfoUtxoFixed value) utxoFixed,
    required TResult Function(FeeInfoUtxoPerKbyte value) utxoPerKbyte,
    required TResult Function(FeeInfoEthGas value) ethGas,
    required TResult Function(FeeInfoQrc20Gas value) qrc20Gas,
    required TResult Function(FeeInfoCosmosGas value) cosmosGas,
  }) {
    return cosmosGas(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult? Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult? Function(FeeInfoEthGas value)? ethGas,
    TResult? Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult? Function(FeeInfoCosmosGas value)? cosmosGas,
  }) {
    return cosmosGas?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FeeInfoUtxoFixed value)? utxoFixed,
    TResult Function(FeeInfoUtxoPerKbyte value)? utxoPerKbyte,
    TResult Function(FeeInfoEthGas value)? ethGas,
    TResult Function(FeeInfoQrc20Gas value)? qrc20Gas,
    TResult Function(FeeInfoCosmosGas value)? cosmosGas,
    required TResult orElse(),
  }) {
    if (cosmosGas != null) {
      return cosmosGas(this);
    }
    return orElse();
  }
}

abstract class FeeInfoCosmosGas extends FeeInfo {
  const factory FeeInfoCosmosGas(
      {required final String coin,
      required final Decimal gasPrice,
      required final int gasLimit}) = _$FeeInfoCosmosGasImpl;
  const FeeInfoCosmosGas._() : super._();

  @override
  String get coin;

  /// Gas price in coin units. e.g. "0.05"
  Decimal get gasPrice;

  /// Gas limit
  int get gasLimit;

  /// Create a copy of FeeInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeeInfoCosmosGasImplCopyWith<_$FeeInfoCosmosGasImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
