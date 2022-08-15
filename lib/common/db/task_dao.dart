import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/db/task.dart';

@dao
abstract class TaskDao {
  @insert
  Future<void> insertTask(Task task);

  @Query("SELECT * FROM task")
  Future<List<Task>> getAllTasks();

  @Query("SELECT * FROM task WHERE id = :id")
  Future<Task?> getTask(String id);

  @Query("DELETE FROM task WHERE id = :id")
  Future<void> removeTask(String id);
}
