// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkpoint_block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckPointBlock {

 num? get height; num? get time; String? get hash; String? get saplingTree;
/// Create a copy of CheckPointBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckPointBlockCopyWith<CheckPointBlock> get copyWith => _$CheckPointBlockCopyWithImpl<CheckPointBlock>(this as CheckPointBlock, _$identity);

  /// Serializes this CheckPointBlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckPointBlock&&(identical(other.height, height) || other.height == height)&&(identical(other.time, time) || other.time == time)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.saplingTree, saplingTree) || other.saplingTree == saplingTree));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,height,time,hash,saplingTree);

@override
String toString() {
  return 'CheckPointBlock(height: $height, time: $time, hash: $hash, saplingTree: $saplingTree)';
}


}

/// @nodoc
abstract mixin class $CheckPointBlockCopyWith<$Res>  {
  factory $CheckPointBlockCopyWith(CheckPointBlock value, $Res Function(CheckPointBlock) _then) = _$CheckPointBlockCopyWithImpl;
@useResult
$Res call({
 num? height, num? time, String? hash, String? saplingTree
});




}
/// @nodoc
class _$CheckPointBlockCopyWithImpl<$Res>
    implements $CheckPointBlockCopyWith<$Res> {
  _$CheckPointBlockCopyWithImpl(this._self, this._then);

  final CheckPointBlock _self;
  final $Res Function(CheckPointBlock) _then;

/// Create a copy of CheckPointBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? height = freezed,Object? time = freezed,Object? hash = freezed,Object? saplingTree = freezed,}) {
  return _then(_self.copyWith(
height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as num?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as num?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,saplingTree: freezed == saplingTree ? _self.saplingTree : saplingTree // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CheckPointBlock implements CheckPointBlock {
  const _CheckPointBlock({this.height, this.time, this.hash, this.saplingTree});
  factory _CheckPointBlock.fromJson(Map<String, dynamic> json) => _$CheckPointBlockFromJson(json);

@override final  num? height;
@override final  num? time;
@override final  String? hash;
@override final  String? saplingTree;

/// Create a copy of CheckPointBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckPointBlockCopyWith<_CheckPointBlock> get copyWith => __$CheckPointBlockCopyWithImpl<_CheckPointBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckPointBlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckPointBlock&&(identical(other.height, height) || other.height == height)&&(identical(other.time, time) || other.time == time)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.saplingTree, saplingTree) || other.saplingTree == saplingTree));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,height,time,hash,saplingTree);

@override
String toString() {
  return 'CheckPointBlock(height: $height, time: $time, hash: $hash, saplingTree: $saplingTree)';
}


}

/// @nodoc
abstract mixin class _$CheckPointBlockCopyWith<$Res> implements $CheckPointBlockCopyWith<$Res> {
  factory _$CheckPointBlockCopyWith(_CheckPointBlock value, $Res Function(_CheckPointBlock) _then) = __$CheckPointBlockCopyWithImpl;
@override @useResult
$Res call({
 num? height, num? time, String? hash, String? saplingTree
});




}
/// @nodoc
class __$CheckPointBlockCopyWithImpl<$Res>
    implements _$CheckPointBlockCopyWith<$Res> {
  __$CheckPointBlockCopyWithImpl(this._self, this._then);

  final _CheckPointBlock _self;
  final $Res Function(_CheckPointBlock) _then;

/// Create a copy of CheckPointBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? height = freezed,Object? time = freezed,Object? hash = freezed,Object? saplingTree = freezed,}) {
  return _then(_CheckPointBlock(
height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as num?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as num?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,saplingTree: freezed == saplingTree ? _self.saplingTree : saplingTree // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
