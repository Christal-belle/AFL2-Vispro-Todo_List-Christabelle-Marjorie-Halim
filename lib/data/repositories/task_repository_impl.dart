import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDataSource dataSource;

  TaskRepositoryImpl({required this.dataSource});

  @override
  Future<List<Task>> getTasks() async {
    return await dataSource.getTasks();
  }

  @override
  Future<void> addTask(Task task) async {
    final tasks = await dataSource.getTasks();
    tasks.add(TaskModel.fromEntity(task));
    await dataSource.saveTasks(tasks);
  }

  @override
  Future<void> updateTask(Task task) async {
    final tasks = await dataSource.getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = TaskModel.fromEntity(task);
      await dataSource.saveTasks(tasks);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    final tasks = await dataSource.getTasks();
    tasks.removeWhere((t) => t.id == id);
    await dataSource.saveTasks(tasks);
  }
}