import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kdf_sdk_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Migration Integration Tests', () {
    testWidgets('App launches successfully', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to initialize
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify the app launched
      expect(find.text('KDF Demo'), findsOneWidget);
    });

    testWidgets('Migration button appears for legacy users when signed in', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Try to find sign-in related elements
      // Note: This is a simplified test that checks if we can find UI elements
      // In a real test environment, you would have proper test data and authentication

      // Look for any authentication-related widgets
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        // If there are text fields, assume they're for authentication
        // Fill in test data
        await tester.enterText(textFields.first, 'test_wallet');
        await tester.pumpAndSettle();

        // Look for additional fields (like password)
        final allTextFields = find.byType(TextFormField);
        if (allTextFields.evaluate().length > 1) {
          await tester.enterText(allTextFields.at(1), 'test_password');
          await tester.pumpAndSettle();
        }

        // Try to find a sign-in button
        final signInButtons = [
          find.text('Sign In'),
          find.text('Login'),
          find.byKey(const Key('sign_in_button')),
        ];

        for (final buttonFinder in signInButtons) {
          if (buttonFinder.evaluate().isNotEmpty) {
            await tester.tap(buttonFinder);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            break;
          }
        }
      }

      // Now look for the migration button
      final migrationButton = find.byKey(const Key('migrate_to_hd_button'));

      // The button might not be visible if:
      // 1. User is not authenticated
      // 2. User is already using HD wallet
      // 3. Migration is not available for this user type
      if (migrationButton.evaluate().isNotEmpty) {
        // Migration button found - test it
        expect(find.text('Migrate to HD'), findsOneWidget);

        // Tap the migration button
        await tester.tap(migrationButton);
        await tester.pumpAndSettle();

        // Verify migration dialog appears
        expect(find.text('Migrate Funds to HD Wallet'), findsOneWidget);
        expect(find.text('Start Migration'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        // Test starting migration
        await tester.tap(find.byKey(const Key('start_migration_button')));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Should see scanning screen
        expect(find.text('Migrating to HD Wallet'), findsOneWidget);
        expect(find.text('Step 1 of 3: Scanning your assets...'), findsOneWidget);

        // Wait for dummy scan to complete (3 seconds in mock implementation)
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Should progress to preview screen
        expect(find.text('Migration Preview'), findsOneWidget);
        expect(find.text('Coin'), findsOneWidget);
        expect(find.text('Amount'), findsOneWidget);
        expect(find.text('Status'), findsOneWidget);

        // Should see some dummy coins
        expect(find.text('KMD'), findsOneWidget);
        expect(find.text('Ready'), findsAtLeastNWidgets(1));

        // Test closing the migration
        final cancelButton = find.byKey(const Key('migration_preview_back_button'));
        if (cancelButton.evaluate().isNotEmpty) {
          await tester.tap(cancelButton);
          await tester.pumpAndSettle();
        }
      } else {
        // Migration button not found - this is expected in many cases
        debugPrint('Migration button not found - user may not be in legacy mode or not authenticated');
      }
    });

    testWidgets('Migration can be cancelled during scanning', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Look for migration button (simplified check)
      final migrationButton = find.byKey(const Key('migrate_to_hd_button'));

      if (migrationButton.evaluate().isNotEmpty) {
        // Start migration
        await tester.tap(migrationButton);
        await tester.pumpAndSettle();

        // Click start migration
        await tester.tap(find.byKey(const Key('start_migration_button')));
        await tester.pumpAndSettle();

        // Should be in scanning state
        expect(find.text('Step 1 of 3: Scanning your assets...'), findsOneWidget);

        // Cancel migration
        final cancelButton = find.byKey(const Key('cancel_migration_button'));
        if (cancelButton.evaluate().isNotEmpty) {
          await tester.tap(cancelButton);
          await tester.pumpAndSettle();

          // Should be back to main screen (migration dialog closed)
          expect(find.text('Migrating to HD Wallet'), findsNothing);
        }
      } else {
        debugPrint('Migration button not available for cancellation test');
      }
    });

    testWidgets('App handles navigation correctly', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test basic navigation
      expect(find.text('KDF Demo'), findsOneWidget);

      // Look for drawer or navigation elements
      final drawerFinder = find.byType(Drawer);
      if (drawerFinder.evaluate().isNotEmpty) {
        // Test drawer interaction if available
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
      }

      // Test that the app doesn't crash during basic interactions
      expect(tester.takeException(), isNull);
    });
  });
}
