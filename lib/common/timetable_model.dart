import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';

import '../ui/dialog/new_class_cell_dialog.dart';
import 'db/class_cell.dart';

class TimetableModel {
  TimetableModel(this.title, this.isUserClassCell) {
    cells = createEmptyTimetable();
  }

  late List<List<ClassCell?>> cells;
  String title;
  bool isUserClassCell;

  @override
  String toString() {
    var s = "TimetableModel.$title{";
    applyToAllCells((classCell) {
      s += "${classCell?.name ?? ""},";
    });
    return "$s}";
  }

  int getSumOfNumberOfCredit() {
    var sum = 0;
    List<ClassCell> alreadyCountedClass = [];
    applyToAllCells((classCell) {
      if (classCell?.numberOfCredit != null &&
          !alreadyCountedClass.contains(classCell)) {
        sum += classCell!.numberOfCredit!;
        alreadyCountedClass.add(classCell);
      }
    });
    return sum;
  }

  void clearTimetable() {
    for (int r = 0; r < cells.length; r++) {
      for (int c = 0; c < cells[0].length; c++) {
        cells[r][c] = null;
      }
    }
  }

  Future<void> addCell(ClassCell cell) async {
    var db = await AppDatabase.getDatabase();

    // remove old cell
    var oldCell = cells[cell.period][cell.dayOfWeek];
    if (oldCell != null) {
      await removeCell(oldCell, db);
    }

    await db.currentClassCellDao.insertClassCell(cell);
    if (cell.period >= 0 && cell.dayOfWeek >= 0) {
      cells[cell.period][cell.dayOfWeek] = cell;
    }
  }

  Future<void> applyToAllCells(
      void Function(ClassCell? classCell) process) async {
    for (int r = 0; r < cells.length; r++) {
      for (int c = 0; c < cells[0].length; c++) {
        process(cells[r][c]);
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

  Future<void> removeCell(ClassCell cell, AppDatabase db) async {
    if (cell.period >= 0 && cell.dayOfWeek >= 0) {
      cells[cell.period][cell.dayOfWeek] = null;
    }
    print("removed $cell");
    await db.currentClassCellDao.removeClassCell(cell);
  }

  Future<void> showNewClassCellDialog(int row, int col, BuildContext context,
      {ClassCell? classCell}) async {
    ClassCell? dialogResponse = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return NewClassCellDialog(
          row,
          col,
          this,
          editingClassCell: classCell,
        );
      },
    );

    if (dialogResponse != null) {
      await addCell(dialogResponse);
    }
  }

  Map<int, int> getColorAndCreditMap() {
    Map<int, int> colorAndCreditMap = {};

    applyToAllCells((classCell) {
      if (classCell != null) {
        if (colorAndCreditMap[
                classCell.customColorInt ?? Colors.white70.value] !=
            null) {
          colorAndCreditMap[classCell.customColorInt ?? Colors.white70.value] =
              colorAndCreditMap[
                      classCell.customColorInt ?? Colors.white70.value]! +
                  (classCell.numberOfCredit ?? 0);
        } else {
          colorAndCreditMap[classCell.customColorInt ?? Colors.white70.value] =
              classCell.numberOfCredit ?? 0;
        }
      }
    });

    return colorAndCreditMap;
  }
}
