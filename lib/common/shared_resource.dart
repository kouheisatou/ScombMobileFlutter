// shared resource
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/notification.dart';
import 'package:scomb_mobile/ui/component/timetable.dart';

import 'db/class_cell.dart';
import 'db/task.dart';

String? sessionId;
String? userName;

List<List<ClassCell?>> sharedTimetable = createEmptyTimetable();
bool timetableInitialized = false;
int? timetableYear;
String? timetableTerm;
void clearTimetable() {
  for (int r = 0; r < sharedTimetable.length; r++) {
    for (int c = 0; c < sharedTimetable[0].length; c++) {
      sharedTimetable[r][c] = null;
    }
  }
}

Future<void> applyToAllCells(List<List<ClassCell?>> timetable,
    void Function(ClassCell? classCell) process) async {
  for (int r = 0; r < timetable.length; r++) {
    for (int c = 0; c < timetable[0].length; c++) {
      process(timetable[r][c]);
    }
  }
}

// ------------- task_list-----------
List<Task> taskList = [];
bool taskListInitialized = false;
void sortTasks() {
  taskList.sort((a, b) => a.deadline.compareTo(b.deadline));
}

void addOrReplaceTask(Task newTask, bool fromServer) {
  // deadline over
  if (newTask.deadline < DateTime.now().millisecondsSinceEpoch) return;

  // detect conflicting
  int? conflictedTaskIndex;
  for (int i = 0; i < taskList.length; i++) {
    if (taskList[i] == newTask) {
      conflictedTaskIndex = i;
    }
  }

  if (fromServer) {
    if (conflictedTaskIndex == null) {
      taskList.add(newTask);
      print("task_from_scomb(add) : $newTask");
    }
    // on conflict, replace task
    else {
      taskList.removeAt(conflictedTaskIndex);
      taskList.add(newTask);
      // add from server and replace -> scomb task is done
      print("task_from_scomb(replace) : $newTask");
    }
  } else {
    if (conflictedTaskIndex == null) {
      taskList.add(newTask);
      // for judging if scomb task done
      if (!newTask.addManually) {
        newTask.done = true;
      }
      print("task_from_db(add) : $newTask");
    }
    // on conflict, replace task
    else {
      taskList.removeAt(conflictedTaskIndex);
      taskList.add(newTask);
      print("task_from_db(replace) : $newTask");
    }
  }

  _saveToDB(newTask);
}

Future<void> _saveToDB(Task newTask) async {
  var db = await AppDatabase.getDatabase();

  // does not exist in db, register notification
  var tasksFromDB = await db.currentTaskDao.getAllTasks();
  var isAlreadyExists = false;
  for (var taskFromDb in tasksFromDB) {
    if (taskFromDb.id == newTask.id) {
      isAlreadyExists = true;
      break;
    }
  }
  if (!isAlreadyExists) {
    registerTaskNotification(newTask, db: db);
  }

  // replace
  db.currentTaskDao.insertTask(newTask);
}
