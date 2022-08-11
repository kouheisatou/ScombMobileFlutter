import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/network_screen.dart';
import 'package:scomb_mobile/common/scraping/surveys_scraping.dart';
import 'package:scomb_mobile/common/scraping/task_scraping.dart';

import '../../common/values.dart';

class TaskListScreen extends NetworkScreen {
  TaskListScreen(super.parent, super.title);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends NetworkScreenState<TaskListScreen> {
  @override
  Future<void> getFromServerAndSaveToSharedResource(savedSessionId) async {
    await fetchSurveys(sessionId ?? savedSessionId);
    await fetchTasks(sessionId ?? savedSessionId);
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
