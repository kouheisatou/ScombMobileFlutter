import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:scomb_mobile/common/values.dart';

Future<Document?> getTimetable(
  String sessionId,
  int year,
  Term term,
) async {
  int termInt = 10;
  if (term == Term.First) {
    termInt = 10;
  } else {
    termInt = 20;
  }

  var url = "$SCOMB_TIMETABLE_URL?risyunen=$year&kikanCd=$termInt";

  var dio = Dio();

  var response = await dio.get(
    url,
    options: Options(
      headers: {
        "Cookie": "$SESSION_COOKIE_ID=$sessionId",
      },
    ),
  );

  var document = parse(response.data);

  return document;
}
