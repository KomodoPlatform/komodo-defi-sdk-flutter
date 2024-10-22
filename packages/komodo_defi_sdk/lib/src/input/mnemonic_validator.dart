import 'package:flutter/services.dart' show rootBundle;

final Set<String> _mnemonicWordlist = {};

const _validLengths = [12, 24];

class MnemonicValidator {
  static Future<void> init() async {
    if (_mnemonicWordlist.isEmpty) {
      final wordlist = await rootBundle.loadString(
          'packages/komodo_defi_sdk/assets/bip-0039/english-wordlist.txt');
      _mnemonicWordlist.addAll(wordlist.split('\n'));
    }
  }

  static bool validateString(String input) {
    assert(
      _mnemonicWordlist.isNotEmpty,
      'Mnemonic wordlist is not initialized. '
      'Call MnemonicValidator.init() first.',
    );

    final words = input.trim().split(' ');

    if (!_validLengths.contains(words.length)) {
      return false;
    }

    for (final word in words) {
      if (!_mnemonicWordlist.contains(word)) {
        return false;
      }
    }

    return true;
  }
}
