import '../models/task_model.dart';
import 'task_datasource.dart';

class MockTaskDataSource implements TaskDataSource {
  List<TaskModel> _mockStorage = [
    const TaskModel(
      id: 'mock-1',
      title: '[MOCK] Kerjakan laporan arsitektur MVVM',
      isCompleted: false,
    ),
    const TaskModel(
      id: 'mock-2',
      title: '[MOCK] Rekam bukti 1-line data-source swap',
      isCompleted: true,
    ),
  ];

  @override
  Future<List<TaskModel>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List<TaskModel>.from(_mockStorage);
  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockStorage = List<TaskModel>.from(tasks);
  }
}