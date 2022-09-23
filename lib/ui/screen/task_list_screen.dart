import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/notification.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/ui/dialog/add_task_dialog.dart';
import 'package:scomb_mobile/ui/screen/network_screen.dart';
import 'package:scomb_mobile/ui/screen/single_page_scomb.dart';

import '../../common/db/task.dart';
import '../../common/scraping/surveys_scraping.dart';
import '../../common/scraping/task_scraping.dart';
import '../../common/shared_resource.dart';
import '../../common/values.dart';

class TaskListScreen extends NetworkScreen {
  TaskListScreen(super.title, {Key? key}) : super(key: key);

  @override
  NetworkScreenState<TaskListScreen> createState() => TaskListScreenState();
}

class TaskListScreenState extends NetworkScreenState<TaskListScreen> {
  bool showDoneTasks = false;
  bool showTasks = true;
  bool showTests = true;
  bool showSurveys = true;
  bool showOthers = true;

  @override
  Future<void> getFromServerAndSaveToSharedResource(savedSessionId) async {
    if (taskListInitialized) return;

    // tasks from db
    await inflateTasksFromDB();

    int dbTaskCount = taskList.length;

    // inflate tasks from server
    await fetchSurveys(sessionId ?? savedSessionId);
    await fetchTasks(sessionId ?? savedSessionId);

    int allTaskCount = taskList.length;
    int newlyAddedTasksCount = allTaskCount - dbTaskCount;

    if (newlyAddedTasksCount > 0) {
      Fluttertoast.showToast(msg: "$newlyAddedTasksCount件のタスクを通知に登録しました");
    }

    taskListInitialized = true;
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
    return Column(
      children: [
        // chip list
        Container(
          color: Theme.of(context).primaryColor.withAlpha(50),
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Padding(
                    padding: EdgeInsets.only(right: 6, left: 6),
                    child: Text("絞り込み")),
                buildChip(
                  showTasks,
                  onTap: () {
                    showTasks = !showTasks;
                  },
                  text: "課題",
                ),
                buildChip(
                  showTests,
                  onTap: () {
                    showTests = !showTests;
                  },
                  text: "テスト",
                ),
                buildChip(
                  showSurveys,
                  onTap: () {
                    showSurveys = !showSurveys;
                  },
                  text: "アンケート",
                ),
                buildChip(
                  showOthers,
                  onTap: () {
                    showOthers = !showOthers;
                  },
                  text: "その他",
                ),
                buildChip(
                  showDoneTasks,
                  onTap: () {
                    showDoneTasks = !showDoneTasks;
                  },
                  text: "完了したタスクを含める",
                ),
              ],
            ),
          ),
        ),
        // task list
        Expanded(child: buildList(taskList)),
      ],
    );
  }

  Widget buildChip(
    bool enabled, {
    required Function onTap,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkResponse(
        onTap: () {
          setState(() {
            onTap();
          });
        },
        child: Chip(
          backgroundColor:
              enabled ? Theme.of(context).primaryColor : Colors.black12,
          label: Text(
            text,
            style: TextStyle(color: enabled ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget buildList(List<Task> currentTaskList) {
    List<Widget> list = [];
    for (int i = 0; i < currentTaskList.length; i++) {
      if (((showTasks && currentTaskList[i].taskType == TaskType.TASK) ||
              (showTests && currentTaskList[i].taskType == TaskType.TEST) ||
              (showOthers && currentTaskList[i].taskType == TaskType.OTHERS) ||
              (showSurveys &&
                  currentTaskList[i].taskType == TaskType.SURVEY)) &&
          (showDoneTasks || !currentTaskList[i].done)) {
        list.add(buildListTile(i, currentTaskList));
      }
    }
    list.add(
      TextButton(
        onPressed: () {
          showAddNewTaskDialog();
        },
        child: const Text("todoタスク追加"),
      ),
    );

    return RefreshIndicator(
      onRefresh: refreshData,
      child: Scrollbar(
        child: ListView(
          children: list,
        ),
      ),
    );
  }

  Widget buildListTile(int index, List<Task> currentTaskList) {
    var currentTask = currentTaskList[index];
    var textStyle = TextStyle(
      color: Theme.of(context).primaryColor,
      fontSize: 10,
      fontWeight: FontWeight.w300,
    );
    late Widget icon;
    switch (currentTask.taskType) {
      case TaskType.TASK:
        icon = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.text_snippet_outlined,
                color: Theme.of(context).primaryColor),
            Text("課 題", style: textStyle),
          ],
        );
        break;
      case TaskType.TEST:
        icon = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_outlined, color: Theme.of(context).primaryColor),
            Text("テ ス ト", style: textStyle),
          ],
        );
        break;
      case TaskType.SURVEY:
        icon = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.question_mark_rounded,
                color: Theme.of(context).primaryColor),
            Text("アンケート", style: textStyle),
          ],
        );
        break;
      case TaskType.OTHERS:
        icon = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.playlist_add_check_outlined,
                color: Theme.of(context).primaryColor),
            Text("そ の 他", style: textStyle),
          ],
        );
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
                              cancelNotification(
                                notificationId: currentTask.id.hashCode,
                              );
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
                Checkbox(
                  onChanged: (bool? value) async {
                    currentTask.done = value ?? false;
                    var db = await AppDatabase.getDatabase();
                    db.currentTaskDao.insertTask(currentTask);

                    setState(() {});
                  },
                  value: currentTask.done,
                )
              ],
            )
          : null,
      key: Key(currentTask.id),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 45),
              child: icon,
            ),
            title: !currentTask.done
                ? Text(
                    currentTask.title,
                    textAlign: TextAlign.left,
                  )
                : Text(
                    "(提出済み) ${currentTask.title}",
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
            onLongPress: () {
              print(currentTask);
            },
            onTap: () {
              if (currentTask.url == "") return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SinglePageScomb(
                    Uri.parse(currentTask.url),
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
                    style: isSameDay(
                      DateTime.fromMillisecondsSinceEpoch(currentTask.deadline),
                      DateTime.now(),
                    )
                        ? const TextStyle(color: Colors.red)
                        : const TextStyle(),
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
      addOrReplaceTask(newTask, false);
      sortTasks();
    });
  }
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
    addOrReplaceTask(task, false);
  }
}
