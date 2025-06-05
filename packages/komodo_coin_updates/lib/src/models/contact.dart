import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'adapters/contact_adapter.dart';

class Contact extends Equatable {
  const Contact({this.email, this.github});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      email: json['email'] as String?,
      github: json['github'] as String?,
    );
  }

  final String? email;
  final String? github;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email, 'github': github};
  }

  @override
  List<Object?> get props => <Object?>[email, github];
}
