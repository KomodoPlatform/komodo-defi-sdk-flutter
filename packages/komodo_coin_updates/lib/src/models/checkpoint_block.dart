import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkpoint_block.freezed.dart';
part 'checkpoint_block.g.dart';

@freezed
abstract class CheckPointBlock with _$CheckPointBlock {
  const factory CheckPointBlock({
    num? height,
    num? time,
    String? hash,
    String? saplingTree,
  }) = _CheckPointBlock;

  factory CheckPointBlock.fromJson(Map<String, dynamic> json) =>
      _$CheckPointBlockFromJson(json);
}
