import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/database_exception.dart';
import 'package:scomb_mobile/common/login_exception.dart';
import 'package:scomb_mobile/common/shared_resource.dart';
import 'package:scomb_mobile/ui/scomb_mobile.dart';

import '../../common/db/scomb_mobile_database.dart';
import '../../common/db/setting_entity.dart';

abstract class NetworkScreen extends StatefulWidget {
  NetworkScreen(this.parent, this.title, {Key? key}) : super(key: key);

  ScombMobileState parent;
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

      if (savedSessionId == null) throw LoginException("ログインが必要です");

      await getFromServerAndSaveToSharedResource(savedSessionId);

      // saved session id passed
      sessionId ??= savedSessionId;
    }

    // offline mode
    on SocketException catch (e, stackTrace) {
      Fluttertoast.showToast(msg: "オフライン");
      await getDataOffLine();
    }

    // if fetch failed, auto nav to login screen
    on LoginException catch (e, stackTrace) {
      widget.parent.navToLoginScreen();
      print("login_fail $e\n$stackTrace");
      Fluttertoast.showToast(msg: "ログインが必要です");
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
      taskList.sort((a, b) => a.deadline.compareTo(b.deadline));

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
