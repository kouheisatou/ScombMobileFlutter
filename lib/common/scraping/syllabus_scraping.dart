import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:scomb_mobile/common/utils.dart';
// import 'package:http/http.dart';

Future<Map<String, String>> fetchAllSyllabusSearchResult(String url) async {
  Map<String, String> result = {};

  Dio dio = Dio();
  Response? response = await dio.get<List<int>>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );

  var bodyString = await convertEUCJPtoUTF8(response.data);

  var document = parse(bodyString);

  for (int i = 0; i < 200; i++) {
    var searchResult = document.getElementById("hit_$i");
    if (searchResult == null) continue;

    result[searchResult.text] = searchResult.attributes["href"] ?? "";
  }

  return result;
}
