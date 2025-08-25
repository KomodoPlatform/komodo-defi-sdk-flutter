import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kdf_sdk_example/migrations/migrations.dart';
import 'package:kdf_sdk_example/widgets/migration/migration_widget.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

class MockMigrationBloc extends MockBloc<MigrationEvent, MigrationState>
    implements MigrationBloc {}

void main() {
  group('MigrationWidget', () {
    late MockMigrationBloc mockMigrationBloc;

    setUp(() {
      mockMigrationBloc = MockMigrationBloc();
      when(() => mockMigrationBloc.state).thenReturn(const MigrationState());
    });

    final testUser = KdfUser(
      walletId: WalletId(
        name: 'Test Wallet',
        authOptions: AuthOptions(
          derivationMethod: DerivationMethod.iguana,
          privKeyPolicy: PrivKeyPolicy.trezorPolicy,
        ),
      ),
    );

    Widget createWidgetUnderTest({
      KdfUser? sourceWallet,
      KdfUser? destinationWallet,
    }) {
      return MaterialApp(
        home: BlocProvider<MigrationBloc>.value(
          value: mockMigrationBloc,
          child: MigrationWidget(
            sourceWallet: sourceWallet,
            destinationWallet: destinationWallet,
          ),
        ),
      );
    }

    testWidgets('displays as dialog with proper constraints', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Dialog), findsOneWidget);

      final containerWidget = tester.widget<Container>(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(Container),
        ).first,
      );

      expect(containerWidget.constraints!.maxWidth, equals(800));
      expect(containerWidget.constraints!.maxHeight, equals(700));
    });

    testWidgets('displays app bar with correct title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Wallet Migration'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows close button when not in progress', (tester) async {
      when(() => mockMigrationBloc.state).thenReturn(const MigrationState());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byKey(const Key('close_migration_button')), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('hides close button when migration is in progress', (tester) async {
      when(() => mockMigrationBloc.state).thenReturn(
        const MigrationState(status: MigrationFlowStatus.scanning),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byKey(const Key('close_migration_button')), findsNothing);
    });

    testWidgets('close button triggers MigrationCancelled and pops navigator', (tester) async {
      when(() => mockMigrationBloc.state).thenReturn(MigrationState.initial());

      bool didPop = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onPopPage: (route, result) {
              didPop = true;
              return route.didPop(result);
            },
            pages: [
              MaterialPage(
                child: BlocProvider<MigrationBloc>.value(
                  value: mockMigrationBloc,
                  child: const MigrationWidget(),
                ),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('close_migration_button')));
      await tester.pumpAndSettle();

      verify(() => mockMigrationBloc.add(const MigrationCancelled())).called(1);
      expect(didPop, isTrue);
    });

    testWidgets('displays InitiateMigrationScreen for idle state', (tester) async {
      when(() => mockMigrationBloc.state).thenReturn(const MigrationState());

      await tester.pumpWidget(createWidgetUnderTest(sourceWallet: testUser));

      expect(find.text('Migrate Funds to HD Wallet'), findsOneWidget);
      expect(find.text('Start Migration'), findsOneWidget);
    });

    testWidgets('displays ScanningBalancesScreen for scanning state', (tester) async {
      when(() => mockMigrationBloc.state).thenReturn(
        const MigrationState(status: MigrationFlowStatus.scanning),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Migrating to HD Wallet'), findsOneWidget);
      expect(find.text('Step 1 of 3: Scanning your assets...'), findsOneWidget);
    });

    testWidgets('displays MigrationPreviewScreen for preview state', (tester) async {
      final coins = [
        MigrationCoin.ready(
          asset: const Asset(
            id: AssetId('KMD'),
            name: 'Komodo',
            symbol: 'KMD',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '10.0',
        ),
      ];

      when(() => mockMigrationBloc.state).thenReturn(
        MigrationState(
          status: MigrationFlowStatus.preview,
          coins: coins,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Migration Preview'), findsOneWidget);
      expect(find.text('Coin'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
    });

    testWidgets('displays TransferringFundsScreen for transferring state', (tester) async {
      final coins = [
        MigrationCoin.ready(
          asset: const Asset(
            id: AssetId('KMD'),
            name: 'Komodo',
            symbol: 'KMD',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '10.0',
        ),
      ];

      when(() => mockMigrationBloc.state).thenReturn(
        MigrationState(
          status: MigrationFlowStatus.transferring,
          coins: coins,
          currentCoinIndex: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Migrating Funds...'), findsOneWidget);
      expect(find.text('Step 2 of 3: Transferring assets to HD'), findsOneWidget);
    });

    testWidgets('displays MigrationResultsScreen for completed state', (tester) async {
      final coins = [
        MigrationCoin.transferred(
          asset: const Asset(
            id: AssetId('KMD'),
            name: 'Komodo',
            symbol: 'KMD',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '10.0',
          transactionId: 'tx123',
        ),
      ];

      when(() => mockMigrationBloc.state).thenReturn(
        MigrationState.completed(coins: coins),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Migration Complete'), findsOneWidget);
      expect(find.text('Transferred'), findsOneWidget);
    });

    testWidgets('displays error screen for error state', (tester) async {
      when(() => mockMigrationBloc.state).thenReturn(
        const MigrationState(
          status: MigrationFlowStatus.error,
          errorMessage: 'Test error occurred',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Migration Error'), findsOneWidget);
      expect(find.text('Test error occurred'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('error screen has Close and Try Again buttons', (tester) async {
      when(() => mockMigrationBloc.state).thenReturn(
        const MigrationState(
          status: MigrationFlowStatus.error,
          errorMessage: 'Test error',
          sourceWalletName: 'Source',
          destinationWalletName: 'Dest',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.byKey(const Key('close_error_button')), findsOneWidget);
      expect(find.byKey(const Key('retry_migration_button')), findsOneWidget);
    });

    testWidgets('Try Again button clears error and restarts migration', (tester) async {
      when(() => mockMigrationBloc.state).thenReturn(
        const MigrationState(
          status: MigrationFlowStatus.error,
          errorMessage: 'Test error',
          sourceWalletName: 'Source',
          destinationWalletName: 'Dest',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byKey(const Key('retry_migration_button')));
      await tester.pump();

      verify(() => mockMigrationBloc.add(const MigrationErrorCleared())).called(1);
      verify(() => mockMigrationBloc.add(
        const MigrationInitiated(
          sourceWalletName: 'Source',
          destinationWalletName: 'Dest',
        ),
      )).called(1);
    });

    testWidgets('shows snackbar on error state', (tester) async {
      when(() => mockMigrationBloc.state).thenReturn(const MigrationState());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Simulate error state change
      when(() => mockMigrationBloc.state).thenReturn(
        const MigrationState(
          status: MigrationFlowStatus.error,
          errorMessage: 'Network error',
        ),
      );

      // Rebuild with error state
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Network error'), findsAtLeastNWidgets(1));
    });

    testWidgets('error screen shows help text', (tester) async {
      when(() => mockMigrationBloc.state).thenReturn(
        const MigrationState(
          status: MigrationFlowStatus.error,
          errorMessage: 'Test error',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.textContaining(
          'If the problem persists, please check your network connection',
        ),
        findsOneWidget,
      );
    });

    testWidgets('error screen mentions partial processing when coins exist', (tester) async {
      final coins = [
        MigrationCoin.transferred(
          asset: const Asset(
            id: AssetId('KMD'),
            name: 'Komodo',
            symbol: 'KMD',
            decimals: 8,
            logoUrl: '',
          ),
          balance: '10.0',
          transactionId: 'tx123',
        ),
      ];

      when(() => mockMigrationBloc.state).thenReturn(
        MigrationState(
          status: MigrationFlowStatus.error,
          errorMessage: 'Test error',
          coins: coins,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.text('Some coins may have been partially processed.'),
        findsOneWidget,
      );
    });
  });

  group('MigrationDialog', () {
    testWidgets('show method creates and displays dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    MigrationDialog.show(context);
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Wallet Migration'), findsOneWidget);
    });
  });

  group('MigrationPage', () {
    late MockMigrationBloc mockMigrationBloc;

    setUp(() {
      mockMigrationBloc = MockMigrationBloc();
      when(() => mockMigrationBloc.state).thenReturn(const MigrationState());
    });

    Widget createPageUnderTest() {
      return MaterialApp(
        home: BlocProvider<MigrationBloc>.value(
          value: mockMigrationBloc,
          child: const MigrationPage(),
        ),
      );
    }

    testWidgets('displays as full page with app bar', (tester) async {
      await tester.pumpWidget(createPageUnderTest());

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Wallet Migration'), findsOneWidget);
    });

    testWidgets('shows back arrow when not in progress', (tester) async {
      when(() => mockMigrationBloc.state).thenReturn(const MigrationState());

      await tester.pumpWidget(createPageUnderTest());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('hides back button when migration is in progress', (tester) async {
      when(() => mockMigrationBloc.state).thenReturn(
        const MigrationState(status: MigrationFlowStatus.scanning),
      );

      await tester.pumpWidget(createPageUnderTest());

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });
  });
}
