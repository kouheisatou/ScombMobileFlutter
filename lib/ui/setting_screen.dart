import 'package:flutter/material.dart';

import 'scomb_mobile.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen(this.parent, {Key? key}) : super(key: key);
  ScombMobileState parent;

  @override
  State<SettingScreen> createState() => _SettingScreenState(parent);
}

class _SettingScreenState extends State<SettingScreen> {
  _SettingScreenState(this.parent);

  ScombMobileState parent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("設定"),
      ),
      body: const Center(child: Text("設定画面")),
    );
  }
}
