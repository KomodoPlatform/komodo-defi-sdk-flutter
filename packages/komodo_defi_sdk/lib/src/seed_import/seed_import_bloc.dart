import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/src/seed_import/seed_import_manager.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';

part 'seed_import_event.dart';
part 'seed_import_state.dart';

class SeedImportBloc extends Bloc<SeedImportEvent, SeedImportState> {
  SeedImportBloc({required SeedImportManager manager})
      : _manager = manager,
        super(const SeedImportState.initial()) {
    on<SeedImportRequested>(_onImportRequested);
    on<SeedImportReset>(_onReset);
  }

  final SeedImportManager _manager;

  Future<void> _onImportRequested(
    SeedImportRequested event,
    Emitter<SeedImportState> emit,
  ) async {
    emit(state.copyWith(status: SeedImportStatus.loading, error: null));
    try {
      final mnemonic = await _manager.importAny(
        fileName: event.fileName,
        bytes: event.bytes,
        text: event.text,
        password: event.password,
      );
      emit(state.copyWith(status: SeedImportStatus.success, mnemonic: mnemonic));
    } catch (e) {
      emit(state.copyWith(status: SeedImportStatus.failure, error: e.toString()));
    }
  }

  void _onReset(SeedImportReset event, Emitter<SeedImportState> emit) {
    emit(const SeedImportState.initial());
  }
}

