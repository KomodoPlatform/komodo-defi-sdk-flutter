// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthOptions {
  @JsonKey(
      name: 'derivation_method',
      fromJson: DerivationMethod.parse,
      toJson: _derivationMethodToJson)
  DerivationMethod get derivationMethod;
  @JsonKey(name: 'allow_weak_password')
  bool get allowWeakPassword;
  @JsonKey(
      name: 'priv_key_policy', fromJson: _policyFromJson, toJson: _policyToJson)
  PrivateKeyPolicy get privKeyPolicy;

  /// Create a copy of AuthOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthOptionsCopyWith<AuthOptions> get copyWith =>
      _$AuthOptionsCopyWithImpl<AuthOptions>(this as AuthOptions, _$identity);

  /// Serializes this AuthOptions to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthOptions &&
            (identical(other.derivationMethod, derivationMethod) ||
                other.derivationMethod == derivationMethod) &&
            (identical(other.allowWeakPassword, allowWeakPassword) ||
                other.allowWeakPassword == allowWeakPassword) &&
            (identical(other.privKeyPolicy, privKeyPolicy) ||
                other.privKeyPolicy == privKeyPolicy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, derivationMethod, allowWeakPassword, privKeyPolicy);

  @override
  String toString() {
    return 'AuthOptions(derivationMethod: $derivationMethod, allowWeakPassword: $allowWeakPassword, privKeyPolicy: $privKeyPolicy)';
  }
}

/// @nodoc
abstract mixin class $AuthOptionsCopyWith<$Res> {
  factory $AuthOptionsCopyWith(
          AuthOptions value, $Res Function(AuthOptions) _then) =
      _$AuthOptionsCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(
          name: 'derivation_method',
          fromJson: DerivationMethod.parse,
          toJson: _derivationMethodToJson)
      DerivationMethod derivationMethod,
      @JsonKey(name: 'allow_weak_password') bool allowWeakPassword,
      @JsonKey(
          name: 'priv_key_policy',
          fromJson: _policyFromJson,
          toJson: _policyToJson)
      PrivateKeyPolicy privKeyPolicy});
}

/// @nodoc
class _$AuthOptionsCopyWithImpl<$Res> implements $AuthOptionsCopyWith<$Res> {
  _$AuthOptionsCopyWithImpl(this._self, this._then);

  final AuthOptions _self;
  final $Res Function(AuthOptions) _then;

  /// Create a copy of AuthOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? derivationMethod = null,
    Object? allowWeakPassword = null,
    Object? privKeyPolicy = null,
  }) {
    return _then(_self.copyWith(
      derivationMethod: null == derivationMethod
          ? _self.derivationMethod
          : derivationMethod // ignore: cast_nullable_to_non_nullable
              as DerivationMethod,
      allowWeakPassword: null == allowWeakPassword
          ? _self.allowWeakPassword
          : allowWeakPassword // ignore: cast_nullable_to_non_nullable
              as bool,
      privKeyPolicy: null == privKeyPolicy
          ? _self.privKeyPolicy
          : privKeyPolicy // ignore: cast_nullable_to_non_nullable
              as PrivateKeyPolicy,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _AuthOptions implements AuthOptions {
  const _AuthOptions(
      {@JsonKey(
          name: 'derivation_method',
          fromJson: DerivationMethod.parse,
          toJson: _derivationMethodToJson)
      required this.derivationMethod,
      @JsonKey(name: 'allow_weak_password') this.allowWeakPassword = false,
      @JsonKey(
          name: 'priv_key_policy',
          fromJson: _policyFromJson,
          toJson: _policyToJson)
      this.privKeyPolicy = PrivateKeyPolicy.contextPrivKey});
  factory _AuthOptions.fromJson(Map<String, dynamic> json) =>
      _$AuthOptionsFromJson(json);

  @override
  @JsonKey(
      name: 'derivation_method',
      fromJson: DerivationMethod.parse,
      toJson: _derivationMethodToJson)
  final DerivationMethod derivationMethod;
  @override
  @JsonKey(name: 'allow_weak_password')
  final bool allowWeakPassword;
  @override
  @JsonKey(
      name: 'priv_key_policy', fromJson: _policyFromJson, toJson: _policyToJson)
  final PrivateKeyPolicy privKeyPolicy;

  /// Create a copy of AuthOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthOptionsCopyWith<_AuthOptions> get copyWith =>
      __$AuthOptionsCopyWithImpl<_AuthOptions>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AuthOptionsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthOptions &&
            (identical(other.derivationMethod, derivationMethod) ||
                other.derivationMethod == derivationMethod) &&
            (identical(other.allowWeakPassword, allowWeakPassword) ||
                other.allowWeakPassword == allowWeakPassword) &&
            (identical(other.privKeyPolicy, privKeyPolicy) ||
                other.privKeyPolicy == privKeyPolicy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, derivationMethod, allowWeakPassword, privKeyPolicy);

  @override
  String toString() {
    return 'AuthOptions(derivationMethod: $derivationMethod, allowWeakPassword: $allowWeakPassword, privKeyPolicy: $privKeyPolicy)';
  }
}

/// @nodoc
abstract mixin class _$AuthOptionsCopyWith<$Res>
    implements $AuthOptionsCopyWith<$Res> {
  factory _$AuthOptionsCopyWith(
          _AuthOptions value, $Res Function(_AuthOptions) _then) =
      __$AuthOptionsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(
          name: 'derivation_method',
          fromJson: DerivationMethod.parse,
          toJson: _derivationMethodToJson)
      DerivationMethod derivationMethod,
      @JsonKey(name: 'allow_weak_password') bool allowWeakPassword,
      @JsonKey(
          name: 'priv_key_policy',
          fromJson: _policyFromJson,
          toJson: _policyToJson)
      PrivateKeyPolicy privKeyPolicy});
}

/// @nodoc
class __$AuthOptionsCopyWithImpl<$Res> implements _$AuthOptionsCopyWith<$Res> {
  __$AuthOptionsCopyWithImpl(this._self, this._then);

  final _AuthOptions _self;
  final $Res Function(_AuthOptions) _then;

  /// Create a copy of AuthOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? derivationMethod = null,
    Object? allowWeakPassword = null,
    Object? privKeyPolicy = null,
  }) {
    return _then(_AuthOptions(
      derivationMethod: null == derivationMethod
          ? _self.derivationMethod
          : derivationMethod // ignore: cast_nullable_to_non_nullable
              as DerivationMethod,
      allowWeakPassword: null == allowWeakPassword
          ? _self.allowWeakPassword
          : allowWeakPassword // ignore: cast_nullable_to_non_nullable
              as bool,
      privKeyPolicy: null == privKeyPolicy
          ? _self.privKeyPolicy
          : privKeyPolicy // ignore: cast_nullable_to_non_nullable
              as PrivateKeyPolicy,
    ));
  }
}

// dart format on
