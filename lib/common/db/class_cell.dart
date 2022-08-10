class ClassCell {
  String classId;
  String name;
  String teachers;
  String room;
  int dayOfWeek;
  int period;
  int year;
  int term;
  late String id;

  ClassCell(
    this.classId,
    this.name,
    this.teachers,
    this.room,
    this.dayOfWeek,
    this.period,
    this.year,
    this.term,
  ) {
    id = "$year:$term-$dayOfWeek:$period-$classId";
  }

  @override
  String toString() {
    return "ClassCell { id = $id, classId=$classId, name=$name, teachers=$teachers, room=$room, dayOfWeek=$dayOfWeek, period=$period, year=$year, term=$term }";
  }
}
