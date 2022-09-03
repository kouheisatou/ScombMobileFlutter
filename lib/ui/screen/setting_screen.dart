import 'package:app_review/app_review.dart';
import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';
import 'package:scomb_mobile/ui/dialog/selector_dialog.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/notification.dart';
import '../../common/shared_resource.dart';
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
            SettingsTile(
              title: const Text("学部"),
              value: Text(findMapKeyFromValue(
                      SettingValues.SECTION, settings[SettingKeys.Section]) ??
                  ""),
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder: (_) {
                    return SelectorDialog(
                      SettingValues.SECTION,
                      (key, value) async {
                        updateSetting(SettingKeys.Section, value.toString());
                      },
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
              title: const Text("表示年度"),
              value: Text(
                settings[SettingKeys.TIMETABLE_YEAR] ?? "最新",
              ),
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder: (_) {
                    return SelectorDialog<int?>(
                      buildYearSelection(6, true),
                      (key, value) async {
                        // on "最新" selected
                        if (value == null) {
                          updateSetting(
                            SettingKeys.TIMETABLE_TERM,
                            null,
                          );
                        }
                        // on custom year selected
                        else {
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
              title: const Text("表示学期"),
              enabled: !isLatestTimetable,
              value: Text(
                findMapKeyFromValue(
                      SettingValues.TIMETABLE_TERM,
                      settings[SettingKeys.TIMETABLE_TERM] ?? "",
                    ) ??
                    "",
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
            SettingsTile(
              title: const Text("自動更新間隔"),
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
                      description:
                          "時間割は一度ScombZから取得すると、しばらく本体に保存されます。\n\n保存する期間を選択してください。",
                    );
                  },
                );
              },
            ),
            SettingsTile(
              title: const Text("最終更新日時"),
              value: settings[SettingKeys.TIMETABLE_LAST_UPDATE] != null
                  ? Text(
                      timeToString(
                        int.parse(settings[SettingKeys.TIMETABLE_LAST_UPDATE]!),
                      ),
                    )
                  : const Text("未取得"),
              onPressed: (context) async {
                updateSetting(
                  SettingKeys.TIMETABLE_LAST_UPDATE,
                  "0",
                );
                settings[SettingKeys.TIMETABLE_LAST_UPDATE] =
                    DateTime.now().millisecondsSinceEpoch.toString();
                timetableInitialized = false;
              },
            ),
          ],
        ),
        SettingsSection(
          title: const Text("通知設定"),
          tiles: [
            SettingsTile(
              title: const Text("課題締切通知"),
              value: Text(
                findMapKeyFromValue<int>(
                      SettingValues.NOTIFICATION_TIMING,
                      int.parse(
                        settings[SettingKeys.NOTIFICATION_TIMING] ??
                            (60000 * 60).toString(),
                      ),
                    ) ??
                    "１時間前",
              ),
              onPressed: (context) {
                showDialog(
                  context: context,
                  builder: (_) {
                    return SelectorDialog(
                      SettingValues.NOTIFICATION_TIMING,
                      (key, value) async {
                        updateSetting(
                            SettingKeys.NOTIFICATION_TIMING, value.toString());
                      },
                    );
                  },
                );
              },
            ),
            SettingsTile(
              title: const Text("\"今日の課題\"通知時刻"),
              value: Text(settings[SettingKeys.TODAYS_TASK_NOTIFICATION_TIME] ??
                  "8:00"),
              onPressed: (context) async {
                var prevSetting =
                    settings[SettingKeys.TODAYS_TASK_NOTIFICATION_TIME] ??
                        "8:00";
                var prevSetTime = TimeOfDay(
                  hour: int.parse(prevSetting.split(":")[0]),
                  minute: int.parse(prevSetting.split(":")[1]),
                );
                var selectedTime = await showTimePicker(
                    context: context, initialTime: prevSetTime);
                if (selectedTime == null) return;
                updateSetting(
                  SettingKeys.TODAYS_TASK_NOTIFICATION_TIME,
                  "${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, "0")}",
                );

                // reset and resume notification
                await cancelNotification();
                registerAllTaskNotification(taskList);
              },
            ),
          ],
        ),
        SettingsSection(
          title: const Text("このアプリについて"),
          tiles: [
            SettingsTile(
              title: const Text("レビューを送信"),
              onPressed: (context) async {
                AppReview.requestReview.then((onValue) {
                  print(onValue);
                });
              },
            ),
            SettingsTile(
              title: const Text("ScombZ"),
              onPressed: (context) async {
                if (await canLaunchUrl(
                  Uri.parse(SCOMB_HOME_URL),
                )) {
                  await launchUrl(
                    Uri.parse(SCOMB_HOME_URL),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
            SettingsTile(
              title: const Text("Twitter"),
              onPressed: (context) async {
                if (await canLaunchUrl(
                  Uri.parse(TWITTER_URL),
                )) {
                  await launchUrl(
                    Uri.parse(TWITTER_URL),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
            SettingsTile(
              title: const Text("プライバシーポリシー"),
              onPressed: (context) async {
                if (await canLaunchUrl(
                  Uri.parse(PRIVACY_POLICY_URL),
                )) {
                  await launchUrl(
                    Uri.parse(PRIVACY_POLICY_URL),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Map<String, int?> buildYearSelection(int range, bool allowNull) {
    Map<String, int?> yearSelection = {};
    var thisYear = DateTime.now().year;
    if (allowNull) {
      yearSelection["最新"] = null;
    }
    for (int i = 0; i < range; i++) {
      var year = thisYear - i;
      yearSelection[year.toString()] = year;
    }
    return yearSelection;
  }
}
