import 'package:komodo_defi_types/types.dart';

enum DerivationType {
  hd,
  legacy,
}

class Pubkey {
  Pubkey({
    required this.pubkey,
    // required this.derivationType,
    required this.assetId,
    required this.keys,
  });
  //
  AssetId assetId;
  String pubkey;
  // DerivationType derivationType;

  // Record type of address index and public key
  List<(int index, String pubkey)> keys;

  // TODO:
  // String derivationPath;
}
