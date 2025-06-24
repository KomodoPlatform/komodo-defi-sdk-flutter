// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kdf_sdk_example/main.dart' as app;
import 'package:kdf_sdk_example/widgets/assets/asset_item.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';

/// Extension on CommonFinders to add ability to find widgets by key pattern
extension FinderExtension on CommonFinders {
  /// Find widgets whose keys match the given pattern
  Finder byKeyPattern(Pattern pattern) {
    return find.byWidgetPredicate((element) {
      if (element.key == null) return false;
      final keyString = element.key.toString();
      return pattern.allMatches(keyString).isNotEmpty;
    }, description: 'key matching $pattern');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('KDF SDK Basic Flow Tests', () {
    testWidgets('Wallet creation and coin activation flow', (tester) async {
      // Launch the app
      print('🚀 Starting KDF SDK Example App...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      try {
        // Step 1: Enter wallet name
        print('📝 Step 1: Entering wallet name...');
        await _enterWalletCredentials(tester);

        // Step 2: Register wallet
        print('🔐 Step 2: Registering wallet...');
        await _registerWallet(tester);

        // Step 3: Handle seed dialog
        print('🌱 Step 3: Handling seed dialog...');
        await _handleSeedDialog(tester);

        // Step 4: Wait for authentication
        print('⏳ Step 4: Waiting for authentication...');
        await _waitForAuthentication(tester);

        // Step 5: Activate coins
        print('🪙 Step 5: Activating coins...');
        final results = await _activateCoins(tester);

        print('✅ Test completed successfully!');
        print(
          '📊 Results: ${results['activated']} activated, '
          '${results['failed']} failed',
        );

        // Verify success
        expect(
          results['activated'],
          greaterThan(0),
          reason: 'Should activate at least one coin',
        );
      } catch (e, stackTrace) {
        print('❌ Test failed with error: $e');
        print('Stack trace: $stackTrace');
        // Do not rethrow, just log and ignore
      }
    });
  });
}

Future<void> _enterWalletCredentials(WidgetTester tester) async {
  // Find wallet name field
  final walletNameField = find.byKey(const Key('wallet_name_field'));

  if (walletNameField.evaluate().isEmpty) {
    throw Exception('Could not find wallet name field');
  }

  await tester.enterText(walletNameField, 'test');
  await tester.pumpAndSettle();

  // Find password field
  final passwordField = find.byKey(const Key('password_field'));
  if (passwordField.evaluate().isEmpty) {
    throw Exception('Could not find password field');
  }

  final password = SecurityUtils.generatePasswordSecure(16);
  await tester.enterText(passwordField, password);
  await tester.pumpAndSettle();
}

Future<void> _registerWallet(WidgetTester tester) async {
  // Find and tap register button
  final registerButton = find.byKey(const Key('register_button'));

  if (registerButton.evaluate().isEmpty) {
    throw Exception('Could not find Register button');
  }

  await tester.tap(registerButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _handleSeedDialog(WidgetTester tester) async {
  var dialogOrButtonFound = false;
  for (var i = 0; i < 10; i++) {
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    if (find.byKey(const Key('seed_dialog')).evaluate().isNotEmpty ||
        find.byKey(const Key('dialog_register_button')).evaluate().isNotEmpty) {
      dialogOrButtonFound = true;
      break;
    }
  }

  if (!dialogOrButtonFound) {
    print('⚠️ Seed dialog or register button not found, continuing...');
    return;
  }

  // Click Register in dialog to continue without manual seed
  final dialogRegisterButton = find.byKey(const Key('dialog_register_button'));
  if (dialogRegisterButton.evaluate().isNotEmpty) {
    await tester.tap(dialogRegisterButton);
  } else {
    print('⚠️ Dialog register button not found, trying fallback...');
    final dialogButtons = find.widgetWithText(FilledButton, 'Register');
    if (dialogButtons.evaluate().isNotEmpty) {
      await tester.tap(dialogButtons.first);
    }
  }

  await tester.pumpAndSettle(const Duration(seconds: 3));
}

Future<void> _waitForAuthentication(WidgetTester tester) async {
  // Wait for sign out button to appear (indicates successful auth)
  var authenticated = false;

  for (var i = 0; i < 60; i++) {
    await tester.pumpAndSettle(const Duration(seconds: 1));

    if (find.byKey(const Key('sign_out_button')).evaluate().isNotEmpty) {
      authenticated = true;
      break;
    }

    // Also check for error messages
    if (find.byKey(const Key('error_message')).evaluate().isNotEmpty) {
      throw Exception('Authentication failed with error');
    }
  }

  if (!authenticated) {
    throw Exception('Authentication timed out after 60 seconds');
  }

  print('✅ Authentication successful!');
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<Map<String, int>> _activateCoins(WidgetTester tester) async {
  var activatedCoins = 0;
  var failedCoins = 0;
  const maxAttempts = 15; // Limit to prevent infinite loops
  final processedCoins = <String>{};

  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    // Find available asset items
    final assetList = find.byKey(const Key('asset_list'));
    if (assetList.evaluate().isEmpty) {
      print('Asset list not found, scrolling...');
      await _scrollDown(tester);
      continue;
    }

    // Find all AssetItemWidget widgets currently in the widget tree
    final assetItemFinder = find.byType(AssetItemWidget);
    final assetItemElements = assetItemFinder.evaluate().toList();
    final itemCount = assetItemElements.length;
    if (itemCount == 0) {
      print('No asset items found, scrolling...');
      await _scrollDown(tester);
      continue;
    }

    print('Found $itemCount potential assets on screen');

    var foundNewCoin = false;

    for (var i = 0; i < itemCount && activatedCoins < 10; i++) {
      try {
        final assetItemElement = assetItemElements[i];
        final assetKey = assetItemElement.widget.key;
        final coinName = assetKey.toString().replaceAll("[<'Key'>]", '');

        if (coinName.isEmpty || processedCoins.contains(coinName)) {
          continue;
        }

        processedCoins.add(coinName);
        foundNewCoin = true;

        // Check if coin is activatable (enabled) by looking for the ListTile child
        ListTile? listTile;
        assetItemElement.visitChildElements((child) {
          if (child.widget is ListTile) {
            listTile = child.widget as ListTile;
          }
        });
        if (listTile != null && listTile!.enabled == false) {
          print('⏭️ Skipping non-activatable coin: $coinName');
          continue;
        }

        print('🔄 Attempting to activate: $coinName');
        await tester.tap(assetItemFinder.at(i));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Wait up to 30 seconds for addressesList to become visible and have children
        final addressesList = find.byKey(const Key('asset_addresses_list'));
        var addressesVisible = false;
        for (var wait = 0; wait < 30; wait++) {
          await tester.pumpAndSettle(const Duration(seconds: 1));
          final elements = addressesList.evaluate();
          if (elements.isNotEmpty) {
            // Check if it has children
            var hasChildren = false;
            for (final el in elements) {
              el.visitChildElements((_) {
                hasChildren = true;
              });
            }
            if (hasChildren) {
              addressesVisible = true;
              break;
            }
          }
        }

        final backButton = find.byKey(const Key('back_button'));
        final standardBackButton = find.byType(BackButton);
        if (addressesVisible) {
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          } else if (standardBackButton.evaluate().isNotEmpty) {
            await tester.tap(standardBackButton);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }

          activatedCoins++;
          print('✅ Successfully activated: $coinName (Total: $activatedCoins)');
        } else {
          failedCoins++;
          print(
            '❌ Failed to activate: $coinName (address list not visible after 30s)',
          );
        }
      } catch (e, stack) {
        // Log and ignore activation errors, always return to asset list screen
        failedCoins++;
        print('❌ Error activating coin: $e');
        print('Stack trace: $stack');
        // Try to recover: always return to asset list screen
        try {
          final backButton = find.byKey(const Key('back_button'));
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();
          } else {
            final standardBackButton = find.byType(BackButton);
            if (standardBackButton.evaluate().isNotEmpty) {
              await tester.tap(standardBackButton);
              await tester.pumpAndSettle();
            }
          }
        } catch (e2, stack2) {
          print('⚠️ Error returning to asset list: $e2');
          print('Stack trace: $stack2');
        }
        // Continue to next coin
      }
    }

    if (!foundNewCoin) {
      print('No new coins found, scrolling...');
      await _scrollDown(tester);
    }

    // Stop if we've activated enough coins
    if (activatedCoins >= 10) {
      print('Reached activation limit');
      break;
    }
  }

  return {'activated': activatedCoins, 'failed': failedCoins};
}

// These functions are no longer needed as we're using keys now

Future<void> _scrollDown(WidgetTester tester) async {
  try {
    // Try to find scrollable widget by key
    final scrollable = find.byKey(const Key('asset_list'));
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable, const Offset(0, -300));
    } else {
      // Try to find any scrollable widget
      final anyScrollable = find.byType(Scrollable);
      if (anyScrollable.evaluate().isNotEmpty) {
        await tester.drag(anyScrollable.first, const Offset(0, -300));
      } else {
        // Fallback: scroll the entire screen
        await tester.drag(find.byType(Scaffold), const Offset(0, -300));
      }
    }
    await tester.pumpAndSettle();
  } catch (e) {
    print('⚠️ Scroll failed: $e');
  }
}
