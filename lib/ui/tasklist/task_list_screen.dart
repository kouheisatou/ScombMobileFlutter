import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/network_screen.dart';
import 'package:scomb_mobile/ui/tasklist/task_scraping.dart';

import '../../common/values.dart';

class TaskListScreen extends NetworkScreen {
  TaskListScreen(super.parent, super.title);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends NetworkScreenState<TaskListScreen> {
  @override
  Future<void> getFromServerAndSaveToSharedResource() async {
    // todo recover from local db
    var savedSessionId = "saved_session_id";

    var newTaskList = await fetchTasks(sessionId ?? savedSessionId);

    if (newTaskList == null) {
      widget.parent.navToLoginScreen();
      widget.initialized = false;
      throw Exception("not_permitted");
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
