import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/src/assets/asset_id.dart' show AssetId;

class PrivateKey extends Equatable {
  const PrivateKey({
    required this.assetId,
    required this.publicKey,
    required this.privateKey,
    this.hdInfo,
  });

  final AssetId assetId;
  final String publicKey;
  final String privateKey;
  final PrivateKeyHdInfo? hdInfo;

  JsonMap toJson() {
    return {
      'asset_id': assetId,
      'public_key': publicKey,
      'private_key': privateKey,
      if (hdInfo != null) 'hd_info': hdInfo!.toJson(),
    };
  }

  @override
  List<Object?> get props => [assetId, publicKey, privateKey];
}

class PrivateKeyHdInfo extends Equatable {
  const PrivateKeyHdInfo({
    required this.derivationPath,
  });

  final String derivationPath;

  JsonMap toJson() {
    return {
      'derivation_path': derivationPath,
    };
  }

  @override
  List<Object?> get props => [derivationPath];
}
