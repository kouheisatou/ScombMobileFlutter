// shared resource
import 'db/class_cell.dart';
import 'db/task.dart';

String? sessionId;
String? userName;
List<List<ClassCell?>> timetable = [
  [null, null, null, null, null, null],
  [null, null, null, null, null, null],
  [null, null, null, null, null, null],
  [null, null, null, null, null, null],
  [null, null, null, null, null, null],
  [null, null, null, null, null, null],
  [null, null, null, null, null, null],
];
List<Task>? taskList = [];
