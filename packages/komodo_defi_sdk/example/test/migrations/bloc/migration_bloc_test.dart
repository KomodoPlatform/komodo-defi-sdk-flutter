import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';

import '../../../lib/migrations/bloc/migration_bloc_exports.dart';

class MockKomodoDefiSdk extends Mock implements KomodoDefiSdk {}

void main() {
  group('MigrationBloc (simplified)', () {
    late MockKomodoDefiSdk mockSdk;
    late MigrationBloc bloc;

    setUp(() {
      mockSdk = MockKomodoDefiSdk();
      // We do not trigger any events that would access sdk.assets in these
      // minimal tests, so no additional stubbing is required.
      bloc = MigrationBloc(sdk: mockSdk);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is idle', () {
      expect(bloc.state.status, MigrationFlowStatus.idle);
      expect(bloc.state.coins, isEmpty);
    });
  });
}
