import 'package:floor/floor.dart';

import 'class_cell.dart';

@dao
abstract class ClassCellDao {
  @Query("SELECT * FROM class_cell")
  Future<List<ClassCell>> getAllClasses();

  @Query("SELECT * FROM class_cell WHERE classId = :classId")
  Future<ClassCell?> getClassCell(String classId);

  // onConflict = replace
  // fix OnConflictStrategy.abort -> OnConflictStrategy.replace in scomb_mobile_database.g.dart after generate
  @insert
  Future<void> insertClassCell(ClassCell classCell);

  // @Query(
  //     "UPDATE class_cell SET customColorInt = :newColorInt WHERE classId = :classId")
  // Future<void> updateColor(String classId, int newColorInt);
}
