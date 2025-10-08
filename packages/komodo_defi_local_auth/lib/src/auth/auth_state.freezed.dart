// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthenticationState {

 AuthenticationStatus get status; String? get message; int? get taskId; String? get error; KdfUser? get user; AuthenticationData? get data;
/// Create a copy of AuthenticationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthenticationStateCopyWith<AuthenticationState> get copyWith => _$AuthenticationStateCopyWithImpl<AuthenticationState>(this as AuthenticationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationState&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.error, error) || other.error == error)&&(identical(other.user, user) || other.user == user)&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,status,message,taskId,error,user,data);

@override
String toString() {
  return 'AuthenticationState(status: $status, message: $message, taskId: $taskId, error: $error, user: $user, data: $data)';
}


}

/// @nodoc
abstract mixin class $AuthenticationStateCopyWith<$Res>  {
  factory $AuthenticationStateCopyWith(AuthenticationState value, $Res Function(AuthenticationState) _then) = _$AuthenticationStateCopyWithImpl;
@useResult
$Res call({
 AuthenticationStatus status, String? message, int? taskId, String? error, KdfUser? user, AuthenticationData? data
});


$AuthenticationDataCopyWith<$Res>? get data;

}
/// @nodoc
class _$AuthenticationStateCopyWithImpl<$Res>
    implements $AuthenticationStateCopyWith<$Res> {
  _$AuthenticationStateCopyWithImpl(this._self, this._then);

  final AuthenticationState _self;
  final $Res Function(AuthenticationState) _then;

/// Create a copy of AuthenticationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? message = freezed,Object? taskId = freezed,Object? error = freezed,Object? user = freezed,Object? data = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthenticationStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as KdfUser?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AuthenticationData?,
  ));
}
/// Create a copy of AuthenticationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthenticationDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $AuthenticationDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthenticationState].
extension AuthenticationStatePatterns on AuthenticationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthenticationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthenticationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthenticationState value)  $default,){
final _that = this;
switch (_that) {
case _AuthenticationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthenticationState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthenticationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthenticationStatus status,  String? message,  int? taskId,  String? error,  KdfUser? user,  AuthenticationData? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthenticationState() when $default != null:
return $default(_that.status,_that.message,_that.taskId,_that.error,_that.user,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthenticationStatus status,  String? message,  int? taskId,  String? error,  KdfUser? user,  AuthenticationData? data)  $default,) {final _that = this;
switch (_that) {
case _AuthenticationState():
return $default(_that.status,_that.message,_that.taskId,_that.error,_that.user,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthenticationStatus status,  String? message,  int? taskId,  String? error,  KdfUser? user,  AuthenticationData? data)?  $default,) {final _that = this;
switch (_that) {
case _AuthenticationState() when $default != null:
return $default(_that.status,_that.message,_that.taskId,_that.error,_that.user,_that.data);case _:
  return null;

}
}

}

/// @nodoc


class _AuthenticationState implements AuthenticationState {
  const _AuthenticationState({required this.status, this.message, this.taskId, this.error, this.user, this.data});
  

@override final  AuthenticationStatus status;
@override final  String? message;
@override final  int? taskId;
@override final  String? error;
@override final  KdfUser? user;
@override final  AuthenticationData? data;

/// Create a copy of AuthenticationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthenticationStateCopyWith<_AuthenticationState> get copyWith => __$AuthenticationStateCopyWithImpl<_AuthenticationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthenticationState&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.error, error) || other.error == error)&&(identical(other.user, user) || other.user == user)&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,status,message,taskId,error,user,data);

@override
String toString() {
  return 'AuthenticationState(status: $status, message: $message, taskId: $taskId, error: $error, user: $user, data: $data)';
}


}

/// @nodoc
abstract mixin class _$AuthenticationStateCopyWith<$Res> implements $AuthenticationStateCopyWith<$Res> {
  factory _$AuthenticationStateCopyWith(_AuthenticationState value, $Res Function(_AuthenticationState) _then) = __$AuthenticationStateCopyWithImpl;
@override @useResult
$Res call({
 AuthenticationStatus status, String? message, int? taskId, String? error, KdfUser? user, AuthenticationData? data
});


@override $AuthenticationDataCopyWith<$Res>? get data;

}
/// @nodoc
class __$AuthenticationStateCopyWithImpl<$Res>
    implements _$AuthenticationStateCopyWith<$Res> {
  __$AuthenticationStateCopyWithImpl(this._self, this._then);

  final _AuthenticationState _self;
  final $Res Function(_AuthenticationState) _then;

/// Create a copy of AuthenticationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? message = freezed,Object? taskId = freezed,Object? error = freezed,Object? user = freezed,Object? data = freezed,}) {
  return _then(_AuthenticationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthenticationStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as KdfUser?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AuthenticationData?,
  ));
}

/// Create a copy of AuthenticationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthenticationDataCopyWith<$Res>? get data {
    if (_self.data == null) {
    return null;
  }

  return $AuthenticationDataCopyWith<$Res>(_self.data!, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc
mixin _$AuthenticationData {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationData);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthenticationData()';
}


}

