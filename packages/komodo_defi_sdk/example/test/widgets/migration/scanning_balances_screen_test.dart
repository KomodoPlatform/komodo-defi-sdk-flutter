import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kdf_sdk_example/migrations/migrations.dart';
import 'package:kdf_sdk_example/widgets/migration/scanning_balances_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockMigrationBloc extends MockBloc<MigrationEvent, MigrationState>
    implements MigrationBloc {}

void main() {
  group('ScanningBalancesScreen', () {
    late MockMigrationBloc mockMigrationBloc;

    setUp(() {
      mockMigrationBloc = MockMigrationBloc();
      when(() => mockMigrationBloc.state).thenReturn(MigrationState.scanning());
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<MigrationBloc>.value(
          value: mockMigrationBloc,
          child: const Scaffold(
            body: ScanningBalancesScreen(),
          ),
        ),
      );
    }

    testWidgets('displays correct title and step indicator', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Migrating to HD Wallet'), findsOneWidget);
      expect(find.text('Step 1 of 3: Scanning your assets...'), findsOneWidget);
    });

    testWidgets('displays loading indicator', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays scanning description', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.text('Please wait while we check your legacy wallet for funds.'),
        findsOneWidget,
      );
    });

    testWidgets('displays tip card with helpful information', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Tip:'), findsOneWidget);
      expect(
        find.textContaining(
          'This may take a few moments if you have many assets',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('has Cancel Migration button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Cancel Migration'), findsOneWidget);
      expect(find.byKey(const Key('cancel_migration_button')), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('Cancel button triggers MigrationCancelled event and pops navigator',
        (tester) async {
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
                    body: ScanningBalancesScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('cancel_migration_button')));
      await tester.pumpAndSettle();

      verify(() => mockMigrationBloc.add(const MigrationCancelled())).called(1);
      expect(didPop, isTrue);
    });

    testWidgets('displays proper layout with spacing', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify main column structure
      expect(find.byType(Column), findsAtLeastNWidgets(1));

      // Verify card structure for tip
      expect(find.byType(Card), findsOneWidget);

      // Verify proper button styling
      final cancelButton = find.byKey(const Key('cancel_migration_button'));
      expect(cancelButton, findsOneWidget);

      final buttonWidget = tester.widget<OutlinedButton>(cancelButton);
      expect(buttonWidget.child, isA<Row>()); // Button with icon and text
    });

    testWidgets('has proper accessibility labels', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify text is readable by screen readers
      expect(
        tester.getSemantics(find.text('Migrating to HD Wallet')),
        matchesSemantics(
          label: 'Migrating to HD Wallet',
          textDirection: TextDirection.ltr,
        ),
      );
    });
  });
}
