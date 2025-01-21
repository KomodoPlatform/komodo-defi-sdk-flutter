import 'package:komodo_defi_types/komodo_defi_types.dart';

class AuthResult {
  AuthResult({
    this.user,
    this.error,
  });

  final KdfUser? user;
  final AuthException? error;

  bool get isSuccess => user != null && error == null;

  JsonMap toJson() {
    return {
      'user': user?.toJson(),
      'error': error?.toString(),
    };
  }

  @override
  String toString() {
    return 'AuthResult(${toJson().toJsonString()})';
  }
}
