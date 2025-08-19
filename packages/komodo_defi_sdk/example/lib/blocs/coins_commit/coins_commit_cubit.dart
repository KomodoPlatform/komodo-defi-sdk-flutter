import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

class CoinsCommitState extends Equatable {
  const CoinsCommitState({
    this.current,
    this.latest,
    this.isLoading = false,
    this.errorMessage,
  });

  final String? current;
  final String? latest;
  final bool isLoading;
  final String? errorMessage;

  /// Returns the current commit hash truncated to 7 characters
  String? get currentTruncated =>
      current?.substring(0, current!.length >= 7 ? 7 : current!.length);

  /// Returns the latest commit hash truncated to 7 characters
  String? get latestTruncated =>
      latest?.substring(0, latest!.length >= 7 ? 7 : latest!.length);

  CoinsCommitState copyWith({
    String? current,
    String? latest,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CoinsCommitState(
      current: current ?? this.current,
      latest: latest ?? this.latest,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [current, latest, isLoading, errorMessage];
}

class CoinsCommitCubit extends Cubit<CoinsCommitState> {
  CoinsCommitCubit({required KomodoDefiSdk sdk})
    : _sdk = sdk,
      super(const CoinsCommitState(isLoading: true));

  final KomodoDefiSdk _sdk;

  Future<void> load() async {
    try {
      emit(state.copyWith(isLoading: true));
      final current = await _sdk.assets.currentCoinsCommit;
      final latest = await _sdk.assets.latestCoinsCommit;
      emit(CoinsCommitState(current: current, latest: latest));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
