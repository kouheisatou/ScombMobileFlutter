import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:scomb_mobile/common/login_exception.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';

import '../db/scomb_mobile_database.dart';
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
    throw LoginException("セッションIDの有効期限切れ");
  }

  await _constructSurveys(document);
}

Future<void> _constructSurveys(Document document) async {
  var db = await AppDatabase.getDatabase();

  var contents = document.getElementsByClassName("result-list");

  for (var row in contents) {
    if (row.children.length < 7) continue;
    var surveyId = row.children[0].attributes["value"];
    var classId = row.children[1].attributes["value"];

    if (surveyId == null || classId == null) continue;

    // if this survey is done, skip this
    var isDone = false;
    row.children[2]
        .getElementsByClassName("portal-surveys-status")
        .forEach((tag) {
      if (tag.text == "済み") {
        isDone = true;
      }
    });

    var title = row.children[2].children[0].text;

    if (row.children[3].children.length < 3) continue;
    var deadline = row.children[3].children[2].text;

    if (row.children[5].children.isEmpty) continue;
    var surveyDomain = row.children[5].children[0].text;

    // custom color from timetable
    int? customColor;
    var classCellFromDB =
        await db.currentClassCellDao.getCurrentClassCellByClassId(classId);
    customColor = classCellFromDB?.customColorInt;

    String url;
    // surveys from others
    if (classId == "") {
      url = "$SURVEY_PAGE_URL?surveyId=$surveyId";
    }
    // surveys from LMS
    else {
      url = "$LMS_SURVEY_PAGE_URL?idnumber=$classId&surveyId=$surveyId";
    }

    var newSurvey = Task(
      title,
      surveyDomain,
      TaskType.SURVEY,
      stringToTime(deadline, includeSecond: false),
      url,
      surveyId,
      classId,
      customColor,
      false,
      isDone,
    );

    // if already exists, merge task
    addOrReplaceTask(newSurvey, true);
  }
}
