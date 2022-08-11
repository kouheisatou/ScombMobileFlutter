import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';

@Entity(tableName: "class_cell")
class ClassCell {
  @primaryKey
  String classId;
  String name;
  String teachers;
  String room;
  int dayOfWeek;
  int period;
  int year;
  int term;
  int? customColorInt;

  ClassCell(this.classId, this.name, this.teachers, this.room, this.dayOfWeek,
      this.period, this.year, this.term, this.customColorInt);

  Future<void> setColor(int? colorInt) async {
    if (colorInt == null) return;
    var db = await AppDatabase.getDatabase();
    customColorInt = colorInt;
    await db.currentClassCellDao.insertClassCell(this);
  }

  @override
  String toString() {
    return "ClassCell { classId=$classId, name=$name, teachers=$teachers, room=$room, dayOfWeek=$dayOfWeek, period=$period, year=$year, term=$term, customColor=$customColorInt }";
  }
}
