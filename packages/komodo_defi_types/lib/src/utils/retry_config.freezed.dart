// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'retry_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RetryConfig {
  int get maxAttempts;
  Duration? get perAttemptTimeout;
  bool Function(Object error)? get shouldRetry;
  void Function(int attempt, Object error)? get onRetry;
  Duration get backoffDelay;

  /// Create a copy of RetryConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RetryConfigCopyWith<RetryConfig> get copyWith =>
      _$RetryConfigCopyWithImpl<RetryConfig>(this as RetryConfig, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RetryConfig &&
            (identical(other.maxAttempts, maxAttempts) ||
                other.maxAttempts == maxAttempts) &&
            (identical(other.perAttemptTimeout, perAttemptTimeout) ||
                other.perAttemptTimeout == perAttemptTimeout) &&
            (identical(other.shouldRetry, shouldRetry) ||
                other.shouldRetry == shouldRetry) &&
            (identical(other.onRetry, onRetry) || other.onRetry == onRetry) &&
            (identical(other.backoffDelay, backoffDelay) ||
                other.backoffDelay == backoffDelay));
  }

  @override
  int get hashCode => Object.hash(runtimeType, maxAttempts, perAttemptTimeout,
      shouldRetry, onRetry, backoffDelay);

  @override
  String toString() {
    return 'RetryConfig(maxAttempts: $maxAttempts, perAttemptTimeout: $perAttemptTimeout, shouldRetry: $shouldRetry, onRetry: $onRetry, backoffDelay: $backoffDelay)';
  }
}

/// @nodoc
abstract mixin class $RetryConfigCopyWith<$Res> {
  factory $RetryConfigCopyWith(
          RetryConfig value, $Res Function(RetryConfig) _then) =
      _$RetryConfigCopyWithImpl;
  @useResult
  $Res call(
      {int maxAttempts,
      Duration? perAttemptTimeout,
      bool Function(Object)? shouldRetry,
      void Function(int, Object)? onRetry,
      Duration backoffDelay});
}

/// @nodoc
class _$RetryConfigCopyWithImpl<$Res> implements $RetryConfigCopyWith<$Res> {
  _$RetryConfigCopyWithImpl(this._self, this._then);

  final RetryConfig _self;
  final $Res Function(RetryConfig) _then;

  /// Create a copy of RetryConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxAttempts = null,
    Object? perAttemptTimeout = freezed,
    Object? shouldRetry = freezed,
    Object? onRetry = freezed,
    Object? backoffDelay = null,
  }) {
    return _then(_self.copyWith(
      maxAttempts: null == maxAttempts
          ? _self.maxAttempts
          : maxAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      perAttemptTimeout: freezed == perAttemptTimeout
          ? _self.perAttemptTimeout
          : perAttemptTimeout // ignore: cast_nullable_to_non_nullable
              as Duration?,
      shouldRetry: freezed == shouldRetry
          ? _self.shouldRetry!
          : shouldRetry // ignore: cast_nullable_to_non_nullable
              as bool Function(Object)?,
      onRetry: freezed == onRetry
          ? _self.onRetry!
          : onRetry // ignore: cast_nullable_to_non_nullable
              as void Function(int, Object)?,
      backoffDelay: null == backoffDelay
          ? _self.backoffDelay
          : backoffDelay // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _RetryConfig extends RetryConfig {
  const _RetryConfig(
      {this.maxAttempts = 3,
      this.perAttemptTimeout,
      this.shouldRetry,
      this.onRetry,
      this.backoffDelay = const Duration(milliseconds: 100)})
      : super._();

  @override
  @JsonKey()
  final int maxAttempts;
  @override
  final Duration? perAttemptTimeout;
  @override
  final bool Function(Object)? shouldRetry;
  @override
  final void Function(int, Object)? onRetry;
  @override
  @JsonKey()
  final Duration backoffDelay;

  /// Create a copy of RetryConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RetryConfigCopyWith<_RetryConfig> get copyWith =>
      __$RetryConfigCopyWithImpl<_RetryConfig>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RetryConfig &&
            (identical(other.maxAttempts, maxAttempts) ||
                other.maxAttempts == maxAttempts) &&
            (identical(other.perAttemptTimeout, perAttemptTimeout) ||
                other.perAttemptTimeout == perAttemptTimeout) &&
            (identical(other.shouldRetry, shouldRetry) ||
                other.shouldRetry == shouldRetry) &&
            (identical(other.onRetry, onRetry) || other.onRetry == onRetry) &&
            (identical(other.backoffDelay, backoffDelay) ||
                other.backoffDelay == backoffDelay));
  }

  @override
  int get hashCode => Object.hash(runtimeType, maxAttempts, perAttemptTimeout,
      shouldRetry, onRetry, backoffDelay);

  @override
  String toString() {
    return 'RetryConfig(maxAttempts: $maxAttempts, perAttemptTimeout: $perAttemptTimeout, shouldRetry: $shouldRetry, onRetry: $onRetry, backoffDelay: $backoffDelay)';
  }
}

/// @nodoc
abstract mixin class _$RetryConfigCopyWith<$Res>
    implements $RetryConfigCopyWith<$Res> {
  factory _$RetryConfigCopyWith(
          _RetryConfig value, $Res Function(_RetryConfig) _then) =
      __$RetryConfigCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int maxAttempts,
      Duration? perAttemptTimeout,
      bool Function(Object)? shouldRetry,
      void Function(int, Object)? onRetry,
      Duration backoffDelay});
}

/// @nodoc
class __$RetryConfigCopyWithImpl<$Res> implements _$RetryConfigCopyWith<$Res> {
  __$RetryConfigCopyWithImpl(this._self, this._then);

  final _RetryConfig _self;
  final $Res Function(_RetryConfig) _then;

  /// Create a copy of RetryConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? maxAttempts = null,
    Object? perAttemptTimeout = freezed,
    Object? shouldRetry = freezed,
    Object? onRetry = freezed,
    Object? backoffDelay = null,
  }) {
    return _then(_RetryConfig(
      maxAttempts: null == maxAttempts
          ? _self.maxAttempts
          : maxAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      perAttemptTimeout: freezed == perAttemptTimeout
          ? _self.perAttemptTimeout
          : perAttemptTimeout // ignore: cast_nullable_to_non_nullable
              as Duration?,
      shouldRetry: freezed == shouldRetry
          ? _self.shouldRetry
          : shouldRetry // ignore: cast_nullable_to_non_nullable
              as bool Function(Object)?,
      onRetry: freezed == onRetry
          ? _self.onRetry
          : onRetry // ignore: cast_nullable_to_non_nullable
              as void Function(int, Object)?,
      backoffDelay: null == backoffDelay
          ? _self.backoffDelay
          : backoffDelay // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

// dart format on
