import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';

import '../../../common/db/setting_entity.dart';

class LoginSettingScreen extends StatelessWidget {
  LoginSettingScreen(this.settings, this.db);

  Map<String, String?> settings;
  AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ログイン設定"),
      ),
      body: Column(
        children: [
          TextFormField(
            initialValue: settings[SettingKeys.USERNAME],
            onChanged: (text) {
              // updateSetting(SettingKeys.USERNAME, text);
            },
            decoration: const InputDecoration(hintText: "学籍番号"),
          ),
          TextFormField(
            obscureText: true,
            initialValue: settings[SettingKeys.PASSWORD],
            onChanged: (text) {
              // updateSetting(SettingKeys.PASSWORD, text);
            },
            decoration: const InputDecoration(hintText: "パスワード"),
          ),
        ],
      ),
    );
  }
}
