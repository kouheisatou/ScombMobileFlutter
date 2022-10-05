import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';

import '../timetable_model.dart';
import 'class_cell.dart';

@dao
abstract class ClassCellDao {
  @Query("SELECT * FROM class_cell")
  Future<List<ClassCell>> getAllClasses();

  @Query("SELECT * FROM class_cell WHERE timetableTitle = :timetableTitle")
  Future<List<ClassCell>> getCells(String timetableTitle);

  @Query(
      "SELECT * FROM class_cell WHERE classId = :classId AND isUserClassCell = 0 LIMIT 1")
  Future<ClassCell?> getCurrentClassCellByClassId(String classId);

  @insert
  Future<void> insertClassCell(ClassCell classCell);

  @delete
  Future<void> removeClassCell(ClassCell classCell);

  @Query("DELETE FROM class_cell WHERE timetableTitle = :timetableTitle")
  Future<void> removeTimetable(String timetableTitle);
}

Future<Map<String, TimetableModel>> getAllTimetables({
  required Function(Map<String, TimetableModel> result) onFetchFinished,
}) async {
  Map<String, TimetableModel> timetables = {};

  var db = await AppDatabase.getDatabase();
  var allCells = await db.currentClassCellDao.getAllClasses();

  for (var cell in allCells) {
    // if my timetable, year is 0
    if (cell.isUserClassCell) {
      // new timetable model
      if (timetables[cell.timetableTitle] == null) {
        timetables[cell.timetableTitle] = TimetableModel(
          cell.timetableTitle,
          true,
        );
      }

      // insert to map
      cell.currentTimetable = timetables[cell.timetableTitle]!;
      if (cell.period >= 0 && cell.dayOfWeek >= 0) {
        timetables[cell.timetableTitle]!.cells[cell.period][cell.dayOfWeek] =
            cell;
      }
    }
  }

  timetables.forEach((key, value) {
    print(value);
  });

  onFetchFinished(timetables);

  return timetables;
}
