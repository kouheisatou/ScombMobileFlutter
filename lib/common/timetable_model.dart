import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';

import 'db/class_cell.dart';

class TimetableModel {
  TimetableModel(this.title, this.timetable);
  TimetableModel.empty(this.title) {
    timetable = createEmptyTimetable();
  }

  late List<List<ClassCell?>> timetable;
  String title;

  @override
  String toString() {
    var s = "TimetableModel.$title{";
    applyToAllCells((classCell) {
      s += "${classCell?.name ?? ""},";
    });
    return "$s}";
  }

  void clearTimetable() {
    for (int r = 0; r < timetable.length; r++) {
      for (int c = 0; c < timetable[0].length; c++) {
        timetable[r][c] = null;
      }
    }
  }

  Future<void> applyToAllCells(
      void Function(ClassCell? classCell) process) async {
    for (int r = 0; r < timetable.length; r++) {
      for (int c = 0; c < timetable[0].length; c++) {
        process(timetable[r][c]);
      }
    }
  }

  List<List<ClassCell?>> createEmptyTimetable() {
    List<List<ClassCell?>> timetable = [
      [null, null, null, null, null, null],
      [null, null, null, null, null, null],
      [null, null, null, null, null, null],
      [null, null, null, null, null, null],
      [null, null, null, null, null, null],
      [null, null, null, null, null, null],
      [null, null, null, null, null, null],
    ];
    return timetable;
  }

  Future<void> removeAllCell() async {
    var db = await AppDatabase.getDatabase();

    await applyToAllCells((classCell) {
      if (classCell != null) {
        removeCell(classCell, db);
      }
    });
  }

  Future<void> removeCell(ClassCell cell, AppDatabase db) async {
    await db.currentClassCellDao.removeClassCell(cell);
    timetable[cell.period][cell.dayOfWeek] = null;
  }
}