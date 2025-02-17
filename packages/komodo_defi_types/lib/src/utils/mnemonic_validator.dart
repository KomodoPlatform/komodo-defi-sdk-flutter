// TODO: This may be better suited to be moved to the UI package.

import 'package:flutter/services.dart' show rootBundle;

final Set<String> _mnemonicWordlist = {};

const _validLengths = [12, 15, 18, 21, 24];

enum MnemonicFailedReason {
  empty,
  customNotSupportedForHd,
  customNotAllowed,
  invalidLength,
}

class MnemonicValidator {
  Future<void> init() async {
    if (_mnemonicWordlist.isEmpty) {
      final wordlist = await rootBundle.loadString(
        'packages/komodo_defi_types/assets/bip-0039/english-wordlist.txt',
      );
      _mnemonicWordlist.addAll(wordlist.split('\n'));
    }
  }

  MnemonicFailedReason? validateMnemonic(
    String input, {
    required bool isHd,
    int? minWordCount,
    int? maxWordCount,
    bool allowCustomSeed = false,
  }) {
    assert(
      _mnemonicWordlist.isNotEmpty,
      'Mnemonic wordlist is not initialized. '
      'Call MnemonicValidator.init() first.',
    );

    final words = input.trim().split(' ');

    if (words.isEmpty) {
      return MnemonicFailedReason.empty;
    }

    if (minWordCount != null && words.length < minWordCount) {
      return MnemonicFailedReason.invalidLength;
    }

    if (maxWordCount != null && words.length > maxWordCount) {
      return MnemonicFailedReason.invalidLength;
    }

    final isValidBip39 = validateBip39(input);

    if (isValidBip39) {
      return null;
    }

    if (isHd) {
      return MnemonicFailedReason.customNotSupportedForHd;
    }

    if (!allowCustomSeed) {
      return MnemonicFailedReason.customNotAllowed;
    }
    return null;
  }

  bool validateBip39(String input) {
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
