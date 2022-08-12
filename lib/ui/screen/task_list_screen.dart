import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/scraping/surveys_scraping.dart';
import 'package:scomb_mobile/common/scraping/task_scraping.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/ui/screen/network_screen.dart';
import 'package:scomb_mobile/ui/screen/single_page_scomb.dart';

import '../../common/db/task.dart';
import '../../common/shared_resource.dart';
import '../../common/values.dart';

class TaskListScreen extends NetworkScreen {
  TaskListScreen(super.parent, super.title, {Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => TaskListScreenState();
}

class TaskListScreenState extends NetworkScreenState<TaskListScreen> {
  @override
  Future<void> getFromServerAndSaveToSharedResource(savedSessionId) async {
    if (taskListInitialized) return;
    await fetchSurveys(sessionId ?? savedSessionId);
    await fetchTasks(sessionId ?? savedSessionId);
    taskList.sort((a, b) => a.deadline.compareTo(b.deadline));
    taskListInitialized = true;
  }

  @override
  Future<void> refreshData() {
    taskListInitialized = false;
    return super.refreshData();
  }

  @override
  Widget innerBuild() {
    return ListView.separated(
      itemCount: taskList.length,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 0.5,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return buildListTile(index, taskList);
      },
    );
  }

  Widget buildListTile(int index, List<Task> taskList) {
    var currentTask = taskList[index];
    late Icon icon;
    switch (currentTask.taskType) {
      case TaskType.Task:
        icon = const Icon(Icons.assignment);
        break;
      case TaskType.Test:
        icon = const Icon(Icons.checklist);
        break;
      case TaskType.Survey:
        icon = const Icon(Icons.question_mark_rounded);
        break;
      case TaskType.Others:
        icon = const Icon(Icons.task);
        break;
    }

    return ListTile(
      leading: icon,
      title: Text(
        currentTask.title,
        textAlign: TextAlign.left,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SinglePageScomb(
              currentTask.url,
              currentTask.title,
            ),
            fullscreenDialog: true,
          ),
        );
      },
      subtitle: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              currentTask.className,
              style: currentTask.customColor != null
                  ? TextStyle(
                      color: Color(currentTask.customColor!),
                    )
                  : const TextStyle(),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              timeToString(currentTask.deadline),
            ),
          ),
        ],
      ),
    );
  }
}
