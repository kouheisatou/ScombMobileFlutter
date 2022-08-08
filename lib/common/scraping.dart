import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
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

  final url = "$SCOMB_TIMETABLE_URL?risyunen=$year&kikanCd=$termInt";

  final response = await http.get(
    Uri.parse(url),
    headers: {SESSION_COOKIE_ID: sessionId},
  );

  if (response.statusCode != 200) {
    print('ERROR: ${response.statusCode}');
    return null;
  }

  final document = parse(response.body);

  return document;
}
