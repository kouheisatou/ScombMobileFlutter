import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/parser.dart';
import 'package:scomb_mobile/common/db/class_cell.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';

import '../timetable_model.dart';

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

Future<ClassCell?> fetchClassDetail(
  String url,
  TimetableModel timetable,
) async {
  Dio dio = Dio();
  Response? response = await dio.get(url);
  var document = parse(response.data);

  ClassCell? result;

  try {
    String? name =
        document.body?.children[0].children[0].children[0].children[0].text;

    String? teacher = document.body?.children[0].children[0].children[3]
        .children[0].children[0].children[0].children[0].children[2].text;
    print(teacher ?? "null");

    String? syllabusUrl = document
        .body
        ?.children[0]
        .children[0]
        .children[5]
        .children[1]
        .children[2]
        .children[0]
        .children[1]
        .children[1]
        .children[0]
        .children[0]
        .attributes["href"];

    var infoTable = document.body?.children[0].children[0].children[5]
        .children[0].children[0].children[0];

    String? room = infoTable?.children[3].children[1].text;

    var classTimeString = infoTable?.children[1].children[1].text
        .replaceAll("１", "1")
        .replaceAll("２", "2")
        .replaceAll("３", "3")
        .replaceAll("４", "4")
        .replaceAll("５", "5")
        .replaceAll("６", "6")
        .replaceAll("７", "7");
    String? periodString = classTimeString?.substring(2, 4);
    String? dayOfWeekString = classTimeString?.substring(0, 2);
    int? period = findMapKeyFromValue<int, String>(PERIOD_MAP, periodString!);
    int? dayOfWeek =
        findMapKeyFromValue<int, String>(DAY_OF_WEEK_MAP, dayOfWeekString!);

    if (name == null || period == null || dayOfWeek == null) {
      return null;
    }

    result = ClassCell.user(
      "${timetable.title}/user_class_cell/${DateTime.now().millisecondsSinceEpoch}",
      period,
      dayOfWeek,
      true,
      timetable.title,
      null,
      null,
      name,
      teacher,
      room,
      null,
      null,
      null,
      syllabusUrl,
      timetable,
      0,
    );
  } catch (e, stacktrace) {
    print(e);
    print(stacktrace);
    Fluttertoast.showToast(msg: "授業詳細を取得できませんでした");
  }

  return result;
}
