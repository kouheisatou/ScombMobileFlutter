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
bool timetableInitialized = false;
int? timetableYear;
int? timetableTerm;
void clearTimetable() {
  for (int r = 0; r < timetable.length; r++) {
    for (int c = 0; c < timetable[0].length; c++) {
      timetable[r][c] = null;
    }
  }
}

List<Task> taskList = [];
bool taskListInitialized = false;

void addOrReplaceTask(Task newTask) {
  // deadline over
  if (newTask.deadline < DateTime.now().millisecondsSinceEpoch) return;

  // detect conflicting
  int? conflictedTaskIndex;
  for (int i = 0; i < taskList.length; i++) {
    if (taskList[i] == newTask) {
      conflictedTaskIndex = i;
    }
  }

  if (conflictedTaskIndex == null) {
    taskList.add(newTask);
  }
  // on conflict, replace task
  else {
    taskList.removeAt(conflictedTaskIndex);
    taskList.add(newTask);
  }
}
