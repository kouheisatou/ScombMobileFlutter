import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/network_screen.dart';
import 'package:scomb_mobile/common/utils.dart';
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
    return ListView.builder(
      itemCount: taskList?.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: determineIcon(taskList?[index].taskType),
          title: Container(
              alignment: Alignment.centerLeft, //任意のプロパティ
              width: double.infinity,
              child: Text('${taskList?[index].title}')),
          subtitle: Column(
            children: [
              Text('${taskList?[index].className}\n'),
              Text(timeToString(taskList?[index].deadline ?? 0)),
            ],
          ),
          dense: true,
        );
      },
    );
  }

  Widget determineIcon(TaskType? taskType) {
    print(taskType);
    Fluttertoast.showToast(msg: "$taskType");
    if (taskType == TaskType.Task) {
      return Column(
        children: [
          const Icon(Icons.task),
          Text('課題'),
        ],
      );
    } else if (taskType == TaskType.Test) {
      return Column(children: [
        const Icon(Icons.text_snippet),
        Text('テスト'),
      ]);
    } else if (taskType == TaskType.Questionnaire) {
      return Column(children: [
        const Icon(Icons.question_answer),
        Text('アンケート'),
      ]);
    } else {
      return Column(children: [
        const Icon(Icons.task_alt),
        Text('その他'),
      ]);
    }
  }
}
