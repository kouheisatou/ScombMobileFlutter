import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/database_exception.dart';
import 'package:scomb_mobile/common/login_exception.dart';
import 'package:scomb_mobile/common/shared_resource.dart';
import 'package:scomb_mobile/ui/screen/login_screen.dart';

import '../../common/db/scomb_mobile_database.dart';
import '../../common/db/setting_entity.dart';
import '../dialog/selector_dialog.dart';

abstract class NetworkScreen extends StatefulWidget {
  NetworkScreen(this.title, {Key? key}) : super(key: key);

  String title;
  bool isLoading = false;

  @override
  NetworkScreenState<NetworkScreen> createState();
}

abstract class NetworkScreenState<T extends NetworkScreen> extends State<T> {
  Future<void> fetchData() async {
    setState(() {
      widget.isLoading = true;
    });

    var db = await AppDatabase.getDatabase();
    try {
      // recover session_id from local db
      var sessionIdSetting =
          await db.currentSettingDao.getSetting(SettingKeys.SESSION_ID);
      var savedSessionId = sessionIdSetting?.settingValue;

      // first launch
      if (savedSessionId == null) {
        await showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text("免責事項"),
              actions: [
                TextButton(
                  onPressed: () async {
                    db.currentSettingDao.insertSetting(
                      Setting(
                        SettingKeys.SESSION_ID,
                        "",
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("同意する"),
                )
              ],
              content: const Text(
                  "このアプリはScomb上の情報を確認することを目的に作成されました。\nアプリ内に表示されるWebページ内でテスト受験やアンケート解答、課題提出することは可能ですが、推奨されません。\nこのアプリ内からテスト受験やアンケート解答、課題提出する場合は、自己責任で行ってください。"),
            );
          },
        );
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return SelectorDialog(
              SettingValues.SECTION,
              (key, value) async {
                (await AppDatabase.getDatabase())
                    .currentSettingDao
                    .insertSetting(
                        Setting(SettingKeys.Section, value.toString()));
              },
              description: "学部を選択してください",
            );
          },
        );
        throw LoginException("ログインが必要です");
      }

      await getFromServerAndSaveToSharedResource(savedSessionId);

      // saved session id passed
      if (sessionId == null && taskListInitialized) {
        sessionId = savedSessionId;
        Fluttertoast.showToast(msg: "自動ログインしました");
      }
    }

    // offline mode
    on SocketException catch (e, stackTrace) {
      Fluttertoast.showToast(msg: "オフライン");
      await getDataOffLine();
    }

    // if fetch failed, auto nav to login screen
    on LoginException catch (e, stackTrace) {
      print("login_fail $e\n$stackTrace");
      Fluttertoast.showToast(msg: "ログインが必要です");
      bool canceled = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (builder) {
            return LoginScreen();
          },
          fullscreenDialog: true,
        ),
      );
      if (!canceled) {
        refreshData();
      }
      return;
    }

    // inflate invalid setting
    on DatabaseException catch (e, stackTrace) {
      db.currentSettingDao.deleteAllSettings();
      print("invalid_setting $e\n$stackTrace");
      Fluttertoast.showToast(msg: "無効な設定");
    }

    // unhandled error
    catch (e, stackTrace) {
      Fluttertoast.showToast(
          msg: "予期せぬエラーが発生しました。開発者に報告してください。\n$e,$stackTrace");
    } finally {
      // sort
      sortTasks();

      // force to disable loading mode
      try {
        setState(() {
          widget.isLoading = false;
        });
      } catch (e) {
        widget.isLoading = false;
      }
    }
  }

  Future<void> refreshData();

  /// build view here
  Widget innerBuild();

  /// fetch data and save as shared resource here
  // if login error, throw LoginException
  // if offline error, throw SocketException
  Future<void> getFromServerAndSaveToSharedResource(String savedSessionId);

  /// fetch data from db and save to shared resource here
  Future<void> getDataOffLine();

  NetworkScreenState() {
    // run fetch after build
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: !widget.isLoading
          ? innerBuild()
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
