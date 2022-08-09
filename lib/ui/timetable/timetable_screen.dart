import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/ui/timetable/class_cell.dart';

import '../../common/scraping.dart';
import '../../common/values.dart';
import '../login/login_screen.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("時間割"),
      ),
      body: Column(
        children: [
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
            child: const Text("ログイン画面へ"),
          ),
          ElevatedButton(
            onPressed: () async {
              var timetable = await getTimetableArray(
                2022,
                Term.FIRST,
              );
              Fluttertoast.showToast(
                msg: "timetable : $timetable",
              );
            },
            child: const Text("時間割画面"),
          ),
        ],
      ),
    );
  }

  // if returned null, permission denied
  Future<List<List<ClassCell?>>?> getTimetableArray(int year, int term) async {
    // var doc = await fetchTimetable(sessionId, year, term);
    var doc = await fetchTimetable(
      sessionId,
      year,
      term,
    );
    if (doc == null) {
      return null;
    }

    List<List<ClassCell?>> timetable = List.filled(7, List.filled(6, null));

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

        if (id == null || room == null) continue;
        var newCell = ClassCell(id, name, teachers, room, c, r, year, term);
        timetable[r][c] = newCell;
        print("fetched_timetable : $newCell");
      }
    }
    return timetable;
  }
}
