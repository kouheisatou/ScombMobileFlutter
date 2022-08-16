import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/notification.dart';
import 'package:scomb_mobile/common/scraping/surveys_scraping.dart';
import 'package:scomb_mobile/common/scraping/task_scraping.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/ui/dialog/add_task_dialog.dart';
import 'package:scomb_mobile/ui/screen/network_screen.dart';
import 'package:scomb_mobile/ui/screen/single_page_scomb.dart';

import '../../common/db/task.dart';
import '../../common/shared_resource.dart';
import '../../common/values.dart';

class TaskListScreen extends NetworkScreen {
  TaskListScreen(super.parent, super.title, {Key? key}) : super(key: key);

  @override
  NetworkScreenState<TaskListScreen> createState() => TaskListScreenState();
}

class TaskListScreenState extends NetworkScreenState<TaskListScreen> {
  @override
  Future<void> getFromServerAndSaveToSharedResource(savedSessionId) async {
    if (taskListInitialized) return;

    // reset notification
    await cancelNotification();

    await inflateTasksFromDB();

    // inflate tasks from server
    await fetchSurveys(sessionId ?? savedSessionId);
    await fetchTasks(sessionId ?? savedSessionId);

    taskListInitialized = true;
  }

  Future<void> inflateTasksFromDB() async {
    var db = await AppDatabase.getDatabase();
    var tasksFromDB = await db.currentTaskDao.getAllTasks();
    for (var task in tasksFromDB) {
      print("task_from_db : $task");
      var relatedClass =
          await db.currentClassCellDao.getClassCellByClassId(task.classId);
      if (relatedClass != null) {
        task.customColor = relatedClass.customColorInt;
      }
      addOrReplaceTask(task);
    }
  }

  @override
  Future<void> getDataOffLine() async {
    await inflateTasksFromDB();
  }

  @override
  Future<void> refreshData() async {
    taskListInitialized = false;
    super.fetchData();
  }

  @override
  Widget innerBuild() {
    return buildList(taskList);
  }

  Widget buildList(List<Task> currentTaskList) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: refreshData,
          child: ListView.builder(
            itemCount: currentTaskList.length,
            itemBuilder: (BuildContext context, int index) {
              return buildListTile(index, currentTaskList);
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: () {
                showAddNewTaskDialog();
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(5),
              ),
              child: const Icon(
                Icons.add,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildListTile(int index, List<Task> currentTaskList) {
    var currentTask = currentTaskList[index];
    late Icon icon;
    switch (currentTask.taskType) {
      case TaskType.TASK:
        icon = const Icon(Icons.assignment);
        break;
      case TaskType.TEST:
        icon = const Icon(Icons.checklist);
        break;
      case TaskType.SURVEY:
        icon = const Icon(Icons.question_mark_rounded);
        break;
      case TaskType.OTHERS:
        icon = const Icon(Icons.task);
        break;
    }

    return Slidable(
      endActionPane: currentTask.addManually
          ? ActionPane(
              motion: const ScrollMotion(),
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog<int>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("タスク削除"),
                        content: Text("${currentTask.title}\nを本当に削除しますか？"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("キャンセル")),
                          TextButton(
                            onPressed: () async {
                              var db = await AppDatabase.getDatabase();
                              await db.currentTaskDao
                                  .removeTask(currentTask.id);
                              taskList.remove(currentTask);
                              setState(() {});
                              Navigator.pop(context);
                            },
                            child: const Text("削除"),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      key: Key(currentTask.id),
      child: Column(
        children: [
          ListTile(
            leading: icon,
            title: Text(
              currentTask.title,
              textAlign: TextAlign.left,
            ),
            onTap: () {
              if (currentTask.url == "") return;
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
          ),
          const Divider(
            height: 0.5,
          ),
        ],
      ),
    );
  }

  Future<void> showAddNewTaskDialog() async {
    var newTask = await showDialog<Task>(
      context: context,
      builder: (_) {
        return AddTaskDialog(null, null);
      },
    );
    if (newTask == null) return;
    setState(() {
      addOrReplaceTask(newTask);
      registerTaskNotification(newTask);
      taskList.sort((a, b) => a.deadline.compareTo(b.deadline));
    });
  }
}
