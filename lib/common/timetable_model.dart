import 'package:scomb_mobile/common/shared_resource.dart';
import 'package:scomb_mobile/ui/component/timetable.dart';

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
    applyToAllCells(timetable, (classCell) {
      s += "${classCell?.name ?? "null"},";
    });
    return "$s}";
  }
}
