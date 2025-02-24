// TODO: This may be better suited to be moved to the UI package.

import 'package:flutter/services.dart' show rootBundle;

final Set<String> _validMnemonicWords = {};

const _validLengths = [12, 15, 18, 21, 24];

enum MnemonicFailedReason {
  empty,
  customNotSupportedForHd,
  customNotAllowed,
  invalidLength,
}

class MnemonicValidator {
  Future<void> init() async {
    if (_validMnemonicWords.isEmpty) {
      final wordlist = await rootBundle.loadString(
        'packages/komodo_defi_types/assets/bip-0039/english-wordlist.txt',
      );
      _validMnemonicWords.addAll(
        wordlist.split('\n').map((w) => w.replaceAll(RegExp(r'\r?\n'), '')),
      );
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
      _validMnemonicWords.isNotEmpty,
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
      _validMnemonicWords.isNotEmpty,
      'Mnemonic wordlist is not initialized. '
      'Call MnemonicValidator.init() first.',
    );

    final inputWordsList = input.split(' ');

    if (!_validLengths.contains(inputWordsList.length)) {
      return false;
    }

    if (inputWordsList.any(
      (element) => !_validMnemonicWords.contains(element),
    )) {
      return false;
    }
    return true;
  }
}
