import 'package:encrypt/encrypt.dart';

// TODO create file(/lib/keys.dart) and define const value of encrypt key here.
import '../keys.dart' as keys;

String? encryptAES(String? plainText) {
  String? result;
  try {
    final key = Key.fromUtf8(keys.ENCRYPT_KEY_32);
    final iv = IV.fromLength(16);

    final encryptor = Encrypter(AES(key));

    final encrypted = encryptor.encrypt(plainText ?? "", iv: iv);

    result = encrypted.base64;
  } catch (e, stackTrace) {
    print(e);
    print(stackTrace);
  }

  return result;
}

String? decryptAES(String? encryptedText) {
  String? result;
  try {
    final key = Key.fromUtf8(keys.ENCRYPT_KEY_32);
    final iv = IV.fromLength(16);

    final encryptor = Encrypter(AES(key));

    final decrypted = encryptor.decrypt64(encryptedText ?? "", iv: iv);

    result = decrypted;
  } catch (e, stackTrace) {
    print(e);
    print(stackTrace);
  }

  return result;
}

void main() {
  var a = "encrypt_test";
  var encrypted = encryptAES(a);
  var decrypted = decryptAES(encrypted);
}
