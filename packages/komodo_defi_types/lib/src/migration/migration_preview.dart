import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart'
    show WalletId, WithdrawalPreview;

part 'migration_preview.freezed.dart';
part 'migration_preview.g.dart';

@freezed
abstract class MigrationPreview with _$MigrationPreview {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory MigrationPreview({
    required WalletId fromWalletId,
    required WalletId toWalletId,
    required String pubkeyHash,
    required List<WithdrawalPreview> withdrawals,
  }) = _MigrationPreview;

  factory MigrationPreview.fromJson(JsonMap json) =>
      _$MigrationPreviewFromJson(json);
}
