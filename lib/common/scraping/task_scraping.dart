import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';
import 'package:scomb_mobile/ui/tasklist/task.dart';

Future<List<Task>?> fetchTasks(
  String? sessionId,
) async {
  var dio = Dio();
  dio.options.baseUrl = TASK_LIST_PAGE_URL;

  Response? response;
  try {
    response = await dio.get(
      TASK_LIST_PAGE_URL,
      options: Options(
        headers: {
          "Cookie": "$SESSION_COOKIE_ID=$sessionId",
        },
      ),
    );
  } catch (e) {
    return null;
  }

  var document = parse(response.data);
  var currentUrl = "https://${response.realUri.host}${response.realUri.path}";

  if (currentUrl == SCOMB_LOGGED_OUT_PAGE_URL) return null;

  return _constructTasks(document);
}

List<Task> _constructTasks(Document document) {
  List<Task> newTasks = [];

  var taskRows = document.getElementsByClassName(TASK_LIST_CSS_CLASS_NM);
  for (var row in taskRows) {
    if (row.children.length < 5) continue;

    var className = row.children[0].text;

    late TaskType taskType;
    switch (row.children[1].text) {
      case "課題":
        taskType = TaskType.Task;
        break;
      case "テスト":
        taskType = TaskType.Test;
        break;
      case "アンケート":
        taskType = TaskType.Questionnaire;
        break;
      default:
        taskType = TaskType.Others;
        break;
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
    newTasks.add(newTask);
  }

  return newTasks;
}
