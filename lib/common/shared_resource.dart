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
List<Task> taskList = [];
bool taskListInitialized = false;

void addOrReplaceTask(Task newTask) {
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
