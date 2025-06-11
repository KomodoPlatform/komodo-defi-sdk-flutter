// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swap_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SwapProgress {
  SwapStatus get status;
  String get message;
  SwapResult? get swapResult;
  SwapErrorCode? get errorCode;
  String? get errorMessage;
  String? get uuid;

  /// Create a copy of SwapProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SwapProgressCopyWith<SwapProgress> get copyWith =>
      _$SwapProgressCopyWithImpl<SwapProgress>(
          this as SwapProgress, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SwapProgress &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.swapResult, swapResult) ||
                other.swapResult == swapResult) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.uuid, uuid) || other.uuid == uuid));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, status, message, swapResult, errorCode, errorMessage, uuid);

  @override
  String toString() {
    return 'SwapProgress(status: $status, message: $message, swapResult: $swapResult, errorCode: $errorCode, errorMessage: $errorMessage, uuid: $uuid)';
  }
}

/// @nodoc
abstract mixin class $SwapProgressCopyWith<$Res> {
  factory $SwapProgressCopyWith(
          SwapProgress value, $Res Function(SwapProgress) _then) =
      _$SwapProgressCopyWithImpl;
  @useResult
  $Res call(
      {SwapStatus status,
      String message,
      SwapResult? swapResult,
      SwapErrorCode? errorCode,
      String? errorMessage,
      String? uuid});

  $SwapResultCopyWith<$Res>? get swapResult;
}

/// @nodoc
class _$SwapProgressCopyWithImpl<$Res> implements $SwapProgressCopyWith<$Res> {
  _$SwapProgressCopyWithImpl(this._self, this._then);

  final SwapProgress _self;
  final $Res Function(SwapProgress) _then;

  /// Create a copy of SwapProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? message = null,
    Object? swapResult = freezed,
    Object? errorCode = freezed,
    Object? errorMessage = freezed,
    Object? uuid = freezed,
  }) {
    return _then(_self.copyWith(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SwapStatus,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      swapResult: freezed == swapResult
          ? _self.swapResult
          : swapResult // ignore: cast_nullable_to_non_nullable
              as SwapResult?,
      errorCode: freezed == errorCode
          ? _self.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as SwapErrorCode?,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      uuid: freezed == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of SwapProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SwapResultCopyWith<$Res>? get swapResult {
    if (_self.swapResult == null) {
      return null;
    }

    return $SwapResultCopyWith<$Res>(_self.swapResult!, (value) {
      return _then(_self.copyWith(swapResult: value));
    });
  }
}

/// @nodoc

class _SwapProgress extends SwapProgress {
  const _SwapProgress(
      {required this.status,
      required this.message,
      this.swapResult,
      this.errorCode,
      this.errorMessage,
      this.uuid})
      : super._();

  @override
  final SwapStatus status;
  @override
  final String message;
  @override
  final SwapResult? swapResult;
  @override
  final SwapErrorCode? errorCode;
  @override
  final String? errorMessage;
  @override
  final String? uuid;

  /// Create a copy of SwapProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SwapProgressCopyWith<_SwapProgress> get copyWith =>
      __$SwapProgressCopyWithImpl<_SwapProgress>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SwapProgress &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.swapResult, swapResult) ||
                other.swapResult == swapResult) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.uuid, uuid) || other.uuid == uuid));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, status, message, swapResult, errorCode, errorMessage, uuid);

  @override
  String toString() {
    return 'SwapProgress(status: $status, message: $message, swapResult: $swapResult, errorCode: $errorCode, errorMessage: $errorMessage, uuid: $uuid)';
  }
}

/// @nodoc
abstract mixin class _$SwapProgressCopyWith<$Res>
    implements $SwapProgressCopyWith<$Res> {
  factory _$SwapProgressCopyWith(
          _SwapProgress value, $Res Function(_SwapProgress) _then) =
      __$SwapProgressCopyWithImpl;
  @override
  @useResult
  $Res call(
      {SwapStatus status,
      String message,
      SwapResult? swapResult,
      SwapErrorCode? errorCode,
      String? errorMessage,
      String? uuid});

  @override
  $SwapResultCopyWith<$Res>? get swapResult;
}

/// @nodoc
class __$SwapProgressCopyWithImpl<$Res>
    implements _$SwapProgressCopyWith<$Res> {
  __$SwapProgressCopyWithImpl(this._self, this._then);

  final _SwapProgress _self;
  final $Res Function(_SwapProgress) _then;

  /// Create a copy of SwapProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? status = null,
    Object? message = null,
    Object? swapResult = freezed,
    Object? errorCode = freezed,
    Object? errorMessage = freezed,
    Object? uuid = freezed,
  }) {
    return _then(_SwapProgress(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SwapStatus,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      swapResult: freezed == swapResult
          ? _self.swapResult
          : swapResult // ignore: cast_nullable_to_non_nullable
              as SwapResult?,
      errorCode: freezed == errorCode
          ? _self.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as SwapErrorCode?,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      uuid: freezed == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of SwapProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SwapResultCopyWith<$Res>? get swapResult {
    if (_self.swapResult == null) {
      return null;
    }

    return $SwapResultCopyWith<$Res>(_self.swapResult!, (value) {
      return _then(_self.copyWith(swapResult: value));
    });
  }
}

// dart format on
