import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/shared_resource.dart';
import 'package:scomb_mobile/ui/scomb_mobile.dart';

import '../../common/db/scomb_mobile_database.dart';
import '../../common/db/setting_entity.dart';

class NetworkScreen extends StatefulWidget {
  NetworkScreen(this.parent, this.title, {Key? key}) : super(key: key);

  ScombMobileState parent;
  String title;
  bool initialized = false;
  bool isLoading = false;

  @override
  State<NetworkScreen> createState() {
    return NetworkScreenState<NetworkScreen>();
  }
}

class NetworkScreenState<T extends NetworkScreen> extends State<T> {
  Future<void> fetchData() async {
    if (widget.initialized) {
      return;
    }

    setState(() {
      widget.isLoading = true;
    });

    try {
      // recover session_id from local db
      var db = await AppDatabase.getDatabase();
      var sessionIdSetting =
          await db.currentSettingDao.getSetting(SettingKeys.SESSION_ID);
      var savedSessionId = sessionIdSetting?.settingValue;

      if (savedSessionId == null) throw Exception("ログインが必要です");

      await getFromServerAndSaveToSharedResource(savedSessionId);

      // saved session id passed
      sessionId ??= savedSessionId;

      widget.initialized = true;
    } on SocketException catch (e, stackTrace) {
      Fluttertoast.showToast(msg: "オフライン");
      widget.parent.selectedIndex = 0;
    } catch (e, stackTrace) {
      // if fetch failed, auto nav to login screen
      widget.parent.navToLoginScreen();
      widget.initialized = false;
      print("$e\n$stackTrace");
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      try {
        setState(() {
          widget.isLoading = false;
        });
      } catch (e) {
        widget.isLoading = false;
      }
    }
  }

  Future<void> refreshData() async {
    widget.initialized = false;
    fetchData();
  }

  /// build view here
  Widget innerBuild() {
    return Container();
  }

  /// fetch data and save as shared resource here
  // if fail, throw exception
  Future<void> getFromServerAndSaveToSharedResource(
      String savedSessionId) async {}

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
