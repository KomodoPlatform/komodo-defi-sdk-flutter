// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'new_address_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NewAddressState {
  NewAddressStatus get status;
  String? get message;
  int? get taskId;
  NewAddressInfo? get address;
  String? get expectedAddress;
  String? get error;

  /// Create a copy of NewAddressState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NewAddressStateCopyWith<NewAddressState> get copyWith =>
      _$NewAddressStateCopyWithImpl<NewAddressState>(
          this as NewAddressState, _$identity);

  /// Serializes this NewAddressState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NewAddressState &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.expectedAddress, expectedAddress) ||
                other.expectedAddress == expectedAddress) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, status, message, taskId, address, expectedAddress, error);

  @override
  String toString() {
    return 'NewAddressState(status: $status, message: $message, taskId: $taskId, address: $address, expectedAddress: $expectedAddress, error: $error)';
  }
}

/// @nodoc
abstract mixin class $NewAddressStateCopyWith<$Res> {
  factory $NewAddressStateCopyWith(
          NewAddressState value, $Res Function(NewAddressState) _then) =
      _$NewAddressStateCopyWithImpl;
  @useResult
  $Res call(
      {NewAddressStatus status,
      String? message,
      int? taskId,
      NewAddressInfo? address,
      String? expectedAddress,
      String? error});
}

/// @nodoc
class _$NewAddressStateCopyWithImpl<$Res>
    implements $NewAddressStateCopyWith<$Res> {
  _$NewAddressStateCopyWithImpl(this._self, this._then);

  final NewAddressState _self;
  final $Res Function(NewAddressState) _then;

  /// Create a copy of NewAddressState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? message = freezed,
    Object? taskId = freezed,
    Object? address = freezed,
    Object? expectedAddress = freezed,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as NewAddressStatus,
      message: freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      taskId: freezed == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as NewAddressInfo?,
      expectedAddress: freezed == expectedAddress
          ? _self.expectedAddress
          : expectedAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _NewAddressState extends NewAddressState {
  const _NewAddressState(
      {required this.status,
      this.message,
      this.taskId,
      this.address,
      this.expectedAddress,
      this.error})
      : super._();
  factory _NewAddressState.fromJson(Map<String, dynamic> json) =>
      _$NewAddressStateFromJson(json);

  @override
  final NewAddressStatus status;
  @override
  final String? message;
  @override
  final int? taskId;
  @override
  final NewAddressInfo? address;
  @override
  final String? expectedAddress;
  @override
  final String? error;

  /// Create a copy of NewAddressState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NewAddressStateCopyWith<_NewAddressState> get copyWith =>
      __$NewAddressStateCopyWithImpl<_NewAddressState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NewAddressStateToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NewAddressState &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.expectedAddress, expectedAddress) ||
                other.expectedAddress == expectedAddress) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, status, message, taskId, address, expectedAddress, error);

  @override
  String toString() {
    return 'NewAddressState(status: $status, message: $message, taskId: $taskId, address: $address, expectedAddress: $expectedAddress, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$NewAddressStateCopyWith<$Res>
    implements $NewAddressStateCopyWith<$Res> {
  factory _$NewAddressStateCopyWith(
          _NewAddressState value, $Res Function(_NewAddressState) _then) =
      __$NewAddressStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {NewAddressStatus status,
      String? message,
      int? taskId,
      NewAddressInfo? address,
      String? expectedAddress,
      String? error});
}

/// @nodoc
class __$NewAddressStateCopyWithImpl<$Res>
    implements _$NewAddressStateCopyWith<$Res> {
  __$NewAddressStateCopyWithImpl(this._self, this._then);

  final _NewAddressState _self;
  final $Res Function(_NewAddressState) _then;

  /// Create a copy of NewAddressState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? status = null,
    Object? message = freezed,
    Object? taskId = freezed,
    Object? address = freezed,
    Object? expectedAddress = freezed,
    Object? error = freezed,
  }) {
    return _then(_NewAddressState(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as NewAddressStatus,
      message: freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      taskId: freezed == taskId
          ? _self.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as int?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as NewAddressInfo?,
      expectedAddress: freezed == expectedAddress
          ? _self.expectedAddress
          : expectedAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
