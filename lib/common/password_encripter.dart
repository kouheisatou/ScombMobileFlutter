import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';

// TODO create file(/lib/keys.dart) and define const value of encrypt key here.
import '../keys.dart' as keys;

/// 暗号化関数
///
/// [plainText]を[ENCRYPT_KEY_32]で暗号化する
Future<String> encryptAES(String? plainText) async {
  final key = Key.fromUtf8(keys.ENCRYPT_KEY_32);
  final iv = await getIV();
  final encryptor = Encrypter(AES(key));
  final encrypted = encryptor.encrypt(plainText ?? "", iv: iv);
  return encrypted.base64;
}

/// 復号化関数
///
/// [plainText]を[ENCRYPT_KEY_32]で復号化する
Future<String> decryptAES(String? encryptedBase64Text) async {
  final key = Key.fromUtf8(keys.ENCRYPT_KEY_32);
  final iv = await getIV();
  final encryptor = Encrypter(AES(key));
  final decrypted = encryptor.decrypt64(encryptedBase64Text!, iv: iv);
  return decrypted;
}

Future<IV> getIV() async {
  var db = await AppDatabase.getDatabase();

  IV iv;
  try {
    iv = IV.fromBase64((await db.currentSettingDao.getSetting(SettingKeys.AES_IV))!.settingValue!);
  } catch (e) {
    iv = IV.fromLength(16);
    db.currentSettingDao.insertSetting(Setting(SettingKeys.AES_IV, iv.base64));
  }
  return iv;
}
