// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cosmos_explorer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CosmosExplorer {

 String? get kind; String get url; String? get txPage; String? get accountPage; String? get validatorPage; String? get proposalPage; String? get blockPage;
/// Create a copy of CosmosExplorer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CosmosExplorerCopyWith<CosmosExplorer> get copyWith => _$CosmosExplorerCopyWithImpl<CosmosExplorer>(this as CosmosExplorer, _$identity);

  /// Serializes this CosmosExplorer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CosmosExplorer&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.url, url) || other.url == url)&&(identical(other.txPage, txPage) || other.txPage == txPage)&&(identical(other.accountPage, accountPage) || other.accountPage == accountPage)&&(identical(other.validatorPage, validatorPage) || other.validatorPage == validatorPage)&&(identical(other.proposalPage, proposalPage) || other.proposalPage == proposalPage)&&(identical(other.blockPage, blockPage) || other.blockPage == blockPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,url,txPage,accountPage,validatorPage,proposalPage,blockPage);

@override
String toString() {
  return 'CosmosExplorer(kind: $kind, url: $url, txPage: $txPage, accountPage: $accountPage, validatorPage: $validatorPage, proposalPage: $proposalPage, blockPage: $blockPage)';
}


}

/// @nodoc
abstract mixin class $CosmosExplorerCopyWith<$Res>  {
  factory $CosmosExplorerCopyWith(CosmosExplorer value, $Res Function(CosmosExplorer) _then) = _$CosmosExplorerCopyWithImpl;
@useResult
$Res call({
 String? kind, String url, String? txPage, String? accountPage, String? validatorPage, String? proposalPage, String? blockPage
});




}
/// @nodoc
class _$CosmosExplorerCopyWithImpl<$Res>
    implements $CosmosExplorerCopyWith<$Res> {
  _$CosmosExplorerCopyWithImpl(this._self, this._then);

  final CosmosExplorer _self;
  final $Res Function(CosmosExplorer) _then;

/// Create a copy of CosmosExplorer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = freezed,Object? url = null,Object? txPage = freezed,Object? accountPage = freezed,Object? validatorPage = freezed,Object? proposalPage = freezed,Object? blockPage = freezed,}) {
  return _then(_self.copyWith(
kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,txPage: freezed == txPage ? _self.txPage : txPage // ignore: cast_nullable_to_non_nullable
as String?,accountPage: freezed == accountPage ? _self.accountPage : accountPage // ignore: cast_nullable_to_non_nullable
as String?,validatorPage: freezed == validatorPage ? _self.validatorPage : validatorPage // ignore: cast_nullable_to_non_nullable
as String?,proposalPage: freezed == proposalPage ? _self.proposalPage : proposalPage // ignore: cast_nullable_to_non_nullable
as String?,blockPage: freezed == blockPage ? _self.blockPage : blockPage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CosmosExplorer].
extension CosmosExplorerPatterns on CosmosExplorer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CosmosExplorer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CosmosExplorer() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CosmosExplorer value)  $default,){
final _that = this;
switch (_that) {
case _CosmosExplorer():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CosmosExplorer value)?  $default,){
final _that = this;
switch (_that) {
case _CosmosExplorer() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? kind,  String url,  String? txPage,  String? accountPage,  String? validatorPage,  String? proposalPage,  String? blockPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CosmosExplorer() when $default != null:
return $default(_that.kind,_that.url,_that.txPage,_that.accountPage,_that.validatorPage,_that.proposalPage,_that.blockPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? kind,  String url,  String? txPage,  String? accountPage,  String? validatorPage,  String? proposalPage,  String? blockPage)  $default,) {final _that = this;
switch (_that) {
case _CosmosExplorer():
return $default(_that.kind,_that.url,_that.txPage,_that.accountPage,_that.validatorPage,_that.proposalPage,_that.blockPage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? kind,  String url,  String? txPage,  String? accountPage,  String? validatorPage,  String? proposalPage,  String? blockPage)?  $default,) {final _that = this;
switch (_that) {
case _CosmosExplorer() when $default != null:
return $default(_that.kind,_that.url,_that.txPage,_that.accountPage,_that.validatorPage,_that.proposalPage,_that.blockPage);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CosmosExplorer extends CosmosExplorer {
  const _CosmosExplorer({this.kind, required this.url, this.txPage, this.accountPage, this.validatorPage, this.proposalPage, this.blockPage}): super._();
  factory _CosmosExplorer.fromJson(Map<String, dynamic> json) => _$CosmosExplorerFromJson(json);

@override final  String? kind;
@override final  String url;
@override final  String? txPage;
@override final  String? accountPage;
@override final  String? validatorPage;
@override final  String? proposalPage;
@override final  String? blockPage;

/// Create a copy of CosmosExplorer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CosmosExplorerCopyWith<_CosmosExplorer> get copyWith => __$CosmosExplorerCopyWithImpl<_CosmosExplorer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CosmosExplorerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CosmosExplorer&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.url, url) || other.url == url)&&(identical(other.txPage, txPage) || other.txPage == txPage)&&(identical(other.accountPage, accountPage) || other.accountPage == accountPage)&&(identical(other.validatorPage, validatorPage) || other.validatorPage == validatorPage)&&(identical(other.proposalPage, proposalPage) || other.proposalPage == proposalPage)&&(identical(other.blockPage, blockPage) || other.blockPage == blockPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,url,txPage,accountPage,validatorPage,proposalPage,blockPage);

@override
String toString() {
  return 'CosmosExplorer(kind: $kind, url: $url, txPage: $txPage, accountPage: $accountPage, validatorPage: $validatorPage, proposalPage: $proposalPage, blockPage: $blockPage)';
}


}

/// @nodoc
abstract mixin class _$CosmosExplorerCopyWith<$Res> implements $CosmosExplorerCopyWith<$Res> {
  factory _$CosmosExplorerCopyWith(_CosmosExplorer value, $Res Function(_CosmosExplorer) _then) = __$CosmosExplorerCopyWithImpl;
@override @useResult
$Res call({
 String? kind, String url, String? txPage, String? accountPage, String? validatorPage, String? proposalPage, String? blockPage
});




}
/// @nodoc
class __$CosmosExplorerCopyWithImpl<$Res>
    implements _$CosmosExplorerCopyWith<$Res> {
  __$CosmosExplorerCopyWithImpl(this._self, this._then);

  final _CosmosExplorer _self;
  final $Res Function(_CosmosExplorer) _then;

/// Create a copy of CosmosExplorer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = freezed,Object? url = null,Object? txPage = freezed,Object? accountPage = freezed,Object? validatorPage = freezed,Object? proposalPage = freezed,Object? blockPage = freezed,}) {
  return _then(_CosmosExplorer(
kind: freezed == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,txPage: freezed == txPage ? _self.txPage : txPage // ignore: cast_nullable_to_non_nullable
as String?,accountPage: freezed == accountPage ? _self.accountPage : accountPage // ignore: cast_nullable_to_non_nullable
as String?,validatorPage: freezed == validatorPage ? _self.validatorPage : validatorPage // ignore: cast_nullable_to_non_nullable
as String?,proposalPage: freezed == proposalPage ? _self.proposalPage : proposalPage // ignore: cast_nullable_to_non_nullable
as String?,blockPage: freezed == blockPage ? _self.blockPage : blockPage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
