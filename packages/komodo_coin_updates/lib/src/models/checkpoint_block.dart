import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'adapters/checkpoint_block_adapter.dart';

class CheckPointBlock extends Equatable {
  const CheckPointBlock({
    this.height,
    this.time,
    this.hash,
    this.saplingTree,
  });

  factory CheckPointBlock.fromJson(Map<String, dynamic> json) {
    return CheckPointBlock(
      height: json['height'] as num?,
      time: json['time'] as num?,
      hash: json['hash'] as String?,
      saplingTree: json['saplingTree'] as String?,
    );
  }

  final num? height;
  final num? time;
  final String? hash;
  final String? saplingTree;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'height': height,
      'time': time,
      'hash': hash,
      'saplingTree': saplingTree,
    };
  }

  @override
  List<Object?> get props => <Object?>[height, time, hash, saplingTree];
}
