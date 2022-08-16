import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/utils.dart';

import '../../common/values.dart';
import '../scomb_mobile.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen(this.parent, {Key? key}) : super(key: key);
  ScombMobileState parent;

  @override
  State<SettingScreen> createState() => _SettingScreenState(parent);
}

class _SettingScreenState extends State<SettingScreen> {
  _SettingScreenState(this.parent);

  ScombMobileState parent;
  late AppDatabase db;
  Map<String, String?> settings = {};
  late bool isLoading;
  bool isLatestTimetable = true;

  @override
  void initState() {
    isLoading = true;
    getDB();
    super.initState();
  }

  Future<void> getDB() async {
    setState(() {
      isLoading = true;
    });

    db = await AppDatabase.getDatabase();
    var allSettings = await db.currentSettingDao.getAllSetting();
    for (var setting in allSettings) {
      settings[setting.settingKey] = setting.settingValue;
    }
    print("setting_inflated");
    print(settings);

    isLatestTimetable = settings[SettingKeys.TIMETABLE_YEAR] == null;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("設定"),
      ),
      body: !isLoading
          ? innerBuild()
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<void> updateSetting(String settingKey, String? settingValue) async {
    settings[settingKey] = settingValue;
    db.currentSettingDao.insertSetting(Setting(settingKey, settingValue));
    setState(() {});
    print("update_setting : $settingKey=$settingValue");
  }

  Widget innerBuild() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          // ログイン設定
          ListTile(
            title: const Text("ログイン設定"),
            subtitle: Column(
              children: [
                TextFormField(
                  initialValue: settings[SettingKeys.USERNAME],
                  onChanged: (text) {
                    updateSetting(SettingKeys.USERNAME, text);
                  },
                  decoration: const InputDecoration(hintText: "学籍番号"),
                ),
                TextFormField(
                  obscureText: true,
                  initialValue: settings[SettingKeys.PASSWORD],
                  onChanged: (text) {
                    updateSetting(SettingKeys.PASSWORD, text);
                  },
                  decoration: const InputDecoration(hintText: "パスワード"),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 時間割設定
          ListTile(
            title: const Text("時間割最終更新日時"),
            subtitle: settings[SettingKeys.TIMETABLE_LAST_UPDATE] != null
                ? Text(timeToString(
                    int.parse(settings[SettingKeys.TIMETABLE_LAST_UPDATE]!)))
                : const Text("未取得"),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text("時間割取得間隔"),
            subtitle: DropdownButton(
              value: settings[SettingKeys.TIMETABLE_UPDATE_INTERVAL] ??
                  (86400000 * 7).toString(),
              items: [
                DropdownMenuItem(
                  value: 0.toString(),
                  child: const Text("常に更新"),
                ),
                DropdownMenuItem(
                  value: (86400000 * 1).toString(),
                  child: const Text("1日"),
                ),
                DropdownMenuItem(
                  value: (86400000 * 2).toString(),
                  child: const Text("2日"),
                ),
                DropdownMenuItem(
                  value: (86400000 * 7).toString(),
                  child: const Text("1週間"),
                ),
                DropdownMenuItem(
                  value: (86400000 * 14).toString(),
                  child: const Text("2週間"),
                ),
                DropdownMenuItem(
                  value: (86400000 * 28).toString(),
                  child: const Text("4週間"),
                ),
              ],
              onChanged: (String? value) async {
                updateSetting(
                  SettingKeys.TIMETABLE_UPDATE_INTERVAL,
                  value ?? (86400000 * 7).toString(),
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text("時間割年度"),
            subtitle: Column(
              children: [
                CheckboxListTile(
                  title: const Text("最新"),
                  value: isLatestTimetable,
                  onChanged: (checked) {
                    if (checked == true) {
                      updateSetting(SettingKeys.TIMETABLE_YEAR, null);
                    } else {
                      settings[SettingKeys.TIMETABLE_YEAR] =
                          DateTime.now().year.toString();
                      settings[SettingKeys.TIMETABLE_TERM] =
                          getCurrentTerm().toString();
                    }

                    setState(() {
                      isLatestTimetable = (checked == true);
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: Visibility(
                        visible: !isLatestTimetable,
                        child: TextFormField(
                          initialValue: settings[SettingKeys.TIMETABLE_YEAR],
                          decoration: const InputDecoration(hintText: "表示年度"),
                          keyboardType: TextInputType.number,
                          onChanged: (text) {
                            updateSetting(SettingKeys.TIMETABLE_YEAR, text);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Visibility(
                        visible: !isLatestTimetable,
                        child: DropdownButton<String?>(
                          value: settings[SettingKeys.TIMETABLE_TERM] ??
                              getCurrentTerm().toString(),
                          items: [
                            DropdownMenuItem(
                              value: Term.FIRST.toString(),
                              child: const Text("前期"),
                            ),
                            DropdownMenuItem(
                              value: Term.SECOND.toString(),
                              child: const Text("後期"),
                            ),
                          ],
                          onChanged: (String? value) async {
                            updateSetting(
                              SettingKeys.TIMETABLE_TERM,
                              value ?? getCurrentTerm().toString(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
