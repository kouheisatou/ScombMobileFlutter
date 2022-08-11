import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:scomb_mobile/common/db/task.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';

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
    throw Exception("セッションIDの有効期限切れ");
  }

  _constructTasks(document);
}

void _constructTasks(Document document) {
  var taskRows = document.getElementsByClassName(TASK_LIST_CSS_CLASS_NM);
  for (var row in taskRows) {
    if (row.children.length < 5) continue;

    var className = row.children[0].text;

    late TaskType taskType;
    if (row.children[1].text.contains("課題")) {
      taskType = TaskType.Task;
    } else if (row.children[1].text.contains("テスト")) {
      taskType = TaskType.Test;
    } else if (row.children[1].text.contains("アンケート")) {
      taskType = TaskType.Survey;
    } else {
      taskType = TaskType.Others;
    }

    var title = row.children[2].text;

    var url = row.children[2].children[0].attributes["href"];

    var deadlineElement =
        row.getElementsByClassName(TASK_LIST_DEADLINE_CULUMN_CSS_NM);
    if (deadlineElement.isEmpty) continue;
    if (deadlineElement[0].children.length < 2) continue;
    var deadline = stringToTime(deadlineElement[0].children[1].text);

    if (url == null) continue;
    var newTask = Task(title, className, taskType, deadline, url);
    print("fetched_tasks : $newTask");
    taskList.add(newTask);
  }
}
