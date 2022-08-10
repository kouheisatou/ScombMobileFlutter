import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:scomb_mobile/common/values.dart';

import '../db/task.dart';

Future<List<Task>?> fetchSurveys(
  String? sessionId,
) async {
  var dio = Dio();
  dio.options.baseUrl = SURVEY_LIST_PAGE_URL;

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

  return _constructSurveys(document);
}

List<Task> _constructSurveys(Document document) {
  List<Task> newSurveys = [];

  print(document.getElementById("surveyTakeList")?.text);

  return newSurveys;
}

// not yet implemented
Future<List<Task>>? fetchTasksAndSurveys(String? sessionId) async {
  List<Task> newTaskList = [];
  return newTaskList;
}
