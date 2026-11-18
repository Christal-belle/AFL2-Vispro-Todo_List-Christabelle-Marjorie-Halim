import '../models/task_model.dart';

abstract class TaskDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> saveTasks(List<TaskModel> tasks);
}