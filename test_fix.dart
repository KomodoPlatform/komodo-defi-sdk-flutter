#!/usr/bin/env dart
// Test script to verify the fix for the P2P disable with seed nodes error

import 'dart:io';
// Add the packages directory to the import path
import 'packages/komodo_defi_framework/lib/src/config/kdf_startup_config.dart';

void main() async {
  print(
    'Testing KdfStartupConfig fix for disableP2p + seedNodes configuration...\n',
  );

  // Test 1: disableP2p = true should result in no seed nodes
  print('Test 1: Creating config with disableP2p=true');
  try {
    final config = await KdfStartupConfig.generateWithDefaults(
      walletName: 'test_wallet',
      walletPassword: 'test_password_123',
      enableHd: false,
      disableP2p: true,
      // Note: we're not explicitly passing seedNodes, so defaults would normally be used
    );

    final encoded = config.encodeStartParams();

    print('✅ Config created successfully');
    print('   seedNodes in config: ${config.seedNodes}');
    print('   disableP2p: ${config.disableP2p}');
    print(
      '   seednodes in encoded params: ${encoded.containsKey('seednodes') ? encoded['seednodes'] : 'NOT PRESENT'}',
    );
    print('   disable_p2p in encoded params: ${encoded['disable_p2p']}');

    // Verify that when P2P is disabled, seed nodes are null
    assert(
      config.seedNodes == null,
      'seedNodes should be null when P2P is disabled',
    );
    assert(
      !encoded.containsKey('seednodes'),
      'seednodes should not be in encoded params when P2P is disabled',
    );

    print('   ✅ Test 1 PASSED: No seed nodes when P2P is disabled\n');
  } catch (e) {
    print('   ❌ Test 1 FAILED: $e\n');
    exit(1);
  }

  // Test 2: disableP2p = false should use default seed nodes
  print('Test 2: Creating config with disableP2p=false');
  try {
    final config = await KdfStartupConfig.generateWithDefaults(
      walletName: 'test_wallet',
      walletPassword: 'test_password_123',
      enableHd: false,
      disableP2p: false,
    );

    final encoded = config.encodeStartParams();

    print('✅ Config created successfully');
    print('   seedNodes in config: ${config.seedNodes}');
    print('   disableP2p: ${config.disableP2p}');
    print('   seednodes in encoded params: ${encoded['seednodes']}');
    print('   disable_p2p in encoded params: ${encoded['disable_p2p']}');

    // Verify that when P2P is enabled, seed nodes are present
    assert(
      config.seedNodes != null && config.seedNodes!.isNotEmpty,
      'seedNodes should be present when P2P is enabled',
    );
    assert(
      encoded.containsKey('seednodes'),
      'seednodes should be in encoded params when P2P is enabled',
    );

    print('   ✅ Test 2 PASSED: Default seed nodes when P2P is enabled\n');
  } catch (e) {
    print('   ❌ Test 2 FAILED: $e\n');
    exit(1);
  }

  // Test 3: disableP2p = null (default) should use default seed nodes
  print('Test 3: Creating config with disableP2p=null (default)');
  try {
    final config = await KdfStartupConfig.generateWithDefaults(
      walletName: 'test_wallet',
      walletPassword: 'test_password_123',
      enableHd: false,
      // disableP2p not specified, should default to null/false behavior
    );

    final encoded = config.encodeStartParams();

    print('✅ Config created successfully');
    print('   seedNodes in config: ${config.seedNodes}');
    print('   disableP2p: ${config.disableP2p}');
    print('   seednodes in encoded params: ${encoded['seednodes']}');
    print(
      '   disable_p2p in encoded params: ${encoded.containsKey('disable_p2p') ? encoded['disable_p2p'] : 'NOT PRESENT'}',
    );

    // Verify that default behavior includes seed nodes
    assert(
      config.seedNodes != null && config.seedNodes!.isNotEmpty,
      'seedNodes should be present by default',
    );
    assert(
      encoded.containsKey('seednodes'),
      'seednodes should be in encoded params by default',
    );

    print('   ✅ Test 3 PASSED: Default behavior includes seed nodes\n');
  } catch (e) {
    print('   ❌ Test 3 FAILED: $e\n');
    exit(1);
  }

  // Test 4: noAuthStartup with disableP2p = true
  print('Test 4: Creating noAuthStartup config with disableP2p=true');
  try {
    final config = await KdfStartupConfig.noAuthStartup();

    final encoded = config.encodeStartParams();

    print('✅ Config created successfully');
    print('   seedNodes in config: ${config.seedNodes}');
    print('   disableP2p: ${config.disableP2p}');
    print(
      '   seednodes in encoded params: ${encoded.containsKey('seednodes') ? encoded['seednodes'] : 'NOT PRESENT'}',
    );
    print('   disable_p2p in encoded params: ${encoded['disable_p2p']}');

    // Verify that when P2P is disabled, seed nodes are null
    assert(
      config.seedNodes == null,
      'seedNodes should be null when P2P is disabled in noAuthStartup',
    );
    assert(
      !encoded.containsKey('seednodes'),
      'seednodes should not be in encoded params when P2P is disabled in noAuthStartup',
    );

    print(
      '   ✅ Test 4 PASSED: noAuthStartup works correctly with P2P disabled\n',
    );
  } catch (e) {
    print('   ❌ Test 4 FAILED: $e\n');
    exit(1);
  }

  print('🎉 All tests passed! The fix is working correctly.');
  print('');
  print('Summary of the fix:');
  print('- When disableP2p=true, seedNodes are set to null');
  print('- When disableP2p=false or null, default seed nodes are used');
  print(
    '- The encodeStartParams() method only includes seednodes when P2P is enabled',
  );
  print(
    '- This prevents the "Cannot disable P2P while seed nodes are configured" error',
  );
}
