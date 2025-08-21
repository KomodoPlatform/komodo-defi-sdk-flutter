import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kdf_sdk_example/migrations/migrations.dart';
import 'package:kdf_sdk_example/widgets/migration/initiate_migration_screen.dart';

void main() {
  group('Simple Migration Test', () {
    late MigrationBloc migrationBloc;

    setUp(() {
      migrationBloc = MigrationBloc();
    });

    tearDown(() {
      migrationBloc.close();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<MigrationBloc>.value(
          value: migrationBloc,
          child: const Scaffold(
            body: InitiateMigrationScreen(),
          ),
        ),
      );
    }

    testWidgets('displays migration screen title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Migrate Funds to HD Wallet'), findsOneWidget);
    });

    testWidgets('has start migration button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Start Migration'), findsOneWidget);
      expect(find.byKey(const Key('start_migration_button')), findsOneWidget);
    });

    testWidgets('has cancel button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays wallet information section', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Legacy Wallet (Iguana mode)'), findsOneWidget);
      expect(find.text('My HD Wallet'), findsOneWidget);
    });

    testWidgets('displays description text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(
        find.textContaining('You are about to transfer all funds'),
        findsOneWidget,
      );
    });

    testWidgets('start migration button triggers event', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final button = find.byKey(const Key('start_migration_button'));
      await tester.tap(button);
      await tester.pump();

      // Verify the bloc state changed to scanning
      expect(migrationBloc.state.status, equals(MigrationFlowStatus.scanning));
    });

    testWidgets('shows proper icons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('displays important note', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(
        find.textContaining('Your legacy wallet will remain accessible'),
        findsOneWidget,
      );
    });
  });
}
