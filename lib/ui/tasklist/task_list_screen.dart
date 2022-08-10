import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/network_screen.dart';
import 'package:scomb_mobile/common/scraping/surveys_scraping.dart';

import '../../common/db/scomb_mobile_database.dart';
import '../../common/db/setting_entity.dart';
import '../../common/values.dart';

class TaskListScreen extends NetworkScreen {
  TaskListScreen(super.parent, super.title);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends NetworkScreenState<TaskListScreen> {
  @override
  Future<void> getFromServerAndSaveToSharedResource() async {
    // recover session_id from local db
    var db = await AppDatabase.getDatabase();
    var sessionIdSetting =
        await db.currentSettingDao.getSetting(SettingKeys.SESSION_ID);
    var savedSessionId = sessionIdSetting?.settingValue;

    if (savedSessionId == null) throw Exception("ログインが必要です");

    // var newTaskList = await fetchTasks(sessionId ?? savedSessionId);
    var newTaskList = await fetchSurveys(sessionId ?? savedSessionId);

    if (newTaskList == null) {
      widget.parent.navToLoginScreen();
      widget.initialized = false;
      throw Exception("セッションIDの有効期限切れ");
    }
    // saved session id passed
    else {
      sessionId ??= savedSessionId;
    }

    taskList = newTaskList;
  }

  @override
  Widget innerBuild() {
    return Column(
      children: [
        OutlinedButton(
          onPressed: () async {
            refreshData();
          },
          child: const Text("課題リスト再取得"),
        ),
        Text(taskList.toString())
      ],
    );
  }
}
