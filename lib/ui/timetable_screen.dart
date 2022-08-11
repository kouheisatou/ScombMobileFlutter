import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/network_screen.dart';
import 'package:scomb_mobile/common/scraping/timetable_scraping.dart';

import '../common/db/scomb_mobile_database.dart';
import '../common/values.dart';

class TimetableScreen extends NetworkScreen {
  TimetableScreen(super.parent, super.title, {Key? key}) : super(key: key);

  @override
  State<TimetableScreen> createState() {
    return _TimetableScreenState();
  }
}

class _TimetableScreenState extends NetworkScreenState<TimetableScreen> {
  _TimetableScreenState();

  @override
  Future<void> getFromServerAndSaveToSharedResource(savedSessionId) async {
    // todo recover from timetable setting
    var yearFromSettings = 2022;
    var termFromSettings = Term.FIRST;

    await fetchTimetable(
      sessionId ?? savedSessionId,
      yearFromSettings,
      termFromSettings,
    );
  }

  @override
  Widget innerBuild() {
    return DefaultTextStyle(
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10, color: Colors.black),
      child: buildTable(),
    );
  }

  Widget buildTable() {
    // day of week row
    List<Widget> tableRows = [buildDayOfWeekRow()];

    // main rows
    for (int r = 0; r < timetable.length; r++) {
      tableRows.add(buildTableRow(r));
    }

    return Column(
      children: tableRows,
    );
  }

  Row buildDayOfWeekRow() {
    List<Widget> dayOfWeekCells = [];
    // day of week row
    dayOfWeekCells.add(
      const Text(" 　"),
    );
    DAY_OF_WEEK.forEach(
      (key, value) {
        dayOfWeekCells.add(
          Expanded(
            child: Center(
              child: Text(value),
            ),
          ),
        );
      },
    );

    return Row(children: dayOfWeekCells);
  }

  Widget buildTableRow(int row) {
    List<Widget> tableCells = [];

    // period column
    tableCells.add(
      Container(
        child: Center(
          child: Text(textAlign: TextAlign.center, PERIOD[row] ?? ""),
        ),
      ),
    );

    // main columns
    for (int c = 0; c < timetable[0].length; c++) {
      tableCells.add(buildTableCell(row, c));
    }

    return Expanded(child: Row(children: tableCells));
  }

  Widget buildTableCell(int row, int col) {
    return Expanded(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: timetable[row][col] == null
            ? const Text("")
            : MaterialButton(
                color: Color(timetable[row][col]?.customColorInt ??
                    Colors.white70.value),
                onPressed: () async {
                  await timetable[row][col]?.setColor(Colors.red.value);
                  setState(() {});
                },
                onLongPress: () async {
                  var db = await AppDatabase.getDatabase();
                  var classCellFromDB = await db.currentClassCellDao
                      .getClassCell(timetable[row][col]?.classId ?? "");
                  print(classCellFromDB);

                  Fluttertoast.showToast(msg: timetable[row][col]?.room ?? "");
                },
                child: Text(
                  timetable[row][col]?.name ?? "",
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }
}
