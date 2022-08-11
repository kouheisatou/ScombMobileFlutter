import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/network_screen.dart';
import 'package:scomb_mobile/common/scraping/timetable_scraping.dart';

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

  Table buildTable() {
    for (int r = 0; r < timetable.length; r++) {
      for (int c = 0; c < timetable[0].length; c++) {
        print("$r-$c : ${timetable[r][c]?.name}");
      }
    }

    List<TableRow> tableRows = [];

    // day of week row
    List<TableCell> dayOfWeekCells = [const TableCell(child: Text(""))];
    DAY_OF_WEEK.forEach((key, value) {
      dayOfWeekCells.add(TableCell(child: Center(child: Text(value))));
    });
    var dayOfWeekRow = TableRow(children: dayOfWeekCells);
    tableRows.add(dayOfWeekRow);

    // main rows
    for (int r = 0; r < timetable.length; r++) {
      tableRows.add(buildTableRow(r));
    }
    return Table(
      children: tableRows,
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
      },
    );
  }

  TableRow buildTableRow(int row) {
    List<TableCell> tableCells = [];

    // period column
    tableCells.add(
      TableCell(
        child: Center(
          child: Text(textAlign: TextAlign.center, PERIOD[row] ?? ""),
        ),
      ),
    );

    // main columns
    for (int c = 0; c < timetable[0].length; c++) {
      tableCells.add(buildTableCell(row, c));
    }

    return TableRow(children: tableCells);
  }

  TableCell buildTableCell(int row, int col) {
    return TableCell(
      child: timetable[row][col] == null
          ? const Text("")
          : OutlinedButton(
              onPressed: () {
                Fluttertoast.showToast(msg: timetable[row][col]?.room ?? "");
              },
              child: Text(
                timetable[row][col]?.name ?? "",
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
