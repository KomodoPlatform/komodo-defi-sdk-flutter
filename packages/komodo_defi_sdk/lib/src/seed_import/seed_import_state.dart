part of 'seed_import_bloc.dart';

enum SeedImportStatus { initial, loading, success, failure }

class SeedImportState extends Equatable {
  const SeedImportState({
    required this.status,
    this.mnemonic,
    this.error,
  });

  const SeedImportState.initial() : this(status: SeedImportStatus.initial);

  final SeedImportStatus status;
  final Mnemonic? mnemonic;
  final String? error;

  SeedImportState copyWith({
    SeedImportStatus? status,
    Mnemonic? mnemonic,
    String? error,
  }) => SeedImportState(
        status: status ?? this.status,
        mnemonic: mnemonic ?? this.mnemonic,
        error: error,
      );

  @override
  List<Object?> get props => [status, mnemonic, error];
}

