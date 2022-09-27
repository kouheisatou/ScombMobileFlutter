import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/database_exception.dart';
import 'package:scomb_mobile/common/login_exception.dart';
import 'package:scomb_mobile/common/password_encripter.dart';
import 'package:scomb_mobile/common/shared_resource.dart';
import 'package:scomb_mobile/ui/screen/login_screen.dart';

import '../../common/db/scomb_mobile_database.dart';
import '../../common/db/setting_entity.dart';
import '../dialog/selector_dialog.dart';

abstract class NetworkScreen extends StatefulWidget {
  NetworkScreen(this.title, {Key? key}) : super(key: key);

  String title;

  @override
  NetworkScreenState<NetworkScreen> createState();
}

abstract class NetworkScreenState<T extends NetworkScreen> extends State<T> {
  bool isLoading = false;

  Future<void> fetchData() async {
    var db = await AppDatabase.getDatabase();
    try {
      // recover session_id from local db
      var sessionIdSetting =
          await db.currentSettingDao.getSetting(SettingKeys.SESSION_ID);
      var savedSessionId = decryptAES(sessionIdSetting?.settingValue);

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
                        Setting(SettingKeys.SECTION, value.toString()));
              },
              description: "学部を選択してください",
            );
          },
        );
        throw LoginException("ログインが必要です");
      }

      // fetch data from server
      setState(() {
        isLoading = true;
      });
      await getFromServerAndSaveToSharedResource(savedSessionId);

      // saved session id passed
      if (sessionId == null && taskListInitialized) {
        sessionId = savedSessionId;
        Fluttertoast.showToast(msg: "自動ログインしました");
      }
    }

    // offline mode
    on SocketException catch (e) {
      Fluttertoast.showToast(msg: "オフライン");
      await getDataOffLine();
    }

    // offline mode
    on DioError catch (e) {
      Fluttertoast.showToast(msg: "オフライン");
      await getDataOffLine();
    }

    // if fetch failed, auto nav to login screen
    on LoginException catch (e, stackTrace) {
      print("login_fail $e\n$stackTrace");
      Fluttertoast.showToast(msg: "ログインが必要です");
      var canceled = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (builder) {
            return LoginScreen();
          },
          fullscreenDialog: true,
        ),
      );
      if (canceled is bool && canceled == false) {
        await refreshData();
      }
    }

    // inflate invalid setting
    on DatabaseException catch (e, stackTrace) {
      db.currentSettingDao.deleteAllSettings();
      print("invalid_setting $e\n$stackTrace");
      Fluttertoast.showToast(msg: "無効な設定");
    }

    // unhandled error
    catch (e, stackTrace) {
      Fluttertoast.showToast(msg: "予期せぬエラーが発生しました。\n$e,$stackTrace");
      print(e);
      print(stackTrace);
    } finally {
      // sort
      sortTasks();
      try {
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        isLoading = false;
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

  List<Widget> buildAppBarActions() {
    List<Widget> result = [];
    return result;
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        actions: buildAppBarActions(),
      ),
      body: !isLoading
          ? innerBuild()
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
