import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/login_exception.dart';
import 'package:scomb_mobile/common/values.dart';

import '../db/class_cell.dart';
import '../shared_resource.dart';

// if returned null, permission denied
Future<void> fetchTimetable(
  String? sessionId,
  int year,
  String term,
) async {
  var url = "$SCOMB_TIMETABLE_URL?risyunen=$year&kikanCd=$term";

  var dio = Dio();
  dio.options.baseUrl = url;

  Response? response = await dio.get(
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
    throw LoginException("セッションIDの有効期限切れ");
  }

  await _constructTimetableArray(document, year, term);
}

Future<void> _constructTimetableArray(
    Document doc, int year, String term) async {
  var db = await AppDatabase.getDatabase();

  var timetableRows = doc.getElementsByClassName(TIMETABLE_ROW_CSS_CLASS_NM);
  for (var r = 0; r < timetableRows.length; r++) {
    var timetableCells =
        timetableRows[r].getElementsByClassName(TIMETABLE_CELL_CSS_CLASS_NM);
    for (var c = 0; c < timetableCells.length; c++) {
      var timetableCell = timetableCells[c];

      // if no class
      if (timetableCell.children.isEmpty) continue;

      // get header and detail element
      var cellHeader = timetableCell
          .getElementsByClassName(TIMETABLE_CELL_HEADER_CSS_CLASS_NM);
      if (cellHeader.isEmpty) continue;
      var cellDetail = timetableCell
          .getElementsByClassName(TIMETABLE_CELL_DETAIL_CSS_CLASS_NM);
      if (cellDetail.isEmpty) continue;

      // header
      var id = cellHeader[0].attributes["id"];
      var name = cellHeader[0].text;

      // detail
      if (cellDetail[0].children.isEmpty) continue;
      var room = cellDetail[0].children[0].attributes["title"];
      var teachers = "";
      for (var teacher in cellDetail[0].children[0].children) {
        if (teacher.text != "【教室】") {
          teachers += teacher.text;
        }
      }

      if (id == null) continue;
      var newCell = ClassCell(
        id,
        r,
        c,
        false,
        "$year-$term",
        year,
        term,
        name,
        teachers,
        room,
        null,
        CLASS_PAGE_URL.replaceFirst("\${classId}", id),
        null,
        null,
        null,
      );
      sharedTimetable.timetable[r][c] = newCell;

      // merge old timetable and new one
      var classCellFromDB =
          await db.currentClassCellDao.getClassCellByClassId(newCell.classId);
      print("class_from_db : $classCellFromDB");
      newCell.customColorInt = classCellFromDB?.customColorInt;
      newCell.note = classCellFromDB?.note;
      await db.currentClassCellDao.insertClassCell(newCell);

      print("class_from_server : $newCell");
    }
  }
}
