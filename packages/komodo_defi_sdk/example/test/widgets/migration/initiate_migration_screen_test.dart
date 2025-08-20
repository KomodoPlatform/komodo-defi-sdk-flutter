import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kdf_sdk_example/blocs/migration/migration_bloc.dart';
import 'package:kdf_sdk_example/blocs/migration/migration_models.dart';
import 'package:kdf_sdk_example/widgets/migration/initiate_migration_screen.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:mocktail/mocktail.dart';

class MockMigrationBloc extends MockBloc<MigrationEvent, MigrationState>
    implements MigrationBloc {}

void main() {
  group('InitiateMigrationScreen', () {
    late MockMigrationBloc mockMigrationBloc;

    setUp(() {
      mockMigrationBloc = MockMigrationBloc();
      when(() => mockMigrationBloc.state).thenReturn(MigrationState.initial());
    });

    Widget createWidgetUnderTest({
      KdfUser? sourceWallet,
      KdfUser? destinationWallet,
    }) {
      return MaterialApp(
        home: BlocProvider<MigrationBloc>.value(
          value: mockMigrationBloc,
          child: Scaffold(
            body: InitiateMigrationScreen(
              sourceWallet: sourceWallet,
              destinationWallet: destinationWallet,
            ),
          ),
        ),
      );
    }

    testWidgets('displays correct title and description', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Migrate Funds to HD Wallet'), findsOneWidget);
      expect(
        find.textContaining(
          'You are about to transfer all funds from your Legacy (Iguana) Wallet',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays default wallet names when wallets are null',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Legacy Wallet (Iguana mode)'), findsOneWidget);
      expect(find.text('My HD Wallet'), findsOneWidget);
    });

    testWidgets('displays actual wallet names when provided', (tester) async {
      final sourceWallet = KdfUser(
        walletId: WalletId(
          name: 'Test Legacy Wallet',
          authOptions: AuthOptions(
            derivationMethod: DerivationMethod.iguana,
            privKeyPolicy: PrivKeyPolicy.trezorPolicy,
          ),
        ),
      );
      final destinationWallet = KdfUser(
        walletId: WalletId(
          name: 'Test HD Wallet',
          authOptions: AuthOptions(
            derivationMethod: DerivationMethod.hdWallet,
            privKeyPolicy: PrivKeyPolicy.contextualPolicy,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(
        sourceWallet: sourceWallet,
        destinationWallet: destinationWallet,
      ));

      expect(find.text('Test Legacy Wallet'), findsOneWidget);
      expect(find.text('Test HD Wallet'), findsOneWidget);
    });

    testWidgets('displays important note about legacy wallet accessibility',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.textContaining(
          'Your legacy wallet will remain accessible, but its funds will be moved to the HD wallet',
        ),
        findsOneWidget,
      );
    });

    testWidgets('has Cancel and Start Migration buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Start Migration'), findsOneWidget);
      expect(find.byKey(const Key('start_migration_button')), findsOneWidget);
    });

    testWidgets('Start Migration button triggers MigrationInitiated event',
        (tester) async {
      final sourceWallet = KdfUser(
        walletId: WalletId(
          name: 'Source Wallet',
          authOptions: AuthOptions(
            derivationMethod: DerivationMethod.iguana,
            privKeyPolicy: PrivKeyPolicy.trezorPolicy,
          ),
        ),
      );
      final destinationWallet = KdfUser(
        walletId: WalletId(
          name: 'Dest Wallet',
          authOptions: AuthOptions(
            derivationMethod: DerivationMethod.hdWallet,
            privKeyPolicy: PrivKeyPolicy.contextualPolicy,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(
        sourceWallet: sourceWallet,
        destinationWallet: destinationWallet,
      ));

      await tester.tap(find.byKey(const Key('start_migration_button')));
      await tester.pump();

      verify(
        () => mockMigrationBloc.add(
          const MigrationInitiated(
            sourceWalletName: 'Source Wallet',
            destinationWalletName: 'Dest Wallet',
          ),
        ),
      ).called(1);
    });

    testWidgets('Cancel button pops the navigator', (tester) async {
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
                  child: const Scaffold(
                    body: InitiateMigrationScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(didPop, isTrue);
    });

    testWidgets('displays source and destination icons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('displays info icon with note', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('displays send icon on Start Migration button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final startButton = find.byKey(const Key('start_migration_button'));
      expect(startButton, findsOneWidget);

      final buttonWidget = tester.widget<FilledButton>(startButton);
      expect(buttonWidget.icon, isA<Icon>());
      final icon = buttonWidget.icon! as Icon;
      expect(icon.icon, equals(Icons.send));
    });
  });
}
