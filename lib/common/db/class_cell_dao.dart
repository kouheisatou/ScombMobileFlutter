import 'package:floor/floor.dart';

import 'class_cell.dart';

@dao
abstract class ClassCellDao {
  @Query("SELECT * FROM class_cell")
  Future<List<ClassCell>> getAllClasses();

  @Query("SELECT * FROM class_cell WHERE classId = :classId LIMIT 1")
  Future<ClassCell?> getClassCellByClassId(String classId);

  @Query("SELECT * FROM class_cell WHERE cellId = :cellId")
  Future<ClassCell?> getClassCellByCellId(String cellId);

  @insert
  Future<void> insertClassCell(ClassCell classCell);
}
