import 'dart:math';

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
  const specialCharacters = r'!@#$%^&*()-_=+[]{}|;:,.<>?/`~';
  const specialCharactersExtended =
      r'±÷×‰∞∑∆€£¥₹©®™♠♥♦♣☺☻♀♂•○◘◙©®™°µ²³½¼¾¿¡†‡±÷×√∞∫∂∑∆π$¢£¥€`~!@#\$%^&*()-_=+[]{}|;:\,.<>?/«»‹›©®™¤¬¦§¶‡';

  // Combine all the characters
  final allCharacters = upperCaseLetters +
      lowerCaseLetters +
      digits +
      specialCharacters +
      (extendedSpecialCharacters == true ? specialCharactersExtended : '');

  // Ensure the password length is at least 8 characters
  if (length < 8) {
    throw ArgumentError('Password length must be at least 8 characters.');
  }

  // Random number generator
  final random = Random.secure();

  // Pick one character from each category to ensure password strength
  final password = <String>[]
    // ignore: prefer_inlined_adds
    ..add(upperCaseLetters[random.nextInt(upperCaseLetters.length)])
    ..add(lowerCaseLetters[random.nextInt(lowerCaseLetters.length)])
    ..add(digits[random.nextInt(digits.length)])
    ..add(specialCharacters[random.nextInt(specialCharacters.length)]);

  // Fill the rest of the password length with random characters from the pool
  for (var i = 4; i < length; i++) {
    password.add(allCharacters[random.nextInt(allCharacters.length)]);
  }

  // Shuffle the password to ensure randomness
  password.shuffle(random);

  // Join the list into a string and return it
  return password.join();
}

// Example Test
void main() {
  final password = SecurityUtils.securePassword(48);
  final extendedPassword =
      SecurityUtils.securePassword(48, extendedSpecialCharacters: true);

  // ignore: avoid_print
  print('Password: $password');
  // ignore: avoid_print
  print('Extended Password: $extendedPassword');
}
