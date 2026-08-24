import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/features/auth/domain/auth_validators.dart';

void main() {
  group('validateEmail', () {
    test('accepts a plain address', () {
      expect(validateEmail('dana@pacepulse.app'), isNull);
    });

    test('rejects empty', () {
      expect(validateEmail(''), AuthCopy.emailRequired);
      expect(validateEmail('   '), AuthCopy.emailRequired);
    });

    test('rejects malformed', () {
      for (final bad in ['dana', 'dana@', '@pacepulse.app', 'dana@app']) {
        expect(validateEmail(bad), AuthCopy.emailInvalid, reason: bad);
      }
    });

    test('trims surrounding whitespace before judging', () {
      expect(validateEmail('  dana@pacepulse.app  '), isNull);
    });
  });

  group('validatePassword', () {
    test('accepts 8 characters with a digit', () {
      expect(validatePassword('runfast1'), isNull);
    });

    test('rejects fewer than 8 characters', () {
      expect(validatePassword('run1'), AuthCopy.passwordRule);
    });

    test('rejects 8 characters with no digit', () {
      expect(validatePassword('runfastx'), AuthCopy.passwordRule);
    });

    test('rejects empty', () {
      expect(validatePassword(''), AuthCopy.passwordRule);
    });

    test('does not trim — spaces are legal password characters', () {
      // Leading AND trailing spaces on purpose: an internal space (e.g.
      // 'run fas1') survives trim() too, so it could never distinguish a
      // trimming implementation from a non-trimming one. ' pass123 ' is
      // 9 characters WITH the edges and 7 without, so a trim would drop
      // it below the 8-character rule and return an error.
      expect(validatePassword(' pass123 '), isNull);
    });
  });
}
