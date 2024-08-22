import 'package:komodo_defi_types/komodo_defi_types.dart';

class KdfUser {
  KdfUser({
    required this.uid,
    required this.walletName,
  });

  factory KdfUser.fromJson(String jsonString) {
    final json = jsonFromString(jsonString);
    return KdfUser(
      walletName: json.value<String>('wallet_name'),
      uid: json.value<String>('uid'),
    );
  }
  final String uid;
  final String walletName;

  JsonMap toJson() {
    return {'wallet_name': walletName, 'uid': uid};
  }
}
