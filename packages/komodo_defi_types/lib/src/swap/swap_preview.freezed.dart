// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swap_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SwapPreview {
  TradingFee get baseCoinFee;
  TradingFee get relCoinFee;
  List<TradingFee> get totalFees;
  @DecimalConverter()
  Decimal get volume;
  TradingFee? get takerFee;
  TradingFee? get feeToSendTakerFee;

  /// Create a copy of SwapPreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SwapPreviewCopyWith<SwapPreview> get copyWith =>
      _$SwapPreviewCopyWithImpl<SwapPreview>(this as SwapPreview, _$identity);

  /// Serializes this SwapPreview to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SwapPreview &&
            (identical(other.baseCoinFee, baseCoinFee) ||
                other.baseCoinFee == baseCoinFee) &&
            (identical(other.relCoinFee, relCoinFee) ||
                other.relCoinFee == relCoinFee) &&
            const DeepCollectionEquality().equals(other.totalFees, totalFees) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.takerFee, takerFee) ||
                other.takerFee == takerFee) &&
            (identical(other.feeToSendTakerFee, feeToSendTakerFee) ||
                other.feeToSendTakerFee == feeToSendTakerFee));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      baseCoinFee,
      relCoinFee,
      const DeepCollectionEquality().hash(totalFees),
      volume,
      takerFee,
      feeToSendTakerFee);

  @override
  String toString() {
    return 'SwapPreview(baseCoinFee: $baseCoinFee, relCoinFee: $relCoinFee, totalFees: $totalFees, volume: $volume, takerFee: $takerFee, feeToSendTakerFee: $feeToSendTakerFee)';
  }
}

/// @nodoc
abstract mixin class $SwapPreviewCopyWith<$Res> {
  factory $SwapPreviewCopyWith(
          SwapPreview value, $Res Function(SwapPreview) _then) =
      _$SwapPreviewCopyWithImpl;
  @useResult
  $Res call(
      {TradingFee baseCoinFee,
      TradingFee relCoinFee,
      List<TradingFee> totalFees,
      @DecimalConverter() Decimal volume,
      TradingFee? takerFee,
      TradingFee? feeToSendTakerFee});

  $TradingFeeCopyWith<$Res> get baseCoinFee;
  $TradingFeeCopyWith<$Res> get relCoinFee;
  $TradingFeeCopyWith<$Res>? get takerFee;
  $TradingFeeCopyWith<$Res>? get feeToSendTakerFee;
}

/// @nodoc
class _$SwapPreviewCopyWithImpl<$Res> implements $SwapPreviewCopyWith<$Res> {
  _$SwapPreviewCopyWithImpl(this._self, this._then);

  final SwapPreview _self;
  final $Res Function(SwapPreview) _then;

  /// Create a copy of SwapPreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseCoinFee = null,
    Object? relCoinFee = null,
    Object? totalFees = null,
    Object? volume = null,
    Object? takerFee = freezed,
    Object? feeToSendTakerFee = freezed,
  }) {
    return _then(_self.copyWith(
      baseCoinFee: null == baseCoinFee
          ? _self.baseCoinFee
          : baseCoinFee // ignore: cast_nullable_to_non_nullable
              as TradingFee,
      relCoinFee: null == relCoinFee
          ? _self.relCoinFee
          : relCoinFee // ignore: cast_nullable_to_non_nullable
              as TradingFee,
      totalFees: null == totalFees
          ? _self.totalFees
          : totalFees // ignore: cast_nullable_to_non_nullable
              as List<TradingFee>,
      volume: null == volume
          ? _self.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as Decimal,
      takerFee: freezed == takerFee
          ? _self.takerFee
          : takerFee // ignore: cast_nullable_to_non_nullable
              as TradingFee?,
      feeToSendTakerFee: freezed == feeToSendTakerFee
          ? _self.feeToSendTakerFee
          : feeToSendTakerFee // ignore: cast_nullable_to_non_nullable
              as TradingFee?,
    ));
  }

  /// Create a copy of SwapPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TradingFeeCopyWith<$Res> get baseCoinFee {
    return $TradingFeeCopyWith<$Res>(_self.baseCoinFee, (value) {
      return _then(_self.copyWith(baseCoinFee: value));
    });
  }

  /// Create a copy of SwapPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TradingFeeCopyWith<$Res> get relCoinFee {
    return $TradingFeeCopyWith<$Res>(_self.relCoinFee, (value) {
      return _then(_self.copyWith(relCoinFee: value));
    });
  }

  /// Create a copy of SwapPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TradingFeeCopyWith<$Res>? get takerFee {
    if (_self.takerFee == null) {
      return null;
    }

    return $TradingFeeCopyWith<$Res>(_self.takerFee!, (value) {
      return _then(_self.copyWith(takerFee: value));
    });
  }

  /// Create a copy of SwapPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TradingFeeCopyWith<$Res>? get feeToSendTakerFee {
    if (_self.feeToSendTakerFee == null) {
      return null;
    }

    return $TradingFeeCopyWith<$Res>(_self.feeToSendTakerFee!, (value) {
      return _then(_self.copyWith(feeToSendTakerFee: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SwapPreview extends SwapPreview {
  const _SwapPreview(
      {required this.baseCoinFee,
      required this.relCoinFee,
      required final List<TradingFee> totalFees,
      @DecimalConverter() required this.volume,
      this.takerFee,
      this.feeToSendTakerFee})
      : _totalFees = totalFees,
        super._();
  factory _SwapPreview.fromJson(Map<String, dynamic> json) =>
      _$SwapPreviewFromJson(json);

  @override
  final TradingFee baseCoinFee;
  @override
  final TradingFee relCoinFee;
  final List<TradingFee> _totalFees;
  @override
  List<TradingFee> get totalFees {
    if (_totalFees is EqualUnmodifiableListView) return _totalFees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_totalFees);
  }

  @override
  @DecimalConverter()
  final Decimal volume;
  @override
  final TradingFee? takerFee;
  @override
  final TradingFee? feeToSendTakerFee;

  /// Create a copy of SwapPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SwapPreviewCopyWith<_SwapPreview> get copyWith =>
      __$SwapPreviewCopyWithImpl<_SwapPreview>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SwapPreviewToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SwapPreview &&
            (identical(other.baseCoinFee, baseCoinFee) ||
                other.baseCoinFee == baseCoinFee) &&
            (identical(other.relCoinFee, relCoinFee) ||
                other.relCoinFee == relCoinFee) &&
            const DeepCollectionEquality()
                .equals(other._totalFees, _totalFees) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.takerFee, takerFee) ||
                other.takerFee == takerFee) &&
            (identical(other.feeToSendTakerFee, feeToSendTakerFee) ||
                other.feeToSendTakerFee == feeToSendTakerFee));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      baseCoinFee,
      relCoinFee,
      const DeepCollectionEquality().hash(_totalFees),
      volume,
      takerFee,
      feeToSendTakerFee);

  @override
  String toString() {
    return 'SwapPreview(baseCoinFee: $baseCoinFee, relCoinFee: $relCoinFee, totalFees: $totalFees, volume: $volume, takerFee: $takerFee, feeToSendTakerFee: $feeToSendTakerFee)';
  }
}

