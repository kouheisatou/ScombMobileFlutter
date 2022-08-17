import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/ui/dialog/selector_dialog.dart';
import 'package:settings_ui/settings_ui.dart';

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

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    isLatestTimetable = settings[SettingKeys.TIMETABLE_YEAR] == null;
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
    return SettingsList(
      sections: [
        SettingsSection(
          title: const Text("ログイン設定"),
          tiles: [
            SettingsTile(
              title: const Text("学籍番号"),
              value: Text(settings[SettingKeys.USERNAME] ?? ""),
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("学籍番号"),
                      content: TextFormField(
                        initialValue: settings[SettingKeys.USERNAME],
                        onChanged: (text) {
                          updateSetting(SettingKeys.USERNAME, text);
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("閉じる"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            SettingsTile(
              title: const Text("パスワード"),
              value: Text(genHiddenText(settings[SettingKeys.PASSWORD] ?? "")),
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("パスワード"),
                      content: TextFormField(
                        obscureText: true,
                        initialValue: settings[SettingKeys.PASSWORD],
                        onChanged: (text) {
                          updateSetting(SettingKeys.PASSWORD, text);
                        },
                        decoration: const InputDecoration(hintText: "パスワード"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("閉じる"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        SettingsSection(
          title: const Text("時間割設定"),
          tiles: [
            SettingsTile(
              title: const Text("取得間隔"),
              value: Text(
                findMapKeyFromValue(
                      SettingValues.TIMETABLE_UPDATE_INTERVAL,
                      int.parse(
                        settings[SettingKeys.TIMETABLE_UPDATE_INTERVAL] ??
                            (86400000 * 7).toString(),
                      ),
                    ) ??
                    "1週間",
              ),
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder: (_) {
                    return SelectorDialog(
                      SettingValues.TIMETABLE_UPDATE_INTERVAL,
                      (selectedText, selectedValue) async {
                        updateSetting(
                          SettingKeys.TIMETABLE_UPDATE_INTERVAL,
                          selectedValue.toString(),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingsTile(
              title: const Text("年度"),
              value: Text(
                settings[SettingKeys.TIMETABLE_YEAR] ?? "最新",
              ),
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder: (_) {
                    return SelectorDialog<int?>(
                      buildYearSelection(),
                      (key, value) async {
                        if (value == null) {
                          updateSetting(
                            SettingKeys.TIMETABLE_TERM,
                            getCurrentTerm(),
                          );
                        }
                        updateSetting(
                          SettingKeys.TIMETABLE_YEAR,
                          value?.toString(),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingsTile(
              title: const Text("学期"),
              enabled: !isLatestTimetable,
              value: Text(
                findMapKeyFromValue(
                      SettingValues.TIMETABLE_TERM,
                      settings[SettingKeys.TIMETABLE_TERM] ?? getCurrentTerm(),
                    ) ??
                    getCurrentTerm(),
              ),
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder: (_) {
                    return SelectorDialog(
                      SettingValues.TIMETABLE_TERM,
                      (key, value) async {
                        updateSetting(
                          SettingKeys.TIMETABLE_TERM,
                          value.toString(),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        SettingsSection(
          title: const Text("通知設定"),
          tiles: [
            SettingsTile(
              title: const Text("課題締切通知"),
            ),
          ],
        ),
        SettingsSection(
          title: const Text("このアプリについて"),
          tiles: [
            SettingsTile(
              title: const Text("GitHub"),
            ),
            SettingsTile(
              title: const Text("プライバシーポリシー"),
            )
          ],
        ),
      ],
    );

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
                      updateSetting(SettingKeys.TIMETABLE_TERM,
                          getCurrentTerm().toString());
                    } else {
                      updateSetting(SettingKeys.TIMETABLE_YEAR,
                          DateTime.now().year.toString());
                      updateSetting(SettingKeys.TIMETABLE_TERM,
                          getCurrentTerm().toString());
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

  Map<String, int?> buildYearSelection() {
    Map<String, int?> yearSelection = {};
    var thisYear = DateTime.now().year;
    yearSelection["最新"] = null;
    for (int i = 0; i < 6; i++) {
      var year = thisYear - i;
      yearSelection[year.toString()] = year;
    }
    return yearSelection;
  }
}
