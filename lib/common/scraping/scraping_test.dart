import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../values.dart';

void main() async {
  var sessionId = "ZjdmM2FiYzgtOWUxMy00MDFiLTllMGYtZGU3MzdlNjI5ZmMz";

  Response? response;
  try {
    response = await http.get(
      Uri.parse(SURVEY_LIST_PAGE_URL),
      headers: {
        "Cookie": "$SESSION_COOKIE_ID=$sessionId",
      },
    );
  } catch (e) {
    return null;
  }

  var document = parse(response.body);

  var contents = document.getElementsByClassName("result-list");

  contents.forEach((element) {
    print(element.text);
  });
}
