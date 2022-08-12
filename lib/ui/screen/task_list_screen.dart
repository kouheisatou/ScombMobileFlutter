import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/scraping/surveys_scraping.dart';
import 'package:scomb_mobile/common/scraping/task_scraping.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/ui/screen/network_screen.dart';
import 'package:scomb_mobile/ui/screen/single_page_scomb.dart';

import '../../common/shared_resource.dart';
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
    taskList?.sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  @override
  Widget innerBuild() {
    return ListView.separated(
      itemCount: taskList?.length ?? 0,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 0.5,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return buildListTile(index);
      },
    );
  }

  Widget buildListTile(int index) {
    var currentTask = taskList![index];
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