/// @nodoc
class $AuthenticationDataCopyWith<$Res>  {
$AuthenticationDataCopyWith(AuthenticationData _, $Res Function(AuthenticationData) __);
}


/// Adds pattern-matching-related methods to [AuthenticationData].
extension AuthenticationDataPatterns on AuthenticationData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( QRCodeData value)?  qrCode,TResult Function( TrezorData value)?  trezor,TResult Function( WalletConnectData value)?  walletConnect,required TResult orElse(),}){
final _that = this;
switch (_that) {
case QRCodeData() when qrCode != null:
return qrCode(_that);case TrezorData() when trezor != null:
return trezor(_that);case WalletConnectData() when walletConnect != null:
return walletConnect(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( QRCodeData value)  qrCode,required TResult Function( TrezorData value)  trezor,required TResult Function( WalletConnectData value)  walletConnect,}){
final _that = this;
switch (_that) {
case QRCodeData():
return qrCode(_that);case TrezorData():
return trezor(_that);case WalletConnectData():
return walletConnect(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( QRCodeData value)?  qrCode,TResult? Function( TrezorData value)?  trezor,TResult? Function( WalletConnectData value)?  walletConnect,}){
final _that = this;
switch (_that) {
case QRCodeData() when qrCode != null:
return qrCode(_that);case TrezorData() when trezor != null:
return trezor(_that);case WalletConnectData() when walletConnect != null:
return walletConnect(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String uri,  Map<String, dynamic> requiredNamespaces,  String? sessionTopic)?  qrCode,TResult Function( int taskId,  String? deviceInfo)?  trezor,TResult Function( String sessionTopic,  Map<String, dynamic>? session,  List<String>? supportedChains)?  walletConnect,required TResult orElse(),}) {final _that = this;
switch (_that) {
case QRCodeData() when qrCode != null:
return qrCode(_that.uri,_that.requiredNamespaces,_that.sessionTopic);case TrezorData() when trezor != null:
return trezor(_that.taskId,_that.deviceInfo);case WalletConnectData() when walletConnect != null:
return walletConnect(_that.sessionTopic,_that.session,_that.supportedChains);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String uri,  Map<String, dynamic> requiredNamespaces,  String? sessionTopic)  qrCode,required TResult Function( int taskId,  String? deviceInfo)  trezor,required TResult Function( String sessionTopic,  Map<String, dynamic>? session,  List<String>? supportedChains)  walletConnect,}) {final _that = this;
switch (_that) {
case QRCodeData():
return qrCode(_that.uri,_that.requiredNamespaces,_that.sessionTopic);case TrezorData():
return trezor(_that.taskId,_that.deviceInfo);case WalletConnectData():
return walletConnect(_that.sessionTopic,_that.session,_that.supportedChains);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String uri,  Map<String, dynamic> requiredNamespaces,  String? sessionTopic)?  qrCode,TResult? Function( int taskId,  String? deviceInfo)?  trezor,TResult? Function( String sessionTopic,  Map<String, dynamic>? session,  List<String>? supportedChains)?  walletConnect,}) {final _that = this;
switch (_that) {
case QRCodeData() when qrCode != null:
return qrCode(_that.uri,_that.requiredNamespaces,_that.sessionTopic);case TrezorData() when trezor != null:
return trezor(_that.taskId,_that.deviceInfo);case WalletConnectData() when walletConnect != null:
return walletConnect(_that.sessionTopic,_that.session,_that.supportedChains);case _:
  return null;

}
}

}

/// @nodoc


class QRCodeData implements AuthenticationData {
  const QRCodeData({required this.uri, required final  Map<String, dynamic> requiredNamespaces, this.sessionTopic}): _requiredNamespaces = requiredNamespaces;
  

 final  String uri;
 final  Map<String, dynamic> _requiredNamespaces;
 Map<String, dynamic> get requiredNamespaces {
  if (_requiredNamespaces is EqualUnmodifiableMapView) return _requiredNamespaces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_requiredNamespaces);
}

 final  String? sessionTopic;

/// Create a copy of AuthenticationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QRCodeDataCopyWith<QRCodeData> get copyWith => _$QRCodeDataCopyWithImpl<QRCodeData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QRCodeData&&(identical(other.uri, uri) || other.uri == uri)&&const DeepCollectionEquality().equals(other._requiredNamespaces, _requiredNamespaces)&&(identical(other.sessionTopic, sessionTopic) || other.sessionTopic == sessionTopic));
}


@override
int get hashCode => Object.hash(runtimeType,uri,const DeepCollectionEquality().hash(_requiredNamespaces),sessionTopic);

@override
String toString() {
  return 'AuthenticationData.qrCode(uri: $uri, requiredNamespaces: $requiredNamespaces, sessionTopic: $sessionTopic)';
}


}

