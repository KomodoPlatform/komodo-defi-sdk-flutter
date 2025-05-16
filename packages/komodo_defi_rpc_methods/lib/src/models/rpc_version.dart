import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

enum RpcVersion {
  _v2_0,
  _legacy;

  static const String _paramKey = 'mmrpc';

  static String get v2_0 => RpcVersion._v2_0.toParamString!;
  static String? get legacy => RpcVersion._legacy.toParamString;

  static RpcVersion fromString(String value) {
    switch (value) {
      case '2.0':
        return RpcVersion._v2_0;
      default:
        return RpcVersion._legacy;
    }
  }

  ///  Get the string representation of the version used in the RPC call.
  ///
  /// `null` values indicate that the version should not be included in the
  ///
  /// `null` is returned for the legacy version as it is the default.
  String? get toParamString {
    switch (this) {
      case RpcVersion._v2_0:
        return '2.0';
      case RpcVersion._legacy:
        return null;
    }
  }

  JsonMap get toParamJson {
    final version = toParamString;
    return {if (version != null) _paramKey: version};
  }
}
