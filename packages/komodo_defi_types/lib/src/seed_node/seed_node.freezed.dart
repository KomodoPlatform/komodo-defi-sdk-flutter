// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seed_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SeedNode {
  String get name;
  String get host;
  List<SeedNodeContact> get contact;

  /// Create a copy of SeedNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SeedNodeCopyWith<SeedNode> get copyWith =>
      _$SeedNodeCopyWithImpl<SeedNode>(this as SeedNode, _$identity);

  /// Serializes this SeedNode to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SeedNode &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.host, host) || other.host == host) &&
            const DeepCollectionEquality().equals(other.contact, contact));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, host, const DeepCollectionEquality().hash(contact));

  @override
  String toString() {
    return 'SeedNode(name: $name, host: $host, contact: $contact)';
  }
}

/// @nodoc
abstract mixin class $SeedNodeCopyWith<$Res> {
  factory $SeedNodeCopyWith(SeedNode value, $Res Function(SeedNode) _then) =
      _$SeedNodeCopyWithImpl;
  @useResult
  $Res call({String name, String host, List<SeedNodeContact> contact});
}

/// @nodoc
class _$SeedNodeCopyWithImpl<$Res> implements $SeedNodeCopyWith<$Res> {
  _$SeedNodeCopyWithImpl(this._self, this._then);

  final SeedNode _self;
  final $Res Function(SeedNode) _then;

  /// Create a copy of SeedNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? host = null,
    Object? contact = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      host: null == host
          ? _self.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      contact: null == contact
          ? _self.contact
          : contact // ignore: cast_nullable_to_non_nullable
              as List<SeedNodeContact>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SeedNode implements SeedNode {
  const _SeedNode(
      {required this.name,
      required this.host,
      required final List<SeedNodeContact> contact})
      : _contact = contact;
  factory _SeedNode.fromJson(Map<String, dynamic> json) =>
      _$SeedNodeFromJson(json);

  @override
  final String name;
  @override
  final String host;
  final List<SeedNodeContact> _contact;
  @override
  List<SeedNodeContact> get contact {
    if (_contact is EqualUnmodifiableListView) return _contact;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contact);
  }

  /// Create a copy of SeedNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SeedNodeCopyWith<_SeedNode> get copyWith =>
      __$SeedNodeCopyWithImpl<_SeedNode>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SeedNodeToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SeedNode &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.host, host) || other.host == host) &&
            const DeepCollectionEquality().equals(other._contact, _contact));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, host, const DeepCollectionEquality().hash(_contact));

  @override
  String toString() {
    return 'SeedNode(name: $name, host: $host, contact: $contact)';
  }
}

/// @nodoc
abstract mixin class _$SeedNodeCopyWith<$Res>
    implements $SeedNodeCopyWith<$Res> {
  factory _$SeedNodeCopyWith(_SeedNode value, $Res Function(_SeedNode) _then) =
      __$SeedNodeCopyWithImpl;
  @override
  @useResult
  $Res call({String name, String host, List<SeedNodeContact> contact});
}

/// @nodoc
class __$SeedNodeCopyWithImpl<$Res> implements _$SeedNodeCopyWith<$Res> {
  __$SeedNodeCopyWithImpl(this._self, this._then);

  final _SeedNode _self;
  final $Res Function(_SeedNode) _then;

  /// Create a copy of SeedNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? host = null,
    Object? contact = null,
  }) {
    return _then(_SeedNode(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      host: null == host
          ? _self.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      contact: null == contact
          ? _self._contact
          : contact // ignore: cast_nullable_to_non_nullable
              as List<SeedNodeContact>,
    ));
  }
}

/// @nodoc
mixin _$SeedNodeContact {
  String get email;

  /// Create a copy of SeedNodeContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SeedNodeContactCopyWith<SeedNodeContact> get copyWith =>
      _$SeedNodeContactCopyWithImpl<SeedNodeContact>(
          this as SeedNodeContact, _$identity);

  /// Serializes this SeedNodeContact to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SeedNodeContact &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email);

  @override
  String toString() {
    return 'SeedNodeContact(email: $email)';
  }
}

/// @nodoc
abstract mixin class $SeedNodeContactCopyWith<$Res> {
  factory $SeedNodeContactCopyWith(
          SeedNodeContact value, $Res Function(SeedNodeContact) _then) =
      _$SeedNodeContactCopyWithImpl;
  @useResult
  $Res call({String email});
}

/// @nodoc
class _$SeedNodeContactCopyWithImpl<$Res>
    implements $SeedNodeContactCopyWith<$Res> {
  _$SeedNodeContactCopyWithImpl(this._self, this._then);

  final SeedNodeContact _self;
  final $Res Function(SeedNodeContact) _then;

  /// Create a copy of SeedNodeContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
  }) {
    return _then(_self.copyWith(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SeedNodeContact implements SeedNodeContact {
  const _SeedNodeContact({required this.email});
  factory _SeedNodeContact.fromJson(Map<String, dynamic> json) =>
      _$SeedNodeContactFromJson(json);

  @override
  final String email;

  /// Create a copy of SeedNodeContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SeedNodeContactCopyWith<_SeedNodeContact> get copyWith =>
      __$SeedNodeContactCopyWithImpl<_SeedNodeContact>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SeedNodeContactToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SeedNodeContact &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email);

  @override
  String toString() {
    return 'SeedNodeContact(email: $email)';
  }
}

/// @nodoc
abstract mixin class _$SeedNodeContactCopyWith<$Res>
    implements $SeedNodeContactCopyWith<$Res> {
  factory _$SeedNodeContactCopyWith(
          _SeedNodeContact value, $Res Function(_SeedNodeContact) _then) =
      __$SeedNodeContactCopyWithImpl;
  @override
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$SeedNodeContactCopyWithImpl<$Res>
    implements _$SeedNodeContactCopyWith<$Res> {
  __$SeedNodeContactCopyWithImpl(this._self, this._then);

  final _SeedNodeContact _self;
  final $Res Function(_SeedNodeContact) _then;

  /// Create a copy of SeedNodeContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
  }) {
    return _then(_SeedNodeContact(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
