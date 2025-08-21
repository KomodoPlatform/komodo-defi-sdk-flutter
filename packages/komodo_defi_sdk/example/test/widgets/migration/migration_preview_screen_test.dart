import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kdf_sdk_example/migrations/migrations.dart';
import 'package:kdf_sdk_example/widgets/migration/migration_preview_screen.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_asset_helper.dart';

class MockMigrationBloc extends MockBloc<MigrationEvent, MigrationState>
    implements MigrationBloc {}

void main() {
  group('MigrationPreviewScreen', () {
    late MockMigrationBloc mockMigrationBloc;

    setUp(() {
      mockMigrationBloc = MockMigrationBloc();
      when(() => mockMigrationBloc.state).thenReturn(MigrationState.initial());
    });

    final testCoins = [
      MigrationCoin.ready(
        asset: MockAssetHelper.mockKMD,
        balance: '12.5',
        estimatedFee: '0.0001',
      ),
      MigrationCoin.feeTooLow(
        asset: MockAssetHelper.mockBTC,
        balance: '0.0005',
        errorMessage: 'Balance too low to cover network fee',
      ),
      MigrationCoin.ready(
        asset: MockAssetHelper.mockRFOX,
        balance: '1500.0',
        estimatedFee: '0.0001',
      ),
    ];

    Widget createWidgetUnderTest({required List<MigrationCoin> coins}) {
      return MaterialApp(
        home: BlocProvider<MigrationBloc>.value(
          value: mockMigrationBloc,
          child: Scaffold(
            body: MigrationPreviewScreen(coins: coins),
          ),
        ),
      );
    }

    testWidgets('displays correct title and description', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coins: testCoins));

      expect(find.text('Migration Preview'), findsOneWidget);
      expect(
        find.textContaining(
          'We found the following assets in your legacy wallet that can be migrated to HD',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays table headers', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coins: testCoins));

      expect(find.text('Coin'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
    });

    testWidgets('displays all coins in the list', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coins: testCoins));

      // Check each coin is displayed
      expect(find.text('KMD'), findsOneWidget);
      expect(find.text('12.5'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);

      expect(find.text('BTC'), findsOneWidget);
      expect(find.text('0.0005'), findsOneWidget);
      expect(find.text('Fee too low'), findsOneWidget);

      expect(find.text('RFOX'), findsOneWidget);
      expect(find.text('1000'), findsOneWidget);
    });

    testWidgets('displays problem coins section when there are issues', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coins: testCoins));

      expect(find.text('Issues found:'), findsOneWidget);
      expect(
        find.textContaining('BTC: Balance too low to cover network fee'),
        findsOneWidget,
      );
    });

    testWidgets('displays correct summary for migratable coins', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coins: testCoins));

      expect(
        find.textContaining('Review the above and click "Confirm" to transfer 2 coins'),
        findsOneWidget,
      );
    });

    testWidgets('has Back and Confirm buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coins: testCoins));

      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Confirm & Migrate'), findsOneWidget);
      expect(find.byKey(const Key('migration_preview_back_button')), findsOneWidget);
      expect(find.byKey(const Key('confirm_migration_button')), findsOneWidget);
    });

    testWidgets('Back button triggers MigrationCancelled event', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coins: testCoins));

      await tester.tap(find.byKey(const Key('migration_preview_back_button')));
      await tester.pump();

      verify(() => mockMigrationBloc.add(const MigrationCancelled())).called(1);
    });

    testWidgets('Confirm button triggers MigrationConfirmed event', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coins: testCoins));

      await tester.tap(find.byKey(const Key('confirm_migration_button')));
      await tester.pump();

      verify(() => mockMigrationBloc.add(const MigrationConfirmed())).called(1);
    });

    testWidgets('disables Confirm button when no coins can be migrated', (tester) async {
      final problematicCoins = [
        MigrationCoin.feeTooLow(
          asset: const Asset(
            id: AssetId('BTC'),
            name: 'Bitcoin',
            symbol: 'BTC',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '0.0001',
          errorMessage: 'Balance too low',
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(coins: problematicCoins));

      final confirmButton = tester.widget<FilledButton>(
        find.byKey(const Key('confirm_migration_button')),
      );
      expect(confirmButton.onPressed, isNull);

      expect(
        find.text('No coins can be migrated at this time. Please resolve the issues above.'),
        findsOneWidget,
      );
    });

    testWidgets('displays correct status indicators for different coin statuses', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coins: testCoins));

      // Check for status indicators (icons)
      expect(find.byIcon(Icons.check_circle_outline), findsAtLeast(1)); // Ready coins
      expect(find.byIcon(Icons.warning), findsOneWidget); // Fee too low
    });

    testWidgets('displays coin symbols in circular containers', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coins: testCoins));

      // Check that coin symbols are displayed in containers
      expect(find.text('K'), findsOneWidget); // KMD first letter
      expect(find.text('B'), findsOneWidget); // BTC first letter
      expect(find.text('R'), findsOneWidget); // RFOX first letter
    });

    testWidgets('shows warning section only when problems exist', (tester) async {
      final cleanCoins = [
        MigrationCoin.ready(
          asset: MockAssetHelper.mockKMD,
          balance: '10.0',
          estimatedFee: '0.0001',
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(coins: cleanCoins));

      expect(find.text('Issues found:'), findsNothing);
    });

    testWidgets('displays correct text for single coin migration', (tester) async {
      final singleCoin = [testCoins.first];

      await tester.pumpWidget(createWidgetUnderTest(coins: singleCoin));

      expect(
        find.textContaining('transfer 1 coin to your HD wallet'),
        findsOneWidget,
      );
    });

    testWidgets('handles empty coin list gracefully', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coins: []));

      expect(find.byType(ListView), findsOneWidget);
      expect(
        find.text('No coins can be migrated at this time'),
        findsOneWidget,
      );
    });

    testWidgets('displays proper layout structure', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(coins: testCoins));

      // Verify main structure
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Row), findsAtLeastNWidgets(3)); // Button row + coin rows
    });
  });
}
