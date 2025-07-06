// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
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
  TrezorUserActionType get actionType;
  String? get pin;
  String? get passphrase;

  /// Create a copy of TrezorUserActionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TrezorUserActionDataCopyWith<TrezorUserActionData> get copyWith =>
      _$TrezorUserActionDataCopyWithImpl<TrezorUserActionData>(
          this as TrezorUserActionData, _$identity);

  /// Serializes this TrezorUserActionData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TrezorUserActionData &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.pin, pin) || other.pin == pin) &&
            (identical(other.passphrase, passphrase) ||
                other.passphrase == passphrase));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, actionType, pin, passphrase);

  @override
  String toString() {
    return 'TrezorUserActionData(actionType: $actionType, pin: $pin, passphrase: $passphrase)';
  }
}

/// @nodoc
abstract mixin class $TrezorUserActionDataCopyWith<$Res> {
  factory $TrezorUserActionDataCopyWith(TrezorUserActionData value,
          $Res Function(TrezorUserActionData) _then) =
      _$TrezorUserActionDataCopyWithImpl;
  @useResult
  $Res call({TrezorUserActionType actionType, String? pin, String? passphrase});
}

/// @nodoc
class _$TrezorUserActionDataCopyWithImpl<$Res>
    implements $TrezorUserActionDataCopyWith<$Res> {
  _$TrezorUserActionDataCopyWithImpl(this._self, this._then);

  final TrezorUserActionData _self;
  final $Res Function(TrezorUserActionData) _then;

  /// Create a copy of TrezorUserActionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actionType = null,
    Object? pin = freezed,
    Object? passphrase = freezed,
  }) {
    return _then(_self.copyWith(
      actionType: null == actionType
          ? _self.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as TrezorUserActionType,
      pin: freezed == pin
          ? _self.pin
          : pin // ignore: cast_nullable_to_non_nullable
              as String?,
      passphrase: freezed == passphrase
          ? _self.passphrase
          : passphrase // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [TrezorUserActionData].
extension TrezorUserActionDataPatterns on TrezorUserActionData {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TrezorUserActionData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TrezorUserActionData() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TrezorUserActionData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrezorUserActionData():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TrezorUserActionData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrezorUserActionData() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            TrezorUserActionType actionType, String? pin, String? passphrase)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TrezorUserActionData() when $default != null:
        return $default(_that.actionType, _that.pin, _that.passphrase);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            TrezorUserActionType actionType, String? pin, String? passphrase)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrezorUserActionData():
        return $default(_that.actionType, _that.pin, _that.passphrase);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            TrezorUserActionType actionType, String? pin, String? passphrase)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TrezorUserActionData() when $default != null:
        return $default(_that.actionType, _that.pin, _that.passphrase);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TrezorUserActionData implements TrezorUserActionData {
  const _TrezorUserActionData(
      {required this.actionType, this.pin, this.passphrase})
      : assert(
            ((actionType == TrezorUserActionType.trezorPin && pin != null) ||
                (actionType == TrezorUserActionType.trezorPassphrase &&
                    passphrase != null)),
            'PIN must be provided for TrezorPin action, passphrase for TrezorPassphrase action');
  factory _TrezorUserActionData.fromJson(Map<String, dynamic> json) =>
      _$TrezorUserActionDataFromJson(json);

  @override
  final TrezorUserActionType actionType;
  @override
  final String? pin;
  @override
  final String? passphrase;

  /// Create a copy of TrezorUserActionData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TrezorUserActionDataCopyWith<_TrezorUserActionData> get copyWith =>
      __$TrezorUserActionDataCopyWithImpl<_TrezorUserActionData>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TrezorUserActionDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TrezorUserActionData &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.pin, pin) || other.pin == pin) &&
            (identical(other.passphrase, passphrase) ||
                other.passphrase == passphrase));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, actionType, pin, passphrase);

  @override
  String toString() {
    return 'TrezorUserActionData(actionType: $actionType, pin: $pin, passphrase: $passphrase)';
  }
}

/// @nodoc
abstract mixin class _$TrezorUserActionDataCopyWith<$Res>
    implements $TrezorUserActionDataCopyWith<$Res> {
  factory _$TrezorUserActionDataCopyWith(_TrezorUserActionData value,
          $Res Function(_TrezorUserActionData) _then) =
      __$TrezorUserActionDataCopyWithImpl;
  @override
  @useResult
  $Res call({TrezorUserActionType actionType, String? pin, String? passphrase});
}

/// @nodoc
class __$TrezorUserActionDataCopyWithImpl<$Res>
    implements _$TrezorUserActionDataCopyWith<$Res> {
  __$TrezorUserActionDataCopyWithImpl(this._self, this._then);

  final _TrezorUserActionData _self;
  final $Res Function(_TrezorUserActionData) _then;

  /// Create a copy of TrezorUserActionData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? actionType = null,
    Object? pin = freezed,
    Object? passphrase = freezed,
  }) {
    return _then(_TrezorUserActionData(
      actionType: null == actionType
          ? _self.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as TrezorUserActionType,
      pin: freezed == pin
          ? _self.pin
          : pin // ignore: cast_nullable_to_non_nullable
              as String?,
      passphrase: freezed == passphrase
          ? _self.passphrase
          : passphrase // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
