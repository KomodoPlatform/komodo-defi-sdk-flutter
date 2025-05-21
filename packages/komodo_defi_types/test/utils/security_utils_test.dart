import 'dart:math';

import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Password validation tests', () {
    test('Too short passwords should fail', () {
      expect(
        SecurityUtils.checkPasswordRequirements('Abc1!'),
        PasswordValidationError.tooShort,
      );
      expect(SecurityUtils.checkPasswordRequirements(''),
          PasswordValidationError.tooShort);
      expect(
        SecurityUtils.checkPasswordRequirements('A1b!'),
        PasswordValidationError.tooShort,
      );
    });

    test('Passwords containing "password" should fail', () {
      expect(
        SecurityUtils.checkPasswordRequirements('myPassword123!'),
        PasswordValidationError.containsPassword,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('PASSWORDabc123!'),
        PasswordValidationError.containsPassword,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('pAsSwOrD123!'),
        PasswordValidationError.containsPassword,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('My-password-is-secure!123'),
        PasswordValidationError.containsPassword,
      );
    });

    test('Passwords without digits should fail', () {
      expect(
        SecurityUtils.checkPasswordRequirements('StrongPass!'),
        PasswordValidationError.missingDigit,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('NoDigitsHere!@#'),
        PasswordValidationError.missingDigit,
      );
    });

    test('Passwords without lowercase should fail', () {
      expect(
        SecurityUtils.checkPasswordRequirements('STRONG123!'),
        PasswordValidationError.missingLowercase,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('ALL123CAPS!@#'),
        PasswordValidationError.missingLowercase,
      );
    });

    test('Passwords without uppercase should fail', () {
      expect(
        SecurityUtils.checkPasswordRequirements('strong123!'),
        PasswordValidationError.missingUppercase,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('all123lower!@#'),
        PasswordValidationError.missingUppercase,
      );
    });

    test('Passwords without special characters should fail', () {
      expect(
        SecurityUtils.checkPasswordRequirements('Strong123'),
        PasswordValidationError.missingSpecialCharacter,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('NoSpecial1Characters2'),
        PasswordValidationError.missingSpecialCharacter,
      );
    });

    test('Multiple validation errors should return most critical first', () {
      expect(
        SecurityUtils.checkPasswordRequirements('pass'),
        PasswordValidationError.tooShort,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('passwordddd'),
        PasswordValidationError.containsPassword,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Abcaaa1234*%'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Abcde123'),
        PasswordValidationError.missingSpecialCharacter,
      );
    });

    test('Edge cases with spaces and special formatting', () {
      expect(
        SecurityUtils.checkPasswordRequirements('Pass 123!'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Tab\t123!A'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Line\nBreak123!A'),
        PasswordValidationError.none,
      );
    });

    test('Passwords with numbers in various positions', () {
      expect(
        SecurityUtils.checkPasswordRequirements('1AbcSpecial!'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Abc1Special!'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('AbcSpecial!1'),
        PasswordValidationError.none,
      );
    });

    test('Various special characters', () {
      expect(
        SecurityUtils.checkPasswordRequirements('AbcDef123@'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Abc_Def123#'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements(r'AbcDef123$'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('AbcDef123%'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('AbcDef123&'),
        PasswordValidationError.none,
      );
    });

    test('Valid passwords should not fail', () {
      expect(
        SecurityUtils.checkPasswordRequirements('Very!hard!pass!77'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Komodo2024!'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Complex!P4ssword123'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements(r'!P4ssword#$@'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Mix3d_Ch4r4ct3rs!'),
        PasswordValidationError.none,
      );
    });

    test('Password specifically mentioned in the issue should be rejected', () {
      // Should fail (has consecutive characters)
      expect(
        SecurityUtils.checkPasswordRequirements('Very!hard!pass!777'),
        PasswordValidationError.consecutiveCharacters,
      );
    });

    test(
        'Passwords with three or more consecutive identical '
        'characters should fail', () {
      expect(
        SecurityUtils.checkPasswordRequirements('Strong111Security!'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Secure222!A'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('A1!Secure333'),
        PasswordValidationError.consecutiveCharacters,
      );

      expect(
        SecurityUtils.checkPasswordRequirements('aaaStrong1!'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Strong1!bbb'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Strong1!CCC'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Strong1!!!Secure'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Strong1###Secure'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements(r'Strong1$$$Secure'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Strong1!aaaaa'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Strong1!44444'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Strong1!!!!!'),
        PasswordValidationError.consecutiveCharacters,
      );
    });

    test(
        'Valid passwords with two consecutive identical characters should pass',
        () {
      expect(
        SecurityUtils.checkPasswordRequirements('Strong11Secured!'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Strong!!Secured1'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('aaStrong1!Secured'),
        PasswordValidationError.none,
      );
    });

    test('Special case - passwords with unicode characters', () {
      expect(
        SecurityUtils.checkPasswordRequirements('Пароль123!'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('密码Abc123!'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Mötley123!'),
        PasswordValidationError.none,
      );
    });

    test('Extended Unicode character password tests', () {
      expect(
        SecurityUtils.checkPasswordRequirements('علي123!Abc'), // Arabic
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('こんにちは123!Ab'), // Japanese
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('안녕하세요123!Ab'), // Korean
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Привет123!Ab'), // Cyrillic
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Γειά123!Aa'), // Greek
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('שלום123!Aa'), // Hebrew
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('नमस्ते123!Ab'), // Devanagari
        PasswordValidationError.none,
      );
    });

    test('Unicode edge cases and challenging patterns', () {
      expect(
        SecurityUtils.checkPasswordRequirements(
            'Раssw0rd!'), // Cyrillic 'Р' (not Latin 'P')
        PasswordValidationError.none,
      );

      expect(
        SecurityUtils.checkPasswordRequirements('Pass\u200Bword123!'),
        PasswordValidationError.none,
      );

      expect(
        // a + combining acute accent
        SecurityUtils.checkPasswordRequirements('Pa\u0301ssword123!'),
        PasswordValidationError.none,
      );

      expect(
        SecurityUtils.checkPasswordRequirements('Strong🔑123!A'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('A1!🎮🎲🎯aa'),
        PasswordValidationError.none,
      );

      expect(
        SecurityUtils.checkPasswordRequirements('Strоng123!'),
        PasswordValidationError.none,
      );
    });

    test('Unicode sequential characters detection', () {
      expect(
        SecurityUtils.checkPasswordRequirements('Strong爱爱爱123!'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Strong😊😊😊123!'),
        PasswordValidationError.consecutiveCharacters,
      );

      // Characters that look similar but are actually different code points
      expect(
        SecurityUtils.checkPasswordRequirements('StrongАААbc123!'),
        PasswordValidationError.consecutiveCharacters,
      );
    });

    test('Bidirectional text and special Unicode formatting', () {
      // Right-to-left marks and embedding
      expect(
        SecurityUtils.checkPasswordRequirements(
            'Pass\u200Eword123!A'), // Contains LTR mark
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements(
            'Pass\u200Fword123!A'), // Contains RTL mark
        PasswordValidationError.none,
      );

      // Mixed directionality
      expect(
        SecurityUtils.checkPasswordRequirements(
            'Abcהמסיסמ123!'), // Hebrew mixed with Latin
        PasswordValidationError.none,
      );

      // Special spaces
      expect(
        SecurityUtils.checkPasswordRequirements(
            'Pass\u2007word123!A'), // Figure space
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements(
            'Pass\u00A0word123!A'), // Non-breaking space
        PasswordValidationError.none,
      );
    });

    test('Advanced emoji password tests in valid passwords', () {
      expect(
        SecurityUtils.checkPasswordRequirements('Strong123!🔒'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('🔑Abcasba123!'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Pass🔥123!A'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Abc123!🌟✨🚀'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('🎮🎯A1!abaa'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Strong👨‍👩‍👧‍👦123!'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('A1!👍🏽Strong1234'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Pass🇺🇸123!A'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Strong123A🎯'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Strong1A🎯🎯🎯'),
        PasswordValidationError.consecutiveCharacters,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('🔥🔥🔥Strong1A!'),
        PasswordValidationError.consecutiveCharacters,
      );
    });
    test('Complex emoji sequences and ZWJ', () {
      expect(
        // ZWJ sequence (man technologist)
        SecurityUtils.checkPasswordRequirements('Strong123A👨‍💻'),
        PasswordValidationError.none,
      );
      expect(
        // Complex ZWJ sequence
        SecurityUtils.checkPasswordRequirements('Strong123A👁️‍🗨️'),
        PasswordValidationError.none,
      );
      expect(
        // Emoji presentation selector
        SecurityUtils.checkPasswordRequirements('Strong123A☺️'),
        PasswordValidationError.none,
      );
    });

    test('Mixed emoji and text patterns', () {
      expect(
        SecurityUtils.checkPasswordRequirements('Aaba🔒1🔑!🚀'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('Se🔒cure123!'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('St🔑r🔒ng1!'),
        PasswordValidationError.none,
      );
      expect(
        // Should not trigger containsPassword
        SecurityUtils.checkPasswordRequirements('p🔑ssw🔒rd123A!'),
        PasswordValidationError.none,
      );
      expect(
        SecurityUtils.checkPasswordRequirements('🔒🚀🎮��Aa1!'),
        PasswordValidationError.none,
      );
    });

    test('Limited fuzzy testing', () {
      final random = Random();
      const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123'
          r'456789!@#$%^&*()';

      for (int i = 0; i < 10; i++) {
        final int length = random.nextInt(15) + 1;
        final StringBuffer passwordBuffer = StringBuffer();

        for (int j = 0; j < length; j++) {
          passwordBuffer.write(chars[random.nextInt(chars.length)]);
        }

        // Test the random password - we don't assert specific errors,
        // just verify the validator properly handles random input
        SecurityUtils.checkPasswordRequirements(passwordBuffer.toString());
      }

      final List<String> problematicInputs = [
        // Password too short
        'a',
        // Repeated characters
        'aaaPassword1!',
        'Password111!',
        'Password!!!1',
        // Mixed borderline cases
        'pass A1!',
        'PASS a1!',
        'Pass A!',
        'Pass A1',
        // Contains "password"
        'MyPasswordIs1!',
        'password123A!',
        '!PASSWORDabc1',
      ];

      for (final String input in problematicInputs) {
        SecurityUtils.checkPasswordRequirements(input);
      }
    });
  });
}
