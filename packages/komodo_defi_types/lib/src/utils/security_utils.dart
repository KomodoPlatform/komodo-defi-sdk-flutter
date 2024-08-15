import 'dart:math';

import 'package:komodo_defi_types/komodo_defi_types.dart';

// ignore: one_member_abstracts
abstract class SecurityUtils {
  static String securePassword(
    int length, {
    bool extendedSpecialCharacters = false,
  }) =>
      _generateSecurePassword(
        length,
        extendedSpecialCharacters: extendedSpecialCharacters,
      );
}

// TODO: unit tests

String _generateSecurePassword(
  int length, {
  bool extendedSpecialCharacters = false,
}) {
  const upperCaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const lowerCaseLetters = 'abcdefghijklmnopqrstuvwxyz';
  const digits = '0123456789';

  // Standard special characters that are generally safe in most contexts, including JSON
  const specialCharacters = '!@#%^&*()-_=+[]{}|;:,<>.?';

  // Optionally include extended special characters if requested
  const extendedSpecial = r'~`$^*+=<>?';

  final availableSpecialCharacters = extendedSpecialCharacters
      ? specialCharacters + extendedSpecial
      : specialCharacters;

  // Combine all the characters
  final allCharacters =
      upperCaseLetters + lowerCaseLetters + digits + availableSpecialCharacters;

  // Ensure the password length is at least 8 characters
  if (length < 8) {
    throw ArgumentError('Password length must be at least 8 characters.');
  }

  // Random number generator
  final random = Random.secure();

  // Pick one character from each category to ensure password strength
  final password = <String>[
    upperCaseLetters[random.nextInt(upperCaseLetters.length)],
    lowerCaseLetters[random.nextInt(lowerCaseLetters.length)],
    digits[random.nextInt(digits.length)],
    availableSpecialCharacters[
        random.nextInt(availableSpecialCharacters.length)],
  ];

  // Fill the rest of the password length with random characters from the pool
  for (var i = 4; i < length; i++) {
    password.add(allCharacters[random.nextInt(allCharacters.length)]);
  }

  // Shuffle the password to ensure randomness
  password.shuffle(random);

  // Join the list into a string and return it
  return password.join();
}

extension CensoredJsonMap on JsonMap {
  Map<String, dynamic> censor() {
    // Search recursively for the following keys and replace their values
    // with "*" characters.
    const sensitive = [
      'seed',
      'userpass',
      'passphrase',
      'password',
      'mnemonic',
      'private_key',
      'wif',
      'view_key',
      'spend_key',
      'address',
      'pubkey',
      'privkey',
      'userpass',
    ];

    return censorKeys(sensitive);
  }
}

// Example Test
void main() {
  final password = SecurityUtils.securePassword(24);
  final extendedPassword =
      SecurityUtils.securePassword(24, extendedSpecialCharacters: true);

  // ignore: avoid_print
  print('Password: $password');
  // ignore: avoid_print
  print('Extended Password: $extendedPassword');
}
