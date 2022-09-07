import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';

import '../ui/dialog/new_class_cell_dialog.dart';
import 'db/class_cell.dart';

class TimetableModel {
  TimetableModel(this.title, this.timetable, this.header);
  TimetableModel.empty(this.title) {
    timetable = createEmptyTimetable();
    header = ClassCell(
      "$title/timetable_header",
      "",
      "",
      "",
      -1,
      -1,
      0,
      title,
      null,
      null,
      0,
      0,
      null,
      "",
    );
  }

  late List<List<ClassCell?>> timetable;
  String title;
  late ClassCell header;

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

  Future<void> addCell(ClassCell cell) async {
    var db = await AppDatabase.getDatabase();
    await db.currentClassCellDao.insertClassCell(cell);
    if (cell.period >= 0 && cell.dayOfWeek >= 0) {
      timetable[cell.period][cell.dayOfWeek] = cell;
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

    await applyToAllCells((classCell) async {
      if (classCell != null) {
        await removeCell(classCell, db);
      }
    });
    await removeCell(header, db);
  }

  Future<void> removeCell(ClassCell cell, AppDatabase db) async {
    await db.currentClassCellDao.removeClassCell(cell);
    print("removed $cell");
    if (cell.period >= 0 && cell.dayOfWeek >= 0) {
      timetable[cell.period][cell.dayOfWeek] = null;
    }
  }

  Future<void> showNewClassCellDialog(int row, int col, BuildContext context,
      {ClassCell? classCell}) async {
    var dialog = NewClassCellDialog(
      row,
      col,
      this,
      editingClassCell: classCell,
    );

    await showDialog(
      context: context,
      builder: (_) {
        return dialog;
      },
    );

    dialog.editingClassCell.resetCellId();
    await addCell(dialog.editingClassCell);
  }
}
