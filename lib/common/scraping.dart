import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:scomb_mobile/common/values.dart';

Future<Document?> fetchTimetable(
  String? sessionId,
  int year,
  int term,
) async {
  var url = "$SCOMB_TIMETABLE_URL?risyunen=$year&kikanCd=$term";

  var dio = Dio();
  dio.options.baseUrl = url;

  var response = await dio.get(
    url,
    options: Options(
      headers: {
        "Cookie": "$SESSION_COOKIE_ID=$sessionId",
      },
    ),
  );

  var document = parse(response.data);
  var currentUrl = "https://${response.realUri.host}${response.realUri.path}";

  if (currentUrl == SCOMB_LOGGED_OUT_PAGE_URL) {
    return null;
  } else {
    return document;
  }
}

Future<Document?> fetchTasks() async {
  var response = await Dio().get(
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
    return null;
  } else {
    return document;
  }
}
