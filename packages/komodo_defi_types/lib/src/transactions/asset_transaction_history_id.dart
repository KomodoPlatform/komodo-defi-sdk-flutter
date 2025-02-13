import 'package:equatable/equatable.dart';
import 'package:komodo_defi_types/src/assets/asset_id.dart';
import 'package:komodo_defi_types/src/auth/kdf_user.dart';

/// Compound unique for the transaction history of an asset for a given wallet.
/// This is used to store the transaction history in key-value storage without
/// collisions when using multiple wallets on the same device.
class AssetTransactionHistoryId extends Equatable {
  const AssetTransactionHistoryId(this.walletId, this.assetId);

  /// The wallet for which the transaction history is stored (cached). This is
  /// used to uniquely identify the transaction history for a given wallet and
  /// asset.
  final WalletId walletId;

  /// The asset for which the transaction history is stored (cached).
  final AssetId assetId;

  @override
  List<Object?> get props => [walletId, assetId];
}