/// @nodoc
abstract mixin class _$SwapPreviewCopyWith<$Res>
    implements $SwapPreviewCopyWith<$Res> {
  factory _$SwapPreviewCopyWith(
          _SwapPreview value, $Res Function(_SwapPreview) _then) =
      __$SwapPreviewCopyWithImpl;
  @override
  @useResult
  $Res call(
      {TradingFee baseCoinFee,
      TradingFee relCoinFee,
      List<TradingFee> totalFees,
      @DecimalConverter() Decimal volume,
      TradingFee? takerFee,
      TradingFee? feeToSendTakerFee});

  @override
  $TradingFeeCopyWith<$Res> get baseCoinFee;
  @override
  $TradingFeeCopyWith<$Res> get relCoinFee;
  @override
  $TradingFeeCopyWith<$Res>? get takerFee;
  @override
  $TradingFeeCopyWith<$Res>? get feeToSendTakerFee;
}

/// @nodoc
class __$SwapPreviewCopyWithImpl<$Res> implements _$SwapPreviewCopyWith<$Res> {
  __$SwapPreviewCopyWithImpl(this._self, this._then);

  final _SwapPreview _self;
  final $Res Function(_SwapPreview) _then;

  /// Create a copy of SwapPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? baseCoinFee = null,
    Object? relCoinFee = null,
    Object? totalFees = null,
    Object? volume = null,
    Object? takerFee = freezed,
    Object? feeToSendTakerFee = freezed,
  }) {
    return _then(_SwapPreview(
      baseCoinFee: null == baseCoinFee
          ? _self.baseCoinFee
          : baseCoinFee // ignore: cast_nullable_to_non_nullable
              as TradingFee,
      relCoinFee: null == relCoinFee
          ? _self.relCoinFee
          : relCoinFee // ignore: cast_nullable_to_non_nullable
              as TradingFee,
      totalFees: null == totalFees
          ? _self._totalFees
          : totalFees // ignore: cast_nullable_to_non_nullable
              as List<TradingFee>,
      volume: null == volume
          ? _self.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as Decimal,
      takerFee: freezed == takerFee
          ? _self.takerFee
          : takerFee // ignore: cast_nullable_to_non_nullable
              as TradingFee?,
      feeToSendTakerFee: freezed == feeToSendTakerFee
          ? _self.feeToSendTakerFee
          : feeToSendTakerFee // ignore: cast_nullable_to_non_nullable
              as TradingFee?,
    ));
  }

  /// Create a copy of SwapPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TradingFeeCopyWith<$Res> get baseCoinFee {
    return $TradingFeeCopyWith<$Res>(_self.baseCoinFee, (value) {
      return _then(_self.copyWith(baseCoinFee: value));
    });
  }

  /// Create a copy of SwapPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TradingFeeCopyWith<$Res> get relCoinFee {
    return $TradingFeeCopyWith<$Res>(_self.relCoinFee, (value) {
      return _then(_self.copyWith(relCoinFee: value));
    });
  }

  /// Create a copy of SwapPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TradingFeeCopyWith<$Res>? get takerFee {
    if (_self.takerFee == null) {
      return null;
    }

    return $TradingFeeCopyWith<$Res>(_self.takerFee!, (value) {
      return _then(_self.copyWith(takerFee: value));
    });
  }

  /// Create a copy of SwapPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TradingFeeCopyWith<$Res>? get feeToSendTakerFee {
    if (_self.feeToSendTakerFee == null) {
      return null;
    }

    return $TradingFeeCopyWith<$Res>(_self.feeToSendTakerFee!, (value) {
      return _then(_self.copyWith(feeToSendTakerFee: value));
    });
  }
}

// dart format on