/// @nodoc
abstract mixin class $QRCodeDataCopyWith<$Res> implements $AuthenticationDataCopyWith<$Res> {
  factory $QRCodeDataCopyWith(QRCodeData value, $Res Function(QRCodeData) _then) = _$QRCodeDataCopyWithImpl;
@useResult
$Res call({
 String uri, Map<String, dynamic> requiredNamespaces, String? sessionTopic
});




}
/// @nodoc
class _$QRCodeDataCopyWithImpl<$Res>
    implements $QRCodeDataCopyWith<$Res> {
  _$QRCodeDataCopyWithImpl(this._self, this._then);

  final QRCodeData _self;
  final $Res Function(QRCodeData) _then;

/// Create a copy of AuthenticationData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? requiredNamespaces = null,Object? sessionTopic = freezed,}) {
  return _then(QRCodeData(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,requiredNamespaces: null == requiredNamespaces ? _self._requiredNamespaces : requiredNamespaces // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,sessionTopic: freezed == sessionTopic ? _self.sessionTopic : sessionTopic // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class TrezorData implements AuthenticationData {
  const TrezorData({required this.taskId, this.deviceInfo});
  

 final  int taskId;
 final  String? deviceInfo;

/// Create a copy of AuthenticationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrezorDataCopyWith<TrezorData> get copyWith => _$TrezorDataCopyWithImpl<TrezorData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrezorData&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.deviceInfo, deviceInfo) || other.deviceInfo == deviceInfo));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,deviceInfo);

@override
String toString() {
  return 'AuthenticationData.trezor(taskId: $taskId, deviceInfo: $deviceInfo)';
}


}

/// @nodoc
abstract mixin class $TrezorDataCopyWith<$Res> implements $AuthenticationDataCopyWith<$Res> {
  factory $TrezorDataCopyWith(TrezorData value, $Res Function(TrezorData) _then) = _$TrezorDataCopyWithImpl;
@useResult
$Res call({
 int taskId, String? deviceInfo
});




}
/// @nodoc
class _$TrezorDataCopyWithImpl<$Res>
    implements $TrezorDataCopyWith<$Res> {
  _$TrezorDataCopyWithImpl(this._self, this._then);

  final TrezorData _self;
  final $Res Function(TrezorData) _then;

/// Create a copy of AuthenticationData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? deviceInfo = freezed,}) {
  return _then(TrezorData(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,deviceInfo: freezed == deviceInfo ? _self.deviceInfo : deviceInfo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class WalletConnectData implements AuthenticationData {
  const WalletConnectData({required this.sessionTopic, final  Map<String, dynamic>? session, final  List<String>? supportedChains}): _session = session,_supportedChains = supportedChains;
  

 final  String sessionTopic;
 final  Map<String, dynamic>? _session;
 Map<String, dynamic>? get session {
  final value = _session;
  if (value == null) return null;
  if (_session is EqualUnmodifiableMapView) return _session;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _supportedChains;
 List<String>? get supportedChains {
  final value = _supportedChains;
  if (value == null) return null;
  if (_supportedChains is EqualUnmodifiableListView) return _supportedChains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of AuthenticationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletConnectDataCopyWith<WalletConnectData> get copyWith => _$WalletConnectDataCopyWithImpl<WalletConnectData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletConnectData&&(identical(other.sessionTopic, sessionTopic) || other.sessionTopic == sessionTopic)&&const DeepCollectionEquality().equals(other._session, _session)&&const DeepCollectionEquality().equals(other._supportedChains, _supportedChains));
}


@override
int get hashCode => Object.hash(runtimeType,sessionTopic,const DeepCollectionEquality().hash(_session),const DeepCollectionEquality().hash(_supportedChains));

@override
String toString() {
  return 'AuthenticationData.walletConnect(sessionTopic: $sessionTopic, session: $session, supportedChains: $supportedChains)';
}


}

/// @nodoc
abstract mixin class $WalletConnectDataCopyWith<$Res> implements $AuthenticationDataCopyWith<$Res> {
  factory $WalletConnectDataCopyWith(WalletConnectData value, $Res Function(WalletConnectData) _then) = _$WalletConnectDataCopyWithImpl;
@useResult
$Res call({
 String sessionTopic, Map<String, dynamic>? session, List<String>? supportedChains
});




}
/// @nodoc
class _$WalletConnectDataCopyWithImpl<$Res>
    implements $WalletConnectDataCopyWith<$Res> {
  _$WalletConnectDataCopyWithImpl(this._self, this._then);

  final WalletConnectData _self;
  final $Res Function(WalletConnectData) _then;

/// Create a copy of AuthenticationData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sessionTopic = null,Object? session = freezed,Object? supportedChains = freezed,}) {
  return _then(WalletConnectData(
sessionTopic: null == sessionTopic ? _self.sessionTopic : sessionTopic // ignore: cast_nullable_to_non_nullable
as String,session: freezed == session ? _self._session : session // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,supportedChains: freezed == supportedChains ? _self._supportedChains : supportedChains // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
