import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

part 'adapters/links_adapter.dart';

class Links extends Equatable {
  const Links({this.github, this.homepage});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      github: json['github'] as String?,
      homepage: json['homepage'] as String?,
    );
  }

  final String? github;
  final String? homepage;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'github': github, 'homepage': homepage};
  }

  @override
  List<Object?> get props => <Object?>[github, homepage];
}
