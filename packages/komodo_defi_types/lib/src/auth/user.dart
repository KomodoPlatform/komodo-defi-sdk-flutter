import 'package:komodo_defi_types/komodo_defi_types.dart';

// TODO! Document this class
class KdfUser {
  KdfUser({required this.walletName});

  factory KdfUser.fromJson(String jsonString) {
    final json = jsonFromString(jsonString);
    return KdfUser(
      walletName: json.value<String>('wallet_name'),
    );
  }

  /// The name of the wallet. Since this is unique, it is equivalent to an
  /// account ID.
  final String walletName;

  JsonMap toJson() {
    return {'wallet_name': walletName};
  }
}
