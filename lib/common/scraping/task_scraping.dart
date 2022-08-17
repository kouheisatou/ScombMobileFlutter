import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/task.dart';
import 'package:scomb_mobile/common/login_exception.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';

import '../shared_resource.dart';

Future<void> fetchTasks(
  String? sessionId,
) async {
  var dio = Dio();
  dio.options.baseUrl = TASK_LIST_PAGE_URL;

  Response? response = await dio.get(
    TASK_LIST_PAGE_URL,
    options: Options(
      headers: {
        "Cookie": "$SESSION_COOKIE_ID=$sessionId",
      },
    ),
  );

  var document = parse(response.data);
  var currentUrl = "https://${response.realUri.host}${response.realUri.path}";

  if (currentUrl == SCOMB_LOGGED_OUT_PAGE_URL) {
    throw LoginException("セッションIDの有効期限切れ");
  }

  await _constructTasks(document);
}

Future<void> _constructTasks(Document document) async {
  var db = await AppDatabase.getDatabase();
  var tasksFromDB = await db.currentTaskDao.getAllTasks();

  var taskRows = document.getElementsByClassName(TASK_LIST_CSS_CLASS_NM);
  for (var row in taskRows) {
    if (row.children.length < 5) continue;

    var className = row.children[0].text;

    late int taskType;
    if (row.children[1].text.contains("課題")) {
      taskType = TaskType.TASK;
    } else if (row.children[1].text.contains("テスト")) {
      taskType = TaskType.TEST;
    } else if (row.children[1].text.contains("アンケート")) {
      taskType = TaskType.SURVEY;
    } else {
      taskType = TaskType.OTHERS;
    }

    if (row.children[2].children.isEmpty) continue;
    var title = row.children[2].children[0].text;

    var url = "$SCOMBZ_DOMAIN${row.children[2].children[0].attributes["href"]}";

    var deadlineElement =
        row.getElementsByClassName(TASK_LIST_DEADLINE_CULUMN_CSS_NM);
    if (deadlineElement.isEmpty) continue;
    if (deadlineElement[0].children.length < 2) continue;
    var deadline = stringToTime(deadlineElement[0].children[1].text);

    var newTask = Task.idFromUrl(
      title,
      className,
      taskType,
      deadline,
      url,
      null,
      false,
    );

    // custom color from timetable
    var classCellFromDB =
        await db.currentClassCellDao.getClassCellByClassId(newTask.classId);
    newTask.customColor = classCellFromDB?.customColorInt;

    print("fetched_tasks : $newTask");

    // if already exists
    addOrReplaceTask(newTask);

    await db.currentTaskDao.insertTask(newTask);
  }
}
