import 'package:codesphere/core/security/password_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('salt is unique per call', () {
    expect(PasswordHasher.generateSalt(), isNot(equals(PasswordHasher.generateSalt())));
  });

  test('correct password verifies', () {
    const pwd = '1234';
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(pwd, salt);
    expect(PasswordHasher.verify(pwd, salt, hash), isTrue);
  });

  test('wrong password is rejected', () {
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash('1234', salt);
    expect(PasswordHasher.verify('12345', salt, hash), isFalse);
  });

  test('same password with different salt gives different hash', () {
    final h1 = PasswordHasher.hash('1234', PasswordHasher.generateSalt());
    final h2 = PasswordHasher.hash('1234', PasswordHasher.generateSalt());
    expect(h1, isNot(equals(h2)));
  });
}
