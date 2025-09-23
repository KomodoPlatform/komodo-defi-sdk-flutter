part of 'seed_import_bloc.dart';

abstract class SeedImportEvent extends Equatable {
  const SeedImportEvent();

  @override
  List<Object?> get props => [];
}

class SeedImportRequested extends SeedImportEvent {
  const SeedImportRequested({
    this.fileName,
    this.bytes,
    this.text,
    required this.password,
  });

  final String? fileName;
  final Uint8List? bytes;
  final String? text;
  final String password;

  @override
  List<Object?> get props => [fileName, bytes, text, password];
}

class SeedImportReset extends SeedImportEvent {
  const SeedImportReset();
}

