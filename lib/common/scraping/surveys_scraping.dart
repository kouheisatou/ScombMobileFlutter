import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';

import '../db/task.dart';
import '../shared_resource.dart';

Future<void> fetchSurveys(
  String? sessionId,
) async {
  Response? response = await http.get(
    Uri.parse(SURVEY_LIST_PAGE_URL),
    headers: {
      "Cookie": "$SESSION_COOKIE_ID=$sessionId",
    },
  );

  var document = parse(response.body);

  var currentUrl =
      "https://${response.request?.url.host}${response.request?.url.path}";
  if (currentUrl == SCOMB_LOGGED_OUT_PAGE_URL) {
    throw Exception("セッションIDの有効期限切れ");
  }

  _constructSurveys(document);
}

void _constructSurveys(Document document) {
  var contents = document.getElementsByClassName("result-list");

  for (var row in contents) {
    if (row.children.length < 7) continue;
    var surveyId = row.children[0].attributes["value"];
    var classId = row.children[1].attributes["value"];

    // if this survey is done, skip this
    if (row.children[2]
        .getElementsByClassName("portal-surveys-status")
        .isNotEmpty) continue;

    var title = row.children[2].children[0].text;

    if (row.children[3].children.length < 3) continue;
    var deadline = row.children[3].children[2].text;

    if (row.children[5].children.isEmpty) continue;
    var surveyDomain = row.children[5].children[0].text;

    var newSurvey = Task(
      title,
      surveyDomain,
      TaskType.Survey,
      stringToTime(deadline, includeSecond: false),
      null,
      surveyId,
      classId,
    );
    print(newSurvey);
    if (taskList != null) {
      taskList!.add(newSurvey);
    } else {
      taskList = [];
    }
  }
}
