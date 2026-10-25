import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// تجزئة كلمات السر — مستوى مشروع تخرّج.
/// ليست بديلاً عن bcrypt/Argon2 ولا عن خادم مصادقة حقيقي.
class PasswordHasher {
  static const int _iterations = 10000;
  static const int _saltLength = 16;

  PasswordHasher._();

  static String generateSalt() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(_saltLength, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String hash(String password, String salt) {
    var digest = utf8.encode('$salt:$password');
    for (var i = 0; i < _iterations; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return base64Url.encode(digest);
  }

  /// مقارنة بزمن ثابت لتفادي هجمات التوقيت.
  static bool verify(String password, String salt, String expected) {
    final actual = hash(password, salt);
    if (actual.length != expected.length) return false;
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual.codeUnitAt(i) ^ expected.codeUnitAt(i);
    }
    return diff == 0;
  }
}
