import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local_task_datasource.dart';
// ignore: unused_import
import '../../data/datasources/mock_task_datasource.dart';
import '../../data/datasources/task_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../presentation/viewmodels/task_viewmodel.dart';

class ServiceLocator {
  const ServiceLocator._();

  static late final TaskRepository taskRepository;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final TaskDataSource dataSource = LocalTaskDataSource(sharedPreferences: prefs);
    //final TaskDataSource dataSource = MockTaskDataSource();

    taskRepository = TaskRepositoryImpl(dataSource: dataSource);
  }
  static TaskViewModel createTaskViewModel() {
    return TaskViewModel(repository: taskRepository);
  }
}